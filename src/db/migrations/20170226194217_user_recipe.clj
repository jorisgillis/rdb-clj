(ns db.migrations.20170226194217-user-recipe
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/migrations/20170226194217-user-recipe.sql")

(defn up
  "Migrates the database up to version 20170226194217."
  []
  (println "db.migrations.20170226194217-user-recipe up...")
  (add-user-recipe! {} (use-connection)))

(defn down
  "Migrates the database down from version 20170226194217."
  []
  (println "db.migrations.20170226194217-user-recipe down..."))