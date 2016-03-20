-- name: create-migration-schema
CREATE TABLE migration_schema (
       version INTEGER
)

-- name: init-schema
INSERT INTO migration_schema (version) VALUES (0)

-- name: select-current-version
SELECT version FROM migration_schema

-- name: update-current-version
UPDATE migration_schema SET version = :new-version
