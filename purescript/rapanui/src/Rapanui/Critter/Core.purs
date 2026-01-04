module Rapanui.Critter.Core where

import Prelude

import Data.Array as Ar
import Data.Either (Either(..))
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import HarborView.Common (errToString)

import Rapanui.Critter.Rules (StockOptionPurchase)
import Rapanui.Critter.CritterRule as Critter
import Rapanui.Nordnet.Adapter as Nordnet
import Rapanui.Nordnet.Transform as Transform
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)

foreign import setIsSold :: StockOptionPurchase -> Unit

applyPurchase_ :: StockOption -> StockOptionPurchase -> Array OptionSale
applyPurchase_ opx purchase =
  if purchase.isSold == false then
    let
      ask = opx.option.ask
      fn = Critter.applyCritter ask opx
    in
      map fn purchase.critters
  else
    []


applyPurchase :: StockOptionPurchase -> Aff (Array OptionSale)
applyPurchase purchase =
  Nordnet.fetchStockOption purchase.ticker >>= \response ->
    case response of
      Left err ->
        pure [SaleError $ errToString err]
      Right result1 ->
        let
          currentStock = Transform.mapStockOptionResponse result1
        in
        pure $ applyPurchase_ currentStock purchase

applyPurchases :: Array StockOptionPurchase -> Aff (Array OptionSale)
applyPurchases purchases =
  traverse applyPurchase purchases >>= \px ->
    pure $ Ar.concat px
