module Derivatives.Adapter
  where

import Prelude

import Data.Either (Either)
import Derivatives.Response (StockAndOptionsPayload)
import Derivatives.Response as R
import Derivatives.Types (Page(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import HarborView.AppStatus (AppStatus)
import HarborView.Common (StockTicker(..))
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
