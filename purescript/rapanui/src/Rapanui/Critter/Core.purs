module Rapanui.Critter.Core where

import Prelude

import Data.Array as Ar
import Data.Either (Either(..))
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import HarborView.Common (errToString)

import Rapanui.Critter.Rules (StockOptionPurchase)
import Rapanui.Nordnet.Adapter as Nordnet
import Rapanui.Nordnet.Transform as Transform
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)

applyPurchase_ :: StockOption -> StockOptionPurchase -> Array OptionSale
applyPurchase_ opx purchase =
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
