module HarborView.UI.Radio
  ( RadioBtn
  , RadioGroupParam
  , mkRadioGroup
  ) where

import Prelude

import DOM.HTML.Indexed.InputType (InputType(..))
import Halogen.HTML (AttrName(..), ClassName(..), HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import HarborView.UI.Common (Title(..), HtmlId)
import Web.UIEvent.MouseEvent (MouseEvent)

type RadioBtn i =
  { val :: String
  , id :: HtmlId
  , evt :: (MouseEvent -> i)
  }

type RadioGroupParam i =
  { title :: Title
  , group :: String
  , btns :: Array (RadioBtn i)
  }

-- mkRadioBtn :: forall w i. String -> (RadioBtn i) -> HTML w i
-- mkRadioBtn group btn =
--   let
--     HtmlId btnId = btn.id
--   in
--     HH.div [ HP.classes [ ClassName "form-control"] ]
--       [ HH.input
--           [ HP.type_ InputRadio
--           , HP.attr (AttrName "name") group
--           , HP.id btnId
--           , HP.value btn.val
--           , HE.onClick btn.evt
--           ]
--       , HH.label
--           [ HP.attr (AttrName "for") btnId
--           ]
--           [ HH.text btn.val ]
--       ]

mkRadioBtn :: forall w i. String -> (RadioBtn i) -> HTML w i
mkRadioBtn group btn =
  HH.label [ HP.style "margin-right:1.5rem", HP.classes [ ClassName "radio-inline" ] ]
    [ HH.input
        [ HP.type_ InputRadio
        , HP.style "margin-right:0.5rem"
        , HP.attr (AttrName "name") group
        , HP.value btn.val
        , HE.onClick btn.evt
        ]
    , HH.text btn.val
    ]

mkRadioGroup :: forall w i. RadioGroupParam i -> HTML w i
mkRadioGroup p =
  let
    radios = map (mkRadioBtn p.group) p.btns
    Title t = p.title
  in
    HH.div_
      [ HH.label [] [ HH.text t ]
      , HH.form_ radios
      ]
