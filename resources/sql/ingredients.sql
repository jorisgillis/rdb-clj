--name: select-ingredients-for-recipe
SELECT ri.amount, ri.unit, i.id, i.name, i.description
  FROM recipeIngredient ri
  JOIN ingredients i ON (ri.ingredientId=i.id)
 WHERE ri.recipeId = :recipeId

--name: fetch-recipe-ingredient-link
SELECT *
  FROM recipeIngredient
 WHERE recipeId = :recipeId AND ingredientId = :ingredientId

--name: create-link!
INSERT INTO recipeIngredient (recipeId, ingredientId, amount, unit)
VALUES (:recipeId, :ingredientId, :amount, :unit)

--name: update-link!
UPDATE recipeIngredient
   SET amount = :amount, unit = :unit
 WHERE recipeId = :recipeId AND ingredientId = :ingredientId

--name: fetch-all-ingredients
SELECT id, name, description
  FROM ingredients

--name: fetch-ingredient-by-id
SELECT id, name, description
  FROM ingredients
 WHERE id = :id

--name: delete-ingredient-by-id!
DELETE FROM ingredients
 WHERE id = :id

--name: insert-ingredient<!
INSERT INTO ingredients (name, description)
     VALUES (:name, :description)

--name: update-ingredient!
UPDATE ingredients
   SET name = :name, description = :description
 WHERE id = :id
