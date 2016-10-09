(ns rdb.util.db
  (:require [clojure.java.jdbc :as jdbc]))

(def db-spec
  {:classname   "org.sqlite.JDBC"
   :subprotocol "sqlite"
   :subname     "database.db"})

(defn use-connection []
  {:connection db-spec})
