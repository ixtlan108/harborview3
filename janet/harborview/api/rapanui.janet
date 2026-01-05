(import joy)
(import joy/responder :as r)
(import json :as j)

(defn acc-rule (oid)
  {:oid 72
   :pid 47
   :cid 45
   :rtyp 7
   :value 3.0
   :active true})

(defn critter (ticker)
  {:vol 10
   :status 7
   :oid 45
   :accRules [(acc-rule 45)]})

(defn ticker-payload ()
  (let (ticker "NHY9E30")
    {:ticker ticker 
     :oid 47
     :price 5.8
     :critters [(critter ticker)]}))
  

(defn purchase [req]
  (printf "%q" req)
  (let (response {:appstatus 0 :msg nil :payload [(ticker-payload)]})
    (r/respond :json (j/encode response))))

(joy/route :get "/critter/purchase/:purchasetype" purchase)

(var stock-opt-counter 0)

(defn option [spot bid ask]
  { :spot spot :option {:bid bid :ask ask} :optionStatus 0 :msg nil})

(defn inc-counter []
  (set stock-opt-counter (inc stock-opt-counter)))

(defn get-stock-opt []
  (case stock-opt-counter
    1 (option 100.0 10.0 11.0)
    2 (option 102.0 10.5 11.5)
    3 (option 104.0 12.5 14.5)
    4 (option 103.0 11.5 13.5)
    5 (option 99.0 9.0 10.5)
    (option 200.0 20.0 24.0)))

(defn stock-option [req]
  (printf "%q" req)
  (inc-counter)
  (let (response {:appstatus 0 :msg nil :payload (get-stock-opt)})
    (r/respond :json (j/encode response))))

(joy/route :get "/rapanui/stockoption/:ticker" stock-option)

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
