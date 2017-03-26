(defproject rdb "0.1.0-SNAPSHOT"
  :description "Recipes database"
  :url "http://example.com/FIXME"
  :license {:name "GNU GPL v3"
            :url  "http://gplv3.fsf.org/"}
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.clojure/tools.logging "0.3.1"]
                 [org.clojure/data.json "0.2.6"]
                 [org.clojure/java.jdbc "0.4.2"]
                 [org.clojure/core.cache "0.6.5"]
                 [ch.qos.logback/logback-classic "1.1.3"]
                 [compojure "1.5.0"]
                 [ring "1.4.0"]
                 [ring/ring-json "0.4.0"]
                 [jumblerg/ring.middleware.cors "1.0.1"]
                 [com.cemerick/friend "0.2.3"]
                 [com.cemerick/url "0.1.1"]
                 [clojusc/friend-oauth2 "0.2.0"]
                 [peridot "0.4.3"]
                 [yesql "0.5.2"]
                 [org.xerial/sqlite-jdbc "3.7.2"]
                 [drift "1.5.3"]
                 [midje "1.8.3"]
                 [prismatic/schema "1.1.0"]
                 [org.apache.httpcomponents/httpcore "4.4.5"]
                 [org.apache.httpcomponents/httpclient "4.5.2"]
                 [clj-http "2.3.0"]]
  :plugins [[lein-ring "0.9.7"]
            [drift "1.5.3"]
            [lein-midje "3.2"]]

  :ring {:handler rdb.handler/app}
  :dev {:injections [(require 'schema.core) (schema.core/set-fn-validation! true)]}
  :main ^:skip-aot rdb.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}
             :dev     {:jvm-opts ["-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8787"]}}
  :aliases {"debug" ["with-profile" "dev" "ring" "server-headless"]
            "serve" {"ring" "server-headless"}})
