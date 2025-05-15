create database Practica1;

use Practica1;

create table Categorias(
	categoria_id int primary key,
    nombre varchar(50) not null
);

create table Products (
	product_id int primary key,
    nombre_producto varchar(50) not null,
	codigo_bara varchar(50) unique not null,
    precio float default 0 check (precio >= 0),
    cantidad_stock int default 0,
    categoria_id int,
    foreign key (Categoria_id) references Categorias(categoria_id)
    );
    

    
    create table Vehiculos (
		vehiculos_id int primary key,
        marca varchar(50) not null,
        modelo varchar(50) not null, 
        tipo_vehiculo varchar(50) not null,
        patente varchar(50) unique not null,
        tipo_combustible varchar(50) not null,
        kilometraje int check (kilometraje >= 0),
        fecha_revision_tecnica date not null,
        disponibilidad boolean not null,
    );