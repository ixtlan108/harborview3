module Rapanui.StockMarket.StockOption where

-- import Prelude

import Rapanui.Common (Bid,Ask,Spot,Status,Msg)

type StockOptionItem =
  { bid :: Bid
  , ask :: Ask
  }

type StockOption =
  { spot :: Spot
  , option :: StockOptionItem
  , optionStatus :: Status
  , msg :: Msg
  }
