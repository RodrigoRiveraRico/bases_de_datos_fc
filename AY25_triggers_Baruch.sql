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
Trigger que registra en `city_log` cada nueva ciudad agregada en `city`.
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
('New City 1', 'USA', 'New District', 1000000),
('New City 2', 'USA', 'New District', 2000000),
('New City 3', 'USA', 'New District', 3000000),
('New City 4', 'USA', 'New District', 4000000),
('New City 5', 'USA', 'New District', 5000000);

-- Veamos que el trigger efectivamente convirtió en mayúsculas el nombre de la ciudad de las nuevas inserciones.
SELECT * FROM city WHERE Name LIKE 'new city _';

-- Veamos que el trigger efectivamente registró las nuevas inserciones.
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
Trigger que registra en `city_log` cada row que ha sido actualizado en `city`.
*/
DROP TRIGGER IF EXISTS city_AU_trigger;

CREATE TRIGGER IF NOT EXISTS city_AU_trigger
AFTER UPDATE ON city
FOR EACH ROW
INSERT INTO city_log (city_id, city_name, country_code, district, population, action, action_day, user)
VALUES (OLD.ID, OLD.Name, OLD.CountryCode, OLD.District, OLD.Population, 'UPDATE', NOW(), USER());

-- Actualizamos datos en `city`.
UPDATE city
SET Population = 20000000
WHERE Name = 'New City 1' AND CountryCode = 'USA';

UPDATE city
SET Population = 30000000
WHERE Name = 'New City 2' AND CountryCode = 'USA';

UPDATE city
SET Population = 10000
WHERE Name = 'New City 3' AND CountryCode = 'USA';

/*
No hacemos uso del operador CASE en el UPDATE ya que este recorre cada uno de los rows en la tabla `city`.
A pesar de que solo cambiarán de valor las poblaciones que cumplan con las condiciones del CASE,
el trigger `city_AU_trigger` se ejecutará para cada uno de los rows de la tabla,
causando inserciones en `city_log` no deseadas (solo nos interesa insertar datos que sí cambiaron de valor en la población).

UPDATE city
SET Population = CASE
    WHEN Name = 'New City 1' AND CountryCode = 'USA' THEN 20000000
    WHEN Name = 'New City 2' AND CountryCode = 'USA' THEN 30000000
    WHEN Name = 'New City 3' AND CountryCode = 'USA' THEN 10000
    ELSE Population -- No olvidar este ELSE para que en el UPDATE no se asigne NULL en la población de los rows que no están considerados en el operador CASE.
END;
*/
    
-- Verificamos que efectivamente la población tanto de 'New City 1' como de 'New City 2' no supera los 10 millones de habitantes.
SELECT * FROM city WHERE Name LIKE 'new city _';

-- Veamos que el trigger efectivamente registró el estado anterior a la actualización de los rows modificados.
SELECT * FROM city_log;
