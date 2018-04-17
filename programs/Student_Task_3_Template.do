/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Student_Task_3.do
* Author(s): Strategic Data Project
* Date: 
* Core of this task:
* 1. Ensure each student has one score per school year and grade level.
* 2. Generate standardized and composite test scores.
*
* Inputs: /raw/Student_Test_Scores_Raw.dta
*
* Outputs: /clean/Student_Test_Scores_Clean.dta
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

// This program makes use of a user-written commands called "center" and "unique." The packages 
// will be downloaded and automatically installed from the Statistical Software Components (SSC) repository 
// if they are not installed already. Internet access is required.
capture ssc install center
capture ssc install unique

log using "${log}\Student_Task_3.txt", text replace

/*** Step 0: Load the raw data file and keep relevant variables and observations.***/
	
// 1. Load the Student_Test_Scores_Raw input file.
	
	
// 2. Keep only the variables you need and limit the sample to state test scores.
	
	
// 3. Drop observations with a missing scaled score, a score of zero, or a negative score.
	
	
/*** Step 1: Ensure each student has one score per school year and grade level. ***/	

// Identify same-year repeat test takers and take the earliest score. If a student takes the same test more than once on the same date, use the highest score.

// 1. For each student, grade level, school year, and subject, find the earliest date a test was taken.
	
	
// 2. Keep only the test score from the earliest date.
	
	
// 3. For those with more than one such score on the same date, take the highest score.
	
	
// 4. Verify that each student has only one state test in a subject at a given grade level and school year.
	
	
/*** Step 2: Ensure each student has one score per school year. ***/	

// Identify different-year repeat test takes and take the score from the earliest school year.

// 1. For each student, subject, and grade level, find the earliest school year for which a score exists.
	
	
// 2. Keep only the test score from the earliest year.
	
	
// 3. Verify that each student has only one state test in a subject at a given grade level.
	
	
/*** Step 3: Reshape the data so math and ELA tests appear on the same row. ***/		
	
// 1. Reformat the test_subject variable for the reshape.
	
	
// 2. Verify that each student has only one state test in each year and drop unneeded variables.
	
	
/*** Step 4: Generate standardized and composite test scores. ***/
	
// 1. Compute standardized test scores with mean 0 and standard deviation 1.
	
	
// 2. Generate composite standardized scores that average standardized ELA and math scores.
	
	
/*** Step 5: Order the variables, sort the data, and save the file. ***/

// 1. Order the variables.
	
	
// 2. Sort the data.
	
	
// 3. Save the file.
	
	
log close
