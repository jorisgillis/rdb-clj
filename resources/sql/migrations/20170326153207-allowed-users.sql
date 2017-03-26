--name: create-allowed-users!
CREATE TABLE allowedusers (
    email VARCHAR(512) NOT NULL UNIQUE
);

--name: drop-allowed-users!
DROP TABLE allowedusers;