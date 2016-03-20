(ns rdb.recipe
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]
            [schema.core :as s]))

(defqueries "sql/recipe.sql")

(s/defrecord Recipe 
    [id :- s/Int 
     name :- s/Str 
     description :- s/Str])

(s/defrecord RecipeCreate 
    [name :- s/Str
     description :- s/Str])

(s/defn get-all-recipes :- [Recipe] 
  []
  (->>
   (select-recipes {} (use-connection))
   (mapv map->Recipe)))

(s/defn get-recipe :- Recipe 
  [recipe-id :- s/Int]
  (let [recipe (->
                (select-recipe-by-id {:id recipe-id} (use-connection))
                first)]
    (when-not (nil? recipe) (map->Recipe recipe))))

(s/defn create-new-recipe 
  [recipe :- RecipeCreate]
  (create-recipe! recipe (use-connection)))
