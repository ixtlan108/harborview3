module Derivatives.Types
  where

import Prelude

--------------- Page ---------------

data Page =
  Calls
  | Puts

fromString :: String -> Page
fromString "calls" = Calls
fromString _ = Puts

instance Show Page where
  show Calls = "calls"
  show Puts = "puts"

--------------- Risc ---------------

newtype Risc = Risc Number
