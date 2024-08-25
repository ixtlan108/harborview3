module HarborView.UI.Input
  ( InputParams
    , mkInputWrapper
    , mkInputStr
    , mkInputInt
    , mkInputNum
    --, mkInputDate
  ) where

import Prelude

import DOM.HTML.Indexed.InputType (InputType(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Array ((:))
import Halogen.HTML (AttrName(..), ClassName(..), HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML.Properties (IProp)
import HarborView.UI.Common (Title(..), Style(..))
import Web.Event.Event (Event)

-- data InputVal
--   = InpS (Maybe String)
--   | InpDate
--   | InpNum (Maybe Number)
--   | InpI (Maybe Int)

type InputParams i =
  { evt :: String -> i
  , style :: Maybe Style
  , inpClasses :: Array ClassName
  , spanClasses :: Array ClassName
  , disabled :: Boolean
  , dateMax :: Maybe String
  }

-- mkInput_ :: forall w i. InputParams i -> HTML w i
-- mkInput_ p =
--   let
--     content =
--       [ HE.onValueChange p.evt
--       , HP.disabled p.disabled
--       , HP.classes p.inpClasses
--       , HE.onValueChange p.evt
--       ]
--   in
--     case p.inpVal of
--       InpS s ->
--         case s of
--           Nothing ->
--             HH.input (HP.type_ InputText : content)
--           Just s1 ->
--             HH.input (HP.type_ InputText : HP.value s1 : content)
--       InpDate ->
--         HH.input (HP.attr (AttrName "max") p.dateMax : HP.type_ InputDate : content)
--       InpNum num ->
--         case num of
--           Nothing ->
--             HH.input (HP.type_ InputNumber : content)
--           Just num1 ->
--             HH.input (HP.type_ InputNumber : HP.value (show num1) : content)
--       InpI num ->
--         case num of
--           Nothing ->
--             HH.input (HP.type_ InputNumber : content)
--           Just num1 ->
--             HH.input (HP.type_ InputNumber : HP.value (show num1) : content)

-- mkInput :: forall w i. InputParams i -> HTML w i
-- mkInput p =
--   let
--     Title t = p.title
--     inp = mkInput_ p
--   in
--     HH.span [ HP.classes [ ClassName "form-group" ] ]
--       [ HH.label [ HP.classes p.lblClasses ] [ HH.text t ]
--       , inp
--       ]
--
mkInputStr :: forall w i. Maybe String -> InputParams i -> HTML w i
mkInputStr val p =
  case val of
    Nothing ->
      HH.input (HP.type_ InputText : defaultInputContent p)
    Just s ->
      HH.input (HP.type_ InputText : HP.value s : defaultInputContent p)

mkInputNum :: forall w i. Maybe Number -> InputParams i -> HTML w i
mkInputNum val p =
  let
    s = fromMaybe 0.0 val
  in
    HH.input (HP.type_ InputNumber : HP.value (show s) : defaultInputContent p)

mkInputInt :: forall w i. Maybe Int -> InputParams i -> HTML w i
mkInputInt val p =
  case val of
    Nothing ->
      HH.input (HP.type_ InputNumber : defaultInputContent p)
    Just ival ->
      HH.input (HP.type_ InputNumber : HP.value (show ival) : defaultInputContent p)


-- mkInputDate :: forall w i. Maybe String -> InputParams i -> HTML w i
-- mkInputDate val p =
--   let
--     dmx =
--       case p.dateMax of
--             Nothing ->
--               DU.todayStr
--             Just dmx1 ->
--               dmx1
--   in
--   case val of
--     Nothing ->
--       HH.input (HP.attr (AttrName "max") dmx : HP.type_ InputDate : defaultInputContent p)
--     Just s ->
--       HH.input (HP.attr (AttrName "max") dmx : HP.value s : HP.type_ InputDate : defaultInputContent p)

mkInputWrapper :: forall w i. Title -> Array ClassName -> HTML w i-> HTML w i
mkInputWrapper title clazz inp =
  let
    Title t = title
  in
  HH.span [ HP.classes [ ClassName "form-group" ] ]
    [ HH.label [ HP.classes clazz ] [ HH.text t ]
    , inp
    ]

defaultInputContent ::
  forall r i r2.
  { disabled :: Boolean
  , evt :: String -> i
  , inpClasses :: Array ClassName
  , style :: Maybe Style
  | r
  }
  -> Array
        (IProp
          ( class :: String
          , disabled :: Boolean
          , onChange :: Event
          , style :: String
          , value :: String
          | r2
          )
          i
        )
defaultInputContent p =
  case p.style of
    Nothing ->
      [ HE.onValueChange p.evt
      , HP.disabled p.disabled
      , HP.classes p.inpClasses
      ]
    Just (Style sty) ->
      [ HE.onValueChange p.evt
      , HP.disabled p.disabled
      , HP.classes p.inpClasses
      , HP.style sty
      ]
