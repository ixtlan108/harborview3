module HarborView.CommonJson
  where

import Prelude

import Affjax.RequestBody (RequestBody)
import Affjax.RequestBody as REQB
import Data.Argonaut.Core (Json)
import Data.Argonaut.Core as AC
import Data.Argonaut.Decode as Decode
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Either (Either)
--import Data.Foldable (class Foldable)
import Data.Int (toNumber)
import Data.Int as DI
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Tuple (Tuple(..))
import Foreign.Object (fromFoldable)
import HarborView.Common as HC

type PayloadResponse a =
  { appStatusCode :: Int
  , msg :: Maybe String
  , payload :: a
  }

payload :: Array (Tuple String Json) -> RequestBody
payload jb =
  REQB.json $ AC.fromObject $ fromFoldable jb

fromArrayX2 :: Array (Array (Tuple String Json)) -> Array Json
fromArrayX2 jb =
  map (AC.fromObject <<< fromFoldable) jb

reqBodyArrayX2 :: Array (Array (Tuple String Json)) -> RequestBody
reqBodyArrayX2 jb =
  REQB.json $ AC.fromArray $ fromArrayX2 jb

type DefaultResponse =
  { appStatusCode :: Int
  , msg :: Maybe String
  }

defaultResponseDecoder :: Json -> Either JsonDecodeError DefaultResponse
defaultResponseDecoder = Decode.decodeJson

fromArray :: String -> Array (Tuple String Json) -> Tuple String Json
fromArray jsonKey [] =
  Tuple jsonKey AC.jsonNull
fromArray jsonKey array =
  Tuple jsonKey $ AC.fromObject $ fromFoldable array

fromMaybeString :: String -> Maybe String -> Tuple String Json
fromMaybeString jsonKey Nothing =
  Tuple jsonKey AC.jsonNull
fromMaybeString jsonKey (Just val) =
  Tuple jsonKey (AC.fromString val)

fromMaybeInt :: String -> Maybe Int -> Tuple String Json
fromMaybeInt jsonKey Nothing =
  Tuple jsonKey AC.jsonNull
fromMaybeInt jsonKey (Just val) =
  Tuple jsonKey (AC.fromNumber $ toNumber val)

fromMaybeNum :: String -> Maybe Number -> Tuple String Json
fromMaybeNum jsonKey Nothing =
  Tuple jsonKey AC.jsonNull
fromMaybeNum jsonKey (Just val) =
  Tuple jsonKey (AC.fromNumber val)

fromInt :: String -> Int -> Tuple String Json
fromInt jsonKey val =
  Tuple jsonKey (AC.fromNumber $ toNumber val)

fromNumber :: String -> Number -> Tuple String Json
fromNumber jsonKey val =
  Tuple jsonKey (AC.fromNumber val)

fromString :: String -> String -> Tuple String Json
fromString jsonKey val =
  Tuple jsonKey (AC.fromString val)

fromBool :: String -> Boolean -> Tuple String Json
fromBool jsonKey val =
  Tuple jsonKey (AC.fromBoolean val)

class ToJsonTuple a where
  toJsonTuple :: a -> Tuple String Json

jsonTupleStr :: forall a. Newtype a String => Maybe a -> String -> Tuple String Json
jsonTupleStr ams key =
  let
    ams1 = HC.mapx ams
  in
  case ams1 of
    Nothing ->
      Tuple key AC.jsonNull
    (Just val) ->
      Tuple key (AC.fromString val)


jsonTupleInt :: forall a. Newtype a Int => Maybe a -> String -> Tuple String Json
jsonTupleInt ams key =
  let
    ams1 = HC.mapx ams
  in
  case ams1 of
    Nothing ->
      Tuple key AC.jsonNull
    (Just val) ->
      Tuple key (AC.fromNumber $ DI.toNumber val)

-- jsonTupleNum :: forall a. a -> String -> Tuple String Json

jsonTupleNum :: forall a. Newtype a Number => Maybe a -> String -> Tuple String Json
jsonTupleNum ams key =
  let
    ams1 = HC.mapx ams
  in
  case ams1 of
    Nothing ->
      Tuple key AC.jsonNull
    (Just val) ->
      Tuple key (AC.fromNumber val)
