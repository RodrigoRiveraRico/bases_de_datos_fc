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
CREATE USER IF NOT EXISTS 'baruch_bd'@'localhost' IDENTIFIED BY '1234';
CREATE USER IF NOT EXISTS 'miguel_bd'@'localhost' IDENTIFIED BY '5678';
CREATE USER IF NOT EXISTS 'jazz_bd'@'localhost' IDENTIFIED BY 'abcd';
/*
>   Indicamos el nombre de usuario:
    *   barcuh_bd
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
-- mysql -u baruch_bd -p -h localhost -P 3306
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
SHOW GRANTS FOR 'baruch_bd'@'localhost';
SHOW GRANTS FOR 'miguel_bd'@'localhost';
SHOW GRANTS FOR 'jazz_bd'@'localhost';

-- Ejemplo 4
/*
Veamos los permisos que pueden ser otorgados.
*/
SHOW PRIVILEGES \G

-- Ejemplo 5
/*
Veamos la sintaxis básica para otorgar permisos.
*/
GRANT SELECT ON world.country TO 'baruch_bd'@'localhost';
GRANT SELECT, UPDATE ON world.* TO 'miguel_bd'@'localhost', 'jazz_bd'@'localhost';
/*
>   Otorgamos permisos de solo lectura (SELECT) en la tabla `country` de la base de datos `world`
    al usuario `barcuh_bd`@`localhost`.
>   Otorgamos permisos de lectura y actualización (SELECT y UPDATE) en todas las tablas de la base de datos `world`
    a los usuarios `miguel_bd`@`localhost` y `jazz_bd`@`localhost`.
*/

-- Ejemplo 6
/*
Revisamos los permisos de cada usuario.
*/
SHOW GRANTS FOR 'baruch_bd'@'localhost';
SHOW GRANTS FOR 'miguel_bd'@'localhost';
SHOW GRANTS FOR 'jazz_bd'@'localhost';

-- Ejemplo 7
/*
Veamos la sintaxis básica para quitar permisos.
*/
REVOKE UPDATE ON world.* FROM 'miguel_bd'@'localhost';
/*
>   Quitamos el permiso de actualización (UPDATE) en todas las tablas de la base de datos `world`
    al usuario `miguel_bd`@`localhost`.
>   A este usuario le queda el permiso de SELECT sobre todas las tablas; intentemos quitar este permiso a solo una tabla.
*/
REVOKE SELECT ON world.country FROM 'miguel_bd'@'localhost';
/*
>   Obtenemos el siguiente error:
    ERROR 1147 (42000): There is no such grant defined for user 'miguel_bd' on host 'localhost' on table 'country'
>   No podemos quitar permisos que no hemos asignado:
    El usuario tiene permiso de SELECT sobre todas las tablas, mas no tiene definido el permiso sobre una única tabla.
*/

-- Ejemplo 8
/*
Veamos la sintaxis básica para crear roles.
*/




-- Ejemplo 
/*
Veamos la sintaxis básica para la creación de un rol.
Los roles son grupos de permisos que se pueden asignar a varios usuarios.
(Desde root)
*/
CREATE ROLE IF NOT EXISTS 'rol_lector'@'localhost';





-- Ejemplo