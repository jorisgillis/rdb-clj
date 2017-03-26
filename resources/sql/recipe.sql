--name: select-recipes
SELECT r.*, u.name AS username
  FROM recipe AS r
  JOIN users AS u ON (r.userid=u.id)

--name: select-recipe-by-id
SELECT r.id, r.name, r.description, u.name AS username
  FROM recipe AS r
  JOIN users AS u ON (r.userid=u.id)
 WHERE r.id = :id

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
