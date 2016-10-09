(ns rdb.recipe-test
  (:use clojure.test midje.sweet)
  (:require [rdb.recipe :refer :all]
            [rdb.util.db :refer [use-connection]]))

(fact "get-all-recipes fetches all recipes from the database"
      (let [result1 {:id 1 :name "recipe1" :description "description1"}
            result2 {:id 2 :name "recipe2" :description "description2"}]
        (get-all-recipes) => [result1 result2]
        (provided
         (use-connection) => :connected
         (select-recipes {} :connected) => [result1 result2])))

(fact "get-recipe fetches the recipe by id"
      (let [result {:id 1 :name "my-recipe" :description "my-description"}]
        (get-recipe 1) => result
        (provided
         (use-connection) => :connected
         (select-recipe-by-id {:id 1} :connected) => [result])))

(fact "creates new recipe and returns the id of the newly created recipe"
      (create-new-recipe {}) => {:id 7}
      (provided
       (use-connection) => :connected
       (create-recipe<! {} :connected) => {:last-row-id 7}))
