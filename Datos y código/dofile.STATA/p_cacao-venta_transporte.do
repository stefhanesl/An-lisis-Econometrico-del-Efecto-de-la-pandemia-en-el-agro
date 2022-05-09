*000000000000000000000000000000000000000000000000000000000000000000000000
*                  Cacao
*000000000000000000000000000000000000000000000000000000000000000000000000
clear all
set more off

use "/Users/juancarlosharo/Desktop/Integradora/RESULTADOS PARÁMETRO/cacao_p.dta", clear
*-----------------------------------------------------------

rename (cg_k100 cg_k101 cg_k102 cp_k409 cp_afecta_prod cp_riego pa_arealm eq_emotoguadana eq_ebmanual ventas cp_cantidad_npk_fq)(sexo edad educacion sup_plantada afectacion_produccion riego almacenamiento m_guadana eq_ebmanual ventas_toneladas fertilizantes)


*--------------------------------------------------------
gen ln_scosechada_ventas = ln(parametro_ventas)
hist ln_scosechada_ventas


tabulate educacion, generate(formacion)
tabulate afectacion_produccion, generate(afectacion)
tabulate ual_parr, generate(parroquia)

*************Variable cambiante
drop parroquia14

rename afectacion1 af_sequia
rename afectacion2 af_plagas
rename afectacion3 af_inundacion
rename afectacion5 af_edad_plantacion


*Variables elevadas al cuadrado
gen edadC = edad*edad
gen sup_plantada2 = sup_plantada*sup_plantada


*Variables interactivas
gen sexo_edad = sexo*edad
gen riego_edad = riego * edad
gen sexo_plantada = sexo * sup_plantada
gen edad_plantada = edad * sup_plantada
gen riego_plantada = riego * sup_plantada

*Formacion
gen primaria = formacion1 + formacion4
gen secundaria = formacion2 + formacion5
gen universidad = formacion3 + formacion6
gen ninguna_for = formacion7

*--------------------------------------------------------
global ylist ln_scosechada_ventas

global treatment tratamiento_ventas_transporte

global xlist sexo edad primaria secundaria universidad ninguna_for sup_plantada af_sequia af_plagas af_inundacion af_edad_plantacion riego almacenamiento m_guadana eq_ebmanual parroquia* edadC sup_plantada2 sexo_edad riego_edad sexo_plantada edad_plantada riego_plantada


global xlist2 sexo edad primaria secundaria universidad ninguna_for sup_plantada af_sequia af_plagas af_inundacion af_edad_plantacion riego almacenamiento m_guadana eq_ebmanual parroquia*
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
quietly probit $treatment $xlist2, robust
predict pprobit, pr
*................................................................
*Ho:u0=u1
asdoc ksmirnov pprobit, by($treatment)

*................................................................
**----------------------------------------------------------------
*HISTOGRAMA
**----------------------------------------------------------------
*................................................................
twoway hist pprobit if $treatment == 1 || hist pprobit if $treatment == 0, fcolor(none) lcolor(blue) legend(label(1 "Tratamiento") label(2 "Control")) xtitle("Probabilidad de ser afectado en ventas por hectarea a causa del transporte") ytitle("Densidad") title("Histograma Cacao")

sum pprobit if $treatment == 1, detail
sum pprobit if $treatment == 0, detail 

*................................................................
*************Variable cambiante
gen soporteComun = 0
replace soporteComun = 1 if pprobit>= .2176581 & pprobit<= .702645 

*................................................................

*Regresion con todas las observaciones
reg $ylist $treatment $xlist2, robust
asdoc reg $ylist $treatment $xlist2, robust, replace tzok dec(4)

*Regresion con las variables que tienen soporte comun
reg $ylist $treatment $xlist2 if soporteComun == 1, robust
asdoc reg $ylist $treatment $xlist2 if soporteComun == 1, robust, replace tzok dec(4)

*Variable de interes

sum parametro_ventas if $treatment == 0
asdoc sum parametro_ventas if $treatment == 0 , replace tzok dec(4)

di .8345287*-.1332292

*resultado = -.11118359

gen resultado = cp_k411ha * fact_exp_fin_cultivo if $treatment == 1
sum resultado if $treatment == 1

di 90.81876*-.11118359

*resultado = -10.097556 
