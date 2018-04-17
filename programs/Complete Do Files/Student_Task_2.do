/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Student_Task_2.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program generates a clean Student_School_Year file unique
* by sid + school_year by:
* 1. Creating one consistent grade level for each student within the same year.
* 2. Creating a variable to indicate if a student was retained in the next school year.
* 3. Creating one consistent FRPL value for each student within the same year.
* 4. Creating one consistent IEP value for each student within the same year.
* 5. Creating one consistent ELL value for each student within the same year.
* 6. Creating one consistent gifted value for each student within the same year.
* 7. Tagging students who had high absence rates (>=10% of enrolled days) during the school year.
*
* Inputs: /raw/Student_School_Year_Raw.dta
*
* Outputs: /clean/Student_School_Year_Clean.dta
*
***************************************************************************/

clear
set more off

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

log using "${log}\Student_Task_2.txt", text replace

/*** Step 0: Load the Student_School_Year_Raw data file ***/
	use "${raw}\Student_School_Year_Raw.dta", clear
	
/*** Step 1: Create one consistent grade level for each student within the same year. ***/

// 1. Check if there are any instances of multiple grade levels per sid per school_year.
	bys sid school_year: egen nvals_grade = nvals(grade_level)
	tab nvals_grade, mi
	
// 2. Keep the highest value per school year.
	bys sid school_year: egen max_grade_level = max(grade_level)
	replace grade_level = max_grade_level
	
// 3. Drop temporary variables.
	drop nvals_grade max_grade_level
	

/*** Step 2: Create a variable to indicate if a student was retained in the next school year. ***/
	
// 1. Create a separate variable for each school year and populate it with the grade in that school year.
	levelsof(school_year), local(schyr)

	foreach var in `schyr' {
		gen temp_`var' = grade_level if school_year == `var'
		egen grade_yr_`var' = max(temp_`var'), by(sid)
		drop temp
	}
	
// 2. Create a variable to indicate the grade level in the previous school year.
	// We don't have previous grade info in the first year, so start from the second year.
	gen grade_level_prevyr =.
		
	local i=1
	
	foreach var in `schyr' {
		local prevyr = `var' - 1
		if `i' > 1 {
			replace grade_level_prevyr = grade_yr_`prevyr' if school_year == `var'
		}
		local ++i
	}

// 3. Indicate if the student was retained.
	gen retained =.
	replace retained = 1 if (grade_level ==  grade_level_prevyr) & !mi(grade_level_prevyr)
	replace retained = 0 if (grade_level !=  grade_level_prevyr) & !mi(grade_level_prevyr)
	
// 4. Label the variable.
	label define yesno10 0 "No" 1 "Yes"
	label values retained yesno10

// 5. Drop unnecessary variables.
	drop grade_yr* grade_level_prevyr

	
/*** Step 3: Create one consistent FRPL value for each student within the same year. ***/

// 1. Recode raw FRPL variable with string type to numeric type.
	tab frpl, mi
	
	gen frpl_num = .
	replace frpl_num = 0 if frpl == "full cost lunch"
	replace frpl_num = 1 if frpl == "reduced price lunch"
	replace frpl_num = 2 if frpl == "free lunch"
		
	// Drop the old string variable and rename the numeric variable.
	drop frpl
	rename frpl_num frpl
	
// 2. Ensure that FRPL is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of FRPL status are reported in the same school year.
	bys sid school_year: egen nvals_frpl = nvals(frpl)
	tab nvals_frpl, mi
	
	// Report the highest value of FRPL by year for each student, selecting free over reduced and reduced over not participating.
	egen highest_frpl = max(frpl), by(sid school_year)
	replace frpl = highest_frpl
	
	// Label the FRPL values.
	label define frpl 0 "Not FRPL eligible" 1 "Reduced price lunch eligible" 2 "Free price lunch eligible"
	label values frpl frpl
	
	// Drop the temporary variables.
	drop nvals_frpl highest_frpl


/*** Step 4: Create one consistent IEP value for each student within the same school year. ***/
	
// 1. Recode raw IEP variable with string type to numeric type.
	tab iep, mi
	
	gen iep_num = .
	replace iep_num = 0 if iep == "not IEP" 
	replace iep_num = 1 if iep == "IEP"
		
	// Drop the old string variable and rename the numeric variable.
	drop iep
	rename iep_num iep
	
// 2. Ensure that IEP is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of IEP status are reported in the same school year.
	bys sid school_year: egen nvals_iep = nvals(iep)
	tab nvals_iep, mi
	
	// Report the highest value of IEP by year for each student, selecting participating over not participating.
	egen highest_iep = max(iep), by(sid school_year)
	replace iep = highest_iep
	
	// Label the IEP values.
	label define iep 0 "No IEP" 1 "IEP"
	label values iep iep
	
	// Drop the temporary variables.
	drop nvals_iep highest_iep

/*** Step 5: Create one consistent ELL value for each student within the same school year. ***/

// 1. Recode raw ELL variable with string type to numeric type.
	tab ell, mi
	
	gen ell_num = .
	replace ell_num = 0 if ell == "not ELL" 
	replace ell_num = 1 if ell == "ELL"
		
	// Drop the old string variable and rename the numeric variable.
	drop ell
	rename ell_num ell
	
// 2. Ensure that ELL is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of ELL status are reported in the same school year.
	bys sid school_year: egen nvals_ell = nvals(ell)
	tab nvals_ell, mi
	
	// Report the highest value of ELL by year for each student, selecting participating over not participating.
	egen highest_ell = max(ell), by(sid school_year)
	replace ell = highest_ell
	
	// Label the ELL values.
	label define ell 0 "Not ELL" 1 "ELL"
	label values ell ell
	
	// Drop the temporary variables.
	drop nvals_ell highest_ell

/*** Step 6: Create one consistent gifted value for each student within the same school year. ***/

// 1. Recode the raw gifted variable with string type to numeric type.
	tab gifted, mi
	
	gen gifted_num = .
	replace gifted_num = 0 if gifted == "not gifted"
	replace gifted_num = 1 if gifted == "gifted"
		
	// Drop the old string variable and rename the numeric variable.
	drop gifted
	rename gifted_num gifted
	
// 2. Ensure that gifted is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of gifted status are reported in the same school year.
	bys sid school_year: egen nvals_gifted = nvals(gifted)
	tab nvals_gifted, mi
	
	// Report the highest value of gifted by year for each student, selecting participating over not participating.
	egen highest_gifted = max(gifted), by(sid school_year)
	replace gifted = highest_gifted
	
	// Label the gifted values.
	label define gifted 0 "Not gifted" 1 "Gifted"
	label values gifted gifted
	
	// Drop the temporary variables.
	drop nvals_gifted highest_gifted
	
	
/*** Step 7: Tag students who had high absence rates (>=10% of enrolled days) during the school year. ***/

// 1. Create a variable that indicates the 10% cut point above which a student will be marked for high absence.
	gen abs_cutpoint = floor(days_enrolled * 0.1)

// 2. Tag students who were absent more days than the cutoff.
	gen absence_high = . 
	replace absence_high = 1 if days_absent >= abs_cutpoint & !mi(days_absent) 
	replace absence_high = 0 if days_absent < abs_cutpoint & !mi(days_absent) 
	
// 3. Tag observations where the absence data was not available.
	gen absence_miss = mi(days_absent)
	
// 4. Drop the temporary variable.
	drop abs_cutpoint
	

/*** Step 8: Drop any unnecessary variables, drop duplicates, and save the file. ***/

// 1. Drop duplicate observations.
	duplicates drop

// 2. Make sure your file is now unique by student and school year.
	isid sid school_year

// 3. Use a loop to standardize variable names for later merging. 
	foreach var of varlist retained frpl iep ell gifted{
		rename `var' s_`var'
	}
	
// 4. Order, sort, and the current file as Student_School_Year_Clean.
	order sid school_year grade_level s_retained s_frpl s_iep s_ell s_gifted days_enrolled days_absent absence_high absence_miss 
	sort sid school_year
	save "${clean}\Student_School_Year_Clean.dta", replace

log close
