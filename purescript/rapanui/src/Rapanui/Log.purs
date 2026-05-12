module Rapanui.Log
  where

import Rapanui.Common (OptionTicker(..), Cid(..), Bid(..), Oid(..))

type Log =
  { oid :: Oid
  , cid :: Cid
  , log :: String
  }
