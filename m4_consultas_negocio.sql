-- Pre Entrega 3 (Clase Anterior). Silvina Pampin

CREATE DATABASE ventas_tech_db;
GO
USE ventas_tech_db;
GO

-- Sección 1 — DROP TABLES
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

-- Sección 2 — CREATE TABLES

CREATE TABLE categorias (
	id_categoria INT PRIMARY KEY,
	nombre_categoria VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200)
);

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY,
	nombre VARCHAR (100) NOT NULL,
	email VARCHAR(100) unique,
	ciudad VARCHAR(50),
	fecha_registro DATE NOT NULL
);

CREATE TABLE productos (
	id_producto INT PRIMARY KEY,
	nombre_producto VARCHAR(100) NOT NULL,
	id_categoria INT,
	precio DECIMAL(10,2) NOT NULL,
	stock INT DEFAULT 0,
	activo BIT DEFAULT 1,
	FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE ventas (
	id_venta INT PRIMARY KEY,
	id_cliente INT,
	id_producto INT,
	cantidad INT NOT NULL,
	precio_unitario DECIMAL(10,2) NOT NULL,
	fecha_venta DATE NOT NULL,
	FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
	FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Sección 3 — INSERT DATA

INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
  (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
  (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
  (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
  (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

  INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
  (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
  (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
  (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
  (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
  (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

  INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
  ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
  ( 2, 2, 2, 5,   28.00, '2024-03-06'),
  ( 3, 3, 3, 1,  450.00, '2024-03-07'),
  ( 4, 1, 4, 2,  120.00, '2024-03-08'),
  ( 5, 4, 5, 3,  130.00, '2024-03-10'),
  ( 6, 2, 6, 4,   95.00, '2024-03-11'),
  ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
  ( 8, 3, 2, 8,   28.00, '2024-03-13'),
  ( 9, 4, 4, 1,  120.00, '2024-03-14'),
  (10, 5, 3, 2,  450.00, '2024-03-15');

  -- Sección 4 — VALIDACIÓN

SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas

-- Pre entrega 4. Silvina Pampin
-- Consulta 1: Resumen ejecutivo mensual Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes. 

SELECT YEAR(fecha_venta) as anio,
       MONTH(fecha_venta) as mes,
	   SUM(cantidad * precio_unitario) as total_facturado,
	   COUNT(id_cliente) as cantidad_de_pedidos,
	   cast(AVG(cantidad * precio_unitario) as decimal(10,2)) as ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes
;

-- Consulta 2:  Ranking de productos Top 5 de id_producto por total facturado, mostrando las unidades vendidas y el total generado.

SELECT TOP 5 id_producto, 
       SUM(cantidad * precio_unitario) as total_facturado,
       SUM(cantidad) as unidades_vendidas
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
;

-- Consulta 3: Clientes recurrentes id_cliente que hayan realizado más de un pedido, mostrando la cantidad de pedidos y el total gastado.

SELECT id_cliente,
       SUM(cantidad * precio_unitario) as total_gastado,
       COUNT(id_venta) as cantidad_de_pedidos
FROM ventas
GROUP BY id_cliente
HAVING COUNT(id_venta) > 1
ORDER BY cantidad_de_pedidos DESC
;

-- Consulta 4: Productos por encima/por debajo del promedio Total facturado por id_producto, con una columna adicional que etiquete con CASE WHEN si ese producto quedó 'Por encima' o 'Por debajo' del promedio de facturación por producto.

WITH ventas_mensuales AS ( 
SELECT id_producto, YEAR(fecha_venta) AS anio, MONTH(fecha_venta) AS mes,
SUM(cantidad * precio_unitario) AS facturacion 
FROM ventas
GROUP BY id_producto, YEAR(fecha_venta), MONTH(fecha_venta)
)
SELECT Id_producto, anio, mes, facturacion, 
CASE WHEN facturacion >= (SELECT AVG(facturacion) FROM ventas_mensuales)
THEN 'Por encima' ELSE 'Por debajo'
END AS evaluacion_promedio
FROM ventas_mensuales
ORDER BY anio, mes;

-- Extra: 3 hallazgos concretos que encontraste al revisar los resultados. 
-- "El cliente 1 tiene el 41% de la facturación del trimestre."
-- "Solo el 33% de los productos  (1 y 3) se encuentran por encima del total promedio facturado por id_producto en dicho período"
-- "El producto más vendido también es el 2 con un 50% de la cantidad vendida del top 5 de productos"

-- GRACIAS