module Rapanui.Critter.Core where

import Prelude

import Data.Array as Ar
import Data.Either (Either(..))
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import Effect (Effect)
import Effect.Class (liftEffect)
import HarborView.Common (errToString)

import Rapanui.Critter.Rules (StockOptionPurchase)
import Rapanui.Critter.CritterRule as Critter
import Rapanui.Nordnet.Adapter as Nordnet
import Rapanui.Nordnet.Transform as Transform
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)

foreign import setIsSold :: StockOptionPurchase -> Effect Unit

applyPurchase_ :: StockOption -> StockOptionPurchase -> Array OptionSale
applyPurchase_ opx purchase =
  let
    ask = opx.option.ask
    fn = Critter.applyCritter ask opx
  in
    Ar.concat $ map fn purchase.critters

applyPurchase :: StockOptionPurchase -> Aff (Array OptionSale)
applyPurchase purchase =
  if purchase.isSold == false then
    Nordnet.fetchStockOption purchase.ticker >>= \response ->
      case response of
        Left err ->
          pure [SaleError $ errToString err]
        Right result1 ->
          let
            currentStock = Transform.mapStockOptionResponse result1
          in
          (liftEffect $ setIsSold purchase) *>
          (pure $ applyPurchase_ currentStock purchase)
  else
    pure []

applyPurchases :: Array StockOptionPurchase -> Aff (Array OptionSale)
applyPurchases purchases =
  traverse applyPurchase purchases >>= \px ->
    pure $ Ar.concat px
