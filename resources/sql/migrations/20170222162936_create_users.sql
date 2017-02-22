--name: create-users-table!
CREATE TABLE users (
    id VARCHAR(75) PRIMARY KEY,
    name VARCHAR(255),
    fullname VARCHAR(255),
    email VARCHAR(512)
);

--name: drop-users-table!
DROP TABLE users;