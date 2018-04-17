/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Staff_Task_3.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program generates a clean Staff_Job_Codes file unique
* by tid, school_year, and school_code by:
* 1. Resolving instances in which a teacher has multiple degree levels in a single school year
* 2. Identifying a single job code for each individual within each school year 
*
* Inputs: /raw/Staff_School_Year_Raw.dta
*
* Outputs: /clean/Staff_Degrees_Job_Codes_Clean.dta
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

log using "${log}\Staff_Task_3.txt", text replace

/*** Step 0: Load the Staff_School_Year data file, keep only necessary variables and drop duplicates. ***/
	
	use "${raw}/Staff_School_Year_Raw.dta", clear
	keep tid school_year school_code degree job_code job_code_desc experience hire_date termination_date
	duplicates drop

/*** Step 1. Assign one unique value for each teacher degree level within each school year. ***/ 

// 1. String fields entered by hand often contain spelling errors and nonstandard terms. Tabulate degree to examine the data. 
	tab degree, mi
	 
// 2. There are many unique values for degree, but many appear to indicate the same degree. Some of these can be combined by changing all values to uppercase.
	replace degree = upper(degree) 
 
// 3. There are many variations of spellings for each degree level. The index command assigns one value to all values that contain a specified phrase. For example, every value that contains the letters "MA" will be reassigned the value "MASTERS DEGREE" in the command below. 
	replace degree = "MASTERS DEGREE" if index(degree, "MA") 
	replace degree = "DOCTORATE DEGREE" if index(degree, "PH") 
	
// 4. There are many variations of degree for teachers with bachelor's degrees. Use a for loop with the index command to replace the remaining nonstandard terms with one consistent value. 
	foreach ba in "A.B." "BA" "BACH"  { 
		replace degree = "BACHELORS DEGREE" if index(degree, "`ba'") 
	}
	
// 5. Check that there is one unique value for each degree level. 
	tab degree, mi 
	 
	assert degree == "" | degree == "BACHELORS DEGREE" | degree == "MASTERS DEGREE" | degree == "DOCTORATE DEGREE"
	
/*** Step 2. Recode the degree variable as a numeric variable and label it. Replace the string degree variable with the numeric one. ***/ 

// 1. Generate a variable that assigns a numeric value for each degree level. 
	gen degree_num = . 
	replace degree_num = 1 if degree == "BACHELORS DEGREE" 
	replace degree_num = 2 if degree == "MASTERS DEGREE" 
	replace degree_num = 3 if degree == "DOCTORATE DEGREE" 
	
	
// 2. Define value labels for degree_num that correspond to the string values in degree.
	label define degree 1 "Bachelor's Degree" 2 "Master's Degree" 3 "Doctorate Degree"
	label values degree_num degree 
	
// 3. Check that the values for degree_num match those in degree. Then, drop degree and rename degree_num to degree.
	tab degree degree_num, mi 
	drop degree 
	rename degree_num degree 
	

/*** Step 3: Resolve cases in which teachers are missing values for degree or have values less than the degree recorded in a prior year. ***/ 

// 1. Some teachers are missing values for degree in some years but not others. 
// Also, some have a value for a degree that is less than the degree they recorded in a prior year. 

// Use a for loop to identify the first and last years in which a teacher held a particular degree 
// and fill in missing or incorrect values. 

// Replace missing values for degree if no degree is recorded 
// for the last year(s) the teacher is in the data. 

// Begin with the highest degree value (doctorate) to impute the last observation(s) for each teacher 
// with the highest degree if the last values are missing. 

foreach degree in 3 2 1 { 
	egen temp_last_degree_year`degree' = max(school_year) if degree==`degree', by(tid) 
	egen last_degree_year`degree' = max(temp_last_degree_year`degree'), by(tid) 
	
	egen temp_first_degree_year`degree' = min(school_year) if degree==`degree', by(tid) 
	egen first_degree_year`degree' = max(temp_first_degree_year`degree'), by(tid) 
	
	replace degree = `degree' if school_year<=last_degree_year`degree' & school_year>=first_degree_year`degree'
	replace degree = `degree' if school_year>last_degree_year`degree' & mi(degree) & !mi(last_degree_year`degree')
	
	drop *first_degree* *last_degree* 
} 
			
/*** Step 4: Create consistent values for job_code_desc. ***/ 

// 1. String fields entered by hand often contain spelling errors and nonstandard terms. Tabulate job_code_desc to examine the data. 
	tab job_code_desc job_code, mi

// 2. There are many unique values for job_code_desc, but many appear to indicate the same job description. Some of these can be combined by changing all values to uppercase. 
	replace job_code_desc = upper(job_code_desc) 

// 3. Some job code descriptions have only two unique values. A replace command will resolve these cases. 
	replace job_code_desc = "PRINCIPAL / ASSISTANT PRINCIPAL" if job_code_desc=="AP" 
	
// 4. The index command assigns one value to all values that contain a specified phrase. For example, every value that contains the word "COACH" will be reassigned the value "COACH" in the command below. 
	replace job_code_desc = "COACH" if index(job_code_desc, "COACH") 
	
// 5. There are many variations of job_code_desc for teachers. Use a for loop with the index command to replace the remaining nonstandard terms with one consistent value. 
	foreach teach in "TEACHER" "TCHR" "TAECHER" { 
		replace job_code_desc = "TEACHER" if index(job_code_desc, "`teach'") 
	}

// 6. Tabulate job_code_desc to check that each job description has one unique value. 
	tab job_code_desc, mi
	
	
/*** Step 5: Create one consistent value for job_code for each teacher and school year. ***/

// 1. Destring job_code, turning it into a numeric variable. 
	destring job_code, replace 

// 2. Tabulate job_code and job_code_desc to check that each job description is assigned one job code. 
	tab job_code_desc job_code
	
// 3.  Notice that job_code 3 has two job descriptions: "CLASSROOM ASSITANT" and "SUBSTITUTE". These appear to be different positions. Assign a new, unique job code to classroom assistants. 
	replace job_code = 9 if job_code_desc == "CLASSROOM ASSISTANT" 

// 4. Individuals in a school district often serve multiple roles in the same school year. Create a variable that shows how many unique values job_code assumes for each teacher and school year. Name this variable nvals_job. 
	bys tid school_year: egen nvals_job = nvals(job_code)

// 5. Tabulate nvals_job to determine how many instances there are in the data where teachers have more than one unique job code reported in the same school year. 
	tab nvals_job, mi

// 6. Create a variable using job_code that flags an individual as a teacher. Using parentheses around the "if statement" tells Stata to make a binary variable that assigns a value of 1 to all observations where the statement is true and 0 to all other observations. 
	gen teacher = (job_code == 1) 

// 7. Create a variable that indicates whether an individual is a teacher in that school year.
	bys tid school_year: egen t_is_teacher = max(teacher)

// 8. For individuals who are teachers and have other job descriptions in the same school year, replace their job code with "TEACHER" in all instances. 
	replace job_code_desc = "TEACHER" if t_is_teacher == 1 
	replace job_code = 1 if t_is_teacher == 1  

// 9. For individuals who have multiple job codes in the same school year and are not teachers, keep the observation that is "PRINCIPAL / ASSISTANT PRINCIPAL". 
	gen principal = 0 
	replace principal = 1 if job_code == 2
	bys tid school_year: egen is_principal = max(principal)
	replace job_code_desc = "PRINCIPAL / ASSISTANT PRINCIPAL" if is_principal == 1 & t_is_teacher == 0
	replace job_code = 2 if is_principal == 1 & t_is_teacher == 0  

// The standard SDP analysis does not differentiate teachers by the jobs they take after they leave teaching if they stay in the district. 
// A possible extension to the Human Capital diagnostic is to determine the average teacher effect scores of teachers who become principals. 

// 10. Some individuals still have more than one job code per school year but are neither teachers nor principals. Resolve these cases using the decision rules below. 
	// First, give priority to permanent roles (drop instances where individuals are temps or substitutes).
	// Then, drop observations in which the position is non-academic (coaches and school staff). 
	// Give preference to special education assistants - a more specialized position - over classroom assistants. 
	// Finally, give preference to counselors over special education assistants. 
	
	// Use a for loop to accomplish this process efficiently. List the job codes in the order specified above, drop cases in which the role has lower priority for teachers with more than one job in the same school year, and re-identify teachers who still have more than one job code after executing each decision rule.
	foreach job in 7 3 4 8 9 6 { 
		drop if nvals_job > 1 & job_code==`job' 
		drop nvals_job
		bys tid school_year: egen nvals_job = nvals(job_code) 
	}

// 11. Label the values of job_code and drop job_code_desc. 
	label define job 1 "Teacher" 2 "Principal / Assistant Principal" 3 "Substitute" 4 "Coach" 5 "Counselor" 6 "Special Education Assistant" 7 "Temp" 8 "School Staff" 9 "Classroom Assistant"
	label values job_code job 
	
	drop job_code_desc
	
// 12. Drop unnecessary variables. Keep the t_is_teacher variable to identify teachers for analysis samples. 
	drop nvals_job teacher principal is_principal  


/*** Step 6. Make the data unique by tid, school_year, and school_code, check the data, and save the file. ***/

// 1. Drop duplicate observations. 
	duplicates drop 

// 2. Check that the file is unique by tid, school_year, and school_code.
	isid tid school_year school_code 

// 3. Order variables, sort the data, and save the data file.
	order  tid school_year school_code job_code degree t_is_teacher experience hire_date termination_date
	sort tid school_year 
	save "${clean}/Staff_Degrees_Job_Codes_Clean.dta", replace

log close
