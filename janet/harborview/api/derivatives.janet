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
                   :bid 190 
                   :ask 195 
                   :expiry "2026-12-18"
                   :ivBid -0.3 
                   :ivAsk 0.4}
                 {
                   :brEven 12
                   :days 293
                   :ticker "YAR6L300"
                   :x 300
                   :bid 210 
                   :ask 215 
                   :expiry "2026-12-18"
                   :ivBid 0.1 
                   :ivAsk -0.2}
                 {
                   :brEven 12
                   :days 293
                   :ticker "YAR6L280"
                   :x 280
                   :bid 230 
                   :ask 235 
                   :expiry "2026-12-18"
                   :ivBid 0.4 
                   :ivAsk 0.5}
                 {
                   :brEven 12
                   :days 293
                   :ticker "YAR6L260"
                   :x 260
                   :bid 250 
                   :ask 255
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

(def opx-1 (opx 1))

(def payload  
  {:stockprice stock-price
   :opx opx-1}) 
        
(defn between [v vmin vmax] 
  (and (>= v vmin) (< v vmax)))

(defn calc-risc-2 [v]
  (cond 
    (between v 0 200.0) 420.0
    (between v 200.0 220.0) 430.0
    (between v 220.0 230.0) 440.0
    (between v 230.0 240.0) 450.0
    465.0))

(defn calc-risc [{:ticker t :risc r}]
  (let [hit (find (fn [x] (= (x :ticker) t)) opx-1)
        adjusted-bid (- (hit :ask) r)
        sp-at-risc (calc-risc-2 adjusted-bid)]
    (printf "HIT %q, adjusted bid %f, sp-at-risc: %f" hit adjusted-bid sp-at-risc)
    {:ticker t :stockprice sp-at-risc :optionprice adjusted-bid :status 1}))

(defn stock-options [req]
  (printf "%q" req)
  (let (response {:appStatusCode 1 :error nil :payload payload})
    (r/respond :json (j/encode response))))

(joy/route :get "/nordnet/calls/:oid" stock-options)
(joy/route :get "/nordnet/puts/:oid" stock-options)

(defn calculate-riscs [req]
  (printf "%q" req)
  (let [risc-payload (map calc-risc (req :body))
        response {:appStatusCode 1 :error nil :payload risc-payload}
        json-response (j/encode response)]
    #(printf "%q" json-response)
    (r/respond :json json-response)))
  
(joy/route :post "/maunaloa/stockprice/calculate" calculate-riscs)


