/*
=================================
Ayudantía 20: INNER JOIN
Rodrigo Baruch Rivera Rico
29 octubre 2024
=================================
*/

-- Antes de empezar: cargar la base world y ponerla en uso
-- \. path\to\script\base_world.sql
-- \u world

/*
Recordemos que:
La cláusula JOIN se utiliza para combinar filas de dos o más tablas, basándose en una columna relacionada entre ellas.
*/

/*
Metadata:
-> La tabla `country` tiene registros de países. La columna `Code` es llave primaria que indica el código del país y a esta columna se hace referencia en las tablas `city` y `countrylanguage`.
-> La tabla `city` tiene registros de ciudades con una llave foránea `CountryCode` que indica el país al que pertenecen.
-> La tabla `countrylanguage` tiene registros de los idiomas hablados en cada país. La llave foránea `CountryCode` hace referencia al país en cuestión.
-> La columna `Capital` en la tabla `country` se relaciona con la columna `ID` de la tabla `city` para obetener la capital de cada país.
*/

-- IMPORTANTE -- 
/*
En MySQL, JOIN e INNER JOIN son equivalentes sintácticos (pueden sustituirse entre sí).
En SQL estándar, no son equivalentes.
En general, los paréntesis pueden ignorarse en expresiones join que sólo contengan operaciones inner join.

Con inner join se pueden usar indistintamente las cláusulas ON y USING.
Lo anterior no es cierto para outer join.
(https://dev.mysql.com/doc/refman/8.4/en/join.html)
*/

-- Ejemplo 1 (INNER JOIN)
/*
Queremos obtener información sobre países y sus ciudades:
Nos interesa saber tanto el nombre del país como el de sus ciudades considerando solo las ciudades que empiezan con X.
*/
SELECT country.Name AS CountryName, city.Name AS CityName
FROM country
INNER JOIN city ON country.Code = city.CountryCode
WHERE city.Name like 'X%'
;
-- Notemos que tanto en la tabla `country` como en `city` hay una columna que se llama igual en ambas: `Name`.
-- Para evitar ambigüedades se hace referencia al nombre de la tabla que se usará.
-- Se realiza un INNER JOIN entre `country` y `city` usando la columna `Code` de `country` y `CountryCode` de `city` como condición de coincidencia.
-- Esto devuelve solo las combinaciones donde hay una correspondencia en ambas tablas.

-- Ejemplo 2 (JOIN <-- equivalente a INNER JOIN)
/*
Modificar el QUERY anterior con JOIN.
*/
SELECT country.Name AS CountryName, city.Name AS CityName
FROM country
JOIN city ON country.Code = city.CountryCode
WHERE city.Name like 'X%'
;
-- Dado que estamos usando MySQL, pudemos cambiar JOIN por INNER JOIN en el QUERY y obtener el mismo resultado.

-- Ejemplo 3 (JOIN)
/*
Queremos obtener las combinaciones entre ciudades e idiomas:
Nos interesa la combinación de Jamaica, país cuyo código es 'JAM'.
*/
SELECT city.CountryCode, city.Name AS CityName, countrylanguage.Language
FROM city
JOIN countrylanguage ON city.CountryCode = countrylanguage.CountryCode
WHERE city.CountryCode = 'JAM'
;
-- El QUERY anterior devuelve las combinaciones donde hay una correspondencia en ambas tablas mediante la columna en común `CountryCode`.
-- Nótese que se puede usar indistintamente `city.CountryCode` y `countrylanguage.CountryCode` en el SELECT.

-- Ejemplo 4 (JOIN ... USING)
/*
Modificar el QUERY anterior con USING.
*/
SELECT city.CountryCode, city.Name AS CityName, countrylanguage.Language
FROM city
JOIN countrylanguage USING (CountryCode)
WHERE city.CountryCode = 'JAM'
;
-- En USING se indica la columna en común `CountryCode`.
-- Nótese que el nombre de la columna en USING debe ser idéntico en ambas tablas.

-- Ejemplo 5 (NATURAL JOIN <-- equivalente a JOIN ... USING)
/*
Modificar el QUERY anterior con NATURAL JOIN.
*/
SELECT city.CountryCode, city.Name AS CityName, countrylanguage.Language
FROM city
NATURAL JOIN countrylanguage
WHERE city.CountryCode = 'JAM'
;
-- Aquí NATURAL JOIN encuentra automáticamente la columna en común `CountryCode`.

-- Ejemplo 6 (JOIN con múltiples tablas)
/*
Tomando el QUERY del ejemplo 5 uniremos `country`, `city` y `countrylanguage` 
para mostrar el nombe del país, su continente y las combinaciones entre ciudades e idiomas del país en cuestión (el cual es Jamaica).
*/
SELECT ciudad.CountryCode, pais.Name AS CountryName, pais.Continent, ciudad.Name AS CityName, idioma.Language
FROM city AS ciudad
NATURAL JOIN countrylanguage AS idioma
JOIN country AS pais ON ciudad.CountryCode = pais.Code
WHERE ciudad.CountryCode = 'JAM'
;
-- Notemos que hemos etiquetado a la tabla `country` como `pais`, a la tabla `city` como `ciudad` y a la tabla `countrylanguage` como `idioma`.
-- Estas etiquetas son utilizadas en las cláusulas ON, WHERE y SELECT.

-- Ejemplo 7 (JOIN)
/*
Queremos mostrar los idiomas de cada país:
Nos interesa saber tanto el país como los idiomas que se hablan en dicho país considerando solo los países que empiezan P.
*/
SELECT pais.Name AS CountryName, idioma.Language
FROM country AS pais
JOIN countrylanguage AS idioma ON pais.Code = idioma.CountryCode
WHERE pais.Name like 'P%'
;

-- Ejemplo 8 (JOIN)
/*
Queremos mostrar las capitales de cada país:
Nos interesa saber el nombre tanto de la capital como del país, así como de la población hay en cada capital.
*/
SELECT pais.Name AS CountryName, ciudad.Name AS CityName, ciudad.Population
FROM country AS pais
JOIN city AS ciudad ON pais.Capital = ciudad.ID
;

-- Ejemplo 9 (JOIN con función de agregación)
/*
Queremos obtener el nombre del país y el total de idiomas registrados.
*/
SELECT Name AS CountryName, COUNT(Language) AS TotalLanguage
FROM country
INNER JOIN countrylanguage ON Code = CountryCode
GROUP BY Code
ORDER BY 2
;
-- Esta consulta une `country` y `countrylanguage` y agrupa los idiomas de cada país, calculando el total de idiomas registrados por país.
-- Nótese que no hubo necesidad de indicar en SELECT, ON o GROUP BY el nombre de la tabla de las respectivas columnas pues todo el QUERY está libre de ambigüedades.

-- Ejemplo 10 (JOIN con subconsulta)
/*
Queremos agrupar las ciudades por país y obtener la población mínima de cada país.
*/
SELECT CountryCode, MIN(Population) AS MinCityPopulation
FROM city
GROUP BY CountryCode
;
/* 
Obtener a su vez el nombre de la ciudad con la población mínima de cada país.
*/
SELECT 
    T.CountryCode,
    T.MinCityPopulation AS Population,
    city.Name AS CityName
FROM
    (SELECT 
        CountryCode, MIN(Population) AS MinCityPopulation
    FROM
        city
    GROUP BY CountryCode) AS T
JOIN
    city ON T.CountryCode = city.CountryCode AND T.MinCityPopulation = city.Population
;
-- La primera consulta del ejemplo muestra 232 rows, la segunda consulta muestra 235 rows.
-- ¿Esperarías ese resultado?
-- Mediante subconsultas (a partir de los QUERIES del ejemplo), ¿podrías identificar los 3 rows extras?
/*
Respuesta: El siguiente QUERY muestra los países que tienen más de una ciudad que coinciden en MIN(Population).
*/
SELECT 
    B.CountryCode, COUNT(*)
FROM
    (SELECT 
        T.CountryCode,
        T.MinCityPopulation AS Population,
        city.Name AS CityName
    FROM
        (SELECT 
            CountryCode, MIN(Population) AS MinCityPopulation
        FROM
            city
        GROUP BY CountryCode) AS T
    JOIN city ON T.CountryCode = city.CountryCode AND T.MinCityPopulation = city.Population) AS B
GROUP BY B.CountryCode
HAVING COUNT(*) > 1
;

-- Ejemplo 11 (JOIN y subconsultas)
/*
Queremos mostrar el nombre del país, su continente y las ciudades que lo componen en un arreglo JSON
de los países que cuenten con exactamente 1 idioma registrado.
Muestre el resultado verticalmente.
*/
SELECT 
    CountryName, Continent, JSON_ARRAYAGG(CityName) AS 'CityArray'
FROM
    (SELECT 
        B.Code,
        B.Name AS CountryName,
        B.Continent,
        C.Name AS CityName
    FROM
        (SELECT 
            CountryCode
        FROM
            countrylanguage
        GROUP BY 1
        HAVING COUNT(*) = 1) AS A
    JOIN country AS B ON A.CountryCode = B.Code
    JOIN city AS C ON A.CountryCode = C.CountryCode) AS D
GROUP BY Code
\G

-- Ejemplo 12 (JOIN y subconsultas)
/*
Queremos mostrar el nombre del país, su continente, las ciudades que lo componen en un arreglo JSON y generar un objeto JSON tal que
las llaves sean el idioma y los valores la indicación de si el idioma es oficial 'T' o no lo es 'F', tal como se indica en la columna `IsOfficial`,
de los países que cuenten con exactamente 4 idiomas registrados como oficiales.
Muestra el resultado verticalmente.
*/
SELECT 
    B.Name AS CountryName,
    B.Continent,
    JSON_ARRAYAGG(C.Name) AS CityArray,
    D.LanguageObject
FROM
    (SELECT 
        CountryCode
    FROM
        countrylanguage
    WHERE
        isofficial = 'T'
    GROUP BY 1
    HAVING COUNT(*) = 4) AS A
JOIN
    country AS B ON A.CountryCode = B.Code
JOIN
    city AS C ON A.CountryCode = C.CountryCode
JOIN
    (SELECT 
        CountryCode,
        JSON_OBJECTAGG(Language, IsOfficial) AS LanguageObject
    FROM
        countrylanguage
    WHERE
        CountryCode IN (SELECT 
                            CountryCode 
                        FROM 
                            countrylanguage 
                        WHERE 
                            isofficial = 'T' 
                        GROUP BY 1 
                        HAVING COUNT(*) = 4)
    GROUP BY CountryCode) AS D ON A.CountryCode = D.CountryCode
GROUP BY B.Code
\G
