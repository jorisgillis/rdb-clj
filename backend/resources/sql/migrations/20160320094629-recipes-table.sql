--name: create-recipes-table!
CREATE TABLE recipe (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL
)

--name: drop-recipes-table!
DROP TABLE recipe;
