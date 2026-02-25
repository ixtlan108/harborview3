module Derivatives.Types
  where

import Prelude

data Page =
  Calls
  | Puts

fromString :: String -> Page
fromString "calls" = Calls
fromString _ = Puts

instance Show Page where
  show Calls = "calls"
  show Puts = "puts"
