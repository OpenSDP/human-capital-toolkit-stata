/****************************************************************************
* SDP Version 01.0
* Last Updated: April 3, 2014
* File name: Connect.do
* Author(s): Strategic Data Project
* Description:
* This program generates analysis files used to make the charts in the Analyze
* section. 
*
* Inputs: All of the final outputs from School Task 1, Staff Tasks 1-4, and Student Tasks 1-4
*
* Outputs: Student_Teacher_Year_Analysis, Teacher_Year_Analysis
*
***************************************************************************/

clear all
set more off
capture log close
set mem 1000m

// Change the file path below to the directory with folders for data, logs, programs and tables and figures.
cd "K:\working_files"

global raw		".\data\raw"
global clean	".\data\clean"
global analysis	".\data\analysis"

// Create a folder for log files in the top level directory if one does not exist already.
global log 		".\logs"

// Switches
global step_1_merge				"1"
global step_2_restrict			"1"
global step_3_generate			"1"
global step_4_understand		"1"

log using "${log}\Connect.txt", text replace 

/****************************************
* STEP 1: Merge all files together
****************************************/
if $step_1_merge == 1 {

	// 1.1 Load the Core_Courses_Clean output file and ensure its uniqueness by class ID.
	

	// 1.2 Merge the Student_Class_Enrollment_Clean output file using the class ID as an identifier.
	
	
	// 1.3 Load Student_Test_Scores_Clean. Create a quartile variable that corresponds to each test subject. Create variables for prior-year test results.
	
		preserve
		
			
		restore

	// 1.4 Merge the `student_test_scores' tempfile to the working file you previously had in memory. 
		

	// 1.5 Load Student_School_Year_Clean and rename all student variables with an 's_' prefix.
	
		preserve
			
			
		restore
		
	// 1.6 Merge the `student_school_year' tempfile to the working file you previously had in memory.
		
		
	// 1.7 Load Student_Attributes_Clean and rename all student variables with an 's_' prefix. Merge the `student_school_year' tempfile to the working file you previously had in memory.

		preserve
		
	
		restore
		
	
	// 1.8 Perform a similar set of operations for the Staff files including: Staff_School_Year_Clean, Staff_Attributes_Clean and Staff_Certifications_Clean. Add a “t_” prefix to identify these as teacher variables.

		// Staff school year
		preserve
		
			
		restore
		
	
		// Staff attributes

		preserve
		
	
		restore
		
		merge m:1 tid using `staff_attributes', gen(_m_staff_attributes)
		
		// Staff certifications

		preserve
		
		
		restore

		
	// 1.9 Merge on the School file which to obtain information on school names, types, and poverty level.

	
	
	// 1.10 Drop observations missing student ids, sort the file, and then save as Connect_Step1.dta.

	save "${analysis}/Connect_Step1.dta", replace
	
}

/***************************************************************
* STEP 2: Restrict the sample to tested grades and core subjects 
***************************************************************/
if $step_2_restrict == 1 {
	
	// 2.1 Load the Connect_Step1 file and drop the merge variables you will not need for Analyze.
		

	// 2.2 Keep data only on core courses.
		
		
	// 2.3 Drop courses that have more than one or no teacher.	
		
		
	// 2.4 Drop students who have more than one core course in a given subject in a given year.
		
		
	// 2.5 Drop classes with a small number of students.
		
		
	// 2.6 Check that each student has core courses in only one school in any year.
	
		
	// 2.7 Restructure the data file to have math and ELA teacher IDs and math and ELA class IDs for each student and school year. 
	// This process will structure the data so it will be unique by student and school_year in the next substep.	
		
		
	// 2.8 Drop duplicates and assert that the file is now unique by student and school_year.
		
		
	// 2.9 Generate dummy variables. Impute missing values to zero and define indicators for missing.
		
		
	// 2.10 Generate class and cohort-level average variables.
		
		
	// 2.11 Generate class and cohort size variables.
		
		
	// 2.12 Generate variables that capture the proportion of students with a missing prior test score for both class and cohort.
		
		
	// 2.13 Create school poverty measures at the year-school level using student FRPL indicators.
		preserve
		

		restore

		
	// 2.14 Create average prior achievement measures at the year-school level using student test scores.

		preserve 
		
		restore 

		
	// 2.15 Sort the file, ensure uniqueness, and then save as Connect_Step2.dta.
	
		save ${analysis}/Connect_Step2.dta, replace
	
}	

/**************************************************************************************************************
* STEP 3: Generate key variables required for the Teacher_Year_Analysis file
**************************************************************************************************************/
if $step_3_generate == 1 {

	// 3.1 Load the Connect_Step1 file and drop the student-level variables you will not need for the Teacher_Year_Analysis file.
	
	
	// 3.2 Resolve any potential conflicts in the school_code variable by giving preference to the student data.
	
		
	// 3.3 Merge on the school-level variables from the school file using the now-singular school code.
	

	// 3.4 Create dummy variables for race/ethnicity, which will be used as controls or outcomes in Analyze.

		
	// 3.5 Create an indicator for a teacher possessing either a Master’s or Doctorate degree.
	
		
	// 3.6 Create a new hire dummy variable.
	

	// 3.7 Create t_novice, t_novice_ever and veteran new hire dummy variables.	
	
		
	// 3.8 Create the retention dummy variables.
		
		// Set the time series
		
		// Define next-year status variables
		
	// 3.9 Merge on the school-level poverty and average prior achievement variables created in Connect Step 2. 
		
		preserve 

		restore 
		
	
	// 3.10 Sort the file, ensure uniqueness, save a tempfile, and then save as Teacher_Year_Analysis.dta.
	
		save ${analysis}/Teacher_Year_Analysis.dta, replace
}		
/**************************************************************************************************************
* STEP 4: Merge on teacher value added estimates and save the Student_Teacher_Year_Analysis and Teacher_Year_Analysis files
**************************************************************************************************************/
if $step_4_understand==1 { 
		
	// 4.1 Understand one possible measure of teacher effectiveness, value-added estimates.

	// 4.2 Load the Teacher_Year_Analysis file, merge on your chosen measure of teacher effectiveness, 
	// and save the final Teacher_Year_Analysis file. 
	
		save ${analysis}/Teacher_Year_Analysis.dta, replace 
				
	// 4.3 Structure the student analysis file so that each student has two observations for each year – 
	// one that contains information relevant to math, and the other to ELA.dta.
	
		
	// 4.4 Sort the file, ensure uniqueness, and then save as Student_Teacher_Year_Analysis.dta.
	
		save ${analysis}/Student_Teacher_Year_Analysis.dta, replace	

}
log close
