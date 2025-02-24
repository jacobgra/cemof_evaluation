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