/*******************************************************************************
                       PS10: Regression discontinuity

                          Universidad de San Andrés
                              Economía Aplicada
							       								2022							           
*******************************************************************************/

global main "G:\My Drive\Udesa\aplicada\tp\PS10\ps"
global output "$main/output"
global input "$main/input"

cd "$output"



/********************************************************************************
Si algun codigo falla, sugiero correr los siguientes codigos
** RDROBUST: net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
** RDDENSITY: net install rdlocrand, from(https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata) replace
** LPDENSITY: net install lpdensity, from(https://raw.githubusercontent.com/nppackages/lpdensity/master/stata) replace
** RDLOCRAND: net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
********************************************************************************/

**********************************
** 1. Generamos la variable demwon
**********************************

use "$input/data_elections.dta", clear

// Generating a variable with cut off of 0.5
gen demwon = vote_share_democrats - 0.5


// Generating the classical RD plot
* RD plot 
global y lne 
global x demwon
global covs unemplyd union urban veterans


**************************************************************
** 2. Grafiquen el tradicional gráfico de RD
**************************************************************

// Polinomio de grado 1
#delimit ;
	rdplot $y $x, 
				p(1)
				graph_options(graphregion(color(white) )
				xtitle(Proportion of votes)
				ytitle(Log FED expenditure in district)
				legend( pos(6) ));

	graph export "${output}/rd_plot_ply1.png", replace ;

// Polinomio de grado 2
	rdplot $y $x, 
				p(2)
				graph_options( graphregion( color( white ) )
				xtitle( Proportion of votes )
				ytitle( Log FED expenditure in district )
				legend( pos(6) ));

	graph export "${output}/rd_plot_ply2.png", replace ;
#delimit cr
// Aunque el polinomio de grado 2 parece ajustarse mejor, no veo que haya necesidad de 
// forzar la curva a un polinomio mas alto


**********************************
** 3. Falsification tests
**********************************

* Density discontinuity test
// We need to install lpdensity
global covs unemplyd union urban veterans

rddensity $x, plot graph_opt( xtitle(Proportion of votes) legend(off) )
graph export "${output}/discontinuity_test.png", replace 


* Placebo tests on pre-determined covariates
// We use the same polynomial degree for te plots
foreach var of global covs {
	rdrobust `var' $x
	rdplot `var' $x, p(1) graph_options( legend( pos(6) ) ///
									graphregion(color(white)  ) ///
								  xlabel(-0.4(0.40)1) ///
								  ytitle(`var') )
	graph export "${output}/placebo_`var'.png", replace 

}

// Generando una tabla de p values para cada test con las covariables
local num: list sizeof global(covs)
mat def pvals = J(`num',1,.)
local row = 1

foreach var of global covs {
    qui rdrobust `var' $x
    mat pvals[`row',1] = e(pv_rb)
    local row = `row'+1
	}
frmttable , statmat(pvals)

// Tabla en Latex
mat rownames pvals = "Unemployment" "Union" "Urban" "Veterans"
#delimit ;

  global pre_head_nv "\begin{table}[H]\centering 
          \begin{threeparttable} \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
           \caption{Tests de Falsificacion - Covariables}" ;

	  esttab matrix(pvals, fmt( 2 ) ) using "${output}/table_3.tex" , replace
	        collabels(none)  
	        delim("&")    
	        noobs  
	        mtitles( "P Value" ) 
	        prehead( "${pre_head_nv}" "\label{pvalues_table}" 
	          "\begin{tabular}{l*{2}c}" \hline \hline ) 
	        postfoot(\hline \hline  \end{tabular}  
	          \begin{tablenotes} 
	          \begin{footnotesize} 
	          ${note_nv} 
	          \end{footnotesize} 
	          "\end{tablenotes} \end{threeparttable} \end{table}") ;
	#delimit cr


***********************************
* 4. Con y Sin Variables de Control 
***********************************

// Matrix para almacenar bandwidths

* Comparación de resultados con y sin covariables
rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) p(1) 
est sto reg_con

rdrobust $y $x, masspoints(off) stdvars(on) p(1) 
est sto reg_sin

		#delimit ;
		 global pre_head_nv "\begin{table}[H]\centering 
          \begin{threeparttable} \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
           \caption{Estimaciones Con/Sin Covariables}" ;

	  esttab reg_sin reg_con using "${output}/table_4.tex" , replace ///
	        eqlabels( none ) nostar nobaselevels 
	        cells(b(label(coef.) star fmt(%11.4f) ) se( par fmt(%11.4f) ) ) nonote 
	        starlevels( \sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01 )
	        s( N N_l N_r N_h_l N_h_r h_l h_r, 
	        	label( "Obs" 
	        		"All Obs Left" "All Obs Right" 
	        		"Effec. Obs Left" "Effec. Obs Right" 
	        		"Bandwidth Left" "Bandwidth Right" 
	        	 ) 
	        	fmt( 0 0 0 0 0 3 3 ) ) /// 
	        collabels(none)  
	        delim("&")    
	        noobs 
	        keep( RD_Estimate ) 
	        varlabels( RD_Estimate "Tratamiento" )
	        mtitles( "Sin Covariables" "Con Covariables"  ) 
	        prehead( "${pre_head_nv}" "\label{comparacion cut off}" 
	          "\begin{tabular}{l*{2}c}" \hline \hline ) 
	        postfoot(\hline \hline "\multicolumn{4}{l}{\footnotesize Standard errors in parentheses}\\" 
	            "\multicolumn{3}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\" \end{tabular}  
	          \begin{tablenotes} 
	          \begin{footnotesize} 
	          ${note_nv} 
	          \end{footnotesize} 
	          "\end{tablenotes} \end{threeparttable} \end{table}") ;
	#delimit cr

******************************************************
* 5. Estimacion del modelo con variables de control
******************************************************

	* Repetición de la estimación 3 veces
	local bands 0.025 0.15 0.25
	local i = 1
	foreach var of local bands{
		rdrobust $y $x, covs($covs) h(`var') masspoints(off) stdvars(on) p(1)
		est sto reg_`i'
		local i = `i' + 1
	}


		#delimit ;
		 global pre_head_nv "\begin{table}[H]\centering  \fontsize{10}{4}\selectfont 
          \begin{threeparttable} \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
           \caption{Estimaciones Aumentando el BandWidth}" ;

	  esttab reg_1 reg_2 reg_3 using "${output}/table_5.tex" , replace ///
	        eqlabels( none )  nostar nobaselevels 
	        cells(b(label(coef.) star fmt(%11.4f) ) se( par fmt(%11.4f) ) ) nonote 
	        starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01)
	        s( N N_l N_r N_h_l N_h_r h_l h_r, 
	        	label( "Obs" 
	        		"All Obs Left" "All Obs Right" 
	        		"Effec. Obs Left" "Effec. Obs Right" 
	        		"Bandwidth Left" "Bandwidth Right" 
	        	 ) 
	        	fmt( 0 0 0 0 0 3 3 ) ) 
	        collabels(none)  
	        delim("&")    
	        noobs 
	        keep( RD_Estimate ) 
	        varlabels( RD_Estimate "Tratamiento" )
	        mtitles( "Bandwidth 0.025" "Bandwidth 0.15" "Bandwidth 0.25" ) 
	        prehead( "${pre_head_nv}" "\label{comparacion cut off}" 
	          "\begin{tabular}{l*{3}c}" \hline \hline ) 
	        postfoot(\hline \hline "\multicolumn{4}{l}{\footnotesize Standard errors in parentheses}\\" 
	            "\multicolumn{5}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\" \end{tabular}  
	          \begin{tablenotes} 
	          \begin{footnotesize} 
	          ${note_nv} 
	          \end{footnotesize} 
	          "\end{tablenotes} \end{threeparttable} \end{table}") ;
	#delimit cr


**************************************************************
* 6. Cambiando el cut off de referencia por cut off falsos
**************************************************************


	// Real
	use "$input/data_elections.dta", clear

	// Generating a variable with cut off of 0.5
	gen demwon = vote_share_democrats - 0.5
	// Generating the classical RD plot
	* RD plot 
	global y lne 
	global x demwon
	global covs unemplyd union urban veterans
	rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) p(1)
	est sto reg_50


	// Cut off de 40
	use "$input/data_elections.dta", clear

	// Generating a variable with cut off of 0.5
	gen demwon = vote_share_democrats - 0.4
	// Generating the classical RD plot
	* RD plot 
	global y lne 
	global x demwon
	global covs unemplyd union urban veterans
	rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) p(1)
	est sto reg_40

	// Cut off de 60
	use "$input/data_elections.dta", clear

	// Generating a variable with cut off of 0.5
	gen demwon = vote_share_democrats - 0.6
	// Generating the classical RD plot
	* RD plot 
	global y lne 
	global x demwon
	global covs unemplyd union urban veterans
	rdrobust $y $x, covs($covs) masspoints(off) stdvars(on) p(1)
	est sto reg_60

	// Tabla de comparacion de los tres resultados


	#delimit ;
	global pre_head_nv "\begin{table}[H]\centering 
          \begin{threeparttable} \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
           \caption{Estimaciones Falseando el Cut-Off}" ;

	  esttab reg_50 reg_40 reg_60 using "${output}/table_6.tex" , replace ///
	        eqlabels( none )  nostar nobaselevels 
	        cells(b(label(coef.) star fmt(%11.4f) ) se( par fmt(%11.4f) ) ) nonote 
	        starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01)
	        s( N N_l N_r N_h_l N_h_r h_l h_r, 
	        	label( "Obs" 
	        		"All Obs Left" "All Obs Right" 
	        		"Effec. Obs Left" "Effec. Obs Right" 
	        		"Bandwidth Left" "Bandwidth Right" 
	        	 ) 
	        	fmt( 0 0 0 0 0 3 3 ) ) 
	        collabels(none)  
	        delim("&")    
	        noobs 
	        keep( RD_Estimate ) 
	        varlabels( RD_Estimate "Tratamiento" )
	        mtitles( "Cut off Real (50)" "Cut off Fake (40)" "Cut off Real (60)" ) 
	        prehead( "${pre_head_nv}" "\label{comparacion cut off}" 
	          "\begin{tabular}{l*{3}c}" \hline \hline ) 
	        postfoot(\hline \hline "\multicolumn{4}{l}{\footnotesize Standard errors in parentheses}\\" 
	            "\multicolumn{5}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\" \end{tabular}  
	          \begin{tablenotes} 
	          \begin{footnotesize} 
	          ${note_nv} 
	          \end{footnotesize} 
	          "\end{tablenotes} \end{threeparttable} \end{table}") ;
	#delimit cr


***************************************
* 7. Local Randomization Approach
***************************************
use "$input/data_elections.dta", clear

// Generating a variable with cut off of 0.5
gen demwon = vote_share_democrats - 0.5
// Generating the classical RD plot
* RD plot 
global y lne 
global x demwon
global covs unemplyd union urban veterans


#delimit ;
	rdwinselect $x $covs, wmin(0.05) 
		wstep(0.01) 
		kernel(triangular) 
		nwindows(20) 
		seed(444) plot 
		graph_options( xtitle(Half window length) 
			ytitle(Minimum p-value across all covariates) 
			graphregion(color(white)) 
			name(windows, replace))  ;

	graph export "${output}/min_pval.png", replace 
#delimit cr

* Randomization inference

local  w =  0.180
rdrandinf $y $x, wl(-`w') wr(`w') reps(1000) seed(444)


