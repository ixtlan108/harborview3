module Rapanui.Nordnet.Adapter
  ( fetchCritters
  , fetchStockOption
  , toggleAccActive
  , registerSales
  )
  where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Core as AC
import Data.Either (Either)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
--import HarborView.Common (HarborViewError)
import HarborView.AppStatus (AppStatus)
import HarborView.CommonJson as CJ
import HarborView.Util.HttpUtil2 as HU
import Rapanui.Common (OptionTicker(..), Cid(..), Bid(..), Oid(..))
import Rapanui.Nordnet.CoreJson (CritterResponse, DefaultResponse, StockOptionPayload)
import Rapanui.Nordnet.CoreJson as CoreJson
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))

fetchCritters :: Aff (Either AppStatus CritterResponse)
fetchCritters =
  HU.get
    "/critter/purchase/11"
    CoreJson.critterResponseDecoder

fetchStockOption :: OptionTicker -> Aff (Either AppStatus StockOptionPayload)
fetchStockOption (OptionTicker ticker) =
  HU.get
    ("/rapanui/stockoption/" <> ticker)
    CoreJson.stockOptionDecoder

toggleAccActive :: Int -> Boolean -> Aff (Either AppStatus DefaultResponse)
toggleAccActive oid isChecked =
  HU.get
    ("/rapanui/toggleAccrule/" <> show oid <> "/" <> show isChecked)
    CoreJson.defaultResponseDecoder

mapOptionSale :: OptionSale -> Array (Tuple String Json)
mapOptionSale (Sale { critterId: (Cid cid), price: (Bid bid)}) =
  [ CJ.fromInt "cid" cid
  , CJ.fromNumber "bid" bid
  , Tuple "error" AC.jsonNull
  , CJ.fromBool "isSale" true
  , Tuple "oid" AC.jsonNull
  ]
mapOptionSale (SaleError { error, oid: (Oid oid) }) =
  [ Tuple "cid" AC.jsonNull
  , Tuple "bid" AC.jsonNull
  , CJ.fromInt "oid" oid
  , CJ.fromString "error" error
  , CJ.fromBool "isSale" false
  ]
mapOptionSale _ =
  [ Tuple "cid" AC.jsonNull
  , Tuple "bid" AC.jsonNull
  , Tuple "error" AC.jsonNull
  , Tuple "oid" AC.jsonNull
  , CJ.fromBool "isSale" false
  ]

registerSales :: Array OptionSale -> Aff (Either AppStatus DefaultResponse)
registerSales items =
  let
    jb =
      map mapOptionSale items
    pl =
      CJ.reqBodyArrayX2 jb
    url =
      "/rapanui/optionsales"
  in
  HU.put url pl CoreJson.defaultResponseDecoder
