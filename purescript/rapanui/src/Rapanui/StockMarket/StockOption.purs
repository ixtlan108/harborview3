module Rapanui.StockMarket.StockOption where

-- import Prelude

import Rapanui.Common (Bid,Ask,Status,Msg)

type StockOptionItem =
  { bid :: Bid
  , ask :: Ask
  }

type StockOption =
  { option :: StockOptionItem
  , status :: Status
  , msg :: Msg
  }
