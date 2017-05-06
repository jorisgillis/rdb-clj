(ns db.migrations.20170506095440-ingredients
  (:require [rdb.util.db :refer [with-db-transaction use-connection]]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/migrations/20170506095440-ingredients.sql")

(defn up []
  (println "db.migrations.20170506095440-ingredients up...")
  (with-db-transaction
    (fn [connection]
      (create-ingredients! {} (use-connection connection))
      (create-recipe-ingredient! {} (use-connection connection)))))

(defn down []
  (println "db.migrations.20170506095440-ingredients down...")
  (with-db-transaction
    (fn [connection]
      (drop-recipe-ingredient! {} (use-connection connection))
      (drop-ingredients! {} (use-connection connection)))))
