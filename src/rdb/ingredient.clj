(ns rdb.ingredient
  (:require [rdb.util.db :refer [use-connection with-db-transaction]]
            [yesql.core :refer [defqueries]]))

(defqueries "sql/ingredients.sql")

(defn get-all-ingredients []
  (fetch-all-ingredients {} (use-connection)))

(defn get-ingredient [id]
  (->
    (fetch-ingredient-by-id {:id id} (use-connection))
    first))

(defn include-ingredients [{recipe-id :id :as recipe}]
  (->>
    (select-ingredients-for-recipe {:recipeId recipe-id} (use-connection))
    (assoc recipe :ingredients)))

(defn- link-exists? [recipe-id ingredient-id connection]
  (->
    {:recipeId recipe-id :ingredientId ingredient-id}
    (fetch-recipe-ingredient-link (use-connection connection))
    empty?
    not))

(defn- update-link [recipe-id ingredient-id amount unit connection]
  (update-link! {:recipeId recipe-id :ingredientId ingredient-id :amount amount :unit unit} (use-connection connection)))

(defn- create-link [recipe-id ingredient-id amount unit connection]
  (create-link! {:recipeId recipe-id :ingredientId ingredient-id :amount amount :unit unit} (use-connection connection)))

(defn- persist-ingredient-recipe-link [recipe-id ingredient-id amount unit connection]
  (let [persist-link-fn (if (link-exists? recipe-id ingredient-id connection)
                          update-link
                          create-link)]
    (persist-link-fn recipe-id ingredient-id amount unit connection)))

(defn- persist-ingredient [recipe-id {:keys [id name description amount unit]} connection]
  (update-ingredient! {:id id :name name :description description} (use-connection connection))
  (persist-ingredient-recipe-link recipe-id id amount unit connection))

(defn persist-ingredients [{ingredients :ingredients recipe-id :id}]
  (with-db-transaction
    (fn [connection]
      (doseq [ingredient ingredients]
        (persist-ingredient recipe-id ingredient connection)))))

(defn remove-ingredient [id]
  (delete-ingredient-by-id! {:id id} (use-connection)))

(defn update-ingredient [id {:keys [name description]}]
  (update-ingredient! {:id id :name name :description description} (use-connection)))

(defn create-ingredient [ingredient]
  (insert-ingredient<! ingredient (use-connection)))