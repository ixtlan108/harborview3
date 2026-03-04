module Derivatives.Types
  where

import Prelude

import Data.Tuple (Tuple)
import Data.Argonaut.Core (Json)
import HarborView.CommonJson as CJ

--------------- Page ---------------

data Page =
  Calls
  | Puts


derive instance Eq Page

fromString :: String -> Page
fromString "calls" = Calls
fromString _ = Puts

instance Show Page where
  show Calls = "calls"
  show Puts = "puts"

--------------- Risc ---------------

newtype Risc = Risc Number

--------------- Risc Request ---------------
type RiscRequest =
  { ticker :: String
    , risc :: Number
  }

toJson :: RiscRequest -> Array (Tuple String Json)
toJson risc =
  [ CJ.fromString "ticker" risc.ticker
   , CJ.fromNumber "risc" risc.risc
  ]
