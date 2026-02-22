module Rapanui.Critter.Core where

import Prelude

import Data.Array as A
import Data.Either (Either(..))
import Data.Traversable (traverse)
import Effect.Aff (Aff)
--import Effect (Effect)
--import Effect.Class (liftEffect)
-- import HarborView.Common (errToString)

import Rapanui.Critter.Rules (StockOptionPurchase)
import Rapanui.Critter.CritterRule as Critter
import Rapanui.Nordnet.Adapter as Nordnet
import Rapanui.Nordnet.Transform as Transform
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)

applyPurchase_ :: StockOption -> StockOptionPurchase -> Array OptionSale
applyPurchase_ opx purchase =
  let
    ask = purchase.price
    fn = Critter.applyCritter ask opx
  in
    map fn purchase.critters

is100PctSold :: StockOptionPurchase -> Boolean
is100PctSold sop =
  A.all (\x -> x.status == 9) sop.critters

applyPurchase :: StockOptionPurchase -> Aff (Array OptionSale)
applyPurchase purchase =
  if is100PctSold purchase == false then
    Nordnet.fetchStockOption purchase.ticker >>= \response ->
      case response of
        Left err ->
          pure [SaleError { error: show err, oid: purchase.oid }]
        Right result1 ->
          if result1.status > 0 then
            pure [SaleError { error: "Payload error: " <> show result1.status, oid: purchase.oid }]
          else
            let
              currentStock = Transform.mapStockOptionResponse result1
            in
            pure $ applyPurchase_ currentStock purchase
  else
    pure []

applyPurchases :: Array StockOptionPurchase -> Aff (Array OptionSale)
applyPurchases purchases =
  traverse applyPurchase purchases >>= \px ->
    pure $ A.concat px
