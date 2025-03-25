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

CREATE TABLE IF NOT EXISTS orders2 (
	transaction_id VARCHAR(100) NOT NULL,
    product_id INT NOT NULL);


INSERT INTO orders2 (transaction_id, product_id)
SELECT transactions.id as transaction_id, products.id AS product_id
FROM transactions
JOIN products ON FIND_IN_SET(products.id, REPLACE (transactions.product_ids, " ", "")) > 0;

SELECT * FROM orders2;