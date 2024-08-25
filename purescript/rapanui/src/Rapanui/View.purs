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
import HarborView.UI.Button (ButtonParams, mkButton)
import HarborView.UI.Checkbox as CB
import HarborView.UI.Common (Title(..))
import HarborView.UI.Input (InputParams)
import HarborView.UI.Input as Inp

import Rapanui.Command (handleAction)
import Rapanui.Common (MainAction(..), Oid(..), OptionTicker(..), Rtyp(..))
import Rapanui.Critter.Rules (StockOptionPurchase, Critter, AcceptRule)
import Rapanui.State (State, defaultState)
import Web.UIEvent.MouseEvent (MouseEvent)

--noSort ∷ ∀ r i. Array (IProp (class ∷ String | r) i)
--noSort =
--  [ HP.classes [ ClassName "no-sort" ] ]

--        [ HH.th UI.noSort [ HH.text "Id" ]
tableHeader :: forall w. HTML w MainAction
tableHeader =
  HH.thead []
    [ HH.tr
        []
        [ HH.th [] [ HH.text "Oid" ]
        , HH.th [] [ HH.text "Sell" ]
        , HH.th [] [ HH.text "Status" ]
        , HH.th [] [ HH.text "-" ]
        , HH.th [] [ HH.text "Acc.oid" ]
        , HH.th [] [ HH.text "Rtyp" ]
        , HH.th [] [ HH.text "Desc" ]
        , HH.th [] [ HH.text "Value" ]
        , HH.th [] [ HH.text "Active" ]
        ]
    ]

critterPart :: forall w. Maybe Critter -> Array (HTML w MainAction)
critterPart crit =
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
      in
        [ HH.td [] [ HH.text (Common.fromInt oid) ]
        , HH.td [] [ HH.text ("10") ]
        , HH.td [] [ HH.text (Common.fromInt c.status) ]
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
        Rtyp rtyp = curAcc.rtyp
        cbActive =
          CB.mkCheckboxSimple (CB.defaultSimpleChecboxParam $ IsActive oid)
      in
        [ HH.td [] [ HH.text (Common.fromInt oid) ]
        , HH.td [] [ HH.text (Common.fromInt rtyp) ]
        , HH.td [] [ HH.text "rtyp desc" ]
        --, HH.td [] [ HH.text (rtypDesc curAcc.rtyp) ]
        , HH.td [] [ HH.text (Common.numToString curAcc.value) ]
        , HH.td [] [ cbActive ]
        --, HH.td [] [ H.a [ A.href "#", A.class "newdnyrule href-td", E.onClick (DenyRuleMsgFor (NewDenyRule <| Oid curAcc.oid)) ] [ HH.text "New Deny" ] ]
        ]

critAcc1Tr :: forall w. Maybe Critter -> Maybe AcceptRule -> HTML w MainAction
critAcc1Tr crit acc =
  let
    tdRow =
      Array.concat [ critterPart crit, accPart acc ]
  in
    HH.tr [] tdRow

acc1Tr :: forall w. AcceptRule -> HTML w MainAction
acc1Tr acc =
  let
    tdRow =
      Array.concat [ critterPart Nothing, accPart (Just acc) ]
  in
    HH.tr [] tdRow

accsTr :: forall w. Maybe (Array AcceptRule) -> Array (HTML w MainAction)
accsTr acc =
  case acc of
    Nothing -> []
    Just acc1 -> map acc1Tr acc1

critterRows :: forall w. Critter -> Array (HTML w MainAction)
critterRows crit =
  case crit.accRules of
    [] ->
      [ critAcc1Tr (Just crit) Nothing ]

    [ acc ] ->
      [ critAcc1Tr (Just crit) (Just acc) ]

    items ->
      let
        firstAcc =
          Array.head items

        firstRow =
          critAcc1Tr (Just crit) firstAcc

      in
        firstRow : accsTr (Array.tail items)

critterArea :: forall w. StockOptionPurchase -> Array (HTML w MainAction)
critterArea opx =
  Array.concat (map critterRows opx.critters)

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

{-
  emptyTable
createTable_ [ item ] =
  HH.table_
    [ gpObjHead
    , HH.tbody_ $ createTableRows item
    ]
createTable_ all =
  let
    allx = Array.concat $ map createTableRows all
  in
    HH.table
      [ HP.classes [ ClassName "sortable" ] ]
      [ gpObjHead
      , HH.tbody_ $ allx
      ]
-}

createTable :: ∀ w. State -> HTML w MainAction
createTable st =
  HH.div_ $ map details st.stockOptions

--createTable_ st.stockOptions

defaultButtonParams :: forall i. String -> (MouseEvent -> i) -> ButtonParams i
defaultButtonParams t curEvt =
  let
    clazz =
      "ps-btn btn btn-outline-success"
  in
    { title: Title t
    , evt: curEvt
    , btnClazz: [ ClassName clazz ]
    , disabled: false
    }

-- defaultInputParams :: InputParams MainAction
-- defaultInputParams =
--   { title: Title "Timer (sec)"
--   , evt: Noop
--   , inpVal: InpNum Nothing
--   , lblClasses: []
--   , inpClasses: []
--   , spanClasses: []
--   , disabled: false
--   , dateMax: ""
--   }

defaultInputParams :: forall i. (String -> i) -> InputParams i
defaultInputParams curEvt =
    { evt: curEvt
    , style: Nothing
    , disabled: false
    , inpClasses: [ ClassName "form-control" ]
    , spanClasses: [ ClassName "form-group" ]
    , dateMax: Nothing -- DU.todayStr
    }

component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { initialState: \_ ->
        defaultState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

defaultLabelClasses :: Array ClassName
defaultLabelClasses = [ ClassName "ps-label" ]

render :: ∀ s m. MonadAff m => State -> H.ComponentHTML MainAction s m
render st =
  let
    interval =
      (Inp.mkInputWrapper (Title "Interval") defaultLabelClasses
        (Inp.mkInputNum st.interval $ (defaultInputParams $ IntervalChange))) -- { style = Just $ isDoneStyle phs.isDone }))

    tick =
      (Inp.mkInputWrapper (Title "Tick") defaultLabelClasses
        (Inp.mkInputInt (Just st.tickDemo) $ (defaultInputParams $ Noop))) -- { style = Just $ isDoneStyle phs.isDone }))
  in
  HH.div []
    [ mkButton $ defaultButtonParams "Fetch Purchases" FetchPurchases
    , mkButton $ defaultButtonParams "Start Timer" (Timer true)
    , mkButton $ defaultButtonParams "Stop Timer" (Timer false)
    , interval
    , tick
    --, mkInput defaultInputParams { inpVal = InpNum st.interval, evt = IntervalChange }
    --, mkInput_ defaultInputParams { inpVal = InpI $ Just st.tickDemo }
    , createTable st
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
