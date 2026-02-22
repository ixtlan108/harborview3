module HarborView.Util.HttpUtil
  ( get
  , getTransform
  , post
  , put
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

import HarborView.HarborViewError (HarborViewError(..))

getTransform :: forall r v. URL -> (Json -> Either JsonDecodeError r) -> (r -> v) -> Aff (Either HarborViewError v)
getTransform url f fv =
  Affjax.get ResponseFormat.json url >>= \res ->
    let
      result :: Either HarborViewError v
      result =
        case res of
          Left err ->
            Left $ AffjaxError (Affjax.printError err)
          Right response ->
            let
              fresult = f response.body
            in
              case fresult of
                Left err ->
                  Left $ JsonError (show err)
                Right fresult1 ->
                  Right $ fv fresult1
    in
      pure result

parseResult :: forall r r2.
    Either Error { body :: Json, status :: StatusCode | r2 }
    -> (Json -> Either JsonDecodeError r) -> Either HarborViewError r
parseResult res f =
  case res of
    Left err ->
      Left $ AffjaxError (Affjax.printError err)
    Right response ->
      let
        StatusCode code = response.status
      in
        if code >= 400 then
          Left $ HttpError $ "StatusCode: " <> show code
        else
          let
            fresult = f response.body
          in
            case fresult of
              Left err ->
                Left $ JsonError (show err)
              Right fresult1 ->
                Right fresult1

get :: forall r. URL -> (Json -> Either JsonDecodeError r) -> Aff (Either HarborViewError r)
get url f =
  Affjax.get ResponseFormat.json url >>= \res ->
    pure $ parseResult res f

post
  :: forall r
  . URL
  -> RequestBody
  -> (Json -> Either JsonDecodeError r)
  -> Aff (Either HarborViewError r)
post url requestBody f =
  Affjax.post ResponseFormat.json url (Just requestBody) >>= \res ->
    pure $ parseResult res f


put
  :: forall r
  . URL
  -> RequestBody
  -> (Json -> Either JsonDecodeError r)
  -> Aff (Either HarborViewError r)
put url requestBody f =
  Affjax.put ResponseFormat.json url (Just requestBody) >>= \res ->
    pure $ parseResult res f

delete :: forall r. URL -> (Json -> Either JsonDecodeError r) -> Aff (Either HarborViewError r)
delete url f =
  Affjax.delete ResponseFormat.json url >>= \res ->
    pure $ parseResult res f
