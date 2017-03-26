(ns rdb.middleware.allowed-users-test
  (:use [midje.sweet])
  (:require [rdb.middleware.allowed-users :refer :all]
            [rdb.util.db :as db]))

(background
  (db/use-connection) => :connection
  (all-allowed-users {} :connection) => [{:email "me@me.com"}])

(let [handler identity]
  (fact "allows a logged in user when the email is known"
        (let [request {:session {:email "me@me.com"}}]
          ((wrap-allowed-users handler) request) => request))

  (fact "disallows a logged in user when the email is not known"
        (let [request  {:session {:email "me@not-me.com"}}
              response ((wrap-allowed-users handler) request)]
          (:status response) => 403
          (:body response) => {:error "Not allowed"})))
