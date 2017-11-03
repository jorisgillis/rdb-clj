(ns rdb.handler
  (:gen-class)
  (:use compojure.core)
  (:require [rdb.recipe :as r]
            [rdb.ingredient :as ingredient]
            [rdb.middleware.user-middleware :refer [wrap-create-new-user wrap-user-info-in-session get-user-id]]
            [rdb.middleware.allowed-users :refer [wrap-allowed-users]]
            [ring.middleware.json :refer [wrap-json-response wrap-json-body]]
            [ring.util.response :refer [response not-found header status file-response resource-response]]
            [ring.middleware.params :refer [wrap-params]]
            [ring.middleware.keyword-params :refer [wrap-keyword-params]]
            [ring.middleware.cors :refer [wrap-cors]]
            [ring.middleware.session :refer [wrap-session]]
            [compojure.route :as route]
            [compojure.handler :as handler]
            [clojure.walk :as walk]
            [clojure.data.json :refer [write-str read-str]]
            [friend-oauth2.workflow :as oauth2]
            [friend-oauth2.util :as util]
            [cemerick.friend :as friend]
            [cemerick.friend.workflows :as workflows]
            [cemerick.friend.credentials :as creds]
            [cemerick.url :as url]
            [clj-http.client :as client]))

(defn- parse-request-body [request]
  (->
    request
    :body
    walk/keywordize-keys))

(defroutes
  main-routes

  (GET "/user/" request
    (->
      request
      :session
      (select-keys [:id :name :email])
      response))

  (context "/recipe" []
    (GET "/" []
      (->>
        (r/get-all-recipes)
        (map ingredient/include-ingredients)
        (assoc {} :recipes)
        response))

    (GET "/:id" [id]
      (let [recipe (r/get-recipe id)]
        (if-not (nil? recipe)
          (response (ingredient/include-ingredients recipe))
          (not-found recipe))))

    (POST "/" request
      (->
        (parse-request-body request)
        (assoc :userid (get-user-id request))
        r/create-new-recipe
        response))

    (PUT "/" request
      (->
        (parse-request-body request)
        r/update-recipe)
      (response {:response "ok"}))

    (DELETE "/:id" [id]
      (do
        (r/delete-recipe id)
        (response {:response "ok"}))))

  (context "/ingredient" []
    (GET "/" []
      (response {:ingredients (ingredient/get-all-ingredients)}))

    (GET "/:id" [id]
      (let [ingredient (ingredient/get-ingredient id)]
        (if (nil? ingredient)
          (not-found (str "Ingredient with id " id " could not be found"))
          (response ingredient))))

    (POST "/" request
      (let [id (ingredient/create-ingredient request)]
        (if (not (nil? id))
          (response {:id id})
          (status "Failed" 500))))

    (PUT "/:id" [id :as request]
      (let [id (ingredient/update-ingredient id request)]
        (if (not (nil? id))
          (response {:id id})
          (status "Failed" 500))))

    (DELETE "/:id" [id]
      (ingredient/remove-ingredient id)
      (response "")))

  (route/resources "/")
  (route/not-found "Page not found"))

(def callback-url "http://localhost:3000/authentication/callback")
(def parsed-url (url/url callback-url))

(def client-config
  {:client-id     (System/getenv "RDB_CLIENT_ID")
   :client-secret (System/getenv "RDB_SECRET")
   :callback      {:domain (format "%s://%s:%s"
                                   (:protocol parsed-url)
                                   (:host parsed-url)
                                   (:port parsed-url))
                   :path   (:path parsed-url)}})

(def uri-config
  {:authentication-uri {:url   "https://accounts.google.com/o/oauth2/v2/auth"
                        :query {:client_id     (:client-id client-config)
                                :response_type "code"
                                :redirect_uri  callback-url
                                :scope         "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"}}
   :access-token-uri   {:url   "https://www.googleapis.com/oauth2/v4/token"
                        :query {:client_id     (:client-id client-config)
                                :client_secret (:client-secret client-config)
                                :grant_type    "authorization_code"
                                :redirect_uri  callback-url}}})

(defn credential-fn
  [token]
  {:identity token
   :roles    #{::user}})

(def workflow
  (oauth2/workflow
    {:client-config client-config
     :uri-config    uri-config
     :credential-fn credential-fn}))

(def auth-opts
  {:allow-anon? false
   :workflows   [workflow]})

(def unsecured-app
  (->
    main-routes
    handler/api
    wrap-json-body
    wrap-json-response
    wrap-session))

(def app
  (->
    main-routes
    wrap-allowed-users
    wrap-create-new-user
    wrap-user-info-in-session
    (friend/authenticate auth-opts)
    handler/api
    wrap-json-body
    wrap-session
    wrap-json-response
    (wrap-cors identity)))
