(ns config.migrate-config
  (:require [rdb.util.db :as db]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/migration.sql")

(defn current-db-version []
  (select-current-version {} (db/use-connection)))

(defn update-db-version [new-version]
  (update-current-version {:new-version new-version} (db/use-connection)))

(defn migrate-config []
  {:directory "db/migrations"
   :current-version current-db-version
   :update-version update-db-version})
