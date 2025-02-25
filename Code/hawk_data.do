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
	
	gen inf_interest = inflation/total
	keep if governor == "Martin Flodén"
	twoway ///
	(line inf_interest period )