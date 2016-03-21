--name: select-recipes
SELECT *
  FROM recipe

--name: select-recipe-by-id
SELECT id, name, description
  FROM recipe
 WHERE id = :id

--name: create-recipe!
INSERT INTO recipe (name, description) VALUES (:name, :description)
