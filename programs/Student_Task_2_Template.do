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
	
	
/*** Step 1: Create one consistent grade level for each student within the same year. ***/

// 1. Check if there are any instances of multiple grade levels per sid per school_year.
	
	
// 2. Keep the highest value per school year.
	
	
// 3. Drop temporary variables.
	
	
/*** Step 2: Create a variable to indicate if a student was retained in the next school year. ***/
	
// 1. Create a separate variable for each school year and populate it with the grade in that school year.
	
	
// 2. Create a variable to indicate the grade level in the previous school year.
	// We don't have previous grade info in the first year, so start from the second year.
	
	
// 3. Indicate if the student was retained.
	
	
// 4. Label the variable.
	
	
// 5. Drop unnecessary variables.
	
	
/*** Step 3: Create one consistent FRPL value for each student within the same year. ***/

// 1. Recode raw FRPL variable with string type to numeric type.
	
	
	// Drop the old string variable and rename the numeric variable.
	
	
// 2. Ensure that FRPL is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of FRPL status are reported in the same school year.
	
	
	// Report the highest value of FRPL by year for each student, selecting free over reduced and reduced over not participating.
	
	
	// Label the FRPL values.
	
	
	// Drop the temporary variables.
	
	
/*** Step 4: Create one consistent IEP value for each student within the same school year. ***/
	
// 1. Recode raw IEP variable with string type to numeric type.
	
	
	// Drop the old string variable and rename the numeric variable.
	
	
// 2. Ensure that IEP is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of IEP status are reported in the same school year.
	
	
	// Report the highest value of IEP by year for each student, selecting participating over not participating.
	
	
	// Label the IEP values.
	
	
	// Drop the temporary variables.
	
	
/*** Step 5: Create one consistent ELL value for each student within the same school year. ***/

// 1. Recode raw ELL variable with string type to numeric type.
	
	
	// Drop the old string variable and rename the numeric variable.
	
	
// 2. Ensure that ELL is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of ELL status are reported in the same school year.
	
	
	// Report the highest value of ELL by year for each student, selecting participating over not participating.
	
	
	// Label the ELL values.
	
	
	// Drop the temporary variables.
	
	
/*** Step 6: Create one consistent gifted value for each student within the same school year. ***/

// 1. Recode the raw gifted variable with string type to numeric type.
	
	
	// Drop the old string variable and rename the numeric variable.
	
	
// 2. Ensure that gifted is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of gifted status are reported in the same school year.
	
	
	// Report the highest value of gifted by year for each student, selecting participating over not participating.
	
	
	// Label the gifted values.
	
	
	// Drop the temporary variables.
	
	
/*** Step 7: Tag students who had high absence rates (>=10% of enrolled days) during the school year. ***/

// 1. Create a variable that indicates the 10% cut point above which a student will be marked for high absence.
	
	
// 2. Tag students who were absent more days than the cutoff.
	
	
// 3. Tag observations where the absence data was not available.
	
	
// 4. Drop the temporary variable.
	
	
/*** Step 8: Drop any unnecessary variables, drop duplicates, and save the file. ***/

// 1. Drop duplicate observations.
	
	
// 2. Make sure your file is now unique by student and school year.
	
	
// 3. Use a loop to standardize variable names for later merging. 
	
	
// 4. Order, sort, and the current file as Student_School_Year_Clean.
	
	
log close
