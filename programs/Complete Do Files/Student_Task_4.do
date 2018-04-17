/****************************************************************************
* SDP Version 1.0
* Last Updated: December 18, 2013
* File name: Student_Task_4.do
* Author(s): Strategic Data Project
* Date: 
* The core of this task:
* 1.	Establish a true one-to-one relationship between course code and course description for all classes.
* 2.	Identify course code – course description pairs that constitute core courses in math and ELA.
* 3.	Identify a single teacher for each course.
*
* Inputs: /raw/Student_Class_Enrollment_Raw.dta
*
* Outputs: /clean/Core_Courses_Clean.dta
*		   /clean/Student_Class_Enrollment_Clean.dta
*
***************************************************************************/

clear
set more off
set mem 1000m
cap log close

// Change the file path below to the directory with folders for data, logs, programs and tables and figures.
cd "K:\working_files"

global raw		".\data\raw"
global clean	".\data\clean"
// Create a folder for log files in the top level directory if one does not exist already.
global log 		".\logs"

log using "${log}\Student_Task_4.txt", text replace

/*** Step 0: Load the Student_Class_Enrollment_Raw file. ***/
	use "${raw}/Student_Class_Enrollment_Raw.dta", clear

/*** Step 1: Fix spelling mistakes and inconsistencies in the string variables. ***/

// 1. Destring course code and section code for ease of writing "if" conditions without double quotes and to enable modal operations in Step 2.
	destring course_code section_code, replace
	
// 2. Combine same-subject departments using the results of the tabulation.
	tab department, mi
	replace department = "ELA" if department == "ENG" | department == "ENGL" | department == "LIT"
	replace department = "MTH" if department == "MATH"

// 3. Standardize similar course names.
	tab course_code_desc, mi
	
	replace course_code_desc = "FOURTH GRADE" if course_code_desc == "4TH GRADE" | course_code_desc == "FORTH GRADE"
	replace course_code_desc = "FIFTH GRADE" if course_code_desc == "5TH GRADE" | course_code_desc == "GRADE 5"

	replace course_code_desc = "ALGEBRA 1" if course_code_desc == "AGLEBRA 1"

	replace course_code_desc = "LIT & COMP" if course_code_desc == "LITCMP"
	replace course_code_desc = "ENGLISH 6" if course_code_desc == "EGNLISH 6"
	replace course_code_desc = "ENGLISH 7" if course_code_desc == "EGNLISH7"
	
// 4. Check the courses labeled "MATH".
	tab course_code if course_code_desc == "MATH"
	tab course_code_desc if course_code == 26
	tab course_code_desc if course_code == 27
	
// 5. Since it's clear that "MATH" should be either "MATH 6" or "MATH 7", change it where possible.
	replace course_code_desc = "MATH 6" if course_code_desc == "MATH" & course_code == 26
	replace course_code_desc = "MATH 7" if course_code_desc == "MATH" & course_code == 27
	
// 6. Check the courses labeled "ENGLISH".
	tab course_code if course_code_desc == "ENGLISH"
	tab course_code_desc if course_code == 11
	tab course_code_desc if course_code == 12
	
// 7. Since it's clear that "ENGLISH" should be either "ENGLISH 6" or "ENGLISH 7", change it where possible.
	replace course_code_desc = "ENGLISH 6" if course_code_desc == "ENGLISH" & course_code == 11
	replace course_code_desc = "ENGLISH 7" if course_code_desc == "ENGLISH" & course_code == 12
	
// Note that not all instances of "MATH" and "ENGLISH" could be fixed as there is no way to know what real course they signify.
	tab department if course_code_desc == "MATH"
	tab department if course_code_desc == "ENGLISH"
	
// 8. Check that there are no core-course-sounding classes in non-core departments (can ignore fixing these).
	tab course_code_desc if department != "ELA" & department != "MTH" & department != "ELEM"

/*** Step 2: Merge on grade level information and browse course descriptions by grade level
			 to identify courses that most students at each grade level are enrolled in. ***/	 
	
// 1. Preserve the data and load the clean Student School Year information.
	preserve
		use ${clean}/Student_School_Year_Clean.dta, clear
		
// 2. Keep only the merge variables (student ID and school year) and grade level.
		keep sid school_year grade_level
		
// 3. Save as a temp file and restore the data.
		tempfile grade_level_data
		save `grade_level_data'
		
	restore
	
// 4. Merge on the grade level information by student ID and school year, and assure that the merge is successful.
	merge m:1 sid school_year using `grade_level_data', assert(3) nogen
	 
// 5. Cross tabulate course description by grade level, restricted to core departments, to determine the courses that most students 
// at each grade level are enrolled in. Note these course descriptions for later.
	tab course_code_desc grade_level if department == "MTH" | department == "ELA"
	
// For example, in the tab above, it is easy to see that for 6th graders, most of the observations fall under two courses: 40% of 
// observations are for ENGLISH 6 and 42% are for MATH 6. 
// It is reasonable to infer that these are the standard required core math and ELA courses for 6th graders, with the other courses 
// mostly electives, extended pullouts, and advanced courses.

/*** Step 3: Use modal instances within course code to establish 1-to-1 relation between 
			 course code and course description, and create indicators for core courses. ***/
	preserve
	
// 1. Keep only needed variables and non-missing observations.
		keep course*
		drop if course_code_desc == "" | course_code == .
	
// 2. Since we could not accurately label some "ENGLISH" and "MATH" instances, drop them from our true table.
		drop if course_code_desc == "MATH" | course_code_desc == "ENGLISH"
	
// 3. Find modal course code for each course descripiton.
		egen mode = mode(course_code), by(course_code_desc)
	
// 4. Drop those observations where the course code does not equal to the modal course code for a given course description.
		drop if course_code != mode
		drop mode
	
// 5. Drop duplicate observations.
		duplicates drop
	
// 6. Make sure there is a 1-to-1 relation between course code and course code description.
		unique course_code
		local a = r(sum)
		unique course_code_desc
		local b = r(sum)
		assert `a' == `b'

// 7. Create indicators for math and ELA by browsing the list and selecting appropriately.
		gen math = inlist(course_code, 2, 3, 13, 16, 26, 27, 28, 37, 51, 52)
		gen ela = inlist(course_code, 10, 11, 12, 13, 16, 22, 25, 40, 47)

// 8. Using the course descriptions identified in Step 2 as core courses, identify core course codes in math and ELA.

// Note that you should also use agency knowledge to complete identification of core courses. For example, the earlier tabulations 
// would not indicate that "ALG / GEOM" is a core course because not many 8th graders are enrolled in it. However, it is counted as a 
// core course because it is the only math course for advanced students, which are a relative minority among their peers. This information 
// can be obtained from your agency.
		gen core = inlist(course_code, 3, 11, 12, 13, 16, 25, 26, 27, 51, 52)
	
// 9. Save data in a temporary file for later use.
		sort course_code
		tempfile course_catalog
		save `course_catalog'
	
	restore
	
/*** Step 4: Create a class file that contains, for each class ID, a singular teacher ID and indicators for math, ELA, and core courses. ***/

// 1. Preserve the data and find the modal teacher for each class ID and assign it to each class ID.

// Note that it is likely that, in your agency, there is not always one teacher per physical classroom (team teaching, for example). 
// In this data, however, there is a very small number of instances where this occurs, likely due to typos in the raw data and perhaps 
// a few specialized classrooms. Thus, the analyses you will perform in the Analyze section use value-added estimates that assume one 
// teacher per classroom. If team teaching is prevalent in your agency, it may be important to consider using weights in the value-added 
// estimation step to properly attribute each teacher's influence on student achievement in such classrooms. This, however, is beyond the 
// scope of this toolkit.
preserve
		egen tid_mode = mode(tid), by(cid)
		replace tid = tid_mode
		drop tid_mode
	
// 2. Investigate the reliability of course_code and course_code_desc in order to determine which one (or both) to use to create the subject and
// core indicators.

// Note that as there may be typos in the raw data, there may not be a perfect concordance between course code and course description. To extract
// whether a given class ID is a math and/or ELA course and/or core course, it is necessary to use the more reliable of the available variables that 
// refer to the type course that class ID is. In cases where there is no obvious difference in reliability, it may be best to use a combination of the
// variables to assess the most likely "true" status of a given course. In this case, however, it is clear that the combination of course description and
// department are more reliable than the combination of course code and department. Thus, the indicators will be created based off of the course description.
		browse course_code if department == "MTH"
		browse course_code_desc if department == "MTH"
	
		browse course_code if department == "ELA"
		browse course_code_desc if department == "ELA"
	
// 3. Temporarily rename course_code so as to not overwrite it during the merge that follows.
		rename course_code raw_course_code

// 4. Using the course description, merge on the indicators from the course catalog constructed in Step 3.9.
		merge m:1 course_code_desc using `course_catalog', keep(1 2 3) nogen
	
// 5. Drop course_code from the course catalog, and rename raw_course_code back to its original name.
		drop course_code
		rename raw_course_code course_code

// 6. For each class ID, find the modes of the indicators for math, ELA, and core course, and replace each indicator with its corresponding modal value.
		foreach indicator in math ela core{
			egen `indicator'_mode = mode(`indicator'), by(cid)
			replace `indicator' = `indicator'_mode
			drop `indicator'_mode
		}
	
// Note that a singular course description or course code is not forced on each class ID. The only variables of importance to value-added estimation
// are the math, ELA, and core course indicators. For example, if there are 20 students in a given class ID, and 19 of them have that class ID marked
// as an Algebra class, while the 20th has it marked as Photography, the modal values of the indicators will label that class ID as a core math course,
// even for the student who is supposedly studying Photography. It may seem prudent to attribute that discrepancy to a typo and overwrite Photography with
// Algebra. However, such overwriting becomes problematic in mixed-level classrooms, when, for example, 6th and 7th graders are studying 6th and 7th grade
// level math, respectively, in the same classroom. If the modal course code or description was forced on such a classroom, it may appear that some of the
// students are either advanced or remedial, when neither is true. However, we can be reasonably sure that in such a classroom, students are pursuing a core
// math course.
	
// 7. Keep only the necessary variables and ensure uniqueness at the class ID level.
		keep cid tid school_year school_code math ela core
		duplicates drop
		isid cid

// 8. Save the class ID and indicator data and restore.
		save "${clean}/Core_Courses_Clean.dta", replace

	restore

/*** Step 5: Save the Student_Class_Enrollment_Clean file ensuring uniqueness by sid and cid. ***/

// 1. Keep relevant variables.
	keep sid cid final_grade_mark final_grade_mark_numeric
	
// 2. Drop duplicates.
	duplicates drop
	
// 3. Find all cases where there is more than one observation for a sid-cid pair.
	bys sid cid: gen x = _N
	tab x
	
// 4. Ensure that only one of the observations has grade information.
	gen grade_info_exists = !mi(final_grade_mark)
	egen grade_info_exists_max = max(grade_info_exists) if x >1, by(sid cid)
	egen grade_info_exists_min = min(grade_info_exists) if x >1, by(sid cid)
	assert grade_info_exists_max == 1 & grade_info_exists_min == 0 if x >1
	
// 5. For such cases, drop the observations without grade information.
	drop if mi(final_grade_mark) & x >1
	
// 6. Clean up the file and save.
	drop x grade_info*
	isid sid cid
	save "${clean}/Student_Class_Enrollment_Clean.dta", replace
	
/*** Step 6: Run checks to make sure that the class data is sensible. ***/

// 1. Merge on the class data.
	merge m:1 cid using "${clean}/Core_Courses_Clean.dta", keep(1 3) nogen
	
// 2. Check that students take a reasonable number of classes in a given year.
	egen stu_class_per_year = count(cid), by(sid school_year)
	tab stu_class_per_year, mi
	
// 3. Check that students usually have one ELA and one math core course in a given year.  First, preserve the data and keep the necessary variables.
	preserve 
		keep sid cid school_year math ela core
		
// 4. For each subject, count the instances of core math and core ELA courses for each student and year, and fill in for each student.
		foreach subj in math ela{
			egen core_`subj'_per_year_temp = count(cid) if `subj' == 1 & core == 1, by(sid school_year)
			egen core_`subj'_per_year = max(core_`subj'_per_year_temp), by(sid school_year)
			drop core_`subj'_per_year_temp
		}
		
// 5. Keep only the necessary variables, drop duplicates, ensure uniqueness by student ID and school year, tab the variables, and then restore the data.
		keep sid school_year core_*_per_year
		duplicates drop
		isid sid school_year
		tab core_math_per_year, mi
		tab core_ela_per_year, mi
	
	restore
	
// 6. Check that class sizes are reasonable.
	egen class_size = count(sid), by(cid)
	summ class_size, detail
	
// 7. Check that teachers teach a reasonable number of classes in a given year.
	keep tid cid school_year
	duplicates drop
	egen tch_class_per_year = count(cid), by(tid school_year)
	tab tch_class_per_year

log close
