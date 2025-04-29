create database SistemaGestionVentasDB;

use SistemaGestionVentasDB;

create table Clientes(
	id_cliente int auto_increment primary key,
	id_cliente int auto_increment primary key,
	nombre varchar(50) not null,
    correo_electronico varchar(100) not null unique
);

create table Productos(
	id_producto int auto_increment primary key,
    nombre varchar(50) not null,
    precio decimal(10, 2) not null,
    stock int default 0,
    check (precio > 0),
    check (stock >= 0)
);

create table Pedidos(
	id_pedidos int auto_increment primary key,
    id_cliente int not null,
    id_producto int not null,
    cantidad int not null check(cantidad > 0),
    fecha date not null,
	FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) on delete cascade,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) on delete cascade
);


DELIMITER //
CREATE TRIGGER valida_stock_pedido
before insert on pedidos
for each row
begin 
	declare stock_disponible int;
    
    select stock into stock_disponible
    from productos
    where id_producto = new.id_producto;
    
    if new.cantidad > stock_disponible then
		signal sqlstate '45000'
        set message_text = 'no hay suficiente stock para relizar el pedido';
	end if;
end;
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


