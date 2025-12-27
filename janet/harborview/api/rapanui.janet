(import joy)
(import joy/responder :as r)
(import json :as j)

(defn acc-rule (oid)
  {:oid 72
   :pid 47
   :cid 45
   :rtyp 1
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
     ::price 5.8
     :critters [(critter ticker)]}))
  

(defn purchase [req]
  (printf "%q" req)
  (let (response {:appstatus 0 :msg nil :payload [(ticker-payload)]})
    (r/respond :json (j/encode response))))

(joy/route :get "/critter/purchase/:purchasetype" purchase)


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
