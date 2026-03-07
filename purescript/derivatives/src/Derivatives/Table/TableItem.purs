module Derivatives.Table.TableItem
  where

type TableItem =
  { lnr :: Int
    , selected :: Boolean
    , ticker :: String
    , days :: Int
    , bid :: Number
    , ask :: Number
    , spread :: Number
    , ivBid :: Number
    , ivAsk :: Number
    , breakEven :: Number
    , risc :: Number
    , opAtRisc :: Number
    , spAtRisc :: Number
  }
