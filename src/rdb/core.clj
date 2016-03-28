(ns rdb.core
  (:require [rdb.handler :refer [app]]
            [ring.adapter.jetty :as jetty]))

(defn -main []
  (jetty/run-jetty app {:port 3000}))
