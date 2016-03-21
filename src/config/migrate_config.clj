(ns config.migrate-config
  (:require [rdb.util.db :as db]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/migration.sql")

(defn current-db-version []
  (or (-> 
       (select-current-version {} (db/use-connection))
       first
       :version) 
      0))

(defn update-db-version [new-version]
  (update-current-version! {:next new-version} (db/use-connection)))

(defn migrate-config []
  {:directory "/src/db/migrations"
   :current-version current-db-version
   :update-version update-db-version})
