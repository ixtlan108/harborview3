module HarborView.UI.Text
  ( HSize(..)
  , mkH
  ) where

import Data.Maybe (Maybe(..))
import Halogen.HTML (ClassName(..), HTML)
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import HarborView.UI.Common (Style(..))

--import Prelude

data HSize
  = H5
  | H6

mkH :: forall w i. HSize -> String -> Maybe Style -> HTML w i
mkH H5 t style =
  case style of
    Nothing ->
      HH.h5 [ HP.classes [ ClassName "ps-h" ] ] [ HH.text t ]
    Just (Style s) ->
      HH.h5 [ HP.style s, HP.classes [ ClassName "ps-h" ] ] [ HH.text t ]
mkH H6 t style =
  case style of
    Nothing ->
      HH.h6 [ HP.classes [ ClassName "ps-h" ] ] [ HH.text t ]
    Just (Style s) ->
      HH.h6 [ HP.style s, HP.classes [ ClassName "ps-h" ] ] [ HH.text t ]
