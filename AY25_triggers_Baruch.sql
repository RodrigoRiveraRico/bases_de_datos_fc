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