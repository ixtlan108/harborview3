module HarborView.Maunaloa.Core where

import Prelude

import Control.Monad.Reader (runReader)
import Data.Either (Either(..))
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Number.Format (toString)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import HarborView.Maunaloa.ChartCollection as ChartCollection
import HarborView.Maunaloa.ChartTransform as ChartTransform
import HarborView.Maunaloa.Common (ChartMapping(..), ChartMappings, ChartHeight(..), ChartId(..), Drop(..), Take(..), Env(..), HtmlId(..), StockTicker(..), ChartType(..), ChartWidth(..), Scaling(..))
import HarborView.Maunaloa.Common as Common
import HarborView.Maunaloa.JsonCharts (JsonChartPayload, fetchCharts)
import HarborView.Maunaloa.LevelLine as LevelLine
import HarborView.Maunaloa.MaunaloaError (handleErrorAff)
import HarborView.Maunaloa.Repository as Repository

createEnv :: ChartType -> StockTicker -> Drop -> Take -> ChartMappings -> Env
createEnv ctype tik curDrop curTake mappings =
  Env
  { ticker: tik
  , dropAmt: curDrop
  , takeAmt: curTake
  , chartType: ctype
  , mappings: mappings
  , globalChartWidth: ChartWidth 1750.0
  , scaling: Scaling 1.1
  }

createEnvEmpty :: ChartMappings -> Env
createEnvEmpty mappings =
  Env
  { ticker: StockTicker "-"
  , dropAmt: Drop 0
  , takeAmt: Take 0
  , chartType: DayChart
  , mappings: mappings
  , globalChartWidth: ChartWidth 1750.0
  , scaling: Scaling 1.0
  }


reposIdFor :: ChartType -> StockTicker -> String
reposIdFor chartType (StockTicker ticker) =
  ticker <> ":" <> (toString $ toNumber $ Common.chartTypeAsInt chartType)

resetChart :: ChartType -> StockTicker -> Effect Unit
resetChart chartType ticker =
  let
    reposId = reposIdFor chartType ticker
  in
  Repository.resetChart reposId

resetCharts :: Effect Unit
resetCharts =
  Repository.resetCharts

paintNoCache :: ChartType -> StockTicker -> Drop -> Take -> Effect Unit
paintNoCache EmptyChartType _ _ _ =
  pure unit
paintNoCache chartType ticker dropAmt takeAmt =
  let
    mappings = chartTypeAsMappings chartType
    reposId = reposIdFor chartType ticker
    curEnv = createEnv chartType ticker dropAmt takeAmt mappings
  in
  launchAff_ $
    fetchCharts ticker chartType >>= \charts ->
      case charts of
        Left err ->
          handleErrorAff err
        Right jsonChartResponse ->
          case jsonChartResponse.payload of
            Just jsonChartPayload ->
              let
                collection = runReader (ChartTransform.transform jsonChartPayload) curEnv
              in
              (liftEffect $ Repository.setJsonResponse reposId jsonChartPayload) *>
              ChartCollection.paintAff chartType collection
            Nothing ->
              pure unit

paint :: ChartType -> StockTicker -> Drop -> Take -> Effect Unit
paint EmptyChartType _ _ _ =
  pure unit
paint chartType ticker dropAmt takeAmt =
  let
    mappings = chartTypeAsMappings chartType
    reposId = reposIdFor chartType ticker
    cachedResponse =  Repository.getJsonResponse reposId
  in
  logShow ticker *>
  case cachedResponse of
    Just cachedResponse1 ->
      let
        curEnv = createEnv chartType ticker dropAmt takeAmt mappings
        collection = runReader (ChartTransform.transform cachedResponse1) curEnv
      in
      logShow "Fetched response from repository" *>
      ChartCollection.paint chartType collection
    Nothing ->
      let
        curEnv = createEnv chartType ticker dropAmt takeAmt mappings
      in
      launchAff_ $
        fetchCharts ticker chartType >>= \charts ->
          case charts of
            Left err ->
              handleErrorAff err
            Right jsonChartResponse ->
              case jsonChartResponse.payload of
                Just payload1 ->
                  let
                    collection = runReader (ChartTransform.transform payload1) curEnv
                  in
                  (liftEffect $ Repository.setJsonResponse reposId payload1) *>
                  ChartCollection.paintAff chartType collection
                Nothing ->
                  pure unit

paintEmpty :: ChartType -> Effect Unit
paintEmpty ct =
  let
    mappings = chartTypeAsMappings ct
    curEnv = createEnvEmpty mappings
    collection = runReader (ChartTransform.transformEmpty) curEnv
  in
  let
    (ChartCollection.EmptyChartCollection coll) = collection
  in
  logShow "__paintEmpty__" *>
  logShow coll *>
  ChartCollection.paintEmpty collection

initEvents :: ChartType -> Effect Unit
initEvents ct =
  let
    mappings = chartTypeAsMappings ct
  in
  traverse_ (LevelLine.initEvents ct) mappings

addLevelLine :: ChartType -> Effect Unit
addLevelLine ct =
  LevelLine.addLine ct

fetchLevelLines :: ChartType -> StockTicker -> Effect Unit
fetchLevelLines ct ticker =
  LevelLine.fetchLevelLines ct ticker

deleteNonPersistentLevelLines :: ChartType -> Effect Unit
deleteNonPersistentLevelLines ct =
  LevelLine.deleteNonPersistent ct

deleteAllLevelLines :: ChartType -> StockTicker -> Effect Unit
deleteAllLevelLines ct ticker =
  LevelLine.deleteAll ct ticker

fetchSpot :: ChartType -> StockTicker -> Effect Unit
fetchSpot ct ticker =
  LevelLine.fetchSpot ct ticker

chartTypeAsMappings :: ChartType -> ChartMappings
chartTypeAsMappings DayChart =
  let
    mainChart =
      ChartMapping
      { chartId: ChartId "chart"
      , canvasId: HtmlId "chart-1"
      , chartHeight: ChartHeight 600.0
      , levelCanvasId: HtmlId "levellines-1"
      }
    osc =
      ChartMapping
      { chartId: ChartId "chart2"
      , canvasId: HtmlId "osc-1"
      , chartHeight: ChartHeight 200.0
      , levelCanvasId: NoHtmlId
      }
    volume =
      ChartMapping
      { chartId: ChartId "chart3"
      , canvasId: HtmlId "vol-1"
      , chartHeight: ChartHeight 110.0
      , levelCanvasId: NoHtmlId
      }
  in
  [ mainChart, osc, volume ]
chartTypeAsMappings WeekChart =
  let
    mainChart =
      ChartMapping
      { chartId: ChartId "chart"
      , canvasId: HtmlId "chart-2"
      , chartHeight: ChartHeight 600.0
      , levelCanvasId: HtmlId "levellines-2"
      }
    osc =
      ChartMapping
      { chartId: ChartId "chart2"
      , canvasId: HtmlId "osc-2"
      , chartHeight: ChartHeight 200.0
      , levelCanvasId: NoHtmlId
      }
    volume =
      ChartMapping
      { chartId: ChartId "chart3"
      , canvasId: HtmlId "vol-2"
      , chartHeight: ChartHeight 110.0
      , levelCanvasId: NoHtmlId
      }
  in
  [ mainChart, osc, volume ]
chartTypeAsMappings MonthChart =
  let
    mainChart =
      ChartMapping
      { chartId: ChartId "chart"
      , canvasId: HtmlId "chart-3"
      , chartHeight: ChartHeight 600.0
      , levelCanvasId: HtmlId "levellines-3"
      }
    osc =
      ChartMapping
      { chartId: ChartId "chart2"
      , canvasId: HtmlId "osc-3"
      , chartHeight: ChartHeight 200.0
      , levelCanvasId: NoHtmlId
      }
    volume =
      ChartMapping
      { chartId: ChartId "chart3"
      , canvasId: HtmlId "vol-3"
      , chartHeight: ChartHeight 110.0
      , levelCanvasId: NoHtmlId
      }
  in
  [ mainChart, osc, volume ]
chartTypeAsMappings EmptyChartType =
  []



  {-
        DAY: {
            MAIN_CHART: 'chart-1',
            VOLUME: 'vol-1',
            OSC: 'osc-1',
            LEVEL_LINES: 'levellines-1',
            BTN_LEVELLINE: "btn-levelline-1",
            BTN_RISCLINES: "btn-persistent-levelline-1",
            BTN_DEL_RISCLINES: "btn-del-persistent-levelline-1"
        },
        WEEK: {
            MAIN_CHART: 'chart-2',
            VOLUME: 'vol-2',
            OSC: 'osc-2',
            LEVEL_LINES: 'levellines-2',
            BTN_LEVELLINE: "btn-levelline-2",
            BTN_RISCLINES: "btn-persistent-levelline-2",
            BTN_DEL_RISCLINES: "btn-del-persistent-levelline-2"
        },
        MONTH: {
            MAIN_CHART: 'chart-3',
            VOLUME: 'vol-3',
            OSC: 'osc-3',
            LEVEL_LINES: 'levellines-3',
            BTN_LEVELLINE: "btn-levelline-3",
            BTN_RISCLINES: "btn-persistent-levelline-3",
            BTN_DEL_RISCLINES: "btn-del-persistent-levelline-3"
        }
    };
-}
