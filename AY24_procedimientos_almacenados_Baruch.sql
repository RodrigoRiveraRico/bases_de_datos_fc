/*
=================================
Ayudantía 24: Procedimientos almacenados
Rodrigo Baruch Rivera Rico
14 noviembre 2024
=================================
*/

-- Antes de empezar: cargar la base world y ponerla en uso
-- \. path\to\script\base_world.sql
-- \u world

/*
Procedimientos almacenados

IMPORTANTE: Si no se especifica el tipo de parámetro en el procedimiento, por default se asigna IN.
    Un procedimiento que no recibe parámetros se debe definir con una lista vacía de parámetros: ()
    No returna un valor directamente (puede usar out)
*/

-- Ejemplo 1 (IN)
/*
Procedimiento que toma el código de un país como entrada y calcula su densidad poblacional.
*/
DROP PROCEDURE IF EXISTS CountryPopulationDensity;

CREATE PROCEDURE IF NOT EXISTS CountryPopulationDensity(IN countryCode CHAR(3))
    SELECT Name, Population / SurfaceArea AS PopulationDensity
    FROM country
    WHERE Code = countryCode;

-- Llamamos al procedimiento `CountryPopulationDensity` para:
-- > México (MEX)
CALL CountryPopulationDensity('MEX');
-- > China (CHN)
CALL CountryPopulationDensity('CHN');

-- Ejemplo 2 (OUT)
/*
Procedimiento que toma el código de un país como entrada y devuelve su año de independencia.
*/
DROP PROCEDURE IF EXISTS CountryIndepYear;

CREATE PROCEDURE IF NOT EXISTS CountryIndepYear(IN countryCode CHAR(3), OUT indep VARCHAR(15))
    SELECT IFNULL(IndepYear, 'No hay registro') INTO indep
    FROM country
    WHERE Code = countryCode;

-- Llamamos al procedimineto `CountryIndepYear` para:
-- > México (MEX)
-- > Estados Unidos (USA)
-- > Puerto Rico (PRI)
CALL CountryIndepYear('MEX', @independencia_mex);
CALL CountryIndepYear('USA', @independencia_usa);
CALL CountryIndepYear('PRI', @independencia_pri);
-- Mostramos los valores devueltos por el procedimmiento.
SELECT 
    @independencia_mex AS 'Año de independencia de Mexico',
    @independencia_usa AS 'Año de independencia de Estados Unidos',
    @independencia_pri AS 'Año de independencia de Puerto Rico';

-- Ejemplo 3 (INOUT)
/*
Procedimiento que recibe el código de un país como entrada y devuelve el número de ciudades que este tiene.
*/
DROP PROCEDURE IF EXISTS CountryInfo;

-- Cambiamos el delimitador para que el bloque de código dentro del cuerpo BEGIN...END no se ejecute al finalizar con punto y coma cada declaración.
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS CountryInfo(INOUT countryCodeInfo TINYTEXT)
-- A pesar de que la entrada del procedimiento será un CHAR(3), 
-- definimos al parámetro `countryCodeInfo` como TINYTEXT pues la salida del procedimiento será una cadena mayor a CHAR(3).
BEGIN
    DECLARE conteo INT UNSIGNED;
    
    SELECT COUNT(*) INTO conteo
    FROM city
    WHERE CountryCode = countryCodeInfo;

    SET countryCodeInfo = CONCAT_WS(' ', countryCodeInfo, 'tiene', conteo, 'ciudades.');
END //
    
-- Regresamos al delimitador de punto y coma para ejecutar consultas de forma ordinaria.    
DELIMITER ;

-- Llamamos al procedimiento `countryInfo` para México (MEX).
-- IMPORTANTE: Inicializar la variable antes de llamar al procedimiento.
SET @info = 'MEX';
CALL CountryInfo(@info);
-- Llamamos a la variable @info pues el procedimiento modifica a esta misma variable.
SELECT @info;



