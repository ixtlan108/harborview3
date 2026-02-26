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

get :: forall r. URL -> (Json -> Either JsonDecodeError r) -> Aff (Either HarborViewError r)
get url f =
  Affjax.get ResponseFormat.json url >>= \res ->
    let
      result :: Either HarborViewError r
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
                  Right fresult1
    in
      pure result

post
  :: forall r
  . URL
  -> RequestBody
  -> (Json -> Either JsonDecodeError r)
  -> Aff (Either HarborViewError r)
post url requestBody f =
  Affjax.post ResponseFormat.json url (Just requestBody) >>= \res ->
    let
      result :: Either HarborViewError r
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
                  Right fresult1
    in
      pure result

put
  :: forall r
  . URL
  -> RequestBody
  -> (Json -> Either JsonDecodeError r)
  -> Aff (Either HarborViewError r)
put url requestBody f =
  Affjax.put ResponseFormat.json url (Just requestBody) >>= \res ->
    let
      result :: Either HarborViewError r
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
                  Right fresult1
    in
      pure result

delete :: forall r. URL -> (Json -> Either JsonDecodeError r) -> Aff (Either HarborViewError r)
delete url f =
  Affjax.delete ResponseFormat.json url >>= \res ->
    let
      result :: Either HarborViewError r
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
                  Right fresult1
    in
      pure result
