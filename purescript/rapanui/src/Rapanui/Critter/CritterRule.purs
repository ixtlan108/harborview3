module Rapanui.Critter.CritterRule
  where

import Prelude

import Rapanui.Common (Ask, StatusCode(..))
import Rapanui.Critter.AcceptRule as A
import Rapanui.Critter.Rules (Critter)
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..), validOptionSales)
import Rapanui.StockMarket.StockOption (StockOption)


-- extractSale :: Array OptionSale -> OptionSale
-- extractSale sales =
--   let
--     result = validOptionSales sales
--   in
--   if AR.null result == true then
--     NoSale
--   else
--     unsafePartial $ fromJust $ AR.head result

{-
  let
    hits = [x | x@(Sale{}) <- sales] :: [OptionSale]
  in
    case hits of
      [] -> NoSale
      (x : _) -> x
-}

applyCritter :: Ask -> StockOption -> Critter -> Array OptionSale
applyCritter s o c =
  if c.status == CRITTER_ACTIVE
    then
      validOptionSales $ map (A.applyAcc s o) c.accRules
    else
      [NotActive]

{-
  if status c == 7
    then extractSale $ map (A.apply s o) (accRules c)
    else NotActive
-}
