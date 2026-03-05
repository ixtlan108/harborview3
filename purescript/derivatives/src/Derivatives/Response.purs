module Derivatives.Response
  where

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode as Decode
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Either (Either)
import HarborView.CommonJson (PayloadResponse)

type Derivative =
  { ticker :: String
    , x :: Number
    , days :: Int
    , bid :: Number
    , ask :: Number
    , ivBid :: Number
    , ivAsk :: Number
    , brEven :: Number
    , expiry :: String
  }

type Stock =
  { unixtime :: Number
    , o :: Number
    , h :: Number
    , l :: Number
    , c :: Number
  }

type StockAndOptionsResponse =
  { stockprice :: Stock
    , opx :: Array Derivative
  }

type StockAndOptionsPayload = PayloadResponse StockAndOptionsResponse

stockAndOptionsDecoder :: Json -> Either JsonDecodeError StockAndOptionsPayload
stockAndOptionsDecoder = Decode.decodeJson

type RiscResponse =
  { ticker :: String
    , stockprice :: Number
    , optionprice :: Number
    , status :: Int
  }

type RiscPayload = PayloadResponse (Array RiscResponse)

riscPayloadDecoder :: Json -> Either JsonDecodeError RiscPayload
riscPayloadDecoder = Decode.decodeJson

{-
  optionDecoder : JD.Decoder Option
  optionDecoder =
      JD.succeed buildOption
          |> JP.required "ticker" JD.string
          |> JP.required "x" JD.float
          |> JP.required "days" JD.float
          |> JP.required "bid" JD.float
          |> JP.required "ask" JD.float
          |> JP.required "ivBid" JD.float
          |> JP.required "ivAsk" JD.float
          |> JP.required "brEven" JD.float
          |> JP.required "expiry" JD.string


  stockDecoder : JD.Decoder Stock
  stockDecoder =
      JD.succeed Stock
          |> JP.required "unixtime" JD.int
          |> JP.required "o" JD.float
          |> JP.required "h" JD.float
          |> JP.required "l" JD.float
          |> JP.required "c" JD.float


  stockAndOptionsDecoder : JD.Decoder StockAndOptions
  stockAndOptionsDecoder =
      JD.succeed StockAndOptions
          |> JP.required "stockprice" stockDecoder
          |> JP.required "opx" (JD.list optionDecoder)
-}
