(ns rdb.ingredient-test
  (:use [midje.sweet])
  (:require [rdb.ingredient :refer :all]
            [rdb.util.db :refer [use-connection with-db-transaction]]))

(def tomato {:id 42 :name "Tomato" :description "Pomodoro" :amount 2 :unit "kg"})
(def potato {:id 43 :name "Potato" :description "Nicola" :amount 3 :unit "piece"})
(def recipe {:id 1 :ingredients [tomato potato]})

(background
  (use-connection :connection) => :connected
  (use-connection) => :connected)

(with-redefs
  [with-db-transaction (fn [f] (f :connection))]

  (fact "updates ingredients and links if already exist"
        (persist-ingredients recipe) => anything
        (provided
          (fetch-recipe-ingredient-link {:recipeId 1 :ingredientId 42} :connected) => [{}]
          (fetch-recipe-ingredient-link {:recipeId 1 :ingredientId 43} :connected) => [{}]
          (update-ingredient! {:id 42 :name "Tomato" :description "Pomodoro"} :connected) => anything
          (update-ingredient! {:id 43 :name "Potato" :description "Nicola"} :connected) => anything
          (update-link! {:recipeId 1 :ingredientId 42 :amount 2 :unit "kg"} :connected) => anything
          (update-link! {:recipeId 1 :ingredientId 43 :amount 3 :unit "piece"} :connected) => anything))

  (fact "updates ingredients and stores new links if non existing"
        (persist-ingredients recipe) => anything
        (provided
          (fetch-recipe-ingredient-link {:recipeId 1 :ingredientId 42} :connected) => []
          (fetch-recipe-ingredient-link {:recipeId 1 :ingredientId 43} :connected) => []
          (update-ingredient! {:id 42 :name "Tomato" :description "Pomodoro"} :connected) => anything
          (update-ingredient! {:id 43 :name "Potato" :description "Nicola"} :connected) => anything
          (create-link! {:recipeId 1 :ingredientId 42 :amount 2 :unit "kg"} :connected) => anything
          (create-link! {:recipeId 1 :ingredientId 43 :amount 3 :unit "piece"} :connected) => anything)))
