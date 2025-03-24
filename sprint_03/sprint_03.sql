-- Nivel 1
-- Ejercicio 1

-- Creamos la base de datos
CREATE DATABASE IF NOT EXISTS transactions;
USE transactions;

-- Creamos la tabla transaction
CREATE TABLE IF NOT EXISTS transaction (
	id VARCHAR(255) PRIMARY KEY,
	credit_card_id VARCHAR(15) REFERENCES credit_card(id),
	company_id VARCHAR(20), 
	user_id INT REFERENCES user(id),
	lat FLOAT,
	longitude FLOAT,
	timestamp TIMESTAMP,
	amount DECIMAL(10, 2),
	declined BOOLEAN,
    FOREIGN KEY (company_id) REFERENCES company(id) 
);

-- Creamos la tabla company
CREATE TABLE IF NOT EXISTS company (
	id VARCHAR(15) PRIMARY KEY,
	company_name VARCHAR(255),
	phone VARCHAR(15),
	email VARCHAR(100),
	country VARCHAR(100),
	website VARCHAR(255));
    
-- insertamos los datos de las tablas

-- creación de la tabla credit_card
CREATE INDEX idx_credit_card_id ON transaction(credit_card_id);

DROP TABLE IF EXISTS credit_card;
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(20) PRIMARY KEY,
    iban VARCHAR(50),
	pan VARCHAR(50),
    pin VARCHAR(50),
    cvv INT,
    expiring_date VARCHAR(20));
    
-- insertamos los datos

-- relacionamos las tablas
ALTER TABLE transaction ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- mostramos el resultado
SHOW TABLES FROM transactions;
SHOW COLUMNS FROM company;
SHOW COLUMNS FROM credit_card;
SHOW COLUMNS FROM transaction;
SHOW INDEXES FROM transaction;

-- Ejercicio 2
-- Modificar el iban del usuario con id "CcU-2938"
SELECT * FROM credit_card
WHERE id = "CcU-2938";

UPDATE credit_card set
iban = "R323456312213576817699999"
WHERE id = "CcU-2938";

-- Ejercicio 3
-- ingresar un nuevo usuario
SELECT * FROM transaction
WHERE id = "108B1D1D-5B23-A76C-55EF-C568E49A99DD";

SELECT * FROM credit_card
WHERE id = "CcU-9999";

SELECT * FROM company
WHERE id = "b-9999";

INSERT INTO company (id)
VALUES ('b-9999');

INSERT INTO credit_card (id)
VALUES ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

-- Ejercicio 4
-- Eliminar la columna pan de credit_card

SHOW COLUMNS FROM credit_card;

ALTER TABLE credit_card DROP COLUMN pan;

-- Nivell 2
-- Ejercicio 1
-- Eliminar de transaction el registroID 02C6201E-D90A-1859-B4EE-88D2986D3B02
SELECT * FROM transaction WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

DELETE FROM transaction WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- Ejercicio 2
-- Creación de un View: VistaMarketing 
CREATE VIEW VistaMarketing AS 
SELECT company_name, company.phone, company.country, AVG(amount) as media_compra
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
GROUP BY company_name, company.phone, company.country
ORDER BY media_compra DESC;

SELECT * FROM VistaMarketing;

-- Ejercicio 3
-- Filtrar la vista VistaMarketing per a mostrar las compañías en "Germany"
SELECT * FROM VistaMarketing
WHERE country = "Germany";

-- Nivell 3
-- Ejercicio 1
-- Comandos para generar el diagrama
SHOW TABLES FROM transactions;

-- Creamos la tabla user
CREATE INDEX idx_user_id ON transaction(user_id);
DROP TABLE IF EXISTS user;
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
		FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );
        
-- insertar datos

-- modificar el nombre de la tabla
ALTER TABLE user RENAME TO data_user;

SHOW TABLES FROM transactions;

SHOW INDEXES FROM transaction;
SHOW COLUMNS FROM transaction;
SHOW COLUMNS FROM company;

-- eliminar la columna website
ALTER TABLE company DROP COLUMN website;

SHOW COLUMNS FROM data_user;

-- cambiar el nombre de la columna email
ALTER TABLE data_user CHANGE email personal_email VARCHAR(150);

SHOW COLUMNS FROM credit_card;

-- Crear la columna fecha_actual
ALTER TABLE credit_card ADD COLUMN fecha_actual DATE;

-- En caso de que se quisiera rellenar la columna con la fecha actual:
-- UPDATE credit_card SET fecha_actual = CURDATE();

-- error con la Foreign Key
-- eliminar FK
ALTER TABLE data_user DROP FOREIGN KEY data_user_ibfk_1;

-- añadimos el registro a data_user id = 9999
-- confirmamos que no exista ya
SELECT * FROM data_user WHERE id = 9999;

-- insertar registro de la transacción insertada previamente para que los datos coincidan
INSERT INTO data_user (id) VALUES (9999);

-- crear relación pk/fk
ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES data_user(id);
    
-- Ejercicio 2
-- Crear VIEW: "InformeTecnico" 
CREATE VIEW InformeTecnico AS
SELECT transaction.id AS transaccion, CONCAT(data_user.name, " ", surname) AS usuario, 
company_name AS empresa, iban, declined AS declinada, SUM(amount) AS total_compras  
FROM transaction
INNER JOIN data_user ON transaction.user_id = data_user.id
INNER JOIN credit_card ON transaction.credit_card_id = credit_card.id
INNER JOIN company ON transaction.company_id = company.id
GROUP BY transaccion
ORDER BY transaction.id DESC;

SELECT * FROM InformeTecnico;

DROP VIEW InformeTecnico;









