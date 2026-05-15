module Rapanui.State
  ( State
  , defaultState
  ) where

import Halogen.Subscription (Emitter)
import Data.Maybe (Maybe(..))
import Halogen (SubscriptionId)
import HarborView.ModalDialog (ModalState(..))
import Rapanui.Critter.Rules (StockOptionPurchase)
import Rapanui.Common (MainAction,Log)
import Rapanui.StockMarket.OptionSaleItem (OptionSale)


--import Prelude

type State =
  { stockOptions :: Array StockOptionPurchase
  , tickCounter :: Int
  , interval :: Maybe Number
  , subId :: Maybe SubscriptionId
  , emitter :: Maybe (Emitter MainAction)
  , modalStateBottom :: ModalState
  , optionSales :: Array OptionSale
  , logs :: Array Log
  }

defaultState :: State
defaultState =
  { stockOptions: []
  , tickCounter: 0
  , interval: Just 300.0 -- seconds ie 5 minutes
  , subId: Nothing
  , emitter: Nothing
  , modalStateBottom: ModalHidden
  , optionSales: []
  , logs: []
  }

--instance Show State where
--  show st = "(State " <> show st.stockOptions <> show st.tickDemo <> ")"
