/*
=================================
Ayudantía 23: Funciones
Rodrigo Baruch Rivera Rico
08 noviembre 2024
=================================
*/

-- Antes de empezar: cargar la base world y ponerla en uso
-- \. path\to\script\base_world.sql
-- \u world

/*
Funciones en MySQL
>   Es un bloque de código que realiza una tarea específica y devuelve un único valor.
>   Característica:
    *   A diferencia de los procedimineto almacenado, las funciones siempre deben devolver un único valor.
    *   Son útiles para realizar cálculos o transformar datos en una consulta SQL.
    *   Dentro de las funciones se pueden declarar variables y usar estructuras de control como IF, CASE, LOOP, WHILE y REPEAT.
    *   Las funciones pueden ser DETERMINISTIC o NOT DETERMINISTIC:
        ~   DETERMINISTIC cuando se quiere que la función devuelva el mismo valor para los mismos parámetros de entrada.
            Esto permite a MySQL optimizar el rendimiento almacenando resultados en caché.
        ~   NOT DETERMINISTIC podría devolver resultados distintos con los mismos parámetros de entrada.
            Esto se emplea cuando la función depende de factores externos,
            como puede ser la dependencia con la fecha actual cuando esta se emplea en la función.
    *   Las funciones pueden ser llamadas en SELECT, WHERE, ORDER BY, en otras funciones o precedimientos.
>  IMPORTANTE: Por default, las funciones (y los procedimientos almacenados) están asociados con la base de datos en uso.
*/

