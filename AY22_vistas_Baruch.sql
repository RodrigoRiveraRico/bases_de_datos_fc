/*
=================================
Ayudantía 22: VISTAS
Rodrigo Baruch Rivera Rico
07 noviembre 2024
=================================
*/

-- Antes de empezar: cargar la base world y ponerla en uso
-- \. path\to\script\base_world.sql
-- \u world

/*
¿Qué es una tabla virtual?
>   En términos generales, es una tabla que no se almacena en la base de datos 
    y se computa de alguna forma con el motor de almacenamiento.

¿Qué es una vista?
>   Es un query almacenado que al ser invocado produce un resultado (una tabla virtual).
>   Las vistas permiten visualizar datos de una o más tablas.
>   Las vistas son creadas seleccionado un conjunto de columnas y un conjunto de filas
    de una tabla la cual ha sido filtrada bajo alguna condición.

¿Por qué es útil?
>   En la implementación en una aplicación restringe el acceso a datos críticos a terceros usurarios.
>   Simplifica la obtención de consultas que involucren queries complejos.
>   Simplifica la obtención de consultas repetitivas al definir vistas cuyos queries sean de uso común o recurrente.
*/

-- Ejemplo 1
/*
Veamos primero que una vista muestra los datos actuales de la tabla de donde se obtienen.
*/
-- Creamos la tabla t_de_prueba.
CREATE TABLE IF NOT EXISTS t_de_prueba (cantidad int, precio int);
-- Insertamos dos tuplas.
INSERT INTO t_de_prueba VALUES (3, 50), (4,20);
-- Creamos una vista que nos muestra el precio total.
CREATE OR REPLACE VIEW v_de_prueba AS SELECT cantidad, precio, cantidad*precio AS Total FROM t_de_prueba;
-- Mostramos todo en la vista.
SELECT * FROM v_de_prueba;
-- Insertamos otra tupla en la tabla t_de_prueba.
INSERT INTO t_de_prueba VALUES (10,10);
-- Volvemos a mostrar todo en la vista. Observamos que la vista muestra los datos actuales.
SELECT * FROM v_de_prueba;
-- Mostramos cómo fue creada la vista.
SHOW CREATE VIEW v_de_prueba;
-- Borramos la vista.
DROP VIEW IF EXISTS v_de_prueba;
-- Verificamos que la tabla t_de_prueba no fue afectada al borrar la vista.
SELECT * FROM t_de_prueba;
-- Borramos la tabla.
DROP TABLE IF EXISTS t_de_prueba;

-- Ejemplo 2
/*
Creamos una vista con cálculos estadísticos de la población por continente.
*/
CREATE OR REPLACE VIEW PopulationContinentStatistics AS 
SELECT Continent, MIN(Population) AS MinPopulation, AVG(Population) AS AvgPopulation, MAX(Population) AS MaxPopulation
FROM country
GROUP BY Continent;

/*
Utilizaremos la vista PopulationContinentStatistics para consultar los países que tienen una población mayor al promedio de su continente.
*/
SELECT country.Name AS CountryName, country.Continent, country.Population
FROM country
JOIN PopulationContinentStatistics AS PCS ON country.Continent = PCS.Continent
WHERE country.Population > AvgPopulation
ORDER BY country.Continent; 

/*
Utilizaremos la vista PopulationContinentStatistics para catalogar a los países según si su población supera o no al promedio de su continente.
Si lo supera, lo indicaremos como 'Mucha Gente'.
En caso contrario, lo indicaremos como 'Poca Gente'.
*/
SELECT country.Name AS CountryName, country.Continent, 
    CASE 
        WHEN country.Population > AvgPopulation THEN 'Mucha Gente'
        ELSE 'Poca Gente'
    END AS 'Criterio'
FROM country
JOIN PopulationContinentStatistics AS PCS ON country.Continent = PCS.Continent
ORDER BY country.Continent;
-- Con este ejemplo mostramos una de las utilidades de las vistas:
-- Simplifica la obtención de consultas repetitivas al definir vistas cuyos queries sean de uso común o recurrente.
-- En la vista PopulationContinentStatistics guardamos el query que genera información estadística que puede ser de uso recurrente.

-- Ejemplo 3
/*
Creamos una vista para listar los países de un continente en específico.
Nos interesa mostrar el nombre del país, su población y área superficial de los países de América del Sur.
*/
CREATE OR REPLACE VIEW SouthAmericaCountries AS
SELECT Name AS CountryName, Population, LPAD(FORMAT(SurfaceArea, 0), LENGTH('SurfaceArea (km^2)'), ' ') AS 'SurfaceArea (km^2)'
FROM country
WHERE Continent = 'South America';
-- Esta vista almacena una consulta que nos duelve el área superficial con formato.
SELECT * FROM SouthAmericaCountries;
-- Observar que las columnas de la vista están renombradas. 
-- ¿Cómo seleccionamos columnas cuyos nombres tienen espacios?
-- Empleamos la tílde invertida (`)
SELECT CountryName, `SurfaceArea (km^2)` FROM SouthAmericaCountries;

-- Ejemplo 4
/*
Creamos una vista con subconsultas.
Nos interesa conocer el número de ciudades de los países que están registrados en la tabla `country`.
En caso de faltar algún dato, indicarlo con N/A.
*/
CREATE OR REPLACE VIEW CitiesXCountry AS
SELECT Name AS CountryName, IFNULL(CityCount, 'N/A') AS CityCount
FROM country
LEFT JOIN (SELECT CountryCode, COUNT(*) AS CityCount FROM city GROUP BY 1) AS R ON Code = CountryCode 
ORDER BY R.CityCount;
-- Esta vista almacena una consulta que nos indica con N/A los países que no tienen ciudades registradas en la tabla `city`.
SELECT * FROM CitiesXCountry;

-- Ejemplo 5
/*
A partir de la vista anterior (CitiesXCountry) obtener los países que no tienen ciudades registradas.
*/
SELECT * FROM CitiesXCountry WHERE CityCount = 'N/A';
-- Este ejemplo junto con el anterior mostramos otra de las utilidades de las vistas:
-- Simplifica la obtención de consultas que involucren queries complejos. Ya no es necesario volver a escribir el query definido en la vista.

-- Ejemplo 6
/*
Queremos una vista que muestre el nombre del país, su continente, las ciudades que lo componen en un arreglo JSON y generar un objeto JSON tal que
las llaves sean el idioma y los valores la indicación de si el idioma es oficial 'T' o no lo es 'F', tal como se indica en la columna `IsOfficial`,
de los países que cuenten con registro tanto en `city` como en `countrylanguage`.
*/
CREATE OR REPLACE VIEW JSON_OBJJ_Country AS
SELECT 
    B.Name AS CountryName,
    B.Continent,
    JSON_ARRAYAGG(C.Name) AS CityArray,
    D.LanguageObject
FROM
    country AS B 
JOIN
    city AS C ON B.Code = C.CountryCode
JOIN
    (SELECT 
        CountryCode,
        JSON_OBJECTAGG(Language, IsOfficial) AS LanguageObject
    FROM
        countrylanguage
    GROUP BY CountryCode) AS D ON B.Code = D.CountryCode
GROUP BY B.Code;
-- Ya teniendo la vista creada es fácil obtener la consulta de cada país simplemente haciendo un WHERE.
SELECT * FROM JSON_OBJJ_Country WHERE CountryName = 'mexico'\G
SELECT * FROM JSON_OBJJ_Country WHERE CountryName = 'jamaica'\G
SELECT * FROM JSON_OBJJ_Country WHERE CountryName = 'peru'\G

/*
Borramos de forma segura las vistas creadas.
*/
DROP VIEW IF EXISTS PopulationContinentStatistics, SouthAmericaCountries, CitiesXCountry, JSON_OBJJ_Country;
