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

********************************************************************************
