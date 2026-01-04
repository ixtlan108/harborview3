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
  , Status(..)
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
  | Noop String
  | IntervalChange String
  | ModalDialogBottomClose MouseEvent

newtype OptionTicker = OptionTicker String

derive instance Generic OptionTicker _
instance Show OptionTicker where
  show = genericShow

-- newtype StockTicker = StockTicker String deriving (Eq,Show,Generic)

newtype Oid = Oid Int

derive instance Generic Oid _
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

--newtype MarketOpen = MarketOpen TimeOfDay deriving (Show)

--newtype MarketClose = MarketClose TimeOfDay deriving (Show)
