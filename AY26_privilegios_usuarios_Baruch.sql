/*
=================================
Ayudantía 26: Privilegios y usuarios
Rodrigo Baruch Rivera Rico
21 noviembre 2024
=================================
*/

/*
GESTIÓN DE USUARIOS
>   Esta es una tarea importante para cualquiera que sea responsable de la gestión de una base de datos MySQL, 
    ya que le permite controlar qué usuarios tienen acceso a qué partes de su base de datos. 
>   Concediendo los privilegios apropiados a cada usuario, puedes asegurarte de que tu base de datos permanece 
    segura al mismo tiempo que permites a los usuarios realizar las tareas que necesitan.
*/

-- Ejemplo 1
/*
Veamos la sintaxis básica para la creación de un nuevo usuario.
*/
CREATE USER IF NOT EXISTS 'baruch_db'@'localhost' IDENTIFIED BY '1234';
CREATE USER IF NOT EXISTS 'adrian_db'@'localhost' IDENTIFIED BY '5678';
CREATE USER IF NOT EXISTS 'jazz_db'@'localhost' IDENTIFIED BY 'abcd';
/*
>   Indicamos el nombre de usuario:
    *   barcuh_db
>   Indicamos el host:
    *   localhost
    ~   NOTAS: 
        1)  El host define desde qué máquina puede conectarse el usuario.
        2)  Usar % para permitir acceso desde cualquier host.
        3)  Si no se define el host, se establece % por default.
>   Indicamos la contraseña:
    *   1234
*/

-- Ejemplo 2
/*
Conexión desde el cliente.
*/
-- mysql -u baruch_db -p -h localhost -P 3306
/*
    -u para ingresar el nombre de usuario.
    -p para ingresar la contraseña.
    -h (opcional) para ingresar el IP del servidor MySQL. Por defecto se asigna localhost.
    -P (opcional) para ingresar el puerto de acceso al servidor. Es opcional si el servidor MySQL usa el puerto por defecto (3306).
*/

-- Ejemplo 3
/*
Veamos los permisos que tiene cada usuario.
*/
SHOW GRANTS FOR 'baruch_db'@'localhost';
SHOW GRANTS FOR 'adrian_db'@'localhost';
SHOW GRANTS FOR 'jazz_db'@'localhost';
/*
>   Todos los usuarios tienen el permiso USAGE automáticamente al ser creados.
>   USAGE no otorga privilegios sobre bases de datos o tablas; solo permite que el usuario exista y se autentique.
*/

-- Ejemplo 4
/*
Veamos los permisos que pueden ser otorgados.
*/
SHOW PRIVILEGES \G

-- Ejemplo 5
/*
Veamos la sintaxis básica para otorgar permisos.
*/
GRANT SELECT ON world.country TO 'baruch_db'@'localhost';
GRANT SELECT, UPDATE ON world.* TO 'adrian_db'@'localhost', 'jazz_db'@'localhost';
/*
>   Otorgamos permisos de solo lectura (SELECT) en la tabla `country` de la base de datos `world`
    al usuario `barcuh_db`@`localhost`.
>   Otorgamos permisos de lectura y actualización (SELECT y UPDATE) en todas las tablas de la base de datos `world`
    a los usuarios `adrian_db`@`localhost` y `jazz_db`@`localhost`.
*/

-- Ejemplo 6
/*
Revisamos los permisos de cada usuario.
*/
SHOW GRANTS FOR 'baruch_db'@'localhost';
SHOW GRANTS FOR 'adrian_db'@'localhost';
SHOW GRANTS FOR 'jazz_db'@'localhost';

-- Ejemplo 7
/*
Veamos la sintaxis básica para quitar permisos.
*/
REVOKE UPDATE ON world.* FROM 'adrian_db'@'localhost';
/*
>   Quitamos el permiso de actualización (UPDATE) en todas las tablas de la base de datos `world`
    al usuario `adrian_db`@`localhost`.
>   A este usuario le queda el permiso de SELECT sobre todas las tablas; intentemos quitar este permiso a solo una tabla.
*/
REVOKE SELECT ON world.country FROM 'adrian_db'@'localhost';
/*
>   Obtenemos el siguiente error:
    ERROR 1147 (42000): There is no such grant defined for user 'adrian_db' on host 'localhost' on table 'country'
>   No podemos quitar permisos que no hemos asignado:
    El usuario tiene permiso de SELECT sobre todas las tablas, mas no tiene definido el permiso sobre una única tabla.
*/
REVOKE ALL ON *.* FROM 'baruch_db'@'localhost', 'adrian_db'@'localhost', 'jazz_db'@'localhost';
/*
>   Con el query anterior quitamos todos los permisos a cada usuario.
>   Quitamos todos los permisos de forma global: en bases de datos, tablas, columnas y rutinas.
*/

-- Ejemplo 8
/*
Veamos la sintaxis básica para crear roles.
Los roles son un conjunto de permisos que se pueden asignar a varios usuarios.
*/
CREATE ROLE IF NOT EXISTS 'write_role'@'localhost';

-- Ejemplo 9
/*
Asignamos permisos al rol.
*/
GRANT INSERT ON world.* TO 'write_role'@'localhost';

-- Ejemplo 10
/*
Revisamos los permisos del rol.
*/
SHOW GRANTS FOR 'write_role'@'localhost';

-- Ejemplo 11
/*
Adjuntamos usuarios al rol.
*/
GRANT 'write_role'@'localhost' TO 'baruch_db'@'localhost';
/*
>   Adjuntar usuarios al rol no hace que el rol se active automáticamente cuando 
    el usuario inicie sesión.
>   Lo anterior se puede verificar ejecutando SELECT CURRENT_ROLE(); en la sesión del usuario y observando que aparece NONE.
>   Para que el usuario active el rol debe ejecutar lo siguiente:
    SET ROLE 'write_role'@'localhost';
>   Verificamos los roles activos:
    SELECT CURRENT_ROLE();
>   Revisamos que los permisos del usuario correspondan con los del rol activo:
    SHOW GRANTS;
>   Para desactivar los roles activos:
    SET ROLE NONE;
*/
SET DEFAULT ROLE 'write_role'@'localhost' TO 'baruch_db'@'localhost';
/*
>   Con el query anterior indicamos que el rol `write_role`@`localhost` se activará automáticamente
    para el usuario `barcuh_db`@`localhost` cuando inicie sesión.
>   Si el usuario quiere activar (después de haber desactivado algún rol) todos los roles 
    que por default tiene asignados, ejecuta lo siguiente:
    SET ROLE DEFAULT;
*/

-- Ejemplo 12
/*
Quitamos roles a usuarios.
*/
REVOKE 'write_role'@'localhost' FROM 'baruch_db'@'localhost';

-- Ejemplo 13
/*
Quitamos permisos en roles.
*/
REVOKE IF EXISTS INSERT ON world.* FROM 'write_role'@'localhost';
/*
>   Podemos hacer uso de REVOKE IF EXISTS para evitar que MySQL devuelva error cuando
    el permiso a quitar no exista para el usuario indicado.
*/

-- Ejemplo 14
/*
Consultamos los usuarios y roles existentes.
*/
SELECT USER, HOST FROM mysql.user;

-- Ejemplo 15
/*
Le daremos permiso al usuario `jazz_db`@`localhost`
de ejecución de la función cuenta_regresiva que definimos en la ayudantía 23.
*/
GRANT EXECUTE ON FUNCTION world.cuenta_regresiva TO 'jazz_db'@'localhost';
/*
>   En la sesión del usuario se puede hacer la ejecución:
    SELECT cuenta_regresiva(100);
*/

-- Ejemplo 16
/*
Le daremos permiso al usuario `jazz_db`@`localhost`
de ejecución del procedimiento MaxPopulation que definimos en la ayudantía 24.
*/
GRANT EXECUTE ON PROCEDURE world.MaxPopulation TO 'jazz_db'@'localhost';
/*
>   En la sesión del usuario se puede hacer la ejecución:
    CALL MaxPopulation(@max_val);
    SELECT @max_val;
    Lo interesante es que el usuario puede ejecutar el procedimiento pero no tiene acceso a ninguna tabla de la base:
    SHOW TABLES;
*/

-- Ejemplo 17
/*
Podemos designar permisos sobre columnas específicas en tablas.
*/
GRANT SELECT (Name, Continent) ON world.country TO 'adrian_db'@'localhost';
/*
>   En la sesión del usuario se puede observar que solo tiene acceso a dos columnas de la tabla `country`:
    DESC country;
*/

-- Ejemplo 18
/*
Borramos usuarios y roles.
*/
DROP USER IF EXISTS 'baruch_db'@'localhost', 'jazz_db'@'localhost', 'adrian_db'@'localhost';
DROP ROLE IF EXISTS 'write_role'@'localhost';
