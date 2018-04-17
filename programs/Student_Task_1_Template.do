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
	
	
/*** Step 1: Create one consistent value for gender for each student across years. ***/

// 1. Recode the gender variable as a numeric variable and label it.
	
	
// 2. Create a variable that shows how many unique values male assumes for each student. Name this variable nvals_male. 
	// Tabulate the variable and browse the relevant data.
	
	
// 3. Identify the modal gender. If multiple modes exist for a student, report the most recent gender recorded.
	
	// Define the modal gender. For students who have a mode, replace male with the modal value (male_mode will be missing if there is no single mode).
	
	
	// If multiple modes exist for a student, report the most recent gender recorded.
	
	
	// Drop temporary variables
	
	
/*** Step 2: Create one consistent value for race_ethnicity for each student across years. ***/

// 1. Recode the raw race_ethnicity variable as a numeric variable and label it.  Replace the string race_ethnicity variable with the numeric one.
	
	
// 2. Create a variable that shows how many unique values race_ethnicity assumes for each student. Name this variable nvals_race. Tabulate the variable.
	
	
// 3. Adjust nvals if a student has a missing race value.
	
	
// 4. If more than one race is reported, report the student as multiracial, unless one of their reported race_ethnicity values is Latino.  
	// Report the student as Latino in that case.
	// If the student had a only one race but also missing values, use the race that was reported.
	
	
	// Drop the temporary variables you created.
	
	
/*** Step 3: Drop any unneeded variables, drop duplicates, check the data, and save the file. ***/

// 1. Drop school_year as you no longer need it.  
	
	
// 2. Drop duplicate values.
	
	
// 3. Check that the file is unique by sid.
	
	
// 4. Save the current file as Student_Attributes.dta.
	
	
log close
