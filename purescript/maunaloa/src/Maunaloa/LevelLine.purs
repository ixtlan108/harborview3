module HarborView.Maunaloa.LevelLine
  ( Line(..)
  , addLine
  , deleteNonPersistent
  , deleteAll
  , fetchLevelLines
  , fetchSpot
  , initEvents
  , updateRulers
  ) where

import Prelude

import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as Affjax
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode as Decode
import Data.Argonaut.Decode.Error (JsonDecodeError)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Number.Format (toStringWith, fixed)
import Data.Traversable as Traversable
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (logShow, warn)
import Graphics.Canvas (CanvasElement, Context2D)
import Graphics.Canvas as Canvas
import HarborView.Common (UnixTime(..), defaultEventHandling)
import HarborView.Maunaloa.Candlestick as Candlestick
import HarborView.Maunaloa.Common (Pix(..), ChartMapping(..), HtmlId(..), OptionTicker(..), StockTicker(..), ChartType, JsonSpot, chartTypeAsInt, mainURL, alert)
import HarborView.Maunaloa.HRuler (HRuler, timeStampToPix)
import HarborView.Maunaloa.MaunaloaError (handleErrorAff)
import HarborView.Common (HarborViewError(..))
import HarborView.Maunaloa.VRuler (VRuler, valueToPix, pixToValue)
import HarborView.Util.HttpUtil as HU
import Web.DOM.Element (toEventTarget, Element)
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)
import Web.Event.Event (EventType(..))
import Web.Event.Event as Event
import Web.Event.EventTarget as EventTarget
import Web.HTML as HTML
import Web.HTML.Event.EventTypes (offline)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.Window as Window

{-
import Data.IORef (newIORef,modifyIORef,readIORef)

type Counter = Int -> IO Int

makeCounter :: IO Counter
makeCounter = do
    r <- newIORef 0
    return (\i -> do modifyIORef r (\q -> q + i) -- (+i)
                    readIORef r)

testCounter :: Counter -> IO ()
testCounter counter = do
  b <- counter 1
  c <- counter 1
  d <- counter 1
  print [b,c,d]

main = do
  counter <- makeCounter
  testCounter counter
  testCounter counter
-}

foreign import clearLines :: Int -> Effect Unit

foreign import addLineImpl :: Int -> Line -> Effect Unit

foreign import onMouseDown :: Int -> Event.Event -> Effect Unit

foreign import onMouseDrag :: Int -> Event.Event -> Effect Unit

foreign import onMouseUpImpl :: Int -> (Line -> Maybe Line) -> (Maybe Line) -> Effect (Maybe Line)

foreign import updateRiscLine :: Int -> Line -> Number -> Effect Unit

foreign import updateRulersImpl :: Int -> VRuler -> HRuler -> Effect Unit

foreign import updateCtxImpl :: Int -> Context2D -> Effect Unit

foreign import randomRgb :: Effect String

foreign import currentVruler :: Int -> Effect VRuler

foreign import currentHruler :: Int -> Effect HRuler

foreign import currentCtx :: Int -> Effect Context2D

--foreign import showJson :: Json -> Effect Unit

--foreign import alert :: String -> Effect Unit

data Line
  = StdLine
      { y :: Number
      , selected :: Boolean
      , lt :: Int
      , color :: String
      }
  | RiscLine
      { y :: Number
      , selected :: Boolean
      , ticker :: OptionTicker
      , ask :: Number
      , bid :: Number
      , risc :: Number
      , riscPrice :: Number
      , lt :: Int
      }
  | BreakEvenLine
      { y :: Number
      , ticker :: OptionTicker
      , ask :: Number
      , breakEven :: Number
      , lt :: Int
      }

instance showLine :: Show Line where
  show (StdLine v) = "StdLine: " <> show v
  show (RiscLine v) = "RiscLine: " <> show v
  show (BreakEvenLine v) = "BreakEvenLine: " <> show v

ltSTD :: Int
ltSTD = 1

ltRISC :: Int
ltRISC = 2

ltBREAK_EVEN :: Int
ltBREAK_EVEN = 3

onMouseUp :: ChartType -> Event.Event -> Effect (Maybe Line)
onMouseUp ct _ = onMouseUpImpl (chartTypeAsInt ct) Just Nothing

getDoc :: Effect NonElementParentNode
getDoc =
  HTML.window >>= \win ->
    Window.document win >>= \doc ->
      pure $ HTMLDocument.toNonElementParentNode doc

type HtmlContext =
  { canvasContext :: CanvasElement --Canvas.Context2D
  , canvasElement :: Element
  }

type RiscLineJson =
  { ticker :: String
  , be :: Number
  , riscStockPrice :: Number
  , riscOptionPrice :: Number
  , bid :: Number
  , ask :: Number
  , risc :: Number
  }

type RiscLinesJson = Array RiscLineJson

riscLinesDecoder :: Json -> Either JsonDecodeError RiscLinesJson
riscLinesDecoder = Decode.decodeJson

type UpdatedOptionPriceJson =
  { value :: Number
  }

updOptionPriceFromJson :: Json -> Either JsonDecodeError UpdatedOptionPriceJson
updOptionPriceFromJson = Decode.decodeJson

type StatusJson =
  { ok :: Boolean
  , msg :: String
  , statusCode :: Int
  }

statusDecoder :: Json -> Either JsonDecodeError StatusJson
statusDecoder = Decode.decodeJson

spotDecoder :: Json -> Either JsonDecodeError JsonSpot
spotDecoder = Decode.decodeJson

----------------------------- BEGIN URLs -----------------------------

levelLinesURL :: StockTicker -> String
levelLinesURL (StockTicker ticker) =
  -- "http://localhost:6346/maunaloa/risclines/" <> ticker
  mainURL <> "/risclines/" <> ticker

optionPriceURL :: OptionTicker -> Number -> String
optionPriceURL (OptionTicker ticker) curStockPrice =
  mainURL <> "/stockoption/price/" <> ticker <> "/" <> toStringWith (fixed 2) curStockPrice

spotURL :: StockTicker -> String
spotURL (StockTicker ticker) =
  mainURL <> "/stockprice/spot/" <> ticker

----------------------------- END URLs -----------------------------

----------------------------- BEGIN Fetch level lines -----------------------------

addLine :: ChartType -> Effect Unit
addLine ct =
  liftEffect (randomRgb) >>= \curColor ->
    let
      line = StdLine { y: 200.0, selected: false, lt: ltSTD, color: curColor }
    in
      addLineImpl (chartTypeAsInt ct) line

addRiscLine :: ChartType -> RiscLineJson -> Effect Unit
addRiscLine ct line =
  let
    cti = chartTypeAsInt ct
    ticker = OptionTicker line.ticker
  in
    currentVruler cti >>= \vr ->
      let
        rl =
          RiscLine
            { y: valueToPix vr line.riscStockPrice
            , selected: false
            , ticker: ticker
            , ask: line.ask
            , bid: line.bid
            , risc: line.risc
            , riscPrice: line.riscOptionPrice
            , lt: ltRISC
            }
        bl =
          BreakEvenLine
            { y: valueToPix vr line.be
            , ticker: ticker
            , ask: line.ask
            , breakEven: line.be
            , lt: ltBREAK_EVEN
            }
      in
        addLineImpl cti rl *>
          addLineImpl cti bl

addRiscLines :: ChartType -> RiscLinesJson -> Effect Unit
addRiscLines ct lines =
  let
    addRiscLine1 = addRiscLine ct
  in
    Traversable.traverse_ addRiscLine1 lines

fetchLevelLines_ :: StockTicker -> Aff (Either HarborViewError RiscLinesJson)
fetchLevelLines_ ticker = HU.get (levelLinesURL ticker) riscLinesDecoder

fetchLevelLines :: ChartType -> StockTicker -> Aff Unit
fetchLevelLines ct ticker =
  fetchLevelLines_ ticker >>= \lines ->
    case lines of
      Left err ->
        handleErrorAff err
      Right lines1 ->
        case lines1 of
          [] ->
            pure unit -- liftEffect $ logShow "No level lines registered for this thicker"
          _ ->
            liftEffect $
              clearLines (chartTypeAsInt ct) *>
              addRiscLines ct lines1

----------------------------- END Fetch level lines -----------------------------

----------------------------- BEGIN Delete all level lines -----------------------------

deleteAll_ :: StockTicker -> Aff (Either HarborViewError StatusJson)
deleteAll_ ticker =
  HU.delete (levelLinesURL ticker) statusDecoder

deleteNonPersistent :: ChartType -> Effect Unit
deleteNonPersistent ct =
  clearLines (chartTypeAsInt ct)

deleteAll :: ChartType -> StockTicker -> Aff Unit
deleteAll ct ticker =
  liftEffect (clearLines (chartTypeAsInt ct)) *>
    deleteAll_ ticker >>= \status ->
      case status of
        Left err ->
          handleErrorAff err
        Right _ ->
          pure unit

----------------------------- END Delete all level lines -----------------------------

----------------------------- BEGIN Fetch Spot -----------------------------

fetchSpot_ :: StockTicker -> Aff (Either HarborViewError JsonSpot)
fetchSpot_ ticker =
  HU.get (spotURL ticker) spotDecoder

addSpot :: ChartType -> JsonSpot -> Effect Unit
addSpot ct spot =
  logShow spot *>
    let
      cti = chartTypeAsInt ct
    in
      if spot.appStatusCode /= 1 then
        logShow("Error " <> show spot.appStatusCode)
      else
        case spot.payload of
          Nothing -> logShow "Paload is null"
          Just payload1 ->
            currentVruler cti >>= \vr ->
              currentHruler cti >>= \hr ->
                currentCtx cti >>= \ctx ->
                  let
                    cndl = Candlestick.candleToPix vr payload1
                    px = timeStampToPix hr (UnixTime payload1.unixTime)
                  in
                    Candlestick.paintSingle (Pix px) cndl ctx

fetchSpot :: ChartType -> StockTicker -> Aff Unit
fetchSpot ct ticker =
  fetchSpot_ ticker >>= \spot ->
      case spot of
        Left err ->
          handleErrorAff err
        Right spot1 ->
          liftEffect (addSpot ct spot1)

----------------------------- END Fetch Spot -----------------------------

mouseEventDown :: ChartType -> Event.Event -> Effect Unit
mouseEventDown ct evt =
  defaultEventHandling evt *>
    onMouseDown (chartTypeAsInt ct) evt

mouseEventDrag :: ChartType -> Event.Event -> Effect Unit
mouseEventDrag ct evt =
  defaultEventHandling evt *>
    onMouseDrag (chartTypeAsInt ct) evt

fetchUpdatedOptionPrice :: OptionTicker -> Number -> Aff (Either HarborViewError Number)
fetchUpdatedOptionPrice ticker curStockPrice =
  let
    fn :: UpdatedOptionPriceJson -> Number
    fn v = v.value
  in
  HU.getTransform (optionPriceURL ticker curStockPrice) updOptionPriceFromJson fn

  -- Affjax.get ResponseFormat.json (optionPriceURL ticker curStockPrice) >>= \res ->
  --   let
  --     result :: Either HarborViewError Number
  --     result =
  --       case res of
  --         Left err ->
  --           Left $ AffjaxError (Affjax.printError err)
  --         Right response ->
  --           let
  --             json = updOptionPriceFromJson response.body
  --           in
  --             case json of
  --               Left err ->
  --                 Left $ JsonError (show err)
  --               Right json1 ->
  --                 Right json1.value
  --   in
  --     pure result

handleUpdateOptionPrice :: ChartType -> VRuler -> Line -> Effect Unit
handleUpdateOptionPrice ct vr lref@(RiscLine line) =
  launchAff_ $
    let
      cti = chartTypeAsInt ct
      sp = pixToValue vr (Pix line.y)
    in
      fetchUpdatedOptionPrice line.ticker sp >>= \n ->
        case n of
          Left err ->
            handleErrorAff err
          Right value ->
            (liftEffect $ updateRiscLine cti lref value)
handleUpdateOptionPrice _ _ _ =
  pure unit

handleMouseEventUpLine :: ChartType -> VRuler -> Maybe Line -> Effect Unit
handleMouseEventUpLine ct vr line =
  case line of
    Nothing ->
      pure unit
    Just line1 ->
      handleUpdateOptionPrice ct vr line1

{-
        Just lref@(RiscLine rec0) ->76
            logShow rec0 *>
            let
                oldOpPrice = rec0.bid
                newPrice = oldOpPrice * 1.2
            in
            updateRiscLine lref newPrice
        _ ->
            pure unit
-}

mouseEventUp :: ChartType -> Event.Event -> Effect Unit
mouseEventUp ct evt =
  defaultEventHandling evt *>
    onMouseUp ct evt >>= \line ->
    currentVruler (chartTypeAsInt ct) >>= \vruler ->
      handleMouseEventUpLine ct vruler line

getHtmlContext1
  :: { canvas :: Maybe Element
     , ctx :: Maybe CanvasElement
     }
  -> Maybe HtmlContext
getHtmlContext1 prm =
  prm.canvas >>= \canvas1 ->
    prm.ctx >>= \ctx1 ->
      Just
        { canvasContext: ctx1
        , canvasElement: canvas1
        }

validateMaybe :: forall a. String -> Maybe a -> Effect Unit
validateMaybe desc el =
  case el of
    Nothing -> alert ("ERROR!: " <> desc)
    Just _ -> pure unit -- logShow ("OK: " <> desc)

getHtmlContext
  :: forall r
   . { levelCanvasId :: HtmlId | r }
  -> Effect (Maybe HtmlContext)
getHtmlContext
  { levelCanvasId: (HtmlId levelCanvasId1)
  } =
  logShow ("levelCanvasId1: " <> levelCanvasId1) *>
    getDoc >>= \doc ->
    getElementById levelCanvasId1 doc >>= \canvasElement ->
      Canvas.getCanvasElementById levelCanvasId1 >>= \canvas ->
        validateMaybe "canvasElement" canvasElement
          *> validateMaybe "canvas" canvas
          *>
            pure
              ( getHtmlContext1
                  { canvas: canvasElement
                  , ctx: canvas
                  }
              )
getHtmlContext _ =
  pure Nothing

initEvent :: (Event.Event -> Effect Unit) -> Element -> EventType -> Effect Unit
initEvent toListener element eventType =
  EventTarget.eventListener toListener >>= \e1 ->
    EventTarget.addEventListener eventType e1 false (toEventTarget element)

initEvents :: ChartType -> ChartMapping -> Effect Unit
initEvents ct (ChartMapping cm) =
  getHtmlContext cm >>= \context ->
    case context of
      Nothing ->
        logShow ("(initEvents) No getHtmlContext for: " <> (show cm.levelCanvasId)) *>
          pure unit
      Just context1 ->
        let
          ce = context1.canvasContext
        in
          Canvas.getContext2D ce >>= \ctx ->
            updateCtxImpl (chartTypeAsInt ct) ctx
              *> initEvent (mouseEventDown ct) context1.canvasElement (EventType "mousedown")
              *> initEvent (mouseEventDrag ct) context1.canvasElement (EventType "mousemove")
              *>
                initEvent (mouseEventUp ct) context1.canvasElement (EventType "mouseup")

updateRulers :: ChartType -> VRuler -> HRuler -> Effect Unit
updateRulers ct vr hr =
  updateRulersImpl (chartTypeAsInt ct) vr hr
