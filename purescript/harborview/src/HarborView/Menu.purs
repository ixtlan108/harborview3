module HarborView.Menu
  where

import Prelude

import Halogen.HTML (ClassName(..), HTML)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

data ActivePage
  = Critters
  | Rapanui
  | Charts
  | Derivatives
  | Purchases


derive instance Eq ActivePage

mkMenu :: forall w action. ActivePage -> HTML w action
mkMenu ap =
  let
    critter = if ap == Critters then
      HH.a [ HP.href "/critter/overlook", HP.classes [ ClassName "menu--active" ]]
    else
      HH.a [ HP.href "/critter/overlook" ]
    rapanui = if ap == Rapanui then
      HH.a [ HP.href "/rapanui", HP.classes [ ClassName "menu--active" ]]
    else
      HH.a [ HP.href "/rapanui" ]
  in
  HH.div [ HP.classes [ ClassName "menu--header menu--header-x" ]]
    [ HH.ul [ HP.classes [ ClassName "menu--ul"]]
      [ HH.li [ HP.classes [ ClassName "menu--li" ]]
          [ critter
            [ HH.text "Critter"]
          ]
        , HH.li [ HP.classes [ ClassName "menu--li" ]]
            [ rapanui
              [ HH.text "Rapanui"]
            ]
        , HH.li [ HP.classes [ ClassName "menu--li menu--version" ]]
          [ HH.text "Ver. 0.9.76 2026-04-23" ]
        ]
    ]

-- mkMenu :: forall w action. ActivePage -> HTML w action
-- mkMenu ap =
--   let
--     home = if ap == Home then
--       HH.a [ HP.href "/registry", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/registry" ]
--     log = if ap == KlaxtonLog then
--       HH.a [ HP.href "/log", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/log" ]
--     measurements = if ap == Measurements then
--       HH.a [ HP.href "/measurements", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/measurements" ]
--     report = if ap == Report then
--       HH.a [ HP.href "/report", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/report" ]
--     camera = if ap == Camera then
--       HH.a [ HP.href "/camera", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/camera" ]
--     generator = if ap == Generator then
--       HH.a [ HP.href "/generator", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/generator" ]
--     printsInStock = if ap == PrintsInStock then
--       HH.a [ HP.href "/storageshelf", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/storageshelf" ]
--     customer = if ap == Customer then
--       HH.a [ HP.href "/customer", HP.classes [ ClassName "menu--active" ]]
--     else
--       HH.a [ HP.href "/customer" ]
--     transport =
--       HH.a [ HP.href "/head/select" ]
--     window1 =
--       HH.a [ HP.href "/riga" ]
--     storageSpace =
--       HH.a [ HP.href "/storageSpace" ]
--   in
--   HH.div [ HP.classes [ ClassName "menu--header menu--header-x" ]]
--     [ HH.ul [ HP.classes [ ClassName "menu--ul"]]
--       [
--       HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ home
--           [ HH.text "Registration"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ measurements
--           [ HH.text "Measurements"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ camera
--           [ HH.text "Camera"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ report
--           [ HH.text "Reports"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ generator
--           [ HH.text "Generator"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ log
--           [ HH.text "Log"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ printsInStock
--           [ HH.text "Prints in stock"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ customer
--           [ HH.text "Customer"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ transport
--           [ HH.text "Transport"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ storageSpace
--           [ HH.text "Storage Space"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li" ]]
--         [ window1
--           [ HH.text "Window 1"]
--         ]
--       , HH.li [ HP.classes [ ClassName "menu--li menu--version" ]]
--         [ HH.text "Ver. 0.9.76 2026-04-23" ]
--       ]
--     ]
