(ns rdb.user
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/user.sql")

(defn user-exists [name]
  (->
    (fetch-user {:name name} (use-connection))
    count
    (= 1)))

