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

mainUrl :: String
mainUrl = "/nordnet"

fetchDerivatives_ :: StockTicker -> Page -> Aff (Either HarborViewError StockAndOptionsPayload)
fetchDerivatives_ (StockTicker ticker) page =
  let
    url =
      if page == Calls then
        mainUrl <> "/calls/" <> show ticker
      else
        mainUrl <> "/puts/" <> show ticker
  in
  HU.get url R.stockAndOptionsDecoder

fetchDerivatives :: forall m. MonadAff m
  => StockTicker
  -> Page
  -> m (Either AppStatusResponse StockAndOptionsPayload)
fetchDerivatives ticker isCalls =
  H.liftAff (fetchDerivatives_ ticker isCalls) >>= \result ->
    case result of
      Left err ->
        pure $ Left $ { appStatus: HarborViewErr, msg: err2string err }
      Right result1 ->
        pure $ Right result1
        --  pure $ Right tbl --$ transformShelfPayload tbl
