(defproject rdb "0.1.0-SNAPSHOT"
  :description "Recipes database"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dev-dependencies [[drift "1.5.3"]]
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [compojure "1.5.0"]
                 [ring "1.4.0"]
                 [yesql "0.5.2"]
                 [org.clojure/java.jdbc "0.4.2"]
                 [org.xerial/sqlite-jdbc "3.7.2"]]
  :plugins [[lein-ring "0.9.7"]
            [drift "1.5.3"]]

  :ring {:handler rdb.handler/handler}
  
  :main ^:skip-aot rdb.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
