module Rapanui.Critter.CritterRule
  where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Array as A
import Rapanui.Common (Ask)
--import Rapanui.Common (Ask, Cid(..), Bid(..))
import Rapanui.Critter.AcceptRule as Acc
import Rapanui.Critter.Rules (Critter)
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
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

-- hasSale :: Array OptionSale -> Boolean
-- hasSale sales =
--   A.any saleHit sales

applyCritter :: Ask -> StockOption -> Critter -> OptionSale
applyCritter s o c =
  case c.status of
    7 -> -- CRITTER_ACTIVE
      let
        result = map (Acc.applyAcc s o) c.accRules
        hit = A.find saleHit result
      in
        case hit of
          Just hit1 ->
            let
              _ = setStatus c 9
            in
              hit1
          Nothing ->
            NoSale
    9 -> -- CRITTER_SOLD
      NoSale
    _ ->
      NotActive

-- demo :: Array OptionSale
-- demo =
--   [NoSale,NoSale,Sale {critterId: Cid 1, price: Bid 12.9}]
