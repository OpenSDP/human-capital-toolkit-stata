/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Staff_Task_4.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program generates a clean Staff_School_Year_Clean file 
* unique by tid and school_year by:
* 1. Identifying one unique school code per teacher within each school year.
* 2. Resolving inconsistencies in years of teacher experience across school years.
* 3. Assigning one hire and termination date to each employment period.
*
* Inputs: /clean/Staff_Degrees_Job_Codes_Clean.dta
*		  /raw/School_Clean.dta
*
* Outputs: /clean/Staff_School_Year_Clean.dta
*
***************************************************************************/

clear
set more off
program drop _all
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

log using "${log}\Staff_Task_4.txt", text replace

/*** Step 0. Load the Staff_Degrees_Job_Codes_Clean data file. Merge school variables from school file. ***/

// 1. Open Staff_Degrees_Job_Codes_Clean.dta.
	use "${clean}/Staff_Degrees_Job_Codes_Clean.dta", clear
	
// 2. Merge school variables from School_Clean.dta file. Assert that all observations match.  
	merge m:1 school_code  using "${clean}/School_Clean.dta", keepusing(elementary middle high alternative) assert(3) nogen 

/*** Step 1. Identify one unique school code per teacher within each school year. ***/ 

// 1. A school code that is associated with many non-teachers is a sign that the school code might not be an actual school. It might indicate that the individual is based at the central office or another non-school based location.

	tab school_code t_is_teacher, mi

	// Tabulate job code descriptions for school codes 9 and 800. 
	foreach school in 9 800 { 
		tab job_code if school_code == `school'
	}
	
	// Most individuals in school 9 are substitutes and many in school 800 are temporary employees. It is reasonable to assume that a substitute teacher or temporary employee would not earn teaching experience. 
	// This information will be important later when we make decisions about which school code to assign to teachers who have multiple in each school year. If one of a teacher's schools is 9 or 800, we will keep the other one. 
		
// 2. Create a variable that shows how many unique values school_code assumes for each individual and school year. Name this variable nvals_school. 
	bys tid school_year: egen nvals_school = nvals(school_code)

// 3. Tabulate nvals_school to determine how many instances there are in the data where individuals have more than one unique school code reported in the same school year. 
	tab nvals_school
	
// 4. If an individual has more than one school code within the same year and one of them is 9 or 800, drop the observation with a school_code of 9 or 800. 
	foreach school in 9 800 {
		drop if nvals_school > 1 & school_code==`school' & t_is_teacher == 1
	}
	
// 5. If an individual has more than one school code within the same year and one of them is a high school and the other is either a middle school or elementary school, 
// keep the middle or elementary school observation, since SDP does not calculate teacher effects for high school teachers.
	
	// First, generate a variable that indicates whether one or both of the school codes within a teacher and school year are a middle school or elementary school.  
	gen temp_ms_es = (middle == 1 | elementary == 1) 
	bys tid school_year: egen ms_es = max(temp_ms_es) 
	
	// Drop the high school observation for teachers who have more than one school code in the same school year and also teach at a middle or elementary school. 
	drop if nvals_school > 1 & !mi(nvals_school) & high == 1 & ms_es == 1 

// 6. If an individual has more than one school code within the same year and one of them is a non-traditional school and the other is a traditional school, keep the traditional school observation.	
	
	// First, determine if teachers teach in non-alternative schools. Generate a variable called non_alternative that assigns "0" to all observations of teachers within school years if they ever taught at a traditional school. 
	bys tid school_year: egen non_alternative = min(alternative)
	
	// Drop the alternative school observation for teachers who have more than one school code in the same school year and also teach at a traditional school. 
	drop if nvals_school > 1  & !mi(nvals_school) & alternative == 1 & non_alternative == 0

	// Drop variables that are no longer needed. 
	drop high middle elementary *alternative *ms_es
	
// 7. Since we have resolved some cases where teachers have more than one school code in a single school year, the nvals_school variable no longer reflects which teachers have more than one school code per school year. Therefore, we need to create a new variable that identifies how many cases we still need to resolve. Call this new variable nvals_school2. 
	bys tid school_year: egen nvals_school2 = nvals(school_code)
	tab nvals_school2

// 8. For teachers with more than one school code per year, use the school code from the following (n+1) year. Use a for loop to sequentially identify the maximum and minimum school code and replace its value if it is missing.

	// First, if one of the school codes matches the school code from the following year for the same teacher (a more recent year), choose that school code. 
	// For teachers who have more than one school code in the same school year, create separate variable for each school code with values of school code that are constant among all observations within teacher and school year. 
	// Generate a variable whose value is the school code that matches the school code in the following year. The value of this variable will be missing if neither school code matches the value of the school code for the following school year.
	// Generate a variable that fills in all of the observations within teacher and school year with the value of next_school_is_min and next_school_is_max for teachers who have more than one school code in the same school year. 
	// Replace school_code with the value of next_school_code_is_min or next_school_code_is_max if the value is not missing and a teacher has more than one school code in the same school year. 
	// Drop the variables no longer needed. 
	foreach code in max min { 
		egen `code'_school = `code'(school_code) if nvals_school2 > 1 & !mi(nvals_school2), by(tid school_year) 
		gen temp_next_school_is_`code' = `code'_school if `code'_school == school_code[_n+1] & school_year < school_year[_n+1] & tid == tid[_n+1] & nvals_school2[_n+1] == 1
		egen next_school_is_`code' = `code'(temp_next_school_is_`code'), by(tid school_year) 
		replace school_code = next_school_is_`code' if nvals_school2 > 1 & !mi(nvals_school2) & next_school_is_`code' !=. 
		drop `code'_school temp_next_school_is_`code' next_school_is_`code'
	} 

// 9. Drop duplicate observations
	duplicates drop 
		
// 10. Again, create a variable that identifies how many teachers still have more than one school code in the same school year. 	 
	bys tid school_year: egen nvals_school3 = nvals(school_code)
	tab nvals_school3

// 11. Repeat the process for step 9, but instead of selecting the school code that matches the one for the following year, choose the one that matches the school code from the prior year within the same teacher. 
	foreach code in max min { 
		egen `code'_school = `code'(school_code) if nvals_school3 > 1 & !mi(nvals_school3), by(tid school_year) 
		gen temp_last_school_is_`code' = `code'_school if `code'_school == school_code[_n-1] & school_year > school_year[_n-1] & tid == tid[_n-1] & nvals_school3[_n-1] == 1
		egen last_school_is_`code' = `code'(temp_last_school_is_`code'), by(tid school_year) 
		replace school_code = last_school_is_`code' if nvals_school3 > 1 & !mi(nvals_school3) & last_school_is_`code' !=. 
		drop `code'_school temp_last_school_is_`code' last_school_is_`code'
	} 
	
// 12. Drop duplicate observations 
	duplicates drop 
	
// 13. Now the only teachers assigned to more than one school are assigned to two schools that do not repeat in the years following or preceding the year in which the teacher has two schools. For these remaining cases, keep an observation at random. 
	bys tid school_year: egen nvals_school4 = nvals(school_code)
	tab nvals_school4
	bys tid school_year: gen n = _n 
	drop if n == 2 & nvals_school4 > 1 & !mi(nvals_school4)
	
// 14. Check that the data file is unique by teacher and school year. 
	isid tid school_year

// 15. Drop unnecessary variables. 
	drop n nvals_school*
	
// 16. Use a for loop to format both hire_date and termination_date as a date format. 
	foreach date in hire_date termination_date { 
		gen `date'_num = date(`date', "MDY") 
		format `date'_num %td 
		drop `date'
		rename `date'_num `date'
	}

// 17. Drop variables that still need to be cleaned and save this file as a temporary file that we will merge onto the data after cleaning the teacher experience variable.
	preserve 
	drop experience hire_date termination_date
	tempfile clean_school
	save `clean_school'
	restore 
	
/*** Step 2. Resolve inconsistencies in years of teacher experience across school years. ***/ 

// 1. In cases where non-teachers have years of teaching experience and appear as novice teachers (with one year of experience) in a later year, replace years of experience as missing. 
	sort tid school_year 
	replace experience = . if tid==tid[_n+1] & t_is_teacher==0 & t_is_teacher[_n+1]==1 & experience!=. & experience!=0 & experience[_n+1]==1 

// 2. Keep only observations where the individual is a teacher.   
	keep if t_is_teacher == 1 
	
// 3. It is vital to have only one occurence of the first year of experience teaching. Force experience to equal 2 for all but the earliest instance of 1 for a given teacher.
	egen min_novice_year = min(school_year) if experience == 1, by(tid)
	replace experience = 2 if experience == 1 & school_year != min_novice_year
	drop min_novice_year

// 4. Write a command named drops (this is called a program) to fix drops in experience over time, which is theoretically impossible and likely occurs due to typos in the raw data.
	program drops
	
		// 4a. Flag every instance when a value of experience is less than the prior value for a given teacher and count the total such instances in the whole data.
		bys tid (school_year): gen neg = 1 if experience < experience[_n-1] & _n != 1 & !mi(experience) & !mi(experience[_n-1])
		tab neg
		local neg = r(N)
		
		// 4b. If the total is zero (no instances of drops in experience for any teacher in the data), finish the program.
		if `neg' == 0{
			drop neg
			exit
		}
		
		// 4c. If such instances still exist in the data, replace experience with the prior value of experience, and re-run this process.
		else{
			replace experience = experience[_n-1] if neg == 1
			drop neg
			drops
		}
		
	end
	
// 5. Now that the program has been created, execute it like any other Stata command.
	drops
	
// 6. Write a command named jumps to fix jumps in experience that are too large given the number of years that have elapsed (for example, a teacher's experience increases by two in one year), and count all such instances in the whole data.
	program jumps

		// 6a. Flag every instance when a value of experience has increased by more than the number of school years that have elapsed for a given teacher.
		bys tid (school_year): gen jump = 1 if (school_year - school_year[_n-1]) < (experience - experience[_n-1]) & !mi(experience) & !mi(experience[_n-1])
		tab jump
		local jump = r(N)
		
		// 6b. If no such instances exist for any teacher, finish the program.
		if `jump' == 0{
			drop jump*
			exit
		}
		
		// 6c. If such instances exist, subtract 1 year of experience in the latter observation where the jump happens, and re-run this process.
		else{
			replace experience = experience - 1 if jump == 1 & experience == experience[_n+1]
			gen jump2 = jump[_n+1]
			replace experience = experience[_n+1] - 1 if jump2 == 1
			drop jump*
			jumps
		}
	
	end
	
// 7. Execute the command written above.
	jumps

// 8. Note that most teachers are missing experience in 2012. Replace years of experience in 2012 for missing observations, assuming that the teacher gains one year of experience from the prior year. 
	replace experience = (experience[_n-1]+1) if tid==tid[_n-1] & t_is_teacher==1 & school_year==2012 & experience==. 
	
// 9. Keep only the variables needed.
	keep tid school_year school_code job_code experience degree t_is_teacher hire_date termination_date

/*** Step 3. Assign one hire and termination date to each employment period. ***/
	
// 1. Create a variable to identify each employment period for a teacher.
	sort tid hire_date termination_date
	bys tid hire_date termination_date: gen employment_period = (_n==1)
	replace employment_period = employment_period[_n-1] + employment_period if tid == tid[_n-1]
		
// 2. Identify the hire and termination date for each employment period. Replace hire and termination dates with the mode for the employment period. If there is no mode for the employment period, replace the hire and termination dates with the teacher's overall hire and termination date modes.  
	foreach var of varlist hire_date termination_date { 
		bys tid employment_period: egen period_mode_`var' = mode(`var')
		replace `var' = period_mode_`var' if !mi(period_mode_`var')
		bys tid : egen total_mode_`var' = mode(`var')
		replace `var' = total_mode_`var' if mi(period_mode_`var') & !mi(total_mode_`var') 
	} 
	
// 3. If there is no hire date or termination date mode overall, choose the earliest hire date and the latest termination date. 
	bys tid: egen min_hire_date = min(hire_date) 
	replace hire_date = min_hire_date if mi(period_mode_hire_date) & mi(total_mode_hire_date)
	
	bys tid: egen max_termination_date = max(termination_date) 
	replace termination_date = max_termination_date if mi(period_mode_termination_date) & mi(total_mode_termination_date)
	
// 4. Assert that there is only one value for hire and termination dates within an employment period.
	foreach var of varlist hire_date termination_date { 
		bys tid tid employment_period: egen nvals_`var' = nvals(`var')
		assert nvals_`var' == 1 | nvals_`var' ==. 
		drop nvals_`var'
	}
	
/*** Step 4. Merge the temporary file with cleaned school codes to the current data file, check the data, and save the file. ***/ 

// 1. Merge data from the temporary file we created earlier. This file contains information about non-teachers. 
	merge 1:1 tid school_year using `clean_school', nogen 
	
	// Note that experience, hire date, and termination date are missing for non-teachers. SDP does not include these variables in any analyses for non-teachers. 
	
// 2. Keep only the variables we need. 
	keep tid school_year school_code job_code experience degree t_is_teacher hire_date termination_date
	
// 3. Check that data is unique by tid and school_year.
	isid tid school_year
	
// 4. Order variables, sort the data, and save the data file.
	order  tid school_year school_code job_code degree t_is_teacher experience hire_date termination_date
	sort tid school_year 
	save "${clean}/Staff_School_Year_Clean.dta", replace 

log close
