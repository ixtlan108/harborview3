module Derivatives.Table.Table
  where

import Prelude

import Halogen.HTML (ClassName(..), HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (IProp)
import Halogen.HTML.Properties as HP
import Derivatives.Actions (MainAction(..))
import Derivatives.Table.SortField (SortField(..))
--import Report.Report1.Types (Report1Action(..))
--import Waimea.Common as W
--import Oahu.SortField (SortField(..))
import Web.HTML.Common (AttrName(..))

tdAlign :: forall r i. Boolean -> IProp r i
tdAlign isLeft =
  if isLeft then
    HP.attr (AttrName "align") "left"
  else
    HP.attr (AttrName "align") "right"

thSortAsc :: forall r i. Boolean -> IProp r i
thSortAsc asc =
  if asc then
    HP.attr (AttrName "aria-sort") "ascending"
  else
    HP.attr (AttrName "aria-sort") "descending"

noSort ∷ ∀ r i. Array (IProp (class ∷ String | r) i)
noSort =
  [ HP.classes [ ClassName "no-sort" ] ]


{-
  [ checkboxColumn
  , buttonColumn
  , Table.stringColumn "Ticker" .ticker
  , Table.floatColumn "Exercise" .x
  , Table.floatColumn "Days" .days
  , Table.floatColumn "Bid" .buy
  , Table.floatColumn "Ask" .sell
  , Table.floatColumn "Spread" .spread
  , Table.floatColumn "IvBid" .ivBuy
  , Table.floatColumn "IvAsk" .ivSell
  , Table.floatColumn "Break-Even" .breakEven
  , Table.floatColumn "Risc" .risc
  , Table.floatColumn "O.P. at Risc" .optionPriceAtRisc
  , Table.floatColumn "S.P. at Risc" .stockPriceAtRisc
  ]
-}

sortedTh :: forall w. SortField -> SortField -> String -> Boolean -> HTML w MainAction
sortedTh curSortField sortField title isAsc =
  if curSortField == sortField then
    HH.th [ HE.onClick (TableSort sortField), thSortAsc isAsc ] [ HH.text title ]
  else
    HH.th [ HE.onClick (TableSort sortField) ] [ HH.text title ]

unSortedTh :: forall w. String -> HTML w MainAction
unSortedTh title =
  HH.th noSort [ HH.text title ]

tableHead :: forall w. SortField -> Boolean -> HTML w MainAction
tableHead sf isAsc =
  let
    thTicker = sortedTh sf SfTicker "Ticker" isAsc
    thIvBid = sortedTh sf SfIvBid "IvBid" isAsc
    thIvAsk = sortedTh sf SfIvAsk "IvAsk" isAsc
  in
  HH.thead_
    [ HH.tr_
        [ unSortedTh "Selected"
          , unSortedTh "Purchase"
          , thTicker
          , unSortedTh "Days"
          , unSortedTh "Bid"
          , unSortedTh "Ask"
          , unSortedTh "Spread"
          , thIvBid
          , thIvAsk
          , unSortedTh "Break-Even"
          , unSortedTh "Risc"
          , unSortedTh "O.P. at Risc"
          , unSortedTh "S.P. at Risc"
        ]
    ]
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

payloadDecoder : JD.Decoder Payload
payloadDecoder =
    JD.succeed Payload
    |> JP.required "payload" stockAndOptionsDecoder
    |> JP.required "appStatusCode" JD.int
    |> JP.optional "error" JD.string ""
-}

type TableItem =
  { ticker :: String
    , days :: Int
    , bid :: Number
    , ask :: Number
    , spread :: Number
    , ivBid :: Number
    , ivAsk :: Number
    , breakEven :: Number
    , risc :: Number
    , opAtRisc :: Number
    , spAtRisc :: Number
  }

createRow :: forall w. TableItem -> HTML w MainAction
createRow item =
  HH.tr_
    [ HH.td_ [ HH.text "Selected" ]
     ,HH.td_ [ HH.text "Purchase" ]
    , HH.td_ [ HH.text item.ticker ]
    , HH.td_ [ HH.text $ show item.days ]
    , HH.td_ [ HH.text $ show item.bid ]
    , HH.td_ [ HH.text $ show item.ask ]
    , HH.td_ [ HH.text $ show item.spread ]
    , HH.td_ [ HH.text $ show item.ivBid ]
    , HH.td_ [ HH.text $ show item.ivAsk ]
    , HH.td_ [ HH.text $ show item.breakEven ]
    , HH.td_ [ HH.text $ show item.risc ]
    , HH.td_ [ HH.text $ show item.opAtRisc ]
    , HH.td_ [ HH.text $ show item.spAtRisc ]
  ]

createTable :: forall w.
  Array TableItem
  -> SortField
  -> Boolean
  -> HTML w MainAction
createTable items sf isAsc =
  let
    rows = map createRow items
  in
    HH.table
      [ HP.classes [ ClassName "sortable ps-mt-1" ] ]
      [ tableHead sf isAsc
      , HH.tbody_ rows
      ]


    {-
createRow
  :: forall w r
   .  { loc :: String
      , gps :: Int
      , edn :: Maybe String
      , edt :: Maybe Int
      , photo :: Int
      , pwf :: Maybe String
      , gpo :: Maybe Int
      , stdFrame :: Maybe String
      , shootDate :: Maybe String
      , ata :: Maybe String
      , atd :: Maybe String
      | r
      }
   -> HTML w MainAction
createRow item =
  HH.tr_
    [ HH.td_ [ HH.text $ item.loc ]
    , HH.td_ [ HH.text $ show item.gps ]
    , HH.td_ [ HH.text $ fromMaybe "" item.edn ]
    , HH.td_ [ HH.text $ W.maybeInt2Str item.edt ""]
    , HH.td [ tdAlign false ] [ HH.text $ show item.photo ]
    , HH.td_ [ HH.text $ fromMaybe "" item.pwf ]
    , HH.td [ tdAlign false ] [ HH.text $ W.maybeInt2Str item.gpo "" ]
    , HH.td_ [ HH.text $ fromMaybe "" item.stdFrame ]
    , HH.td_ [ HH.text $ fromMaybe "" item.shootDate ]
    , HH.td_ [ HH.text $ fromMaybe "" item.ata ]
    , HH.td_ [ HH.text $ fromMaybe "" item.atd ]
    ]

createTable
  :: forall w r
  . Array
      { loc :: String
      , gps :: Int
      , edn :: Maybe String
      , edt :: Maybe Int
      , photo :: Int
      , pwf :: Maybe String
      , gpo :: Maybe Int
      , stdFrame :: Maybe String
      , shootDate :: Maybe String
      , ata :: Maybe String
      , atd :: Maybe String
      | r
      }
  -> SortField
  -> Boolean
  -> HTML w MainAction
createTable items sf isAsc =
  let
    rows = map createRow items
  in
    HH.table
      [ HP.classes [ ClassName "sortable ps-mt-1" ] ]
      [ tableHead sf isAsc
      , HH.tbody_ rows
      ]

-}
