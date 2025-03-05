********************************************************************************
/* HAWK DEFINITION AND PLOT

Plot time series data of below defined index variable on hawkishness of 
individual governors. */
********************************************************************************

	clear all 
	set more off, permanently
    cd "/Users/jacob/SU/PhD/Projects/cemof_evaluation"
********************************************************************************
/* Import word count data */
	import delimited "Data/old_governors_data.csv", clear
    gen date_var = date(date, "YMD")
	gen year  = year(date_var)
	gen month = month(date_var)
	gen period = ym(year, month)
	
	format %tm period 
	sort period

	egen hawk_sum = rowtotal(kpif-kostnad)
	egen dove_sum = rowtotal(tillväxt-räntekänslig)
	egen geo_sum = rowtotal(geopolitisk-tullar)

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

	egen hawk_sum = rowtotal(kpif-kostnad)
	egen dove_sum = rowtotal(tillväxt-räntekänslig)
	egen geo_sum = rowtotal(geopolitisk-tullar)

	gen ordsumma = hawk_sum + dove_sum + geo_sum
	gen hawk_ind = hawk_sum / ordsumma
	gen geo_ind = geo_sum / ordsumma
	save "gov_tmp.dta", replace
	
	restore 
	append using "gov_tmp.dta"
	erase "gov_tmp.dta

	* Non residualized plot
	twoway (line hawk_ind period if governor == "Martin Flodén") /// 
	(line hawk_ind period if governor == "Per Jansson") ///
	(line hawk_ind period if governor == "Stefan Ingves") ///
	(line hawk_ind period if governor == "Lars E.O. Svensson") ///
	(line hawk_ind period if governor == "Kerstin af Jochnick") ///
	(line hawk_ind period if governor == "Cecilia Skingsley") ///
	(line hawk_ind period if governor == "Henry Ohlsson") ///
	(line hawk_ind period if governor == "Anna Breman") ///
	, legend( order(1 "Martin Flodén" 2 "Per Jansson" 3 "Stefan Ingves" 4 "Lars E.O. Svensson" 5 "Kerstin af Jochnick" 6 "Cecilia Skingsley" 7 "Henry Ohlsson" 8 "Anna Breman")) ytitle("Hawkishness index") xtitle("Time") title("Hawkishness index of individual governors")

	* Merge with inflation time series
	preserve

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

	drop cpif_ind cpifxe_ind
	save "inf_tmp.dta", replace
	
	restore 
	
	merge m:1 year month using "inf_tmp.dta"
	keep if _merge == 3
	drop _merge 
	erase "inf_tmp.dta"

	
	collapse (mean) hawk_ind geo_ind cpif_ch, by(period)

	* Extracting the residuals of the index while controlling for inflation (put into equally sized bins)
	fastxtile inflation_bin = cpif_ch, n(5)
	reghdfe hawk_ind, a(inflation_bin) resid 
	rename _reghdfe_resid res_hawk

	*Proposing a simple absolute weighting based on distance from target inflation of the hawkishness index
	gen inf_dist = 1+abs(cpif_ch-2)

	gen hawk_ind_weighted = hawk_ind / inf_dist

	hawk_words = ['inflation','kpif','lön','prissättning',  'energi', 'målet', 'olj', 'råvaru', 'livsmedel', 'utbudsstörning','utbud', 'kostnad', 'kron','växelkurs'] #'växelkurs','el'
	dove_words = ['tillväxt','resursutnyttjande','sysselsättning','konjunktur', 'finansiella',  'bnp','skuldsättning','bolån','bostadsmarknad','räntekänslig', 'real', 'arbets','samhället' ] #'finans' 'skuld ,'belån'
	geo_words = ['geopolitisk', 'handelskonflikt','handelshinder','tullar', 'protektionis','osäkerhet']
	
	twoway (line res_hawk period, yaxis(1) ) (line hawk_ind period, yaxis(2) ), legend( order(1 "Res" 2 "Hawk_ind"))