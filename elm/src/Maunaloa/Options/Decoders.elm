module Maunaloa.Options.Decoders exposing (payloadDecoder, optionDecoder, stockAndOptionsDecoder, stockDecoder)

import Common.Types exposing (JsonStatus)
import Common.Utils as U
import Json.Decode as JD
import Json.Decode.Pipeline as JP
import Maunaloa.Options.Types exposing (Payload, Option, Options, Stock, StockAndOptions)


purchaseStatusDecoder =
    JD.succeed JsonStatus
        |> JP.required "ok" JD.bool
        |> JP.required "msg" JD.string
        |> JP.required "statusCode" JD.int


buildOption :
    String
    -> Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> String
    -> Option
buildOption t x d b s ib is be ex =
    Option
        t
        x
        d
        b
        s
        ib
        is
        be
        ex
        (U.toDecimal (100 * ((s / b) - 1.0)) 10.0)
        0
        0
        0
        False


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

payloadDecoder : JD.Decoder Payload
payloadDecoder =
    JD.succeed Payload
    |> JP.required "payload" stockAndOptionsDecoder