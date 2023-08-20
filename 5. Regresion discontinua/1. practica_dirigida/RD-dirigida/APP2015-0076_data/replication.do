/*

Replication code for output in

                     "Do Fiscal Rules Matter?" 
       by Veronica Grembi, Tommaso Nannicini and Ugo Troiano 
	   
	   
*/

clear
set more off

* Installing or replacing necessary packages
ssc install cdfplot, replace
net install rdrobust, from("http://www-personal.umich.edu/~cattaneo/software/rdrobust/stata-2014") replace
ssc install outreg2, replace

* Tables in the main paper
do tables.do

* Figures in the main paper
do figures.do

