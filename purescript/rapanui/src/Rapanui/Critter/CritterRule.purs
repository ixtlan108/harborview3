module Rapanui.Critter.CritterRule
  where

import Prelude

import Data.Array as AR
import Rapanui.Common (Ask)
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

foreign import setStatus :: Critter -> Int -> Unit

saleHit :: OptionSale -> Boolean
saleHit s =
  case s of
    Sale _ -> true
    _ -> false

hasSale :: Array OptionSale -> Boolean
hasSale sales =
  AR.any saleHit sales

applyCritter :: Ask -> StockOption -> Critter -> Array OptionSale
applyCritter s o c =
  case c.status of
    7 -> -- CRITTER_ACTIVE
      let
        result = validOptionSales $ map (A.applyAcc s o) c.accRules
        _ = if hasSale result then
              setStatus c 9
            else
              unit
      in
        result
    9 -> -- CRITTER_SOLD
      [NoSale]
    _ ->
      [NotActive]

{-
  if status c == 7
    then extractSale $ map (A.apply s o) (accRules c)
    else NotActive
-}
