module Derivatives.Adapter
  where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Derivatives.Response (StockAndOptionsPayload)
import Derivatives.Response as R
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import HarborView.HarborViewError (err2string, HarborViewError)
import HarborView.AppStatus (AppStatus(..),AppStatusResponse(..),fromInt)
import HarborView.Common (Oid(..))
import HarborView.Util.HttpUtil as HU

mainUrl :: String
mainUrl = "/nordnet"

fetchDerivatives_ :: Oid -> Boolean -> Aff (Either HarborViewError StockAndOptionsPayload)
fetchDerivatives_ (Oid oid) isCalls =
  let
    url = mainUrl -- <> "/prints/" <> show shelf <> "/" <> show stack
  in
  HU.get url R.stockAndOptionsDecoder

fetchDerivatives :: forall m. MonadAff m => Oid -> Boolean -> m (Either AppStatusResponse (Array Int))
fetchDerivatives oid isCalls =
  H.liftAff (fetchDerivatives_ oid isCalls) >>= \result ->
    case result of
      Left err ->
        pure $ Left $ { appStatus: HarborViewErr, msg: err2string err }
      Right result1 ->
        pure $ Left $ { appStatus: HarborViewErr, msg: "err2string err" }
        --  pure $ Right tbl --$ transformShelfPayload tbl
