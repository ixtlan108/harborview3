module HarborView.Maunaloa.JsonCharts where

import Prelude

import Affjax.Web (URL)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode as Decode
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import HarborView.HarborViewError (HarborViewError)
import HarborView.Maunaloa.Common (ChartType(..), StockTicker(..), ValueRange)
import HarborView.Util.HttpUtil as HU

--foreign import addCharts :: String -> JsonChartResponse -> Effect Unit
--foreign import getChartsImpl :: (JsonChartResponse -> Maybe JsonChartResponse) -> Maybe JsonChartResponse -> String -> Maybe JsonChartResponse

--getCharts :: String -> Maybe JsonChartResponse
--getCharts key = getChartsImpl Just Nothing key

type JsonCandlestick =
  { o :: Number
  , h :: Number
  , l :: Number
  , c :: Number
  }

type JsonChart =
  { lines :: Maybe (Array (Array Number))
  , bars :: Maybe (Array (Array Number))
  , candlesticks :: Maybe (Array JsonCandlestick)
  }

data JsonChartWindow
  = JsonChartWindow
      { lines :: Array (Array Number)
      , candlesticks :: Array JsonCandlestick
      , valueRange :: ValueRange
      , numVlines :: Int
      }
  | JsonChartWindowBar
      { bars :: Array (Array Number)
      , valueRange :: ValueRange
      , numVlines :: Int
      }
  | JsonChartWindowEmpty

type JsonChartPayload =
  { ticker :: String
  , chart :: JsonChart
  , chart2 :: JsonChart
  , chart3 :: JsonChart
  , xAxis :: Array Int
  , minDx :: Number
  }

type JsonChartResponse =
  { payload :: Maybe JsonChartPayload
  , appStatusCode :: Int
  , msg :: Maybe String
  }

emptyJsonChart :: JsonChart
emptyJsonChart =
  { lines: Nothing
  , bars: Nothing
  , candlesticks: Nothing
  }

chartsDecoder :: Json -> Either JsonDecodeError JsonChartResponse
chartsDecoder = Decode.decodeJson

chartUrl :: ChartType -> StockTicker -> URL
chartUrl DayChart (StockTicker ticker) =
  "/maunaloa/stockprice/days/" <> ticker
chartUrl WeekChart (StockTicker ticker) =
  "/maunaloa/stockprice/weeks/" <> ticker
chartUrl MonthChart (StockTicker ticker) =
  "/maunaloa/stockprice/months/" <> ticker
chartUrl EmptyChartType _ = ""

fetchCharts :: StockTicker -> ChartType -> Aff (Either HarborViewError JsonChartResponse)
fetchCharts ticker chartType =
  HU.get
    (chartUrl chartType ticker)
    chartsDecoder

-- pure $ Left $ AffjaxError "ahsf"

-- Affjax.get ResponseFormat.json (chartUrl chartType ticker) >>= \res ->
--     let
--         result :: Either MaunaloaError JsonChartResponse
--         result =
--             case res of
--                 Left err ->
--                     Left $ AffjaxError (Affjax.printError err)
--                 Right response ->
--                     let
--                         charts = chartsFromJson response.body
--                     in
--                     case charts of
--                         Left err ->
--                             Left $ JsonError (show err)
--                         Right charts1 ->
--                             Right charts1
--     in
--     pure result

{-
demo :: Effect Unit
demo =
    launchAff_ $
        --Affjax.get ResponseFormat.json "https://reqbin.com/echo/get/json" >>= \res ->
        let
            key = "1"
        in
        Affjax.get ResponseFormat.json (days key) >>= \res ->
            case res of
                Left err ->
                    (liftEffect $ logShow $ "Affjax Error: " <> Affjax.printError err) *>
                    pure unit
                Right response ->
                    -- (liftEffect $ logShow "OK!") *>
                    let
                        charts = chartsFromJson response.body
                    in
                    -- (liftEffect $ showJson response.body) *>
                    case charts of
                        Left err ->
                            (liftEffect $ alert $ show err)
                        Right charts1 ->
                            -- -> (liftEffect $ logShow charts1)
                            (liftEffect $ addCharts key charts1)
-}
