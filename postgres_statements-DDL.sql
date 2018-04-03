DROP TABLE rooms;
DROP TABLE employees;
DROP TABLE reservations;

CREATE  TABLE rooms (
  id SERIAL,
  name TEXT NOT NULL,
  capacity INTEGER,
  PRIMARY KEY(id)
);

CREATE  TABLE employees (
 id SERIAL PRIMARY KEY,
 name TEXT NOT NULL,
 experience FLOAT
);


CREATE TABLE reservations (
  id SERIAL PRIMARY KEY ,
  employee_id INTEGER NOT NULL REFERENCES employees(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  room_id INTEGER NOT NULL,
  reservation_date DATE NULL,
  FOREIGN KEY(room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- This will fail due tu fk constraints
INSERT INTO reservations(employee_id, room_id, reservation_date) VALUES (2, 3, current_date);

INSERT INTO employees(name,experience) VALUES
  ('McGerraghty Karissa', 3.9),
  ('Nassey Winston', 2.1),
  ('Gannan Haleigh', 1.2),
  ('Bryant Roman', 2.5),
  ('Rameaux Rakel', 1.2),
  ('Kermannes Belita', 1.7),
  ('Stirtle Edward', 2.2);

INSERT INTO rooms(id,name,capacity) VALUES
  (1,'Toughjoyfax', 300),
  (2,'Lotstring', 150),
  (3,'Redhold', 80),
  (4,'Konklux', 60),
  (5,'Stim', 50);
  
INSERT INTO reservations(employee_id,room_id,reservation_date) VALUES
  (1,2,'2017-08-14'),
  (1,3,'2018-02-25'),
  (2,1,'2017-03-19'),
  (2,5,'2018-04-12'),
  (3,1,'2017-05-14'),
  (3,4,'2016-06-23'),
  (4,3,'2017-06-26'),
  (4,4,'2018-07-15'),
  (5,1,'2017-08-31'),
  (5,1,'2018-06-28');

SELECT * FROM reservations;