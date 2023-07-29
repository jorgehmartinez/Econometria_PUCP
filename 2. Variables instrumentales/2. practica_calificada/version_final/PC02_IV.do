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
cd "C:\Users\lfigueroa\Documents\Ciencia_de_Datos\Econometría_Avanzada\PC Prácticas Calificadas\PC.02"

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


* 4. Estime la ecuación de primera etapa ¿Qué debemos ver en esta regresión? ¿Qué podría decir respecto de la correlación parcial existente entre educ y nearc4?
reg educ nearc4 exper
corr nearc4 educ


*5.Estime el modelo usando el estimador de Variables Instrumentales, usando nearc4 como un instrumento para la variable educ.
ivregress 2sls lwage (educ = nearc4)

*6. Testee la presencia de instrumentos débiles usando
*i) el estadístico F
estat firststage
* ii) el estadístico de Cragg y Donald (1993)
ivregress 2sls lwage (educ = nearc4)
predict resid, residuals
regress resid nearc4
scalar cragg_donald = _b[_cons]^2
* iii) las tablas de Stock y Yogo (2005) con respecto a la medida del test de Wald
ivregress 2sls lwage (educ = nearc4)
testnl _b[educ] = 0



*7. Use nearc2 con nearc4 como instrumentos para educ. Primero estime la primera etapa para educ y analice cuál de los dos instrumentos está más fuertemente relacionada parcialmente con educ. Después use el estimador de IV usando por separado nearc2 y nearc4 como instrumento para educ. Luego use el de 2SLS (incluyendo ambos instrumentos). Discuta sus resultados.  Verifique que el estimador 2SLS es válido.

* a) Hacemos la regresión de la variable 'edu' con las variables 'nearc2' y 'nearc4'.
reg educ nearc2 nearc4


* b) Luego utilizamos el estimador IV por separado.
ivreg lwage (educ = nearc2)
ivreg lwage (educ = nearc4)


* c) Ahora usamos el estimador IV 2SLS para ambos instrumentos.
ivregress 2sls lwage (educ = nearc2 nearc4), first



*8. Hemos asumido hasta ahora homoscedasticidad ¿Es razonable esto?¿Qué permite el estimador de GMM que no permite el de IV en 2 etapas bajo heterosk. Compare los resultados (del coeficiente educación) del estimador 2SLS con el del estimador GMM bajo heterocedasticidad
ivregress gmm lwage (educ = nearc2 nearc4), robust


*9
ivregress 2sls lwage black south c.exper##c.exper (educ=nearc4 nearc2), vce(robust)
estat overid

ivregress gmm lwage black south c.exper##c.exper (educ=nearc2 nearc4), vce(robust)
estat overid

*10
eststo, title("MCO"): reg lwage black south c.exper##c.exper educ, vce(robust)
eststo, title("IV"): ivregress 2sls lwage black south c.exper##c.exper (educ = nearc2 nearc4), vce(robust)
esttab, mtitle se
estat endogenous	

