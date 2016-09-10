--name: select-recipes
SELECT *
  FROM recipe

--name: select-recipe-by-id
SELECT id, name, description
  FROM recipe
 WHERE id = :id

--name: create-recipe<!
INSERT INTO recipe (name, description) VALUES (:name, :description)

--name: update-recipe<!
UPDATE recipe 
   SET name = :name, 
       description = :description
 WHERE id = :id

--name: delete-recipe!
DELETE FROM recipe
WHERE id = :id
