CREATE DATABASE IF NOT EXISTS SistemaGestionVentasDB;

USE SistemaGestionVentasDB;

CREATE TABLE IF NOT EXISTS Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) UNIQUE,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE IF NOT EXISTS Pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    fecha DATE NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER IF NOT EXISTS valida_stock_pedido
BEFORE INSERT ON Pedidos
FOR EACH ROW
BEGIN
    DECLARE stock_disponible INT;

    SELECT stock INTO stock_disponible
    FROM Productos
    WHERE id_producto = NEW.id_producto;

    IF NEW.cantidad > stock_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock para realizar el pedido.';
    END IF;
END;
//
DELIMITER ;

/*--------- INSERTAR CLIENTES --------*/
INSERT INTO CLIENTES(NOMBRE, CORREO_ELECTRONICO)
VALUES('JUAN', 'JUAN@GMAIL.COM');

/*--------- INSERTAR PRODUCTOS --------*/
INSERT INTO PRODUCTOS(NOMBRE, PRECIO, STOCK)
VALUES('AZUCAR', 50, 10);

/*--------- PRUEBA DE RESTRICCIONES --------*/
INSERT INTO CLIENTES(NOMBRE)
VALUES('JUAN' );

INSERT INTO PRODUCTOS(NOMBRE, PRECIO, STOCK)
VALUES('AZUCAR', 50, -3);

INSERT INTO PEDIDOS(ID_CLIENTE, ID_PRODUCTO, CANTIDAD, FECHA)
VALUES(1, 1, 11, NOW());


/*-------------------------------- 2  -----------------------------------------*/
/*1.	Clientes: 
○	Cada cliente debe tener una forma única de ser identificado en el sistema. 
○ El nombre del cliente es un dato obligatorio. 
○ El teléfono y el correo electrónico son datos importantes que deben cumplir ciertas condiciones para evitar duplicados o valores inválidos. 
*/
CREATE DATABASE IF NOT EXISTS SistemaGestionLibrosDB;

USE SistemaGestionLibrosDB;

CREATE TABLE IF NOT EXISTS Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL CHECK (telefono REGEXP '^[0-9]{6,15}$') UNIQUE,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE CHECK (correo_electronico REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') UNIQUE
);

CREATE TABLE IF NOT EXISTS Libros (
    id_libro INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL UNIQUE,
    autor VARCHAR(100) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0)
);

CREATE TABLE IF NOT EXISTS Prestamos (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_libro INT NOT NULL,
    fecha_prestamo TIMESTAMP DEFAULT CURRENT_TIMESTAMP UNIQUE,
    fecha_devolucion_estimada DATE NOT NULL,
    fecha_devolucion_real TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_libro) REFERENCES Libros(id_libro) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER IF NOT EXISTS validar_stock_prestamo
BEFORE INSERT ON Prestamos
FOR EACH ROW
BEGIN
    DECLARE stock_disponible INT;

    SELECT stock INTO stock_disponible
    FROM Libros
    WHERE id_libro = NEW.id_libro;

    IF stock_disponible < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock disponible para prestar este libro.';
    END IF;

    UPDATE Libros
    SET stock = stock - 1
    WHERE id_libro = NEW.id_libro;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER IF NOT EXISTS actualizar_stock_devolucion
AFTER UPDATE ON Prestamos
FOR EACH ROW
BEGIN
    IF NEW.fecha_devolucion_real IS NOT NULL AND OLD.fecha_devolucion_real IS NULL THEN
        UPDATE Libros
        SET stock = stock + 1
        WHERE id_libro = NEW.id_libro;
    END IF;
END;
//
DELIMITER ;

/*--------- PRUEBA DE RESTRICCIONES --------*/
INSERT INTO CLIENTES(NOMBRE, TELEFONO, CORREO_ELECTRONICO)
VALUES('JUAN', '0303456', 'JUAN@HOTMAIL.COM' );

INSERT INTO LIBROS(TITULO, AUTOR, STOCK, PRECIO)
VALUES('100 AÑOS DE SOLEDAD', 'LORCA' , 1, 35000);

INSERT INTO CLIENTES(NOMBRE, TELEFONO, CORREO_ELECTRONICO)
VALUES('JUAN', '0303456', 'JUANHOTMAIL.COM' );

INSERT INTO LIBROS(TITULO, AUTOR, STOCK, PRECIO)
VALUES('100 AÑOS DE SOLEDAD', 'LORCA' , -1, 35000);

SELECT * FROM LIBROS;

INSERT INTO Prestamos (id_cliente, id_libro, fecha_devolucion_estimada)
VALUES (1, 3, DATE('2025-05-10'));

-- actulizar devolucion 
UPDATE Prestamos
SET fecha_devolucion_real = NOW() -- ALTERNATIVA '2025-05-02 14:30:00'
WHERE id_prestamo = 1;


/*----------------------------------------- 3 ---------------------------*/
CREATE DATABASE HOTELESDB;

USE HOTELESDB;
/*1.	Habitaciones: 
○	Cada habitación tiene un número único que la identifica. 
○ El tipo de habitación (individual, doble, suite) es un dato obligatorio. 
○ El precio por noche debe ser mayor a 0. 
○ La habitación puede estar disponible o no, dependiendo de las reservas. */
CREATE TABLE IF NOT EXISTS HABITACIONES(
    ID_HABITACION INT AUTO_INCREMENT PRIMARY KEY,
    TIPO_HABITACION ENUM('INDIVIDUAL', 'DOBLE', 'SUITE') NOT NULL,
    PRECIO_POR_NOCHE DECIMAL(10, 2) NOT NULL,
    DISPONIBLE BOOLEAN DEFAULT TRUE,
    CONSTRAINT CHK_PRECIO CHECK (PRECIO_POR_NOCHE > 0)
);

/*2.	Clientes: 
○	Cada cliente tiene una forma única de ser identificado en el sistema. 
○ El nombre y el correo electrónico son datos obligatorios. ○ El correo electrónico debe ser único para cada cliente.*/ 
CREATE TABLE IF NOT EXISTS CLIENTES(
    ID_CLIENTE INT AUTO_INCREMENT PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE CHECK (correo_electronico REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);


/*3.	Reservas: 
○	Cada reserva tiene un identificador único. 
○ Una reserva está asociada a un cliente y a una habitación. 
○ Las fechas de check-in y check-out son obligatorias. 
○ No se puede reservar una habitación si ya está ocupada en las fechas solicitadas. 
○ Si un cliente se elimina, sus reservas también deben eliminarse. 
○ Si una habitación se elimina, las reservas asociadas deben manejarse de alguna forma específica. 
*/
CREATE TABLE IF NOT EXISTS RESERVAS(
    ID_RESERVAS INT AUTO_INCREMENT PRIMARY KEY,
    ID_CLIENTE INT NOT NULL,
    ID_HABITACION INT NOT NULL,
    FECHA_CHECK_IN DATETIME NOT NULL,
    FECHA_CHECK_OUT DATETIME NOT NULL,
    FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTES(ID_CLIENTE) ON DELETE CASCADE,
    FOREIGN KEY (ID_HABITACION) REFERENCES HABITACIONES(ID_HABITACION) ON DELETE CASCADE,
    -- Aseguramos que la fecha de check-in sea anterior a la de check-out
    CONSTRAINT CHK_FECHAS CHECK (FECHA_CHECK_IN < FECHA_CHECK_OUT)
);
/*PASO 4: Agregar un TRIGGER para Validar la Disponibilidad de la Habitación 
Con base en la narrativa, los alumnos deben definir un trigger que evite reservar una habitación si ya está ocupada en las fechas solicitadas. */
DELIMITER //
CREATE TRIGGER VALIDAR_DISPONIBILIDAD
BEFORE INSERT ON RESERVAS
FOR EACH ROW
BEGIN
    -- Verificar si existe alguna reserva para la misma habitación que se superponga con las nuevas fechas
    IF EXISTS (
        SELECT 1
        FROM RESERVAS
        WHERE
            ID_HABITACION = NEW.ID_HABITACION AND
            NEW.FECHA_CHECK_IN < FECHA_CHECK_OUT AND
            NEW.FECHA_CHECK_OUT > FECHA_CHECK_IN
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La habitación no está disponible para las fechas solicitadas.';
    END IF;
END;
//
DELIMITER ;

INSERT INTO CLIENTES(NOMBRE, CORREO_ELECTRONICO)VALUES('PEPE', 'PEPE@HOTMAIL.COM');

INSERT INTO CLIENTES(NOMBRE, CORREO_ELECTRONICO)VALUES('PEPE', 'PEPE@HOTMAIL.COM');

INSERT INTO HABITACIONES (TIPO_HABITACION, PRECIO_POR_NOCHE, DISPONIBLE)
VALUES ('INDIVIDUAL', 50.00, 0);

USE HOTELESDB;

USE HOTELESDB;

INSERT INTO RESERVAS (ID_CLIENTE, ID_HABITACION, FECHA_CHECK_IN, FECHA_CHECK_OUT)
VALUES (1, 2, '2025-05-10 14:00:00', '2025-05-12 12:00:00');
