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

-- INNER JOIN o JOIN
-- Importante: 
/*
En MySQL, JOIN e INNER JOIN son equivalentes sintácticos (pueden sustituirse entre sí).
En SQL estándar, no son equivalentes.
En general, los paréntesis pueden ignorarse en expresiones join que sólo contengan operaciones inner join.
(https://dev.mysql.com/doc/refman/8.4/en/join.html)
*/

