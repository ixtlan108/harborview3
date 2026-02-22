module Rapanui.UI
  where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Array ((:))
import DOM.HTML.Indexed.InputType (InputType(..))
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML.Events as HE
import Halogen.HTML (HTML, ClassName(..))
import Rapanui.Common (MainAction(..))


fetchPurchases :: forall w. HTML w MainAction
fetchPurchases =
  HH.button [HE.onClick FetchPurchases, HP.classes [ ClassName "ps-mr-1 ps-btn btn btn-outline-success"]] [HH.text "Fetch Purchases"]

startTimer :: forall w. HTML w MainAction
startTimer =
  HH.button [HE.onClick (Timer true), HP.classes [ ClassName "ps-mr-1 ps-btn btn btn-outline-success"]] [HH.text "Start Timer"]

stopTimer :: forall w. HTML w MainAction
stopTimer =
  HH.button [HE.onClick (Timer false), HP.classes [ ClassName "ps-mr-1 ps-btn btn btn-outline-success"]] [HH.text "Stop Timer"]

clearLogs :: forall w. HTML w MainAction
clearLogs =
  HH.button [HE.onClick ClearLogs, HP.classes [ ClassName "ps-mr-1 ps-btn btn btn-outline-success"]] [HH.text "Clear Logs"]

inpInterval :: forall w. Maybe Number -> HTML w MainAction
inpInterval val =
  HH.span [ HP.classes [ ClassName "form-group" ]]
    [ HH.label [ HP.classes [ ClassName "ps-label ps-mr-1" ]]
      [ HH.text "Interval",
        case val of
          Nothing ->
            HH.input [HP.type_ InputNumber, HP.classes [ ClassName "form-control ps-input" ], HE.onValueChange IntervalChange]
          Just val1 ->
            HH.input [HP.type_ InputNumber, HP.classes [ ClassName "form-control ps-input" ], HE.onValueChange IntervalChange, HP.value (show val1)]
      ]
    ]

inpTick :: forall w. Maybe Int -> HTML w MainAction
inpTick val =
  HH.span [ HP.classes [ ClassName "form-group" ]]
    [ HH.label [ HP.classes [ ClassName "ps-label ps-mr-1" ]]
      [ HH.text "Tick",
        case val of
          Nothing ->
            HH.input [HP.type_ InputNumber, HP.classes [ ClassName "form-control ps-input" ]]
          Just val1 ->
            HH.input [HP.type_ InputNumber, HP.classes [ ClassName "form-control ps-input" ], HP.value (show val1)]
      ]
    ]
