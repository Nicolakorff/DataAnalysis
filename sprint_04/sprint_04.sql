-- NIVELL 1

-- Creación base de datos
-- Creamos el esquema de las tablas
CREATE DATABASE IF NOT EXISTS sales;
USE sales;

-- Creamos las tbalas
CREATE TABLE IF NOT EXISTS credit_cards (
	id VARCHAR(20) PRIMARY KEY,
    user_id INT NOT NULL,
    iban VARCHAR(50) UNIQUE NOT NULL,
    pan VARCHAR(50) UNIQUE NOT NULL,
    pin VARCHAR(50) NOT NULL,
    cvv INT NOT NULL,
    track1 VARCHAR(50),
    track2 VARCHAR(50),
    expiring_date VARCHAR(10) NOT NULL);
    
CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(50),
    country VARCHAR(20),
    website VARCHAR(100));
    
CREATE TABLE IF NOT EXISTS users (
	id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(255),
    birth_date VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(50),
    adress VARCHAR(255));
    
CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(100) PRIMARY KEY,
    card_id VARCHAR(20) NOT NULL,
    business_id VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    declined boolean,
    product_ids VARCHAR(50) NOT NULL,
    user_id INT NOT NULL,
    lat FLOAT,
    longitude FLOAT);
    
-- Comprobamos y habilitamos la inserción de archivos locales
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = TRUE;

-- Insertamos de datos
LOAD DATA LOCAL INFILE 'C:/Users/Nicola Korff/Desktop/SQL/da/sprint_04/credit_cards.csv' 
INTO TABLE credit_cards 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT * FROM credit_cards;

LOAD DATA LOCAL INFILE 'C:/Users/Nicola Korff/Desktop/SQL/da/sprint_04/companies.csv' 
INTO TABLE companies 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT * FROM companies;

LOAD DATA LOCAL INFILE 'C:/Users/Nicola Korff/Desktop/SQL/da/sprint_04/users_ca.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Nicola Korff/Desktop/SQL/da/sprint_04/users_uk.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Nicola Korff/Desktop/SQL/da/sprint_04/users_usa.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ','
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

SELECT * FROM users;

LOAD DATA LOCAL INFILE 'C:/Users/Nicola Korff/Desktop/SQL/da/sprint_04/transactions.csv' 
INTO TABLE transactions 
FIELDS TERMINATED BY ';'
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

SELECT * FROM transactions;

-- Cambios en las tablas
-- Eliminamos id_user de la tabla credit_cards
ALTER TABLE credit_cards DROP COLUMN user_id;

-- Modificamos el tipo de dato de la columna expiring_date:
ALTER TABLE credit_cards ADD COLUMN expiring_date_temp DATE; 
UPDATE credit_cards SET expiring_date_temp = STR_TO_DATE(expiring_date, '%m/%d/%y');
ALTER TABLE credit_cards DROP expiring_date;
ALTER TABLE credit_cards CHANGE expiring_date_temp expiring_date DATE NOT NULL;

SHOW COLUMNS FROM credit_cards;

-- En user modificamos el tipo de dato de la columna birth_date: 
ALTER TABLE users ADD COLUMN birth_date_temp DATE; 
UPDATE users SET birth_date_temp = STR_TO_DATE(birth_date, '%b %d, %Y');
ALTER TABLE users DROP birth_date;
ALTER TABLE users CHANGE birth_date_temp birth_date DATE NOT NULL;

SHOW COLUMNS FROM users;

-- Comprobamos que todo se ha creado correctamente
SHOW TABLES FROM sales;

SHOW COLUMNS FROM credit_cards;
SHOW COLUMNS FROM companies;
SHOW COLUMNS FROM users;
SHOW COLUMNS FROM transactions;


-- Creamos las relaciones de Foreign keys entre las tablas
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_credit_cards FOREIGN KEY (card_id) REFERENCES credit_cards (id),
ADD CONSTRAINT fk_transactions_companies FOREIGN KEY (business_id) REFERENCES companies (company_id),
ADD CONSTRAINT fk_transactions_users FOREIGN KEY (user_id) REFERENCES users (id);

-- Comprobamos que se han creado correctamente
SHOW INDEXES FROM transactions;

-- Ejercicio 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT users.id AS id_usuario, CONCAT(users.name, " ", users.surname) AS nombre_usuario 
FROM users 
WHERE id IN (SELECT user_id FROM transactions 
				GROUP BY user_id 
				HAVING COUNT(id) > 30);


-- Ejercicio 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

-- Opción 1: teniendo en cuenta todas las transacciones
SELECT iban, ROUND(AVG(amount),2) AS media_ventas
FROM transactions
LEFT JOIN credit_cards ON transactions.card_id = credit_cards.id
LEFT JOIN companies ON transactions.business_id = companies.company_id
WHERE company_name = "Donec Ltd"
GROUP BY iban;

-- Opción 2: hacemos lo mismo, pero descartando las transacciones con pagos rechazados
SELECT iban, ROUND(AVG(amount),2) AS media_ventas
FROM transactions
LEFT JOIN credit_cards ON transactions.card_id = credit_cards.id
LEFT JOIN companies ON transactions.business_id = companies.company_id
WHERE company_name = "Donec Ltd" AND declined = 0
GROUP BY iban;

-- NIVELL 2

-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades:
-- creamos la tabla 
CREATE TABLE credit_status (
    card_id VARCHAR(20) PRIMARY KEY,
    iban VARCHAR(34) NOT NULL,
    status ENUM('activa', 'bloqueada') NOT NULL);
   
   -- Comprobamos que se ha creado correctamente
    SHOW TABLES FROM sales;

-- Insertar en la tabla los datos filtrados
INSERT INTO credit_status (card_id, iban, status)
SELECT credit_cards.id, credit_cards.iban, 
    CASE 
        WHEN (SELECT COUNT(*) FROM transactions 
            WHERE transactions.card_id = credit_cards.id AND transactions.declined = TRUE 
	ORDER BY transactions.timestamp DESC 
            LIMIT 3) 
        THEN 'bloqueada' 
        ELSE 'activa' 
    END AS status
FROM credit_cards;

SELECT * FROM credit_status;
Select COUNT(id) FROM credit_cards; # para mostrar la cantidad de credit_cards que hay

-- Añadimos el Foreign Key
ALTER TABLE credit_cards
ADD CONSTRAINT fk_credit_cards_credit_status FOREIGN KEY (id) REFERENCES credit_status (card_id);

SHOW INDEXES FROM credit_cards;

-- Ejercicio 1
-- Quantes targetes estan actives?
SELECT COUNT(*) AS targetas_activas 
FROM credit_status 
WHERE status = 'activa';

-- Para ver también los iban:
SELECT card_id, iban 
FROM credit_status 
WHERE status = 'activa';

-- NIVELL 3

-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids.
-- Primero crearemos la tabla products:
CREATE TABLE IF NOT EXISTS products (
	id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price VARCHAR(10) NOT NULL,
    color VARCHAR(20),
    weight FLOAT,
    warehouse_id VARCHAR(10));

-- Insertamos los datos en la tabla products:
LOAD DATA LOCAL INFILE 'C:/Users/Nicola Korff/Desktop/SQL/da/sprint_04/products.csv' 
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM products;

-- comprobamos que se ha creado correctamente
SHOW TABLES FROM sales;
SHOW COLUMNS FROM products;

-- Cambios en la tabla:
-- Eliminar el simbolo $
UPDATE products SET price = REPLACE(price, '$', '');
-- Modificar de VARCHAR a FLOAT
ALTER TABLE products MODIFY price FLOAT NOT NULL;

-- Creamos la tabla intermedio a la que denominamos orders a partir de las columnas id y product_ids de transactions:
CREATE TABLE orders SELECT id, product_ids FROM transactions;

SELECT * FROM orders;

-- A la columna id la convertimos a 0 y le asignamos un número de id automático
SET @row_number = 0;
UPDATE orders SET id = (@row_number := @row_number + 1);
SELECT * FROM orders;

-- creamos la tabla temporal:
CREATE TABLE temp_orders (
	id INT,
	product_id1 INT,
	product_id2 INT,
	product_id3 INT,
   	product_id4 INT);

-- insertamos los productos_id de la tabla
INSERT INTO temp_orders (id, product_id1, product_id2, product_id3, product_id4)
SELECT id,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 1), ',', -1) AS UNSIGNED) AS product_id1,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1) AS UNSIGNED) AS product_id2,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1) AS UNSIGNED) AS product_id3,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1) AS UNSIGNED) AS product_id4
FROM orders;

SELECT * FROM temp_orders;

'''
Otra opción más sencilla de hacerlo para utilizar en un caso similar que me han enseñado durante la correción.
INSERT INTO temp_orders (transacciones_id, producto_id)
SELECT trasnactions.id as trasnacciones_id, products.id AS producto_id
FROM transactions
JOIN products ON FIND_IN_SET(products.id, REPLACES (transactions.products_id " ". "")) > 0;
''' 

-- Una vez resuelta la separación de los valores, traspasamos los datos de la tabla temp_orders a  trasp_order respetando sus ids. 
-- Creamo una tabla auxiliar a la que denominamos trasp_order para traspasar los valores:
CREATE TABLE trasp_order (
	id INT NOT NULL,
    product_id INT);

-- Insertamos los valores:
INSERT INTO trasp_order (id, product_id)
SELECT id, product_id1 
FROM temp_orders
WHERE product_id1 IS NOT NULL 
UNION ALL
SELECT id, product_id2 
FROM temp_orders 
WHERE product_id2 IS NOT NULL
UNION ALL
SELECT id, product_id3 
FROM temp_orders
WHERE product_id3 IS NOT NULL
UNION ALL
SELECT id, product_id4 
FROM temp_orders
WHERE product_id4 IS NOT NULL;

SELECT * FROM trasp_order;

-- Borrar la tabla original "orders" la cual será reemplazada con "trasp_order"
DROP table orders;

-- Renombrar la tabla "trasp_order" a su valor final "orders".
ALTER TABLE trasp_order RENAME orders;

-- Borrar tabla temporal "temp_orders"
DROP TABLE temp_orders;

-- Comprobamos como han quedado las columnas en la tabla:
SHOW TABLES FROM sales;

SELECT * FROM orders ORDER BY id;

-- Le cambiamos el nombre a la columna, la vaciamos y la convertimos en INT
ALTER TABLE transactions CHANGE COLUMN product_ids order_id VARCHAR(50);
UPDATE transactions SET order_id=0;
ALTER TABLE transactions MODIFY COLUMN order_id INT;

-- Hacemos unos cambios en la tabla orders:
ALTER TABLE orders MODIFY id INT NOT NULL;
ALTER TABLE orders MODIFY product_id INT NOT NULL;

-- Comprobamos
SELECT * FROM transactions;

-- Y la rellenamos asignandole un id a transactions.order_id
SET @row_number = 0;
UPDATE transactions SET order_id = (@row_number := @row_number + 1);

-- Comprobamos
SELECT * FROM transactions;

SHOW COLUMNS FROM orders;

-- Añadimos los Foreign Key
-- Tabla orders
-- Creamos un índice de id en orders para vincular con la Foreign Key de la tabla transactions.
CREATE INDEX idx_id ON orders(id);
ALTER TABLE orders
ADD CONSTRAINT fk_orders_products FOREIGN KEY (product_id) REFERENCES products (id);

-- Tabla transactions
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_orders FOREIGN KEY (order_id) REFERENCES orders (id);

-- Comprobamos
SHOW INDEXES FROM orders;
SHOW INDEXES FROM transactions;

-- Ejercicio 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT products.id, products.product_name, count(orders.product_id) AS cantidad_ventas
FROM orders
JOIN products ON orders.product_id = products.id
JOIN transactions ON orders.id = transactions.order_id
WHERE transactions.declined = 0
GROUP BY products.id
ORDER BY cantidad_ventas DESC;


    











