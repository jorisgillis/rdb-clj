--name: add-user-recipe!
ALTER TABLE recipe ADD COLUMN userid VARCHAR(75) REFERENCES user(id);
