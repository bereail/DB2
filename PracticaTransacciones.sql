use biblioteca;

/*--------------   1     ----------------
Crea una transacción que cambie el estado de disponibilidad de un libro a FALSE (prestado), 
pero sólo si el libro está actualmente disponible. Utiliza ROLLBACK si el libro no está disponible.*/

START transaction;

/*declaro la funcion y la trabla*/
update libros

-- guardo un valor en un variable
set disponible = FALSE
where id = 1 and disponible = true;
-- solo se actuliza si el libro esta disponible

-- verifico cuantas filas se modificaron 
select row_count() as filas_afectadas;

-- si filas_afectadas = 1 -> confirma los cambios
COMMIT;

-- si filas afectadas = 0 -> revierte todos los cambios
rollback; 



/*----------------------- 2
Crea un procedimiento almacenado llamado prestar_libro que registre un préstamo y actualice la disponibilidad del libro, todo dentro de una transacción. *//

DELIMITER //

CREATE PROCEDURE prestar_libro(IN libro_id INT)
BEGIN
    DECLARE filas INT DEFAULT 0;

    START TRANSACTION;

    -- Paso 1: marcar el libro como no disponible
    UPDATE libros
    SET disponible = FALSE
    WHERE id = libro_id AND disponible = TRUE;

    -- Paso 2: verificar si se actualizó
    SET filas = ROW_COUNT();

    IF filas = 1 THEN
        -- Paso 3: registrar el préstamo (ejemplo básico)
        INSERT INTO prestamos(id_libro, fecha_prestamo)
        VALUES (libro_id, NOW());

        COMMIT;
        SELECT 'Préstamo registrado correctamente.' AS mensaje;
    ELSE
        ROLLBACK;
        SELECT 'El libro no está disponible o no existe.' AS mensaje;
    END IF;
END //

DELIMITER ;

call prestar_libro(1);

/*-------------3  -------------------------------------------------------------
Crea una transacción simple que añada un nuevo libro. Si el autor no existe (por ejemplo, el autor_id = 10), la transacción debe cancelarse.*/
start transaction;

-- verificar si el auto existe
select count(*) as existe_autor
into @existe
from libros
-- hardcodeo el id
where id = autor_id;

-- si el auto existe (count(*) = 1, insetamos el libro
insert into libros(titulo, autor_id, genero, anio_publicacion, disponible)
values('Nuevo libro', 2, 'Ficcion', 1992, TRUE);

-- confirmo cambios
commit;

-- si @existe = 0
rollback;

