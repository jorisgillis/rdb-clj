(ns db.migrations.20160320094629-recipes-table
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]
            [clojure.java.jdbc :as j]))

(defqueries "sql/migrations/20160320094629-recipes-table.sql")

(defn up
  "Migrates the database up to version 20160320094629."
  []
  (println "migrations.20160320094629-recipes-table up...")
  (create-recipes-table! {} (use-connection)))

(defn down
  "Migrates the database down from version 20160320094629."
  []
  (println "migrations.20160320094629-recipes-table down...")
  (drop-recipes-table! {} (use-connection)))
