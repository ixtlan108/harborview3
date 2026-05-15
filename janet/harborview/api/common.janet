(import joy/responder :as r)
(import json :as j)

(def APP-STATUS-OK 0)
(def SEARCH-NOT-FOUND 32)

(defn get-param-str [req param-name]
  ((req :params) param-name))

#  (let [p (req :params)]
#    (p param-name)))

(defn get-body-item [req item-name]
  (let [b (req :body)]
    (b item-name)))

(defn get-qs-int [req param-name]
  (let [q (req :query-string)
        val (q param-name)]
    (if val
      (-> (int/u64 val) (int/to-number))
      nil)))

(defn get-qs-str [req param-name]
  (let [p (req :query-string)
        val (p param-name)]
   (if val
     (p param-name)
     nil)))

(defn payload-response (payload)
  (let (p {:status APP-STATUS-OK :msg nil :payload payload})
    (r/respond :json (j/encode p))))

(defn default-response (msg)
  (let [resp {:status APP-STATUS-OK :msg msg}]
    (r/respond :json (j/encode resp))))

(defn post-response (status msg)
  (let [resp {:status status :msg msg}]
    (r/respond :json (j/encode resp))))

