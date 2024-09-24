/*
=================================
Ayudantía 15: SELECT y WHERE
Rodrigo Baruch Rivera Rico
26 septiembre 2024
=================================
*/

-- Antes de empezar: cargar la base world y ponerla en uso
-- \. path\to\script\base_world.sql
-- \u world

/* 
Recordemos que el comando SELECT permite mostrar los registros de las tablas.
*/

/* 
Veamos qué tablas existen:
*/
SHOW TABLES;

/* 
Veamos qué columnas hay en la tabla country:
*/
DESC country;

/* 
Para mostrar todos los registros que hay en esta tabla:
*/
SELECT ALL FROM country;
-- Lo cual es equivalente a:
-- SELECT * FROM country;
-- Observamos que tenemos 239 registros en esta tabla.

/* 
Para mostrar todos los registros que hay en una columna en particular de la tabla, la indicamos en el SELECT.
Mostremos todos los registros que hay en las columnas Name, Continent y Population:
*/
SELECT Name, Continent, Population FROM country;

/* 
El resultado anterior lo podemos ordernar indicado si será de forma ascendente o descendente en función de alguna columna de la tabla:
Por default, el ORDER BY es ascendente.
*/
SELECT Name, Continent, Population FROM country ORDER BY Population;
-- Lo cual es equivalente a:
-- SELECT Name, Continent, Population FROM country ORDER BY Population ASC;
-- Lo cual es equivalente a:
-- SELECT Name, Continent, Population FROM country ORDER BY 3;
-- El dígito 3 indica que se usará la tercera columna indicada en el SELECT para ordenar. Nuevamente, por default, será de forma ascendente.


/* 
Observamos que la columna Continent tiene registros repetidos. 
Nos interesa saber cuántos continentes están registrados en el total de los 239 registros de la tabla.
*/
SELECT DISTINCT Continent FROM country;
-- Observamos que tenemos 7 continentes registrados entre el total de los 239 resgistros de la tabla.
-- ¿Qué pasa si intentamos ordernar por continente? Hint: Tipo de dato de la columna es ENUM()

/*
Queremos ver solo los registros de los países con su población.
Queremos ordernar en función de la población de forma descendente:
*/
SELECT Name, Population FROM country ORDER BY 2 DESC;

/*
Si queremos obtener un cierto número N de registros, tenemos que usar LIMIT al final de la consulta.
Del ejemplo anterior, solo queremos los primero 3 registros.
*/
SELECT Name, Population FROM country ORDER BY 2 DESC LIMIT 3;
-- Con LIMIT obtuvimos los primeros tres países con mayor población.

/*
Si queremos obtener los registros de una tabla bajo una condición, usamos la cláusula WHERE.
*/

/*
¿Qué países están en América del Sur?
*/
SELECT Name FROM country WHERE Continent = 'South America';

/*
¿Qué países empiezan con la letra W?
*/
SELECT Name FROM country WHERE Name LIKE 'W%';

/*
¿Qué países tienen una W en su nombre?
*/
SELECT Name FROM country WHERE Name like '%W%';
-- Observamos que en los resultados también aparecen países que empiezan con W.

/*
¿Qué países tiene una W en su nombre pero no empiezan con W?
*/
SELECT Name FROM country WHERE Name like '%W%' AND Name NOT LIKE 'W%';

/*
¿Qué países tuvieron su independencia después del año 1980?
*/
-- DESC country;
SELECT Name, IndepYear FROM country WHERE IndepYear > 1980;

/*
¿Qué países tuvieron su independecia entre 1960 y 1980?
*/
SELECT Name, IndepYear FROM country WHERE IndepYear >= 1960 AND IndepYear <= 1980;
-- Notemos que el mínimo y el máximo son inclusivos.
-- Lo cual es equivalente a:
-- SELECT Name, IndepYear FROM country WHERE IndepYear BETWEEN 1960 AND 1980;

/*
¿Qué países que tienen W en su nombre pero no empiezan con W tuvieron su independencia entre 1960 y 1980 y están ubicados en el continente africano?
Ordernar por población de forma descendente.
*/
SELECT 
    Name, IndepYear, Population, Continent 
FROM 
    country 
WHERE 
    Name like '%W%' 
    AND Name NOT LIKE 'W%'
    AND IndepYear BETWEEN 1960 AND 1980
    AND Continent = 'Africa'
ORDER BY 
    Population DESC;

/*
¿Qué países están tanto en América del Norte como en América del Sur?
*/
SELECT Name, Continent FROM country WHERE Continent = 'North America' OR Continent = 'South America';
-- Lo cual es equivalente a:
-- SELECT Name, Continent FROM country WHERE Continent IN ('North America', 'South America');

/*
Del resultado anterior nos interesa ver los primero 10 registros ordenados por nombre de Z a A.
*/
SELECT Name, Continent FROM country WHERE Continent like 'North%' OR Continent like 'South%' ORDER BY 1 DESC LIMIT 10;

/*
¿Qué países tienen la letra O en la segunda posición del nombre?
*/
SELECT Name, Continent FROM country WHERE Name like '_o%';

/*
¿Qué países tienen la letra O en la segunda posición del nombre y están tanto en América del Norte como en América del Sur?
*/
SELECT 
    Name, Continent 
FROM
     country 
WHERE 
    Name like '_o%'
    AND (Continent like 'North%' OR Continent like 'South%');
-- ¿Qué resultado se obtiene si quitamos los paréntesis?
