module HarborView.UI.Select
  ( SelectItem
  , SelectItems
  , SelectParams
  , mkSelect
  ) where

import Data.Array ((:))
import Halogen.HTML (ClassName, HTML)
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import HarborView.UI.Common (Title(..))

import Prelude

type SelectItem =
  { v :: String
  , t :: String
  }

type SelectItems = Array SelectItem

emptySelectItem :: SelectItem
emptySelectItem = { v: "0", t: "-" }

mkOption :: forall w i. String -> SelectItem -> HTML w i
mkOption selected item =
  HH.option
    [ HP.value item.v
    , HP.selected (item.v == selected)
    ]
    [ HH.text item.t ]

type SelectParams i =
  { title :: Title
  , items :: SelectItems
  , evt :: String -> i
  , selected :: String
  , selClazz :: Array ClassName
  , lblClazz :: Array ClassName
  , spanClazz :: Array ClassName
  , disabled :: Boolean
  }

mkSelect_
  :: forall w i r
   . { items :: SelectItems
     , evt :: (String -> i)
     , selected :: String
     , disabled :: Boolean
     , selClazz :: Array ClassName
     | r
     }
  -> HTML w i
mkSelect_ p =
  let
    opts = map (mkOption p.selected) (emptySelectItem : p.items)
  in
    HH.select
      [ HP.classes p.selClazz
      , HE.onValueChange p.evt
      , HP.disabled p.disabled
      ]
      opts

mkSelect :: forall w i. SelectParams i -> HTML w i
mkSelect p =
  let
    Title t = p.title
    sel = mkSelect_ p
  in
    HH.span [ HP.classes p.spanClazz ]
      [ HH.label [ HP.classes p.lblClazz ] [ HH.text t ]
      , sel
      ]