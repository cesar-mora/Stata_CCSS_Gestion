/*-------------------------------
----QLAB - PUCP -----------------
-- STATA para Ciencias Sociales--
-- y Gestión Pública--------- ---
---- Sesión 1 -------------------
-- Introducción y procesamiento--
-- de datos ---------------------
---------------------------------
-- César Mora - 2022 ------------
----------------------------------*/

/*----------------
- Configuración --
------------------*/

* Inspección de directorio de trabajo:
pwd

* Establecimiento de un directorio - current directory (cd) - Carpeta "Data":
cd "..."

* Revisión de carpetas y archivos en el directorio:
dir

	* archivos de tipo particular:
	dir *.dta
	dir *.csv 

* Creación de "log files" para guardar los resultados que se muestren en la ventana principal:

log using "Mi_logfile.log"

/// En un log file se guardarán todos los resultados que mostrados en la respectiva ventana:	

webuse auto,clear

tab foreign

summarize

/// Al culminar nuestro trabajo podemos cerrar el log file y estará listo para que lo revisemos:
log close


/* Comentarios como este pueden ser escritos 
   en varias líneas
   sin necesidad de colocar asteriscos en cada línea */
  
* Se puede usar /// al final de cada línea para que un comando pueda ser escrito en varias líneas y ser ejecutado sin problemas:

summarize weight length mpg price trunk
summarize weight length ///
  mpg price ///
  trunk

  
* Limpiamos nuestro espacio de trabajo con "cls":
cls 

* Instalación de comandos nuevos:
**ssc install nuevocomando
ssc install outreg2
ssc install mdesc
  
/*---------------------------------
-- Importación de bases de datos --
---------------------------------*/

* Cargando base en formato Stata desde el disco duro:
use "hs0stata"

* Limpiando la memoria del programa (cuando ya se tiene cargada una base de datos)
clear

* Cargando una tabla de excel:
import excel using "hs0_excel.xlsx",sheet("Hoja2") firstrow clear

	* Colocación de la opción "firstrow" para colocar encabezados:
	import excel using "hs0_excel.xlsx",sheet("Hoja2") firstrow clear
	
	* Opción para cargar solo una subtabla:
	import excel using "hs0_excel.xlsx",sheet("Hoja1") cellrange(A1:F51) firstrow clear
	
* Cargando un csv:
import delimited using "hs0.csv", clear

	* Opción para cargar solo una subtabla:
	import delimited using "hs0.csv", colrange(1:5) rowrange(1:20) clear


* Cargando base de datos spss:
import spss "mi_base_spss.sav",clear	
	
	
* Cargando base en formato Stata desde la web:
use https://stats.idre.ucla.edu/stat/data/hs0,clear

	/*---------------------------------
	-- Help files----------------------
	---------------------------------*/

	* Revisar el help para el comando "summarize"
	help summarize

	* Summarize para todas las variables
	summarize

	* Summarize para variables elegidas (usando la abreviatura "summ")
	summ read write

	* Summarize con detalles adicionales:
	summ read, detail
	summ read write, detail

* -------------------------

/* De ahora en adelante trabajaremos con una base de datos de la Plataforma Nacional de Datos Abiertos del Estado Peruano.
En particular, cargaremos el listado de hospitalizados por COVID-19, con indicadores de vacunación y fallecimientos
el cual se encuentra disponible en: https://www.datosabiertos.gob.pe/dataset/hospitalizados-vacunados-y-fallecidos-por-covid-19 */


import delimited using https://cloud.minsa.gob.pe/s/BosSrQ5wDf86xxg/download,clear


/*-------------------------------
-- Exploración de los datos -----
---------------------------------*/

* Contabilizar número de observaciones:
count

* Inspección de la tabla cargada:
browse

* Listado de variables:
ds 

	* Listado de variables (solo string):
	ds, has(type string)
	* Listado de variables (solo integer):
	ds, has(type int)

* Descripción y presentación del listado de variables (tipo, formato, etiquetas en caso las haya)
describe

* Búsqueda de palabras en la carga (lookfor)
lookfor vacuna posit

* Revisar si una variable identifica solo a una observacion (isid):
isid eess_diresa
isid id_persona

/*--------------------------------
-- Distribución de los datos -----
---------------------------------*/

* Inspección con codebook (tipo de variable, estadísticas, número de missings y valores únicos)

	* general:
	codebook 
	* variables seleccionadas:
	codebook eess_diresa edad

* Resumen estadístico con summarize (general y para variables seleccionadas)
summarize
summ edad flag_uci

	* Summarize al detalle:
	sum edad,detail
	sum flag_vacuna,detail

* Inspección con un histograma básico:
inspect edad
inspect flag_vacuna

/*------------------------------------------------------
-- Vista de las observaciones en la tabla de datos -----
--------------------------------------------------------*/

* Mostrar una observación particular:
display edad[25]
display sexo[75]

* Muestra de valores únicos para una variable:
levelsof edad
levelsof eess_diresa

* Lista de variables seleccionadas para las cinco primeras observaciones:
list id_persona edad sexo flag_uci flag_vacuna in 1/5

* Lista para ...:
li id_persona edad sexo flag_uci in 10/20

* Lista de edad para las últimas 5 observaciones:
li edad in -5/L

* Lista de sexo para las últimas 15 observaciones:
li sexo in -10/L

	** Opción if para reducir las listas:

	* Lista de sexo, edad e indicador de fallecimiento para los casos en los que la ///
	/// edad 	es mayor que 60 (observaciones de 1 a 50)
	list sexo edad cdc_fallecido if edad>65 in 1/50

	* Lista de sexo y flag_vacuna para los casos en los que edad es missing (observaciones de 1 a 50):
	list edad flag_vacuna if edad==. in 1/50
	list edad flag_vacuna if missing(edad) in 1/50


* Browse de variables edad flag_uci y flag_vacuna para mujeres (sexo=="F") con edad mayor a 60 años
browse edad flag_uci flag_vacuna if sexo=="F" & edad>60

* Informe de observaciones duplicadas:
duplicates report
display 465+6

* Eliminando los duplicados:
duplicates drop


/*------------------------
* Ordenando información --
--------------------------*/

** revisando datos no ordenados
br id_persona edad sexo
list id_persona edad sexo in 1/10

* ordenando de menor a mayor con sort, y revisando los datos ordenados:
sort id_persona edad
list id_persona edad sexo in 1/10

sort edad
list id_persona edad sexo in 1/10


* ordenando de mayor a menor con gsort(-), y revisando los datos ordenados:
gsort -id_persona 
list id_persona edad sexo in 1/10

gsort -edad
list id_persona edad sexo in 1/10


/*------------------------
- Creación de variables --
--------------------------*/

* Comando generate:
gen edad_cuadrado=edad^2

gen oxigeno_ventilacion=con_oxigeno+con_ventilacion

	* Creacion de binaria con generate byte:
	gen byte adulto_mayor=edad>60
	codebook adulto_mayor
	sum adulto_mayor
	
	* creacion de un índice
	gen indice=_n

	* creacion de un índice por grupo (sexo):
	bysort sexo: gen indice_sexo=_n
	codebook indice_sexo
	br sexo indice_sexo
	
	* Creacion de un indicador de número de observaciones:
	gen casos=_N

	* Creacion de un indicador de número de observaciones por grupo (evolucion hospitalaria)
	bysort evolucion_hosp: gen casos_evolucion=_N
	codebook casos_evol
	br evolucion_hosp casos_evol

* Comando xtile para crear "x-tiles" de una variable:
xtile quintil_edad=edad, nq(5)
codebook quintil_edad

* Creación de dummies e interacciones entre variables:

	* Dicotómica bajo una o más condiciones
	gen mayor50=edad>50 & edad!=.
	codebook mayor50
	
	gen mujer_mayor50=edad>50 & edad!=. & sexo=="F"
	codebook mujer_mayor50

* Creación de dummies o categóricas binarias:

	* usando tabulados:
	tab fabricante_dosis1
	tab fabricante_dosis1, gen(empresa)
	sum empresa*

	* usando el comando xi:
	tab evolucion_hosp
	xi i.evolucion_hosp, noomit
	sum _Ievolucion*
	
	/* Creación de interacciones con xi: producto entre variables, para obtener obs. que 
	comparten caracteristicas*/
	
	xi: i.con_oxigeno*i.flag_uci,noomit
	
	sum _IconXfla_1_1
	tab con_oxigeno flag_uci,cell
	

* Creación de variables con funciones extendidas (comando "egen"):

** egen (mean)
egen prom_edad=mean(edad)
egen prom_edad_sexo=mean(edad),by(sexo)

** egen (rowmean): crea el promedio de la fila de variables especificadas
egen muestra_promedio = rowmean(flag_uci con_ventilacion con_oxigeno)
summarize flag_uci con_ventilacion con_oxigeno muestra_promedio

	* El caso de sumar las variables manualmente:
	gen suma_prueba=edad+flag_vacuna
	codebook edad flag_vacuna suma_prueba
	br edad flag_vacuna suma_prueba
	
	* Si utilizamos la funcion egen (rowtotal) evitamos el problema de perder el resultado:
	egen suma_prueba2=rowtotal(edad flag_vacuna)
	codebook edad flag_vacuna suma_prueba2
	br edad flag_vacuna suma_prueba2
	
** egen (rowtest) estandariza la variable indicada:
egen z_vacuna = std(flag_vacuna)
summarize z_vacuna,detail
	

/*--------------------------------------
-- Resúmenes informativos con tablas ---
----------------------------------------*/

* Tabla de una entrada:
tabulate eess_diresa


* Tabla de doble entrada:
tabulate evolucion_hosp sexo

	** Incluyendo porcentaje por fila y/o columna:
	tab evolucion_hosp sexo
	tab evolucion_hosp sexo, col
	tab evolucion_hosp sexo, row
	tab evolucion_hosp sexo, col row

**Incluyendo missing values:
tab sexo,missing
tabulate eess_diresa sexo,m
	
* Tabulación por categorías:
bysort sexo: tab evolucion_hosp
bysort flag_uci: tab evolucion_hosp


* Tabla compacta de indicadores estadísticos (tabstat)
tabstat flag_vacuna edad, stat(n mean)

	** Por categorías:
	tabstat flag_vacuna edad, by(sexo) stat(n mean)
	tabstat flag_vacuna edad, by(evolucion_hosp) stat(mean sd)
	tabstat flag_vacuna edad, by(evolucion_hosp) stat(mean sd) format(%9.2f)
	
* Tabla flexible de indicadores estadísticos:
table sexo, content(mean edad)
table flag_uci sexo, content(mean edad)
table flag_uci sexo, content(mean edad) col row

* Tabla multinivel:
table (evolucion_hosp) (flag_uci sexo)
table (evolucion_hosp) (flag_uci sexo), content(mean edad)
table (evolucion_hosp) (flag_uci sexo), content(mean edad) format(%9.2f)


* Tablas colapsadas para guardar como bases de datos:
collapse (count) id_persona (mean) edad flag_vacuna,by(eess_diresa)

* Guardado de la tabla como dataset en diversos formatos:

	* En formato Stata:
	save "data_trabajada",replace
	
	* En formato Excel:
	export excel "data_trabajada.xlsx", firstrow (variables) replace	
	export excel "data_trabajada_.xlsx", firstrow (variables) sheet(mi_hoja) replace	

	* En formato csv:
	export delimited "data_trabajada.csv", delimiter (",") replace

	/* No obstante, si queremos volver a la base original, tendremos que abrirla de nuevo
	probablemente perdiendo todo el trabajo que habíamos hecho si no lo guardabamos como una
	nueva base con un nombre particular.
	
	Si queremos usar el comando collapse u otros regresando a las versiones originales, podríamos
	usar las opciones "preserve" y "restore" que nos permiten preservar y reestablecer la tabla
	con la que estabamos trabajando antes de hacerle el cambio*/
	

/*---------------------------------
-- Preservación y restauración  ---
----------------------------------*/	

import delimited using https://cloud.minsa.gob.pe/s/BosSrQ5wDf86xxg/download,clear

* Conservamos una base con solo 9 variables, y solo los casos que tengan información sobre edad:
keep eess_diresa id_persona edad sexo flag_uci con_oxigeno con_ventilacion evolucion_hosp flag_vacuna
drop if edad==.
browse

** Procederemos a obtener una tabla resumen, guardarla, y luego reestablecer la base con la que estabamos trabajando

preserve
collapse (mean) edad flag_vacuna,by(eess_diresa sexo)
save "resumen2",replace
restore

browse
	/* Confirmamos que la base resumen fue creada y guardada, y en STATA continua
	cargada la base con la que estabamos trabajando antes de hacer el collapse */
	

/*----------------------------------------------------------------------------*/

/*----------------------
-- Ejercicio aplicado --
------------------------*/
/*
	Use la base de datos de instituciones educativas que reciben el Programa Qali Warma, cuyo link de acceso es:
	https://www.datosabiertos.gob.pe/sites/default/files/ListadoInstitucionesEducativasPublicas-2022-04-22.csv 

	* Determina cuántos valores únicos tiene la variable “provincia”
	* Contabiliza y elimina las observaciones duplicadas
	* Obtener un tabulado de registros de instituciones educativas por departamento
	* ¿Cuál es el promedio de usuarios (nrousuarios) en las escuelas de Cusco?
	* Obtener una base de datos resumen que contenga una variable que indique el nivel de usuarios a nivel de departamento y provincia. 
	Pista: usar el comando collapse, con la opción (sum) y el agrupamiento by(departamento provincia)
	
	* Exportar la base de datos resumen obtenida en formato Excel, en una hoja llamada “Usuarios”, en la que claramente la primera fila 
	indique el nombre de las variables.
	
*/

* Importación de la base desde la web:
import delimited using https://www.datosabiertos.gob.pe/sites/default/files/ListadoInstitucionesEducativasPublicas-2022-04-22.csv,clear


