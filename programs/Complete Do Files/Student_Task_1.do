/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Student_Task_1.do
* Author(s): Strategic Data Project
* Date:
* Description: This program generates a clean Student_Attributes file unique
* by sid by:
* 1. Creating one consistent value for gender for each student across years.
* 2. Creating one consistent value for race_ethnicity for each student across years.
*
* Inputs: /raw/Student_Demographics_Raw.dta
*
* Outputs: /clean/Student_Attributes_Clean.dta
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

log using "${log}\Student_Task_1.txt", text replace

/*** Step 0: Load the Student_Demographics_Raw data file. ***/
// 1. Load the data into memory.
	use "${raw}\Student_Demographics_Raw.dta", clear
	
/*** Step 1: Create one consistent value for gender for each student across years. ***/

// 1. Recode the gender variable as a numeric variable and label it.
	tab gender, mi
	assert !mi(gender)
	gen male = (gender == "Male")

	label define s_male 0 "Female" 1 "Male"
	label values male s_male
	
	drop gender

// 2. Create a variable that shows how many unique values male assumes for each student. Name this variable nvals_male. 
	// Tabulate the variable and browse the relevant data.
	bys sid: egen nvals_male = nvals(male)
	tab nvals_male

// 3. Identify the modal gender. If multiple modes exist for a student, report the most recent gender recorded.
	
	// Define the modal gender. For students who have a mode, replace male with the modal value (male_mode will be missing if there is no single mode).
	bys sid: egen male_mode = mode(male)
	replace male = male_mode if !mi(male_mode)
	
	// If multiple modes exist for a student, report the most recent gender recorded.
	gsort sid -school_year
	bys sid: gen temp_male_last = male if _n==1
	bys sid: egen male_last = max(temp_male_last)
	replace male = male_last if mi(male_mode)
	
	// Drop temporary variables
	drop nvals_male male_mode temp_male_last male_last
	
/*** Step 2: Create one consistent value for race_ethnicity for each student across years. ***/

// 1. Recode the raw race_ethnicity variable as a numeric variable and label it.  Replace the string race_ethnicity variable with the numeric one.
	tab race_ethnicity, mi

	generate race_num=.
	replace race_num = 1 if race_ethnicity=="B"
	replace race_num = 2 if race_ethnicity =="A"
	replace race_num = 3 if race_ethnicity =="H"
	replace race_num = 4 if race_ethnicity =="NA"
	replace race_num = 5 if race_ethnicity =="W"
	replace race_num = 6 if race_ethnicity =="M/O"
	replace race_num = 7 if race_ethnicity ==""

	label define race 1 "Black" 2 "Asian" 3 "Latino" 4 "Native American" 5 "White" 6 "Multiple/Other" 7 "Missing"
	label val race_num race

	tab race_num, mi
	drop race_ethnicity
	rename race_num race_ethnicity
 
// 2. Create a variable that shows how many unique values race_ethnicity assumes for each student. Name this variable nvals_race. Tabulate the variable.
	bys sid: egen nvals_race = nvals(race_ethnicity)
	tab nvals_race
	
// 3. Adjust nvals if a student has a missing race value.
	egen race_miss = max(race_ethnicity == 7), by(sid)
	replace nvals_race = nvals_race - 1 if race_miss == 1 & nvals_race > 1
	
// 4. If more than one race is reported, report the student as multiracial, unless one of their reported race_ethnicity values is Latino.  
	// Report the student as Latino in that case.
	// If the student had a only one race but also missing values, use the race that was reported.
	gen temp_islatino = .
	replace temp_islatino = 1 if race_ethnicity == 3 & nvals_race > 1
	bys sid: egen islatino = max(temp_islatino)

	replace race_ethnicity = 3 if nvals_race > 1 & nvals_race !=. & islatino == 1
	replace race_ethnicity = 6 if nvals_race > 1 & nvals_race !=. & islatino != 1
	
	egen race_nonmissing = min(race_ethnicity) if race_miss == 1 & nvals_race == 1, by(sid)
	replace race_ethnicity = race_nonmissing if !mi(race_nonmissing)
		
	// Drop the temporary variables you created.
	drop temp_islatino islatino nvals_race race_miss race_nonmissing
	
/*** Step 3: Drop any unneeded variables, drop duplicates, check the data, and save the file. ***/

// 1. Drop school_year as you no longer need it.  
	drop school_year
	
// 2. Drop duplicate values.
	duplicates drop
	
// 3. Check that the file is unique by sid.
	isid sid

// 4. Save the current file as Student_Attributes.dta.
	save "${clean}\Student_Attributes_Clean.dta", replace

log close
