********************************************************************************
/* HAWK DEFINITION AND PLOT

Plot time series data of below defined index variable on hawkishness of 
individual governors. */
********************************************************************************

	clear all 
	set more off, permanently
    *cd "/Users/jacob/SU/PhD/Projects/cemof_evaluation"
	cd "/Users/edvinahlander/Library/CloudStorage/OneDrive-StockholmUniversity/PhD/Year 2/Courses/Monetary/Assignments/RB Evaluation/cemof_evaluation"
	
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
	egen dove_sum = rowtotal(tillväxt-arbets)
	egen geo_sum = rowtotal(geopolitisk-invasion)

	gen ordsumma = hawk_sum + dove_sum 
	gen hawk_ind = ((hawk_sum-dove_sum) / ordsumma) + 1
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
	egen dove_sum = rowtotal(tillväxt-arbets)
	egen geo_sum = rowtotal(geopolitisk-invasion)

	gen ordsumma = hawk_sum + dove_sum
	gen hawk_ind = ((hawk_sum-dove_sum) / ordsumma) + 1
	gen geo_ind = geo_sum
	save "gov_tmp.dta", replace
	
	restore 
	append using "gov_tmp.dta"
	erase "gov_tmp.dta"
	
	* Merge with inflation/unemployment time series
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
	
	import excel "Data/Other/swe_unemp.xlsx", sheet("Monthly") clear
	
	drop if _n == 1
	gen nn = _n
	
	gen year = substr(A, 6, 4)
	bysort year (nn): gen month = _n
	destring year, replace 
	
	rename B unemp_val
	destring unemp_val, replace
	
	gen period = ym(year,month)	
	replace period = period + 1 // lag by one period
	format %tm period
	
	keep period unemp_val 
	order period unemp_val
	
	save "unemp_tmp.dta", replace
	
	restore 
	
	merge m:1 period using "inf_tmp.dta"
	keep if _merge == 3
	drop _merge 
	erase "inf_tmp.dta"
	
	merge m:1 period using "unemp_tmp.dta"
	keep if _merge == 3
	drop _merge 
	erase "unemp_tmp.dta"

	* construct inflation bins 
	gen kpif_bin = .
	replace kpif_bin = 1 if kpif_val < 1.5 // low inflation
	replace kpif_bin = 2 if kpif_val >= 1.5 & kpif_val < 2.5 // inflation at target
	replace kpif_bin = 3 if kpif_val >= 2.5 & kpif_val < 4 // high inflation
	replace kpif_bin = 4 if kpif_val >= 4 // very high inflation
	
	* construct unemployment bins
	gen unemp_bin = . 
	replace unemp_bin = 1 if unemp_val < 7 // low unemployment
	replace unemp_bin = 2 if unemp_val >= 7 & unemp_val < 8 // medium unemployment
	replace unemp_bin = 3 if unemp_val >= 8 // high unemployment
	
	* extract index residuals by removing inflation/unemp averages
	egen gov_id = group(governor)
	sort gov_id period
	xtset gov_id period, monthly
	reghdfe hawk_ind, absorb(i.kpif_bin i.unemp_bin) resid 
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
	
	* plot indices for specific governors (2024)
	twoway (line res_hawk period if governor == "Martin Flodén" & year == 2024) /// 
	(line res_hawk period if governor == "Per Jansson" & year == 2024) ///
	(line res_hawk period if governor == "Aino Bunge" & year == 2024) ///
	(line res_hawk period if governor == "Anna Seim" & year == 2024) ///
	(line res_hawk period if governor == "Erik Thedéen" & year == 2024) ///
	(line res_hawk period if governor == "Anna Breman" & year == 2024), ///
	legend( order(1 "Martin Flodén" 2 "Per Jansson" 3 "Aino Bunge" 4 "Anna Seim" 5 "Erik Thedéen" 4 "Anna Breman")) ///
	ytitle("Hawkishness index") xtitle("Time") title("Hawkishness index of individual governors (2024)") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_res_governor_2024.png", replace
	
	* smooth indices for specific governors 
	tssmooth ma res_hawk_ma = res_hawk, window(2 1 2)
	
	* plot smoothed indices 
	twoway (line res_hawk_ma period if governor == "Martin Flodén") /// 
	(line res_hawk_ma period if governor == "Per Jansson") ///
	(line res_hawk_ma period if governor == "Stefan Ingves") ///
	(line res_hawk_ma period if governor == "Anna Breman"), ///
	legend( order(1 "Martin Flodén" 2 "Per Jansson" 3 "Stefan Ingves" 6 "Anna Breman")) ///
	ytitle("Hawkishness index") xtitle("Time") title("Hawkishness index of individual governors") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_res_ma_governor.png", replace
	
	* plot indices for specific governors (2024)
	twoway (line res_hawk_ma period if governor == "Martin Flodén" & year == 2024) /// 
	(line res_hawk_ma period if governor == "Per Jansson" & year == 2024) ///
	(line res_hawk_ma period if governor == "Aino Bunge" & year == 2024) ///
	(line res_hawk_ma period if governor == "Anna Seim" & year == 2024) ///
	(line res_hawk_ma period if governor == "Erik Thedéen" & year == 2024) ///
	(line res_hawk_ma period if governor == "Anna Breman" & year == 2024), ///
	legend( order(1 "Martin Flodén" 2 "Per Jansson" 3 "Aino Bunge" 4 "Anna Seim" 5 "Erik Thedéen" 6 "Anna Breman")) ///
	ytitle("Hawkishness index") xtitle("Time") title("Hawkishness index of individual governors (2024)") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_res_ma_governor_2024.png", replace
	
	* aggregate over governors
	gen res_hawk_sd = res_hawk
	collapse (mean) hawk_ind res_hawk (sd) res_hawk_sd, by(period)
	
	* plot aggregate index
	twoway (line res_hawk period), ///
	legend(off) ///
	ytitle("Hawkishness index") xtitle("Time") title("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_res.png", replace
	
	* smooth indices
	tsset period
	tssmooth ma res_hawk_ma = res_hawk, window(2 1 2)
	
	* plot smoothed aggregate index
	twoway (line res_hawk_ma period), ///
	legend(off) ///
	ytitle("Hawkishness index") xtitle("Time") title("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_res_ma.png", replace
	
	* extract unanimosity data from votes
	preserve 
	import excel "Data/Other/voting-by-the-executive-board-on-interest-rate-decisions.xlsx", sheet("Voting")  cellrange(F56:GI56) clear
	sxpose, clear force
	rename _var1 unanimousity
	destring unanimousity, force replace
	save "voting_tmp.dta", replace
	
	import excel "Data/Other/voting-by-the-executive-board-on-interest-rate-decisions.xlsx", sheet("Voting") cellrange(F3:GI3) clear
	sxpose, clear force
	rename _var1 date
	destring date, force replace
	format %td date
	gen period = mofd(date)
	format %tm period
	merge 1:1 _n using "voting_tmp.dta"
	drop _merge date
	duplicates drop period, force
	erase "voting_tmp.dta"
	save "enighet_tmp.dta", replace
	restore
	
	merge 1:1 period using "enighet_tmp.dta"
	drop if _merge == 2
	drop _merge 
	erase "enighet_tmp.dta"
	
	* plot unanimosity and std in hawk index
	twoway ///
	(line res_hawk_sd  period) ///
	(line unanimousity period), ///
	legend(order(1 "S.D. Hawk Index" 2 "Unanimosity") position(0) bplacement(swest)) ///
	xtitle("Time") ylabel(0(0.2)1) title("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/hawk_sd.png", replace
