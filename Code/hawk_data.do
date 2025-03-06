********************************************************************************
/* HAWK DEFINITION AND PLOT

Plot time series data of below defined index variable on hawkishness of 
individual governors. */
********************************************************************************

	clear all 
	set more off, permanently
    cd "/Users/jacob/SU/PhD/Projects/cemof_evaluation"
	*cd "/Users/edvinahlander/Library/CloudStorage/OneDrive-StockholmUniversity/PhD/Year 2/Courses/Monetary/Assignments/RB Evaluation/cemof_evaluation"
	
********************************************************************************
/* Import word count data */
	
	import delimited "Data/old_governors_data.csv", clear
    gen date_var = date(date, "YMD")
	gen year  = year(date_var)
	gen month = month(date_var)
	gen period = ym(year, month)
	
	format %tm period 
	sort period

	egen hawk_sum = rowtotal(inflation-växelkurs)
	egen dove_sum = rowtotal(tillväxt-samhället)
	egen geo_sum = rowtotal(geopolitisk-osäkerhet)

	gen ordsumma = hawk_sum + dove_sum 
	gen hawk_ind = hawk_sum / ordsumma
	gen geo_ind = geo_sum

	* Add newer governor data
	preserve

	import delimited "Data/governors_data.csv", clear
 	gen date_var = date(date, "YMD")
	gen year  = year(date_var)
	gen month = month(date_var)
	gen period = ym(year, month)
	
	format %tm period 
	sort period

	egen hawk_sum = rowtotal(inflation-växelkurs)
	egen dove_sum = rowtotal(tillväxt-samhället)
	egen geo_sum = rowtotal(geopolitisk-osäkerhet)

	gen ordsumma = hawk_sum + dove_sum
	gen hawk_ind = hawk_sum / ordsumma
	gen geo_ind = geo_sum
	save "gov_tmp.dta", replace
	
	restore 
	append using "gov_tmp.dta"
	erase "gov_tmp.dta
	
	* Merge with inflation time series
	preserve

	import excel "Data/Other/KPIF.xlsx", clear
	
	destring B, replace force
	drop if missing(B)
	
	gen year  = substr(A, 1, 4)
	gen month = substr(A, 6, 2)
	destring year month, replace 
	
	gen period = ym(year,month)	
	replace period = period + 1 // lag by one period
	format %tm period
	
	rename B kpif_val
	
	keep period kpif_val 
	order period kpif_val

	save "inf_tmp.dta", replace
	
	restore 
	
	merge m:1 period using "inf_tmp.dta"
	keep if _merge == 3
	drop _merge 
	erase "inf_tmp.dta"

	* extracting unanimosity data from votes
	preserve 
	import excel "Data/Other/voting-by-the-executive-board-on-interest-rate-decisions.xlsx", sheet("Voting")  cellrange(F56:GI56) clear
	sxpose, clear force
	rename _var1 unanimousity
	destring unanimousity, force replace
	save "voting_tmp.dta", replace
	restore

	preserve 
	import excel "Data/Other/voting-by-the-executive-board-on-interest-rate-decisions.xlsx", sheet("Voting") cellrange(F3:GI3) clear
	sxpose, clear force
	rename _var1 date
	destring date, force replace
	format %td date
	gen period = mofd(date)
	format %tm period
	merge 1:1 _n using "voting_tmp.dta", force
	drop _merge date
	duplicates drop period, force
	erase "voting_tmp.dta"
	save "enighet_tmp.dta", replace
	restore
	preserve


	* create variance measure for each time period as a proxy for unity of the board (also adding unanimosity measure)
	collapse (sd) hawk_ind, by(period)
	merge 1:1 period using "enighet_tmp.dta"
	keep if _merge == 3
	drop _merge
	erase "enighet_tmp.dta"
	restore

	twoway (line hawk_ind period, yaxis(1)) (line unanimousity period, yaxis(2)), ///
	legend(off) ///
	ytitle("S.d. of hawkishness index") xtitle("Time") title("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_sd.png", replace
	restore
	
	* construct inflation bins 
	gen kpif_bin = .
	replace kpif_bin = 1 if kpif_val < 1.5 // low inflation
	replace kpif_bin = 2 if kpif_val >= 1.5 & kpif_val < 2.5 // inflation at target
	replace kpif_bin = 3 if kpif_val >= 2.5 & kpif_val < 4 // high inflation
	replace kpif_bin = 4 if kpif_val >= 4 // very high inflation
	
	* extract index residuals by removing governor/kpif_bin averages
	reghdfe hawk_ind, absorb(kpif_bin) resid 
	rename _reghdfe_resid res_hawk
	
	* plot indices for specific governors
	twoway (line res_hawk period if governor == "Martin Flodén") /// 
	(line res_hawk period if governor == "Per Jansson") ///
	(line res_hawk period if governor == "Stefan Ingves") ///
	(line res_hawk period if governor == "Anna Breman"), ///
	legend( order(1 "Martin Flodén" 2 "Per Jansson" 3 "Stefan Ingves" 4 "Anna Breman")) ///
	ytitle("Hawkishness index") xtitle("Time") title("Hawkishness index of individual governors") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_res_governor.png", replace
	
	* aggregate over governors
	collapse (sum) hawk_sum-ordsumma (mean) kpif_bin, by(period)
	
	gen hawk_ind = hawk_sum / ordsumma
	reghdfe hawk_ind, absorb(kpif_bin) resid 
	rename _reghdfe_resid res_hawk
	
	* plot aggregate index
	twoway (line res_hawk period), ///
	legend(off) ///
	ytitle("Hawkishness index") xtitle("Time") title("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_res.png", replace
