--name: fetch-user
SELECT * FROM users WHERE name=:name

--name: create-user!
INSERT INTO users (id, name, fullname, email) VALUES(:id, :name, :fullname, :email)