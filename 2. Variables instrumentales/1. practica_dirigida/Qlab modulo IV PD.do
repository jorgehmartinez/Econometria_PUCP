*--------------------------------------  *                    		 
*QLAB
* Endogeneidad y Variables Instrumentales
*Docente: Juan Manuel del Pozo Segura
*Junio 2023
*--------------------------------------	 *
cls
global PD3 "E:\Mis Hojas\Biblioteca\Cursos Académicos\Cursos Dictados\PUCP\QLab\Clase IV\PD"

*ssc install ivreg

**# 1)Efecto de college sobre register
**##i)	
use "$PD3\murnane10.dta", clear

sum register college
tab register college

reg register college

**##ii)	
ivregress 2sls register (college = distance), first


**##iii) 
ivreg2 register black hispanic otherrace (college = distance), first


**##iv)	
gen distxblack 		= distance*black
gen distxhispanic 	= distance*hispanic
gen distxotherrace 	= distance*otherrace

gen collegexblack 	= college*black
gen collegexhispanic = college*hispanic
gen collegexotherrace = college*otherrace

ivreg2 register black hispanic otherrace ///
	(college collegexblack collegexhispanic collegexotherrace = ///
	distance distxblack distxhispanic distxotherrace), first
test collegexblack collegexhispanic collegexotherrace


**#2)	Los retornos a la educación
**###i)	
use "$PD3\card.dta", clear

sum lwage 
reg lwage educ

**###ii) 
ivreg2 lwage (educ=nearc2), first

**###iii) 
ivreg2 lwage (educ=nearc4), first

**###iv) 
ivreg2 lwage black south c.exper##c.exper (educ=nearc4), first

**###v) 
ivreg2 lwage black south c.exper##c.exper (educ=nearc4), first robust
ivreg2 lwage black south c.exper##c.exper (educ=libcrd14), first robust
ivreg2 lwage black south c.exper##c.exper (educ=nearc4 libcrd14), first robust

**###vi) 
ivreg2 lwage black south c.exper##c.exper (educ=nearc4 libcrd14),  
ivreg2 lwage black south c.exper##c.exper (educ=nearc4 libcrd14),  gmm2s

ivreg2 lwage black south c.exper##c.exper (educ=nearc4 libcrd14), robust gmm2s


**##3) Tests de exogeneidad y sobreidentificación
**###i) 
use "$PD3\murnane10.dta", clear

estimates clear
eststo, title("MCO"): reg register black hispanic otherrace college, vce(robust)
*ivreg2 register black hispanic otherrace (college = distance), first
eststo, title("IV"): ivregress 2sls register black hispanic otherrace (college=distance), vce(robust)
esttab, mtitle se
estat endogenous	

use "$PD3\card.dta", clear

estimates clear
*ivreg2 lwage black south c.exper##c.exper (educ=nearc4 libcrd14),  
eststo, title("MCO"): reg lwage black south c.exper##c.exper educ, vce(robust)
*ivreg2 register black hispanic otherrace (college = distance), first
eststo, title("IV"): ivregress 2sls lwage black south c.exper##c.exper (educ=nearc4 libcrd14), vce(robust)
esttab, mtitle se
estat endogenous	


**###ii) 
use "$PD3\card.dta", clear

*ivregress 2sls lwage black south c.exper##c.exper (educ=nearc4 libcrd14), vce(robust)
*estat overid
ivreg2 lwage black south c.exper##c.exper (educ=nearc4 libcrd14), robust

*ivregress gmm lwage black south c.exper##c.exper (educ=nearc4 libcrd14), vce(robust)
*estat overid
ivreg2 lwage black south c.exper##c.exper (educ=nearc4 libcrd14), gmm2s robust


ivregress gmm lwage black south c.exper##c.exper (educ=fatheduc motheduc), vce(robust)
estat overid




exit
