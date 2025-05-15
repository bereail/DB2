create database HotelPracticas;

use HotelPracticas;

CREATE DATABASE HotelPracticas;
USE HotelPracticas;

-- Tabla Habitaciones
CREATE TABLE Habitaciones (
    habitaciones_id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_habitacion ENUM('individual', 'doble', 'suite') NOT NULL,
    precio_por_noche INT CHECK (precio_por_noche > 0),
    disponible BOOLEAN DEFAULT TRUE
);

-- Tabla Clientes
CREATE TABLE Clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla Reservas
CREATE TABLE Reservas (
    reservas_id INT AUTO_INCREMENT PRIMARY KEY,
    id_habitacion INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha_check_in DATE NOT NULL,
    fecha_check_out DATE NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(cliente_id) ON DELETE CASCADE,
    FOREIGN KEY (id_habitacion) REFERENCES Habitaciones(habitaciones_id)
);

/*------------- TRIGGER para Validar la Disponibilidad de la Habitación ------------*/
DELIMITER //

CREATE TRIGGER validar_disponibilidad
BEFORE INSERT ON Reservas
FOR EACH ROW
BEGIN
    DECLARE count_reservas INT;

    SELECT COUNT(*)
    INTO count_reservas
    FROM Reservas
    WHERE id_habitacion = NEW.id_habitacion
      AND (
          (NEW.fecha_check_in BETWEEN fecha_check_in AND fecha_check_out) OR
          (NEW.fecha_check_out BETWEEN fecha_check_in AND fecha_check_out) OR
          (fecha_check_in BETWEEN NEW.fecha_check_in AND NEW.fecha_check_out)
      );

    IF count_reservas > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ La habitación ya está reservada en las fechas indicadas';
    END IF;
END;
//

DELIMITER ;

