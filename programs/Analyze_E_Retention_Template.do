/*****************************************************************************************
* SDP Version 1.0
* Last Updated: April 3, 2014
* File name: Analyze_E_Retention.do
* Author(s): Strategic Data Project
*  
* Description: This program produces analyses that show teacher retention patterns by:
* 1. Describing the overall annual shares of teachers who stay in the same school, 
*    transfer, and leave teaching in the agency.
* 2. Describing the shares of teachers who transfer and leave over time.
* 3. Examining the extent to which retention patterns differ according to school 
*    poverty characteristics.
* 4. Examining whether the most and least effective teachers are being differentially
*    retained.
* 5. Describing the retention trajectory of a cohort of novice teachers.
*
* Inputs: Teacher_Year_Analysis.dta
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

	// Open log file
	
	log using "${log}\Analyze_Retention.txt", text replace

	// Set program switches for development analyses. Set switch to 0 to skip the 
	// section of code that runs a given analysis, and to 1 to run the analysis.

	global retention_pie 					= 1
	global retention_year 					= 1
	global retention_school_poverty 		= 1
	global retention_teacher_effectiveness 	= 1
	global retention_trajectory_novices 	= 1

/*** E1. Average Annual Teacher Retention ***/ 

if $retention_pie == 1 { 

	// Step 1: Load data.
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 2: Restrict sample. Keep only teachers in years for which next-year
	// retention status can be calculated. 
	
	
	// Step 3: Review variables.
	

	// Step 4: Get sample size.
	
	
	// Step 5: Collapse data and calculate shares.
	
	
	// Step 6: Make chart.
	
	#delimit ;
	graph pie t_stay t_transfer t_leave, 
		angle0
			(330) 
		title
			("Average Teacher Retention", span) 
		pie
			(1, color(navy)) 
		pie
			(2, color(forest_green)) 
		pie
			(3, color(maroon)) 		
		pie 
			(4, color(dkorange))
		
		plabel
			(1 percent, gap(5) format("%2.0f") color(white) size(medsmall) placement(3)) 
		plabel
			(2 percent, gap(5) format("%2.0f") color(white) size(medsmall) placement(0)) 
		plabel
			(3 percent, gap(5) format("%2.0f") color(white) size(medsmall) placement(3)) 
		plabel
			(4 percent, gap(5) format("%2.0f") color(white) size(medsmall) placement(3)) 
		plabel
			(1 "Stay", 
				color(black) size(medsmall) placement(9) gap(20))  
		plabel
			(2 "Transfer Schools", 
				color(black) size(medsmall) placement(9) gap(20))  
		plabel
			(3 "Leave",
				color(black) size(medsmall) placement(4) gap(20)) 
		legend
			(off) 
		graphregion(color(white) fcolor(white) lcolor(white)) plotregion(color(white) 
			fcolor(white) lcolor(white))
			
		note(" " "Notes: Sample includes `teacher_years' teacher years and
`unique_teachers' unique teachers in the 2006-07 to 2009-10 school years. Retention
analyses are based" "on one-year retention rates.", span size(vsmall)) ; 
	#delimit cr
	
	// Step 7: Save chart.
	
	graph save "$graphs\E1_Average_Teacher_Retention.gph", replace
	graph export "$graphs\E1_Average_Teacher_Retention.emf", replace
		
} 
	
/*** E2. Teacher Retention by School Year ***/ 

if $retention_year == 1 {	
	
	// Step 1: Load data.
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 2: Restrict sample. Keep only teachers in years for which next-year
	// retention status can be calculated. 
	
	
	// Step 3: Review variables.
	

	// Step 4: Get sample size.
	
	
	// Step 5: Calculate significance indicator variables by year.
	
			
	// Step 6: Collapse and calculate shares.
	
			
	// Step 7: Concatenate value and significance asterisk.
	
	
	// Step 8: Generate count variable and add variables cumulatively for graphing
	
	
	// Step 9: Make chart.
	
	#delimit ;
	
	twoway bar t_transfer count,
		barwidth(.6) color(forest_green) finten(100) ||
		
		bar t_leave count,
		barwidth(.6) color(maroon) finten(100) ||
		
		scatter t_transfer count,
			mlabel(t_transfer_label) 
			msymbol(i) msize(tiny) mlabpos(6) mlabcolor(white) 
			mlabgap(.001) ||

		scatter t_leave count,
			mlabel(t_leave_label) 
			msymbol(i) msize(tiny) mlabpos(6) mlabcolor(white) 
			mlabgap(.001) ||,
			
		title("Average Teacher Turnover", span)
		subtitle("by School Year", span)  
		ytitle("Percent of Teachers", size(medsmall)) 
		yscale(range(0(10)60)) 
		ylabel(0(10)60, nogrid labsize(medsmall)) 
		xtitle("")
		xlabel(1 "2006-07" 2 "2007-08" 3 "2008-09" 4 "2009-10", labsize(medsmall))
		legend(order(1 "Transfer Schools" 2 "Leave")
			ring(0) position(11) symxsize(2) symysize(2) rows(2) size(medsmall) 
			region(lstyle(none) lcolor(none) color(none))) 
		
		graphregion(color(white) fcolor(white) lcolor(white)) plotregion(color(white) 
			fcolor(white) lcolor(white))
		
		note("*Significantly different from 2006-07 value, at the 95 percent confidence
level." "Notes: Sample includes `teacher_years' teacher years and
`unique_teachers' unique teachers. Retention analyses are based on one-year retention
rates.", span size(vsmall)); 

	#delimit cr
	
	// Step 10: Save chart.
	
	graph save "$graphs\E2_Retention_by_School_Year.gph", replace 
	graph export "$graphs\E2_Retention_by_School_Year.emf", replace 
					
} 


/*** E3. Teacher Retention by School Poverty Quartile ***/ 

if $retention_school_poverty == 1 {

	// Step 1: Load data.
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 2: Restrict sample. Keep only teachers in years for which next-year
	// retention status can be calculated. Keep records with non-missing values
	// for school poverty quartile.
	
	
	// Step 3: Review variables.
	
	
	// Step 4: Get sample sizes.
	
						
	// Step 5: Calculate significance indicator variables by quartile.
	
			
	// Step 6: Collapse and calculate shares.
	
			
	// Step 7: Concatenate value and significance asterisk.
	
	
	// Step 8: Generate count variable and add variables cumulatively for graphing.
	
	
	// Step 9: Make chart.
	
	#delimit ;
	
	twoway bar t_transfer count,
		barwidth(.6) color(forest_green) finten(100) ||
		
		bar t_leave count,
		barwidth(.6) color(maroon) finten(100) ||
		
		scatter t_transfer count,
			mlabel(t_transfer_label) 
			msymbol(i) msize(tiny) mlabpos(6) mlabcolor(white) mlabgap(.001) ||
			
		scatter t_leave count,
			mlabel(t_leave_label) 
			msymbol(i) msize(tiny) mlabpos(6) mlabcolor(white) mlabgap(.001) ||,
			
		title("Average Teacher Turnover", span)
		subtitle("by School FRPL Quartile", span) 
		ytitle("Percent of Teachers", size(medsmall)) 
		yscale(range(0(10)60)) 
		ylabel(0(10)60, nogrid labsize(medsmall)) 
		xtitle("") 
		xlabel(1 "Lowest Poverty" 2 "2nd Quartile" 3 "3rd Quartile" 4 "Highest Poverty", 
			labsize(medsmall)) 
		
		legend(order(1 "Transfer Schools" 2 "Leave")
			ring(0) position(11) symxsize(2) symysize(2) rows(2) size(medsmall) 
			region(lstyle(none) lcolor(none) color(none)))
			
		graphregion(color(white) fcolor(white) lcolor(white)) plotregion(color(white) 
			fcolor(white) lcolor(white))
		
		note("*Significantly different from schools in the lowest free and reduced 
price lunch quartile, at the 95 percent confidence level." "Notes: Sample includes
`teacher_years' teacher years and `unique_teachers' unique teachers in the 2006-07
to 2009-10 school years. Retention analyses are based" "on one-year retention rates.",
span size(vsmall));

	#delimit cr
	
	// Step 10: Save chart.
	
	graph save "$graphs\E3_Retention_by_Poverty_Quartile.gph", replace
	graph export "$graphs\E3_Retention_by_Poverty_Quartile.emf", replace
	
} 

/*** E4. Retention by Teacher Effectiveness Tercile ***/

if $retention_teacher_effectiveness == 1 {

	// Step 1: Choose the subject (math or ela) and school level (elem or 
	// middle) for the analysis. Note: to make multiple charts at the same time, 
	// put loops for subject and level around the analysis and graphing code.
	// To include all grade levels in the analysis, comment out the local level 
	// command below.
	
	local subject math
	*local level middle
	
	// Step 2: Load the Teacher_Year_Analysis file.
	
	use "${analysis}/Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 3: Restrict the sample. Keep years for which both teacher effects value 
	// added estimates and next-year retention status are available. Keep only 
	// records for which one-year teacher effectiveness estimates are available. 
	// Keep employees who are teachers. If school level restriction is chosen, 
	// keep only records from either elementary or middle schools.
	

	// Step 4: Review variables.
	
	
	// Step 5: Calculate effectiveness tercile using restricted sample.
	
				
	// Step 6: Get sample sizes.
	

	// Step 7: Calculate significance indicator variables by tercile.
	
	
	// Step 8: Collapse and calculate shares.
	
			
	// Step 9: Concatenate value and significance asterisk.
	

	// Step 10: Generate count variable and add variables cumulatively for graphing.
	
	
	// Step 11: Define titles for subject and school level.
	
	
	// Step 12: Make chart.
	
	#delimit ;
	
	twoway bar t_transfer count,
		barwidth(.6) color(forest_green) finten(100) ||
		
		bar t_leave count,
		barwidth(.6) color(maroon) finten(100) ||
		
		scatter t_transfer count,
			mlabel(t_transfer_label) 
			msymbol(i) msize(tiny) mlabpos(6) mlabcolor(white) mlabgap(.001) ||
			
		scatter t_leave count,
			mlabel(t_leave_label) 
			msymbol(i) msize(tiny) mlabpos(6) mlabcolor(white) mlabgap(.001) ||,
			
		title("Average `subj_title' Teacher Turnover", span)
		subtitle("by Teacher Effects Tercile", span)  
		ytitle("Percent of Teachers", size(medsmall)) 
		yscale(range(0(10)60)) 
		ylabel(0(10)60, nogrid labsize(medsmall)) 
		xtitle(" ")
		xlabel(1 "Bottom Third" 2 "Middle Third" 3 "Top Third", labsize(medsmall))
		
		legend(order(1 "Transfer Schools" 2 "Leave")
			ring(0) position(11) symxsize(2) symysize(2) rows(2) size(medsmall) 
			region(lstyle(none) lcolor(none) color(none)))
			
		graphregion(color(white) fcolor(white) lcolor(white)) plotregion(color(white) 
			fcolor(white) lcolor(white))
		
		note(" " "*Significantly different from bottom tercile value, at the 95 percent 
confidence level." "Notes: Sample includes 2007-08 through 2009-10 `gradespan' grade
`subj_foot' teachers, with `teacher_years' teacher years and `unique_teachers' unique"
"teachers. Teacher effects are measured in test score standard deviations, with
teacher-specific shrinkage factors applied to adjust" "for differences in sample
reliability. Retention analysis is based on one-year retention rates.", 
	span size(vsmall));

	#delimit cr
					
	// Step 13: Save chart.
	
	graph save "$graphs\E4_Retention_by_Effectiveness_Tercile_`subj_title'.gph", replace
	graph export "$graphs\E4_Retention_by_Effectiveness_Tercile_`subj_title'.emf", replace
	
}

/*** E5. Novice Teacher Retention Trajectory ***/ 

if $retention_trajectory_novices == 1 { 

	// Load data.
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Restrict sample to years for which next-year retention status can be observed
	// and to teacher records with non-missing novice indicators.

	
	// Review variables.

	
	// Make indicator for membership in 2007 novice cohort.
	
	
	// Restrict sample to 2007 novice cohort, dropping observations of teachers
	// who reappear after leaving for one or more school years.
	
	
	// Get sample size.
	

	// Get initial school.
		
	
	// Define outcome variables.
	
		
	// Collapse to sum variables of interest.
	
	
	// Calculate outcome percentages by year.
	
	
	// Make chart.
	
	sort school_year
	#delimit ;
	twoway
	scatter still_same_school school_year, 
		connect(l) 
		lcolor(navy) 
		lpattern(solid) 
		msymbol(circle) 
		mcolor(navy) 
		msize(medium) 
		mlabel(still_same_school) 
		mlabpos(6) 
		mlabcolor(navy) 
		mlabsize(small) ||
		
		scatter still_teach school_year, 
		connect(l) 
		lcolor(maroon) 
		lpattern(solid) 
		msymbol(square) 
		mcolor(maroon) 
		mlabsize(small) 
		msize(medium) 
		mlabel(still_teach) 
		mlabpos(12) 
		mlabcolor(maroon) ||,
		
		title("Novice Teacher Trajectory", span)
		ytitle("Percent of Teachers", size(medsmall)) 
		xtitle("") 
		yscale(range(0(20)100)) 
		ylabel(0(20)100, nogrid format(%9.0f) labsize(medsmall)) 
		xscale(range(2007(1)2011)) 
		xlabel(2007 "2006-07" 2008 "2007-08" 2009 "2008-09" 2010 "2009-10" 2011 "2010-11", 
			labsize(medsmall)) 
		legend(position(8) order(2 1) cols(1) symxsize(3) ring(0) size(medsmall) 
			region(lstyle(none) lcolor(none) color(none))
			label(1 "Still Teaching at Same School") 
			label(2 "Still Teaching"))
		
		graphregion(color(white) fcolor(white) lcolor(white)) plotregion(color(white) 
			fcolor(white) lcolor(white))
			
		note(" " "Notes: Sample includes `unique_teachers' teachers who were in their
first year of teaching in the 2006-07 school year.", span size(vsmall));

	#delimit cr
	
	// Save chart.
	
	graph save "$graphs\E5_Novice_Teacher_Retention_Trajectory.gph", replace
	graph export "$graphs\E5_Novice_Teacher_Retention_Trajectory.emf", replace
	
} 

log close
