CREATE TABLE cities (
  id SERIAL NOT NULL PRIMARY KEY,
  name TEXT
);

CREATE TABLE flights (
  id SERIAL NOT NULL PRIMARY KEY,
  from_city INTEGER REFERENCES cities(id),
  to_city  INTEGER REFERENCES cities(id)
);


INSERT INTO cities(name) VALUES
('Vienna'),
('Paris'),
('Boston'),
('New York'),
('Tokyo'),
('Dubai'),
('Sydney'),
('Singapore'),
('London'),
('San Francisco'),
('Los Angeles');

INSERT INTO flights(from_city, to_city) VALUES
(1,2),
(2,3),
(2,4),
(7,5),
(7,11),
(7,10),
(5,8),
(8,7),
(1,9),
(3,4),
(1,6);

INSERT INTO flights(from_city, to_city) VALUES
(4,2);

WITH RECURSIVE connections(from_city, to_city, stops, via) AS (
  SELECT from_city, to_city, 0, '' FROM flights
  UNION ALL
  SELECT conns.from_city, fl.to_city, conns.stops + 1, conns.via || '==>' || cfr.name || '==>'
  FROM connections conns
  JOIN flights fl ON conns.to_city = fl.from_city
  JOIN cities cfr ON cfr.id = fl.from_city
  WHERE conns.from_city != fl.to_city AND conns.stops < 4
) SELECT from_c.name, via , to_c.name, stops FROM connections c
JOIN cities from_c ON from_c.id = c.from_city
JOIN cities to_c ON to_c.id = c.to_city
WHERE from_c.name = 'Vienna';



WITH RECURSIVE connections(from_city, to_city, stops, via) AS (
  SELECT from_city, to_city, 0, ARRAY[]::text[] FROM flights
  UNION ALL
  SELECT conns.from_city, fl.to_city, conns.stops + 1, array_append(conns.via, cfr.name)
  FROM connections conns
  JOIN flights fl ON conns.to_city = fl.from_city
  JOIN cities cfr ON cfr.id = fl.from_city
  WHERE conns.from_city != fl.to_city AND conns.stops < 4 AND NOT(ARRAY[cfr.name]::text[] <@ via)
) SELECT from_c.name, via , to_c.name, stops FROM connections c
JOIN cities from_c ON from_c.id = c.from_city
JOIN cities to_c ON to_c.id = c.to_city
WHERE from_c.name = 'Vienna';
