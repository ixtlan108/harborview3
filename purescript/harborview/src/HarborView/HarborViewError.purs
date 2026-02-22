module HarborView.HarborViewError
  where

import Prelude

import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Effect.Console (logShow)

data HarborViewError
  = AffjaxError String
  | HttpError String
  | JsonError String
  | CoreError String
  | IgnoreError

err2string :: HarborViewError -> String
err2string (AffjaxError err) = "AffjaxError: " <> err
err2string (HttpError err) = "HttpError: " <> err
err2string (JsonError err) = "JsonError: " <> err
err2string (CoreError err) = "CoreError: " <> err
err2string IgnoreError = "IgnoreError"

handleError :: HarborViewError -> Effect Unit
handleError err = logShow $ err2string err

handleErrorAff
    :: forall m
     . MonadAff m
    => HarborViewError
    -> m Unit
handleErrorAff err = liftEffect $ logShow $ err2string err
