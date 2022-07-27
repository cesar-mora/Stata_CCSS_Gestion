/*-------------------------------
----QLAB - PUCP -----------------
-- STATA para Ciencias Sociales--
-- y Gestión Pública--------- ---
---- Sesión 2 -------------------
-- Transformación de datos-------
---------------------------------
---------------------------------
-- César Mora - 2022 ------------
----------------------------------*/


webuse lifeexp,clear

/*
Con fines informativos, se usará la base de datos "lifeexp"
que presenta un conjunto de paises con información
sobre esperanza de vida y pbi percapita
*/

/*------------------------------------
- Revisión y tratamiento de strings --
--------------------------------------*/

describe
*--> analiza la columna "storage type"

* Analisis de extension
display length("Hola, aprendemos STATA")
display length(country)

* Reconocimiento de caracteres en una variable string (comando charlist)
*ssc install charlist
charlist country
*charlist region 	/*no funciona*/

* Identificación de la primera posición de un caracter:
display strpos("La mejor clase","e")
display strpos("La mejor clase","u")
display strpos("La mejor clase","l")

* Encontrando patrones (0=no, 1=sí)
display strmatch("12345","???45")
display strmatch("abc.def","??cdef")

	** creando una variable:
	gen country_d=strmatch(country,"?eru")
	gen country_v=strmatch(country,"???way")

* Substrayendo elementos:
display substr("Aprendo STATA", 3,6)
display substr("Divergencia", 4,9)
display substr("Qlab-PUCP",-4,.)

	** creando una variable (analizar estos casos)
	gen extraccion1=substr(country,1,3)
	gen extraccion2=substr(country,-3,.)
	
* Identificar casos de la variable que contiene un patrón
list country if regexm(country,"u")
list country if regexm(country,"[i,a]")
list country if regexm(country,"[0-9]")

* Busqueda de patrones en variables string:

	* Elemento en algún lugar:
	list if regexm(country,"(Bol|Per|Uru)")
	list if regexm(country,"land")
	
	* Palabra completa (separada):
	list if inlist(word(country,1),"Bosnia", "Uru")
	list if inlist(word(country,2),"Republic")

	
/*----------------------------
- Transformación de strings --
------------------------------*/

* Cambio de palabras en una string:
display regexr("Aprendo R","R","STATA")
display regexr("Esta es una señal","señal","aplicación")

* Cambio de nombre elementos en una variable string:
replace country=subinstr(country,"Republic","Rep.",.)
	list if inlist(word(country,2),"Rep.")

* Gestión de espacios en variables string:

	* remover espacios en blanco a lo largo del texto:
	display stritrim("Mucho    espacio en     blanco")
	
	gen country_fix=stritrim(country)
	
	* remover espacios en blanco al final e inicio del texto:
	display trim(" Espacio al inicio y final        ")

	gen country_fix2=trim(country)
	
* Gestión de mayúsculas y minúsculas:

	* todo a minúsculas:
	display strlower("Mi TEXTO tiene muchas MAYÚSCULAS")

	* todo a mayúsuculas
	display strupper("Quisiera que todo sea mayúsuculas")

	* Primera palabra en mayúsuculas
	display strproper("argentina bolivia chile")
	
	* aplicaciones en variables:
	gen country_min=strlower(country)
	gen country_max=strupper(country)
	gen country_proper=strproper(country)

* Cambiar a un nombre compatible para variable de STATA:
display strtoname("123_mivariable")
display strtoname("1.Edad")
display strtoname("Norte América")

* Convertir un string a un valor real
display real("500")
display real("100")+real("200")


/*----------------------------
- Cambios de tipos de datos --
------------------------------*/

/*Usaremos esta base de ejemplo que contiene información de autos
usados y sus características*/

webuse auto,clear


* Convertir una variable numérica no codificada a una string:
tostring displacement, gen(dis_string)


* Convertir una variable numérica codificada a una string:
	* Chequeo previo:
	codebook foreign
	tab foreign, nolabel
	decode foreign, gen(foreign_string)

* Convertir una variable string con cifras a una numérica:
destring dis_string, gen(dis_num)


/* En todos los casos anteriores, se pudo usar también 
la opción ,replace sin necesidad de crear una nueva variable,
teniendo en cuenta que será sobreescrita*/


/*----------------------------------
- Formateo de variables numéricas --
------------------------------------*/

/*En muchas ocasiones queremos que nuestras variables numéricas
posean un determinado formato, especialmente en las tablas resumen que 
obtenemos, o en nuestra tabla de datos */

** Revisaremos el formato de la variable "headroom"
describe headroom
br headroom

	* Haremos los cambios pertinentes de formato con justificación
	* a la derecha:
	format headroom %9.2f
	describe headroom
	br headroom

* Ejemplo con gear_ratio justificado  a la izquierda:
describe gear_ratio
format gear_ratio %-9.3f
describe gear_ratio
br gear_ratio

** Aplicación de formato en resultados de tablas:
table foreign, c(mean price) /*solo un decimal */

table foreign, c(mean price) format(%9.3f) /* 3 decimales sin comas*/
table foreign, c(mean price mean mpg) format(%9.3fc) /* 3 decimales con comas*/

** Aplicacion para el comando summarize:
format weight length %9.3fc
sum weight length,format

	* caso de variabls ya formateadas:
	sum headroom gear_ratio
	sum headroom gear_ratio, format


/*------------------------------------------
- Gestión de variables y la base de datos --
------------------------------------------*/

/* Usaremos una base de datos de ejemplo
con información de mujeres trabajadoras de EE.UU. para el año 1988*/

webuse nlsw88,clear

* Comando "keep":

** conservando solo algunas variables:
keep idcode age race married collgrad occupation wage hours ttl_exp

** conservando observaciones según condiciones:
sum age hours
keep if age>=35 & hours>=35
sum age hours
	
	* conservando las observaciones indicadas en una lista:
	keep in 100/200
	* conservando las observaciones en un rango
	keep if inrange(wage,20,30)
	
	* conservando casos de acuerdo a textos en variables string:
	tostring occupation,gen(ocu_string)
	keep if inlist(ocu_string,"Sales","Transport","Laborers")
	tab ocu_string

* Debido a que hemos perdido información, abrimos la base nuevamente:
webuse nlsw88,clear

* Comando "drop":

** eliminando algunas variables:
drop never_married south smsa c_city

** eliminando algunas observaciones según condiciones:
drop if age>40 | tenure==.


* Debido a que hemos perdido información, abrimos la base nuevamente:
webuse nlsw88,clear


** revisando datos no ordenados
li  age wage in 10/20

* ordenando de menor a mayor con sort, y revisando los datos ordenados:
sort age wage
li  age wage in 10/20


* ordenando de mayor a menor con sort(-), y revisando los datos ordenados:
gsort -age -wage
li  age wage in 10/20
browse age wage


** Obtención de una muestra aleatoria:
webuse nlsw88,clear

	* Muestra aleatoria del 20%
	count
	sum
	
	sample 20
	sum


/*-------------------------------
- Transformación de variables  --
--------------------------------*/

* Renombrando variables:
rename idcode identificador

rename (ttl_exp race) (exp raza)


* Cambiando valores de variables (con y sin condiciones)
sum age
replace age=40 if age>=40
sum age

	* creando una dicotómica de salario alto (high_wage)con uso de replace:
	gen high_wage=0
	replace high_wage=1 if wage>30
	
* Recodificación de valores:

	* Valores particulares:
	codebook raza
	recode raza (1=1 "Blanco") (2 3 =0 "No blanco"), gen(white)
	codebook white
	
	* Serie de valores:
	recode exp(20/30=20)
	sum exp
	
* Reemplazo de missing values por un valor determinado:
sum wage tenure
codebook union wage tenure

mvencode _all,mv(9999)
codebook union wage tenure
sum union wage tenure


/*----------------------------------
- Etiquetado de base y variables  --
------------------------------------*/

webuse nlsw88,clear
descr

* Etiquetado de la base:
label data "Base de ejemplo para sesión 2"
describe 

* Etiquetado de variables:
label variable occupation "Ocupación"
codebook occupation


* Etiquetado de valores (creación de etiqueta y aplicación)

gen mayor40=age>40

label define etiq_edad 0 "40 o menos" 1 "Mayor de 40"
label values mayor40  etiq_edad
codebook mayor40

* Codificar variables string a numéricas:

	* Primero crearemos una nueva string, y luego la recodificaremos:
	decode industry,gen(industry_str)
	describe industry industry_str
	
		** Ahora la recodificaremos usando el comando "encode" (orden alfabético)
		encode industry_str, gen(industry_nueva)
		codebook industry_nueva
		br industry industry_nueva
		
		* comparemos los valores:
		codebook industry if industry<=5
	
	codebook industry_nueva if industry_nueva<=5


* Obteniendo lista de las etiquetas creadas:
label list


* Modificación de una etiqueta ya existente:
**label define marlbl 0 "Soltero" 1 "Casado" /*no me permite crearla porque ya existe*/
label define marlbl 0 "Soltero" 1 "Casado",modify

label values married marlbl 


/*------------------------------
- Formateo de bases de datos  --
--------------------------------*/

cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2\Data"

use "reshape",clear
browse

**********
* Reshape* 
**********
	* Pase de "long" a "wide":
	reshape long disbursements obligations, i(category) j(year)
	browse

	* Pase de "wide" a "long"
	reshape wide disbursements obligations, i(category) j(year)

**************
* Transponer *
************** 

	** usaremos una base de datos con puros numéricos:
	webuse xposexmpl,clear
	list

	xpose,clear varname
	list
	
	** ahora una base con una variable string
	use "coffeeMaize",clear
	list
	xpose,clear varname
	list
	

/*-----------------------------
-- Combinando bases de datos -
-------------------------------*/


** Append (apilar):

	* Inspección de las bases:
	use "coffeeMaize",clear
	list 
	use "coffeeMaize2",clear
	list 

	** Apilando:
	use "coffeeMaize",clear
	append using "coffeeMaize2"
	list


** Merge (emparejar):

	*** Emparejamiento 1 a 1 (1:1)

		* Inspección de las bases:
		webuse autosize,clear
		list
		webuse autoexpense
		list
		save autoexpense,replace

		** Emparejando:
		webuse autosize,clear
		merge 1:1 make using "autoexpense"
		list

		* la variable _merge:
		tab _merge
	
	*** Emparejamiento varios a 1 (m:1)

			* Inspección de las bases:
			webuse dollars, clear
			list
			webuse sforce
			list
			save sforce, replace

				** Emparejando:
			webuse dollars, clear
			merge 1:m region using "sforce"
			sort region
			list

/* ---------------------------------------------------------
------------------------------------------------------------*/


/*----------------------------------------------------
-- Aplicaciones con la Encuesta Nacional de Hogares --
-----------------------------------------------------*/

/* Realizaremos la descarga desde la página web del INEI, y posteriormente
se llevará a cabo la descompresión directamente desde el dofile*/

****************
** ENAHO 2019 **
****************

* Módulo 100 (nivel de hogar):

copy http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA/687-Modulo01.zip           687-Modulo01.zip, replace
	unzipfile 687-Modulo01.zip
	
* Módulo Sumaria (nivel de hogar):	
	
copy http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA/687-Modulo34.zip           687-Modulo34.zip, replace
	unzipfile 687-Modulo34.zip

** Formateando las bases a latin:

* Módulo 100:
	cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2\Data\687-Modulo01"
	clear
	unicode analyze enaho01-2019-100.dta
	unicode encoding set "latin1"
	unicode translate enaho01-2019-100.dta
	
* Módulo Sumaria:
	cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2\Data\687-Modulo34"
	clear
	unicode analyze sumaria-2019.dta
	unicode encoding set "latin1"
	unicode translate sumaria-2019.dta


*** Revisión del Módulo 100:

cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2\Data\687-Modulo01"
use	"enaho01-2019-100", clear

keep aÑo conglome vivienda hogar ubigeo dominio estrato result p24a p24b p102 p103 p103a p104 p104a p104b1 p105a p110 p111a p1121 p112a p1142 p1144 factor07

count
browse

** Revisión de duplicados por código de hogar:

	* solo con codigo de hogar:
	duplicates report hogar
	
	* con el codigo de hogar completo
	duplicates report conglome vivienda hogar /* no hay duplicados*/

* Descripción de variables:
describe

** Queremos sabes qué porcentaje de los hogares tiene conexión a Internet
codebook p1144
tab p1144

	* Algunos ajustes a la variable:
	rename p1144 internet
	label define et_internet 0 "Sin Internet" 1 "Con Internet"
	label values internet  et_internet

	* Indicando el diseño complejo de la encuesta usando el factor de expansión para tener un mejor indicador:
	svyset conglome [pweight = factor07] , strata(estrato)
	svy:tab internet
	svy:mean internet

** Definición de una variable que identifique regiones según el código de ubigeo:

    gen region=substr(ubigeo,1,2)
    destring region,replace
    label define region 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" ///
    10 "Huánuco" 11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco"  ///
    20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali" 
    label values region region
	
	** Tabla de conexión a Internet por región:
	table region [pweight = factor07],c(mean internet) format(%9.3f) center row
 	

* Guardamos la base de datos trabajada:
save enaho100_2019.dta,replace


*** Revisión del Módulo Sumaria:
cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2\Data\687-Modulo34"
use	"sumaria-2019", clear

** Conservamos solo algunas variables de interés:
keep conglome vivienda hogar estrsocial pobreza
descr

	* creación de variable dummy de hogar pobre:
	codebook pobreza
	recode pobreza (3=0 "No pobre") (1 2 =1 "Pobre"), gen(hogar_pobre)

* Guardamos la base de datos trabajada:
save enaho_sumaria_2019.dta,replace


/*------------------------------------
-- Unión de Módulo 100 con Sumaria --
------------------------------------*/
/* Como la ENAHO tiene bases a nivel hogar e individual, es importante
conocer que los códigos de identificación para cada caso son:

	Hogar: 		conglome vivienda hogar
	Individuo: 	conglome vivienda hogar codperso*/


* En este caso, nosotros uniremos dos bases a nivle hogar:

cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2\Data\687-Modulo01"

** Abrimos la base del módulo 100
use enaho100_2019.dta,clear

*** cambiamos la ruta:
cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2\Data\687-Modulo34"

*** realizamos el merge con la sumaria trabajada:
merge 1:1 conglome vivienda hogar using "enaho_sumaria_2019.dta"


* Análisis de merge:
	tab _merge
	
	* Conservamos solo los hogares en los que hubo empate:
	keep if _merge==3
	
* Calculamos la tasa de pobreza a nivel de hogar según region:
table region [pweight = factor07],c(mean hogar_pobre) format(%9.3f) center row

* Podemos guardar una tabla en formato csv con esta información usando collapse:
collapse (mean) internet hogar_pobre [pweight = factor07],by(region) 

cd "D:\Trabajo\Docencia\PUCP\QLab\QLab-2022\Stata-Gestion-2022\Sesion_2"
export delimited using "Resumen_regional.csv", replace
