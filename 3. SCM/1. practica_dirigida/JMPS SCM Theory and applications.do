*Class JMPS
cd "E:\Mis Hojas\Biblioteca\Cursos Académicos\Cursos Dictados\PUCP\QLab\Clase SCM"

*A) Overview of the command
use synth_smoking.dta , clear
xtset state year, yearly

numlabel, add

/*
T0 and j=1,...,J+1
	trunit(3)									: the unit affected by the intervention is unit no 3 (California). Since no counit() is specified, the donor pool defaults to the control units 1,2,4,5,...,39 (i.e.the other 38 states in the dataset).  
	trperiod(1989)								: the FIRST year of the treatment
	
Model
	Since NO xperiod() is provided, the predictor variables for which no variable specific time period is specified (lnincome retprice age15to24) are averaged over the entire pre-intervention period up to the year of the intervention (1970,1981,...,1988).  
	cigsale(1988) cigsale(1980) cigsale(1975)	: we include in X the observed values of cigsale in those 3 years 
	beer(1984(1)1988)							: we include in X the average of beer taking only 1984, 1985, 1986, 1987 and 1988
	lnincome, retprice and age15to24			: we include in X the average of lnincome, retprice and age15to24 for the whole pre-treatment period (1970 to 1988)
*/
synth cigsale cigsale(1988) cigsale(1980) cigsale(1975) beer(1984(1)1988) lnincome retprice age15to24, trunit(3) trperiod(1989) fig

/*
T0 and j=1,...,J+1
	trunit(3)									: the unit affected by the intervention is unit no 3 (California). Since no counit() is specified, the donor pool defaults to the control units 1,2,4,5,...,39 (i.e.the other 38 states in the dataset).  
	trperiod(1989)								: the FIRST year of the treatment

Model
	Since NO xperiod() is provided, the predictor variables for which no variable specific time period is specified (beer, retprice and age15to24) are averaged over the entire pre-intervention period up to the year of the intervention (1970,1981,...,1988).  
	cigsale(1988 1980 1975)						: we include in X the average of cigsale taking only 1998, 1980 and 1975. This is DIFFERENT from cigsale(1988) cigsale(1980) cigsale(1975)
	lnincome(1980 1985)							: we include in X the average of lnincome taking only 1980 and 1985. This is DIFFERENT from lnincome(1980) lnincome(1985)	
	beer										: we include in X the average of beer for the whole pre-treatment period (1970 to 1988).  Since no data is available for beer prior to 1984, synth will inform the user that there is missing data for this variable and that the missing values are ignored in the averaging. 
	retprice and age15to24						: we include in X the average of retprice and age15to24 for the whole pre-treatment period (1970 to 1988)
*/
synth cigsale cigsale(1988 1980 1975) lnincome(1980 1985) beer retprice age15to24, trunit(3) trperiod(1989) fig

/*
T0 and j=1,...,J+1
	trunit(33)									: the unit affected by the intervention is unit no 33. Since counit(1(1)20) is specified, the donor pool is restricted to ONLY states no 1,2,...,20. NOTE HOW THE STATE NUMBER 33, THE TREATED, DOES NOT APPEAR HERE
	trperiod(1989)								: the FIRST year of the treatment
	resultsperiod(1970(1)1990)					: results are obtained for the 1970,1971,...,1990 period. 
	
Model
	Since NO xperiod() is provided, the predictor variables for which no variable specific time period is specified (retprice and age15to24) are averaged over the entire pre-intervention period up to the year of the intervention (1970,1981,...,1988).  
	cigsale(1970 1979)							: we include in X the average of cigsale taking only 1970 and 1979. This is DIFFERENT from cigsale(1970) cigsale(1979)
	retprice and age15to24						: we include in X the average of retprice and age15to24 for the whole pre-treatment period (1970 to 1988)
*/
synth cigsale cigsale(1970 1979) retprice age15to24, trunit(33) counit(1(1)20) trperiod(1980) resultsperiod(1970(1)1990) fig
/*
Note the equivalence of this latter with
*/
preserve
keep if inrange(state, 1, 20) | state==33
synth cigsale cigsale(1970 1979) retprice age15to24, trunit(33) trperiod(1980) resultsperiod(1970(1)1990) fig
restore

/*
Same as before but keep(resout) will save a dataset named resout.dta in the current Stata working directory 
*/
synth cigsale retprice cigsale(1970 1979), trunit(33) counit(1(1)20) trperiod(1980) resultsperiod(1970(1)1990) fig keep(resout)
  
/*
nested											: typically produces a better fit at the expense of additional computing time. Alternatively, the user can also specified the allopt option which can improve the fit even further and requires yet more computing time. 
*/
synth cigsale cigsale(1975 1988 1980) beer lnincome retprice age15to24, trunit(3) trperiod(1989) xperiod(1980(1)1988) nested fig


*B) Replication of the paper (CHECK THIS ALONGSIDE THE PAPER)
cls
use synth_smoking.dta , clear
xtset state year

//Figure 1
preserve
gen group=(state==3)
tab state group

collapse (mean) cigsale, by(group year)
quietly: reshape wide cigsale, i(year) j(group)

tsline cigsale0 cigsale1, yscale(range(0 140)) xline(1989)
restore

//The synth command
synth cigsale lnincome age15to24 retprice beer(1984(1)1988) cigsale(1988) cigsale(1980) cigsale(1975),  ///
trunit(3) trperiod(1989) ///
xperiod(1980(1)1988) resultsperiod(1970(1)2000) ///
nested fig


//Table 2
matrix list e(W_weights)


//Table 1
///table [., 1..2]
matrix list e(X_balance)

	///table[., 1]
	preserve
	keep if state==3									//this column takes information of ONLY California

	foreach var of varlist lnincome age15to24 retprice {
		replace `var'=. if !inrange(year, 1980, 1988)	//because these variables are averages over 1980 and 1988 via xperiod(1980(1)1988), we set the other values to missing
	}
	replace beer=. if !inrange(year, 1984, 1988)		//because only this variable is averaged over 1984 and 1988 via beer(1984(1)1988), we set the other values to missing
	foreach num of numlist 1975 1980 1988 {
		gen cigsale_`num'=cigsale if year==`num'		//because this variable takes the values in 1988, 1980 and 1975 via cigsale(1988) cigsale(1980) cigsale(1975), we create dummies that only take the value in this year
	}

	collapse (mean) lnincome age15to24 retprice beer cigsale_*	//we take the averages
	list
	restore

	///table[., 2]
	matrix list e(W_weights), format(%7.3fc)
	preserve
	drop if state==3									//this column takes information of the js in DP only (i.e. without California) and uses a weighted average using the Ws*

	gen weight=.
	replace weight=.145 if state==4 	//Colorado        
	replace weight=.058	if state==5  	//Connecticut 
	replace weight=.217	if state==19 	//Montana          
	replace weight=.238	if state==21 	//Nevada  
	replace weight=.342 if state==34 	//Utah  
	replace weight=0 if missing(weight)

	foreach var of varlist lnincome age15to24 retprice {
		replace `var'=. if !inrange(year, 1980, 1988)	//because these variables are averages over 1980 and 1988 via xperiod(1980(1)1988), we set the other values to missing
	}
	replace beer=. if !inrange(year, 1984, 1988)		//because only this variable is averaged over 1984 and 1988 via beer(1984(1)1988), we set the other values to missing
	foreach num of numlist 1975 1980 1988 {
		gen cigsale_`num'=cigsale if year==`num'
	}

	collapse (mean) lnincome age15to24 retprice beer cigsale_* [w=weight]
	list
	restore

///table[., 3]
preserve
drop if state==3										//this column takes information of the js in DP only (i.e. without California) BUT uses a simple average 

foreach var of varlist lnincome age15to24 retprice {
	replace `var'=. if !inrange(year, 1980, 1988)
}
replace beer=. if !inrange(year, 1984, 1988)
foreach num of numlist 1975 1980 1988 {
	gen cigsale_`num'=cigsale if year==`num'
}

collapse (mean) lnincome age15to24 retprice beer cigsale_*
list
restore


//Figure 2
matrix list e(Y_treated)
br state year cigsale if state==3 & inrange(year, 1970, 2000)

matrix list e(Y_synthetic)
preserve
keep if state!=3 & year==1970
br state year cigsale
gen weight=.
replace weight=.147 if state==4 	//Colorado        
replace weight=.059	if state==5  	//Connecticut 
replace weight=.205	if state==19 	//Montana          
replace weight=.242	if state==21 	//Nevada  
replace weight=.346 if state==34 	//Utah  
replace weight=0 if missing(weight)
gen cigsale_sc=weight*cigsale
sum cigsale_sc
display r(sum)
restore

preserve
keep state year cigsale
keep if state==3
rename cigsale cigsale_cal

matrix cigsale_scm=e(Y_synthetic)
svmat cigsale_scm
list

tsline cigsale_cal cigsale_scm, yscale(range(0 140))  xline(1989)

//Figure 3
gen te=cigsale_cal - cigsale_scm

tsline te, ylabel(-30(10)30) yscale(range(-30 30)) xline(1989) yline(0)
restore


//Figure 4
macro drop rmspe_names synth_names
levelsof state, local(states_codes_list)
local i=1
foreach state_code of local states_codes_list {
    display _n(1) as result "State `state_code' (iteration `i')"
	
	quietly: synth cigsale lnincome age15to24 retprice beer(1984(1)1988) cigsale(1975) cigsale(1980) cigsale(1988), ///
	trunit(`state_code') trperiod(1989) /*nested*/ ///
	xperiod(1980(1)1988) resultsperiod(1970(1)2000) /*keep(synth_`state_code'.dta) replace*/
    
	if `i'==1 	{	//for the first iteration, it just creates the vectors separately
		matrix rmspe 	= e(RMSPE)
		matrix y_synth 	= e(Y_synthetic)
		matrix y_obs   	= e(Y_treated)
	}
	else 	{		//for the next iterations, we put the vectors (separately) next to the previous ones
	    matrix rmspe 	= rmspe \ e(RMSPE)
		matrix y_synth 	= y_synth, e(Y_synthetic)	
		matrix y_obs 	= y_obs, e(Y_treated)	
	}
	global rmspe_names ${rmspe_names} `state_code'
	global synth_names ${synth_names} "synth_`state_code'"
	
	matrix list rmspe		//just to see how the accumulation process works, comment out once you actually understand it
	matrix list y_synth
	matrix list y_obs
	more
	
	local ++i
}
mat colnames rmspe = "RMSPE"
mat rownames rmspe = ${rmspe_names}
matrix list rmspe

mat colnames y_synth = ${synth_names}
matrix list y_synth
mat colnames y_obs = ${synth_names}
matrix list y_obs

matrix te= y_obs - y_synth

preserve
drop _all
svmat2 te, names(col) rnames(year)
renvars synth_1-synth_39, subst("synth" "te")
destring year, replace
order year, first

tsset year
#delimit;
graph twoway 
(tsline te_?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_1?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_2?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))			
(tsline te_3?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))			
(tsline te_3, lcolor(red) lpattern(solid) lwidth(medthick)),
ytitle("") ylabel(, angle(0) format(%5.2fc) labsize(medsmall) nogrid) yline(0, lpattern(solid) lcolor(black))
xtitle("") xlabel(1970(5)2000, labsize(medsmall) nogrid) xmtick(1970(1)2000) 
xline(1989, lwidth(medthick) lcolor(red) lpattern(dash))
subtitle("Figure 4", tstyle(subheading) margin(b=2))
legend(off) 
graphregion(fcolor(white)) plotregion(margin(zero) lcolor(black));
#delimit cr
/*
#delimit;
graph twoway 
(tsline te_1-te_2, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_4-te_12 te_14-te_20, lcolor(gs12 ..) lpattern(solid) lwidth(thin))	//we drop manually (te_13) 
(tsline te_21 te_23-te_39, lcolor(gs12 ..) lpattern(solid) lwidth(thin))			//we drop manually NH (te_22) as mentioned in ABadie et al. (2010)
(tsline te_3, lcolor(red) lpattern(solid) lwidth(medthick)),
ytitle("") ylabel(, angle(0) format(%5.2fc) labsize(medsmall) nogrid) yline(0, lpattern(solid) lcolor(black))
xtitle("") xlabel(1970(5)2000, labsize(medsmall) nogrid) xmtick(1970(1)2000) xscale(range(1969.5 2000.5))
xline(1989, lwidth(medthick) lcolor(red) lpattern(dash))
subtitle("Figure 4", tstyle(subheading) margin(b=2))
legend(off) 
graphregion(fcolor(white)) plotregion(margin(zero) lcolor(black))
/*nodraw*/;
#delimit cr
*/
restore
		
preserve
clear
quietly: svmat2 rmspe, rnames(state)
rename rmspe1 rmspe_
*matrix drop rmspe 

quietly: save "Placebos in space rmspe.dta", replace	
restore

preserve
drop _all
svmat2 te, names(col) rnames(year)
renvars synth_1-synth_39, subst("synth" "te")
destring year, replace

quietly: reshape long te_@, i(year) j(state) string
merge m:1 state using "Placebos in space rmspe.dta", assert(3) nogen noreport
erase "Placebos in space rmspe.dta"

sort state year	

gen foo=rmspe_ if state=="3"		//the treated state
egen rmspe_treated_=mean(foo)
drop foo
gen rmspe_ratio_ = rmspe_ / rmspe_treated
drop rmspe_ rmspe_treated_

table state, contents(mean rmspe_ratio)	

quietly: save "Placebos in space.dta", replace
restore


//Figure 5
preserve
use "Placebos in space.dta" if rmspe_ratio_<=20, clear		//<- filtering those above 20
table state,  statistic(mean rmspe_ratio)
quietly: tab state
return list
drop rmspe_ratio_

quietly: reshape wide te_@, i(year) j(state) string
order year te_*

tsset year
#delimit;
graph twoway 
(tsline te_?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_1?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_2?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))		
(tsline te_3?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))		
(tsline te_3, lcolor(red) lpattern(solid) lwidth(medthick)),
ytitle("") ylabel(, angle(0) format(%5.0fc) labsize(medsmall) nogrid) yline(0, lpattern(solid) lcolor(black))
xtitle("") xlabel(1970(5)2000, labsize(medsmall) nogrid) xmtick(1970(1)2000)
xline(1989, lwidth(medthick) lcolor(red) lpattern(dash))
subtitle("Figure 5: Figure 4 Excluding those with RMSPE > 20x California", tstyle(subheading) margin(b=2))
legend(off) 
graphregion(fcolor(white)) plotregion(margin(zero) lcolor(black));
#delimit cr
restore


//Figure 6
preserve
use "Placebos in space.dta" if rmspe_ratio_<=5, clear	//<- filtering those above 5
table state,  statistic(mean rmspe_ratio)
quietly: tab state
return list
drop rmspe_ratio_

quietly: reshape wide te_@, i(year) j(state) string
order year te_*

tsset year
#delimit;
graph twoway 
(tsline te_?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_1?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_2?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))			
(tsline te_3?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))			
(tsline te_3, lcolor(red) lpattern(solid) lwidth(medthick)),
ytitle("") ylabel(-30(10)30, angle(0) format(%5.0fc) labsize(medsmall) nogrid) yscale(range(-35 35)) yline(0, lpattern(solid) lcolor(black))
xtitle("") xlabel(1970(5)2000, labsize(medsmall) nogrid) xmtick(1970(1)2000) 
xline(1989, lwidth(medthick) lcolor(red) lpattern(dash))
subtitle("Figure 6: Figure 4 Excluding those with RMSPE > 5x California", tstyle(subheading) margin(b=2))
legend(off) 
graphregion(fcolor(white)) plotregion(margin(zero) lcolor(black));
#delimit cr
restore


//Figure 7
preserve
use "Placebos in space.dta" if rmspe_ratio_<=2, clear
table state,  statistic(mean rmspe_ratio)
quietly: tab state
return list
drop rmspe_ratio_

quietly: reshape wide te_@, i(year) j(state) string
order year te_*

tsset year
#delimit;
graph twoway 
(tsline te_?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_1?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))
(tsline te_2?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))			
(tsline te_3?, lcolor(gs12 ..) lpattern(solid) lwidth(thin))			
(tsline te_3, lcolor(red) lpattern(solid) lwidth(medthick)),
ytitle("") ylabel(-30(10)30, angle(0) format(%5.0fc) labsize(medsmall) nogrid) yscale(range(-35 35)) yline(0, lpattern(solid) lcolor(black))
xtitle("") xlabel(1970(5)2000, labsize(medsmall) nogrid) xmtick(1970(1)2000) 
xline(1989, lwidth(medthick) lcolor(red) lpattern(dash))
subtitle("Figure 7: Figure 4 Excluding those with RMSPE > 2x California", tstyle(subheading) margin(b=2))
legend(off) 
graphregion(fcolor(white)) plotregion(margin(zero) lcolor(black));
#delimit cr
restore


//Figure 8
preserve
clear
svmat2 te, names(col) rnames(year)
renvars synth_1-synth_39, subst("synth" "te")
destring year, replace

quietly: reshape long te_@, i(year) j(state) string
sort state year 

gen te2			=te^2
gen te2_pre		=te2 if year<1989
gen te2_post	=te2 if year>=1989 
collapse (mean) te2_pre te2_post, by(state)
	
gen ratio = sqrt(te2_post)/ sqrt(te2_pre)
gsort -ratio 
list 

gen rank=_n
gen p=rank/39

gen treated=(state=="3")
separate ratio, by(treated)

labmask rank, val(state)
#delimit;
graph twoway 
(bar ratio1 rank, base(0) color(red))
(bar ratio0 rank, base(0) color(gs12)),
ytitle("") ylabel(, angle(0) format(%5.2fc) labsize(medium) nogrid)
xtitle("") xlabel(1(1)38, labsize(medium) angle(90) nogrid notick valuelabel)
title("Figure 8: ratios", tstyle(heading) margin(b=2))
legend(off) 
graphregion(fcolor(white)) plotregion(margin(zero) lcolor(black));
#delimit cr
restore

exit
