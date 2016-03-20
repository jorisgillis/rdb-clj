-- name: select-current-version
SELECT version 
  FROM migration_schema

-- name: update-current-version!
UPDATE migration_schema 
   SET version = :next
