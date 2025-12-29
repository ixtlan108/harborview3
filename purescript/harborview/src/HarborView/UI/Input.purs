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
import Halogen.HTML (ClassName(..), HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML.Properties (IProp)
import HarborView.UI.Common (Title(..))
import Web.Event.Event (Event)

-- data InputVal
--   = InpS (Maybe String)
--   | InpDate
--   | InpNum (Maybe Number)
--   | InpI (Maybe Int)

-- type InputParamsx i =
--   { evt :: String -> i
--   , style :: Maybe Style
--   , inpClasses :: Array ClassName
--   , spanClasses :: Array ClassName
--   , disabled :: Boolean
--   , dateMax :: Maybe String
--   }

type InputParams i =
  { evt :: String -> i
  , clazz :: Array ClassName
  , disabled :: Boolean
  , placeholder :: Maybe String
  }

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
  , clazz :: Array ClassName
  | r
  }
  -> Array
        (IProp
          ( class :: String
          , disabled :: Boolean
          , onChange :: Event
          , value :: String
          | r2
          )
          i
        )
defaultInputContent p =
  [ HE.onValueChange p.evt
  , HP.disabled p.disabled
  , HP.classes p.clazz
  ]
