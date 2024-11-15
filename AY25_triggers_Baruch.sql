/*
=================================
Ayudantía 25: Triggers
Rodrigo Baruch Rivera Rico
15 noviembre 2024
=================================
*/

-- Antes de empezar: cargar la base world y ponerla en uso
-- \. path\to\script\base_world.sql
-- \u world

/*
Triggers
*/

/*
>   Crearemos la tabla `city_log` para registrar las modificaciones que ocurren en los registros de la tabla `city`.
>   `city_log` tendrá las mismas columnas que `city`, además de:
    *   Llave primaria `log_id` para identificar cada registro.
    *   Columna `action` para registrar el tipo de modificación que se hizo: INSERT, UPDATE, DELETE.
    *   Columna `action_day` para registrar el día en que se hizo la modificación.
    *   Colummna `user` para registrar el nombre del usuario que hizo la modificación.
*/
DROP TABLE IF EXISTS city_log;

CREATE TABLE IF NOT EXISTS city_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT,
    city_name VARCHAR(35),
    country_code CHAR(3),
    district CHAR(20),
    population INT,
    action VARCHAR(10),
    action_day DATE,
    user VARCHAR(50));

-- Ejemplo 1 (BEFORE INSERT)
/*
Trigger que convierte en mayúsculas el nombre de la ciudad antes de hacer una inserción.
*/
DROP TRIGGER IF EXISTS city_BI_trigger;

CREATE TRIGGER IF NOT EXISTS city_BI_trigger
BEFORE INSERT ON city
FOR EACH ROW
SET NEW.Name = UCASE(NEW.Name);

-- Ejemplo 2 (AFTER INSERT)
/*
Trigger que registra en `city_log` cada nuevo row agregado en `city`.
*/
DROP TRIGGER IF EXISTS city_AI_trigger;

CREATE TRIGGER IF NOT EXISTS city_AI_trigger
AFTER INSERT ON city
FOR EACH ROW
INSERT INTO city_log (city_id, city_name, country_code, district, population, action, action_day, user)
VALUES (NEW.ID, NEW.Name, NEW.CountryCode, NEW.District, NEW.Population, 'INSERT', NOW(), USER());
/*
>   Notemos que el trigger debe ser AFTER INSERT ya que al usar BEFORE INSERT ocurría que
    NEW.ID sea 0 (cero), pues antes del INSERT no se ha asignado un valor en la columna `ID` para la nueva inserción.
>   De la documentación de MySQL:
    *   In a BEFORE trigger, the NEW value for an AUTO_INCREMENT column is 0, 
    *   not the sequence number that is generated automatically when the new row actually is inserted.
    *   https://dev.mysql.com/doc/refman/9.0/en/trigger-syntax.html
*/

-- Insertamos nuevos datos en `city`.
INSERT INTO city (Name, CountryCode, District, Population)
VALUES 
('new city 1', 'USA', 'New District', 1000000),
('new city 2', 'USA', 'New District', 2000000),
('new city 3', 'USA', 'New District', 3000000),
('new city 4', 'USA', 'New District', 4000000),
('new city 5', 'USA', 'New District', 5000000);

-- Veamos que el trigger `city_BI_trigger` efectivamente convirtió en mayúsculas el nombre de la ciudad de las nuevas inserciones.
SELECT * FROM city WHERE Name LIKE 'new city _' AND CountryCode = 'USA';

-- Veamos que el trigger `city_AI_trigger` efectivamente registró las nuevas inserciones.
SELECT * FROM city_log;

-- Ejemplo 3 (BEFORE UPDATE)
/*
Trigger que evita que en la actualización de la población en la tabla `city` se superen los 10 millones de habitantes.
*/
DROP TRIGGER IF EXISTS city_BU_trigger;

DELIMITER //

CREATE TRIGGER IF NOT EXISTS city_BU_trigger
BEFORE UPDATE ON city
FOR EACH ROW
BEGIN
    IF NEW.Population > 10000000 THEN
        SET NEW.Population = 10000000;
    END IF;
END //

DELIMITER ;

-- Ejemplo 4 (AFTER UPDATE)
/*
Trigger que registra en `city_log` cada row en `city` en el que ha habido modificación en alguna columna.
Nos interesa registrar el estado anterior del row antes de la modificación.
*/
DROP TRIGGER IF EXISTS city_AU_trigger;

DELIMITER //

CREATE TRIGGER IF NOT EXISTS city_AU_trigger
AFTER UPDATE ON city
FOR EACH ROW
BEGIN
    IF 
        OLD.ID <> NEW.ID OR
        OLD.Name <> NEW.Name OR
        OLD.CountryCode <> NEW.CountryCode OR
        OLD.District <> New.District OR
        OLD.Population <> NEW.Population 
    THEN
        INSERT INTO city_log (city_id, city_name, country_code, district, population, action, action_day, user)
        VALUES (OLD.ID, OLD.Name, OLD.CountryCode, OLD.District, OLD.Population, 'UPDATE', NOW(), USER());
    END IF;
END //

DELIMITER ;
/*
>   Notemos que la condición IF evita la inserción de registros en `city_log` cuando
    el UPDATE no hace ningún cambio en alguna columna de `city`.
>   Recordemos que el trigger se ejecuta por cada row en el que hay coincidencia en el UPDATE (Rows matched).
*/

-- Actualizamos datos (de población) en `city`.
UPDATE city
SET Population = CASE
    WHEN Name = 'New City 1' AND CountryCode = 'USA' THEN 20000000  -- 20 millones
    WHEN Name = 'New City 2' AND CountryCode = 'USA' THEN 30000000  -- 30 millones
    WHEN Name = 'New City 3' AND CountryCode = 'USA' THEN 10000     -- 10 mil
    ELSE Population -- No olvidar este ELSE para que en el UPDATE no se asigne NULL en la población de los rows que no están considerados en el operador CASE.
END;
/*
>   Al hacer uso del operador CASE en el UPDATE se recorre CADA UNO de los rows en la tabla `city`.
>   A pesar de que solo cambiarán de valor las poblaciones de los rows que cumplan con las condiciones del CASE,
    ambos triggers se ejecutarán para cada uno de los rows de la tabla.
>   Lo anterior implica que si en `city` hay alguna ciudad con una población mayor a 10 millones, debido al
    trigger `city_BU_trigger` se le establecerá el límite superior de 10 millones a dicha ciudad.
    Además, debido al trigger `city_AU_trigger`, se registrarán en `city_log` las
    ciudades afectadas por el UPDATE.
*/
    
-- Verificamos que efectivamente la población tanto de 'New City 1' como de 'New City 2' no supera los 10 millones de habitantes.
SELECT * FROM city WHERE Name LIKE 'new city _' AND CountryCode = 'USA';

-- Veamos que el trigger `city_AU_trigger` efectivamente registró el estado anterior a la actualización de los rows modificados.
SELECT * FROM city_log;
/*
Para el ejemplo se hicieron modificaciones poblacionales para mostrar en particular la funcionalidad de `city_BU_trigger`,
pero dada la codificación de `city_AU_trigger`, se pueden realizar modificaciones a cualquier columna de `city` y
estas quedarán registradas (con el estado anterior a la modificación) en `city_log`.
*/

-- Ejemplo 5 (AFTER DELETE)
/*
Trigger que registra en `city_log` cada row que ha sido eliminado en `city`.
*/
DROP TRIGGER IF EXISTS city_AD_trigger;

CREATE TRIGGER IF NOT EXISTS city_AD_trigger
AFTER DELETE ON city
FOR EACH ROW
    INSERT INTO city_log (city_id, city_name, country_code, district, population, action, action_day, user)
    VALUES (OLD.ID, OLD.Name, OLD.CountryCode, OLD.District, OLD.Population, 'DELETE', NOW(), USER());

-- Eliminamos resgistros en `city`.
DELETE FROM city
WHERE Name LIKE 'new city _' AND CountryCode = 'USA';

-- Verificamos que los rows fueron eliminados.
SELECT * FROM city WHERE Name LIKE 'new city _' AND CountryCode = 'USA';

-- Veamos que el trigger `city_AD_trigger` registró los rows en `city_log`.
SELECT * FROM city_log;

-- Ejemplo 6
/*
Ejecutamos la siguiente línea para consultar los triggers creados en las tablas de la base de datos en uso.
*/
SHOW TRIGGERS\G
