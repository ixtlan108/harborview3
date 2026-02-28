module Derivatives.State
  where

import Data.Maybe (Maybe(..))
import HarborView.Common (StockTicker(..))
import Derivatives.Types (Page(..), Risc)
import Derivatives.Table.Table (TableItem)
import Derivatives.Table.SortField (SortField(..))


type State =
  { page :: Page
    , ticker :: Maybe StockTicker
    , risc :: Maybe Risc
    , opx :: Array TableItem
    , sortField :: SortField
    , sortOrderAsc :: Boolean
  }

defaultState :: State
defaultState =
  { page: Puts
    , ticker: Just (StockTicker 28)
    , risc: Nothing
    , opx: []
    , sortField: SfNone
    , sortOrderAsc: false
  }
