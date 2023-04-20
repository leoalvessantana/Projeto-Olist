-- 1. Qual o número de clientes únicos de todos os estados?
SELECT
c.customer_state,
COUNT( DISTINCT c.customer_id ) AS numero_clientes
FROM customer c
GROUP BY c.customer_state;


-- 2. Qual o número de clientes únicos de todas as cidades de Minas Gerais?
SELECT
c.customer_city,
COUNT( DISTINCT c.customer_id ) AS numero_clientes
FROM customer c
WHERE c.customer_state = 'MG'
GROUP BY c.customer_city;


-- 3. Gere uma tabela com a latitude e longitude da cidade de Uberlândia
SELECT
g.geolocation_lat,
g.geolocation_lng,
g.geolocation_city,
g.geolocation_state
FROM geolocation g
WHERE g.geolocation_city = 'uberlandia';


-- 4. Qual o valor médio, máximo e mínimo do preço de todos os pedidos de cada produto?
SELECT
oi.product_id,
AVG( oi.price ) AS preco_medio,
MIN( oi.price ) AS preco_minimo,
MAX( oi.price ) AS preco_maximo
FROM order_items oi
GROUP BY oi.product_id;


-- 5. Qual o valor médio, máximo e mínimo do preço de todos os pedidos?
SELECT
ROUND(AVG( price ), 2) AS 'Média',
ROUND(MAX( price ), 2) AS 'Máximo',
ROUND(MIN(price), 2)   AS 'Mínimo' 
FROM order_items oi;


-- 6. Qual a quantidade de pedidos e a média do valor do pagamento por tipo de pagamentos? (OBS: Ordenar pela quantidade de pedidos.)
SELECT
payment_type,
COUNT( op.order_id ) AS pedidos,
ROUND(AVG( op.payment_value ), 2) AS pagamento_medio
FROM order_payments op
GROUP BY op.payment_type
ORDER BY COUNT( op.order_id ) DESC;



-- 7. Qual o total de pedidos entre Janeiro de 2017 e Agosto de 2018?
SELECT 
COUNT(o.order_id) 
FROM orders o 
WHERE DATE(o.order_approved_at) BETWEEN (DATE(o.order_approved_at)='2017-01-01') AND (DATE(o.order_approved_at)='2018-08-31');

SELECT 
COUNT(o.order_id) 
FROM orders o 
WHERE DATE(o.order_approved_at)>'2017-01-01' AND DATE(o.order_approved_at)<'2018-08-31'



-- 8. Quantos produtos estão cadastrados nas categorias: perfumaria, brinquedos, esporte lazer e cama mesa,
--    que possuem entre 5 e 10 fotos, um peso que não está entre 1 e 5 g, um altura maior que 10 cm, uma 
--    largura maior que 20 cm. Mostra somente as linhas com mais de 10 produtos únicos.
SELECT
product_category_name ,
COUNT( DISTINCT product_id ) AS produtos_unicos
FROM products p
WHERE product_category_name IN ( 'perfumaria', 'brinquedos', 'esporte_lazer', 'cama_mesa_banho')
AND product_photos_qty BETWEEN 5 AND 10
AND product_weight_g NOT BETWEEN 1 AND 5
AND product_height_cm > 10
AND product_width_cm > 20
GROUP BY product_category_name
HAVING COUNT( DISTINCT product_id ) > 10


-- 9. Quantos produtos estão cadastrados em qualquer categorias que comece com a letra “a” e 
--    termine com a letra “o” e que possuem mais de 5 fotos?
SELECT
product_category_name,
COUNT( DISTINCT product_id ) AS produto
FROM products p
WHERE product_category_name LIKE 'a%o'
AND product_photos_qty > 5
GROUP BY product_category_name;




