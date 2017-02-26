(ns rdb.user-test
  (:use clojure.test midje.sweet)
  (:require [rdb.user :refer :all]
            [rdb.util.db :refer [use-connection]]))

(background
  (use-connection) => :connected)

(fact "user-exists"
      (fact "User exists when she is found in the database"
            (user-exists "username") => true
            (provided
              (fetch-user {:name "username"} :connected) => [{:name "username"}]))

      (fact "User does not exist when she is not found in the database"
            (user-exists "username") => false
            (provided
              (fetch-user {:name "username"} :connected) => [])))