*--------------------------------------  *                    		 
* QLAB
* Práctica calificada_IV
*--------------------------------------	 *
* Integrantes:
* -Leonel Figueroa (20105737)
* -Jorge Huanca Martinez (F1314997)
* -Yajaira Huerta (F1311690)
* -Afrania Palomino (20122733)
* -Meir Tintaya Orihuela (20098137)

*--------------------------------------	 *

clear all
/* Set working directory*/
cd "D:\jorge\Documents\PSICOLOGÍA UNMSM\CURSOS\Diplomado PUCP\7. ECONOMETRÍA APLICADA\2. Variables instrumentales\2. practica_calificada"

*--------------------------------------------------
* Strucuture of te log file name 
*--------------------------------------------------

global logfile_name "calificada_IV"

	cap log close
	local td: di %td_CY-N-D  date("$S_DATE", "DMY") 
	local td = trim("`td'")
	local td = subinstr("`td'"," ","_",.)
	local td = subinstr("`td'",":","",.)
	log using "${logfile_name}-`td'_1", text replace 
	local today "`c(current_time)'"
	local curdir "`c(pwd)'"
	local newn = c(N) + 1

****************************************************************************

use "card.dta"

* 1. Realice una descripción de las características de los individuos de la muestra. 
describe
summarize
tabulate black 
tabulate married
tabulate enroll
tabulate momdad14
tabulate sinmom14
tabulate nearc4


* 2. Regresione usando OLS el siguiente modelo en Stata 
* incluyendo edad
reg lwage educ c.exper##c.exper age black south smsa smsa66 reg661-reg668 

* sin incluir edad
reg lwage educ c.exper##c.exper black south smsa smsa66 reg661-reg668



