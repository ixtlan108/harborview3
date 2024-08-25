module Rapanui.Critter.CritterRule
  where

import Prelude

import Rapanui.Common (Ask)
import Rapanui.Critter.AcceptRule as A
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)
import Rapanui.Critter.Rules (Critter)


extractSale :: Array OptionSale -> OptionSale
extractSale sales =
  NoSale
{-
  let
    hits = [x | x@(Sale{}) <- sales] :: [OptionSale]
  in
    case hits of
      [] -> NoSale
      (x : _) -> x
-}

applyCritter :: Ask -> StockOption -> Critter -> OptionSale
applyCritter s o c =
  if c.status == 7
    then
      extractSale $ map (A.applyAcc s o) c.accRules
    else
      NotActive

{-
  if status c == 7
    then extractSale $ map (A.apply s o) (accRules c)
    else NotActive
-}
