module Rapanui.Nordnet.Adapter
  ( fetchCritters
  , fetchStockOption
  , toggleAccActive
  , registerSales
  )
  where

import Prelude

import Data.Either (Either)
import Effect.Aff (Aff)
import HarborView.Common (HarborViewError)
import HarborView.Util.HttpUtil as HU
import Rapanui.Common (OptionTicker(..))
import Rapanui.Nordnet.CoreJson (CritterResponse, DefaultResponse, StockOptionPayload)
import Rapanui.Nordnet.CoreJson as CoreJson
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))

fetchCritters :: Aff (Either HarborViewError CritterResponse)
fetchCritters =
  HU.get
    "http://localhost:8082/critter/purchase/11"
    CoreJson.critterResponseDecoder

fetchStockOption :: OptionTicker -> Aff (Either HarborViewError StockOptionPayload)
fetchStockOption (OptionTicker ticker) =
  HU.get
    ("http://localhost:8082/rapanui/stockoption/" <> ticker)
    CoreJson.stockOptionDecoder

toggleAccActive :: Int -> Boolean -> Aff (Either HarborViewError DefaultResponse)
toggleAccActive oid isChecked =
  HU.get
    ("http://localhost:8082/rapanui/toggleAccrule/" <> show oid <> "/" <> show isChecked)
    CoreJson.defaultResponseDecoder

registerSales :: Array OptionSale -> Aff (Either HarborViewError DefaultResponse)
registerSales items =
  HU.get
    "http://localhost:8082/rapanui/toggleAccrule/"
    CoreJson.defaultResponseDecoder
