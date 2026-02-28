module Derivatives.Transform
  where

import Prelude

import Data.FunctorWithIndex (mapWithIndex)
import Derivatives.Response (StockAndOptionsResponse, Derivative)
import Derivatives.Table.Table (TableItem)

mapOption :: Int -> Derivative -> TableItem
mapOption index d =
  { lnr: index + 1
    , selected: false
    , ticker: d.ticker
    , days: d.days
    , bid: d.bid
    , ask: d.ask
    , spread: 0.0
    , ivBid: d.ivBid
    , ivAsk: d.ivAsk
    , breakEven: d.brEven
    , risc: 3.0
    , opAtRisc: 1.0
    , spAtRisc: 432.0
  }

transform :: StockAndOptionsResponse -> Array TableItem
transform response =
  mapWithIndex mapOption response.opx
