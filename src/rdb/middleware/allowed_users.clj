(ns rdb.middleware.allowed-users
  (:require [rdb.util.db :refer [use-connection]]
            [yesql.core :refer [defqueries]]
            [ring.util.response :refer [response status]]
            [clojure.core.cache :as cache]))

(defqueries "sql/allowed_users.sql")

(def ^:private CACHE_TTL_IN_MS (* 1000 60 15))
(def ^:private cache-allowed-users (cache/ttl-cache-factory {} :ttl CACHE_TTL_IN_MS))

(defn- fetch-all-allowed-users [_]
  (all-allowed-users {} (use-connection)))

(defn- get-allowed-users []
  (->
    (cache/through fetch-all-allowed-users cache-allowed-users :emails)
    :emails))

(defn- is-email-allowed? [email]
  (->>
    (get-allowed-users)
    (filter #(= (:email %) email))
    empty?
    not))

(defn wrap-allowed-users [handler]
  (fn [request]
    (let [email (get-in request [:session :email])]
      (if (is-email-allowed? email)
        (handler request)
        (status (response {:error "Not allowed"}) 403)))))
