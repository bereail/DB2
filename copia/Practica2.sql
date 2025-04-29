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



/*---------------- 7 ------------------
Crea una función llamada fn_calcular_multa que reciba el ID de un préstamo y devuelva el importe de la multa según las siguientes reglas.
0$ si no hay retraso.
500$ por día para los primeros 10 días de retraso.
1000$ por día para los siguientes días.
*/
delimiter //

create procedure fn_calcular_multa(
	in id_prestamo int,
    out importe_multa int
) 
begin 
	declare fecha_prevista DATE;
    declare fecha_real DATE;
    declare dias_retraso int default 0;
   IF EXISTS (
        SELECT 1 FROM prestamos WHERE id = id_prestamo
    ) THEN
    select fecha_devolucion_prevista, fecha_devolucion_real
    into fecha_prevista, fecha_real
    from prestamos
    where id = id_prestamo;
    
    set dias_retraso = datediff(fecha_real, fecha_prevista);
    
    if dias_retraso <=0 then
    set importe_multa = 0;
    elseif importe_multa <= 10 then
    set importe_multa = dias_retraso * 500;
    else
    set importe_multa = (10 * 500) + ((dias_retraso -10) - 1000);
	end if;
else
	set importe_multa = 0;
end if;
end //

delimiter //


INSERT INTO prestamos (libro_id, nombre_usuario, fecha_prestamo, fecha_devolucion_prevista, fecha_devolucion_real)
VALUES (1, 'user', '2024-06-01', '2024-06-10', '2024-06-15');

call fn_calcular_multa(1, @multa);
select @multa;


/*---------------- 8 ------------------
Crea un procedimiento llamado sp_registrar_libro que reciba título, 
nombre del autor, género y año de publicación. Si el autor ya existe, utiliza su ID, 
de lo contrario, crea un nuevo autor.*/

DELIMITER //

CREATE PROCEDURE sp_registrar_libro (
    IN titulo_libro VARCHAR(100),
    IN nombre_autor VARCHAR(50),
    IN genero VARCHAR(50),
    IN año_publicacion DATE
)
BEGIN
    DECLARE id_autor INT;

    -- Intentar obtener el ID del autor si ya existe
    SELECT id INTO id_autor
    FROM autores
    WHERE nombre = nombre_autor
    LIMIT 1;

    -- Si no existe, insertarlo
    IF id_autor IS NULL THEN
        INSERT INTO autores (nombre)
        VALUES (nombre_autor);
        
        SET id_autor = LAST_INSERT_ID();
    END IF;

    -- Insertar el libro
    INSERT INTO libros (titulo, autor_id, genero, año_publicacion)
    VALUES (titulo_libro, id_autor, genero, año_publicacion);
END //

DELIMITER ;

call sp_registrar_libros()


/*---------------- 9 ------------------
Crea una función llamada fn_promedio_libros_por_autor que calcule y devuelva la media de libros por autor en la biblioteca.*/
DELIMITER $$

CREATE FUNCTION fn_promedio_libros_por_autor()
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);
    
    SELECT COUNT(*) / COUNT(DISTINCT autor_id)
    INTO promedio
    FROM libros;
    
    RETURN promedio;
END$$

DELIMITER ;

select fn_promedio_libros_por_autor();



/*--------------------10 --------------------------
Crea un procedimiento llamado sp_categorizar_libros que reciba un año como parámetro
 y clasifique los libros según su fecha de publicación en: "Clásico" (anterior a 1900), 
 "Moderno" (entre 1900 y el año parámetro) o "Contemporáneo" (posterior al año parámetro).*/

delimiter //
create procedure sp_categorizar_libros(
	in año_libro int
)
	begin 
		update libros
        set categorias = 'Clasico'
        where fecha_publicacion < 1900;
        
        update libros 
        set categorias = ';
        
    return genero_literario;
    end//
delimiter//

