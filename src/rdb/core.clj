(ns rdb.core
  (:gen-class)
  (:use compojure.core)
  (:require [ring.adapter.jetty :as jetty]
            [ring.middleware.params :refer [wrap-params]]
            [compojure.route :as route]
            [compojure.handler :as handler]))

(defroutes main-routes
  (GET "/" [] 
       (apply str "Powered by Clojure & Ring"))

  (GET "/:id" [id :as request]
       (str "Id number: " id))

  (route/resources "/")
  (route/not-found "Page not found"))

(def app (handler/api main-routes))

(defn -main []
  (jetty/run-jetty app {:port 3000}))
