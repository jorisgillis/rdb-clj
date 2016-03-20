(ns rdb.handler
  (:gen-class)
  (:use compojure.core)
  (:require [rdb.recipe :as r]
            [ring.adapter.jetty :as jetty]
            [ring.middleware.json :refer [wrap-json-response wrap-json-body]]
            [ring.util.response :refer [response not-found]]
            [ring.middleware.params :refer [wrap-params]]
            [compojure.route :as route]
            [compojure.handler :as handler]))

(defroutes main-routes
  (GET "/" [] 
       (response (apply str "Powered by Clojure & Ring")))

  (context "/recipe" []
           (GET "/" []
                (response {:recipes (r/get-all-recipes)}))

           (GET "/:id" [id :as request]
                (let [recipe (r/get-recipe id)]
                  (if-not (nil? recipe)
                    (response recipe)
                    (not-found recipe))))
           
           (POST "/" [request]         
                 (->
                  request
                  :body
                  r/map->RecipeCreate
                  r/create-new-recipe)))

  (route/resources "/")
  (route/not-found "Page not found"))

(def app 
  (->
   main-routes
   handler/api
   wrap-json-response))

(defn -main []
  (jetty/run-jetty app {:port 3000}))
