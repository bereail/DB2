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

/*------------- 4  ------------------------------------------------------
Crea un procedimiento almacenado que preste un libro específico a un usuario, utilizando una transacción.*/
DELIMITER //

CREATE PROCEDURE fn_prestar_libro(
    IN p_id_libro INT,
    IN p_nombre_usuario VARCHAR(100)
)
BEGIN
    DECLARE v_disponible BOOLEAN;

    -- Verificamos si el libro existe y está disponible
    SELECT disponible INTO v_disponible
    FROM libros
    WHERE id = p_id_libro
    FOR UPDATE;

    START TRANSACTION;

    IF v_disponible = TRUE THEN
        -- Insertar el préstamo
        INSERT INTO prestamos(libro_id, nombre_usuario, fecha_prestamo, fecha_devolucion_prevista)
        VALUES (p_id_libro, p_nombre_usuario, NOW(), DATE_ADD(NOW(), INTERVAL 10 DAY));

        -- Actualizar el estado del libro a no disponible
        UPDATE libros
        SET disponible = FALSE
        WHERE id = p_id_libro;

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END;
//

DELIMITER ;

call fn_prestar_libro(1,'Juan');


/* -------------------------------- 5----------------------------
Crea un procedimiento almacenado llamado devolver_libro que registre la devolución de un libro 
y actualice su disponibilidad. Debe incluir manejo de errores para garantizar que la transacción se complete correctamente.*/

DELIMITER //

CREATE PROCEDURE fn_devolver_libro(
    IN p_id_libro INT,
    IN p_id_prestamo INT
)
BEGIN
    DECLARE v_existe_prestamo INT;

    START TRANSACTION;

    -- Verificar la existencia del préstamo y si está pendiente de devolución
    SELECT COUNT(*) INTO v_existe_prestamo
    FROM prestamos
    WHERE id = p_id_prestamo AND fecha_devolucion_real IS NULL;

    IF v_existe_prestamo = 1 THEN
        -- Registrar la devolución del libro
        UPDATE prestamos
        SET fecha_devolucion_real = NOW()
        WHERE id = p_id_prestamo;

        -- Marcar el libro como disponible nuevamente
        UPDATE libros
        SET disponible = TRUE
        WHERE id = p_id_libro;
    ELSE
       -- Generar error para que puede capturarse en el procedimiento principal
       signal sqlstate '45000' set message_text = 'Prestamo no valido o ya devuellto';
	end if;
END;
//

DELIMITER ;

CALL fn_devolver_libro(1, 1);

/*-------------------------------- 6
Crea un procedimiento para registrar la devolución de múltiples libros en una sola transacción, utilizando savepoints para poder hacer rollback parcial si alguna devolución falla.*/
delimiter //
create procedure fn_registrar_multiples_devoluciones()
begin
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
BEGIN
    -- Si ocurre un error, no cortamos todo. Continuamos y usamos rollback parcial más abajo.
END;

    
    start transaction;
     -- Primer intento
    SAVEPOINT sp1;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK TO SAVEPOINT sp1;
        END;
        CALL fn_devolver_libro(1, 2);
    END;

    -- Segundo intento
    SAVEPOINT sp2;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK TO SAVEPOINT sp2;
        END;
        CALL fn_devolver_libro(2, 3);
    END;

    -- Tercer intento
    SAVEPOINT sp3;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK TO SAVEPOINT sp3;
        END;
        CALL fn_devolver_libro(3, 4);
    END;

    COMMIT;
END;
//

DELIMITER ;

/* ----------------------------------  7
Crea un procedimiento almacenado llamado reservar_libro que permita reservar un libro si no está disponible actualmente. 
La reserva se debe registrar en una nueva tabla. El procedimiento debe usar transacciones para garantizar la integridad.

CREATE TABLE reservas ( id INT AUTO_INCREMENT PRIMARY KEY, libro_id INT, nombre_usuario VARCHAR(100), fecha_reserva DATE, estado ENUM('activa', 'completada', 'cancelada') DEFAULT 'activa', FOREIGN KEY (libro_id) REFERENCES libros(id) );*/

DELIMITER //

CREATE PROCEDURE reservar_libro(
    IN p_id_libro INT,
    IN p_nombre_usuario VARCHAR(50)
)
BEGIN
    DECLARE libro_existe INT;

    START TRANSACTION;

    -- Verificar si el libro existe
    SELECT COUNT(*) INTO libro_existe
    FROM libros
    WHERE id = p_id_libro;

    IF libro_existe = 1 THEN
        -- Registrar la reserva
        INSERT INTO reservas(libro_id, nombre_usuario, fecha_reserva, estado)
        VALUES (p_id_libro, p_nombre_usuario, NOW(), 'activa');

        COMMIT;
        SELECT 'Reserva cargada correctamente' AS mensaje;
    ELSE
        ROLLBACK;
        SELECT 'El ID del libro no existe' AS mensaje;
    END IF;
END;
//

DELIMITER ;

