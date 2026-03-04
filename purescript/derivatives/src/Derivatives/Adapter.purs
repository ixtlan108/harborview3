module Derivatives.Adapter
  where

import Prelude

import Data.Either (Either)
import Derivatives.Response (StockAndOptionsPayload,RiscPayload)
import Derivatives.Response as R
import Derivatives.Types (Page(..), RiscRequest)
import Derivatives.Types as T
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import HarborView.AppStatus (AppStatus)
import HarborView.Common (StockTicker(..))
import HarborView.CommonJson as CJ
import HarborView.Util.HttpUtil2 as HU2

fetchDerivatives :: forall m. MonadAff m
  => StockTicker
  -> Page
  -> m (Either AppStatus StockAndOptionsPayload)
fetchDerivatives (StockTicker ticker) page =
  let
    url =
      if page == Calls then
        "/nordnet/calls/" <> show ticker
      else
        "/nordnet/puts/" <> show ticker
  in
  H.liftAff (HU2.get url R.stockAndOptionsDecoder) >>= pure

calcRisc :: forall m. MonadAff m
  => Array RiscRequest
  -> m (Either AppStatus RiscPayload)
calcRisc riscRequests =
  let
    riscJson =
      map T.toJson riscRequests
    reqBody  =
      CJ.reqBodyArrayX2 riscJson
    url = "/maunaloa/stockprice/calculate"
  in
  H.liftAff (HU2.post url reqBody R.riscPayloadDecoder) >>= pure
