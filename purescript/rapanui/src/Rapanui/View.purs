module Rapanui.View
  ( component
  , createTable
  , render
  ) where

import Prelude

import Data.Array ((:))
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (ClassName(..), HTML)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import HarborView.Common as Common
import HarborView.ModalDialog as DLG
import HarborView.ModalDialog as DLG
import HarborView.Menu (mkMenu, ActivePage(..))
--import HarborView.ModalDialog as DLG
--import HarborView.UI.Checkbox as CB
import Rapanui.Command (handleAction)
import Rapanui.Common (MainAction(..), Oid(..), Ask(..), OptionTicker(..), rtypDesc, Log)
import Rapanui.Critter.Rules (StockOptionPurchase, Critter, AcceptRule)
import Rapanui.State (State, defaultState)
import Rapanui.UI as RU
import Rapanui.LogTable as LogTable
--import Rapanui.StockMarket.OptionSaleItem (OptionSale)

--foreign import curTime :: String

--noSort ∷ ∀ r i. Array (IProp (class ∷ String | r) i)
--noSort =
--  [ HP.classes [ ClassName "no-sort" ] ]

--        [ HH.th UI.noSort [ HH.text "Id" ]
tableHeader :: forall w. HTML w MainAction
tableHeader =
  HH.thead []
    [ HH.tr
        []
        [ HH.th [] [ HH.text "Cid" ]
        , HH.th [] [ HH.text "Ask" ]
        , HH.th [] [ HH.text "Status" ]
        , HH.th [] [ HH.text "-" ]
        , HH.th [] [ HH.text "Acc.oid" ]
        , HH.th [] [ HH.text "Rtyp" ]
        , HH.th [] [ HH.text "Desc" ]
        , HH.th [] [ HH.text "Value" ]
        , HH.th [] [ HH.text "Active" ]
        ]
    ]

critterPart :: forall w. Maybe Ask -> Maybe Critter -> Array (HTML w MainAction)
critterPart ask crit =
  case crit of
    Nothing ->
      [ HH.td [] [ HH.text "-" ]
      , HH.td [] [ HH.text "-" ]
      , HH.td [] [ HH.text "-" ]
      , HH.td [] [ HH.text "-" ]
      ]

    Just c ->
      let
        Oid oid = c.oid
        askPrice =
          case ask of
            Just (Ask value) -> value
            _ -> 0.0
      in
        [ HH.td [] [ HH.text (Common.fromInt oid) ]
        , HH.td [] [ HH.text (show askPrice) ]
        --, HH.td [] [ HH.text (Common.fromInt c.status) ]
        , HH.td [] [ HH.text (show c.status) ]
        , HH.td [] [ HH.text "New Acc Rule" ]
        --, HH.td [] [ H.a [ A.href "#", A.class "newaccrule href-td", E.onClick (AccRuleMsgFor (NewAccRule <| Oid c.oid)) ] [ HH.text "New Acc" ] ]
        ]


accPart :: forall w. Maybe AcceptRule -> Array (HTML w MainAction)
accPart acc =
  case acc of
    Nothing ->
      [ HH.td [] [ HH.text "-" ]
      , HH.td [] [ HH.text "-" ]
      , HH.td [] [ HH.text "-" ]
      , HH.td [] [ HH.text "-" ]
      , HH.td [] [ HH.text "-" ]
      ]

    Just curAcc ->
      let
        Oid oid = curAcc.oid
        -- Rtyp rtyp = curAcc.rtyp
        -- cbActive =
        --   CB.mkCheckboxSimple (CB.defaultSimpleChecboxParam $ IsActive oid)
      in
        [ HH.td [] [ HH.text (Common.fromInt oid) ]
        , HH.td [] [ HH.text (show curAcc.rtyp) ]
        , HH.td [] [ HH.text $ rtypDesc curAcc.rtyp ]
        --, HH.td [] [ HH.text (rtypDesc curAcc.rtyp) ]
        , HH.td [] [ HH.text (Common.numToString curAcc.value) ]
        --, HH.td [] [ cbActive ]
        --, HH.td [] [ H.a [ A.href "#", A.class "newdnyrule href-td", E.onClick (DenyRuleMsgFor (NewDenyRule <| Oid curAcc.oid)) ] [ HH.text "New Deny" ] ]
        ]

critAcc1Tr :: forall w. Maybe Ask -> Maybe Critter -> Maybe AcceptRule -> HTML w MainAction
critAcc1Tr ask crit acc =
  let
    tdRow =
      Array.concat [ critterPart ask crit, accPart acc ]
  in
    HH.tr [] tdRow

acc1Tr :: forall w. AcceptRule -> HTML w MainAction
acc1Tr acc =
  let
    tdRow =
      Array.concat [ critterPart Nothing Nothing, accPart (Just acc) ]
  in
    HH.tr [] tdRow

accsTr :: forall w. Maybe (Array AcceptRule) -> Array (HTML w MainAction)
accsTr acc =
  case acc of
    Nothing -> []
    Just acc1 -> map acc1Tr acc1

critterRows :: forall w. Ask -> Critter -> Array (HTML w MainAction)
critterRows ask crit =
  case crit.accRules of
    [] ->
      [ critAcc1Tr (Just ask) (Just crit) Nothing ]

    [ acc ] ->
      [ critAcc1Tr (Just ask) (Just crit) (Just acc) ]

    items ->
      let
        firstAcc =
          Array.head items

        firstRow =
          critAcc1Tr (Just ask) (Just crit) firstAcc

      in
        firstRow : accsTr (Array.tail items)

critterArea :: forall w. StockOptionPurchase -> Array (HTML w MainAction)
critterArea opx =
  Array.concat (map (critterRows opx.price) opx.critters)

details :: forall w. StockOptionPurchase -> HTML w MainAction
details opx =
  let
    Oid oid = opx.oid
    OptionTicker ticker = opx.ticker
  in
    HH.details []
      [ HH.summary [] [ HH.text ("[ " <> Common.fromInt oid <> "  ] " <> ticker) ]
      , HH.table [ HP.classes [ ClassName "table" ] ]
          [ tableHeader
          , HH.tbody [] (critterArea opx)
          ]
      ]

createTable :: ∀ w. State -> HTML w MainAction
createTable st =
  HH.div_ $ map details st.stockOptions


component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { initialState: \_ ->
        defaultState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

render :: ∀ s m. MonadAff m => State -> H.ComponentHTML MainAction s m
render st =
  let
    interval =
      RU.inpInterval st.interval

    tick =
      RU.inpTick (Just st.tickCounter)

    buttons =
      [ RU.fetchPurchases
      , RU.startTimer
      , RU.stopTimer
      , RU.clearLogs
      ]
  in
  HH.div [ HP.class_ $  ClassName "rapanui--grid-main" ]
    [ mkMenu Rapanui
      , HH.div [ HP.class_ $  ClassName "containerx" ]
        [ HH.div [ HP.classes [ ClassName "buttons" ]] buttons
        , HH.div [ HP.classes [ ClassName "tick-interval" ]] [ interval, tick ]
        , HH.div [ HP.classes [ ClassName "critters" ]] [ createTable st ]
        , HH.div [ HP.classes [ ClassName "logs" ]] [ LogTable.createTable st.logs ]
        , DLG.modalDialogBottom st.modalStateBottom ModalDialogBottomClose
        ]
    ]

{-
[
  {
    "ticker": "NHY9E30",
    "oid": 47,
    "critters": [
      {
        "vol": 10,
        "accRules": [
          {
            "value": 3,
            "active": true,
            "pid": 47,
            "oid": 72,
            "cid": 45,
            "rtyp": 1
          },
          {
            "value": 2,
            "active": false,
            "pid": 47,
            "oid": 73,
            "cid": 45,
            "rtyp": 7
          }
        ],
        "status": 7,
        "oid": 45
      }
    ],
    "price": 5.8
  }
]
-}
