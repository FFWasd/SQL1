DROP TABLE IF EXISTS type CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS route_equipment CASCADE;

create table type(
	id int not null constraint type_pk primary key,
	name text not null
);

create table equipment(
	id int not null constraint equipment_pk primary key,
	name text not null,
	cost int not null
);

create table route(
	id int not null constraint route_pk primary key,
	name text not null,
	difficulty int not null,
	type_id int constraint fk_route_type references type on update cascade on delete cascade
);

create table route_equipment(
	route_id int not null constraint fk_re_route references route on update cascade on delete cascade,
	equipment_id int not null constraint fk_re_equipment references equipment on update cascade on delete cascade,
	count int not null,
	constraint route_equipment_pk primary key (route_id, equipment_id)
);

insert into type(id, name) values (1, 'Пеший'), (2, 'Велосипедный'), (3, 'Лыжный'), (4, 'Горный'), (5, 'Водный'), (6, 'Конный');

insert into equipment(id, name, cost) values (1, 'Палатка', 5000), (2, 'Лыжи', 2500), (3, 'Лыжные палки', 1500), (4,'Велосипед', 30000), (5, 'Велосипедный шлем', 500), (6, 'Каяк', 15000), (7, 'Весло',2000), (8, 'Фонарь', 750), (9, 'Велофонарь', 500), (10, 'Перчатки', 200);

insert into route(id, name, difficulty, type_id) values (1, 'Горная тропа', 3, 4), (2, 'Велопрогулка по парку', 2, 2), (3, 'Лесная тропа', 1, 1), (4, 'Крутой склон', 3, 3), (5, 'Сплав', 3, 5), (6, 'Велопрогулка №2', 4,1), (7,'Скайдайвинг', 4, NULL);

insert into route_equipment(route_id, equipment_id, count) values (1, 1, 1), (2,4,1), (2,5,1), (2, 9, 1), (2,10,1), (3, 1, 1), (4,2,1), (4,3,1), (5, 6,1), (5,7,1);

SELECT name FROM route WHERE difficulty BETWEEN 2 AND 4;

SELECT 
    t.name AS type_name,
    r.name AS route_name,
    r.difficulty
FROM route r
JOIN type t ON r.type_id = t.id
ORDER BY t.name ASC, r.difficulty ASC;

SELECT name FROM equipment WHERE name ILIKE '%фонарь%';

SELECT name FROM route WHERE name ~ '[0-9]$';

SELECT 
    difficulty, 
    COUNT(*) AS route_count
FROM route
GROUP BY difficulty
ORDER BY difficulty ASC;

SELECT t.name
FROM type t
LEFT JOIN route r ON t.id = r.type_id
WHERE r.id IS NULL;

SELECT name FROM equipment WHERE cost = (SELECT MIN(cost) FROM equipment);

SELECT 
    r.name AS route_name,
    t.name AS type_name
FROM route r
INNER JOIN type t ON r.type_id = t.id;

SELECT 
    t.name AS type_name, 
    MAX(r.difficulty) AS max_difficulty
FROM type t
LEFT JOIN route r ON t.id = r.type_id
GROUP BY t.id, t.name
ORDER BY max_difficulty DESC;

SELECT 
    r.name AS route_name,
    COUNT(DISTINCT re.equipment_id) AS unique_equipment_count
FROM route r
LEFT JOIN route_equipment re ON r.id = re.route_id
GROUP BY r.id, r.name
ORDER BY unique_equipment_count DESC;

SELECT 
    e.name AS equipment_name,
    COUNT(re.route_id) AS route_count
FROM equipment e
LEFT JOIN route_equipment re ON e.id = re.equipment_id
GROUP BY e.id, e.name
ORDER BY route_count DESC, equipment_name ASC;

SELECT 
    r.name AS route_name
FROM route r
JOIN route_equipment re ON r.id = re.route_id
GROUP BY r.id, r.name
HAVING COUNT(DISTINCT re.equipment_id) > 3;

UPDATE equipment SET cost = cost - 10 WHERE cost > 100;

UPDATE equipment
SET cost = cost * 2
WHERE id IN (
    SELECT DISTINCT re.equipment_id
    FROM route_equipment re
    JOIN route r ON re.route_id = r.id
    JOIN type t ON r.type_id = t.id
    WHERE t.name = 'Горный'
);

DELETE FROM route_equipment
WHERE route_id IN (
    SELECT id 
    FROM route 
    WHERE difficulty = 1
);


DELETE FROM route_equipment
WHERE equipment_id IN (
    SELECT id 
    FROM equipment 
    WHERE cost < (SELECT AVG(cost) FROM equipment)
);

