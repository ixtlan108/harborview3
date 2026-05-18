(import joy)
(import joy/responder :as r)
(import json :as j)
(import /api/common :as c)

(defn mk-acc [pid cid oid value]
  {:pid pid 
   :cid cid 
   :oid oid 
   :rtyp 7
   :value value 
   :active true})

(defn mk-critter [cid vol acc-rules]
  {:vol vol 
   :status 7
   :oid cid 
   :accRules acc-rules}) 

(defn mk-ticker [ticker oid price critters]
  { :ticker ticker 
    :oid oid
    :price price
    :critters critters})

(comment ticker-payload ()
  (let (ticker "NHY9E30")
    [{:ticker ticker 
        :oid 47
        :price 5.8
        :critters [(critter ticker)]}]))

(def pl-1 
  (let [pid 1 
        cid 11
        acc-oid 111
        acc (mk-acc pid cid acc-oid 3.0)
        critter (mk-critter cid 10 [acc])
        ticker (mk-ticker "NHY9E30" pid 12.0 [critter])]))

(def pl-2
  (let [pid 2 
        cid 12
        acc-oid 112
        acc (mk-acc pid cid acc-oid 1.0)
        critter (mk-critter cid 10 [acc])
        ticker (mk-ticker "NHY9E40" pid 8.0 [critter])]))

(defn purchase [req]
  (printf "%q" req)
  (c/payload-response [pl-1 pl-2]))


(var stock-opt-counter 0)

(defn inc-counter []
  (if (> stock-opt-counter 5)
    (set stock-opt-counter 0) 
    (++ stock-opt-counter)))

(defn option [spot bid]
  (let [ask (* 1.25 bid)]
    { :spot spot :option {:bid bid :ask ask} :optionStatus 0 :msg nil}))

(defn get-stock-opt [ticker]
  (if (= ticker "NHY9E30")
    (case stock-opt-counter
      1 (option 100.0 10.0)
      2 (option 102.0 10.5)
      3 (option 104.0 12.5)
      4 (option 103.0 11.5)
      5 (option 99.0 8.0)
      6 (option 92.0 4.0)
      (option 200.0 20.0))
    (case stock-opt-counter # ticker == NHY9E40
      1 (option 100.0 8.0)
      2 (option 102.0 8.5)
      3 (option 104.0 9.5)
      4 (option 97.0 6.5)
      5 (option 102.0 8.0)
      6 (option 92.0 4.0)
      (option 100.0 8.0))))

(defn stock-option [req]
  #(printf "%q" req)
  #(printf "%q" (c/get-param-str req :ticker))
  (inc-counter)
  (printf "COUNTER: %d" stock-opt-counter)
  (let [ticker (c/get-param-str req :ticker)]
    (c/payload-response (get-stock-opt ticker))))

(defn sale? [v] (v :isSale)) 

(defn option-sales [req]
  (let [body (req :body)
        sales (filter sale? body)]
    (printf "req body %q" body)
    (if (= (length body) (length sales))
      (c/default-response "Option sale registered ok")
      (c/post-response 32 "Some option sales were error"))))

(joy/route :get "/rapanui/stockoption/:ticker" stock-option)
(joy/route :get "/critter/purchase/:purchasetype" purchase)
(joy/route :put "/rapanui/optionsales" option-sales)

# {"appStatusCode": 1,
#  "error": null,
#  "payload":
#    [
#      {
#        "ticker": "NHY9E30",
#        "oid": 47,
#        "price": 5.8,
#        "critters": 
#          [
#           {
#             "vol": 10,
#             "status": 7,
#             "oid": 45,
#             "accRules": []
#                {
#                  "oid": 72,
#                  "pid": 47,
#                  "cid": 45,
#                  "rtyp": 1
#                  "value": 3,
#                  "active": true,}
#                ,
#                {
#                  "oid": 73,
#                  "pid": 47,
#                  "cid": 45,
#                  "rtyp": 7
#                  "value": 2,
#                  "active": false,}}]}]})
#
