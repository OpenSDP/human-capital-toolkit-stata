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
	
		use "${clean}/Core_Courses_Clean.dta", clear
		isid cid

	// 1.2 Merge the Student_Class_Enrollment_Clean output file using the class ID as an identifier.
	
		merge 1:m cid using "${clean}/Student_Class_Enrollment_Clean.dta", gen(_m_class_enrollment) keepusing(sid cid)
		duplicates drop
		isid sid cid
	
	// 1.3 Load Student_Test_Scores_Clean. Create a quartile variable that corresponds to each test subject. Create variables for prior-year test results.
	
		preserve
		
			use "${clean}/Student_Test_Scores_Clean.dta", clear
			drop *composite
			
			foreach subj in math ela {
			
					quietly: levelsof school_year, local(year_list)
					foreach yr in `year_list' {
				
						quietly: levelsof grade_level, local(grade_list)
						foreach gr in `grade_list' {
						
							xtile qrt_`gr'_`subj'_`yr' = scaled_score_`subj' if school_year == `yr' & grade_level == `gr', nq(4)
						
						}
					}
				}
				
				foreach subj in math ela {
					egen qrt_`subj' = rowmax(qrt_*_`subj'_*)
				}
				drop qrt_*_*_*
				
			tsset sid school_year
			
			foreach var of varlist scaled* std* qrt* language* {
				bys sid: gen `var'_tm1 = L.`var'
			}
			
			tempfile student_test_scores
			save `student_test_scores'
			
		restore

	// 1.4 Merge the `student_test_scores' tempfile to the working file you previously had in memory. 
		
		merge m:1 sid school_year using `student_test_scores', gen(_m_test_scores)
		isid sid cid

	// 1.5 Load Student_School_Year_Clean and rename all student variables with an 's_' prefix.
	
		preserve
			
			use "${clean}/Student_School_Year_Clean.dta", clear
			
			foreach var of varlist grade_level  days* absence* {
				rename `var' s_`var'
			}
			
			tempfile student_school_year
			save `student_school_year'
			
		restore
		
	// 1.6 Merge the `student_school_year' tempfile to the working file you previously had in memory.
		
		merge m:1 sid school_year using `student_school_year', gen(_m_student_school_year)
		
	// 1.7 Load Student_Attributes_Clean and rename all student variables with an 's_' prefix. Merge the `student_school_year' tempfile to the working file you previously had in memory.

		preserve
		
			use "${clean}/Student_Attributes_Clean.dta", clear
			isid sid
			
			rename male s_male
			rename race_ethnicity s_race_ethnicity
			
			tempfile student_attributes
			save `student_attributes'
	
		restore
		
		merge m:1 sid using `student_attributes', gen(_m_student_attributes)	

	
	// 1.8 Perform a similar set of operations for the Staff files including: Staff_School_Year_Clean, Staff_Attributes_Clean and Staff_Certifications_Clean. Add a “t_” prefix to identify these as teacher variables.

		// Staff school year
		preserve
		
			use "${clean}\Staff_School_Year_Clean.dta", clear
			
			foreach var of varlist school_code job_code degree experience hire_date termination_date {
				rename `var' t_`var'
			}
			
			tempfile staff_school_year
			save `staff_school_year'
			
		restore
		
		merge m:1 tid school_year using `staff_school_year', gen(_m_staff_school_year)
	
		// Staff attributes
		preserve
		
			use "${clean}/Staff_Attributes_Clean.dta", clear
			
			// birth_date is not needed
			drop birth_date
			
			isid tid
			
			foreach var of varlist male certification_pathway race_ethnicity {
				rename `var' t_`var'
			}
			
			tempfile staff_attributes
			save `staff_attributes'
	
		restore
		
		merge m:1 tid using `staff_attributes', gen(_m_staff_attributes)
		
		// Staff certifications
		preserve
		
			use "${clean}/Staff_Certifications_Clean.dta", clear
			isid tid school_year
			
			foreach var of varlist certification*{
				rename `var' t_`var'
			}
		
			tempfile staff_certifications
			save `staff_certifications'
		
		restore

		merge m:1 tid school_year using `staff_certifications', gen(_m_staff_certificatons)
		
	// 1.9 Merge on the School file which to obtain information on school names, types, and poverty level.
		merge m:1 school_code using "${clean}/School_Clean.dta", gen(_m_school)
	
	// 1.10 Drop observations missing student ids, sort the file, and then save as Connect_Step1.dta.
	drop if mi(sid) 
	sort sid cid school_year
	isid sid cid school_year
	save "${analysis}/Connect_Step1.dta", replace
	
}

/***************************************************************
* STEP 2: Restrict the sample to tested grades and core subjects 
***************************************************************/
if $step_2_restrict == 1 {
	
	// 2.1 Load the Connect_Step1 file and drop the merge variables you will not need for Analyze.
		
		use "${analysis}/Connect_Step1.dta", clear
		drop _m_*
		duplicates drop

	// 2.2 Keep data only on core courses.
		
		tab core, mi
		keep if core == 1
		
		assert math == 1 | ela == 1
		assert cid != .
		
		drop core
		
	// 2.3 Drop courses that have more than one or no teacher.	
		
		egen num_teach = nvals(tid), by(cid)
		tab num_teach, mi
		
		drop if num_teach != 1
		drop num_teach
		
	// 2.4 Drop students who have more than one core course in a given subject in a given year.
		
		foreach subj in math ela {
			egen num_core_`subj' = nvals(cid) if `subj' == 1, by(sid school_year)
			drop if num_core_`subj' > 1 & num_core_`subj' != .
			drop num_core_`subj'
		}
		
	// 2.5 Drop classes with a small number of students.
		
		egen class_size = nvals(sid), by(cid)
		drop if class_size <= 5
		drop class_size
		
	// 2.6 Check that each student has core courses in only one school in any year.
	
		egen num_schools = nvals(school_code), by(sid school_year)
		assert num_schools == 1
		drop num_schools
		
	// 2.7 Restructure the data file to have math and ELA teacher IDs and math and ELA class IDs for each student and school year. 
	// This process will structure the data so it will be unique by student and school_year in the next substep.	
		
		foreach var in tid cid {
			foreach subj in math ela {
				gen `var'_`subj'_ = `var' if `subj' == 1
				egen check = nvals(`var'_`subj'_), by(sid school_year)
				assert check == 1 | check == .
				egen `var'_`subj' = max(`var'_`subj'_), by(sid school_year)
				drop check `var'_`subj'_
			}
		}
		
	// 2.8 Drop duplicates and assert that the file is now unique by student and school_year.
		
		drop tid cid t_* math ela
		duplicates drop
		isid sid school_year
		
	// 2.9 Generate dummy variables. Impute missing values to zero and define indicators for missing.
		
		gen s_black = (s_race_ethnicity == 1)
		gen s_asian = (s_race_ethnicity == 2)
		gen s_latino = (s_race_ethnicity == 3)
		gen s_naam = (s_race_ethnicity == 4)
		gen s_white = (s_race_ethnicity == 5)
		gen s_mult = (s_race_ethnicity == 6)
		gen s_racemiss = (s_race_ethnicity == 7)
		
		gen s_fulllunch = (s_frpl == 0)
		gen s_reducedlunch = (s_frpl == 1)
		gen s_freelunch = (s_frpl == 2)
		gen s_lunch_miss = (s_frpl == .)
		
		replace s_absence_high = 0 if s_absence_miss == 1
		
		foreach var of varlist s_iep s_ell s_retained s_gifted {
			gen `var'_miss = (`var' == .)
			replace `var' = 0 if `var'_miss == 1
		}
		
	// 2.10 Generate class and cohort-level average variables.
		
		foreach var of varlist s_retained s_iep-s_gifted s_absence_high-s_male s_black-s_racemiss s_reducedlunch-s_gifted_miss {
			foreach subj in math ela {
				egen _CLmean_`var'_`subj' = mean(`var') if !mi(cid_`subj'), by(cid_`subj')
			}
			egen _COmean_`var' = mean(`var'), by(grade_level school_code school_year)
		}
		
		foreach subj in math ela {
			egen _CLstd_scaled_score_`subj'_tm1 = mean(std_scaled_score_`subj'_tm1) if !mi(cid_`subj'), by(cid_`subj')
			egen _CLstd_scaled_score_`subj'_tm1_sd = sd(std_scaled_score_`subj'_tm1) if !mi(cid_`subj'), by(cid_`subj')
			egen _COstd_scaled_score_`subj'_tm1 = mean(std_scaled_score_`subj'_tm1), by(grade_level school_code school_year)
			egen _COstd_scaled_score_`subj'_tm1_sd = sd(std_scaled_score_`subj'_tm1), by(grade_level school_code school_year)
		}
		
	// 2.11 Generate class and cohort size variables.
		
		foreach subj in math ela {
			egen _CLnumber_students_`subj' = nvals(sid) if !mi(cid_`subj'), by(cid_`subj')
		}
		
		egen _COnumber_students = nvals(sid), by(grade_level school_code school_year)
		
	// 2.12 Generate variables that capture the proportion of students with a missing prior test score for both class and cohort.
		
		foreach subj in math ela {
		
			egen temp_`subj' = nvals(sid) if mi(std_scaled_score_`subj'_tm1) & !mi(cid_`subj'), by(cid_`subj')
			egen max_temp_`subj' = max(temp_`subj'), by(cid_`subj')
			bysort cid_`subj': gen _CLpct_missing_std_`subj'_tm1 = max_temp_`subj'/_N
			drop max_temp_`subj' temp_`subj'
			
			egen temp_`subj' = nvals(sid) if mi(std_scaled_score_`subj'_tm1), by(grade_level school_code school_year)
			egen max_temp_`subj' = max(temp_`subj'), by(grade_level school_code school_year)
			bysort grade_level school_code school_year: gen _COpct_missing_std_`subj'_tm1 = max_temp_`subj'/_N
			drop max_temp_`subj' temp_`subj'
		}
		
	// 2.13 Create school poverty measures at the year-school level using student FRPL indicators.
		preserve
		
			keep school_code school_year s_frpl
			drop if mi(school_code) | mi(school_year) | mi(s_frpl)
			collapse (mean) s_frpl, by(school_code school_year)
			isid school_code school_year
			gen school_poverty_quartile = .
			forval year = 2007/2011 {
				xtile temp_poverty_quartile = s_frpl if school_year == `year', nq(4)
				replace school_poverty_quartile = temp_poverty_quartile if school_year == `year'
				drop temp_poverty_quartile
			}
			assert !missing(school_poverty_quartile)
			label define pvt 1 "Lowest percentage of FRPL-eligible students"
			label define pvt 2 "Second-lowest percentage of FRPL-eligible students" , add
			label define pvt 3 "Second-highest percentage of FRPL-eligible students" , add
			label define pvt 4 "Highest percentage of FRPL-eligible students", add
			label values school_poverty_quartile pvt
			drop s_frpl

			tempfile school_poverty_qrt
			save `school_poverty_qrt'
		
		restore
		merge m:1 school_code school_year using `school_poverty_qrt', keep(1 2 3) nogen

	// 2.14 Create average prior achievement measures at the year-school level using student test scores.
		preserve 
			foreach var of varlist  std_scaled_score_ela std_scaled_score_math { 
				egen school_avg_`var' = mean(`var'), by(school_code school_year) 
			}

			keep school_code school_year school_avg* 
			duplicates drop 
			tsset school_code school_year 
			forvalues year = 2008/2011 { 
				xtile temp_sch_math_qrt_tm1_`year' = L.school_avg_std_scaled_score_math if school_year==`year', nq(4)
				xtile temp_sch_ela_qrt_tm1_`year' = L.school_avg_std_scaled_score_ela if school_year==`year', nq(4)
			}
			
			gen sch_avg_prior_math_qrt = . 
			gen sch_avg_prior_ela_qrt = . 
			foreach subj in math ela { 
				forvalues year = 2008/2011 { 
					replace sch_avg_prior_`subj'_qrt = temp_sch_`subj'_qrt_tm1_`year' if  sch_avg_prior_`subj'_qrt==. 
				} 
			}
			
			drop temp* school_avg_std_scaled_score*		

			label define pmath 1 "Lowest average prior year math scores" 2 "Second-lowest prior year math scores" 3 "Second-highest prior year math scores" ///
			4 "Highest prior year math scores"
			label values sch_avg_prior_math_qrt pmath 
			
			label define pela 1 "Lowest average prior year ELA scores" 2 "Second-lowest prior year ELA scores" 3 "Second-highest prior year ELA scores" ///
			4 "Highest prior year ELA scores"
			label values sch_avg_prior_ela_qrt pela

			label var sch_avg_prior_math_qrt "4 quartiles of school average prior math scores"
			label var sch_avg_prior_ela_qrt "4 quartiles of school average prior ELA scores"
			tempfile sch_achievement
			save `sch_achievement'
		
		restore 
		merge m:1 school_code school_year using `sch_achievement', nogen

	// 2.15 Sort the file, ensure uniqueness, and then save as Connect_Step2.dta.
	
		isid sid school_year
		sort sid school_year
		order sid school_year school_code grade_level cid* tid* scaled* std* qrt* language* s_* _CL* _CO*
		save ${analysis}/Connect_Step2.dta, replace
	
}	

/**************************************************************************************************************
* STEP 3: Generate key variables required for the Teacher_Year_Analysis file
**************************************************************************************************************/
if $step_3_generate == 1 {

	// 3.1 Load the Connect_Step1 file and drop the student-level variables you will not need for the Teacher_Year_Analysis file.
	
		use ${analysis}/Connect_Step1.dta, clear
		
		drop sid math ela grade_level core *scaled* language* s_* _m* ///
			 qrt* school_name elementary middle high alternative school_lvl
			
		drop if mi(tid)
	
	// 3.2 Resolve any potential conflicts in the school_code variable by giving preference to the student data.
	
		bys tid school_year: gen n = _N
		gen temp = 1
		replace temp = 0 if n > 1 & school_code != t_school_code
		
		gen rand = runiform()
		gsort tid school_year -temp rand
		bys tid school_year: keep if _n == 1
		
		replace school_code = t_school_code if school_code == .
		drop t_school_code n temp rand
		
	// 3.3 Merge on the school-level variables from the school file using the now-singular school code.
	
		merge m:1 school_code using ${clean}/School_Clean.dta, keep(1 3) nogen
		
	// 3.4 Create dummy variables for race/ethnicity, which will be used as controls or outcomes in Analyze.

		gen t_black = (t_race_ethnicity == 1)
		gen t_asian = (t_race_ethnicity == 2)
		gen t_latino = (t_race_ethnicity == 3)
		gen t_naam = (t_race_ethnicity == 4)
		gen t_white = (t_race_ethnicity == 5)
		gen t_mult = (t_race_ethnicity == 6)
		gen t_racemiss = (t_race_ethnicity == 7) | (t_race_ethnicity == .)
		
	// 3.5 Create an indicator for a teacher possessing either a Master’s or Doctorate degree.
	
		gen t_adv_degree = (t_degree == 2 | t_degree == 3)
		replace t_adv_degree = . if t_degree == .
		
	// 3.6 Create a new hire dummy variable.
	
		summ school_year
		local min_school_year = r(min)
		local max_school_year = r(max)
		egen x = min(school_year) if t_is_teacher == 1, by(tid)
		egen first_observed_teacher = max(x), by(tid)
		drop x
		gen t_newhire = 0 if t_is_teacher == 1
		replace t_newhire = 1 if school_year == first_observed_teacher & t_is_teacher == 1
		replace t_newhire = . if school_year == `min_school_year'
		drop first_observed_teacher

	// 3.7 Create t_novice, t_novice_ever and veteran new hire dummy variables.	
	
		gen t_novice = .
		replace t_novice = 1 if t_experience == 1 /*& t_newhire == 1*/
		replace t_novice = 0 if t_novice != 1 & t_is_teacher == 1 & !missing(t_experience)
		
		gen t_veteran_newhire = 0 if t_is_teacher == 1 & !missing(t_experience)
		replace t_veteran_newhire = 1 if t_newhire == 1 & t_novice == 0 & !missing(t_experience)
		
		egen t_novice_ever = max(t_novice), by(tid)
		egen t_novice_ever_check = sum(t_novice), by(tid)
		assert t_novice_ever_check < 2 if t_is_teacher==1
		drop t_novice_ever_check
		
	// 3.8 Create the retention dummy variables.
		
		// Set the time series
		tsset tid school_year
		
		// Define next-year status variables
		foreach var of varlist school_code t_is_teacher {
			gen `var'_tp1 = F.`var'
		}
		assert !missing(school_code) if school_year < `max_school_year'
		gen t_stay = school_code == school_code_tp1 & t_is_teacher_tp1 == 1 ///
			if t_is_teacher == 1 & school_year < `max_school_year'
		gen t_transfer = school_code != school_code_tp1 & t_is_teacher_tp1 == 1 ///
			if t_is_teacher == 1 & school_year < `max_school_year'
		gen t_leave = t_is_teacher_tp1 != 1 ///
			if t_is_teacher == 1 & school_year < `max_school_year'
		assert t_stay + t_transfer + t_leave == 1 if t_is_teacher == 1 & school_year < `max_school_year'
		
	// 3.9 Merge on the school-level poverty and average prior achievement variables created in Connect Step 2. 
		
		preserve 
		use ${analysis}/Connect_Step2.dta, clear
		keep school_code school_year school_poverty_quartile sch_avg_prior* 
		duplicates drop 
		isid school_code school_year 
		tempfile school_vars 
		save `school_vars' 
		restore 
		
		merge m:1 school_code school_year using `school_vars', keep(1 3) nogen
	
	// 3.10 Sort the file, ensure uniqueness, save a tempfile, and then save as Teacher_Year_Analysis.dta.
	
		sort tid school_year
		isid tid school_year
		
		order tid school_year school_code school_name-school_lvl school_poverty_quartile sch_avg_prior* ///
			t_black-t_racemiss t_is_teacher t_job_code t_hire_date t_termination_date t_experience t_degree t_adv_degree ///
			t_certification_pathway-t_certification_sped t_newhire-t_leave cid
		
		tempfile for_stu
		save `for_stu'
		
		drop cid
		save ${analysis}/Teacher_Year_Analysis.dta, replace
}		
/**************************************************************************************************************
* STEP 4: Merge on teacher value added estimates and save the Student_Teacher_Year_Analysis and Teacher_Year_Analysis files
**************************************************************************************************************/
if $step_4_understand==1 { 
		
	// 4.1 Understand one possible measure of teacher effectiveness, value-added estimates.

	// 4.2 Load the Teacher_Year_Analysis file, merge on your chosen measure of teacher effectiveness, 
	// and save the final Teacher_Year_Analysis file. 
	
		use ${analysis}/Teacher_Year_Analysis.dta, clear
	
		merge 1:1 tid school_year using ${analysis}/Connect_TEM.dta, keep(1 3) nogen 
	
		save ${analysis}/Teacher_Year_Analysis.dta, replace 
				
	// 4.3 Structure the student analysis file so that each student has two observations for each year – 
	// one that contains information relevant to math, and the other to ELA.dta.
	
		foreach subj in math ela{
			if "`subj'" == "math"{
				local alt_subj = "ela"
			}
			if "`subj'" == "ela"{
				local alt_subj = "math"
			}
			
			use ${analysis}/Connect_Step2.dta, clear
			drop *`alt_subj'*
			rename tid_`subj' tid
			
			merge m:1 tid school_year using ${analysis}/Connect_TEM.dta, keep(1 3) nogen 
			
			merge m:1 tid school_year using `for_stu', keep(1 3) nogen
			rename tid tid_`subj'
			
			tempfile stu_tch_yr_`subj'
			save `stu_tch_yr_`subj''
		}
		
		use `stu_tch_yr_math', clear
		merge 1:1 sid school_year using `stu_tch_yr_ela', nogen
		
	// 4.4 Sort the file, ensure uniqueness, and then save as Student_Teacher_Year_Analysis.dta.
	
		sort sid school_year
		isid sid school_year
		
		order sid school_year grade_level cid* school_code school_name-school_lvl tid*  ///
			t_race_ethnicity t_black-t_racemiss t_is_teacher t_job_code t_hire_date t_termination_date ///
			t_experience t_degree t_adv_degree t_certification_pathway-t_certification_sped t_newhire-t_leave s_* ///
			scaled_score* std_scaled_score* qrt* language* _CL* _CO*
		
		drop cid
		save ${analysis}/Student_Teacher_Year_Analysis.dta, replace	

}
log close
