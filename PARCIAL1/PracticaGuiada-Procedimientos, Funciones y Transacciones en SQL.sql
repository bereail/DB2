create database ProcedimientosFuncionesTransacciones;

use ProcedimientosFuncionesTransacciones;

/*-------------------------------------------------------------------------------------------
CREATE TABLE chocolates (
id INT PRIMARY KEY,
tipo VARCHAR(20),
cantidad INT
);
INSERT INTO chocolates VALUES
(1, 'Amargo', 50),
(2, 'Con Leche', 30);

Tarea:
1. Inicia una transacción.
2. Añade 10 chocolates amargos.
3. Quita 5 chocolates con leche.
4. Verifica los cambios con SELECT * FROM chocolates;.
5. Si todo está bien, haz COMMIT. Si hay error, usa ROLLBACK.
*/
START TRANSACTION;

-- Sumar 10 chocolates amargos
UPDATE chocolates SET cantidad = cantidad + 10 WHERE id = 1;

-- Restar 5 chocolates con leche
UPDATE chocolates SET cantidad = cantidad - 5 WHERE id = 2;

-- Verificar resultados
SELECT * FROM chocolates;

COMMIT;

/*-------------------------------------------------------------------------------------------
CREATE TABLE libros (
id INT PRIMARY KEY,
titulo VARCHAR(50),
stock INT CHECK (stock >= 0)
);
INSERT INTO libros VALUES
(1, 'El Principito', 5);

Crea un procedimiento prestar_libro(libro_id INT) que:
○ Verifique si hay stock con SELECT stock INTO ....
○ Si hay stock, inicia una transacción y actualiza el stock.
○ Si no hay stock, devuelve un mensaje de error.
*/
DELIMITER //

CREATE PROCEDURE SP_PRESTAR_LIBRO(IN SP_LIBRO_ID INT)
BEGIN
    DECLARE stock_actual INT;
    DECLARE existe_libro INT;

    -- Verificar si el libro existe
    SELECT COUNT(*) INTO existe_libro
    FROM libros
    WHERE id = SP_LIBRO_ID;

    IF existe_libro = 0 THEN
        SELECT 'Error: El libro con ese ID no existe' AS mensaje;
    ELSE
        -- Obtener el stock del libro
        SELECT stock INTO stock_actual
        FROM libros
        WHERE id = SP_LIBRO_ID;

        -- Verificar si hay stock
        IF stock_actual > 0 THEN
            START TRANSACTION;

            -- Restar 1 al stock
            UPDATE libros
            SET stock = stock - 1
            WHERE id = SP_LIBRO_ID;

            COMMIT;

            SELECT 'Préstamo realizado con éxito' AS mensaje;
        ELSE
            -- No hay stock disponible
            SELECT 'Error: No hay stock disponible para este libro' AS mensaje;
        END IF;
    END IF;
END //

DELIMITER ;


call SP_PRESTAR_LIBRO(2);
	
/*-------------------------------------------------------------------------------------------
-- 1. Tabla de juguetes (nuestros productos)
CREATE TABLE juguetes (
id INT PRIMARY KEY,
nombre VARCHAR(100)
);
-- 2. Tabla de inventario (cuántos tenemos)
CREATE TABLE inventario (
juguete_id INT PRIMARY KEY,
cantidad INT,
FOREIGN KEY (juguete_id) REFERENCES juguetes(id)
);
-- 3. Tabla de ventas (lo que vendemos)
CREATE TABLE ventas (
id INT AUTO_INCREMENT PRIMARY KEY,
juguete_id INT,
cantidad INT,
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (juguete_id) REFERENCES juguetes(id)
);
-- Insertamos datos de prueba
INSERT INTO juguetes VALUES
(1, 'Pelota'),
(2, 'Muñeca'),
(3, 'Puzzle');
INSERT INTO inventario VALUES
(1, 5), -- 5 pelotas
(2, 2), -- 2 muñecas
(3, 0); -- 0 puzzles

1. Crea un procedimiento vender_juguete(juguete_id INT, cantidad
INT) que:
○ Verifique el stock.
○ Si hay suficiente, inicie una transacción para:
■ Insertar la venta.
■ Actualizar el inventario.
○ Si no hay stock, haga ROLLBACK*/
DELIMITER //

CREATE PROCEDURE SP_VENDER_JUGUETE(IN SP_JUGUETE_ID INT, IN SP_CANTIDAD INT)
BEGIN
    DECLARE SP_EXISTE_ID INT;
    DECLARE SP_STOCK_ACTUAL INT;

    -- Verificar si el juguete existe
    SELECT COUNT(*) INTO SP_EXISTE_ID
    FROM juguetes
    WHERE id = SP_JUGUETE_ID;

    IF SP_EXISTE_ID = 0 THEN
        SELECT 'No existe ningún juguete con ese ID' AS mensaje;
    ELSE
        -- Obtener stock actual desde la tabla de inventario
        SELECT cantidad INTO SP_STOCK_ACTUAL
        FROM inventario
        WHERE juguete_id = SP_JUGUETE_ID;

        IF SP_STOCK_ACTUAL < SP_CANTIDAD THEN
            SELECT 'No hay suficiente stock para realizar la venta' AS mensaje;
        ELSE
            -- Iniciar transacción
            START TRANSACTION;

            -- Insertar la venta
            INSERT INTO ventas(juguete_id, cantidad)
            VALUES (SP_JUGUETE_ID, SP_CANTIDAD);

            -- Actualizar el inventario
            UPDATE inventario
            SET cantidad = cantidad - SP_CANTIDAD
            WHERE juguete_id = SP_JUGUETE_ID;

            COMMIT;

            SELECT 'Venta realizada exitosamente' AS mensaje;
        END IF;
    END IF;
END //

DELIMITER ;

CALL SP_VENDER_JUGUETE(1,4);



