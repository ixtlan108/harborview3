module Rapanui.State
  ( State
  , defaultState
  ) where

import Halogen.Subscription (Emitter)
import Data.Maybe (Maybe(..))
import Halogen (SubscriptionId)
import Rapanui.Critter.Rules (StockOptionPurchase)
import Rapanui.Common (MainAction)

--import Prelude

type State =
  { stockOptions :: Array StockOptionPurchase
  , tickDemo :: Int
  , interval :: Maybe Number
  , subId :: Maybe SubscriptionId
  , emitter :: Maybe (Emitter MainAction)
  }

defaultState :: State
defaultState =
  { stockOptions: []
  , tickDemo: 0
  , interval: Just 300.0 -- seconds ie 5 minutes
  , subId: Nothing
  , emitter: Nothing
  }

--instance Show State where
--  show st = "(State " <> show st.stockOptions <> show st.tickDemo <> ")"
