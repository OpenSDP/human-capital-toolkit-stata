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
	
	
// 2. Merge school variables from School_Clean.dta file. Assert that all observations match.  
	
	
/*** Step 1. Identify one unique school code per teacher within each school year. ***/ 

// 1. A school code that is associated with many non-teachers is a sign that the school code might not be an actual school. It might indicate that the individual is based at the central office or another non-school based location.
	
	
	// Tabulate job code descriptions for school codes 9 and 800. 
	
	
	// Most individuals in school 9 are substitutes and many in school 800 are temporary employees. It is reasonable to assume that a substitute teacher or temporary employee would not earn teaching experience. 
	// This information will be important later when we make decisions about which school code to assign to teachers who have multiple in each school year. If one of a teacher's schools is 9 or 800, we will keep the other one. 
		
// 2. Create a variable that shows how many unique values school_code assumes for each individual and school year. Name this variable nvals_school. 
	
	
// 3. Tabulate nvals_school to determine how many instances there are in the data where individuals have more than one unique school code reported in the same school year. 
	
	
// 4. If an individual has more than one school code within the same year and one of them is 9 or 800, drop the observation with a school_code of 9 or 800. 
	
	
// 5. If an individual has more than one school code within the same year and one of them is a high school and the other is either a middle school or elementary school, 
// keep the middle or elementary school observation, since SDP does not calculate teacher effects for high school teachers.
	
	// First, generate a variable that indicates whether one or both of the school codes within a teacher and school year are a middle school or elementary school.  
	
	
	// Drop the high school observation for teachers who have more than one school code in the same school year and also teach at a middle or elementary school. 
	
	
// 6. If an individual has more than one school code within the same year and one of them is a non-traditional school and the other is a traditional school, keep the traditional school observation.	
	
	// First, determine if teachers teach in non-alternative schools. Generate a variable called non_alternative that assigns "0" to all observations of teachers within school years if they ever taught at a traditional school. 
	
	
	// Drop the alternative school observation for teachers who have more than one school code in the same school year and also teach at a traditional school. 
	
	
	// Drop variables that are no longer needed. 
	
	
// 7. Since we have resolved some cases where teachers have more than one school code in a single school year, the nvals_school variable no longer reflects which teachers have more than one school code per school year. Therefore, we need to create a new variable that identifies how many cases we still need to resolve. Call this new variable nvals_school2. 
	
	
// 8. For teachers with more than one school code per year, use the school code from the following (n+1) year. Use a for loop to sequentially identify the maximum and minimum school code and replace its value if it is missing.

	// First, if one of the school codes matches the school code from the following year for the same teacher (a more recent year), choose that school code. 
	// For teachers who have more than one school code in the same school year, create separate variable for each school code with values of school code that are constant among all observations within teacher and school year. 
	// Generate a variable whose value is the school code that matches the school code in the following year. The value of this variable will be missing if neither school code matches the value of the school code for the following school year.
	// Generate a variable that fills in all of the observations within teacher and school year with the value of next_school_is_min and next_school_is_max for teachers who have more than one school code in the same school year. 
	// Replace school_code with the value of next_school_code_is_min or next_school_code_is_max if the value is not missing and a teacher has more than one school code in the same school year. 
	// Drop the variables no longer needed. 
	
	
// 9. Drop duplicate observations
	
	
// 10. Again, create a variable that identifies how many teachers still have more than one school code in the same school year. 	 
	
	
// 11. Repeat the process for step 9, but instead of selecting the school code that matches the one for the following year, choose the one that matches the school code from the prior year within the same teacher. 
	
	
// 12. Drop duplicate observations 
	
	
// 13. Now the only teachers assigned to more than one school are assigned to two schools that do not repeat in the years following or preceding the year in which the teacher has two schools. For these remaining cases, keep an observation at random. 
	
	
// 14. Check that the data file is unique by teacher and school year. 
	
	
// 15. Drop unnecessary variables. 
	
	
// 16. Use a for loop to format both hire_date and termination_date as a date format. 
	
	
// 17. Drop variables that still need to be cleaned and save this file as a temporary file that we will merge onto the data after cleaning the teacher experience variable.
	
	
/*** Step 2. Resolve inconsistencies in years of teacher experience across school years. ***/ 

// 1. In cases where non-teachers have years of teaching experience and appear as novice teachers (with one year of experience) in a later year, replace years of experience as missing. 
	
	
// 2. Keep only observations where the individual is a teacher.   
	
	
// 3. It is vital to have only one occurence of the first year of experience teaching. Force experience to equal 2 for all but the earliest instance of 1 for a given teacher.
	
	
// 4. Write a command named drops (this is called a program) to fix drops in experience over time, which is theoretically impossible and likely occurs due to typos in the raw data.
	program drops
	
		// 4a. Flag every instance when a value of experience is less than the prior value for a given teacher and count the total such instances in the whole data.
		
		
		// 4b. If the total is zero (no instances of drops in experience for any teacher in the data), finish the program.
		
		
		// 4c. If such instances still exist in the data, replace experience with the prior value of experience, and re-run this process.
		
		
	end
	
// 5. Now that the program has been created, execute it like any other Stata command.
	
	
// 6. Write a command named jumps to fix jumps in experience that are too large given the number of years that have elapsed (for example, a teacher's experience increases by two in one year), and count all such instances in the whole data.
	program jumps

		// 6a. Flag every instance when a value of experience has increased by more than the number of school years that have elapsed for a given teacher.
		
		
		// 6b. If no such instances exist for any teacher, finish the program.
		
		
		// 6c. If such instances exist, subtract 1 year of experience in the latter observation where the jump happens, and re-run this process.
		
		
	end
	
// 7. Execute the command written above.
	
	
// 8. Note that most teachers are missing experience in 2012. Replace years of experience in 2012 for missing observations, assuming that the teacher gains one year of experience from the prior year. 
	
	
// 9. Keep only the variables needed.
	
	
/*** Step 3. Assign one hire and termination date to each employment period. ***/
	
// 1. Create a variable to identify each employment period for a teacher.
	
	
// 2. Identify the hire and termination date for each employment period. Replace hire and termination dates with the mode for the employment period. If there is no mode for the employment period, replace the hire and termination dates with the teacher's overall hire and termination date modes.  
	
	
// 3. If there is no hire date or termination date mode overall, choose the earliest hire date and the latest termination date. 
	
	
// 4. Assert that there is only one value for hire and termination dates within an employment period.
	
	
/*** Step 4. Merge the temporary file with cleaned school codes to the current data file, check the data, and save the file. ***/ 

// 1. Merge data from the temporary file we created earlier. This file contains information about non-teachers. 
	
	
	// Note that experience, hire date, and termination date are missing for non-teachers. SDP does not include these variables in any analyses for non-teachers. 
	
// 2. Keep only the variables we need. 
	
	
// 3. Check that data is unique by tid and school_year.
	
	
// 4. Order variables, sort the data, and save the data file.
	
	
log close
