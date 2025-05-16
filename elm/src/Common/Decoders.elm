module Common.Decoders exposing
    ( jsonStatusDecoder
    , selectItemDecoder
    , selectItemListDecoder
    , stockTickersDecoder
    )

import Common.Select exposing (SelectItem)
import Maunaloa.Options.Types exposing (StockTickersResponse)
-- import Critters.Types exposing (JsonStatus)
import Json.Decode as JD
import Json.Decode.Pipeline as JP


type alias JsonStatus =
    { ok : Bool, msg : String, statusCode : Int }

jsonStatusDecoder : JD.Decoder JsonStatus
jsonStatusDecoder =
    JD.succeed JsonStatus
        |> JP.required "ok" JD.bool
        |> JP.required "msg" JD.string
        |> JP.required "statusCode" JD.int


selectItemDecoder : JD.Decoder SelectItem
selectItemDecoder =
    JD.map2
        SelectItem
        (JD.field "v" JD.string)
        (JD.field "t" JD.string)


selectItemListDecoder : JD.Decoder (List SelectItem)
selectItemListDecoder =
    JD.list selectItemDecoder


stockTickersDecoder : JD.Decoder StockTickersResponse
stockTickersDecoder =
  JD.succeed StockTickersResponse
    |> JP.required "payload"selectItemListDecoder
    |> JP.required "appStatusCode" JD.int
    |> JP.optional "error" JD.string ""
