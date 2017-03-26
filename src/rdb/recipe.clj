(ns rdb.recipe
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/recipe.sql")

(defn- get-id-from-db-response [db-response]
  (->
   db-response
   first
   last))

(defn get-all-recipes []
  (->>
   (select-recipes {} (use-connection))))

(defn get-recipe [recipe-id]
  (->
   (select-recipe-by-id {:id recipe-id} (use-connection))
   first))

(defn create-new-recipe [recipe]
  (->>
    (create-recipe<! recipe (use-connection))
    get-id-from-db-response
    (assoc {} :id)))

(defn update-recipe [recipe]
  (update-recipe<! recipe (use-connection)))

(defn delete-recipe [recipe-id]
  (delete-recipe! {:id  recipe-id} (use-connection)))
