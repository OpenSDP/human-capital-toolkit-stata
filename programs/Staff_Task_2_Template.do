/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Staff_Task_2.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program generates a clean Staff_Certifications file unique
* by tid school_year.
* The core of this task:
* 1. Identify teachers with special certifications, such as English as a Second Language (ESL), Special Education, and National Board Certification. 
* 2. Use teachers’ effective certification and effective expiration dates to determine the school years in which teachers became certified and their certifications expired.  
* 3. Ensure that you have one record per teacher per year.
*
* Inputs: /raw/Staff_Certifications.dta
*
* Outputs: /clean/Staff_Certifications_Clean.dta
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

log using "${log}\Staff_Task_2.txt", text replace

/*** Step 0: Load the Staff_Certifications raw input file ***/
	
	
/*** Step 1: Create consistent values for certification_code ***/ 

// 1. String fields entered by hand often contain spelling errors and nonstandard terms. Tabulate certification_code to examine the data. 
	
	
// 2. There are 16 unique values for certification_code but many appear to indicate the same certifications. 
// Some of these can be combined by changing all values to uppercase.  
	
	
// 3. Use a for loop with the index command to replace the remaining nonstandard terms with one consistent value. 
// The index command assigns one value to all values that contain a specified phrase. For example, every value that contains 
// the word "ESL" will be reassigned the value "ENGLISH AS A SECOND LANGUAGE" in the command below.  
	
	
// 4. Check that there is only one unique value for each certification.
	
	
/*** Step 2. Identify the school years in which a teacher’s certification is valid. ***/

// 1. Reformat effective and expiration dates to Stata date format.
	 
	
// 2. Identify the school years in which a certificate is valid. Generate variables that indicate the school year and month 
// in which a certificate became effective and a certificate expired.
	 
	
// 3. A certificate is valid during a particular school year if the certification effective date lies between May 1 
// of the previous school year and April 30 of the current school year. 
// To align the year and month variables just created with the standard of defining a school year by the spring year, add one year 
// to effective_date_year if certification effective dates fall between May and December. 
// No changes need to be made for certificates with effective dates between January and April. 
	
	
	// A certificate that expires before October 1 of the current school year is valid only through the end of the previous school year. 
	// No changes need to be made to expiration_date_year for certificates that expire between January and September. 
	// A certificate that expires between October 1 and April 30 of the current school year will be valid until the end of the current school year. 
	// Add one year to expiration_date_year if a certificate expires between October and December to align with defining a school year by the spring year. 
	
	
// 4. Drop observations that are missing both effective_date_year and expiration_date_year. These observations pertain to teachers 
// and certification codes with no evidence of an effective and expiration year. 
	
	
// 5. If a teacher only has either an effective date or an expiration date for a certificate, the most we know about that 
// teacher's certification is the year in which it was effective or expired. Assign the same year to both effective and expiration 
// dates if one or the other is missing. This means that the certificate is valid during the year in which it was issued or expired. 
	
	
// 6. Drop the month variables as they are no longer necessary.
	
	
// 7. Create an observation row for every combination of teacher, certification_code, and expiration_date_year. 
// "fillin" creates a variable called _fillin that indicates if the row was newly created (1) or original to the dataset (0). 
	
	
// 8. Create variables that identify the effective and expiration years for the observations that are original to the dataset. 
	
	
// 9. Generate the maximum value for expire_year and effective_year within teacher and certification_code. 
	
	
// 10. Generate a school_year variable that is equal to the expiration_date_year. 
// Drop observations that have school years before the max_effective_year and after the max_expire_year. 
// This should leave one observation for each school year in which a teacher held a valid certificate. 
	
	
// 11. Drop unnecessary variables. 
	
	
/*** Step 3. Create indicators for special certifications. ***/ 

// 1. Create temporary variables that indicate if a teacher has a certain certificate in a school year.
	
	
// 2. Populate the existence of a certificate in a school year for each teacher/school year observation.
	
	
// 3. Label the certification variables and values.
	
	
// 4. Drop the unnecessary variables and drop duplicates.
	
	
// 5. Verify that the file is unique by tid and school_year.
	
	
/*** Step 4. Keep relevant data and save the file. ***/

// 1. Limit the range of school years to those in the range of the Staff_School_Year_Raw file.
// First, load the Staff_School_Year_Raw file and assign the first and last school year value to local variables.
	
	
// Then drop variables that are outside of the range needed.
	
	
// 2. Save the current file as Staff_Certifications_Clean.dta.
	
	
log close
