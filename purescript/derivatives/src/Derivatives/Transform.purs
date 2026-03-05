module Derivatives.Transform
  where

import Prelude

import Data.FunctorWithIndex (mapWithIndex)
import Derivatives.Response (StockAndOptionsResponse, Derivative)
import Derivatives.Table.Table (TableItem)

mapOption :: Int -> Derivative -> TableItem
mapOption index d =
  let
    curLnr = index + 1
    --selected = if curLnr == 4 || curLnr == 7 || curLnr == 10 then true else false
  in
  { lnr: curLnr
    , selected: false
    , ticker: d.ticker
    , days: d.days
    , bid: d.bid
    , ask: d.ask
    , spread: 0.0
    , ivBid: d.ivBid
    , ivAsk: d.ivAsk
    , breakEven: d.brEven
    , risc: 0.0
    , opAtRisc: 0.0
    , spAtRisc: 0.0
  }

transform :: StockAndOptionsResponse -> Array TableItem
transform response =
  mapWithIndex mapOption response.opx
