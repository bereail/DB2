CREATE DATABASE IF NOT EXISTS biblioteca;
USE biblioteca;
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
INSERT INTO autores (nombre, nacionalidad, fecha_nacimiento) VALUES
('Gabriel García Márquez', 'Colombiana', '1927-03-06'),
('J.K. Rowling', 'Británica', '1965-07-31'),
('Jorge Luis Borges', 'Argentina', '1899-08-24'),
('Isabel Allende', 'Chilena', '1942-08-02'),
('Haruki Murakami', 'Japonesa', '1949-01-12');
INSERT INTO libros (titulo, autor_id, genero, anio_publicacion, disponible) VALUES
('Cien años de soledad', 1, 'Realismo mágico', 1967, TRUE),
('Harry Potter y la piedra filosofal', 2, 'Fantasía', 1997, TRUE),
('El Aleph', 3, 'Ficción', 1949, TRUE),
('La casa de los espíritus', 4, 'Realismo mágico', 1982, TRUE),
('Tokio blues (Norwegian Wood)', 5, 'Novela', 1987, TRUE),
('Crónica de una muerte anunciada', 1, 'Novela', 1981, TRUE),
('Harry Potter y la cámara secreta', 2, 'Fantasía', 1998, FALSE),
('Ficciones', 3, 'Ficción', 1944, TRUE),
('De amor y de sombra', 4, 'Drama', 1984, TRUE),
('Kafka en la orilla', 5, 'Novela', 2002, TRUE);


/*Función fn_obtener_genero
Recibe el ID de un libro y devuelve su género. Si el libro no existe, devuelve
"Desconocido".*/
DELIMITER //
CREATE FUNCTION FN_OBTENER_GENERO(
	F_ID_LIBRO INT
) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN	
	DECLARE RESULTADO_GENERO VARCHAR(100);
    
	SELECT GENERO
   INTO RESULTADO_GENERO
   FROM LIBROS
   WHERE ID = F_ID_LIBRO;
   
   IF RESULTADO_GENERO IS NULL THEN
	RETURN 'DESCONOCIDO';
   ELSE 
	RETURN RESULTADO_GENERO;
	END IF;
END //

DELIMITER ;

SELECT FN_OBTENER_GENERO(1);

/* Procedimiento sp_marcar_no_disponible
Recibe el ID de un libro y lo marca como no disponible (disponible =
FALSE).*/
DELIMITER //

CREATE PROCEDURE SP_MARCAR_NO_DISPONIBLE(
    IN SP_ID_LIBRO INT
)
BEGIN
    DECLARE estado_libro BOOL;

    -- Verificar si el libro existe y obtener su estado
    SELECT DISPONIBLE
    INTO estado_libro
    FROM LIBROS
    WHERE ID = SP_ID_LIBRO;

    -- Si el libro existe y está disponible, lo marcamos como no disponible
    IF estado_libro = TRUE THEN
        UPDATE LIBROS
        SET DISPONIBLE = FALSE
        WHERE ID = SP_ID_LIBRO;
    END IF;
END //

DELIMITER ;

CALL SP_MARCAR_NO_DISPONIBLE(1);

/*3. Procedimiento sp_insertar_autor
Recibe nombre, nacionalidad y fecha de nacimiento de un autor y lo inserta
en la tabla autores.*/
DELIMITER //
CREATE PROCEDURE SP_INSERTAR_AUTO(
	IN SP_NOMBRE VARCHAR(100),
    IN SP_NACIONALIDAD VARCHAR(50),
    IN SP_FECHA_NACIMIENTO date
)BEGIN
	INSERT INTO AUTORES(NOMBRE, NACIONALIDAD, FECHA_NACIMIENTO)
    VALUES (SP_NOMBRE, SP_NACIONALIDAD, SP_FECHA_NACIMIENTO);
END //
DELIMITER ;

CALL SP_INSERTAR_AUTO('PEPE','ARGENTINO','1980-11-11');


/*Función fn_contar_libros_autor
Recibe el ID de un autor y devuelve la cantidad de libros asociados.*/
DELIMITER //

CREATE FUNCTION FN_CONTAR_LIBROS_AUTOR(
    F_ID_AUTOR INT
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE F_LIBROS_ASOCIADOS INT;

    SELECT COUNT(*) INTO F_LIBROS_ASOCIADOS
    FROM libros
    WHERE autor_id = F_ID_AUTOR;

    RETURN F_LIBROS_ASOCIADOS;
END //

DELIMITER ;

SELECT FN_CONTAR_LIBROS_AUTOR(1);


/*Procedimiento sp_actualizar_libro
Recibe ID y todos los datos de un libro, y actualiza sus datos si exist*/
DELIMITER //

CREATE PROCEDURE SP_ACTUALIZAR_LIBRO(
    IN SP_ID_LIBRO INT,
    IN SP_TITULO VARCHAR(200),
    IN SP_AUTOR_ID INT,
    IN SP_GENERO VARCHAR(50),
    IN SP_ANIO_PUBLICACION INT,
    IN SP_DISPONIBLE BOOLEAN
)
BEGIN
    DECLARE LIBRO_EXISTE INT;

    -- Verificamos si el libro existe
    SELECT COUNT(*) INTO LIBRO_EXISTE
    FROM LIBROS
    WHERE ID = SP_ID_LIBRO;

    IF LIBRO_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'LIBRO INEXISTENTE';
    ELSE
        -- Si existe, actualizamos los datos
        UPDATE LIBROS
        SET 
            TITULO = SP_TITULO,
            AUTOR_ID = SP_AUTOR_ID,
            GENERO = SP_GENERO,
            ANIO_PUBLICACION = SP_ANIO_PUBLICACION,
            DISPONIBLE = SP_DISPONIBLE
        WHERE ID = SP_ID_LIBRO;
    END IF;
END //

DELIMITER ;
select * from libros;

call SP_ACTUALIZAR_LIBRO(2,'Cien Años de Soledad',
    2,
    'Realismo Mágico',
    1967,
    TRUE )
    
/*Procedimiento sp_libros_disponibles_por_genero
Recibe un género y devuelve título, autor y año de publicación de todos los
libros disponibles de ese género.
*/
CRE

