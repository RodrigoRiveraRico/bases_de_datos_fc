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
Crearemos la tabla `city_log` para registrar cambios de la tabla `city`.
*/
DROP TABLE IF EXISTS city_log;

CREATE TABLE city_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id INT,
    city_name VARCHAR(35),
    country_code CHAR(3),
    district CHAR(20),
    population INT,
    action VARCHAR(10),
    action_day DATE,
    user VARCHAR(50));

-- Ejemplo 1 (AFTER INSERT)
/*
Trigger que registra en `city_log` cada nueva ciudad agregada en `city`.
Identificar la acción con 'INSERT' en la columna `action`.
*/
DROP TRIGGER IF EXISTS city_AI_trigger;

CREATE TRIGGER IF NOT EXISTS city_AI_trigger
AFTER INSERT ON city
FOR EACH ROW
INSERT INTO city_log (city_id, city_name, country_code, district, population, action, action_day, user)
VALUES (NEW.ID, NEW.Name, NEW.CountryCode, NEW.District, NEW.Population, 'INSERT', NOW(), USER());

-- Insertemos nuevos datos en `city`.
INSERT INTO city (Name, CountryCode, District, Population)
VALUES 
('New City 1', 'USA', 'New District', 1000000),
('New City 2', 'USA', 'New District', 2000000),
('New City 3', 'USA', 'New District', 3000000),
('New City 4', 'USA', 'New District', 4000000),
('New City 5', 'USA', 'New District', 5000000);

-- Veamos que el Trigger efectivamente registró las nuevas inserciones.
SELECT * FROM city_log;