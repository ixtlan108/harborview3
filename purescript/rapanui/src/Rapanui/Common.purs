module Rapanui.Common
  ( AccVal(..)
  , Spot(..)
  , Ask(..)
  , Bid(..)
  , Cid(..)
  , CritterType(..)
  , Iso8601(..)
  , MainAction(..)
  , Msg(..)
  , NordnetHost(..)
  , NordnetPort(..)
  , Oid(..)
  , OptionTicker(..)
  , Pid(..)
  , PosixTimeInt(..)
  , Rtyp(..)
  , StatusCode(..)
  , Status(..)
  , Log
  , rtypDesc
  ) where

-- import Prelude

import Data.Eq (class Eq)
import Data.Show (class Show)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Web.UIEvent.MouseEvent (MouseEvent)

data MainAction
  = Initialize
  | FetchPurchases MouseEvent
  | Timer Boolean MouseEvent
  | IsActive Int Boolean
  | Tick
  | IntervalChange String
  | ModalDialogBottomClose MouseEvent
  | ClearLogs MouseEvent

newtype OptionTicker = OptionTicker String

derive instance Generic OptionTicker _

instance Show OptionTicker where
  show = genericShow

-- newtype StockTicker = StockTicker String deriving (Eq,Show,Generic)

newtype Oid = Oid Int

derive instance Generic Oid _

derive instance Eq Oid

instance Show Oid where
  show = genericShow

newtype Pid = Pid Int

derive instance Generic Pid _

instance Show Pid where
  show = genericShow

newtype Cid = Cid Int

derive instance Eq Cid

derive instance Generic Cid _

instance Show Cid where
  show = genericShow

-- newtype SaleAmount = SaleAmount Int

-- derive instance Eq SaleAmount

-- derive instance Generic SaleAmount _
-- instance Show SaleAmount where
--   show = genericShow

-- newtype Rtyp = Rtyp Int

data StatusCode =
   TRUE_ACTIVE                -- 1 | True/active/valid
   | FALSE_INACTIVE           -- 0 | False/inact./invalid
   | CRITTER_ACTIVE           -- 7 | Critter active
   | CRITTER_INACTIVE         -- 8 | Critter inactive
   | OPTION_TEST_PURCHASE     -- 4 | Option test purchase
   | OPTION_PURCHASE          -- 3 | Option purchase
   | OPTION_PAPER_PURCH       -- 11 | Option paper purch.
   | CRITTER_SOLD             -- 9 | Critter sold
   | OPTION_FULLY_SOLD        -- 2 | Option fully sold
   | SNA

derive instance Eq StatusCode

derive instance Generic StatusCode _

instance Show StatusCode where
  show = genericShow

data Rtyp =
  DIFF_WATERMARK        -- 1 |
  | DIFF_BOUGHT         -- 7 |
  | OPTION_PRICE_ROOF   -- 6 | Option price roof (valid if below option price)
  | OPTION_PRICE_FLOOR  -- 5 | Option price floor (valid if above option price)
  | STOCK_PRICE_ROOF    -- 4 | Stock price roof (valid if below stock price)
  | STOCK_PRICE_FLOOR   -- 3 | Stock price floor (valid if above stock price)
  | NA

derive instance Generic Rtyp _

instance Show Rtyp where
  show = genericShow


rtypDesc :: Rtyp -> String
rtypDesc r =
  case r of
    DIFF_WATERMARK -> "Diff > last watermark by value"
    DIFF_BOUGHT -> "Diff Bid Ask > acc. value"
    OPTION_PRICE_ROOF -> "Option price roof (valid if below option price)"
    OPTION_PRICE_FLOOR -> "Option price floor (valid if above option price)"
    STOCK_PRICE_ROOF -> "Stock price roof (valid if below stock price)"
    STOCK_PRICE_FLOOR -> "Stock price floor (valid if above stock price)"
    NA -> "N/A"

newtype CritterType = CritterType String

newtype NordnetHost = NordnetHost String

newtype NordnetPort = NordnetPort Int

newtype AccVal = AccVal Number

--derive instance Eq Bid

newtype Bid = Bid Number

derive instance Eq Bid

derive instance Generic Bid _

instance Show Bid where
  show = genericShow

newtype Spot = Spot Number

newtype Ask = Ask Number

newtype Status = Status Int

newtype Msg = Msg String

newtype PosixTimeInt = PosixTimeInt Int

newtype Iso8601 = Iso8601 String

type Log =
  { tick :: Int
  , tm :: String
  , oid :: String
  , cid :: String
  , log :: String
  }

--newtype MarketOpen = MarketOpen TimeOfDay deriving (Show)

--newtype MarketClose = MarketClose TimeOfDay deriving (Show)
