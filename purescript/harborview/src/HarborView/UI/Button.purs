module HarborView.UI.Button
  ( ButtonParams
  , mkButton
  ) where

import Web.UIEvent.MouseEvent (MouseEvent)
import Halogen.HTML (ClassName, HTML)
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import HarborView.UI.Common (Title(..))

--import Prelude

type ButtonParams i =
  { title :: Title
  , evt :: MouseEvent -> i
  , btnClazz :: Array ClassName
  , disabled :: Boolean
  }

mkButton :: forall w i. ButtonParams i -> HTML w i
mkButton p =
  let
    Title t = p.title
  in
    HH.button
      [ HE.onClick p.evt
      , HP.disabled p.disabled
      , HP.classes p.btnClazz
      ]
      [ HH.text t ]

-- type TextAreaParams i =
--   { title :: Title
--   , evt :: String -> i
--   , rows :: Int
--   , cols :: Int
--   , text :: String
--   , placeholder :: String
--   , lblClazz :: Array ClassName
--   , spanClazz :: Array ClassName
--   , txClazz :: Array ClassName
--   }