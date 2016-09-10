(ns rdb.handler-test
  (:use midje.sweet)
  (:require [rdb.handler :refer :all]
            [rdb.recipe :as r]
            [rdb.util.db :as db]
            [peridot.core :as peridot]
            [clojure.data.json :refer [write-str]]))

(facts "/recipe"
  (fact "GET without id returns list of all recipes"
        (let [resp             (delay (peridot/request (peridot/session app) "/recipe"))
              recipe1          {:id 1 :name "recipe1" :description nil}
              recipe2          {:id 2 :name "recipe2" :description "Description"}
              expectedResponse (write-str {:recipes [recipe1 recipe2]})]
          (:status (:response @resp)) => 200
          (provided
           (db/use-connection) => :connected
           (r/select-recipes {} :connected) => [recipe1 recipe2])
          (:body (:response @resp)) => expectedResponse))
  
  (fact "GET with id returns recipe with given id"
        (let [resp     (delay (peridot/request (peridot/session app) "/recipe/1"))
              expected (write-str {:id 1 :name "Name" :description "Description"})]
          (:status (:response @resp)) => 200
          (provided
           (r/get-recipe anything) => {:id 1 :name "Name" :description "Description"})
          (:body (:response @resp)) => expected))

  (fact "POST creates new recipe and returns id"
        (let [resp (delay (->
                           (peridot/session app)
                           (peridot/content-type "application/json")
                           (peridot/request
                               "/recipe"
                               :request-method :post
                               :body "{\"name\": \"Name\", \"description\": \"Description\"}")))]
          (:status (:response @resp)) => 200
          (provided
           (r/create-new-recipe {:name "Name" :description "Description"}) => {:id 7})
          (:body (:response @resp)) => (write-str {:id 7})))

  (fact "PUT updates a given recipes"
        (let [body "{\"id\": 1, \"name\": \"Name\", \"description\": \"Description\"}"
              resp (delay (->
                           (peridot/session app)
                           (peridot/content-type "application/json")
                           (peridot/request
                            "/recipe"
                            :request-method :put
                            :body body)))]
          (:status (:response @resp)) => 200
          (provided
           (r/update-recipe {:id 1 :name "Name" :description "Description"}) => anything))))

