
/********************
Lalive (2008)
*********************/
clear all
cls
set more off


cd "C:\Users\Anzony\Documents\GitHub\Advanced_Applied_Econometrics_QLAB_PUCP_2022_I\RD\Data\lalive"


*If not already done, the following packages must be installed:
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata)
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata)
// ssc uninstall st0366


use releaseData, clear
global controles "marr single educ_med educ_hi foreign rr lwage_ljob previous_experience white_collar landw versorg nahrung textil holzind elmasch andfabr bau gasthand verkehr dienstl"


/*----------------------
TABLE 1
-----------------------*/

/*Table 1 reports key background statistics on the 
job seekers entering unemployment from a job in 
the nonsteel sector in the time during REBP (8/1989–7/1991), 
by gender, age and region of residence*/


*Column 1

*A. MEN
estpost tabstat age db marr bau /// 
	if tr==1 & inrange(age, 50, 54) & /// 
	female == 0 & period == 1, listwise /// 
    statistics(mean ) columns(statistics)
est store col1_A

*B. WOMEN
estpost tabstat age db marr bau /// 
	if tr==1 & inrange(age, 50, 54) & /// 
	female == 1 & period == 1, listwise /// 
    statistics(mean) columns(statistics)
est store col1_B

*Column 2

*A. MEN
estpost tabstat age db marr bau ///
	if tr==1 & inrange(age, 46, 50) & /// 
	female == 0 & period == 1, listwise /// 
    statistics(mean) columns(statistics)
est store col2_A

*B. WOMEN
estpost tabstat age db marr bau ///
	if tr==1 & inrange(age, 46, 50) & ///
	female == 1 & period == 1, listwise /// 
    statistics(mean) columns(statistics)
est store col2_B

*Column 3

*A. MEN
estpost tabstat age db marr bau ///
	if tr==0 & inrange(age, 50, 54) & ///
	female == 0 & period == 1, listwise /// 
    statistics(mean) columns(statistics)
est store col3_A

*B. WOMEN
estpost tabstat age db marr bau ///
	if tr==0 & inrange(age, 50, 54) & ///
	female == 1 & period == 1, listwise /// 
    statistics(mean) columns(statistics)
est store col3_B


/// Table 1
#delimit ;

	global note_nv "Source: Own calculations, based on ASSD." ;

	global pre_head_nv "\begin{table}[htbp]\centering  
			\begin{threeparttable} 
			\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
			\caption{Selected descriptive statistics (means)}" ;

	esttab col1_A col2_A col3_A
		using "table1.tex" , replace 
		eqlabels( none )  nostar nobaselevels 
		cells("mean" )
		stats( N, 
			label( "Number of spells" ) 
			fmt( 0 ) ) 
		collabels(none)  
		delim("&")    
		noobs  
		varlabels( age "Age (years)" 
			db "Distance to border (minutes)"
			marr "Married (share)" 
			bau "Construction (share)" )
		mtitles( "\shortstack{Treated region\\50–53 years}" 
			"\shortstack{Treated region\\46–49 years}" 
			"\shortstack{Treated region\\50–53 years}" ) 
		refcat( age "\Gape[0.25cm][0.25cm]{ 
	            \underline{ Panel A.\textbf{ 
	            \textit{ Men } } } }" 
	            , nolabel)
		prehead( "${pre_head_nv}" "\label{means}" 
			"\begin{tabular}{l*{3}{c}}" \hline \hline) 
		posthead(\hline) 
		postfoot( "" ) ;


	esttab col1_B col2_B col3_B
		using "table1.tex" , append 
		eqlabels( none )  nostar nobaselevels 
		cells("mean" )
		stats( N , 
			label( "Number of spells" ) 
			fmt( 0 ) ) 
		collabels(none)  
		delim("&")    
		noobs  
		varlabels( age "Age (years)" 
			db "Distance to border (minutes)"
			marr "Married (share)" 
			bau "Construction (share)" )
		mtitles( "\shortstack{Treated region\\50–53 years}" 
			"\shortstack{Treated region\\46–49 years}" 
			"\shortstack{Treated region\\50–53 years}" ) 
		refcat( age "\Gape[0.25cm][0.25cm]{ 
	            \underline{ Panel B.\textbf{ 
	            \textit{ Women } } } }" 
	            , nolabel)
		prehead( \hline )
		postfoot(\hline \hline \end{tabular}  
			\begin{tablenotes} 
			\begin{footnotesize} 
			${note_nv} 
			\end{footnotesize} 
			"\end{tablenotes} \end{threeparttable} \end{table}") ;

#delimit cr


/*----------------------
FIGURE 2
-----------------------*/

/*Fig. 2 reports average unemployment duration by age at 
entry into unemployment for each age quarter from 46 
years and 1 quarter to 53 years and 4 quarters*/
// Change in employment based on 
rdplot unemployment_duration age if female==0 & tr==1 & period == 1, c(50) p(2) ///
       graph_options(title(Figure 2) ///
                           ytitle(umemployment duration) ///
                           xtitle(age))


/*Control individuals remain unemployed for 13 weeks on average. In contrast, average unemployment duration exceeds 26 weeks in almost all age cells for individuals aged 50 years or older.

This suggests that there is a strong effect of REBP on the average
duration of unemployment spells.*/


/*----------------------
FIGURE 3
-----------------------*/

/*Fig. 3 identifies the effect of REBP by comparing individuals living on both sides of the border between treated and control regions*/

rdplot unemployment_duration db if female==0  & period == 1, c(0) p(1) ///
       graph_options(title(Figure 3) ///
                           ytitle(umemployment duration) ///
                           xtitle(distance to border))

/*that REBP strongly increases average unemployment duration among men living close to
the border between treated and control regions*/						  

/*The evidence in Figs. 2 and 3 suggest that there are important discontinuities in the duration of unemployment at age 50 and at the border between treated and control regions*/

/*----------------------
FIGURE 4
-----------------------*/

/*. Fig. 4 reports average unemployment duration as a function of age and distance to border in the period from 1/1986 until 12/1987, i.e. 2.5 years to 0.5 years before REBP was introduced.*/


*A
rdplot unemployment_duration age if female==0  & tr==1 & period == 0, c(50)  p(1) ///
       graph_options(title(Figure 4 A) ///
                           ytitle(umemployment duration) ///
                           xtitle(age))
						   
/*This evidence thus suggests that it may be
important to account for pre-existing differences in average unemployment duration at the age 50 years
threshold.*/

*B
rdplot unemployment_duration db if female==0  & period == 0 & age >=50, c(0) p(1) ///
       graph_options(title(Figure 4 B) ///
                           ytitle(umemployment duration) ///
                           xtitle(distance to border))

/*The evidence in Fig. 4B thus suggests that identifying the
effect of REBP by contrasting average unemployment duration in communities located at both sides of the
border is a meaningful identification strategy*/


/*----------------------
FIGURE 5
-----------------------*/

*A
rdplot marr age if female==0 & tr==1 & period == 1, c(50)  p(1) ///
       graph_options(title(Figure 5 A) ///
                           ytitle(married (share)) ///
                           xtitle(age))

/* Fig. 5A reveals
that marital status indeed appears to be correlated with age. In the age bracket 46–48 years, the share married
increases from about 75% to about 80%. Importantly, there is no discontinuity at the age 50 threshold.*/
						   
						   
*B
rdplot bau db if female==0 & period == 1 & age >=50, c(0) p(1) ///
       graph_options(title(Figure 5 B) ///
                           ytitle(construction (share)) ///
                           xtitle(age))

/*Fig. 5B discusses inflow composition with respect to previous employment in construction as a function of distance to border. In control regions, the share previously employed in construction is about 60% irrespective of distance to the border between treated and control regions. Just on the other side of the border, the share previously employed in construction decreases quite strongly but insignificantly to 53%*/

						
				
/*----------------------
FIGURE 7
-----------------------*/

/*Fig. 7 concentrates on women entering unemployment in treated regions in the age bracket 46–53 years.*/

rdplot unemployment_duration age if female==1 & tr==1 & period == 1, c(50) p(1) ///
       graph_options(title(Figure 7) ///
                           ytitle(umemployment duration) ///
                           xtitle(age))
				

/*----------------------
FIGURE 8
-----------------------*/

/*Fig. 8 uses variation in distance to border among women aged 50 years or older to identify the effect of REBP.*/

rdplot unemployment_duration db if female==1 & period == 1 & age >=50, c(0) p(1) ///
       graph_options(title(Figure 8) ///
                           ytitle(umemployment duration) ///
                           xtitle(distance to border))

/*as one crosses the border between treated communities and control communities, unemployment duration increases significantly from 26 weeks to a level of 78 weeks*/


/*Taken together, these descriptive analyses suggest that an estimation strategy that measures the discontinuity at the threshold identifies the causal effect of extended benefits on unemployment duration at both thresholds for men and at the border threshold for women.*/


/*----------------------
TABLE 2
-----------------------*/

*A

* replicate result in Table 2 Column (1)
regress unemployment_duration age50 if female == 0 & period == 1 & tr==1, cluster(age)
est store reg1_a

/*Results indicate that unemployment duration is 14.6 weeks longer among men in the age bracket 50–53 years compared to men aged 46–49 year*/


* replicate result in Table 2 Column (2)
regress unemployment_duration age50 dage_1 age50_dage_1 if female == 0 & period == 1 & tr==1, cluster(age)
est store reg2_a

/*The second column reports the results from the basic model (1). Results indicate that REBP prolongs unemployment duration by 14.8 weeks rather than 14.6 weeks*/


* replicate result in Table 2 Column (3)
regress unemployment_duration age50 dage_1 age50_dage_1 dage_2 age50_dage_2 dage_3 age50_dage_3 if female == 0 & period == 1 & tr==1, cluster(age)
est store reg3_a

/*Results indicate that the effect of REBP is weaker than in the basic model (11.2 weeks as opposed to 14.8 weeks).*/

* replicate result in Table 2 Column (4) 
rdrobust unemployment_duration age if female == 0 & period == 1 & tr==1, ///
	c(50) p(1) h(2) kernel(epanechnikov) vce( cluster age )
est store reg4_a

* replicate result in Table 2 Column (5) 
regress unemployment_duration c.age50##i.period c.dage_1##i.period c.age50_dage_1##i.period  if female == 0 & tr==1, cluster(age)
est store reg5_a


/* The local linear estimate of the effect of REBP on unemployment duration is 12.7 weeks, again lower than the basic model estimate of 14.8 week*/

* replicate result in Table 2 Column (6)
regress unemployment_duration age50 dage_1 age50_dage_1 $controles if female == 0 & period == 1 & tr==1, cluster(age)
est store reg6_a

/*Results suggest that REBP prolongs unemployment duration by 13.8 week*/

esttab reg1 reg2 reg3 reg4 reg5 reg6,  star(* 0.1 ** 0.05 *** 0.01)


*B

/*The second identification strategy compares men entering unemployment living on both sides of the border between treated and control regions*/

*Generate border dummy
gen db_0 = 1 if db >= 0 
replace db_0 = 0 if db_0 == .

*Generate vars
gen db2=db^2
gen db3=db^3


* replicate result in Table 2 Column (1)
regress unemployment_duration db_0  if female == 0 & period == 1 & age >=50, cluster(db)
est store reg1_b
/* Contrasting treated and control regions produces a prima facie treatment effect of about 13.9 weeks of REBP on average unemployment duration*/

* replicate result in Table 2 Column (2)
regress unemployment_duration db_0 db i.db_0#c.db if female == 0 & period == 1 & age >=50, cluster(db)
est store reg2_b

* replicate result in Table 2 Column (3)
regress unemployment_duration db_0 db i.db_0#c.db db2 i.db_0#c.db2 db3 i.db_0#c.db3 if female == 0 & period == 1 & age >=50, cluster(db)
est store reg3_b

* replicate result in Table 2 Column (4) 
rdrobust unemployment_duration db if female == 0 & period == 1 & age >=50, c(0) p(1) h(30) kernel(epanechnikov)
est store reg4_b

* replicate result in Table 2 Column (5)
regress unemployment_duration c.db_0##i.period c.db##i.period ///
	i.db_0#c.db##i.period if female == 0 & age >=50, cluster(db)
est store reg5_b

* replicate result in Table 2 Column (6)
regress unemployment_duration db_0 db i.db_0#c.db $controls if female == 0 & period == 1 & age >=50, cluster(db)
est store reg6_b


/*----------------------
TABLE 3
-----------------------*/

*A

* replicate result in Table 3 Column (1)
regress unemployment_duration age50  if female == 1 & period == 1 & tr==1, cluster(age)
est store reg1_2a

* replicate result in Table 3 Column (2)
regress unemployment_duration age50 dage_1 age50_dage_1 if female == 1 & period == 1 & tr==1, cluster(age)
est store reg2_2a

* replicate result in Table 3 Column (3)
regress unemployment_duration age50 dage_1 age50_dage_1 dage_2 age50_dage_2 dage_3 age50_dage_3 if female == 1 & period == 1 & tr==1, cluster(age)
est store reg3_2a

* replicate result in Table 2 Column (4) 
rdrobust unemployment_duration age if female == 1 & period == 1 & tr==1, c(50) p(1) h(2) kernel(epanechnikov)
est store reg4_2a

* replicate result in Table 2 Column (5)
regress unemployment_duration c.age50##i.period c.dage_1##i.period c.age50_dage_1##i.period  if female == 1 & tr==1, cluster(age)
est store reg5_2a

* replicate result in Table 3 Column (6)
regress unemployment_duration age50 dage_1 age50_dage_1 $controls if female == 1 & period == 1 & tr==1, cluster(age)
est store reg6_2a

* B

* replicate result in Table 3 Column (1)
regress unemployment_duration db_0  if female == 1 & period == 1 & age >=50, cluster(db)
est store reg1_2b

* replicate result in Table 3 Column (2)
regress unemployment_duration db_0 db i.db_0#c.db if female == 1 & period == 1 & age >=50, cluster(db)
est store reg2_2b

* replicate result in Table 3 Column (3)
regress unemployment_duration db_0 db i.db_0#c.db db2 i.db_0#c.db2 db3 i.db_0#c.db3 if female == 1 & period == 1 & age >=50, cluster(db)
est store reg3_2b

* replicate result in Table 3 Column (4) 
rdrobust unemployment_duration db if female == 1 & period == 1 & age >=50, c(0) p(1) h(30) kernel(epanechnikov)
est store reg4_2b

* replicate result in Table 3 Column (5)
regress unemployment_duration c.db_0##i.period c.db##i.period i.db_0#c.db##i.period if female == 1 & age >=50, cluster(db)
est store reg5_2b

* replicate result in Table 3 Column (6)
regress unemployment_duration db_0 db i.db_0#c.db $controls if female == 1 & period == 1 & age >=50, cluster(db)
est store reg6_2b

