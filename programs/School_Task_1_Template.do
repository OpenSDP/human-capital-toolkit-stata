/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: School_Task_1.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program generates the School_Clean file unique by school_code.
* The core of this task:
* 1. Ensure that you have one record per school.
* 2. Create variables to indicate school level.
*
* Inputs: /raw/School_Raw.dta
*
* Outputs: /clean/School_Clean.dta
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

log using "${log}\School_Task_1.txt", text replace 

/*** Step 0: Load the Staff_School_Year data file, keep only necessary variables and drop duplicates. ***/
	
// 1. Load the file, and drop possible duplicates.
	
	
/*** Step 1: Clean the file and ensure that the file is unique by school code. ***/
	
// 1. Assert that dummy variables, school names, and levels coincide.
	
	
// 2. Create dummy variables to indicate the school level.
	
	
// 3. Convert the variable indicating if a school is an alternative school into a numberic indicator.
	
	
// 4. Ensure that the file is unique by school code.
	
	
/*** Step 2: Save the file ***/

// 1. Order the variables, sort, and save the current file as School_Clean.dta.
	
	
log close
