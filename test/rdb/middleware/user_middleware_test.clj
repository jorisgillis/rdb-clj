(ns rdb.middleware.user-middleware-test
  (:use [midje.sweet])
  (:require [rdb.middleware.user-middleware :refer :all]
            [rdb.user :as user]
            [rdb.util.db :refer [use-connection]]
            [clj-http.client :as client]
            [clojure.data.json :refer [write-str]]))

(fact "wrap-user-info-in-session"
      (fact "fetches user info and adds to request and response"
            (let [wrap-fn           (wrap-user-info-in-session identity)
                  request           {:session {:cemerick.friend/identity {:current {:access-token "token"}}}}
                  expected-response {:session {:cemerick.friend/identity {:current {:access-token "token"}}
                                               :name                     "name"
                                               :fullname                 "fullname"
                                               :email                    "email"
                                               :id                       "123"}}]
              (wrap-fn request) => expected-response
              (provided
                (client/get "https://www.googleapis.com/oauth2/v2/userinfo"
                            {:query-params {"fields" "given_name,id,email,name"}
                             :headers      {"Authorization" "Bearer token"}
                             :accept       :json}) => {:body (write-str {"given_name" "name"
                                                                         "name"   "fullname"
                                                                         "email"      "email"
                                                                         "id"         "123"})}))

            (fact "does nothing if user info present"
                  (let [wrap-fn (wrap-user-info-in-session identity)
                        request {:session {:name "present"}}]
                    (wrap-fn request) => request))))

(fact "wrap-create-new-user"
      (fact "creates new user when the session user does not exist"
            (let [wrap-fn (wrap-create-new-user identity)
                  user    {:name "unknown" :id "123" :fullname "fullname" :email "email"}
                  request {:session user}]
              (wrap-fn request) => request
              (provided
                (user/user-exists "unknown") => false
                (use-connection) => :connected
                (user/create-user! user :connected) => anything)))

      (fact "does not create new user when the session user already exists"
            (let [wrap-fn (wrap-create-new-user identity)
                  user    {:name "known" :id "123" :fullname "fullname" :email "email"}
                  request {:session user}]
              (wrap-fn request) => request
              (provided
                (user/user-exists "known") => true
                (user/create-user! anything anything) => anything :times 0))))