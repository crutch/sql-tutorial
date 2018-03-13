-- https://en.wikipedia.org/wiki/Nested_set_model

DROP TABLE products;

CREATE TABLE products(
id SERIAL PRIMARY KEY,
label VARCHAR(30),
lft INTEGER,
rgt INTEGER,
parent_id INTEGER
);

INSERT INTO products(id,label, lft,rgt,parent_id) VALUES
(1,'Clothing',1,22,NULL),
(2,'Men''s',2,9,1),
(3,'Women''s',10,21,1),
(4,'Suits',3,8,2),
(5,'Slacks',4,5,4),
(6,'Jackets',6,7,4),
(7,'Dresses',11,16,3),
(8,'Skirts',17,18,3),
(9,'Blouses',19,20,3),
(10,'Evening Gowns',12,13,7),
(11,'Sun Dresses',14,15,7)


SELECT * FROM products WHERE
lft > 10 AND rgt < 21;

-- https://www.postgresql.org/docs/current/static/queries-with.html
WITH RECURSIVE products_tree AS (
   SELECT id, label, parent_id
   FROM products
   where id = 3
   UNION ALL
   SELECT p.id, p.label, p.parent_id 
   FROM products p
   JOIN products_tree pt ON p.parent_id = pt.id
   )
   SELECT * FROM products_tree;


   
