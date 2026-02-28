(import joy)
(import joy/responder :as r)
(import json :as j)

(def stock-price
  {:l 474.3
     :h 483.7
     :unixtime 1772323140000
     :o 462.7
     :c 474.3})

(defn opx [count]
  (let [stem @[
                 {
                   :brEven 12
                   :days 293
                   :ticker "YAR6L320"
                   :x 320
                   :bid 0
                   :ask 0
                   :expiry "2026-12-18"
                   :ivBid 0.3 
                   :ivAsk 0.4}
                 {
                   :brEven 12
                   :days 293
                   :ticker "YAR6L300"
                   :x 300
                   :bid 0
                   :ask 0
                   :expiry "2026-12-18"
                   :ivBid 0.1 
                   :ivAsk 0.2}
                 {
                   :brEven 12
                   :days 293
                   :ticker "YAR6L280"
                   :x 280
                   :bid 0
                   :ask 0
                   :expiry "2026-12-18"
                   :ivBid 0.4 
                   :ivAsk 0.5}
                 {
                   :brEven 12
                   :days 293
                   :ticker "YAR6L260"
                   :x 260
                   :bid 0
                   :ask 0
                   :expiry "2026-12-18"
                   :ivBid 0.2 
                   :ivAsk 0.3}]]
    (case count
      1 stem
      2 (array/join stem stem)
      3 (array/join stem stem stem)
      4 (array/join stem stem stem stem)
      5 (array/join stem stem stem stem stem)
      6 (array/join stem stem stem stem stem stem))))

(def payload  
  {:stockprice stock-price
   :opx (opx 6)}) 
        

(defn stock-options [req]
  (printf "%q" req)
  (let (response {:appStatusCode 1 :error nil :payload payload})
    (r/respond :json (j/encode response))))

(joy/route :get "/nordnet/calls/:oid" stock-options)
(joy/route :get "/nordnet/puts/:oid" stock-options)

