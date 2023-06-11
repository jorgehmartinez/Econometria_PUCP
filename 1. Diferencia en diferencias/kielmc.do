*******************************************************************************
**** 
**** 
**** Written by: Cristina Tello-Trillo
**** 
**** Workers' Compensation and Injury Duration: Evidence from a Natural Experiment AER 1995
*******************************************************************************

cd "D:\jorge\Documents\PSICOLOGÍA UNMSM\CURSOS\Diplomado PUCP\7. ECONOMETRÍA APLICADA\1. Diferencia en diferencias"
use "D:\jorge\Documents\PSICOLOGÍA UNMSM\CURSOS\Diplomado PUCP\7. ECONOMETRÍA APLICADA\1. Diferencia en diferencias\KIELMC.DTA", clear

des 

// by distant
tabulate year nearinc, sum(rprice) 

tab year if nearinc == 1, sum(rprice)
tab year if nearinc == 0, sum(rprice)

// No outliers with log
histogram dist if y81==1, saving(hist1, replace)
*gen ldurat=log(durat)
histogram ldist if y81==1, saving(hist2, replace)
graph combine hist1.gph hist2.gph, ycommon

****************************************
** DID model
****************************************
gen post_treatment=y81*nearinc

// g
reg rprice y81 nearinc post_treatment
est store reg1

// h
reg rprice y81 nearinc post_treatment intst land area rooms baths age
est store reg2

esttab reg1 reg2, star(* 0.1 ** 0.05 *** 0.01) r2 ar2

****************************************
** Dependent variable is now lrprice 
****************************************
	reg lrprice y81 nearinc post_treatment
	est store reg4

	reg lrprice y81 nearinc post_treatment intst land area rooms baths age
	est store reg5

	reg lrprice y81 nearinc post_treatment lintst lland larea rooms baths age
	est store reg6

	esttab reg4 reg5 reg6, star(* 0.1 ** 0.05 *** 0.01) r2
