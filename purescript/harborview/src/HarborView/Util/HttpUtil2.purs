module HarborView.Util.HttpUtil2
  ( get
    , put
    , post
    , delete
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))

import Effect.Aff (Aff)
import Affjax (Error)
import Affjax.StatusCode (StatusCode(..))
import Affjax.Web (URL)
import Affjax.Web as Affjax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.RequestBody (RequestBody)

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Argonaut.Decode as Decode

import HarborView.AppStatus (AppStatus(..))

parseResult :: forall r r2.
    Either Error { body :: String, status :: StatusCode | r2 }
    -> (Json -> Either JsonDecodeError r) -> Either AppStatus r
parseResult res f =
  case res of
    Left err ->
      Left $ AffjaxError (Affjax.printError err)
    Right response ->
      let
        StatusCode code = response.status
      in
        if code >= 400 then
          Left $ HttpError code
        else
          let
            fresult = 
              Decode.parseJson response.body >>= f
          in
            case fresult of
              Left err ->
                Left $ JsonError (show err)
              Right fresult1 ->
                Right fresult1

get :: forall r. URL -> (Json -> Either JsonDecodeError r) -> Aff (Either AppStatus r)
get url f =
  Affjax.get ResponseFormat.string url >>= \res ->
    pure $ parseResult res f

post
  :: forall r
  . URL
  -> RequestBody
  -> (Json -> Either JsonDecodeError r)
  -> Aff (Either AppStatus r)
post url requestBody f =
  Affjax.post ResponseFormat.string url (Just requestBody) >>= \res ->
    pure $ parseResult res f


put
  :: forall r
  . URL
  -> RequestBody
  -> (Json -> Either JsonDecodeError r)
  -> Aff (Either AppStatus r)
put url requestBody f =
  Affjax.put ResponseFormat.string url (Just requestBody) >>= \res ->
    pure $ parseResult res f

delete :: forall r. URL -> (Json -> Either JsonDecodeError r) -> Aff (Either AppStatus r)
delete url f =
  Affjax.delete ResponseFormat.string url >>= \res ->
    pure $ parseResult res f
