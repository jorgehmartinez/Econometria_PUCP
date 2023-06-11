*******************************************************************************
**** 
**** 
**** Written by: Cristina Tello-Trillo
**** 
**** Workers' Compensation and Injury Duration: Evidence from a Natural Experiment AER 1995
*******************************************************************************

cd "D:\jorge\Documents\PSICOLOGÍA UNMSM\CURSOS\Diplomado PUCP\7. ECONOMETRÍA APLICADA\1. Diferencia en diferencias"

*use "H:UMD\PUCP\INJURY.DTA", clear
use "D:\jorge\Documents\PSICOLOGÍA UNMSM\CURSOS\Diplomado PUCP\7. ECONOMETRÍA APLICADA\1. Diferencia en diferencias\INJURY.DTA", clear

des 

// sort the data by highearn and afchnge

sort highearn afchnge
by highearn afchnge: sum durat
tabulate highearn afchnge, sum(durat) 

// by state 
tab highearn afchnge if ky==1, sum(durat)

// No outliers with log
histogram durat if ky==1, saving(hist1, replace)
gen ldurat=log(durat)
histogram ldurat if ky==1, saving(hist2, replace)
graph combine hist1.gph hist2.gph, ycommon

****************************************
** DID model
****************************************
gen post_treatment=afchnge*highearn

reg durat afchnge highearn post_treatment

****************************************
** Dependent variable is now ldurat 
****************************************
global controls_disability "male lprewage manuf construc head neck upextr trunk lowback lowextr occdis married lage ltotmed" 

* robust: use robust standard error 
reg ldurat afchnge highearn post_treatment $controls_disability, robust

reg ldurat afchnge highearn post_treatment $controls_disability if ky==1, robust
est store regky

reg ldurat afchnge highearn post_treatment $controls_disability ///
if mi==1, robust
est store regmi

esttab regky regmi, se mtitle("Kentucky" "Michigan")  star(* 0.1 ** 0.05 *** 0.01) // keep(afchnge highearn treated)
