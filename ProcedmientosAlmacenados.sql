CREATE DATABASE IF NOT EXISTS biblioteca2;
USE biblioteca2;
CREATE TABLE autores (
id INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
nacionalidad VARCHAR(50),
fecha_nacimiento DATE
);
CREATE TABLE libros (
id INT AUTO_INCREMENT PRIMARY KEY,
titulo VARCHAR(200) NOT NULL,
autor_id INT,
genero VARCHAR(50),
anio_publicacion INT,
disponible BOOLEAN DEFAULT TRUE,
FOREIGN KEY (autor_id) REFERENCES autores(id)
);
CREATE TABLE prestamos (
id INT AUTO_INCREMENT PRIMARY KEY,
libro_id INT,
nombre_usuario VARCHAR(100),
fecha_prestamo DATE,
fecha_devolucion_prevista DATE,
fecha_devolucion_real DATE,
FOREIGN KEY (libro_id) REFERENCES libros(id)
);

/*5.2 Ejercicio 1: Procedimiento para Préstamo de Libros
Crear un procedimiento almacenado que gestione el préstamo de un libro, verificando
su disponibilidad y actualizando el estado.*/


DELIMITER //

CREATE PROCEDURE p_prestamo_libro(
    IN p_id_libro INT,
    IN p_nombre_usuario VARCHAR(100),
    IN p_fecha_prestamo DATE,
    IN p_fecha_devolucion_prevista DATE
)
BEGIN
    DECLARE disponibilidad BOOLEAN;

    -- Consultamos si el libro está disponible
    SELECT disponible INTO disponibilidad
    FROM Libros
    WHERE id = p_id_libro;

    -- Verificamos si existe y está disponible
    IF disponibilidad IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El libro no existe.';
    ELSEIF disponibilidad = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El libro no está disponible para préstamo.';
    ELSE
        -- Si está disponible:
        -- 1. Insertamos un préstamo
        INSERT INTO prestamos (libro_id, nombre_usuario, fecha_prestamo, fecha_devolucion_prevista)
        VALUES (p_id_libro, p_nombre_usuario, p_fecha_prestamo, p_fecha_devolucion_prevista);

        -- 2. Actualizamos el estado del libro a NO disponible
        UPDATE Libros
        SET disponible = FALSE
        WHERE id = p_id_libro;
    END IF;
END //

DELIMITER ;


CALL p_prestamo_libro(
    5, 
    'Juan Pérez', 
    CURDATE(), 
    DATE_ADD(CURDATE(), INTERVAL 15 DAY)
);
