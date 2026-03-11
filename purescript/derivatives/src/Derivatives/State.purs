module Derivatives.State
  where

import Data.Maybe (Maybe(..))
import HarborView.Common (StockTicker, Amount)
import HarborView.ModalDialog (DialogState(..), ModalState(..))
import Derivatives.Types (Page(..), Risc)
import Derivatives.Table.TableItem (TableItem)
import Derivatives.Table.SortField (SortField(..))


type State =
  { page :: Page
    , ticker :: Maybe StockTicker
    , risc :: Maybe Risc
    , opx :: Array TableItem
    , sortField :: SortField
    , sortOrderAsc :: Boolean
    , ivNotZero :: Boolean
    , calcRiscSelected :: Boolean
    , modalPurchase :: DialogState
    , purchaseItem :: Maybe TableItem
    , volume :: Maybe Amount
  }

defaultState :: State
defaultState =
  { page: Calls
    , ticker: Nothing
    , risc: Nothing
    , opx: []
    , sortField: SfNone
    , sortOrderAsc: false
    , ivNotZero: false
    , calcRiscSelected: false
    , modalPurchase: DialogHidden
    , purchaseItem: Nothing 
    , volume: Nothing
  }
