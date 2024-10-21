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
La tabla `city` tiene registros de ciudades con una llave foránea `CountryCode` que indica el país al que pertenecen.
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

/*
Queremos agrupar las ciudades por país y obtener la población mínima de cada país.
*/
SELECT CountryCode, MIN(Population) AS MinCityPopulation
FROM city
GROUP BY CountryCode;

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
