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
	
	
/*** Step 1: Create one consistent gender value for each teacher across years. ***/

// 1. Tabulate the male variable to see its values and determine whether any are missing. 
	
	
// 2. Create a variable that shows how many unique values male assumes for each teacher. Name this variable nvals_male. 
	
	
// 3. Tabulate nvals_male to determine how many instances there are in the data in which teachers have more than one unique gender reported.
	
	
// 4. Generate a variable called male_mode that reports the modal gender for each teacher. 
	
	
// 5. For teachers who have a mode, replace their gender with male_mode. 
	
	
// 6. In instances where there are multiple modes, take the most recent value reported. 
	
	
// 7. Generate a variable called temp_male_last that identifies the gender for the first (most recent) observation for each teacher. 
	
	
// 8. Generate a variable that assigns the highest value of temp_male_last (the only non-missing value) to all observations within a each teacher. Call this variable male_last. 
	
	
// 9. Replace male with male_last if male_mode is missing (a teacher has multiple modes for gender). 
	
	
// 10. Drop temporary variables you created.
	
	
/*** Step 2. Create one consistent certification pathway for each teacher across years. ***/

// 1. Tabulate the "certification_pathway" variable to see its values and whether any are missing. 
	
	
// 2. Create consistent values for each certification pathway. 
	
	
// 3. Check that there is only one value for each certification_pathway. 
	
	
// 4. Replace certification_pathway's values with numeric values. 
	
	
// 5. Destring certification pathway. 
	
	
// 6. Label the values of certification pathway.
	
	
// 7. Create a variable that shows how many unique values certification_path assumes for each teacher. Name this variable nvals_cert. 
	
	
// 8. Tabulate nvals_cert to determine how many instances there are in the data where teachers have more than one unique certification pathway reported.
	
// 9. Generate a variable called cert_mode that reports the modal certification pathway for each teacher. 
	
	
// 10. For teachers who have a mode, replace their certification pathway with cert_mode. 
	
	
// 11. This data set does not have any instances where there are multiple modes for teacher certification. As an exercise, fill in the remaining code as if there were multiple modes using Step 1 (creating a consistent gender) as a model.	
/*		
// Sort the data so that the most recent school year is the first observation for each teacher. 
	
	
// 12. Generate a variable called temp_cert_last that identifies the certification pathway for the first (most recent) observation for each teacher. 
	
	
// 13. Generate a variable that assigns the highest value of temp_cert_last (the only non-missing value) to all observations within a each teacher. Call this variable cert_last. 
	
	
// 14. Replace certificaton_path with cert_last if cert_mode is missing (a teacher has multiple modes for certification_path).
	

*/
// 15. Drop temporary variables you created. 
	
	
/*** Step 3: Create one consistent value for race_ethnicity for each teacher across years. ***/

// 1. Tabulate the race_ethnicity variable to see its values and check if any are missing. 
	
	
// 2. Create a numeric variable that has consistent values for each race/ethnicity. Use a for loop to standardize values for Black and  Latino, which have several different spelling variations. 
	
	
// 3. Destring the race_num variable 
	
	
// 4. Label the values of race_num 
	
	
// 5. Check that the values for race_num correspond to the values for race_ethnicity. Tabulate both variables. 
	
	
// 6. Drop the string race_ethnicity variable and rename the numeric one "race_ethnicity".
	
	
// 7. Create a variable that shows how many unique values race_ethnicity assumes for each teacher in each school year. Name this variable nvals_race_year. 
	
	
// 8. Tabulate nvals_race_year to determine how many instances there are in the data where race_ethnicity is not consistent within tid and school_year.
	
	
//9. If a teacher has more than one race in a single school year, replace the teacher's race as multiracial.
	
	
// 10. Generate a variable called temp_islatino to identify observations where a teacher is reported to be Latino. 
	
	
// 11. Generate a variable called islatino that indicates the maximum value of temp_islatino for all observations within each teacher and year. 
	
	
	// Latino teachers should have a value of “1” across all observations and all other teachers should have missing values across all observations for islatino. 
	
	
// 12. Replace race_ethnicity with 3 (Latino) if one of the race_ethnicity values within the same teacher and year is 3 (Latino). 
	
	
	// Replace race_ethnicity with 6 (Multiracial) if a teacher has more than one race in the same year and none of the race_ethnicity values are 3 (Latino).
	
	
// 13. Drop the temporary variables you created. 
	
	
// 14. Next, make race_ethnicity consistent by tid. 
	
	// Check if race_ethnicity is consistent by tid by creating a variable that shows how many unique values race_ethnicity assumes for each teacher. Name this variable nvals_race. 
	
	
// 15. Tabulate nvals_race to determine how many instances there are in the data where race_ethnicity is not consistent within tid.
	
	
// 16. Generate a variable called race_mode that indicates the mode for each teacher’s race_ethnicity.
	
	
// 17. For teachers who have a mode, replace their race_ethnicity with race_mode. 
	
	
// 18. In instances where there are multiple modes, take the most recent value reported.

	// Sort the data so that the most recent school year is the first observation for each teacher. 
	
	
// 19. Generate a variable called temp_race_last that identifies the race_ethnicity for the first (most recent) observation for each teacher. 
	
	
// 20. Generate a variable that assigns the highest value of temp_race_last (the only non-missing value) to all observations within a each teacher. Call this variable race_last.
	
	
// 21. Replace race_ethnicity with race_last if race_mode is missing (a teacher has multiple modes for race_ethnicity). 
	
	
// 22. Drop the temporary variables you created.	
	
	
/*** Step 4: Create one consistent value for birth_date for each teacher across years. ***/
	
// 1.  Convert birth_date to a numeric variable in Stata date format.
	
	
// 2.  Check the number of unique birth dates recorded for each teacher.
	
	
// 3.  Check the number of missing birth dates.
	
	
// 4.  Since each teacher has only one birthday, this variable is clean, so drop the temporary variables you created.
	
	
/*** Step 5: Make the data unique by tid, check the data, and save the file. ***/

// 1.  At this point, we have cleaned the data. We no longer need the school year variable. 
	
	
// 2. Drop duplicate observations.
	
	
// 3. Check that the file is unique by tid.
	
	
// 4. Check the distribution and range of values for each variable; check for missing data.

	// Count the number of observations 
	
	
	// Produce a detailed summary of male, race_ethnicity, and certification_path, check the number of non-missing observations, range, and distribution.
	
	
// 5. Order the variables, sort, and save the current file as Staff_Attributes_Clean.dta.
	
	
log close
