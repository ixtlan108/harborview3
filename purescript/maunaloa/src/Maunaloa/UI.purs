module Maunaloa.UI
  where

import Prelude
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML (HTML, ClassName(..))
import Maunaloa.Actions (Action(..))


tickerSelect :: forall w. String -> HTML w Action
tickerSelect selected = 
  HH.span [ HP.classes [ ClassName "form-group" ]]
    [ HH.label [ HP.classes [ ClassName "ps-label ps-mr-1" ]]
      [ HH.text "", 
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
          , HE.onValueChange SelectChange
          , HP.disabled false ]
          opts
      ]
    ]
