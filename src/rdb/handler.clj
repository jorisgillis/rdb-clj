(ns rdb.handler
  (:gen-class)
  (:use compojure.core)
  (:require [rdb.recipe :as r]
            [ring.middleware.json :refer [wrap-json-response wrap-json-body]]
            [ring.util.response :refer [response not-found]]
            [ring.middleware.params :refer [wrap-params]]
            [ring.middleware.keyword-params :refer [wrap-keyword-params]]
            [compojure.route :as route]
            [compojure.handler :as handler]
            [clojure.walk :as walk]))

(defn- parse-request-body [request]
  (->
   request
   :body
   walk/keywordize-keys))

(defroutes main-routes
  (GET "/" []
       (response (apply str "Powered by Clojure & Ring")))

  (context "/recipe" []
           (GET "/" []
                (response {:recipes (r/get-all-recipes)}))

           (GET "/:id" [id]
                (let [recipe (r/get-recipe id)]
                  (if-not (nil? recipe)
                    (response recipe)
                    (not-found recipe))))

           (POST "/" request
                 (->
                  (parse-request-body request)
                  r/create-new-recipe))

           (PUT "/" request
                (->
                 (parse-request-body request)
                 r/update-recipe)))

  (route/resources "/")
  (route/not-found "Page not found"))

(def app
  (->
   main-routes
   handler/api
   wrap-json-response
   wrap-json-body
   wrap-params
   wrap-keyword-params))
