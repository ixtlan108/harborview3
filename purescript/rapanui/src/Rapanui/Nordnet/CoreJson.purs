module Rapanui.Nordnet.CoreJson
  ( CritterResponse
  , DefaultResponse
  , JsonAccRule
  , JsonCritter
  , JsonPayload
  , StockOptionResponse
  , JsonStockOptionItem
  , PayloadResponse
  , critterResponseDecoder
  , defaultResponseDecoder
  , stockOptionDecoder
  ) where

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode as Decode
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Either (Either)
import Data.Maybe (Maybe)

--import Data.Maybe (Maybe)

--import Prelude

type PayloadResponse a =
  { appstatus :: Int
  , msg :: Maybe String
  , payload :: a
  }

type JsonAccRule =
  { oid :: Int
  , pid :: Int
  , cid :: Int
  , rtyp :: Int
  , value :: Number
  , active :: Boolean
  }

type JsonCritter =
  { vol :: Int
  , status :: Int
  , oid :: Int
  , accRules :: Array JsonAccRule
  }

type JsonPayload =
  { ticker :: String
  , oid :: Int
  , price :: Number
  , critters :: Array JsonCritter
  }

type CritterResponsex =
  { appStatusCode :: Int
  , error :: Maybe String
  , payload :: Array JsonPayload
  }

type CritterResponse = PayloadResponse (Array JsonPayload)

critterResponseDecoder :: Json -> Either JsonDecodeError CritterResponse
critterResponseDecoder = Decode.decodeJson

type DefaultResponse =
  { appStatusCode :: Int
  , msg :: String
  }

defaultResponseDecoder :: Json -> Either JsonDecodeError DefaultResponse
defaultResponseDecoder = Decode.decodeJson

type JsonStockOptionItem =
  { bid :: Number
  , ask :: Number
  }

type StockOptionResponse =
  { option :: JsonStockOptionItem
  , status :: Int
  , msg :: String
  }

stockOptionDecoder :: Json -> Either JsonDecodeError StockOptionResponse
stockOptionDecoder = Decode.decodeJson

{-
{
  "appStatusCode": 1,
  "error": null,
  "payload": [
    {
      "ticker": "NHY9E30",
      "oid": 47,
      "price": 5.8,
      "critters": [
        {
          "vol": 10,
          "status": 7,
          "oid": 45,
          "accRules": [
            {
              "oid": 72,
              "pid": 47,
              "cid": 45,
              "rtyp": 1
              "value": 3,
              "active": true,
            },
            {
              "oid": 73,
              "pid": 47,
              "cid": 45,
              "rtyp": 7
              "value": 2,
              "active": false,
            }
          ]
        }
      ]
    }
  ]
}
-}
