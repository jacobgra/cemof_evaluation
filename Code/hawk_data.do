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

	gen hawk_ind = hawk_sum / total
	gen dove_ind = dove_sum / total
	gen geo_ind = geo_sum / total

	collapse (mean) hawk_ind dove_ind geo_ind, by(period)

	twoway (line hawk_ind period, yaxis(1)) (line dove_ind period, yaxis(2)) 

	twoway (line geo_ind period, yaxis(1)) 





	hawk_words = ['inflation','kpif','lön','prissättning', 'växelkurs', 'energi', 'el ', 'olj', 'råvaru', 'livsmedel', 'utbudsstörning','utbud', 'kostnad']
    dove_words = ['tillväxt','resursutnyttjande','arbetslöshet','sysselsättning','konjunktur', 'finans', 'finansiella', 'bnp','skuld','belån','bostadsmarknad','räntekänslig' ]
	twoway ///
	(line energi period )