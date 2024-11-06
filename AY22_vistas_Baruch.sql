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
    y se computa de alguna forma por el motor de almacenamiento.

¿Qué es una vista?
>   Es un query almacenado que al ser invocado produce un resultado (una tabla virtual).

¿Por qué es útil?
>   Las vistas permiten visualizar datos de una o más tablas.
>   En la implementación en una aplicación restringe el acceso a datos críticos a terceros usurarios.
>   En MySQL, las vistas son creadas seleccionado un conjunto de columnas y un conjunto de filas
    de una tabla la cual ha sido filtrada bajo alguna condición.
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
DROP VIEW v_de_prueba;
-- Verificamos que la tabla t_de_prueba no fue afectada al borrar la vista.
SELECT * FROM t_de_prueba;
-- Borramos la tabla.
DROP TABLE IF EXISTS t_de_prueba;

-- Ejemplo 2

