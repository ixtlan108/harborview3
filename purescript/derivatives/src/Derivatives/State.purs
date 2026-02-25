module Derivatives.State
  where

import Data.Maybe (Maybe(..))
import HarborView.Common (StockTicker)
import Derivatives.Types (Page(..))

type State =
  { page :: Page
    , ticker :: Maybe StockTicker
    , risc :: Maybe Number
  }

defaultState :: State
defaultState =
  { page: Calls
    , ticker: Nothing
    , risc: Nothing
  }
