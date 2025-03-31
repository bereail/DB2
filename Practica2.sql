use Biblioteca;

/*---------------- 1 ------------------

Crea una función llamada fn_obtener_genero que reciba como parámetro el ID de un libro y devuelva su género. Si el libro no existe, devuelve "Desconocido".*/


-- Ahora podés crear tu procedimiento:
DELIMITER //

CREATE PROCEDURE fn_obtener_genero2(
    IN id_libro INT,
    OUT genero_resultado VARCHAR(50)
)
BEGIN
    SELECT genero INTO genero_resultado
    FROM libros
    WHERE id = id_libro;

    IF genero_resultado IS NULL THEN
        SET genero_resultado = 'Desconocido';
    END IF;
END //

DELIMITER ;



-- Declarar la variable de salida
SET @genero = '';

-- Llamar al procedimiento con el nombre correcto
CALL fn_obtener_genero2(2, @genero);

-- Mostrar el resultado
SELECT @genero;



/*---------------- 2 ------------------
Crea un procedimiento llamado sp_marcar_no_disponible que reciba el ID de un libro y lo marque como no disponible (disponible = FALSE) en la base de datos.*/

DELIMITER //

CREATE PROCEDURE sp_marcar_no_disponible(
    IN id_libro INT
)
BEGIN 
    UPDATE libros
    SET disponible = FALSE
    WHERE id = id_libro;
END //

DELIMITER ;

-- Luego lo llamás así:
CALL sp_marcar_no_disponible(2);

SELECT * FROM libros WHERE id = 2;


/*---------------- 3 ------------------
    Crea un procedimiento llamado sp_insertar_autor que reciba nombre, nacionalidad y fecha de nacimiento de un autor, y lo inserte en la tabla correspondie */
DELIMITER //

CREATE PROCEDURE sp_insertar_autor(
    IN nombre VARCHAR(50),
    IN nacionalidad VARCHAR(50),
    IN fecha_nacimiento DATE
)
BEGIN
    INSERT INTO autores (nombre, nacionalidad, fecha_nacimiento)
    VALUES (nombre, nacionalidad, fecha_nacimiento);
END //

DELIMITER ;

CALL sp_insertar_autor('Jorge Luis Borges', 'Argentina', '1899-08-24');


/*---------------- 4 ------------------
Crea una función llamada fn_contar_libros_autor que reciba el ID de un autor y devuelva la cantidad de libros asociados a él.*/

DELIMITER //
CREATE PROCEDURE fn_contar_libros_autor(
	IN ID_AUTOR INT,
    OUT CANTIDAD_LIBROS INT
)
BEGIN 
	select count(*) into cantidad_libros
    from libros
    where autor_id = id_autor;
END
DELIMITER //

set @cantidad = 0;

call fn_contar_libros_autor(1, @cantidad);

select @cantidad;



/*---------------- 5 ------------------
Crea un procedimiento llamado sp_actualizar_libro que reciba ID y todos los datos de un libro y actualice estos datos si el libro existe.*/
use Biblioteca;

/*---------------- 1 ------------------

Crea una función llamada fn_obtener_genero que reciba como parámetro el ID de un libro y devuelva su género. Si el libro no existe, devuelve "Desconocido".*/


-- Ahora podés crear tu procedimiento:
DELIMITER //

CREATE PROCEDURE fn_obtener_genero2(
    IN id_libro INT,
    OUT genero_resultado VARCHAR(50)
)
BEGIN
    SELECT genero INTO genero_resultado
    FROM libros
    WHERE id = id_libro;

    IF genero_resultado IS NULL THEN
        SET genero_resultado = 'Desconocido';
    END IF;
END //

DELIMITER ;



-- Declarar la variable de salida
SET @genero = '';

-- Llamar al procedimiento con el nombre correcto
CALL fn_obtener_genero2(2, @genero);

-- Mostrar el resultado
SELECT @genero;



/*---------------- 2 ------------------
Crea un procedimiento llamado sp_marcar_no_disponible que reciba el ID de un libro y lo marque como no disponible (disponible = FALSE) en la base de datos.*/

DELIMITER //

CREATE PROCEDURE sp_marcar_no_disponible(
    IN id_libro INT
)
BEGIN 
    UPDATE libros
    SET disponible = FALSE
    WHERE id = id_libro;
END //

DELIMITER ;

-- Luego lo llamás así:
CALL sp_marcar_no_disponible(2);

SELECT * FROM libros WHERE id = 2;


/*---------------- 3 ------------------
    Crea un procedimiento llamado sp_insertar_autor que reciba nombre, nacionalidad y fecha de nacimiento de un autor, y lo inserte en la tabla correspondie */
DELIMITER //

CREATE PROCEDURE sp_insertar_autor(
    IN nombre VARCHAR(50),
    IN nacionalidad VARCHAR(50),
    IN fecha_nacimiento DATE
)
BEGIN
    INSERT INTO autores (nombre, nacionalidad, fecha_nacimiento)
    VALUES (nombre, nacionalidad, fecha_nacimiento);
END //

DELIMITER ;

CALL sp_insertar_autor('Jorge Luis Borges', 'Argentina', '1899-08-24');


/*---------------- 4 ------------------
Crea una función llamada fn_contar_libros_autor que reciba el ID de un autor y devuelva la cantidad de libros asociados a él.*/

DELIMITER //
CREATE PROCEDURE fn_contar_libros_autor(
	IN ID_AUTOR INT,
    OUT CANTIDAD_LIBROS INT
)
BEGIN 
	select count(*) into cantidad_libros
    from libros
    where autor_id = id_autor;
END
DELIMITER //

set @cantidad = 0;

call fn_contar_libros_autor(1, @cantidad);

select @cantidad;


/*---------------- 5 ------------------
Crea un procedimiento llamado sp_actualizar_libro que reciba ID y todos los datos de un libro y actualice estos datos si el libro existe.*/
DELIMITER //

CREATE PROCEDURE sp_actualizar_libro(  
    IN p_id INT,     
    IN p_titulo VARCHAR(50),     
    IN p_autor INT,     
    IN p_anio_publicacion INT,     
    IN p_genero VARCHAR(100)     
)
BEGIN  
    IF EXISTS (SELECT 1 FROM libros WHERE id = p_id) THEN     
        UPDATE libros
        SET     
            titulo = p_titulo,     
            autor_id = p_autor,     
            anio_publicacion = p_anio_publicacion,     
            genero = p_genero     
        WHERE id = p_id;     
    ELSE      
        SELECT CONCAT('NO EXISTE LIBRO CON ESE ID = ', p_id) AS mensaje;     
    END IF; 
END //

DELIMITER ;


CALL sp_actualizar_libro(2, 'Otro Título', 3, 2022, 'Drama');
  
DROP PROCEDURE IF EXISTS sp_libros_disponibles_por_genero;

/*---------------- 6 ------------------
Crea un procedimiento llamado sp_libros_disponibles_por_genero que reciba un género como parámetro y devuelva una lista de todos los libros disponibles de ese género, incluyendo título, autor (nombre) y año de publicación.*/
DELIMITER //
CREATE PROCEDURE sp_libros_disponibles_por_genero(
	IN genero_libro VARCHAR(55)
    )
    BEGIN IF EXISTS (
    SELECT 1 from libros 
    WHERE genero = genero_libro
    and disponible = 1
    ) then 
    select titulo, autor_id, anio_publicacion
    from libros
    where genero = genero_libro and disponible = 1;
    ELSE 
    select CONCAT('No se encontraron libros con ese genero', genero_libro) as mensaje;
	end if;
end//
delimiter ;


call sp_libros_disponibles_por_genero('Drama');