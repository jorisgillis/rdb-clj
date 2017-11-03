(ns rdb.handler-test
  (:use midje.sweet)
  (:require [rdb.handler :refer :all]
            [rdb.recipe :as r]
            [rdb.ingredient :as ingredient]
            [rdb.util.db :as db]
            [rdb.middleware.user-middleware :refer [get-user-id]]
            [peridot.core :as peridot]
            [clojure.data.json :refer [write-str]]))

(facts "/recipe"
       (fact "GET without id returns list of all recipes"
             (let [resp                     (delay (peridot/request (peridot/session unsecured-app) "/recipe"))
                   recipe1                  {:id 1 :name "recipe1" :description nil :username "name"}
                   ingredients1             [{:amount 1 :unit "kilogram" :name "flour" :description ""}]
                   recipe1-with-ingredients (assoc recipe1 :ingredients ingredients1)
                   recipe2                  {:id 2 :name "recipe2" :description "Description" :username "name"}
                   ingredients2             [{:amount 3 :unit "pieces" :name "lemon" :description ""}]
                   recipe2-with-ingredients (assoc recipe2 :ingredients ingredients2)
                   expectedResponse         (write-str {:recipes [recipe1-with-ingredients recipe2-with-ingredients]})]
               (:status (:response @resp)) => 200
               (provided
                 (db/use-connection) => :connected
                 (r/select-recipes {} :connected) => [recipe1 recipe2]
                 (ingredient/include-ingredients recipe1) => recipe1-with-ingredients
                 (ingredient/include-ingredients recipe2) => recipe2-with-ingredients)
               (:body (:response @resp)) => expectedResponse))

       (fact "GET with id returns recipe with given id"
             (let [resp        (delay (peridot/request (peridot/session unsecured-app) "/recipe/1"))
                   recipe      {:id 1 :name "Name" :description "Description"}
                   ingredients [{:amount 42 :unit "piece" :name "Gargle Blaster" :description "Pan Galactic"}]
                   expected    (write-str (assoc recipe :ingredients ingredients))]
               (:status (:response @resp)) => 200
               (provided
                 (r/get-recipe anything) => recipe
                 (ingredient/include-ingredients recipe) => (assoc recipe :ingredients ingredients))
               (:body (:response @resp)) => expected))

       (fact "POST creates new recipe and returns id"
             (let [resp (delay (->
                                 (peridot/session unsecured-app)
                                 (peridot/content-type "application/json")
                                 (peridot/request
                                   "/recipe"
                                   :request-method :post
                                   :body "{\"name\": \"Name\", \"description\": \"Description\"}")))]
               (:status (:response @resp)) => 200
               (provided
                 (r/create-new-recipe {:name "Name" :description "Description" :userid 123}) => {:id 7}
                 (get-user-id anything) => 123)
               (:body (:response @resp)) => (write-str {:id 7})))

       (fact "PUT updates a given recipes"
             (let [body "{\"id\": 1, \"name\": \"Name\", \"description\": \"Description\"}"
                   resp (delay (->
                                 (peridot/session unsecured-app)
                                 (peridot/content-type "application/json")
                                 (peridot/request
                                   "/recipe"
                                   :request-method :put
                                   :body body)))]
               (:status (:response @resp)) => 200
               (provided
                 (r/update-recipe {:id 1 :name "Name" :description "Description"}) => anything))))

(facts "/ingredient"
       (fact "GET returns list of all ingredients"
             (let [response          (delay (->
                                              (peridot/session unsecured-app)
                                              (peridot/request "/ingredient")))
                   pasta             {:id 1 :name "Pasta" :description "From Italia"}
                   tomato            {:id 2 :name "Tomato" :description ""}
                   expected-response (write-str {:ingredients [pasta tomato]})]
               (:status (:response @response)) => 200
               (provided
                 (ingredient/get-all-ingredients) => [pasta tomato])
               (:body (:response @response)) => expected-response))

       (fact "GET with id returns the requested ingredient"
             (let [response          (delay (->
                                              (peridot/session unsecured-app)
                                              (peridot/request "/ingredient/42")))
                   gargle-blaster    {:id 42 :name "Gargle Blaster" :description "Pan Galactic"}
                   expected-response (write-str gargle-blaster)]
               (:status (:response @response)) => 200
               (provided
                 (ingredient/get-ingredient "42") => gargle-blaster)
               (:body (:response @response)) => expected-response))

       (fact "GET with id returns not found if requested ingredient doesn't exist"
             (let [response (delay (->
                                     (peridot/session unsecured-app)
                                     (peridot/request "/ingredient/1")))]
               (:status (:response @response)) => 404)))

