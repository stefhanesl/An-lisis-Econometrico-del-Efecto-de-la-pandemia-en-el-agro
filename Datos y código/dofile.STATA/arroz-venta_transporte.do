*000000000000000000000000000000000000000000000000000000000000000000000000
*                  ARROZ
*000000000000000000000000000000000000000000000000000000000000000000000000
clear all
set more off

use "/Users/juancarlosharo/Desktop/Integradora/RESULTADOS/arroz_parametro.dta", clear

*-----------------------------------------------------------

rename (cg_k100 cg_k101 cg_k102 eu_superficie_ha ct_afecta_prod ct_riego pa_arealm pa_areempa eq_earado	eq_semman eq_emotoguadana eq_ebmanual eq_ebestaciona eq_ecosgranfigr Ventas ct_cantidad_npk_fq) (sexo edad educacion hectareas_total afectacion_produccion riego almacenamiento area_empaque m_labranza m_sembradora m_guadana bomba_manual bomba_estacionaria cosechadora ventas_toneladas fertilizantes)

*--------------------------------------------------------
gen ln_ventas = ln(ventas_toneladas)
hist ln_ventas


tabulate educacion, generate(formacion)
tabulate afectacion_produccion, generate(afectacion)
tabulate ual_parr, generate(parroquia)

*************Variable cambiante
drop parroquia7

rename afectacion1 af_sequia
rename afectacion2 af_plagas
rename afectacion3 af_inundacion
rename afectacion5 af_edad_plantacion


*Variables elevadas al cuadrado
gen edadC = edad*edad
gen hectareas_total2 = hectareas_total*hectareas_total


*Variables interactivas
gen sexo_edad = sexo*edad
gen riego_edad = riego * edad
gen sexo_hectareast = sexo * hectareas_total
gen edad_hectareast = edad * hectareas_total
gen riego_hectareast = riego * hectareas_total

*Formacion
gen primaria = formacion1 + formacion4
gen secundaria = formacion2 + formacion5
gen universidad = formacion3 + formacion6
gen ninguna_for = formacion7

*--------------------------------------------------------
global ylist ln_ventas

global treatment tratamiento_ventas_transporte

global xlist sexo edad primaria secundaria universidad ninguna_for hectareas_total af_sequia af_plagas af_inundacion af_edad_plantacion riego almacenamiento area_empaque m_labranza m_sembradora m_guadana bomba_manual bomba_estacionaria cosechadora parroquia* edadC hectareas_total2 sexo_edad riego_edad sexo_hectareast edad_hectareast riego_hectareast

global xlist2 sexo edad primaria secundaria universidad ninguna_for hectareas_total af_sequia af_plagas af_inundacion af_edad_plantacion riego almacenamiento area_empaque m_labranza m_sembradora m_guadana bomba_manual bomba_estacionaria cosechadora parroquia*
*--------------------------------------------------------

* Descripcion
describe $treatment $ylist $xlist
summarize $treatment $ylist $xlist



* Modelo Probit
probit $treatment $xlist, robust
probit $treatment $xlist2, robust

asdoc probit $treatment $xlist, robust, replace tzok dec(2)
asdoc probit $treatment $xlist2, robust, replace tzok dec(2)


* Prediccion de la probabilidad
quietly probit $treatment $xlist2
predict pprobit, pr


**----------------------------------------------------------------
*HISTOGRAMA
**----------------------------------------------------------------
*................................................................
twoway hist pprobit if $treatment == 1 || hist pprobit if $treatment == 0, fcolor(none) lcolor(blue) legend(label(1 "Tratamiento") label(2 "Control")) xtitle("Probabilidad de ser afectado en las ventas por falta de transporte") ytitle("Densidad") title("Histograma Arroz")

sum pprobit if $treatment == 1, detail
sum pprobit if $treatment == 0, detail 

*................................................................
*************Variable cambiante
gen soporteComun = 0
replace soporteComun = 1 if pprobit>= 0.1089463 & pprobit<= 0.7579154

*................................................................
gen groups = tratamiento_ventas_transporte if soporteComun == 1
asdoc ttest sexo, by(groups), replace tzok dec(2)




*Regresion con todas las observaciones
reg $ylist $treatment $xlist2, robust
asdoc reg $ylist $treatment $xlist2, robust, replace tzok dec(4)

*Regresion con las variables que tienen soporte comun
reg $ylist $treatment $xlist2 if soporteComun == 1, robust
asdoc reg $ylist $treatment $xlist2 if soporteComun == 1, robust, replace tzok dec(4)

*Variable de interes
sum ventas_toneladas if $treatment == 0 
asdoc sum ventas_toneladas if $treatment == 0 , replace tzok dec(4)
