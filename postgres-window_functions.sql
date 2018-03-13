-- window functions & GROUPING SETS
-- https://www.postgresql.org/docs/devel/static/queries-table-expressions.html#QUERIES-GROUPING-SETS
-- https://www.postgresql.org/docs/current/static/tutorial-window.html
-- https://www.postgresql.org/docs/current/static/functions-window.html

CREATE SCHEMA scores;
SET SEARCH_PATH TO 'scores';

create table scores (
	id INT,
	name VARCHAR(50),
	score INT
);

insert into scores (id, name, score) values
  (1, 'Sara Alvarez', 62),
  (2, 'Laura Ryan', 63),
  (3, 'Clarence Mcdonald', 76),
  (4, 'Gary Gardner', 71),
  (5, 'Aaron Williamson', 61),
  (6, 'Roger Martin', 60),
  (7, 'William Peterson', 62),
  (8, 'Beverly Hamilton', 57),
  (9, 'Ashley Watkins', 58),
  (10, 'Eugene Gardner', 69);


-- I want to rank students according to their score
-- first without window function
SELECT s1.name,
  s1.score as score,
  (SELECT count(DISTINCT s2.score) FROM scores s2 WHERE s2.score >= s1.score) AS rank
FROM scores s1 
ORDER BY 2, 1

-- with window functions
SELECT s.name, s.score, DENSE_RANK() OVER (ORDER BY s.score DESC)
FROM scores s
ORDER BY 2,1

-- let's try simple RANK
SELECT s.name, s.score, RANK() OVER (ORDER BY s.score DESC)
FROM scores s
ORDER BY 3

CREATE SCHEMA employees;
SET SEARCH_PATH TO 'employees';

CREATE TABLE employees (
	id serial PRIMARY KEY,
	name varchar(50),
  gender char,
	salary bigint,
	department_id bigint
);

CREATE TABLE departments (
id serial PRIMARY KEY,
name varchar(30)
);

INSERT INTO departments(name) VALUES
('IT'),
('Sales'),
('Marketing');

INSERT INTO employees(name, gender, salary, department_id) values
('Jimmy Gonzalez', 'M', 782,1),
('Peter Anderson', 'M', 750,1),
('Justin Bennett', 'M', 728,1),
('Brandon Little', 'M', 728,1),
('Donna Andrews', 'F', 715,1),
('Jerry Harper', 'M', 612,2),
('Judy Fox', 'F', 707,2),
('Paula Murphy', 'F', 759,2),
('Rachel Murphy', 'F', 719,2),
('Joshua Smith', 'M', 750, 3),
('Nancy Mason', 'F', 783, 3);

SELECT d.name, e.gender, avg(salary)
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY GROUPING SETS ((d.name), (d.name, e.gender), ());

SELECT d.name, e.gender, avg(salary)
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY ROLLUP (d.name, e.gender);


SELECT d.name, e.gender, avg(salary)
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY GROUPING SETS ((d.name), (e.gender), (d.name, e.gender), ());


SELECT d.name, e.gender, avg(salary)
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY CUBE (d.name, e.gender);



-- I want top three salaries for each department
-- first without window functions, omg, that's awful
SELECT d.name as department, e3.name as employee, e3.salary
FROM employees e3
JOIN (
       SELECT DISTINCT e.department_id, e.salary
       FROM employees e
       WHERE (
               SELECT COUNT(*)
               FROM (SELECT DISTINCT department_id, salary FROM employees) e2
               WHERE e2.department_id = e.department_id AND e2.salary > e.salary
             ) < 3
     ) tmp ON tmp.department_id = e3.department_id AND tmp.salary = e3.salary
JOIN departments d ON e3.department_id = d.id
ORDER BY 1, 3 DESC, 2 ASC

-- now with window functions
SELECT tmp.name wfdepartment, tmp.empl wfemployee, tmp.salary wfsalary
FROM (
	SELECT d.name, e.name empl, e.salary, DENSE_RANK() OVER (PARTITION BY d.id ORDER BY e.salary DESC) as rank
	FROM departments d
	JOIN employees e ON e.department_id = d.id
) tmp
WHERE rank <= 3
ORDER BY 1,3 DESC, 2 ASC;


CREATE SCHEMA window_functions;
SET SEARCH_PATH TO 'window_functions';

SELECT * FROM generate_series(1,3);

-- just to better understand what order by does
select x, array_agg(x) over ()
    from generate_series(1, 3) as t(x);

select x, array_agg(x) over (order by x)
    from generate_series(1, 3) as t(x);

-- default frame
select x,
       array_agg(x) over (order by x
                            rows between unbounded preceding
                                     and current row)
    from generate_series(1, 3) as t(x);

-- look forward
select x,
	array_agg(x) over (rows between current row
                                     and unbounded following)
    from generate_series(1, 3) as t(x);

-- whole partition
select x,
	array_agg(x) over (rows between unbounded preceding
                                     and unbounded following)
    from generate_series(1, 3) as t(x);

-- use case: sum column and current row ration in a single query
select x,
         array_agg(x) over () as frame,
         sum(x) over () as sum,
         x::float/sum(x) over () as part
    from generate_series(1, 3) as t(x);

-- running total
select x,
         array_agg(x) over () as frame,
         sum(x) over (order by x) as sum,
         x::float/sum(x) over () as part
    from generate_series(1, 3) as t(x);

DROP TABLE p;
CREATE TABLE p as
     select a.date::date as date,
            1 + floor(b.x * random()) as x
       from generate_series(date 'yesterday', date 'tomorrow', '1 day') as a(date),
            generate_series(1, 3) as b(x);

SELECT * FROM p;

 SELECT date, x,
    count(x) over (partition by date, x),
    array_agg(x) over(partition by date, x),
    count(x) over (partition by date),
    array_agg(x) over(partition by date)
 FROM p;

-- dalsie window functions
 select x,
         row_number() over(),
         ntile(4) over w,
         lag(x, 2) over w,
         lead(x, 1) over w
    from generate_series(1, 15, 2) as t(x)
  window w as (order by x);