(import joy)
(import joy/responder :as r)
(import json :as j)

(import /api/rapanui)
(import /api/derivatives)

# Layout
(defn app-layout [{:body body :request request}]
  (joy/text/html
    (joy/doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "RAPA NUI"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (joy/csrf-token-value request)}]
      [:link {:href "https://fonts.googleapis.com" :rel "preconnect"}]
      [:link {:href "https://fonts.gstatic.com" :rel "preconnect" :crossorigin true}]
      [:link {:href "https://fonts.googleapis.com/css2?family=Poppins:wght@300&display=swap" :rel "stylesheet"}]
      [:link {:href "https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" 
              :rel "stylesheet"
              :integrity "sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" 
              :crossorigin "anonymous"}]
      [:script :src "https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"
               :integrity "sha384-HwwvtgBNo3bZJJLYd8oVXjrBZt8cqVSpeBNS5n7C8IVInixGAoxmnlMuBnhbgrkm"
               :crossorigin "anonymous"
               :defer ""]
      [:script :src "https://kit.fontawesome.com/54e36e60f6.js" :crossorigin "anonymous" :defer ""]]

     [:body
       body]]))



# Routes
(joy/route :get "/rapanui" :rapanui-home)

(joy/route :get "/maunaloa/stockoption" :derivatives-home)

(joy/route :get "/" :derivatives-home)


(defn rapanui-home [request]
  [:div {:id "rapanui"}
    [ [:link {:href "/rapanui.css" :rel "stylesheet"}]
      [:script {:src "/rapanui.js" :defer ""}]]])

(defn derivatives-home [request]
  [:div {:id "derivatives"}
    [ [:link {:href "/derivatives.css" :rel "stylesheet"}]
      [:script {:src "/derivatives.js" :defer ""}]]])

(defn maunaloa-home [request]
  [:div {:id "maunaloa"}
    [ [:link {:href "/derivatives.css" :rel "stylesheet"}]
      [:script {:src "/derivatives.js" :defer ""}]]])

# Middleware
(def app (-> (joy/handler)
             (joy/layout app-layout)
             # (joy/with-csrf-token)
             (joy/with-session)
             (joy/extra-methods)
             (joy/query-string)
             (joy/body-parser)
             (joy/json-body-parser)
             (joy/server-error)
             (joy/x-headers)
             (joy/static-files)
             (joy/not-found)
             (joy/logger)))

# Server
(defn main [& args]
  (let [port (get args 1 (os/getenv "PORT" "8080"))
        host (get args 2 "localhost")]
    (joy/server app port host)))



# <head>

#     <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css"
#         integrity="sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4" crossorigin="anonymous">

#     <script src="https://kit.fontawesome.com/54e36e60f6.js" crossorigin="anonymous"></script>
# </head>

# <body>
#     <nav class="navbar navbar-expand-lg navbar-light bg-light">
#         <a class="navbar-brand" href="#">Harborview</a>
#         <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent"
#             aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
#             <span class="navbar-toggler-icon"></span>
#         </button>

#         <div class="collapse navbar-collapse" id="navbarSupportedContent">
#             <ul class="navbar-nav mr-auto">
#                 <li class="nav-item dropdown">
#                     <a class="nav-link dropdown-toggle" href="#" id="navbarDropdownCritters" role="button"
#                         data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Critters</a>
#                     <div class="dropdown-menu" aria-labelledby="navbarDropdownCritters">
#                         <a class="dropdown-item" href="/critter/overlook">Overlook</a>
#                         <a class="dropdown-item" href="/rapanui">Rapa Nui</a>
#                     </div>
#                 </li>
#                 <li class="nav-item dropdown">
#                     <a class="nav-link dropdown-toggle" href="#" id="navbarDropdownMaunaloa" role="button"
#                         data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Maunaloa</a>
#                     <div class="dropdown-menu" aria-labelledby="navbarDropdownMaunaloa">
#                         <a class="dropdown-item" href="/maunaloa/charts">Charts</a>
#                         <a class="dropdown-item" href="/maunaloa/stockoption">Options</a>
#                         <a class="dropdown-item" href="/maunaloa/stockoption/purchases">Option Purchases</a>
#                     </div>
#                 </li>
#             </ul>
#         </div>
#     </nav>
#     <div class="logo"></div>
#     <div id="rapanui"></div>
#     <div>
#         <script type="text/javascript"
#             src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap.native/2.0.15/bootstrap-native-v4.min.js"></script>
#     </div>
#     <div>
# <div class="navbar fixed-bottom">
#     <p>dbinfo.info</p>
# </div>
# </div>

#     <script type="text/javascript" src="/js/rapanui/rapanui-af2aab86.js"></script>
#     <link rel="stylesheet" href="/css/rapanui/rapanui-1a63d339.css">

# </body>

# </html>


