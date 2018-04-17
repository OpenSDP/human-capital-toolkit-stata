/*****************************************************************************************
* SDP Version 1.0
* Last Updated: April 3, 2014
* File name: Analyze_A_Recruitment.do
* Author(s): Strategic Data Project
*
* Description: This program produces analyses that show recruiting practices 
* and the distribution of new hires by: 
* 1. Describing the overall share of novice and experienced new hires.
* 2. Describing the share of novice and experienced new hires by year.
* 3. Examining the extent to which new hires are distributed unevenly across
*    the agency according to school poverty characteristics. 
* 4. Estimating the difference in teacher effectiveness between teachers 
*    with traditional and alternative certifications.
* 5. Comparing the shares of all teachers, newly hired teachers, and students
*    by race.
*
* Inputs: 	Teacher_Year_Analysis.dta
*			Student_Teacher_Year_Analysis.dta
*
*****************************************************************************************/

	// Close log file if open and set up environment
	
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
	
	log using "${log}\Analyze_Recruitment.txt", text replace

	// Set program switches for recruitment analyses. Set switch to 0 to skip the 
	// section of code that runs a given analysis, and to 1 to run the analysis.
	
	global new_hires_pie	 			= 1
	global new_hires_year				= 1
	global new_hires_school_poverty 	= 1
	global teacher_effects_cert_pathway	= 1
	global share_teachers_stu_race		= 1

/*** A1. Share of Teachers Who Are New Hires ***/ 

if ${new_hires_pie}==1 { 

	// Step 1: Load the Teacher_Year_Analysis data file.
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 2: Restrict the analysis sample. Keep only employees who are teachers. Drop
	// the first year of data, since new hires are not defined for that year. Drop 
	// records with missing values for variables important to the analysis.
	
	
	// Step 3: Review the values of variables to be used in the analysis.
	
	
	// Step 4: Define a new variable which includes both novice and experienced 
	// new hires.
	
	
	// Step 5: Calculate and store sample sizes for the chart footnote.
	
	
	// Step 6: Create a pie chart. Footnote text is flush left to allow 
	// wrapping lines without inserting tabs in footnote.
	
	#delimit ;
	graph pie, over (pie_hire) angle(-50) 	
		pie(1, color(dknavy))
		pie(2, color(maroon))
		pie(3, color(forest_green))
		plabel(_all percent, format(%3.0f) color(white) size(*1.2))
		plabel(1 "Experienced" "Teachers", gap(30) color(black) size(medsmall))
		plabel(2 "Novice" "New Hires", gap(30) color(black) size(medsmall))
		plabel(3 "Experienced" "New Hires", gap(30) color(black) size(medsmall))
		legend(off)
		graphregion(color(white) fcolor(white) lcolor(white))
		plotregion(color(white) fcolor(white) lcolor(white) margin(1 1 3 3))
		title("Share of Teachers Who Are New Hires", span)
		note(" " "Notes: Sample includes teachers in the 2007-08 through 2010-11 
school years, with `teacher_years' teacher years and `unique_teachers' unique 
teachers." "Novices were in their first year of teaching.", size(vsmall) span);
	#delimit cr
	
	// Step 7: Save the chart in Stata Graph and EMF formats.
	
	graph export "${graphs}/A1_Share_of_Teachers_New_Hires.emf", replace 
	graph save "${graphs}/A1_Share_of_Teachers_New_Hires.gph", replace 

}

/*** A2. Share of Teachers Who Are New Hires by School Year ***/ 

if ${new_hires_year}==1 { 
	
	// Step 1: Load the Teacher_Year_Analysis data file.
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year
		
	// Step 2: Restrict the analysis sample.
	
	
	// Step 3: Review variables to be used in the analysis.
	
	
	// Step 4: Calculate sample size. 
	
	
	// Step 5: Calculate significance indicator variables by year.
	
		
	// Step 6: Collapse the teacher-level data file to calculate percent of new hires
	// by year.
	
	collapse (mean) t_novice t_veteran_newhire sig_*, by(school_year)
	foreach var in t_novice t_veteran_newhire {
		replace `var' = 100 * `var'
	}
	
	// Step 7: Concatenate values and significance asterisks to make value labels.
	
	
	// Step 8: Get the total new hire percent for each year for graphing.
	
		
	// Step 9: Create a stacked bar graph using overlaid bars. Use scatter plots with
	// invisible symbols for the value labels. 
	
	#delimit ;
	twoway (bar t_total school_year, 
			fcolor(forest_green) lcolor(forest_green) lwidth(0) barwidth(0.75))
		(bar t_novice school_year, 
			fcolor(maroon) lcolor(maroon) lwidth(0) barwidth(0.75)) 
		(scatter t_total school_year, 
			mcolor(none) mlabel(t_veteran_newhire_label) mlabcolor(white) mlabpos(6)  
			mlabsize(small)) 
		(scatter t_novice school_year, 
			mcolor(none) mlabel(t_novice_label) mlabcolor(white) mlabpos(6)  
			mlabsize(small)), 
		title("Share of Teachers Who Are New Hires", span) 
		subtitle("by School Year", span) 
		ytitle("Percent of Teachers") 
		ylabel(0(10)60, nogrid labsize(medsmall)) 
		xtitle("") 
		xlabel(2008 "2007-08" 2009 "2008-09" 2010 "2009-10" 2011 "2010-11", 
			labsize(medsmall)) 
		legend(order(1 "Experienced New Hires" 2 "Novice New Hires")
			ring(0) position(11) symxsize(2) symysize(2) rows(2) size(medsmall) 
			region(lstyle(none) lcolor(none) color(none))) 
		graphregion(color(white) fcolor(white) lcolor(white)) 
		plotregion(color(white) fcolor(white) lcolor(white) margin(2 0 2 0))
		note(" " "*Significantly different from 2008 value, at the 95 percent confidence 
level."	"Notes: Sample includes teachers in the 2007-08 through 2010-11 school 
years, with `teacher_years' teacher years and `unique_teachers' unique teachers.
Novices were in" "their first year of teaching.", size(vsmall) span);
	#delimit cr
	
	// Step 10: Save the chart in Stata Graph and EMF formats.
	
	graph export "${graphs}/A2_New Hires_by_School_Year.emf", replace 
	graph save "${graphs}/A2_New Hires_by_School_Year.gph", replace 

}
	
/*** A3. Share of Teachers Who Are New Hires by School Poverty Level ***/
 
if ${new_hires_school_poverty}==1 { 
	
	// Step 1: Load the Teacher_Year_Analysis data file. 
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear 
	isid tid school_year
		
	// Step 2: Restrict the analysis sample.
	
	
	// Step 3: Review variables used in the analysis.
	
	
	// Step 4: Calculate sample size. 
	
	
	// Step 5: Calculate significance indicator variables by school poverty quartile.
	

	// Step 6: Collapse to calculate shares of new hires in each quartile.
	
	collapse (mean) t_novice t_veteran_newhire sig_*, by(school_poverty_quartile)
	foreach var of varlist t_novice t_veteran_newhire {
		replace `var' = 100 * `var'
	}

	// Step 7: Concatenate values and significance asterisks to make value labels.
	
	
	// Step 8: Get the total new hire percent for each year for graphing.
	

	// Step 9: Create a bar graph using twoway bar and scatter for the labels.
	
	#delimit ;
	twoway (bar t_total school_poverty_quartile, 
			fcolor(forest_green) lcolor(forest_green) lwidth(0) barwidth(0.75))
		(bar t_novice school_poverty_quartile, 
			fcolor(maroon) lcolor(maroon) lwidth(0) barwidth(0.75)) 
		(scatter t_total school_poverty_quartile, 
			mcolor(none) mlabel(t_veteran_newhire_label) mlabcolor(white) mlabpos(6)  
			mlabsize(small)) 
		(scatter t_novice school_poverty_quartile, 
			mcolor(none) mlabel(t_novice_label) mlabcolor(white) mlabpos(6)  
			mlabsize(small)), 
		title("Share of Teachers Who Are New Hires", span) 
		subtitle("by School FRPL Quartile", span) 
		ytitle("Percent of Teachers") 
		ylabel(0(10)60, nogrid labsize(medsmall)) 
		xtitle("") 
		xlabel(1 "Lowest Poverty" 2 "2nd Quartile" 3 "3rd Quartile" 4 "Highest Poverty", 
			labsize(medsmall)) 
		legend(order(1 "Experienced New Hires" 2 "Novice New Hires")
			ring(0) position(11) symxsize(2) symysize(2) rows(2) size(medsmall) 
			region(lstyle(none) lcolor(none) color(none))) 
		graphregion(color(white) fcolor(white) lcolor(white)) 
		plotregion(color(white) fcolor(white) lcolor(white) margin(2 0 2 0))
		note(" " "*Significantly different from schools in the lowest free and reduced 
price lunch quartile, at the 95 percent confidence level." "Notes: Sample includes 
teachers in the 2007-08 through 2010-11 school years, with `teacher_years' teacher years 
and `unique_teachers' unique teachers. Novices were" "in their first year of teaching.", 
	size(vsmall) span);
	#delimit cr
	
	// Step 10: Save the chart in Stata Graph and EMF formats. If marker labels need to be
	// moved by hand using Stata Graph Editor, re-save .gph and .emf files after editing.
	
	graph export "${graphs}/A3_New Hires_by_Poverty_Quartile.emf", replace 
	graph save "${graphs}/A3_New Hires_by_Poverty_Quartile.gph", replace 

}
	
/*** A4. Teacher Effectiveness for Alternatively Certified Teachers ***/ 
	
if ${teacher_effects_cert_pathway}==1{

	// Step 1: Choose a subject for the analysis. Note: To change from math to ELA,
	// switch the subjects in the next two lines. To generate ELA and math charts
	// at the same time, enclose the analysis code within a loop.
	
	local subject math
	local alt_subject ela
	
	// Step 2. Load the Student_Teacher_Year_Analysis data file.
	
	use "${analysis}\Student_Teacher_Year_Analysis.dta", clear  
	isid sid school_year
	
	// Step 3: Restrict the sample. Keep only teachers in their first five years of
	// teaching. Keep grades and years for which prior-year test scores are available. 
	// Keep students with teachers with non-missing values for experience and 
	// certification pathway. Keep students with a single identified core course 
	// and current and prior-year test scores in the given subject.
	
	
	// Step 4: Review teacher variables.
	
	
	// Step 5: Create a dummy variable for alternative certification. 
	
		
	// Step 6: Create dummy variables for each year of teaching experience.
	
		
	// Step 7: Create variable for grade-by-year fixed effects. 
	
	
	// Step 8: Create variables for previous year's score squared and cubed.
	
		
	// Step 9: Create indicator for whether student is missing prior achievement 
	// for alternate subject. Make a replacement variable that imputes score to 
	// zero if missing.
	
		
	// Step 10: Identify prior achievement variables to use as controls.
	
	
	// Step 11: Identify other student variables to use as controls.
	
	
	// Step 12: Review all variables to be included in the teacher effectiveness models.
	// Class and cohort (grade/school/year) variables should include means of all 
	// student variables, and means, standard deviations, and percent missing for 
	// prior-year test scores for both main and alternate subject. Class and 
	// cohort size should also be included as controls.
	
	
	// Step 13: Estimate differences in teacher effectiveness between alternatively 
	// and traditionally certified teachers, without teacher experience controls.
	
		
	// Step 14: Store coefficient and standard error.
	
			
	// Step 15: Get teacher sample size for this model.
	

	// Step 16: Estimate differences in teacher effectiveness between alternatively 
	// and traditionally certified teachers, with teacher experience controls.
	
	
	// Step 17: Store coefficient and standard error.
	

	// Step 18: Get teacher sample size for this model and compare sample size
	// for the two models.
	
	
	// Step 19: Store teacher sample size for footnote.
	
	
	// Step 20: Collapse dataset for graphing.
	
		
	// Step 21: Get signficance.
	
			
	// Step 22: Reshape for graphing.
	
	
	// Step 23: Make value labels with significance indicator.
	
		
	// Step 24: Define subject titles for graph.
	

	// Step 25: Create a bar graph of the estimation results.
	
	#delimit ;
	graph twoway (bar coef spec,
			fcolor(dknavy) lcolor(dknavy) lwidth(0) barwidth(0.7))
		(scatter coef spec,
			mcolor(none) mlabel(coef_label) mlabcolor(black) mlabpos(12)  
			mlabsize(small)),
		yline(0, style(extended) lpattern(dash) lwidth(medthin) lcolor(black))
		title("Effectiveness of `subject_title' Teachers with Alternative Certification", 
		span) 
		subtitle("Relative to Teachers without Alternative Certification", span) 
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
		note(" " "*Significantly different from zero, at the 95 percent confidence level." 
"Notes: Sample includes 2007-08 through 2010-11 5th through 8th grade `subject_foot'
teachers who were in their first five years" "of teaching, with `teacher_years' teacher
years and `unique_teachers' unique teachers. Teacher effects are measured in student test
score standard deviations.", 
	size(vsmall) span);	
	#delimit cr
	
	// Step 26: Save chart.
	
	graph export "${graphs}/A4_Teacher_Effects_Cert_Pathway_`subject_title'.emf", replace 
	graph save "${graphs}/A4_Teacher_Effects_Cert_Pathway_`subject_title'.gph", replace 
	
}		

/*** A5. Share of Teachers and Students by Race ***/ 

if ${share_teachers_stu_race}==1 {

	// Step 1: Set up matrix to hold teacher, new teacher, and student results.
	
	matrix race = J(4, 4, .)
	matrix colnames race = race teacher new_teacher student
	
	// Step 2: Load the Teacher_Year_Analysis data file. 
	
	use "${analysis}\Teacher_Year_Analysis.dta", clear
	isid tid school_year
	
	// Step 3: Restrict the teacher sample.
	
	
	// Step 4: Review teacher variables.
	
		
	// Step 5: Get teacher sample sizes.
	
	
	// Step 6: Store percentages by race for all teachers and newly hired teachers. 
	
	
	// Step 7: Load the Connect_Step1 data file to get student data.
	
	use "${analysis}\Connect_Step1.dta", clear
	isid sid cid
	
	// Step 8: Make the file unique by sid and school_year.
	
	
	// Step 9: Restrict the student sample.
	
	
	// Step 10: Review student variables.
	
	// Step 11: Create dummy variables for major student race/ethnicity categories.
	
	
	// Step 12: Get student sample sizes.
	
	
	// Step 13: Store percentages by race for students.
	
	
	// Step 14: Replace the dataset with the matrix of results.
	
	
	// Step 15: Graph the results.
	
	#delimit ;
	graph bar teacher new_teacher student, 
		bar(1, fcolor(dknavy) lcolor(dknavy)) 
		bar(2, fcolor(dknavy*.7) lcolor(dknavy*.7)) 
		bar(3, fcolor(maroon) lcolor(maroon))
		blabel(bar, position(inside) color(white) format(%10.0f))
		over(race, relabel(1 "White" 2 "Black" 3 "Latino" 4 "Asian") 
			label(labsize(medsmall)))
		title("Share of Teachers and Students", span)
		subtitle("by Race", span)
		ytitle("Percent", size(medsmall))
		ylabel(0(20)100, labsize(medsmall) nogrid)
		legend(order(1 "All Teachers" 2 "Newly Hired Teachers" 3 "Students")
			ring(0) position(11) symxsize(2) symysize(2) rows(3)
			size(medsmall) region(lstyle(none) lcolor(none) color(none)))
		graphregion(color(white) fcolor(white) lcolor(white))
		plotregion(color(white) fcolor(white) lcolor(white) margin(5 5 2 0))
		note(" " "Notes: Sample includes teachers in the 2007-08 through 2010-11 school 
years, with `teacher_years' teacher years, `unique_teachers' unique teachers, 
`student_years' student" "years, and `unique_students' unique students.", size(vsmall) 
span);		
	#delimit cr
	
	// Step 16: Save the chart.
	
	graph export "${graphs}/A5_Share_Teachers_Students_by_Race.emf", replace 
	graph save "${graphs}/A5_Share_Teachers_Students_by_Race.gph", replace 
}

log close
