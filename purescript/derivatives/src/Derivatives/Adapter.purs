module Derivatives.Adapter
  where

import Prelude

import Data.Either (Either(..))
import Derivatives.Response (StockAndOptionsPayload)
import Derivatives.Response as R
import Derivatives.Types (Page(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import HarborView.HarborViewError (err2string, HarborViewError)
import HarborView.AppStatus (AppStatus(..), AppStatusResponse)
import HarborView.Common (StockTicker(..))
import HarborView.Util.HttpUtil as HU
import HarborView.Util.HttpUtil2 as HU2

mainUrl :: String
mainUrl = "/nordnet"

fetchDerivatives :: forall m. MonadAff m
  => StockTicker
  -> Page
  -> m (Either AppStatus StockAndOptionsPayload)
fetchDerivatives (StockTicker ticker) page =
  let
    url =
      if page == Calls then
        mainUrl <> "/calls/" <> show ticker
      else
        mainUrl <> "/puts/" <> show ticker
  in
  H.liftAff (HU2.get url R.stockAndOptionsDecoder) >>= \result ->
    pure $ result
