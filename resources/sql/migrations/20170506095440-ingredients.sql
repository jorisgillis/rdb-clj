--name: create-ingredients!
CREATE TABLE ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT
);

--name: create-recipe-ingredient!
CREATE TABLE recipeIngredient (
    recipeId INTEGER REFERENCES recipe(id) ON DELETE CASCADE,
    ingredientId INTEGER REFERENCES ingredient(id) ON DELETE CASCADE,
    amount FLOAT NOT NULL,
    unit VARCHAR(64) NOT NULL
);

--name: drop-ingredients!
DROP TABLE ingredients;

--name: drop-recipe-ingredient!
DROP TABLE recipeIngredient;