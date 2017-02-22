(ns db.migrations.20170222162936-create-users
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/migrations/20170222162936_create_users.sql")

(defn up
  "Migrates the database up to version 20170222162936."
  []
  (println "db.migrations.20170222162936-create-users up...")
  (create-users-table! {} (use-connection)))

(defn down
  "Migrates the database down from version 20170222162936."
  []
  (println "db.migrations.20170222162936-create-users down...")
  (drop-users-table! {} (use-connection)))
