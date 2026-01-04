module Rapanui.Critter.Rules where

import Rapanui.Common (Cid, Oid, Ask, OptionTicker, Pid, Rtyp)

-- data Rtyp =
--   DIFF_WATERMARK    -- 1
--   DIFF_BOUGHT       -- 7
--   OPX_ROOF          -- Option price roof (valid if below option price)

--import Prelude
type AcceptRule =
  { oid :: Oid
  , pid :: Pid
  , cid :: Cid
  , rtyp :: Rtyp
  , value :: Number
  , active :: Boolean
  }

type Critter =
  { oid :: Oid
  , vol :: Int
  , status :: Int
  , accRules :: Array AcceptRule
  }

type StockOptionPurchase =
  { ticker :: OptionTicker
  , oid :: Oid
  , price :: Ask
  , critters :: Array Critter
  , isSold :: Boolean
  }

--derive instance genericSomeType :: Generic StockOptionPurchase _

--instance showStockOptionPurchase :: Show StockOptionPurchase where
--  show = genericShow
