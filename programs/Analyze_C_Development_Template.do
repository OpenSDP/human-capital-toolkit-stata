/*****************************************************************************************
* SDP Version 1.0
* Last Updated: April 3, 2014
* File Name: Analyze_C_Development.do
* Author(s): Strategic Data Project
*
* Description: This program produces analyses that show the development of the teacher
* workforce by:
* 1. Describing the growth in effectiveness for early-career teachers.
* 2. Examining the difference in effectiveness for teachers with and without advanced 
*    degrees.
*
* Inputs: 	Teacher_Year_Analysis.dta
*			Student_Teacher_Year_Analysis.dta
*
*****************************************************************************************/

	// Close log file if open and set up environment.
	
	capture log close
	clear all
	set mem 1000m
	set more off
	set scheme s1color

	// Edit the file path below to point to the directory with folders for data, logs,
	// programs, and tables and figures. Change to that directory.
	
	cd "K:\working_files"

	// Define file locations
	
	global analysis ".\data\analysis"
	global graphs 	".\tables_figures"
	global log 		".\logs"

	// Open log file
	
	log using "${log}\Analyze_Development.txt", text replace

	// Set program switches for development analyses. Set switch to 0 to skip the 
	// section of code that runs a given analysis, and to 1 to run the analysis.

	// Switches
	global returns_to_experience	= 1
	global return_to_adv_degree		= 0

	
/*** C1. Growth in Teacher Effects for Early Career Teachers ***/

if ${returns_to_experience} == 1 {
		
	// Step 1: Choose the subject (math or ela) and school level (elem or 
	// middle) for the analysis. Note: To change from math to ELA,
	// switch the subjects in the next two lines. To make multiple charts 
	// at the same time, put loops for subject and level around the analysis 
	// and graphing code. To include all grade levels in the analysis, 
	// comment out the local level command below.
	
	local subject math
	local alt_subject ela
	*local level middle
	
	// Step 2. Load the Student_Teacher_Year_Analysis data file.
	
	use "${analysis}\Student_Teacher_Year_Analysis.dta", clear  
	isid sid school_year
	
	// Step 3: Restrict the sample. Keep grades and years for which prior-year test scores
	// are available. Keep students with teachers with non-missing values for experience. 
	// Keep students with a single identified core course and current and prior-year test 
	// scores in the given subject. If school level restriction is chosen, keep only 
	// records from either elementary or middle school grades.
	
	
	// Step 4: Review teacher variables.
	
	
	// Step 5: Create dummy variables for each year of teaching experience, putting all
	// teachers with 10 or more years of experience in one group.
	
		
	// Step 6: Create variable for grade-by-year fixed effects. 
	
	
	// Step 7: Create variables for previous year's score squared and cubed.
	
		
	// Step 8: Create indicator for whether student is missing prior achievement 
	// for alternate subject. Make a replacement variable that imputes score to 
	// zero if missing.
	
		
	// Step 9: Identify prior achievement variables to use as controls.
	
	
	// Step 10: Identify other student variables to use as controls.
	
	
	// Step 11: Review all variables to be included in the teacher effectiveness model.
	// Class and cohort (grade/school/year) variables should include means of all 
	// student variables, and means, standard deviations, and percent missing for 
	// prior-year test scores for both main and alternate subject. Class and 
	// cohort size should also be included as controls.
	
	
	// Step 12: Estimate growth in teacher effectiveness relative to novice teachers,
	// using within-teacher fixed effects.

		 
	// Step 13: Store coefficients and standard errors.
	
	
	// Step 14: Set values to zero for novice comparison teachers.
	
	
	// Step 15: Get teacher sample size.

	
	// Step 16: Collapse and reshape data for graph.
	
	
	// Step 17: Generate confidence intervals of the estimated returns to experience.
	
		
	// Step 18: Define subject and school level titles for graph.
	
	
	// Step 19: Make chart.
	
	#delimit ;
	
	twoway rarea conf_hi conf_low year_teaching if year_teaching <= 10,
		sort
		color(ltblue) ||
		
		scatter coef year_teaching,
			mlab(coef) mlabposition(12) mcolor(dknavy) mlabcolor(dknavy)
			yline(0, lcolor(gs7) lpattern(dash)) 
			yscale(range(-.05(.05).3))
			ylabel(0(.1).4, labsize(medsmall) nogrid)
			ytick(0(.1).4) ||,
		
		graphregion(color(white) fcolor(white) lcolor(white)) 
		plotregion(color(white) fcolor(white) lcolor(white)) 
		
		title("Growth in `subj_title' Teacher Effects", span)
		subtitle("Compared to First Year of Teaching", span)
		ytitle("Difference in Teacher Effects", size(medsmall))
		legend(order(2 1 3) 
		label(2 "Teacher Effect")  
		label(1 "95% Confidence Interval")) 
		legend(cols(2) symxsize(5) ring(1) region(lstyle(none) lcolor(none) color(none))) 
	
		xtitle("Year Teaching") 
		xtick(1(1)10) 
		xscale(range(1(1)10)) 
		xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10+") 
		
		note(" " "Notes: Sample includes `gradespan' grade `subj_foot' teachers
in the 2007-08 through 2011-12 school years, with `teacher_years' teacher years and" 
"`unique_teachers' unique teachers. Teacher effects are average within-teacher
year-to-year changes, measured in student test score standard deviations.", size(vsmall) 
span);
	#delimit cr

	// Step 20: Save chart. If marker labels need to be moved by hand using Stata 
	// Graph Editor, re-save .gph and .emf files after editing.
	
	graph export "${graphs}/C1_Returns_to_Teaching_Experience_`subj_title'.emf", replace 
	graph save "${graphs}/C1_Returns_to_Teaching_Experience_`subj_title'.gph", replace 
	
}
/*** C2. Difference in Teacher Effects for Teachers with and without Advanced Degrees  ***/

if ${return_to_adv_degree} == 1 {
		
	// Step 1: Choose a subject for the analysis. Note: To change from math to ELA,
	// switch the subjects in the next two lines. To generate ELA and math charts
	// at the same time, enclose the analysis code within a loop.
	
	local subject math
	local alt_subject ela
	
	// Step 2. Load the Student_Teacher_Year_Analysis data file.
	
	use "${analysis}\Student_Teacher_Year_Analysis.dta", clear  
	isid sid school_year
	
	// Step 3: Restrict the sample. Keep grades and years for which prior-year test scores
	// are available. Keep students with teachers with non-missing values for experience 
	// and degree information. Keep students with a single identified core course 
	// and current and prior-year test scores in the given subject.
	
	
	// Step 4: Review teacher variables.
	
	
	// Step 5: Create dummy variables for each year of teaching experience.
	
		
	// Step 6: Create variable for grade-by-year fixed effects. 
	
	
	// Step 7: Create variables for previous year's score squared and cubed.
	
		
	// Step 8: Create indicator for whether student is missing prior achievement 
	// for alternate subject. Make a replacement variable that imputes score to 
	// zero if missing.
	
		
	// Step 9: Identify prior achievement variables to use as controls.
	
	
	// Step 10: Identify other student variables to use as controls.
	
	
	// Step 11: Review all variables to be included in the teacher effectiveness models.
	// Class and cohort (grade/school/year) variables should include means of all 
	// student variables, and means, standard deviations, and percent missing for 
	// prior-year test scores for both main and alternate subject. Class and 
	// cohort size should also be included as controls.
	
	
	// Step 12: Estimate differences in teacher effectiveness between teachers
	// with and without advanced degrees, without teacher experience controls.
	
		
	// Step 13: Store coefficient and standard error.
	
			
	// Step 14: Get teacher sample size for this model.
	

	// Step 15: Estimate differences in teacher effectiveness between teachers
	// with and without advanced degrees, with teacher experience controls.
	
	
	// Step 16: Store coefficient and standard error.
	
			
	// Step 17: Get teacher sample size for this model and compare sample size
	// for the two models.
	
	
	// Step 18: Store teacher sample size for footnote.
	
	
	// Step 19: Collapse dataset for graphing.
	
		
	// Step 20: Get significance.
	
			
	// Step 21: Reshape for graphing.
	
	
	// Step 22: Make value labels with significance indicator.
	
		
	// Step 23: Define subject titles for graph.
	

	// Step 24: Create a bar graph of the estimation results.
	
	#delimit ;
	graph twoway (bar coef spec,
			fcolor(dknavy) lcolor(dknavy) lwidth(0) barwidth(0.7))
		(scatter coef spec,
			mcolor(none) mlabel(coef_label) mlabcolor(black) mlabpos(12)  
			mlabsize(small)),
		yline(0, style(extended) lpattern(dash) lwidth(medthin) lcolor(black))
		title("Effectiveness of `subj_title' Teachers with Advanced Degrees", 
		span) 
		subtitle("Relative to Teachers without Advanced Degrees", span) 
		ytitle("Difference in Teacher Effects", size(medsmall)) 
		yscale(range(-.05 .2)) 
		ytick(-.05(.05).2) 
		ylabel(-.05(.05).2, nogrid) 
		xlabel("", notick)
		xtitle("") 
		xlabel(1 `""Without Teacher" "Experience Controls""' 
			2 `""With Teacher" "Experience Controls""', labsize(medsmall)) 
		legend(off) 
		graphregion(color(white) fcolor(white) lcolor(white))
		plotregion(color(white) fcolor(white) lcolor(white) margin(5 5 2 0))
		note(" " "*Significantly different from zero, at the 95 percent confidence 
level." "Notes: Sample includes 2007-08 through 2010-11 5th through 8th grade `subj_foot'
teachers, with `teacher_years' teacher years and `unique_teachers' unique teachers." 
"Teacher effects are measured in student test score standard deviations. Advanced degrees
are master's or higher.", size(vsmall) span);	
	#delimit cr
	
	// Step 25: Save chart. If marker labels need to be moved by hand using Stata 
	// Graph Editor, re-save .gph and .emf files after editing.
	
	graph export "${graphs}/C2_Teacher_Effects_Advanced_Degree_`subj_title'.emf", replace 
	graph save "${graphs}/C2_Teacher_Effects_Advanced_Degree_`subj_title'.gph", replace 
			
}

log close
