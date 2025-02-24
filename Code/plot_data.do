********************************************************************************
/* PLOT DATA 

Plot various time series data related to the Riksbank's policy in 2024. */
********************************************************************************

	clear all 
	set more off, permanently
	cd "/Users/edvinahlander/Library/CloudStorage/OneDrive-StockholmUniversity/PhD/Year 2/Courses/Monetary/Assignments/RB Evaluation/cemof_evaluation"

********************************************************************************
/* Import data */

	* Inflation

	import excel "Data/Attachments/Riksbanken_data_forecasts_GDP_unemployment_GDP_gap.xlsx", sheet("M utfall") clear

	keep A B D E G

	rename (B D E G) (cpif_ind cpifxe_ind cpif_ch cpifxe_ch)

	gen year  = year(A)
	gen month = month(A)

	gen period = ym(year, month)
	format %tm period 

	drop if missing(A)
	destring cpif_ind-cpifxe_ch, replace

	keep period year month cpif_ind cpifxe_ind cpif_ch cpifxe_ch
	order period year month cpif_ind cpifxe_ind cpif_ch cpifxe_ch

	sort period

	gen cpif_6m   = ((cpif_ind[_n]/cpif_ind[_n-6])^(12/6) - 1)*100

	drop if year < 2024

	twoway ///
	(line cpif_ch period) ///
	(line cpif_6m period) ///
	(line cpifxe_ch period), legend(off) ///
	xline(769 770 772 774 775 776 778, lcolor(black%30) lpattern(dash)) ///
	text(4.4 769.1 "", place(e)) ///
	text(4.4 770.1 "-.25", place(e)) ///
	text(4.4 772.1 "", place(e)) /// 
	text(4.4 774.1 "-.25", place(e)) /// 
	text(4.4 775.1 "-.25", place(e)) ///
	text(4.4 776.1 "-.5", place(e)) ///
	text(4.4 778.1 "-.25", place(e)) ///
	text(2.1 779.1 "CPIF-XE", place(e)) ///
	text(1.5 779.1 "CPIF", place(e)) ///
	text(2.3 779.1 "CPIF6M", place(e)) ///
	xtitle("") xlabel(, nogrid) ylabel(, nogrid) ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/inflation.png", replace	
		   
	* Inflation expectations

	import excel "Data/Attachments/Riksbanken_data_forecasts_GDP_unemployment_GDP_gap.xlsx", sheet("Q utfall") clear

	keep A R T V

	rename (R T V) (ie1 ie2 ie5)

	gen year  = year(A)
	gen quarter = quarter(A)

	gen period = yq(year, quarter)
	format %tq period 

	drop if missing(A)
	destring ie1 ie2 ie5, replace

	keep period year quarter ie1 ie2 ie5
	order period year quarter ie1 ie2 ie5

	sort period

	drop if year < 2024

	twoway ///
	(line ie1 period) ///
	(line ie2 period) ///
	(line ie5 period), legend(off) ///
	text(1.73 259.1 "1Y", place(e)) ///
	text(1.95 259.1 "2Y", place(e)) ///
	text(2.05 259.1 "5Y", place(e)) ///
	xtitle("") ylabel(1(1)3) xlabel(256(1)259.5) ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/inflation_expectations.png", replace	
	
	* BNP Gap and Unemployment
	
	import excel "Data/Attachments/Riksbanken_data_forecasts_GDP_unemployment_GDP_gap.xlsx", sheet("Q utfall") clear
	
	keep A I J AI

	rename (I J AI) (bnpgap unemp repo)

	gen year  = year(A)
	gen quarter = quarter(A)

	gen period = yq(year, quarter)
	format %tq period 

	drop if missing(A)
	destring bnpgap unemp repo, replace

	keep period year quarter bnpgap unemp repo
	order period year quarter bnpgap unemp repo

	sort period
	
	drop if year < 2023
	
	twoway ///
	(line bnpgap period, yaxis(1)) ///
	(line repo period, yaxis(2)), legend(order(1 "GDP Gap (L)" 2 "Policy Rate (R)")) ///
	xtitle("") ytitle("", axis(1)) ytitle("", axis(2)) xlabel(252(2)259) ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/bnpgap.png", replace
	
	twoway ///
	(line unemp period, yaxis(1)) ///
	(line repo period, yaxis(2)), legend(order(1 "Unemp. (L)" 2 "Policy Rate (R)")) ///
	xtitle("") ytitle("", axis(1)) ytitle("", axis(2)) xlabel(252(2)259) ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/unemp.png", replace
	
	* Geopolitical risk index
	
	use "Data/Other/data_gpr_export.dta", clear
	
	gen date = dofm(month)
	drop month 
	
	gen year   = year(date)
	gen month  = month(date)
	gen period = ym(year, month)
	format %tm period
	
	keep period year month GPR GPRC_SWE
	order period year month GPR GPRC_SWE
		
	egen gr_avg = mean(GPR)
	egen gr_std = sd(GPR)
	
	gen gr_rel = (GPR-gr_avg)/gr_std
	
	egen grswe_avg = mean(GPRC_SWE)
	egen grswe_std = sd(GPRC_SWE)
	
	gen grswe_rel = (GPRC_SWE-grswe_avg)/grswe_std
	
	egen warshock = mean(gr_rel) if year == 2022 & month < 5
	egen curshock = mean(gr_rel) if (year == 2023 & month > 9) | (year == 2024 & month < 7)
	
	drop if year < 2020
	
	gen warind = .
	replace warind = 319 if year == 2022 & month < 5
	
	gen curind = .
	replace curind = 319 if (year == 2023 & month > 9) | (year == 2024 & month < 7) 
	
	twoway ///
	(line GPR period) ///
	(line gr_avg period) ///
	(area warind period, color(black%20) lwidth(none none none none)) ///
	(area curind period, color(black%20) lwidth(none none none none)), legend(off) ///
	text(316.5 741.2 "1pp", place(e)) ///
	text(316.5 760.8 "0.4pp", place(e)) ///
	xtitle("") ytitle("") ytitle("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/gpr.png", replace
		
	twoway ///
	(line GPRC_SWE period) ///
	(line grswe_avg period), legend(off) ///
	xtitle("") ytitle("") ytitle("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/gpr_swe.png", replace
	
	* Aggregate outcomes and policy rates EA + US
	
	import excel "Data/Attachments/Assignment_figures_CPI_rates.xlsx", sheet("Sheet1") clear
	
	gen year  = year(A)
	gen month = month(A)
	
	drop if missing(A)
	
	rename (D E I J L M) (ea_rat us_rat ea_cpi us_cpi ea_cpixef us_cpixef)
	
	destring ea_rat us_rat ea_cpi us_cpi ea_cpixef us_cpixef, replace
	
	gen period = ym(year, month)
	format %tm period
	
	keep  period year month ea_rat us_rat ea_cpi us_cpi ea_cpixef us_cpixef
	order period year month ea_rat us_rat ea_cpi us_cpi ea_cpixef us_cpixef
	
	sort period 
	
	gen ea_cpi_l1 = ea_cpi[_n-1]
	gen ea_cpi_l2 = ea_cpi[_n-2]
	
	gen us_cpi_l1 = us_cpi[_n-1]
	gen us_cpi_l2 = us_cpi[_n-2]
	
	gen ea_cpi_sh = ea_cpi_l1
	replace ea_cpi_sh = ea_cpi_l2 if period == 769
	
	gen us_cpi_sh = us_cpi_l1 
	replace us_cpi_sh = us_cpi_l2 if period == 769 | period == 772 | period == 778
	
	preserve 
	
	import excel "Data/Other/us_unemp.xlsx", sheet("Monthly") clear
	
	drop if _n == 1
	
	gen year      = substr(A, 6, 4)
	gen month_str = substr(A, 3, 3)
	
	gen month = .
	replace month = 1 if month_str == "jan"
	replace month = 2 if month_str == "feb"
	replace month = 3 if month_str == "mar"
	replace month = 4 if month_str == "apr"
	replace month = 5 if month_str == "may"
	replace month = 6 if month_str == "jun"
	replace month = 7 if month_str == "jul"
	replace month = 8 if month_str == "aug"
	replace month = 9 if month_str == "sep"
	replace month = 10 if month_str == "oct"
	replace month = 11 if month_str == "nov"
	replace month = 12 if month_str == "dec"
		
	rename B us_unemp
	
	destring year us_unemp, replace 
	
	keep  year month us_unemp
	order year month us_unemp

	save "unemp_tmp.dta", replace
	
	restore 
	
	merge 1:1 year month using "unemp_tmp.dta"
	keep if _merge == 3
	drop _merge 
	erase "unemp_tmp.dta"
	
	drop if year < 2024
	
	twoway ///
	(line ea_rat period) ///
	(line ea_cpi_sh period), legend(off) ///
	xline(769 770 772 774 775 776 778, lcolor(black%30) lpattern(dash)) ///
	text(4.1 769.1 "", place(e)) ///
	text(4.1 770.1 "-.25", place(e)) ///
	text(4.1 772.1 "", place(e)) /// 
	text(4.1 774.1 "-.25", place(e)) /// 
	text(4.1 775.1 "-.25", place(e)) ///
	text(4.1 776.1 "-.5", place(e)) ///
	text(4.1 778.1 "-.25", place(e)) ///
	text(3.15 779.05 "ECB Rate", place(e)) ///
	text(2.25 779.05 "EA CPI", place(e)) ///
	xtitle("") xlabel(, nogrid) ylabel(1.5(0.5)4.1, nogrid) ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/ea_rat_cpi.png", replace
	
	twoway ///
	(line us_rat period) ///
	(line us_cpi_sh period), legend(off) ///
	xline(769 770 772 774 775 776 778, lcolor(black%30) lpattern(dash)) ///
	text(6 769.1 "", place(e)) ///
	text(6 770.1 "-.25", place(e)) ///
	text(6 772.1 "", place(e)) /// 
	text(6 774.1 "-.25", place(e)) /// 
	text(6 775.1 "-.25", place(e)) ///
	text(6 776.1 "-.5", place(e)) ///
	text(6 778.1 "-.25", place(e)) ///
	text(4.68 779.05 "Fed Rate", place(e)) ///
	text(2.75 779.05 "US CPI", place(e)) ///
	xtitle("") xlabel(, nogrid) ylabel(, nogrid) ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/us_rat_cpi.png", replace
	
	twoway ///
	(line us_rat period) ///
	(line us_unemp period), legend(off) ///
	text(4.64 779.05 "Fed Rate", place(e)) ///
	text(4.1 779.05 "US UR", place(e)) ///
	xtitle("") ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/us_unemp.png", replace
	
********************************************************************************
