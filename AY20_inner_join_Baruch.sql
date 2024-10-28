/*
=================================
Ayudantía 20: Group By
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



/*
Queremos mostrar los idiomas de cada país:
Nos interesa saber tanto el país como los idiomas que se hablan en dicho país considerando solo los países que empiezan P.
*/
SELECT pais.Name AS CountryName, idioma.Language
FROM country AS pais
JOIN countrylanguage AS idioma ON pais.Code = idioma.CountryCode
WHERE pais.Name like 'P%'
;
-- Notemos que hemos etiquetado a la tabla `country` como `pais` y a la tabla `countrylanguage` como `idioma`.
-- Estas etiquetas son utilizadas en las cláusulas ON, WHERE y SELECT.
-- Aquí JOIN se usa para unir `country` y `countrylanguage` en función de que el código del país coincida. 
-- Se devuelve solo información para aquellos países que tienen datos en ambas tablas.




select left(name,1), count(*)
from city
group by left(name,1)
order by 1;

select CountryCode, count(*) from countrylanguage group by 1  order by 2;

select left(name,1), count(*)
from country
group by left(name,1)
order by 1;