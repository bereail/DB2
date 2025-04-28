create database SistemaGestionVentasDB;

use SistemaGestionVentasDB;

CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT chk_correo CHECK (correo_electronico REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    CONSTRAINT chk_precio_positivo CHECK (precio > 0),
    CONSTRAINT chk_stock_no_negativo CHECK (stock >= 0)
);


CREATE TABLE Pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    fecha DATE NOT NULL,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE CASCADE,
    CONSTRAINT fk_pedido_producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) ON DELETE CASCADE
);


DELIMITER //

CREATE TRIGGER valida_stock_pedido
BEFORE INSERT ON Pedidos
FOR EACH ROW
BEGIN 
    DECLARE stock_disponible INT;
    
    SELECT stock INTO stock_disponible
    FROM Productos
    WHERE id_producto = NEW.id_producto;
    
    IF NEW.cantidad > stock_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock para realizar el pedido';
    END IF;
END;

//

DELIMITER ;
