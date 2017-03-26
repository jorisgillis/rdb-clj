(ns db.migrations.20170326153207-allowed-users
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/migrations/20170326153207-allowed-users.sql")

(defn up
  "Migrates the database up to version 20170326153207."
  []
  (println "db.migrations.20170326153207-allowed-users up...")
  (create-allowed-users! {} (use-connection)))

(defn down
  "Migrates the database down from version 20170326153207."
  []
  (println "db.migrations.20170326153207-allowed-users down...")
  (drop-allowed-users! {} (use-connection)))