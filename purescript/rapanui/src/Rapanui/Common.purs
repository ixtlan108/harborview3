module Rapanui.Common
  ( AccVal(..)
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

derive instance genericOptionTicker :: Generic OptionTicker _
instance Show OptionTicker where
  show = genericShow

-- newtype StockTicker = StockTicker String deriving (Eq,Show,Generic)

newtype Oid = Oid Int

derive instance genericOid :: Generic Oid _
instance Show Oid where
  show = genericShow

newtype Pid = Pid Int

derive instance genericPid :: Generic Pid _
instance Show Pid where
  show = genericShow

newtype Cid = Cid Int

derive instance Eq Cid

derive instance genericCid :: Generic Cid _
instance Show Cid where
  show = genericShow

newtype Rtyp = Rtyp Int

derive instance genericRtyp :: Generic Rtyp _
instance Show Rtyp where
  show = genericShow

newtype CritterType = CritterType String

newtype NordnetHost = NordnetHost String

newtype NordnetPort = NordnetPort Int

newtype AccVal = AccVal Number

--derive instance Eq Bid

newtype Bid = Bid Number

derive instance Eq Bid

derive instance genericBid :: Generic Bid _
instance Show Bid where
  show = genericShow

newtype Ask = Ask Number

newtype Status = Status Int

newtype Msg = Msg String

newtype PosixTimeInt = PosixTimeInt Int

newtype Iso8601 = Iso8601 String

--newtype MarketOpen = MarketOpen TimeOfDay deriving (Show)

--newtype MarketClose = MarketClose TimeOfDay deriving (Show)
