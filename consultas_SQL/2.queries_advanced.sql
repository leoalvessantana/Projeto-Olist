-- 1. Gerar uma tabela de dados com 50 linhas, contendo o id do pedido, o estado e a cidade do cliente, o status
-- do pedido, o id do produto e o preço do produto, somente para clientes do estado de Minas Gerais, 
-- que tenham os pedidos aprovadas a partir do dia 01 de Janeiro de 2017.
SELECT
o.order_id ,
c.customer_state ,
c.customer_city,
o.order_status ,
oi.product_id,
oi.price,
o.order_approved_at
FROM orders o INNER JOIN order_items oi ON ( oi.order_id = o.order_id )
			  INNER JOIN customer c ON ( c.customer_id = o.customer_id )
WHERE c.customer_state = 'MG' AND o.order_approved_at > '2017-01-01 00:00:00'
LIMIT 50;


-- 2. Gerar uma tabela de dados com 50 linhas, contendo o id do pedido, o estado e a cidade do cliente, o status do
-- 	  pedido, o nome da categoria do produto e o preço do produto, somente para pedidos com o status igual a cancelado.
SELECT
o.order_id ,
c.customer_state ,
c.customer_city,
o.order_status ,
p.product_category_name ,
oi.price
FROM orders o INNER JOIN order_items oi ON ( oi.order_id = o.order_id )
			  INNER JOIN customer c ON ( c.customer_id = o.customer_id )
 			  INNER JOIN products p ON ( p.product_id = oi.product_id )
WHERE o.order_status = 'canceled'
LIMIT 50;


-- 3. Gerar uma tabela de dados com 10 linhas, contendo o id do pedido, o estado e a cidade do cliente, o status do pedido,
-- 	  o nome da categoria do produto, o preço do produto, a cidade e o estado do vendedor, a data de aprovação do
-- 	  pedido e o tipo de pagamento, somente para o tipo de pagamento igual a boleto.
SELECT
o.order_id,
c.customer_state,
c.customer_city,
o.order_status,
p.product_category_name,
oi.price,
s.seller_city,
s.seller_state,
o.order_approved_at,
op.payment_type
FROM orders o INNER JOIN order_items oi ON ( oi.order_id = o.order_id )
			  INNER JOIN customer c ON ( c.customer_id = o.customer_id )
 			  INNER JOIN products p ON ( p.product_id = oi.product_id )
			  INNER JOIN sellers s ON ( s.seller_id = oi.seller_id )
			  INNER JOIN order_payments op ON ( op.order_id = o.order_id )
WHERE op.payment_type = 'boleto'
LIMIT 10;


-- 4. Gerar uma tabela de dados com 70 linhas, contendo o id do pedido, o estado e a cidade do cliente, o status do pedido,
-- 	  o nome da categoria do produto, o preço do produto, a cidade e o estado do vendedor, a data de aprovação do
-- 	  pedido, tipo de pagamento e a nota de avaliação do produto, somente para os pedidos com a nota de avaliação do
-- 	  produto igual a 1.
SELECT
o.order_id ,
c.customer_state ,
c.customer_city,
o.order_status ,
p.product_category_name ,
oi.price,
s.seller_city,
s.seller_state,
o.order_approved_at,
op.payment_type ,
or2.review_score
FROM orders o INNER JOIN order_items oi ON ( oi.order_id = o.order_id )
			  INNER JOIN customer c ON ( c.customer_id = o.customer_id )
			  INNER JOIN products p ON ( p.product_id = oi.product_id )
			  INNER JOIN sellers s ON ( s.seller_id = oi.seller_id )
			  INNER JOIN order_payments op ON ( op.order_id = o.order_id )
			  INNER JOIN order_reviews or2 ON ( or2.order_id = o.order_id )
WHERE or2.review_score = 1
LIMIT 70;


-- 5. Qual a cardinalidade entre a tabela Pedidos ( orders ) e Avaliações (reviews )?
SELECT
o.order_id,
COUNT( or2.review_id ) AS review_id
FROM orders o LEFT JOIN order_reviews or2 ON ( or2.order_id = o.order_id )
GROUP BY o.order_id
HAVING COUNT( or2.review_id ) > 1
-- Resposta: A Cardinalidade é 1:N. Pois existe mais de uma avaliação para o mesmo pedido.


-- 6. Quantos pedidos (orders) não tem nenhuma avaliação (review) ?
SELECT
COUNT(o.order_id)
FROM orders o LEFT JOIN order_reviews or2 ON ( or2.order_id = o.order_id )
WHERE or2.order_id IS NULL


-- 7. Quantos pedidos (orders) não possuem nenhum produto (products)?
SELECT
COUNT( o.order_id )
FROM orders o LEFT JOIN order_items oi ON ( oi.order_id = o.order_id )
		      LEFT JOIN products p ON ( p.product_id = oi.product_id )
WHERE p.product_id IS NULL


-- 8. Quais são os top 10 vendedores com mais clientes?
SELECT
s.seller_id,
COUNT( c.customer_id ) AS customer_id
FROM orders o LEFT JOIN order_items oi ON ( oi.order_id = o.order_id )
			  LEFT JOIN sellers s ON ( s.seller_id = oi.seller_id )
			  LEFT JOIN customer c ON ( c.customer_id = o.customer_id)
GROUP BY s.seller_id
ORDER BY customer_id DESC
LIMIT 10;



-- 9. Qual o número de pedido com o tipo de pagamento igual a “boleto”?
SELECT
COUNT( o.order_id ) AS order_id
FROM orders o
WHERE o.order_id IN ( SELECT DISTINCT op.order_id FROM order_payments op WHERE op.payment_type = 'boleto' )



-- 10. Comparar a media de preço de cada categoria com a media geral
SELECT 
p.product_category_name,
(SELECT ROUND(AVG(oi.price), 2) FROM order_items oi) AS avg_price_all,
(SELECT ROUND(AVG(oi.price), 2) FROM order_items oi WHERE oi.product_id  = p.product_id) AS avg_price_category
FROM products p
GROUP BY p.product_category_name;



-- 11. Media dos preços dos produtos que tem tem o status igual a delivered.
SELECT AVG( oi.price ) AS avg_price
FROM order_items oi
WHERE oi.order_id IN ( SELECT o.order_id
			FROM orders o
			WHERE o.order_status = 'delivered' )
-- ou 
SELECT
   AVG( oi.price )
FROM orders o LEFT JOIN order_items oi ON ( oi.order_id = o.order_id )
WHERE o.order_status ='delivered'




-- 12. Cria uma tabela que mostre a média de avaliações por dia, a média de preço por dia, a soma dos preços por dia, 
-- o preço mínimo por dia, o número de pedidos por dia e o número de clientes únicos que compraram no dia.
SELECT
t1.date_,
t1.avg_review,
t2.avg_price,
t2.sum_price,
t2.min_price,
t3.pedido_por_dia,
t3.clientes_unicos
FROM (
	SELECT
	DATE( review_creation_date ) AS date_,
	AVG( review_score ) AS avg_review
	FROM order_reviews or2
	GROUP BY DATE( review_creation_date )
	) AS t1 LEFT JOIN ( 
						SELECT
						DATE( oi.shipping_limit_date ) AS date_,
						AVG( price ) AS avg_price,
						SUM( price ) AS sum_price,
						MIN( price ) AS min_price
						FROM order_items oi
						GROUP BY DATE( oi.shipping_limit_date )
						) AS t2 ON ( t2.date_ = t1.date_)
						LEFT JOIN (
									SELECT
									DATE( o.order_purchase_timestamp ) AS date_,
									COUNT( o.order_id ) AS pedido_por_dia,
									COUNT( DISTINCT o.customer_id ) AS clientes_unicos
									FROM orders o
									GROUP BY DATE( o.order_purchase_timestamp )
									) AS t3 ON ( t3.date_ = t1.date_)















