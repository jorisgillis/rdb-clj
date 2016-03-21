(ns rdb.recipe-test
  (:use clojure.test midje.sweet)
  (:require [rdb.recipe :refer :all]
            [rdb.util.db :refer [use-connection]]))

(namespace-state-changes [(around :facts (schema.core/with-fn-validation ?form))])

(fact "get-all-recipes fetches all recipes from the database"
  (let [result1 {:id 1 :name "recipe1" :description "description1"}
        result2 {:id 2 :name "recipe2" :description "description2"}
        recipe1 (map->Recipe result1)
        recipe2 (map->Recipe result2)]
    (get-all-recipes) => [recipe1 recipe2]
    (provided
     (use-connection) => :connected
     (select-recipes {} :connected) => [result1 result2])))

(fact "get-recipe fetches the recipe by id"
  (let [result {:id 1 :name "my-recipe" :description "my-description"}
        recipe (map->Recipe result)]
    (get-recipe 1) => recipe 
    (provided
     (use-connection) => :connected
     (select-recipe-by-id {:id 1} :connected) => [result])))
