* Limpiar memoria y establecer configuraciones iniciales
clear all
set more off
set matsize 1000
set mem 400m

* Directorio de trabajo
cd "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico"

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Experimentos aleatorios
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------


* utilizo base jperandomizationdata.dta

use "Datos - Olken 2007/jperandomizationdata.dta", replace

* aclaración de consigna:  el único tratamiento es audit


* 1) Presenten evidencia de que tratados y controles están balanceados en las
* siguientes variables: zdistancekec, zkadesedyears, zkadesage, zpop,
* zpercentpoorpra, zkadesbengkoktotal ¿Qué concluimos?

	
	
* Para esto hacemos un test de medias
foreach var of varlist zdistancekec zkadesedyears zkadesage zpop zpercentpoorpra zkadesbengkoktotal {
di "Test de medias de `var'"
ttest `var', by(audit)

}

* Tablas latex ----------------------------------------------------------------

* Tabla de estadistiacas descriptivas
* Tabla LaTeX de estadísticas descriptivas con etiquetas de variables
cap file close myfile
file open myfile using "Lucas/Tabla1_experimentos_aleatorios.tex", write replace
file write myfile "\begin{table}[h]" _n
file write myfile "\centering" _n
file write myfile "\renewcommand{\arraystretch}{1.5}" _n
file write myfile "\begin{tabular}{lccc}" _n
file write myfile "\hline" _n
file write myfile "\textbf{Variable} & Obs. & Promedio & Desvío estándar \\" _n
file write myfile "\hline" _n

foreach var of varlist zdistancekec zkadesedyears zkadesage zpop zpercentpoorpra zkadesbengkoktotal {
    quietly ttest `var', by(audit)
    
    local obs_t = r(N_1)
    local obs_c = r(N_2)
    local mean_t = r(mu_1)
    local mean_c = r(mu_2)
    local sd_t = r(sd_1)
    local sd_c = r(sd_2)

    // Obtener la etiqueta de la variable
    local var_label : variable label `var'
    if "`var_label'" == "" local var_label "`var'"  // Si no tiene etiqueta, usa el nombre de la variable

    // Aplicar formato con dos decimales
    local mean_t_f : display %9.3f `mean_t'
    local mean_c_f : display %9.3f `mean_c'
    local sd_t_f   : display %9.3f `sd_t'
    local sd_c_f   : display %9.3f `sd_c'

    // Escribir el nombre de la variable en negrita
    file write myfile "\textbf{`var_label'} \\" _n

    // Fila Tratado (sin negrita)
    file write myfile "Tratado & `obs_t' & `mean_t_f' & `sd_t_f' \\" _n
    
    // Fila Control (sin negrita)
    file write myfile "Control & `obs_c' & `mean_c_f' & `sd_c_f' \\" _n
    
    // Agregar espacio entre variables
    file write myfile "\addlinespace" _n
}

file write myfile "\hline" _n
file write myfile "\end{tabular}" _n
file write myfile "\caption{Características del grupo tratamiento y control}" _n
file write myfile "\label{tab:group_stats}" _n
file write myfile "\end{table}" _n
file close myfile




* Tabla LaTeX de test de medias con etiquetas en lugar de nombres de variables
cap file close myfile
file open myfile using "Lucas/Tabla2_experimentos_aleatorios.tex", write replace
file write myfile "\begin{table}[h]" _n
file write myfile "\centering" _n
file write myfile "\renewcommand{\arraystretch}{1.5}" _n  // Mayor espaciado entre filas
file write myfile "\begin{tabular}{lccc}" _n
file write myfile "\hline" _n
file write myfile "Variable & Tratamiento & Control & Diferencia \\" _n
file write myfile " &  &  &  \\" _n
file write myfile "\hline" _n

foreach var of varlist zdistancekec zkadesedyears zkadesage zpop zpercentpoorpra zkadesbengkoktotal {
    quietly ttest `var', by(audit)
    
    local mean_t = r(mu_1)
    local mean_c = r(mu_2)
    local diff = r(mu_1) - r(mu_2)
    local stderr = r(se)
    local pval = r(p)

    // Obtener la etiqueta de la variable
    local var_label : variable label `var'
    if "`var_label'" == "" local var_label "`var'"  // Si no tiene etiqueta, usar el nombre de la variable

    // Aplicar formato con dos decimales
    local mean_t_f : display %9.3f `mean_t'
    local mean_c_f : display %9.3f `mean_c'
    local diff_f   : display %9.3f `diff'
    local stderr_f : display %9.3f `stderr'
    
    // Determinar significancia con estrellas
    local star ""
    if `pval' < 0.1 local star "*"
    if `pval' < 0.05 local star "**"
    if `pval' < 0.01 local star "***"

    // Escribir valores en el archivo con formato LaTeX
    file write myfile "`var_label' & `mean_t_f' & `mean_c_f' & \multicolumn{1}{c}{`diff_f'`star'} \\" _n
    file write myfile " &  &  & \multicolumn{1}{c}{(`stderr_f')} \\" _n
    file write myfile "\addlinespace" _n  // Espaciado extra entre filas
}

file write myfile "\hline" _n
file write myfile "\end{tabular}" _n
file write myfile "\caption{Test de medias por auditoría}" _n
file write myfile "\label{tab:ttest}" _n
file write myfile "\end{table}" _n

file close myfile


* 2) Muestren la correlación entre estas variables y el tratamiento ¿Cómo se explican
* estos resultados?

// Calcular la matriz de correlación
correlate audit zdistancekec zkadesedyears zkadesage zpop zpercentpoorpra zkadesbengkoktotal


* 3) Eliminen las observaciones que registran algunos de los otros tratamientos (und
* y fpm). Regresen el tratamiento en función de las variables de los puntos
* anteriores ¿Qué concluimos mirando el estadístico F?
preserve
* Eliminamos las observaciones que fueron tratadas en la variable und o fpm
drop if und != 0 | fpm != 0 

reg audit zdistancekec zkadesedyears zkadesage zpop zpercentpoorpra zkadesbengkoktotal

* Guardamos tablas con comando
eststo table4
* Exporto tabla
esttab table4  ///
using "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Lucas/Tabla4_experimentos_aleatorios.tex", replace ///
star(* 0.1 ** 0.05 *** 0.01) plain nogaps ///
depvars b(%9.3f) se(%9.3f) legend  ///
label style(tex) ///
title("Regresión Olsen (2007)") ///
stats(N F p, fmt(%9.0f %9.3f %9.3f) labels("Obs." "F-stat" "P-value"))  se ///
addnotes("Errores estándar en paréntesis") ///
lines parentheses nolz 
restore

* Volvamos a usar la muestra completa (sin eliminar a las unidades que reciben los otros
* tratamientos). Utilicen el comando "merge" para combinar esta base con
* jperoaddata.dta. El indicador de las villas es desaid. Esta nueva base contiene las
* variables dependientes que usa Olken (2007). Realicen las siguientes regresiones
* usando lndiffeall4mainanci como variable dependiente:

* mergeamos la base jperoaddata.dta.

merge 1:1 desaid using  "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Datos - Olken 2007/jperoaddata.dta" // aclaración: vi las tablas de frecuencia. Para cada observacion le corresponde un id 


* 4) Una regresión usando audit como única variable independiente. Expliquen su
* elección respecto a los errores estándar e interpreten el coeficiente de audit.

reg lndiffeall4mainanci audit,  cluster(kecnum)
eststo table5a

* 5) Una regresión que además de audit incluya como variables de control las que
* usaron para analizar el balance entre tratados y controles. Expliquen qué ocurre
* con el coeficiente de audit y por qué.

reg lndiffeall4mainanci audit zdistancekec zkadesedyears zkadesage zpop zpercentpoorpra zkadesbengkoktotal,  cluster(kecnum) 
eststo table5b

* 6)  Agreguen a la regresión del punto anterior efectos fijos por subdistrito (kecnum)
* ¿Cuál es la variación que identifica nuestro coeficiente de interés? ¿Es correcta
* esta especificación? Justifique.


*Primero convertimos la variable "kecnum" en una de tipo numerico*
encode(kecnum),gen(kecnum1)
*incluyendo efectos fijos por subdistrito*
reg lndiffeall4mainanci audit zdistancekec zkadesedyears zkadesage zpop zpercentpoorpra zkadesbengkoktotal i.kecnum1, cluster(kecnum)
eststo table5c


*Exporto tabla
esttab table5a table5b table5c  ///
using "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Lucas/Tabla5_experimentos_aleatorios.tex", replace ///
keep(audit) ///
star(* 0.1 ** 0.05 *** 0.01) plain nogaps ///
depvars b(%9.3f) se(%9.3f) legend  ///
label style(tex) ///
title("Regresión Olsen (2007)") ///
stats(controles FE N, fmt(%9.0f) labels("Controles" "Efectos fijos" "Obs.")) se ///
addnotes("Nota: Errores estándar agrupados en paréntesis. Agrupados a nivel de subdistritos.") ///
numbers lines parentheses nolz







*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Diferencias en diferencias
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

* Limpiar memoria y establecer configuraciones iniciales
clear all
set more off
set matsize 1000
set mem 400m


* Estilo del gráfico
grstyle init
grstyle set plain, horizontal grid

* Directorio de trabajo
cd "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico"

* Utilizamos la base de datos de González (2024)

use "Datos - González 2024/zc_level.dta", replace

* Seteamos xtset

xtset zipid year

* Como primer paso, muestren evidencia de tendencias paralelas en un gráfico.


lgraph lnactionnonoil year, by(fracked) xline(2005)  ///
xtitle("Año") ytitle("Acciones de regulación ambiental") ///
xlabel(1990(2)2014) ///
legend(order(1 "No Fracked" 2 "Fracked"))


* Generamos la interacción did

gen did = treatment * fracked


* Realizamos DD

* Actions (1)
xtdidregress (lnactionnonoil fracked treatment ) (did),  group(zipid) time(year)
eststo table6_1



* Actions (2)
xtdidregress (lnactionnonoil fracked treatment lnemp lnestab ) (did),  group(zipid) time(year)
eststo table6_2



* Facilities (3)
xtdidregress (lnone_non_oil fracked treatment ) (did),  group(zipid) time(year)
eststo table6_3


* Facilities (4)
xtdidregress (lnone_non_oil fracked treatment lnemp lnestab  ) (did),  group(zipid) time(year)
eststo table6_4


* formal (5)
xtdidregress (lnstate_formal_nonoil fracked treatment  ) (did),  group(zipid) time(year)
eststo table6_5

* formal (6)
xtdidregress (lnstate_formal_nonoil fracked treatment lnemp lnestab ) (did),  group(zipid) time(year)
eststo table6_6

esttab table6_1 table6_2 table6_3 table6_4 table6_5 table6_6 ///
using "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Lucas/Tabla6_DD.tex", replace ///
keep(r1vs0.did ) ///
star(* 0.1 ** 0.05 *** 0.01) plain nogaps ///
depvars b(%9.3f) se(%9.3f) legend  ///
label style(tex) ///
title("Regresión Olsen (2007)") ///
stats(controles FE_i FE_t N_clust N, fmt(%9.0f) labels("Controles" "Efectos fijos por código postal" "Efectos fijos por año" "Códigos postales" "Obs.")) se ///
addnotes("Nota: Errores estándar agrupados en paréntesis. Agrupados a nivel de subdistritos.") ///
numbers lines parentheses nolz


* Supongan que tomamos la especificación de la Columna 1 de la Tabla 1 e incluimos, además de * los efectos fijos a nivel del código postal, efectos fijos por estado ¿Qué ocurre con estos * coeficientes? 

encode(state),gen(state_numeric)

* Actions (1)
xtdidregress (lnactionnonoil fracked treatment) (did),  group(zipid) time(year)
eststo table7_1

* Actions (1) (con efectos fijos de state_numeric)
xtdidregress (lnactionnonoil fracked treatment i.state_numeric) (did),  group(zipid) time(year)
eststo table7_2

esttab table7_1 table7_2 ///
using "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Lucas/Tabla7_DD.tex", replace ///
keep(r1vs0.did ) ///
star(* 0.1 ** 0.05 *** 0.01) plain nogaps ///
depvars b(%9.3f) se(%9.3f) legend  ///
label style(tex) ///
title("Regresión Olsen (2007)") ///
stats(controles FE_i FE_t FE_ii N_clust N, fmt(%9.0f) labels("Controles" "Efectos fijos por código postal" "Efectos fijos por año" "Efectos fijos por estado" "Códigos postales" "Obs.")) se ///
addnotes("Nota: Errores estándar agrupados en paréntesis. Agrupados a nivel de subdistritos.") ///
numbers lines parentheses nolz


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* TWFE
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------


* Limpiar memoria y establecer configuraciones iniciales
clear all
set more off
set matsize 1000
set mem 400m


* Estilo del gráfico
grstyle init
grstyle set plain, horizontal grid

* Directorio de trabajo
cd "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico"

* Utilizamos la base de datos de Cheng y Hoekstra (2013)

use "Datos - Cheng y Hoekstra 2013/castle.dta", replace

xtset sid year

* Lean el trabajo de Cheng y Hoekstra (2013) hasta la página 831. En esta sección vamos
* a usar la base castle1.dta. Las variables con las que van a trabajar son las siguientes:
* - year: años
* - sid: indicador numérico para los estados
* - cdl: igual a uno para los tratados en todos los años en que son tratados, cero en otro caso.
* - switch: igual a uno únicamente para el año en que se asignó el tratamiento, cero en otro caso
* - homicide: homicidios cada 100,000 habitantes
* - motor: robos de vehículos cada 100,000 habitantes
* - Variables de control: 
* + population
* + police: Policías por cada 100.000 habitantes
* + unemployrt
* + income: Ingreso familiar promedio ($)
* + blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44
* - Lags y leads de switch
* - effyear: año en que se implementó el tratamiento



* Primero vamos a realizar una estimación de tipo TWFE usando homicide y motor como
* variables dependientes. Para cada una, realicen una estimación sin otras variables de
* control más que los efectos fijos, y otra estimación con controles. Tengan en cuenta que
* estamos trabajando con datos en panel. Discutan la especificación econométrica y cada
* uno de sus componentes, incluyendo lo que hagan con los errores estándar. Presenten
* los resultados en una tabla.

* homicide (1)
xtreg homicide cdl i.year, fe cluster(sid)
eststo table8_1_TWFE

* homicide (2)
xtreg homicide cdl i.year population police unemployrt income blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44, fe cluster(sid)
eststo table8_2_TWFE

* motor (3)
xtreg motor cdl i.year, fe cluster(sid)
eststo table8_3_TWFE

* motor (4)
xtreg motor cdl i.year population police unemployrt income blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44, fe cluster(sid)
eststo table8_4_TWFE

esttab table8_1_TWFE table8_2_TWFE table8_3_TWFE table8_4_TWFE ///
using "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Lucas/Tabla8_TWFE.tex", replace ///
keep(cdl) ///
star(* 0.1 ** 0.05 *** 0.01) plain nogaps ///
depvars b(%9.3f) se(%9.3f) legend  ///
label style(tex) ///
title("Cheng y Hoekstra (2013)") ///
stats(controles FE_i FE_t N_clust N, fmt(%9.0f) labels("Controles" "Efectos fijos por estado" "Efectos fijos por año" "n de estados" "Obs.")) se ///
addnotes("Nota: Errores estándar agrupados en paréntesis. Agrupados a nivel de estados.") ///
numbers lines parentheses nolz

* Luego, vamos a realizar un event study clásico para ver los efectos dinámicos y testear
* el supuesto de tendencias paralelas para ambas dependientes. Incluyan cuatro leads y
* cuatro lags, y agreguen controles a la regresión (no al gráfico). Comenten los resultados.

* La variable time_til mide la distancia al momento del tratamientos

* Event studies de homicide
preserve
keep if (time_til > -5 & time_til < 5)
eventdd homicide ///
		 ///
		i.year population police unemployrt income blackm_15_24 whitem_15_24 blackm_25_44  whitem_25_44 ///
		, timevar(time_til) ci(rcap)  method(fe, cluster(state))  ///
		graph_op(ytitle("Homicidios cada 100000 habitantes") xtitle("Años desde la implementación de la Ley de la Doctrina del Castillo") xlabel(-4(1)4) legend(order(2 "Estimación puntual" 1 "95% IC") pos(6) rows(1))) 
eststo table9_ES 
esttab table9_ES ///
using "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Lucas/Tabla9_ES.tex", replace ///
keep(lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4) ///
star(* 0.1 ** 0.05 *** 0.01) plain nogaps ///
depvars b(%9.3f) se(%9.3f) legend  ///
label style(tex) ///
title("Homicidios cada 100000 habitantes") ///
stats(controles FE_i FE_t N_clust N, fmt(%9.0f) labels("Controles" "Efectos fijos por estado" "Efectos fijos por año" "n de estados" "Obs.")) se ///
addnotes("Nota: Errores estándar agrupados en paréntesis. Agrupados a nivel de estados.") ///
numbers lines parentheses nolz

restore


* Event studies de motor

preserve
keep if (time_til > -5 & time_til < 5)
eventdd motor ///
		 ///
		i.year population police unemployrt income blackm_15_24 whitem_15_24 blackm_25_44 		 whitem_25_44 ///
		, timevar(time_til) ci(rcap) method(fe, cluster(state)) ///
		graph_op(ytitle("Robos de vehículos cada 100000 habitantes") xtitle("Años desde la implementación de la Ley de la Doctrina del Castillo") xlabel(-4(1)4) legend(order(2 "Estimación puntual" 1 "95% IC") pos(6) rows(1))) 
eststo table10_ES 
esttab table10_ES ///
using "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Evaluación de impacto-MacBook Pro de Lucas/Tópicos de Microeconomía/Trabajos Prácticos/Primer Trabajo Práctico/Lucas/Tabla10_ES.tex", replace ///
keep(lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4) ///
star(* 0.1 ** 0.05 *** 0.01) plain nogaps ///
depvars b(%9.3f) se(%9.3f) legend  ///
label style(tex) ///
title("Robos de vehículos cada 100000 habitantes") ///
stats(controles FE_i FE_t N_clust N, fmt(%9.0f) labels("Controles" "Efectos fijos por estado" "Efectos fijos por año" "n de estados" "Obs.")) se ///
addnotes("Nota: Errores estándar agrupados en paréntesis. Agrupados a nivel de estados.") ///
numbers lines parentheses nolz		
restore



* Ahora vamos a ver si estos resultados son robustos a los nuevos estimadores de
* diferencias en diferencias con variación en el tiempo. Realicen una estimación del ATT y
* presenten un event study utilizando el estimador propuesto por Callaway y Sant ́Anna
* (2021) para homicide y motor. Comenten los resultados. Recuerden que para esto van a
* tener que crear/modificar variables en la muestra para poder aplicar el estimador de
* Callaway y Sant ́Anna en Stata.

* Creamos laa variable identificador de grupo (gvar_CS) (0 si nunca fue tratada)
gen gvar_CS = 0
replace gvar_CS = effyear if effyear != .


* Estimador de Callaway y Sant ́Anna (2021)

* Homicide sin controles
csdid homicide , ivar(sid) time(year) gvar(gvar_CS) notyet method(dripw) window(-4 4) long2 
estat simple, window(-3 4)

* Homicide con controles (para el event study se utilizan controles)
csdid homicide population police unemployrt income blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44, ivar(sid) time(year) gvar(gvar_CS) notyet method(dripw) window(-4 4) long2 
estat event, window(-3 4) 
csdid_plot, ytitle("Homicidios cada 100000 habitantes") xtitle("Años desde la implementación de la Ley de la Doctrina del Castillo") xlabel(-4(1)4) legend(order(2 "Pretratamiento " 4 "Postratamiento") pos(6) rows(1)) 
estat simple, window(-3 4)



* motor sin controles

csdid motor , ivar(sid) time(year) gvar(gvar_CS) notyet method(dripw) window(-4 4) long2
estat simple, window(-3 4)

* motor con controles (para el event study se utilizan controles)

csdid motor population police unemployrt income blackm_15_24 whitem_15_24 blackm_25_44 		 whitem_25_44, ivar(sid) time(year) gvar(gvar_CS) notyet method(dripw) window(-4 4) long2
estat event, window(-3 4) 
csdid_plot,  ytitle("Robos de vehículos cada 100000 habitantes") xtitle("Años desde la implementación de la Ley de la Doctrina del Castillo") xlabel(-4(1)4) legend(order(2 "Pretratamiento " 4 "Postratamiento") pos(6) rows(1)) 
estat simple, window(-3 4)












