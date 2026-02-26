module Derivatives.State
  where

import Data.Maybe (Maybe(..))
import HarborView.Common (StockTicker(..))
import Derivatives.Types (Page(..), Risc)

type State =
  { page :: Page
    , ticker :: Maybe StockTicker
    , risc :: Maybe Risc
  }

defaultState :: State
defaultState =
  { page: Puts
    , ticker: Just (StockTicker 28)
    , risc: Nothing
  }
