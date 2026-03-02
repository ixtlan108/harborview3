module Derivatives.UI
  where

import Prelude
import Data.Maybe (Maybe(..))
import DOM.HTML.Indexed.InputType (InputType(..))
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML (HTML, ClassName(..))
import Derivatives.Actions (MainAction(..))


ivCheck :: forall w. Boolean -> HTML w MainAction
ivCheck isChecked = 
  HH.div [ HP.classes [ ClassName "form-check form-switch ps-mt-24 ps-mr-1" ]]
    [ HH.input [HP.type_ InputCheckbox, HP.id "ivcheck", HP.classes [ ClassName "form-check-input" ], HP.checked isChecked, HE.onChecked IvChecked ]
    , HH.label [ HP.classes [ClassName "form-check-label" ], HP.for "ivcheck"] [ HH.text "Only iv > 0.0"]
    ]

calcRiscOnSelectedCheck :: forall w. Boolean -> HTML w MainAction
calcRiscOnSelectedCheck isChecked = 
  HH.div [ HP.classes [ ClassName "form-check form-switch ps-mt-24" ]]
    [ HH.input [HP.type_ InputCheckbox, HP.id "calcriscselected", HP.classes [ ClassName "form-check-input" ], HP.checked isChecked, HE.onChecked CalcRiscSelectedChecked ]
    , HH.label [ HP.classes [ClassName "form-check-label" ], HP.for "calcriscselected"] [ HH.text "Calc risc on selected"]
    ]

inpRisc :: forall w. Maybe Number -> HTML w MainAction
inpRisc val =
  HH.span [ HP.classes [ ClassName "form-group" ]]
    [ HH.label [ HP.classes [ ClassName "ps-label ps-mr-1" ]]
      [ HH.text "Risc", 
        case val of
          Nothing ->
            HH.input [HP.type_ InputNumber, HP.classes [ ClassName "form-control ps-input ps-mt-auto" ], HE.onValueChange RiscChange]
          Just val1 ->
            HH.input [HP.type_ InputNumber, HP.classes [ ClassName "form-control ps-input ps-mt-auto" ], HE.onValueChange RiscChange, HP.value (show val1)]
      ]
    ]

calcRisc :: forall w. HTML w MainAction
calcRisc =
  HH.button [HE.onClick CalcRisc, HP.classes [ ClassName "ps-mr-1 ps-mt-24 ps-btn btn btn-outline-success"]] [HH.text "Calc Risc"]

pageSelect :: forall w. String -> HTML w MainAction
pageSelect selected = 
  HH.span [ HP.classes [ ClassName "form-group" ]]
    [ HH.label [ HP.classes [ ClassName "ps-label ps-mr-1" ]]
      [ HH.text "Page", 
        let
          opts = 
            [
              HH.option
                [ HP.value "calls"
                , HP.selected ("calls" == selected)]
                [ HH.text "Calls"]
              , HH.option
                 [ HP.value "puts"
                 , HP.selected ("puts" == selected)]
                 [ HH.text "Puts"]
            ]
        in
        HH.select
          [ HP.classes [ ClassName "form-control ps-select" ]
          , HE.onValueChange PageChange
          , HP.disabled false ]
          opts
      ]
    ]

tickerSelect :: forall w. String -> HTML w MainAction
tickerSelect selected = 
  HH.span [ HP.classes [ ClassName "form-group" ]]
    [ HH.label [ HP.classes [ ClassName "ps-label ps-mr-1" ]]
      [ HH.text "Ticker", 
        let
          opts = 
            [
              HH.option
                [ HP.value "-"
                , HP.selected ("-" == selected)]
                [ HH.text "-"]
              , HH.option
                 [ HP.value "18"
                 , HP.selected ("18" == selected)]
                 [ HH.text "AKSO"]
              , HH.option
                 [ HP.value "27"
                 , HP.selected ("27" == selected)]
                 [ HH.text "BAKKA"]
              , HH.option
                 [ HP.value "26"
                 , HP.selected ("26" == selected)]
                 [ HH.text "BWLPG"]
              , HH.option
                 [ HP.value "19"
                 , HP.selected ("19" == selected)]
                 [ HH.text "DNB"]
              , HH.option
                 [ HP.value "20"
                 , HP.selected ("20" == selected)]
                 [ HH.text "DNO"]
              , HH.option
                 [ HP.value "2"
                 , HP.selected ("2" == selected)]
                 [ HH.text "EQNR"]
              , HH.option
                 [ HP.value "21"
                 , HP.selected ("21" == selected)]
                 [ HH.text "GJF"]
              , HH.option
                 [ HP.value "28"
                 , HP.selected ("28" == selected)]
                 [ HH.text "GOGL"]
              , HH.option
                 [ HP.value "1"
                 , HP.selected ("1" == selected)]
                 [ HH.text "NHY"]
              , HH.option
                 [ HP.value "29"
                 , HP.selected ("29" == selected)]
                 [ HH.text "NAS"]
              , HH.option
                 [ HP.value "7"
                 , HP.selected ("7" == selected)]
                 [ HH.text "OBX"]
              , HH.option
                 [ HP.value "9"
                 , HP.selected ("9" == selected)]
                 [ HH.text "ORK"]
              , HH.option
                 [ HP.value "14"
                 , HP.selected ("14" == selected)]
                 [ HH.text "STB"]
              , HH.option
                 [ HP.value "23"
                 , HP.selected ("23" == selected)]
                 [ HH.text "SUBC"]
              , HH.option
                 [ HP.value "6"
                 , HP.selected ("6" == selected)]
                 [ HH.text "TEL"]
              , HH.option
                 [ HP.value "16"
                 , HP.selected ("16" == selected)]
                 [ HH.text "TGS"]
              , HH.option
                 [ HP.value "17"
                 , HP.selected ("17" == selected)]
                 [ HH.text "TOM"]
              , HH.option
                 [ HP.value "3"
                 , HP.selected ("3" == selected)]
                 [ HH.text "YAR"]
            ]
        in
        HH.select
          [ HP.classes [ ClassName "form-control ps-select" ]
          , HE.onValueChange TickerChange
          , HP.disabled false ]
          opts
      ]
    ]
