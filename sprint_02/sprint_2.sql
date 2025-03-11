-- EJERCICIO 2
-- Utilitzant JOIN realitzaràs les següents consultes:
-- Llistat dels països que estan fent compres.
SELECT DISTINCT country
FROM company
INNER JOIN transaction 
ON company.id = transaction.company_id;

-- Des de quants països es realitzen les compres.
SELECT count(DISTINCT country) as paises
FROM company
INNER JOIN transaction 
ON company.id = transaction.company_id;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_id, company_name, ROUND(AVG(amount),2) as media_ventas_usd
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company_id, company_name
ORDER BY media_ventas_usd DESC
LIMIT 1;

-- EJERCICIO 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT transaction.id, company_id, amount as amount_usd
FROM transaction
WHERE company_id IN (SELECT id FROM company WHERE country = 'Germany');

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-- Opció 1 con order by
SELECT DISTINCT company_name
FROM company
WHERE id IN (SELECT company_id FROM transaction 
			WHERE amount >(SELECT AVG(amount) FROM transaction))
ORDER BY company_name;

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
-- Opción 1: Lo haría así, pero no me da resultado pero he comparobado y en ambos casos id = 100 y company_id = 100
-- Todas las compañías tienen transacciones registradas
SELECT company_name
FROM company
WHERE company.id NOT IN (SELECT company_id FROM transaction);

-- Opción 2: Nulls en amount tampoco devuelve nada
SELECT company_name
FROM company
WHERE id IN (SELECT company_id FROM transaction
				WHERE amount IS NULL OR amount = '');

-- Opción 3                
SELECT DISTINCT company_name
FROM company
WHERE NOT EXISTS (SELECT 1 FROM transaction 
					WHERE company_id = company.id);

-- NIVELL 2
-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
-- Opción 1 total de ingreso por dia: 
SELECT DATE(timestamp) AS fecha, sum(amount) as ingresos
FROM transaction
WHERE declined = 0
GROUP BY fecha
ORDER BY ingresos DESC
LIMIT 5;

-- Opción 2 total de ingreso por dia por transacción:
SELECT DATE(timestamp) AS fecha, transaction.id, amount
FROM transaction
INNER JOIN (SELECT DATE(timestamp) AS fecha, SUM(amount) AS ingresos
    FROM transaction
    GROUP BY fecha
    ORDER BY ingresos DESC
    LIMIT 5) dias_top 
ON DATE(timestamp) = dias_top.fecha
ORDER BY dias_top.fecha, timestamp;

-- Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT country, ROUND(AVG(amount),2) as media_ventas_usd
FROM transaction
INNER JOIN company 
ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY country
ORDER BY media_ventas_usd DESC;

-- Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Mostra el llistat aplicant JOIN i subconsultes.
SELECT transaction.id, company_name
FROM company
INNER JOIN transaction 
ON company.id = transaction.company_id
WHERE country = (SELECT country FROM company
				WHERE company_name = "Non Institute") AND NOT company_name = "Non Institute"
ORDER BY company_name;

-- Mostra el llistat aplicant solament subconsultes.
SELECT transaction.id, company_id
FROM transaction
WHERE company_id IN (SELECT id FROM company
					WHERE country = (SELECT country FROM company
									WHERE company_name = "Non Institute") AND NOT company_name = "Non Institute")
ORDER BY company_id;

-- NIVELL 3
-- Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
SELECT company_name, phone, country, DATE(timestamp) as fecha, amount
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
WHERE DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
GROUP BY company_name, phone, country, DATE(timestamp), amount
HAVING amount BETWEEN 100 AND 200
ORDER BY amount DESC;

-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
SELECT company_name,
    CASE 
        WHEN COUNT(transaction.id) > 4 THEN 'Más de 4'
        ELSE 'Menos de 4'
    END AS cantidad_transacciones
FROM company
LEFT JOIN transaction ON company.id = transaction.company_id
GROUP BY company_name
ORDER BY cantidad_transacciones;









