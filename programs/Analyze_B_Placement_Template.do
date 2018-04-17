/*****************************************************************************************
* SDP Version 1.0
* Last Updated: April 3, 2014
* File name: Analyze_B_Placement.do
* Author(s): Strategic Data Project
*  
* Description: This program produces analyses that show teacher placement practices by: 
* 1. Reporting the characteristics of teachers in the highest- and lowest-poverty schools.
* 2. Comparing the prior-year test scores of students in early career teachers' classrooms
*    with those of veteran teachers' students.  
*
* Inputs: Teacher_Year_Analysis.dta
*		  Student_Teacher_Year_Analysis.dta 
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

	// Define file locations.
	
	global analysis ".\data\analysis"
	global graphs 	".\tables_figures"
	global log 		".\logs"

	// Open log file.
	
	log using "${log}\Analyze_Placement.txt", text replace

	// Set program switches for placement analyses. Set switch to 0 to skip the 
	// section of code that runs a given analysis, and to 1 to run the analysis.
	
	global teacher_char_by_school_poverty	= 1
	global student_prior_ach_by_tchr_exp	= 0

/*** 1. Teacher Characteristics by School Poverty ***/ 

if ${teacher_char_by_school_poverty} == 1 { 
	
	// Step 1: Load the Teacher_Year_Analysis data file. 
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year

	// Step 2: Restrict the sample.
	
		
	// Step 3: Review variables.
	
	
	// Step 4: Create binary variables for each school poverty quartile.
	
	
	// Step 5: Create a binary variable for alternative certification. 
	

	// Step 6: Get overall sample size.
	

	// Step 7: Define row titles for the table.
	
	
	// Step 8: Open output file.
	
	tempvar tbl
	file open `tbl' using "${graphs}\B1_Teacher_Char_by_School_Poverty.xls", ///
		write text replace
		
	// Step 9: Write overall and column titles.
	
		
	// Step 10: Start a loop through row variables.
	
	foreach rowvar of varlist t_male t_black t_latino t_white t_newhire ///
		t_adv_degree t_alternative_certification t_experience {
		
		// Step 11: Calculate quartile averages and difference.
		
		
		// Step 12: Get significance for difference between top and bottom quartile.
		
		
		// Step 13: Caclulate agency average.
		

		// Step 14: Write values for high, low, difference, and significance for each 
		//row variable.
		
		
	}
	
	// Step 15: Write footnote including sample sizes.
	
	
	// Step 16: Close output file. Do table formatting in Excel.
	
	file close _all 
	
}

/*** 2. Student Prior Achievement by Teacher Experience ***/

if ${student_prior_ach_by_tchr_exp} == 1 { 
	
	// Step 1: Choose the subject (math or ela) and school level (elem or 
	// middle) for the analysis. Note: to make multiple charts at the same time, 
	// put loops for subject and level around the analysis and graphing code.
	// To include all grade levels in the analysis, comment out the local level 
	// command below.
	
	local subject math
	local level middle
	
	// Step 2: Load the Student_Teacher_Year_Analysis data file. 
	
	use "${analysis}\Student_Teacher_Year_Analysis.dta", clear
	isid sid school_year

	// Step 3: Restrict the sample. Keep grades and years for which prior-year test scores
	// are available. Keep students with teachers with non-missing values for experience. 
	// Keep students with a single identified current-year core course and prior-year test 
	// score in the given subject. If school level restriction is chosen, keep only 
	// records from either elementary or middle school grades.
	
	
	// Step 4: Review teacher and student variables.
	
	
	// Step 5: Define dummy variables for teaching experience. Put teachers
	// with six or more years of experience into one category.
	
	
	// Step 6: Define grade-by-year variable for fixed effects.	
	
	
	// Step 7: Define grade-by-year-by-school variable for fixed effects.
	
	
	// Step 8: Define 5 x 4 matrix to store results.
	
	matrix results = J(5, 4, .)
	matrix colnames results = across_school_coef across_school_se ///
		within_school_coef within_school_se

	// Step 9: Do regression of prior student math score on teacher experience. 
	// Sixth plus year teachers are comparison group.
	
	
	// Step 10: Get student and teacher sample sizes.
	
	
	// Step 11: Store coefficients in the first column and and standard errors in 
	// the second column of the results matrix.
	

	// Step 12: Add school fixed effects to prior model to generate within school 
	// comparison.
	
		
	// Step 13: Store coefficients and standard errors in columns 3 and 4 of results 
	// matrix.
	

	// Step 14: Clear data and replace with matrix contents. Add variable for year 
	// teaching.
	
	
	// Step 15: Get and store significance. Concatenate coefficient and asterisk 
	// to use as value label.
	
				
	// Step 16: Define titles for subject and school level.
	
	
	// Step 17: Start loop through models to make and save across and within schools 
	// charts.
	
	foreach model in across within {
				
		// Step 18: Define subtitle.
		
	
		// Step 19: Make chart. Bar chart gives average score difference relative to 6th 
		// plus year teachers, while scatter plot places value and significance asterisk 
		// as marker label below bar. Marker symbol is invisible.
	
		#delimit ;
		
		twoway bar `model'_school_coef year_teaching, 
			barwidth(.6) color(navy) finten(100) ||
			
		scatter `model'_school_coef year_teaching, 
			mlabel(`model'_school_label) 
			msymbol(i) 
			mlabpos(6) 
			mlabcolor(black) ||,
			
			ytitle("Difference in Prior-Year Test Scores", size(medsmall)) 
			title("Difference in Average Prior `subj_title' Performance"
				"of Students Assigned to Early-Career Teachers"
				"Compared to Teachers with Six or More Years of Teaching", span) 
			subtitle("`subtitle'", span) 
			xtitle("Year Teaching", size(medsmall)) 
			xlabel(,labsize(medsmall))
			legend(off) 

			yline(0, lpattern(dash) lcolor(black)) 
			yscale(range(-.4 .2)) 
			ylabel(-.4(.1).2, nogrid labsize(medsmall)) 
			ytick(-.4(.1).2) 
			graphregion(color(white) fcolor(white) lcolor(white))
			plotregion(color(white) fcolor(white) lcolor(white) margin(5 5 2 0))
			
			note(" " "*Significantly different from zero, at the 95 percent confidence 
level." "Notes: Sample includes `gradespan' grade `subj_foot' teachers and students in
the 2007-08 through 2010-11 school years," "with `teacher_years' teacher years, 
`unique_teachers' unique teachers, `student_years' student years, and `unique_students'
unique students. Test scores are measured in standard deviations.", size(vsmall) span);	
	
		#delimit cr
	
		// Step 20: Save chart. If marker labels need to be moved by hand using Stata 
		// Graph Editor, re-save .gph and .emf files after editing.
		
		graph export "${graphs}/B2_Prior_Ach_by_Exp_`subtitle'_`subj_title'.emf", replace 
		graph save "${graphs}/B2_Prior_Ach_by_Exp_`subtitle'_`subj_title'.gph", replace 
		
	}

}

log close
