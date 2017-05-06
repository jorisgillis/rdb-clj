(ns rdb.util.db
  (:require [clojure.java.jdbc :as jdbc]))

(def db-spec
  {:classname   "org.sqlite.JDBC"
   :subprotocol "sqlite"
   :subname     "database.db"})

(defn use-connection
  ([] {:connection db-spec})
  ([connection] {:connection  connection
                 :identifiers identity}))

(defn with-db-transaction [f]
  (jdbc/with-db-transaction
    [connection db-spec]
    (f connection)))