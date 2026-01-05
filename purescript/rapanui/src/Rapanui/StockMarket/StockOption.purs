module Rapanui.StockMarket.StockOption where

-- import Prelude

import Data.Maybe (Maybe)
import Rapanui.Common (Bid,Ask,Spot,Status,Msg)

type StockOptionItem =
  { bid :: Bid
  , ask :: Ask
  }

type StockOption =
  { spot :: Spot
  , option :: StockOptionItem
  , optionStatus :: Status
  , msg :: Maybe Msg
  }
