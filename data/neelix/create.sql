BEGIN TRANSACTION;
CREATE TABLE foods (
  id INTEGER NOT NULL PRIMARY KEY,
  name varchar(80)
);
CREATE TABLE foods_measures (
  food_id INTEGER NOT NULL,
  measure_id INTEGER NOT NULL,
  grams float,
  ccs float
);
CREATE TABLE ingredients (
  id INTEGER NOT NULL PRIMARY KEY,
  recipe_id INTEGER,
  measure_id INTEGER NOT NULL,
  food_id INTEGER NOT NULL,
  quantity float,
  modifier varchar(80),
  position INTEGER
);
CREATE TABLE measures (
  id INTEGER NOT NULL PRIMARY KEY,
  name varchar(80)
);
CREATE TABLE recipes (
  id INTEGER NOT NULL PRIMARY KEY,
  name varchar(80),
  author varchar(80),
  serves varchar(80),
  yields varchar(80),
  preptime varchar(80),
  tottime varchar(80),
  temp varchar(80),
  directions text,
  notes text
);
create table categories (
  id integer primary key,
  name varchar
);
create table categories_recipes (
  category_id integer,
  recipe_id integer
);
COMMIT;
