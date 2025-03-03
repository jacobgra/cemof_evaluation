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

	gen ordsumma = hawk_sum + dove_sum 
	gen hawk_ind = hawk_sum / ordsumma
	gen geo_ind = geo_sum

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

	*Proposing a simple absolute weighting based on distance from target inflation of the hawkishness index
	gen inf_dist = 1+abs(cpif_ch-2)

	gen hawk_ind_weighted = hawk_ind / inf_dist

	twoway line hawk_ind period if governor == "Martin Flodén" || ///
		line hawk_ind period if governor == "Henry Ohlsson" || ///
		line hawk_ind period if governor == "Per Jansson" || ///
		line hawk_ind period if governor == "Kerstin af Jochnick" || ///
		line hawk_ind period if governor == "Cecilia Skingsley" || ///
		line hawk_ind period if governor == "Anna Breman" || ///
		line hawk_ind period if governor == "Eva Srejber" || ///
		line hawk_ind period if governor == "Lars Nyberg" || ///
		line hawk_ind period if governor == "Barbro Wickman-Parak" || ///
		line hawk_ind period if governor == "Svante Öberg" || ///
		line hawk_ind period if governor == "Lars Heikensten" || ///
		line hawk_ind period if governor == "Stefan Ingves" || ///
		line hawk_ind period if governor == "Villy Bergström" || ///
		line hawk_ind period if governor == "Urban Bäckström" || ///
		line hawk_ind period if governor == "Karin Sjövall" || ///
		line hawk_ind period if governor == "Kerstin Hessius" || ///
		line hawk_ind period if governor == "Lars Wohlin",  legend(order(1 "Martin Flodén" 2 "Henry Ohlsson" 3 "Per Jansson" 4 "Kerstin af Jochnick" 5 "Cecilia Skingsley" 6 "Anna Breman" 7 "Eva Srejber" 8 "Lars Nyberg" 9 "Barbro Wickman-Parak" 10 "Svante Öberg" 11 "Lars Heikensten" 12 "Stefan Ingves" 13 "Villy Bergström" 14 "Urban Bäckström" 15 "Karin Sjövall" 16 "Kerstin Hessius") ) ///
		title("Net Hawkishness Index of Riksbank Governors", size(medium)) ytitle("Net Hawkishness Index") xtitle("Period") ///
		legend(rows(4) pos(1) ring(0) col(1)) ///
		graphregion(color(white)) ///
		plotregion(color(white)) ///
		name(hawk_ind, replace) 

	hawk_words = ['inflation','kpif','lön','prissättning',  'energi', 'målet', 'olj', 'råvaru', 'livsmedel', 'utbudsstörning','utbud', 'kostnad', 'kron','växelkurs'] #'växelkurs','el'
	dove_words = ['tillväxt','resursutnyttjande','sysselsättning','konjunktur', 'finansiella',  'bnp','skuldsättning','bolån','bostadsmarknad','räntekänslig', 'real', 'arbets','samhället' ] #'finans' 'skuld ,'belån'
	geo_words = ['geopolitisk', 'handelskonflikt','handelshinder','tullar', 'protektionis','osäkerhet']
	
	twoway line hawk_ind period,yaxis(1) legend(order(1 "Hawkishness" ) )