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
	gen month = month(A)

	gen period = ym(year, month)
	format %tm period 

	drop if missing(A)
	destring ie1 ie2 ie5, replace

	keep period year month ie1 ie2 ie5
	order period year month ie1 ie2 ie5

	sort period

	drop if year < 2024

	twoway ///
	(line ie1 period) ///
	(line ie2 period) ///
	(line ie5 period), legend(off) ///
	text(1.73 777.1 "1Y", place(e)) ///
	text(1.95 777.1 "2Y", place(e)) ///
	text(2.05 777.1 "5Y", place(e)) ///
	xtitle("") ylabel(1(1)3) xlabel(768(2)778) ///
	graphregion(color(white)) plotregion(color(white))
	graph export "Output/inflation_expectations.png", replace	

********************************************************************************
