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
>   IMPORTANTE: 
    *   Por default, las funciones (y los procedimientos almacenados) están asociados con la base de datos en uso.
    *   Hay que ser consistentes con el tipo de dato definido para la entrada y salida de la función para que MySQL no devuelva ERROR.   
*/

-- Ejemplo 1 (Declaración de variables)
/*
Función que calcula el cuadrado de un número dado.
*/
DROP FUNCTION IF EXISTS cuadrado;

-- Cambiamos el delimitador para que el bloque de código dentro del cuerpo BEGIN...END no se ejecute al finalizar con punto y coma cada declaración.
DELIMITER // 

CREATE FUNCTION IF NOT EXISTS cuadrado(num INT)
RETURNS INT
DETERMINISTIC
BEGIN 
    DECLARE resultado INT;
    SET resultado = POWER(num, 2);
    RETURN resultado;
END //

-- Regresamos al delimitador de punto y coma para ejecutar consultas de forma ordinaria.
DELIMITER ;

-- Llamamos a la función `cuadrado`.
SELECT cuadrado(5) AS 'El cuadrado de 5 es:', cuadrado(-10) AS 'El cuadrado de -10 es:';

-- Ejemplo 2 (IF)
/*
Función que determina si un número es par o impar.
*/
DROP FUNCTION IF EXISTS esPar;

DELIMITER $$

CREATE FUNCTION IF NOT EXISTS esPar(num INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF (num % 2 = 0) THEN
        RETURN 'Par';
    ELSE
        RETURN 'Impar';
    END IF;   
END $$

DELIMITER ;

-- Llamamos a la función `esPar`.
SELECT esPar(5) AS 'El número 5 es:', esPar(20) AS 'El número 20 es:', esPar(0) AS 'El número 0 es:';

-- Ejemplo 3 (CASE)
/*
Función que evalúa una calificación como 'Excelente', 'Bueno', 'Regular' o 'Insuficiente'.
Calificación en [90, 100] es Excelente.
Calificación en [70,90) es Bueno.
Calificación en [50,70) es Regular.
Calificación en [0,50) es Insuficiente.
*/
DROP FUNCTION IF EXISTS evaluacion;

CREATE FUNCTION IF NOT EXISTS evaluacion(cal INT UNSIGNED)
RETURNS VARCHAR(33)
DETERMINISTIC
RETURN CASE
    WHEN cal > 100 THEN 'Calificación ingresada incorrecta'
    WHEN cal >= 90 THEN 'Excelente'
    WHEN cal >= 70 THEN 'Bueno'
    WHEN cal >= 50 THEN 'Regular'
    ELSE 'Insuficiente'
    END;
-- Obsérvese que no hubo necesidad de usar un cuerpo BEGIN...END al poder definir la función en una sola declaración RETURN.
-- Tampoco hubo necesidad de cambiar el delimitador pues el único punto y coma utilizado sirvió para terminar la creación de la función.

-- Llamamos a la función `evaluacion`.
SELECT '100' AS 'Calificación', evaluacion(100) AS 'Evaluación'
UNION 
SELECT '80', evaluacion(80)
UNION
SELECT '10', evaluacion(10)
UNION
SELECT '50', evaluacion(50);

-- Ejemplo 4 (WHILE)
/*
Función que calcula el factorial de un número no negativo.
*/
DROP FUNCTION IS NOT EXISTS factorial;

DELIMITER ##

CREATE FUNCTION IF NOT EXISTS factorial(n INT UNSIGNED)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE resultado INT UNSIGNED DEFAULT 1;   -- Si no se asigna un valor default MySQL inicializa la variable como NULL.
    DECLARE contador INT UNSIGNED DEFAULT 1;

    WHILE contador <= n DO
        SET resultado = resultado * contador;
        SET contador = contador + 1;
    END WHILE;

    RETURN resultado;
END ##

DELIMITER ;

-- Llamamos a la función `factorial`.
SELECT factorial(5) AS 'El resultado de 5! es:';

-- Ejemplo 5 (LOOP & LEAVE)
/*
Función que suma los número de 1 a N.
*/
DROP FUNCTION IF EXISTS suma;

DELIMITER &&

CREATE FUNCTION IF NOT EXISTS suma(N INT UNSIGNED)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE resultado INT UNSIGNED DEFAULT 0;
    DECLARE contador INT UNSIGNED DEFAULT 1;

    mi_loop: LOOP   -- Etiquetamos el LOOP como mi_loop para poder hacer referencia al bucle con LEAVE.
        SET resultado = resultado + contador;
        SET contador = contador + 1;

        IF contador > N THEN
            LEAVE mi_loop;   -- Con LEAVE terminamos el bucle que etiquetamos como mi_loop.
        END IF;
    END LOOP;

    RETURN resultado;
END &&

DELIMITER ;

-- Llamamos a la función `suma`.
SELECT suma(5) AS 'La suma de 1+2+3+4+5 es:';

-- Ejemplo 6 (Funciones aplicadas a tablas)
/*
Crearemos una función para convertir en millones la población de los países (tabla `country`).
*/
DROP FUNCTION IF EXISTS PopulationInMillions;

CREATE FUNCTION IF NOT EXISTS PopulationInMillions(pop INT)
RETURNS FLOAT
DETERMINISTIC
RETURN TRUNCATE(pop / 1000000, 0);

-- Llamamos a la función `PopulationInMillions`.
SELECT Name, PopulationInMillions(Population) FROM country ORDER BY 2 DESC LIMIT 10;

-- Ejemplo 7 (Funciones con SELECT)
/*
Crearemos una función que toma el código de un país y devuelve su idioma oficial (el más hablado) basado en el porcentaje de hablantes.
*/
DROP FUNCTION IF EXISTS MainLanguage;

DELIMITER !!

CREATE FUNCTION IF NOT EXISTS MainLanguage(Code CHAR(3)) 
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE lang VARCHAR(50);

    SELECT Language INTO lang   -- Con INTO asignamos el resultado del SELECT a la variable que definimos como lang.
    FROM countrylanguage
    WHERE CountryCode = Code AND IsOfficial = 'T'
    ORDER BY Percentage DESC
    LIMIT 1;
    -- Solo se puede asignar con INTO un único valor a la variable definida. 
    -- Por ello usamos LIMIT 1 para reducir el número de filas (resultados) a una sola (en caso de obtener más de una fila).
    -- Usar LIMIT no es una buena práctica.

    RETURN lang;
END !!

DELIMITER ;

-- Llamamos a la función `MainLanguage`.
SELECT Name, IFNULL(MainLanguage(Code), 'No hay registro') AS 'MainLanguage' FROM country ORDER BY 1 LIMIT 10;
-- Obsérvese que la función nos puede devolver nulos para algunos países.
-- Lo anterior es debido a uno de los dos siguientes casos:
-- 1) No hay registros del país en la tabla `countrylanguage`.
-- 2) Sí hay registros del país en la tabla `countrylanguage`, pero ningún idioma registrado es oficial (IsOfficial = 'T').
