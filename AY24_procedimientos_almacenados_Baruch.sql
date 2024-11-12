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

-- Ejemplo variables o.O

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
-- IMPORTANTE: Notemos que para este caso hay que inicializar la variable antes de llamar al procedimiento.
SET @info = 'MEX';
CALL CountryInfo(@info);
-- Llamamos a la variable @info pues el procedimiento modifica a esta misma variable.
SELECT @info;

-- Ejemplo 4
/*
Procedimiento que inserta un nuevo registro en la tabla `city`.
*/
DROP PROCEDURE IF EXISTS AddCity;

CREATE PROCEDURE IF NOT EXISTS AddCity(IN cityName VARCHAR(50), IN countryCode CHAR(3), IN district VARCHAR(50), IN population INT)
    INSERT INTO city (Name, CountryCode, District, Population)
    VALUES (cityName, countryCode, district, population);

-- Llamamos al procedimiento `AddCity`.
CALL AddCity('New City 1', 'USA', 'New District', 1000000);
CALL AddCity('New City 2', 'USA', 'New District', 2000000);
CALL AddCity('New City 3', 'USA', 'New District', 3000000);
CALL AddCity('New City 4', 'USA', 'New District', 4000000);
CALL AddCity('New City 5', 'USA', 'New District', 5000000);
-- Verificamos la inserción.
SELECT * FROM city WHERE Name LIKE 'New City _';

-- Ejemplo 5
/*
PLANTEAMIENTO:
>   Procedimiento que actualiza la población o elimina registros en la tabla `city`.
>   Se recibirán como parámetros un entero que será un porcentaje, una cadena que será el nombre de una ciudad y el código del país.
>   El procedimiento aumentará a la población en el porcentaje definido por el usuario.
    >   Si al aumentar la población se supera el umbral de 5000000 habitantes entonces se elimina el registro de la ciudad.
    >   En caso contrario, se hace la actualización de la población en la tabla.
    >   En función del caso en que estemos, se mostrará un query indicando si la ciudad en cuestión fue eliminada o actualizada.
>   Para el ejemplo nos centraremos en modificar los registros recién agregados al llamar al procedimiento.
*/
DROP PROCEDURE IF EXISTS UpdateOrDeleteCity;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS UpdateOrDeleteCity(IN porcentaje INT, IN CityName VARCHAR(50), IN code CHAR(3))
BEGIN
    DECLARE old_population INT;
    DECLARE new_population INT;

    SELECT Population INTO old_population
    FROM city
    WHERE Name = CityName AND CountryCode = code;

    SET new_population = old_population * (1 + porcentaje / 100);

    IF new_population > 5000000 THEN
        SELECT CONCAT_WS(' ', 'Ciudad', CONCAT('"', CityName, '"'), 'con ID', CONCAT('"', ID, '"'), 'eliminada.') AS 'RESULTADO'
        FROM city
        WHERE Name = CityName AND CountryCode = code;
        
        DELETE FROM city
        WHERE Name = CityName AND CountryCode = code;
    
    ELSE      
        SELECT CONCAT_WS(' ', 'Ciudad', CONCAT('"', CityName, '"'), 'con ID', CONCAT('"', ID, '"'), 'actualizada.') AS 'RESULTADO'
        FROM city
        WHERE Name = CityName AND CountryCode = code;

        UPDATE city 
        SET Population = new_population
        WHERE Name = CityName AND CountryCode = code;
    END IF;
END //

DELIMITER ;

-- Llamamos al procedimiento `UpdateOrDeleteCity`.
-- Aplicamos un 10%
CALL UpdateOrDeleteCity(10, 'New City 1', 'USA');
CALL UpdateOrDeleteCity(10, 'New City 2', 'USA');
CALL UpdateOrDeleteCity(10, 'New City 3', 'USA');
CALL UpdateOrDeleteCity(10, 'New City 4', 'USA');
CALL UpdateOrDeleteCity(10, 'New City 5', 'USA');

-- Ejemplo 6
/*
PLANTEAMIENTO:
>   En `country` tenemos el catálogo de países.
>   Las tablas `city` y `countrylanguage` tienen registros de ciudades e idiomas respectivamente, y a su vez hacen referencia a `country`.
>   Nos interesa tener un resumen de la base de datos que muestre el total de países registrados en cada una de las tablas:
    >   En `country`, al ser un catálogo, se encuentra el total de países registrados en nuestra base de datos.
    >   Tanto en `city` como en `countrylanguage` pueden faltar registros de países.
>   Primero se creará una vista con el resumen descrito arriba, es decir,
    mostrando el total de países que contiene cada tabla y el total sin asignación.
>   Luego se usará esta vista en un procedimiento que reciba
    el nombre de la tabla de interés y se ejecute un query que muestre el resumen de la tabla en cuestión.
>   Además, si el parámetro de entrada es '*' se mostrará la vista completa.
    Si se ingresa un nombre incorrecto, se mostrará un query indicándolo.
*/
-- VISTA
DROP VIEW IF EXISTS v_summary;

CREATE OR REPLACE VIEW v_summary AS
SELECT 
    'country' AS 'Tabla',
    COUNT(*) AS 'Total países',
    '-' AS 'Sin asginación'
FROM 
    country
UNION
SELECT 
    'city',
    COUNT(DISTINCT CountryCode), 
    SUM(CASE WHEN CountryCode IS NULL THEN 1 ELSE 0 END)
FROM 
    country
LEFT JOIN 
    city ON country.Code = city.CountryCode
UNION 
SELECT 
    'countrylanguage',
    COUNT(DISTINCT CountryCode), 
    SUM(CASE WHEN CountryCode IS NULL THEN 1 ELSE 0 END)
FROM 
    country
LEFT JOIN 
    countrylanguage ON country.Code = countrylanguage.CountryCode;

-- PROCEDIMIENTO
DROP PROCEDURE IF EXISTS worldSummary;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS worldSummary(IN tbl_name VARCHAR(15))
BEGIN
    IF tbl_name = '*' THEN
        SELECT * FROM v_summary;

    ELSEIF tbl_name IN ('country', 'city', 'countrylanguage') THEN
        SELECT * FROM v_summary WHERE Tabla = tbl_name;

    ELSE
        SELECT CONCAT_WS(' ', 'Tabla', CONCAT('"', tbl_name, '"'), 'no existe.') AS 'ERROR';
    END IF;
END //

DELIMITER ;

-- Llamamos al procedimiento `worldSummary`.
CALL worldSummary('country');
CALL worldSummary('city');
CALL worldSummary('countrylanguage');
CALL worldSummary('*');
CALL worldSummary('UwU');
