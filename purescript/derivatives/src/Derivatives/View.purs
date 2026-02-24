module Options.View where

import Prelude

import Halogen as H
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import Halogen.HTML
  ( HTML
  , ClassName(..)
  )
import Halogen.HTML.Events as HE
import HarborView.UI as UI
import HarborView.UI (SelectItems)

type State =
  { tickers :: SelectItems
  }

data Action = SelectChange String

render :: forall cs m. State -> H.ComponentHTML Action cs m
render st =
  let
    tickers = UI.mkSelect_ st.tickers SelectChange
  in
    HH.div [] []
