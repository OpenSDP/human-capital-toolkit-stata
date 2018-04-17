/*****************************************************************************************
* SDP Version 1.0
* Last Updated: April 3, 2014
* File Name: Analyze_D_Development.do
* Author(s): Strategic Data Project
* 
* Description: This program analyzes teacher effectiveness measures by:
* 1. Showing the overall distribution of a teacher effectiveness measure.
* 2. Examining whether two years of teacher effectiveness measures are predictive
*    of average teacher effectiveness in a third year.
* 3. Examining the distribution of teacher effectiveness in a third year for teachers
*    ranked most and least effective in the prior two years.
*
* Inputs:  Teacher_Year_Analysis.dta
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
	
	log using "${log}\Analyze_Evaluation.txt", text replace

	// Set program switches for recruitment analyses. Set switch to 0 to skip the 
	// section of code that runs a given analysis, and to 1 to run the analysis.

	// Switches
	
	global overall_teacher_effects 					= 1
	global predictive_teacher_effects_avg			= 1
	global predictive_teacher_effects_dist			= 1

/*** D1. Distribution of Teacher Effects ***/

if ${overall_teacher_effects} == 1 {

	// Step 1: Choose the subject (math or ela) and school level (elem or 
	// middle) for the analysis. Note: to make multiple charts at the same time, 
	// put loops for subject and level around the analysis and graphing code.
	// To include all grade levels in the analysis, comment out the local level 
	// command below.
	
	local subject math
	*local level middle
	
	// Step 2: Load the Teacher_Year_Analysis file containing value-added estimates.
	
	use "${analysis}/Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 3: Restrict the sample. Keep years for which teacher effects value added 
	// estimates are available. Keep only employees who are teachers. Keep only records 
	// for which teachers have pooled teacher effects estimates (pooled estimates use 
	// information from all available years for each teacher). If school level restriction 
	// is chosen, keep only records from either elementary or middle schools.
	

	// Step 4: Review variables.
	
	
	// Step 5: Change data from teacher-year uniqueness level to teacher level by keeping
	// only teacher id and pooled estimate and then dropping duplicate records.
	
	
	// Step 6: Get sample size.
	
	
	// Step 7: Get and store values for percentiles and percentile differences.
	

	// Step 8: Set positions for text labels, lines, and arrows.
	
	
	// Step 9: Define subject and school level titles.
	

	// Step 10: Make chart.
	
	#delimit ;
	twoway (pcarrowi `lnht75' `p25_`subject'' `lnht75' `p75_`subject'',
			color(cranberry) mlwidth(medthin) lwidth(medthin))
		(pcarrowi `lnht75' `p75_`subject'' `lnht75' `p25_`subject'',
			color(cranberry) mlwidth(medthin) lwidth(medthin))
		(pcarrowi `lnht90' `p10_`subject'' `lnht90' `p90_`subject'',
			color(green) mlwidth(medthin) lwidth(medthin))
		(pcarrowi `lnht90' `p90_`subject'' `lnht90' `p10_`subject'',
			color(green) mlwidth(medthin) lwidth(medthin))
		(kdensity tre_`subject', color(navy) area(1) 
			xline(`p25_`subject'', lpattern(dash) lcolor(cranberry))
			xline(`p75_`subject'', lpattern(dash) lcolor(cranberry))
			xline(`p10_`subject'', lpattern(dash) lcolor(green))
			xline(`p90_`subject'', lpattern(dash) lcolor(green))),
			
		title("Distribution of `subj_title' Teacher Effects" " ", span)
		xtitle("Teacher Effects", size(medsmall))
		xscale(range(-.5(.25).5))
		xlabel(-.5(.25).5, labsize(medsmall))
		yscale(range(0(1)6))
		ylabel(none)
		text(5 `gphtxt_10' "10th percentile", orientation(vertical) size(small))
		text(5 `gphtxt_25' "25th percentile", orientation(vertical) size(small))
		text(5 `gphtxt_75' "75th percentile", orientation(vertical) size(small))
		text(5 `gphtxt_90' "90th percentile", orientation(vertical) size(small))
		text(`txtht75' 0 "`gap75'", size(medium) color(cranberry))
		text(`txtht90' 0 "`gap90'", size(medium) color(green))
		legend(off)
		graphregion(color(white) fcolor(white) lcolor(white))
		plotregion(color(white) fcolor(white) lcolor(white) margin(5 5 2 0))
		
		note(" " "Notes: Sample includes `unique_teachers' `gradespan' grade `subj_foot'
teachers in school years 2007-08 through 2010-11." "Teacher effects are measured in
student test score standard deviations, with teacher-specific shrinkage factors applied
to adjust for" "differences in sample reliability.", size(vsmall) span);
	#delimit cr	
	
	// Step 11: Save chart.
	
	graph save "${graphs}\D1_Overall_Teacher_Effects_`subj_title'.gph" , replace
	graph export "${graphs}\D1_Overall_Teacher_Effects_`subj_title'.emf" , replace
		
}

/*** 2. Average Teacher Effects in Third Year by Quartile Rank During Previous Two Years ***/

if ${predictive_teacher_effects_avg} == 1 {

	// Step 1: Choose the subject (math or ela) and school level (elem or 
	// middle) for the analysis. Note: to make multiple charts at the same time, 
	// put loops for subject and level around the analysis and graphing code.
	// To include all grade levels in the analysis, comment out the local level 
	// command below.
	
	local subject math
	*local level middle
	
	// Step 2: Load the Teacher_Year_Analysis file containing value-added estimates.
	
	use "${analysis}/Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 3: Restrict the sample. Keep years for which teacher effects value added 
	// estimates are available. Keep only records for which single-year teacher
	// effectiveness estimates are available. Keep only employees who are teachers. 
	// If school level restriction is chosen, keep only records from either elementary
	// or middle schools.
	

	// Step 4: Review variables.
	
	
	// Step 5: Identify the most recent year a teacher is present in the data and tag 
	// as "year 3."
	
	
	// Step 6: Set time series structure and use lead operators to identify years 2 
	// and 1. 
	
	
	// Step 7: Keep a balanced panel which includes only teachers with observations 
	// for all 3 years.
	

	// Step 8: Assign teachers to quartiles based on two-year pooled 
	// teacher effects in year 2, and generate dummy variables for
	// quartiles.
	
	
	// Step 9: Drop records for years 1 and 2, reducing data to one record per teacher.
	
	
	// Step 10: Get sample size.
	

	// Step 11: Get significance.
	
	
	// Step 12: Collapse the data for graphing.
	
			
	// Step 13: Concatenate value labels and significance asterisks.
	
	
	// Step 14: Define subject and school level titles.
	

	// Step 15: Make chart.
	
	#delimit ;
	twoway (bar current_tre_`subj' quart if quart == 4, 
			horizontal fcolor(dkorange) lcolor(dkorange) lwidth(0))
		(bar current_tre_`subj' quart if quart == 3, 
			horizontal fcolor(forest_green) lcolor(forest_green) lwidth(0))
		(bar current_tre_`subj' quart if quart == 2, 
			horizontal fcolor(maroon) lcolor(maroon) lwidth(0))
		(bar current_tre_`subj' quart if quart == 1, 
			horizontal fcolor(dknavy) lcolor(dknavy) lwidth(0))
		(scatter quart current_tre_`subj' if current_tre_`subj' >= 0,
			mlabel(tre_label) msymbol(i) mlabpos(3) mlabcolor(black) mlabgap(.2))
		(scatter quart current_tre_`subj' if current_tre_`subj' < 0,
			mlabel(tre_label) msymbol(i) mlabpos(9) mlabcolor(black) mlabgap(.2)),
		title("`subj_title' Teacher Effects in Third Year", span)
		subtitle("by Quartile Rank During Previous Two Years", span)
		xtitle("Current Average Teacher Effect", size(medsmall))
			xscale(range(-0.15 (.05) 0.15))
			xlabel(-0.15 (.05) 0.15, format(%9.2f) labsize(medsmall)) 
		ytitle("Previous Teacher Effects Quartile", size(medsmall))
			yscale(range(1(1)4))
			ylabel(1 `""Least" "Effective""' 2 "2nd" 3 "3rd" 4 `""Most" "Effective""', 
			labsize(medsmall) nogrid)
		legend(off)
		graphregion(color(white) fcolor(white) lcolor(white))
		plotregion(color(white) fcolor(white) lcolor(white) margin(5 5 2 2))
		
		note(" " "*Significantly different from zero, at the 95 percent confidence level." 
"Notes: Sample includes `unique_teachers' `gradespan' grade `subj_foot' teachers
with three years of teacher effects estimates in school" "years 2007-08 through 2010-11.
Teacher effects are measured in student test score standard deviations, with
teacher-specific" "shrinkage factors applied to adjust for differences in sample
reliability.", 
		span size(vsmall));
	#delimit cr
			 
	// Step 16: Save chart.
	
	graph save "${graphs}\D2_Predictive_Tchr_Effects_Avg_`subj_title'.gph" , replace
	graph export "${graphs}\D2_Predictive_Tchr_Effects_Avg_`subj_title'.emf" , replace
	
} 

/*** 2. Distribution of Teacher Effects in Third Year by Quartile Rank During Previous Two Years ***/

if ${predictive_teacher_effects_dist} == 1 {

	// Step 1: Choose the subject (math or ela) and school level (elem or 
	// middle) for the analysis. Note: to make multiple charts at the same time, 
	// put loops for subject and level around the analysis and graphing code.
	// To include all grade levels in the analysis, comment out the local level 
	// command below.
	
	local subject math
	*local level middle
	
	// Step 2: Load the Teacher_Year_Analysis file containing value-added estimates.
	
	use "${analysis}/Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 3: Restrict the sample. Keep years for which teacher effects value added 
	// estimates are available. Keep only records for which single-year teacher
	// effectiveness estimates are available. Keep only employees who are teachers. 
	// If school level restriction is chosen, keep only records from either elementary
	// or middle schools.
	

	// Step 4: Review variables.
	
	
	// Step 5: Identify the most recent year a teacher is present in the data and tag 
	// as "year 3."
	
	
	// Step 6: Set time series structure and use lead operators to identify years 2 
	// and 1. 
	
	
	// Step 7: Keep a balanced panel which includes only teachers with observations 
	// for all 3 years.
	

	// Step 8: Assign teachers to quartiles based on two-year pooled teacher effects
	// in year 2, and generate dummy variables for quartiles.
	
	
	// Step 9: Drop records for years 1 and 2, reducing data to one record per teacher.
	
	
	// Step 10: Get sample size.
	
	
	// Step 11: Get quartile means and the difference between means for quartiles 
	// 1 and 4.
	
	
	// Step 12: Set positions for lines and text on chart.
	
	
	// Step 13: Define subject and school level titles.
	

	// Step 14: Make chart.
	
	#delimit ;
	
	twoway (pcarrowi `lnht' `mean_q4' `lnht' `mean_q1',
			color(cranberry) mlwidth(medthin) lwidth(medthin))
		(pcarrowi `lnht' `mean_q1' `lnht' `mean_q4',
			color(cranberry) mlwidth(medthin) lwidth(medthin))
		(kdensity current_tre_`subject' if quart == 1, 
			lcolor(navy) area(1) 
			xline(`mean_q1', lpattern(dash) lcolor(navy))) 	
		(kdensity current_tre_`subject' if quart == 4, 
			lcolor(orange) area(1) lwidth(medium)
			xline(`mean_q4', lpattern(dash) lcolor(orange))),
		text(`txtht' `diff_pl' "`diff'", placement(0))
		title("Distribution of `subj_title' Teacher Effects in Third Year", span)
		subtitle("by Quartile Rank During Previous Two Years", span)
		xtitle("Teacher Effects", size(medsmall))
			xscale(range(-.25(.05).25))
			xlabel(-.25(.05).25, labsize(medsmall))
		ytitle("",) 
			yscale(range(0(2)12)) 
			ylabel(none)
		legend(order(3 4) rows(1) label(3 "Bottom Quartile") 
			label(4 "Top Quartile"))
		legend(symxsize(5) ring(1) size(medsmall)
			region(lstyle(none) lcolor(none) color(none))) 
		graphregion(color(white) fcolor(white) lcolor(white))
		plotregion(color(white) fcolor(white) lcolor(white) margin(5 5 2 0))
		
		note(" " "Notes: Sample includes `unique_teachers' `gradespan' grade `subj_foot'
teachers with three years of teacher effects estimates in school" "years 2007-08 through
2010-11. Teacher effects are measured in student test score standard deviations, with
teacher-specific" "shrinkage factors applied to adjust for differences in sample
reliability.", span size(vsmall));

	#delimit cr

	// Step 15: Save chart.
	
	graph save "${graphs}\D3_Predictive_Tchr_Effects_Dist_`subj_title'.gph" , replace
	graph export "${graphs}\D3_Predictive_Tchr_Effects_Dist_`subj_title'.emf" , replace
	
} 

log close
