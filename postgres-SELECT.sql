-- SQL
-- syntax
-- SELECT A1, A2, ...
-- [FROM T1]
-- [JOIN T2 ON cond]
-- [WHERE cond]
-- [ORDER BY col [{ASC|DESC}], ...col]
-- [LIMIT n]
-- ---------------------------------
-- explicit JOIN vs multiple tables in FROM clause


-- Completely joined
-- and let's try various ways how to sort the result set, ascending, descending, using several fields
-- what are the e, ro, r? Why are they there?
-- ---------------------------------
SELECT e.name, e.experience, ro.name, r.reservation_date
FROM employees e
JOIN reservations r ON e.id = r.employee_id
JOIN rooms ro ON r.room_id = ro.id
ORDER BY experience DESC, e.name ASC;

SELECT e.name, e.experience, ro.name, r.reservation_date
FROM employees e, rooms ro, reservations r
WHERE e.id = r.employee_id AND ro.id = r.room_id

-- ---------------------------------
-- We want all the employees having the same xp
-- the problem is that we got the combination with self and duplicities
-- let's try to add a WHERE clause to solve it
-- ---------------------------------
EXPLAIN SELECT e1.id,e1.name, e1.experience, e2.id,e2.name,e2.experience
FROM employees e1
JOIN employees e2 ON e1.experience = e2.experience AND e1.id < e2.id;

EXPLAIN SELECT e1.id,e1.name, e1.experience, e2.id,e2.name,e2.experience
FROM employees e1
JOIN employees e2 ON e1.experience = e2.experience
WHERE e1.id < e2.id;


-- ---------------------------------
-- We can use SET operations, such as UNION, INTERSECT, ...
-- UNION returns distinct values (like a true set operation), UNION ALL does not
-- we want all names (employees, rooms) in a single table
-- what is the name of the column in the result?
-- ---------------------------------
SELECT name AS label FROM employees
UNION ALL
SELECT name FROM rooms
ORDER BY label;
-- ---------------------------------
-- INTERESECT (not really required, as we have JOIN)
-- we want ids of those employees who reserved room 2 and 3
-- ---------------------------------
SELECT employee_id FROM reservations WHERE room_id = 2
INTERSECT
SELECT employee_id FROM reservations WHERE room_id = 3
-- ---------------------------------
-- the same thing through JOIN
-- we want employees who reserved rooms 2 and 3
-- ---------------------------------
SELECT r1.employee_id
FROM reservations r1
JOIN reservations r2 ON r1.employee_id = r2.employee_id
WHERE r1.room_id = 2 AND r2.room_id = 3;
-- ---------------------------------
-- another way, using subselect and `IN`
-- ---------------------------------
SELECT r1.employee_id
FROM reservations r1
WHERE r1.room_id = 2 AND employee_id IN
(SELECT r2.employee_id FROM reservations r2 where r2.room_id = 3);
-- ---------------------------------
-- MINUS (EXCEPT)
-- we want those who reserved 1 and did not reserved 4
-- ---------------------------------
SELECT employee_id FROM reservations WHERE room_id = 1
EXCEPT
SELECT employee_id FROM reservations WHERE room_id = 4;
-- ---------------------------------
-- Another way how to achieve the same thing, using NOT IN
-- ---------------------------------
SELECT DISTINCT r1.employee_id
FROM reservations r1
WHERE r1.room_id = 1
AND r1.employee_id NOT IN
(SELECT r1.employee_id
FROM reservations r1
WHERE r1.room_id = 4);
-- ---------------------------------
-- All employees, who reserved 1, using JOIN
-- ---------------------------------
SELECT avg(DISTINCT e.experience) FROM employees e
JOIN reservations r ON r.employee_id = e.id
WHERE r.room_id = 1;
-- ---------------------------------
-- the same using subselect
-- ---------------------------------
SELECT avg(e.experience) FROM employees e
WHERE e.id IN
(SELECT employee_id FROM reservations WHERE room_id = 1);
-- ---------------------------------
-- The first one (using JOIN) might be a problem, because it is returning rows from reservations,
-- therefore, we can have one employee present multiple times within the results
-- in this particular case, we can use `distinct` to solve it, but what if we requrie experience instead of id...?
-- ===============================================================================
-- ---------------------------------
-- NOT EXISTS, ALL, ANY
-- ---------------------------------
-- max xp through subquery (try MIN as well)
-- ---------------------------------
SELECT * FROM employees
WHERE experience = (SELECT max(experience) FROM employees)

SELECT s1.id,s1.name,s1.experience
FROM employees s1
WHERE NOT EXISTS (SELECT * FROM employees s2 WHERE s1.experience < s2.experience);
-- ---------------------------------
-- The same can be accomplished by two other means
-- why there is an equal sign? Try to put it away
-- ---------------------------------
SELECT * FROM employees s1
where s1.experience >= ALL (SELECT experience FROM employees s2);
-- ---------------------------------
SELECT * FROM employees s1
where NOT s1.experience < ANY (SELECT experience FROM employees s2);
-- ---------------------------------

-- Toy example. I want to adjust the column and filter by it
SELECT *, experience * 2 as double_xp FROM employees
WHERE experience * 2 > 5

SELECT *, experience * 2 as double_xp FROM employees
WHERE experience * 2 > 5
ORDER BY double_xp DESC

-- subselect in FROM clause
SELECT *
FROM (select id, name, experience * 2 as double_xp
from employees) tmp2
where double_xp > 5;

WITH double_xp_table AS (
	select id, name, experience * 2 as double_xp from employees
)
SELECT * FROM double_xp_table
WHERE double_xp > 5;


SELECT '1'

-- subselect in attributes (just to show that it works, must be a single value though)
SELECT r.name, r.capacity, '1' as my_column FROM rooms r;

-- all rooms and the highest xp for each of them (show subselect)
SELECT ro.name,
(SELECT DISTINCT experience
	FROM employees e
	JOIN reservations r ON e.id = r.employee_id
	WHERE r.room_id = ro.id
	AND experience >= ALL (SELECT e.experience FROM employees e
				JOIN reservations r ON e.id = r.employee_id
				WHERE r.room_id = ro.id)
) as xp
FROM rooms ro;


SELECT ro.name,
(SELECT max(experience)
	FROM employees e
	JOIN reservations r ON e.id = r.employee_id
	WHERE r.room_id = ro.id
) as xp
FROM rooms ro;

-- if I was to retrieve name instead of xp, I would fail (it returns more rows)
SELECT ro.name,
(SELECT DISTINCT e.name
	FROM employees e
	JOIN reservations r ON e.id = r.employee_id
	WHERE r.room_id = ro.id
) as name
FROM rooms ro;

-- Aggregations
-- SELECT A1,...,An, left(name, 12) COUNT, MAX, MIN, AVG, SUM
-- FROM T1
-- [JOIN T2, JOIN T3...]
-- [WHERE cond]
-- [GROUP BY attrs]
-- [HAVING cond2]

-- average of all employees
SELECT avg(experience) as average FROM employees;

-- average of all employess, who reserved 'Toughjoyfax'
SELECT avg(experience)
FROM employees e
JOIN reservations r ON r.employee_id = e.id
JOIN rooms ro ON ro.id = r.room_id
WHERE ro.name LIKE 'Toughjoyfax';



-- Is it really ok? Watch out for duplicate rows, JOIN can give me an employee several times
-- so once again
SELECT avg(experience)
FROM employees e
where e.id IN
(SELECT r.employee_id
	FROM reservations r
	JOIN rooms ro ON ro.id = r.room_id
	WHERE ro.name LIKE 'Toughjoyfax');

-- number of rooms where capacity is greater than
SELECT count(*)
FROM rooms r
WHERE capacity > 90;

SELECT * FROM rooms;

-- number of reservations for Toughjoyfax
SELECT count(*)
FROM reservations r
JOIN rooms ro ON ro.id = r.room_id
WHERE ro.name LIKE 'Toughjoyfax';

SELECT *
FROM reservations r
JOIN rooms ro ON ro.id = r.room_id
WHERE ro.name LIKE 'Toughjoyfax';

-- number of people, who reserved Toughjoyfax
-- notice the distinct
SELECT count(distinct employee_id)
FROM reservations r
JOIN rooms ro ON ro.id = r.room_id
WHERE ro.name LIKE 'Toughjoyfax';

-- GROUP BY
SELECT employee_id, count(*) count
FROM reservations
GROUP BY employee_id;

SELECT *
FROM reservations
ORDER BY employee_id;


SELECT * FROM rooms;
-- let's add location to rooms

ALTER TABLE rooms
ADD COLUMN location VARCHAR(50) DEFAULT 'A1'

UPDATE rooms
SET location = 'B1' WHERE id IN (4,5)

-- if we want to see&tune what GROUP BY would do, let's simulate it via ORDER BY
SELECT * FROM rooms ORDER BY location;

-- we want total capacity of individual locations
SELECT location, sum(capacity)
FROM rooms
GROUP BY location;

SELECT * FROM reservations
ORDER BY employee_id, room_id
-- who reserved what, how many times

SELECT employee_id, room_id, count(*)
FROM reservations
GROUP BY employee_id, room_id;

-- can I ask for another attribute that the one I am grouping by
-- what would be its value?

SELECT r.employee_id, e.name, count(*)
FROM reservations r
JOIN employees e ON r.employee_id = e.id
GROUP BY r.employee_id, e.name


-- at least if we group by something, which is known as primary key to postgres

SELECT e.id, e.name, count(*)
FROM reservations r
JOIN employees e ON e.id = r.employee_id
GROUP BY e.id

-- a quick check
SELECT r.employee_id, e.name
FROM reservations r
JOIN employees e ON r.employee_id = e.id
ORDER BY employee_id

-- we want also the employees who did not reserve any room ever
-- using union...
SELECT e.name, count(distinct room_id) as pocet
FROM reservations r
JOIN employees e ON r.employee_id = e.id
GROUP BY employee_id, e.name
UNION
SELECT name, 0 as kount FROM employees WHERE id NOT IN (SELECT employee_id FROM reservations);

-- better solution, using LEFT JOIN
-- http://blog.codinghorror.com/a-visual-explanation-of-sql-joins/

SELECT *
FROM employees e
LEFT JOIN reservations r ON r.employee_id = e.id
ORDER BY e.id;

SELECT e.name, COUNT(room_id)
FROM employees e
LEFT JOIN reservations r ON e.id = r.employee_id
GROUP BY e.id;


-- we want those locations, where we have more than two rooms
-- HAVING allows us to filter groups, which GROUP BY formed
SELECT location, sum(capacity)
FROM rooms
GROUP BY location
HAVING count(*) > 2;

SELECT location, sum(capacity)
FROM rooms
GROUP BY location;

SELECT * FROM rooms;


-- toy example to show, that we can use complex conditions in HAVING
SELECT location
FROM rooms
GROUP BY location
HAVING max(capacity) < (SELECT avg(capacity) FROM rooms);

-- a bit more of syntax
-- DELETE FROM table [WHERE cond]

-- UPDATE table
-- SET attr1 = val1, attr2 = val2
-- [WHERE cond]

-- let's create a record for those, who did not reserve anything yet
INSERT INTO reservations(employee_id, room_id)
	SELECT e.id as employee_id, ro.id as room_id
	FROM employees e, rooms ro
	WHERE e.id NOT IN (SELECT employee_id FROM reservations)
	AND ro.name LIKE 'Toughjoyfax';

SELECT * FROM reservations;

-- delete reservations to employees 6 and 7
DELETE FROM reservations where employee_id IN (6,7);


SELECT DISTINCT prog.name
FROM programmers prog
	JOIN projects_programmers proj_progs ON proj_progs.programmer_id = prog.id
	JOIN projects proj ON proj.id = proj_progs.project_id
	JOIN languages l ON proj.language_id = l.id
WHERE l.label = 'python' AND prog.id IN (SELECT programmer_id FROM
projects_programmers proj_progs WHERE owner IS TRUE);