module Derivatives.Table.SortField
  where

import Prelude (class Eq)

data SortField
  = SfTicker
  | SfIvBid
  | SfIvAsk

derive instance Eq SortField

{-
, Table.stringColumn "Ticker" .ticker
, Table.floatColumn "Exercise" .x
, Table.floatColumn "Days" .days
, Table.floatColumn "Bid" .buy
, Table.floatColumn "Ask" .sell
, Table.floatColumn "Spread" .spread
, Table.floatColumn "IvBid" .ivBuy
, Table.floatColumn "IvAsk" .ivSell
, Table.floatColumn "Break-Even" .breakEven
, Table.floatColumn "Risc" .risc
, Table.floatColumn "O.P. at Risc" .optionPriceAtRisc
, Table.floatColumn "S.P. at Risc" .stockPriceAtRisc
-}
