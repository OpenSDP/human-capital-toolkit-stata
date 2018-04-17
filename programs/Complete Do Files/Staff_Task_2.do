/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Staff_Task_2.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program generates a clean Staff_Certifications file unique
* by tid school_year.
* The core of this task:
* 1. Identify teachers with special certifications, such as English as a Second Language (ESL), Special Education, and National Board Certification. 
* 2. Use teachers’ effective certification and effective expiration dates to determine the school years in which teachers became certified and their certifications expired.  
* 3. Ensure that you have one record per teacher per year.
*
* Inputs: /raw/Staff_Certifications.dta
*
* Outputs: /clean/Staff_Certifications_Clean.dta
*
***************************************************************************/

clear 
set more off
cap log close

// Change the file path below to the directory with folders for data, logs, programs and tables and figures.
cd "K:\working_files"

global raw		".\data\raw"
global clean	".\data\clean"
// Create a folder for log files in the top level directory if one does not exist already.
global log 		".\logs"

log using "${log}\Staff_Task_2.txt", text replace

/*** Step 0: Load the Staff_Certifications raw input file ***/
	use "${raw}/Staff_Certifications.dta", clear

/*** Step 1: Create consistent values for certification_code ***/ 

// 1. String fields entered by hand often contain spelling errors and nonstandard terms. Tabulate certification_code to examine the data. 
	tab certification_code, mi
	
// 2. There are 16 unique values for certification_code but many appear to indicate the same certifications. 
// Some of these can be combined by changing all values to uppercase.  
	replace certification_code = upper(certification_code) 

// 3. Use a for loop with the index command to replace the remaining nonstandard terms with one consistent value. 
// The index command assigns one value to all values that contain a specified phrase. For example, every value that contains 
// the word "ESL" will be reassigned the value "ENGLISH AS A SECOND LANGUAGE" in the command below.  
	foreach esl in "ELS" "ESL" { 
		replace certification_code = "ENGLISH AS A SECOND LANGUAGE CERTIFICATION" if index(certification_code, "`esl'") 
	}
		
	foreach nb in "BOARD" "NATL" "NB" { 
		replace certification_code = "NATIONAL BOARD CERTIFICATION" if index(certification_code, "`nb'") 
	}
	
	foreach sped in "SPECIAL" "SPED" { 
		replace certification_code = "SPECIAL EDUCATION CERTIFICATION" if index(certification_code, "`sped'") 
	} 

// 4. Check that there is only one unique value for each certification.
	tab certification_code, mi
	
	assert certification_code == "ENGLISH AS A SECOND LANGUAGE CERTIFICATION" | ///
		certification_code == "NATIONAL BOARD CERTIFICATION" | ///
		certification_code == "SPECIAL EDUCATION CERTIFICATION"

/*** Step 2. Identify the school years in which a teacher’s certification is valid. ***/

// 1. Reformat effective and expiration dates to Stata date format.
	foreach var of varlist effective_date expiration_date { 
	      gen `var'_num = date(`var', "MDY") 
	      format `var'_num %td 
	      drop `var' 
	      rename `var'_num `var' 
	} 

// 2. Identify the school years in which a certificate is valid. Generate variables that indicate the school year and month 
// in which a certificate became effective and a certificate expired.
	foreach date in effective_date expiration_date { 
	      gen `date'_year = year(`date') 
	      gen `date'_month = month(`date') 
	} 

// 3. A certificate is valid during a particular school year if the certification effective date lies between May 1 
// of the previous school year and April 30 of the current school year. 
// To align the year and month variables just created with the standard of defining a school year by the spring year, add one year 
// to effective_date_year if certification effective dates fall between May and December. 
// No changes need to be made for certificates with effective dates between January and April. 
	
	replace effective_date_year = effective_date_year + 1 if effective_date_month>=5 & effective_date_month<=12

	// A certificate that expires before October 1 of the current school year is valid only through the end of the previous school year. 
	// No changes need to be made to expiration_date_year for certificates that expire between January and September. 
	// A certificate that expires between October 1 and April 30 of the current school year will be valid until the end of the current school year. 
	// Add one year to expiration_date_year if a certificate expires between October and December to align with defining a school year by the spring year. 
	replace expiration_date_year = expiration_date_year+1 if expiration_date_month>=10 & expiration_date_month<=12 
	
// 4. Drop observations that are missing both effective_date_year and expiration_date_year. These observations pertain to teachers 
// and certification codes with no evidence of an effective and expiration year. 
	drop if mi(effective_date_year) & mi(expiration_date_year)

// 5. If a teacher only has either an effective date or an expiration date for a certificate, the most we know about that 
// teacher's certification is the year in which it was effective or expired. Assign the same year to both effective and expiration 
// dates if one or the other is missing. This means that the certificate is valid during the year in which it was issued or expired. 
	replace effective_date_year = expiration_date_year if effective_date_year==. & expiration_date_year!=. 
	replace expiration_date_year = effective_date_year if expiration_date_year==. & effective_date_year!=.  
	
// 6. Drop the month variables as they are no longer necessary.
	drop *month

// 7. Create an observation row for every combination of teacher, certification_code, and expiration_date_year. 
// "fillin" creates a variable called _fillin that indicates if the row was newly created (1) or original to the dataset (0). 
	fillin tid certification_code expiration_date_year

// 8. Create variables that identify the effective and expiration years for the observations that are original to the dataset. 
	gen effective_year = effective_date_year if _fillin==0
	gen expire_year = expiration_date_year if _fillin==0
	
// 9. Generate the maximum value for expire_year and effective_year within teacher and certification_code. 
	foreach yr in effective_year expire_year {
	     egen max_`yr' = max(`yr'), by(tid certification_code)
	 }

// 10. Generate a school_year variable that is equal to the expiration_date_year. 
// Drop observations that have school years before the max_effective_year and after the max_expire_year. 
// This should leave one observation for each school year in which a teacher held a valid certificate. 
	gen school_year = expiration_date_year
	drop if school_year<max_effective_year
	drop if school_year>max_expire_year

// 11. Drop unnecessary variables. 
	drop max* _fillin expire_year effective_year effective_date_year expiration_date_year effective_date expiration_date

/*** Step 3. Create indicators for special certifications. ***/ 

// 1. Create temporary variables that indicate if a teacher has a certain certificate in a school year.
	gen temp_esl = (certification_code == "ENGLISH AS A SECOND LANGUAGE CERTIFICATION")
	gen temp_nbct = (certification_code == "NATIONAL BOARD CERTIFICATION")
	gen temp_sped = (certification_code == "SPECIAL EDUCATION CERTIFICATION")
	
// 2. Populate the existence of a certificate in a school year for each teacher/school year observation.
	foreach cert in esl nbct sped {
		egen certification_`cert' = max(temp_`cert'), by(tid school_year)
	}
	
// 3. Label the certification variables and values.
	label var certification_esl 	"ESL certification" 
	label var certification_nbct 	"National Board certification" 
	label var certification_sped	"Special Education certification" 
	
	label define cert 0 "Not certified" 1 "Certified"
	label values certification_esl certification_nbct certification_sped cert

// 4. Drop the unnecessary variables and drop duplicates.
	drop certification_code temp*
	duplicates drop

// 5. Verify that the file is unique by tid and school_year.
	isid tid school_year
	
/*** Step 4. Keep relevant data and save the file. ***/

// 1. Limit the range of school years to those in the range of the Staff_School_Year_Raw file.
// First, load the Staff_School_Year_Raw file and assign the first and last school year value to local variables.
	preserve
		use "${raw}/Staff_School_Year_Raw.dta", clear
		sort school_year
			local first_yr = school_year
		gsort -school_year
			local last_yr = school_year
	restore
	
// Then drop variables that are outside of the range needed.
	drop if school_year < `first_yr' | school_year > `last_yr'
	
// 2. Save the current file as Staff_Certifications_Clean.dta.
	save "${clean}/Staff_Certifications_Clean.dta", replace 

log close
