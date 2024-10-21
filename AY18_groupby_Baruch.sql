/*
=================================
Ayudantía 18: Group By
Rodrigo Baruch Rivera Rico
22 octubre 2024
=================================
*/

-- Antes de empezar: cargar la base world y ponerla en uso
-- \. path\to\script\base_world.sql
-- \u world

/*
Si durante la ejecución de las consultas SQL aparece el siguiente error:

Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'db.table.col' 
which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by

Hay que correr el siguiente comando para deshabilitar la función ONLY_FULL_GROUP_BY:

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

Finalmente hay que reiniciar la consola (cerrar y volver a abrir).
*/

/*
Recordemos que la sentencia GROUP BY agrupa las filas que tienen los mismos valores en filas resumen.

La sentencia GROUP BY se utiliza a menudo con funciones de agregación 
(COUNT(), MAX(), MIN(), SUM(), AVG()) 
para agrupar el conjunto de resultados por una o más columnas.
*/

/*
Metadata:
-> La tabla `city` tiene registros de ciudades con una llave foránea `CountryCode` que indica el país al que pertenecen.
-> La tabla `countrylanguage` tiene registros de los idiomas hablados en diferentes países con una llave foránea `CountryCode` que indica el país en cuestión.
*/

/*
Queremos agrupar las ciudades por país y contar cuántas ciudades tiene cada uno.
*/
SELECT CountryCode, COUNT(*) AS NumCities
FROM city
GROUP BY CountryCode;

/*
Queremos agrupar las ciudades por país y obtener la población máxima de cada país.
*/
SELECT CountryCode, MAX(Population) AS MaxCityPopulation
FROM city
GROUP BY CountryCode;
-- Para obtener a su vez el nombre de la ciudad con la población máxima de cada país hay que hacer uso de subconsultas o JOIN. Temas que se verán más adelante.

/*
Queremos agrupar las ciudades por país y obtener la población mínima de cada país.
*/
SELECT CountryCode, MIN(Population) AS MinCityPopulation
FROM city
GROUP BY CountryCode;
-- Para obtener a su vez el nombre de la ciudad con la población mínima de cada país hay que hacer uso de subconsultas o JOIN. Temas que se verán más adelante.

/*
Queremos agrupar las ciudades por país 
y obtener la suma las poblaciones de todas las ciudades para obtener la población total de cada país.
*/
SELECT CountryCode, SUM(Population) AS TotalCityPopulation
FROM city
GROUP BY CountryCode;

/*
Queremos agrupar las ciudades por país y calcular el promedio de la población de las ciudades en cada país.
*/
SELECT CountryCode, AVG(Population) AS AvgCityPopulation
FROM city
GROUP BY CountryCode;

/*
Queremos agrupar las ciudades por país y obtiene múltiples métricas: 
el número total de ciudades, la población máxima, mínima, total y promedio por país.
*/
SELECT CountryCode, 
       LPAD(FORMAT(COUNT(*), 0), LENGTH('NumCities'), ' ') AS NumCities, 
       LPAD(FORMAT(MAX(Population), 0), LENGTH('MaxCityPopulation'), ' ') AS MaxCityPopulation, 
       LPAD(FORMAT(MIN(Population), 0), LENGTH('MinCityPopulation'), ' ') AS MinCityPopulation, 
       LPAD(FORMAT(SUM(Population), 0), LENGTH('TotalCityPopulation'), ' ') AS TotalCityPopulation, 
       LPAD(FORMAT(AVG(Population), 1), LENGTH('AvgCityPopulation'), ' ') AS AvgCityPopulation
FROM city
GROUP BY CountryCode;

/*
GROUP_CONCAT()
Función que devuelve un resultado de cadena con valores no nulos concatenados de un grupo.
Devuelve NULL si no hay valores no nulos.
*/

/*
Queremos listar las ciudades de cada país en un formato concatenado.
*/
SELECT CountryCode, GROUP_CONCAT(Name) AS Cities
FROM city
GROUP BY CountryCode
LIMIT 10;
-- Limitamos los registros a 10 para reducir los resultados en pantalla.

/*
Para tener una mejor visualización cuando los resultados son demasiado anchos para la ventana actual,
terminamos la sentencia con \G en lugar de ;
Esto hace que los conjuntos de resultados se muestren verticalmente.
*/
SELECT CountryCode, GROUP_CONCAT(Name) AS Cities
FROM city
GROUP BY CountryCode
LIMIT 10 \G
-- Limitamos los registros a 10 para reducir los resultados en pantalla.

/*
La función GROUP_CONCAT() admite las siguientes opciones:
GROUP_CONCAT(Name ORDER BY Name ASC SEPARATOR ' <-> ')
Al usar ORDER BY hacemos que el formato concatenado esté ordenado.
Por default, el separador es una coma (,)
El separador se puede cambiar al especificarlo con SEPARATOR.
*/
SELECT CountryCode, GROUP_CONCAT(Name ORDER BY Name ASC SEPARATOR ' <-> ') AS Cities
FROM city
GROUP BY CountryCode 
LIMIT 10 \G
-- Limitamos los registros a 10 para reducir los resultados en pantalla.

/*
JSON_ARRAYAGG()
Función que agrega un conjunto de resultados como un único arreglo JSON cuyos elementos consisten en las filas.
La función actúa sobre una columna o una expresión que se evalúa a un único valor.
*/

/*
Queremos obtener un arreglo JSON de todas las ciudades de cada país.
*/
SELECT CountryCode, JSON_ARRAYAGG(Name) AS CitiesArray
FROM city
GROUP BY CountryCode
LIMIT 10 \G
-- Limitamos los registros a 10 para reducir los resultados en pantalla.

/*
JSON_OBJECTAGG()
Función que toma dos columnas o expresiones como argumentos,
el primero de los cuales se utiliza como llave y el segundo como valor,
y devuelve un objeto JSON que contiene pares llave-valor.
*/

/*
Queremos crear un objeto JSON que asocie el nombre de la ciudad con su población para cada país.
*/
SELECT CountryCode, JSON_OBJECTAGG(Name, Population) AS CityPopulationObject
FROM city
GROUP BY CountryCode
limit 10 \G
-- Limitamos los registros a 10 para reducir los resultados en pantalla.

/*
WHERE vs HAVING
La cláusula HAVING, al igual que la cláusula WHERE, especifica condiciones de selección. 
La cláusula WHERE especifica las condiciones de las columnas de la lista de selección, 
pero no puede hacer referencia a funciones de agregación. 
La cláusula HAVING especifica condiciones sobre grupos, normalmente formados por la cláusula GROUP BY. 
El resultado de la consulta sólo incluye los grupos que cumplen las condiciones de HAVING. 
(Si no hay ninguna cláusula GROUP BY, todas las filas forman implícitamente un único grupo agregado).

La clave está en que WHERE se usa para filtrar filas antes de que se realice la agregación, 
mientras que HAVING filtra los grupos resultantes después de la agregación.
*/


