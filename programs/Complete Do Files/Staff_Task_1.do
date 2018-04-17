/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Staff_Task_1.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program generates a clean Staff_Attributes file unique by tid.
* The core of this task:
* 1. Resolve instances when teachers appear with inconsistent attributes over available years. 
* 2. Ensure that you have one record per teacher.
*
* Inputs: /raw/Staff_School_Year_Raw.dta
*
* Outputs: /clean/Staff_Attributes_Clean.dta
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

// This program makes use of the "nvals" command, which comes from a user written package called "egenmore." 
// The package will be downloaded and automatically installed from the Statistical Software Components (SSC)
// repository if it is not installed already. Internet access is required.
capture ssc install egenmore

log using "${log}\Staff_Task_1.txt", text replace 

/*** Step 0: Load the Staff_School_Year data file, keep only necessary variables and drop duplicates. ***/
	use "${raw}/Staff_School_Year_Raw.dta", clear
	
	keep tid school_year male race_ethnicity certification_path birth_date
	duplicates drop

/*** Step 1: Create one consistent gender value for each teacher across years. ***/

// 1. Tabulate the male variable to see its values and determine whether any are missing. 
	tab male, mi
	
// 2. Create a variable that shows how many unique values male assumes for each teacher. Name this variable nvals_male. 
	bys tid: egen nvals_male = nvals(male) 

// 3. Tabulate nvals_male to determine how many instances there are in the data in which teachers have more than one unique gender reported.
	tab nvals_male, mi
	
// 4. Generate a variable called male_mode that reports the modal gender for each teacher. 
	by tid: egen male_mode = mode(male)
	
// 5. For teachers who have a mode, replace their gender with male_mode. 
	replace male = male_mode if !mi(male_mode) 
	
// 6. In instances where there are multiple modes, take the most recent value reported. 
	gsort tid -school_year 
	
// 7. Generate a variable called temp_male_last that identifies the gender for the first (most recent) observation for each teacher. 
	bys tid: gen temp_male_last = male if _n==1 

// 8. Generate a variable that assigns the highest value of temp_male_last (the only non-missing value) to all observations within a each teacher. Call this variable male_last. 
	egen male_last = max(temp_male_last), by(tid) 

// 9. Replace male with male_last if male_mode is missing (a teacher has multiple modes for gender). 
	replace male = male_last if mi(male_mode)

// 10. Drop temporary variables you created.
	drop nvals_male male_mode temp_male_last male_last

 
/*** Step 2. Create one consistent certification pathway for each teacher across years. ***/

// 1. Tabulate the "certification_pathway" variable to see its values and whether any are missing. 
	tab certification_pathway, mi
	
// 2. Create consistent values for each certification pathway. 
	replace certification_pathway = "ALTERNATIVE CERTIFICATION" if ///
		inlist(certification_pathway, "ALT", "ALTCERT", "alternative certification", "altcert")	
	replace certification_pathway = "STANDARD CERTIFICATION" if ///
		inlist(certification_pathway, "STD CERT", "std cert", "standard certification")
	replace certification_pathway = "TFA" if ///
		inlist(certification_pathway, "TAF", "tfa") 
	
// 3. Check that there is only one value for each certification_pathway. 
	tab certification_pathway
	
// 4. Replace certification_pathway's values with numeric values. 
	replace certification_pathway = "1" if certification_pathway == "STANDARD CERTIFICATION" 
	replace certification_pathway = "2" if certification_pathway == "ALTERNATIVE CERTIFICATION" 
	replace certification_pathway = "3" if certification_pathway == "TFA"
	
// 5. Destring certification pathway. 
	destring certification_pathway, replace 
	
// 6. Label the values of certification pathway.
	label define cert 1 "Standard Certification" 2 "Alternative Certification" 3 "TFA" 
	label values certification_pathway cert 

// 7. Create a variable that shows how many unique values certification_path assumes for each teacher. Name this variable nvals_cert. 
	bys tid: egen nvals_cert = nvals(certification_pathway)
	
// 8. Tabulate nvals_cert to determine how many instances there are in the data where teachers have more than one unique certification pathway reported.
	tab nvals_cert

// 9. Generate a variable called cert_mode that reports the modal certification pathway for each teacher. 
	egen cert_mode = mode(certification_pathway), by(tid)

// 10. For teachers who have a mode, replace their certification pathway with cert_mode. 
	replace certification_pathway = cert_mode if !mi(cert_mode)

// 11. This data set does not have any instances where there are multiple modes for teacher certification. As an exercise, fill in the remaining code as if there were multiple modes using Step 1 (creating a consistent gender) as a model.	
/*		
// Sort the data so that the most recent school year is the first observation for each teacher. 
	gsort 

// 12. Generate a variable called temp_cert_last that identifies the certification pathway for the first (most recent) observation for each teacher. 
	bys tid: gen 

// 13. Generate a variable that assigns the highest value of temp_cert_last (the only non-missing value) to all observations within a each teacher. Call this variable cert_last. 
	egen 

// 14. Replace certificaton_path with cert_last if cert_mode is missing (a teacher has multiple modes for certification_path).
	replace 
*/
// 15. Drop temporary variables you created. 
	drop cert_mode nvals_cert
	

/*** Step 3: Create one consistent value for race_ethnicity for each teacher across years. ***/

// 1. Tabulate the race_ethnicity variable to see its values and check if any are missing. 
	tab race_ethnicity, mi

// 2. Create a numeric variable that has consistent values for each race/ethnicity. Use a for loop to standardize values for Black and  Latino, which have several different spelling variations. 
	gen race_num = . 
	foreach afam in "AFAM" "AFRICAN AMERICAN" "BLACK" "afam" "african american" "black" { 
		replace race_num = 1 if race_ethnicity=="`afam'"
	} 
	replace race_num = 2 if race_ethnicity=="ASIAN" | race_ethnicity=="asian" 
	foreach hisp in "HISP" "HISPANIC" "hisp" "hispanic" { 
		replace race_num = 3 if race_ethnicity=="`hisp'" 
	} 
	replace race_num = 4 if race_ethnicity=="NATIVE AMERICAN" | race_ethnicity=="native american" 
	replace race_num = 5 if race_ethnicity=="WHITE" | race_ethnicity=="white" 
	replace race_num = 6 if race_ethnicity=="6" 

// 3. Destring the race_num variable 
	destring race_num, replace 
	
// 4. Label the values of race_num 
	label define race 1 "Black" 2 "Asian" 3 "Latino" 4 "Native American" 5 "White" 6 "Multiple/Other"
	label values race_num race
	
// 5. Check that the values for race_num correspond to the values for race_ethnicity. Tabulate both variables. 
	tab race_ethnicity race_num, mi 
	
// 6. Drop the string race_ethnicity variable and rename the numeric one "race_ethnicity".
	drop race_ethnicity
	rename race_num race_ethnicity
	
// 7. Create a variable that shows how many unique values race_ethnicity assumes for each teacher in each school year. Name this variable nvals_race_year. 
	bys tid school_year: egen nvals_race_year = nvals(race_ethnicity) 

// 8. Tabulate nvals_race_year to determine how many instances there are in the data where race_ethnicity is not consistent within tid and school_year.
	tab nvals_race_year

//9. If a teacher has more than one race in a single school year, replace the teacher's race as multiracial.
	replace race_ethnicity = 6 if nvals_race_year>1 & !mi(nvals_race_year)

// 10. Generate a variable called temp_islatino to identify observations where a teacher is reported to be Latino. 
	gen temp_islatino = . 
	replace temp_islatino = 1 if race_ethnicity == 3 

// 11. Generate a variable called islatino that indicates the maximum value of temp_islatino for all observations within each teacher and year. 
	egen islatino = max(temp_islatino), by(tid school_year) 

	// Latino teachers should have a value of “1” across all observations and all other teachers should have missing values across all observations for islatino. 
	tab islatino, mi
	tab islatino if race_ethnicity==3, mi
	tab islatino if race_ethnicity!=3, mi

// 12. Replace race_ethnicity with 3 (Latino) if one of the race_ethnicity values within the same teacher and year is 3 (Latino). 
	replace race_ethnicity = 3 if nvals_race_year > 1 & !mi(nvals_race_year) & islatino == 1

	// Replace race_ethnicity with 6 (Multiracial) if a teacher has more than one race in the same year and none of the race_ethnicity values are 3 (Latino).
	replace race_ethnicity = 6 if nvals_race_year > 1 & !mi(nvals_race_year) & islatino != 1

// 13. Drop the temporary variables you created. 
	drop nvals_race_year temp_islatino islatino

// 14. Next, make race_ethnicity consistent by tid. 
	
	// Check if race_ethnicity is consistent by tid by creating a variable that shows how many unique values race_ethnicity assumes for each teacher. Name this variable nvals_race. 
	bys tid: egen nvals_race = nvals(race_ethnicity) 

// 15. Tabulate nvals_race to determine how many instances there are in the data where race_ethnicity is not consistent within tid.
	tab nvals_race 
	
// 16. Generate a variable called race_mode that indicates the mode for each teacher’s race_ethnicity.
	bys tid: egen race_mode = mode(race_ethnicity)

// 17. For teachers who have a mode, replace their race_ethnicity with race_mode. 
	replace race_ethnicity = race_mode if !mi(race_mode)

// 18. In instances where there are multiple modes, take the most recent value reported.

	// Sort the data so that the most recent school year is the first observation for each teacher. 
	gsort tid -school_year 

// 19. Generate a variable called temp_race_last that identifies the race_ethnicity for the first (most recent) observation for each teacher. 
	bys tid: gen temp_race_last = race_ethnicity if _n==1

// 20. Generate a variable that assigns the highest value of temp_race_last (the only non-missing value) to all observations within a each teacher. Call this variable race_last.
	egen race_last = max(temp_race_last), by(tid)

// 21. Replace race_ethnicity with race_last if race_mode is missing (a teacher has multiple modes for race_ethnicity). 
	replace race_ethnicity = race_last if mi(race_mode)
	
// 22. Drop the temporary variables you created.	
	drop nvals_race race_mode temp_race_last race_last

/*** Step 4: Create one consistent value for birth_date for each teacher across years. ***/
	
// 1.  Convert birth_date to a numeric variable in Stata date format.
	gen temp_birth_date = date(birth_date, "MDY")
	drop birth_date
	rename temp_birth_date birth_date
	format birth_date %d
	
// 2.  Check the number of unique birth dates recorded for each teacher.
	egen nvals_birth_date = nvals(birth_date), by(tid)
	
// 3.  Check the number of missing birth dates.
	count if mi(birth_date)
	
// 4.  Since each teacher has only one birthday, this variable is clean, so drop the temporary variables you created.
	drop nvals_birth_date
	
/*** Step 5: Make the data unique by tid, check the data, and save the file. ***/

// 1.  At this point, we have cleaned the data. We no longer need the school year variable. 
	drop school_year

// 2. Drop duplicate observations.
	duplicates drop 

// 3. Check that the file is unique by tid.
	isid tid

// 4. Check the distribution and range of values for each variable; check for missing data.

	// Count the number of observations 
	count 

	// Produce a detailed summary of male, race_ethnicity, and certification_path, check the number of non-missing observations, range, and distribution.
	summ male race_ethnicity certification_path, detail  
	
// 5. Order the variables, sort, and save the current file as Staff_Attributes_Clean.dta.
	order tid male race_ethnicity certification_pathway birth_date
	sort tid
	save "${clean}/Staff_Attributes_Clean.dta", replace

log close
