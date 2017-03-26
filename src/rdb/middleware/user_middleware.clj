(ns rdb.middleware.user-middleware
  (:require [rdb.user :refer [user-exists create-user!]]
            [rdb.util.db :refer [use-connection]]
            [cemerick.friend :as friend]
            [clj-http.client :as client]
            [clojure.data.json :refer [read-str]]
            [clojure.walk :as walk]
            [clojure.tools.logging :refer [info]]))

(defn- google-user->user [user-info]
  {:name     (:given_name user-info)
   :fullname (:name user-info "")
   :email    (:email user-info "")
   :id       (:id user-info)})

(defn- get-user-info [token]
  (->
    (client/get "https://www.googleapis.com/oauth2/v2/userinfo"
                {:query-params {"fields" "given_name,id,email,name"}
                 :headers      {"Authorization" (str "Bearer " (:access-token token))}
                 :accept       :json})
    :body
    read-str
    walk/keywordize-keys
    google-user->user))

(defn- user-info-in-session [request]
  (some->
    request
    :session
    :name
    nil?
    not))

(defn get-user-id [request]
  (:id (:session request)))

(defn- add-user-info-to-session [handler request]
  (let [token     (:current (friend/identity request))
        user-info (get-user-info token)
        response  (->
                    request
                    (assoc :session (merge (:session request) user-info))
                    handler)]
    (info (str "Added user info into session, for user " (:name user-info)))
    (assoc response :session (merge (:session response) user-info))))

(defn wrap-user-info-in-session [handler]
  (fn [request]
    (if (not (user-info-in-session request))
      (add-user-info-to-session handler request)
      (handler request))))

(defn wrap-create-new-user [handler]
  (fn [request]
    (when (not (user-exists (get-in request [:session :name])))
      (do
        (info (str "Creating user " (:name (:session request))))
        (->
          (select-keys (:session request) [:id :name :fullname :email])
          (create-user! (use-connection)))))
    (handler request)))
