(import /html/button :as btn)
(import /html/wrapper :as wr)
(import /html/input :as inp)
(import /html/common :as c)
(import /html/select2 :as sel2)
(import /html/checkbox :as cx)


(def prelude 
  @[[1 "module Derivatives.UI"]
    [2 "where"]
    [1 ""]
    [1 "import Prelude"]
    [1 "import Data.Maybe (Maybe(..))"]
    [1 "import DOM.HTML.Indexed.InputType (InputType(..))"]
    [1 "import Halogen.HTML as HH"]
    [1 "import Halogen.HTML.Events as HE"]
    [1 "import Halogen.HTML.Properties as HP"]
    [1 "import Halogen.HTML (HTML, ClassName(..))"]
    [1 "import Derivatives.Actions (MainAction(..),PurchaseAction(..))"]
    [1 ""]])

(def tickers 
    [{ :t "AKSO" :v "18"}
     { :t "BAKKA" :v "27"}
     { :t "BWLPG" :v "26"}
     { :t "DNB" :v "19"}
     { :t "DNO" :v "20"}
     { :t "EQNR" :v "2"}
     { :t "GJF" :v "21"}
     { :t "GOGL" :v "28"}
     { :t "NHY" :v "1"}
     { :t "NAS" :v "29"}
     { :t "OBX" :v "7"}
     { :t "ORK" :v "9"}
     { :t "STB" :v "14"}
     { :t "SUBC" :v "23"}
     { :t "TEL" :v "6"}
     { :t "TGS" :v "16"}
     { :t "TOM" :v "17"}
     { :t  "YAR" :v "3"}])

(def label-class "ps-label ps-mr-1")

(comment selects  
  @[{ :name "pageSelect" 
      :title "Page"
      :evt "PageChange"
      :options [{:v "calls" :t "Calls" :f true} {:v "puts" :t "Puts"}]
      :disabled "false"
      :lc label-class
      :skip-no-sel true} 
    { :name "tickerSelect" 
      :title "Ticker"
      :evt "TickerChange"
      :options tickers
      :lc label-class
      :disabled "false"}])

(def calls-puts [{:v "calls" :t "Calls" :f true} {:v "puts" :t "Puts"}])

(def selects
  @[(sel2/params "pageSelect" "Risc" "PageChange" calls-puts :skip-no-sel true)
    (sel2/params "tickerSelect" "Ticker" "TickerChange" tickers)])

(def btn-class "ps-mr-1 ps-mt-24 ps-btn btn btn-outline-success")

(def buttons 
  @[{ :evt "CalcRisc"
       :title "Calc Risc"
       :disabled "false"
       :class btn-class
       :name "calcRisc"}])


(def modal-inp-class "form-control")

(def modal-label-class "ps-label ps-mb-1")

(comment inputs
  @[{ :name "inpRisc"
      :type :num
      :title "Risc"
      :evt "RiscChange" 
      :lc label-class
      :disabled false 
      :class "form-control ps-input ps-mt-auto"
      :p1 ["val" "Maybe Number"]}
    { :name "purchaseVolume"
      :type :int
      :title "Volume"
      :evt "(PDA <<< XVolume)" 
      :lc modal-label-class 
      :disabled false 
      :class modal-inp-class  
      :p1 ["val" "Maybe Int"]}])

(def inputs
  @[(inp/params "inpRisc" "Risc" :t :num :e "RiscChange")
    (inp/params "purchaseVolume" "Volume" :t :int :e "(PDA <<< XVolume)" :lc modal-label-class)])

(def checkbox
  @[{ :name "ivCheck" :id "ivcheck" :evt "IvChecked" :title "Only iv > 0.0" :cl-div "form-check form-switch ps-mt-24 ps-mr-1"}
    { :name "calcRiscOnSelectedCheck" :id "calcriscselected" :evt "CalcRiscSelectedChecked" :title "Calc risc on selected" :cl-div "form-check form-switch ps-mt-24"}])

(def main-action "MainAction")

# (def fname "/home/rcs/opt/java/harborview3/purescript/derivatives/src/Derivatives/UI.purs")
(def fname (c/localized "maunaloa/src/Maunaloa/UI.purs"))

(defn mk-output-fn1 [&opt f]
  (if f 
     (partial c/write-result f)
     c/prn-result))

(defn mk-output-fn2 [&opt f]
  (if f
    (let [wr-fn (partial c/write-result f)]
      (fn [b] (map wr-fn b)))
    (fn [b] (map c/prn-result b))))

(defn run1 [out-1 out-2]
  (map out-1 prelude)
  (cx/run checkbox main-action out-2)
  (inp/run inputs main-action out-2)
  (btn/run buttons main-action out-2)
  (sel2/run selects main-action out-2))

(defn run [console]
  (c/run console run1 fname))

