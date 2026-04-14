module Derivatives.Table.Table
  where

import Prelude

import Effect (Effect)
import Data.Maybe (Maybe(..))
import Data.Function.Uncurried (Fn3, Fn2, runFn2, runFn3)
import DOM.HTML.Indexed.InputType (InputType(..))
import Halogen.HTML (ClassName(..), HTML)
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (IProp)
import Halogen.HTML.Properties as HP
import Derivatives.Actions (MainAction(..),PurchaseAction(..))
import Derivatives.Table.SortField (SortField(..))
import Derivatives.Table.TableItem (TableItem)
import Derivatives.Types (Risc(..))
--import Report.Report1.Types (Report1Action(..))
--import Waimea.Common as W
--import Oahu.SortField (SortField(..))
import Web.HTML.Common (AttrName(..))


-- {{{tdAlign 
tdAlign :: forall r i. Boolean -> IProp r i
tdAlign isLeft =
  if isLeft then
    HP.attr (AttrName "align") "left"
  else
    HP.attr (AttrName "align") "right"

-- }}}


-- {{{thSortAsc 
thSortAsc :: forall r i. Boolean -> IProp r i
thSortAsc asc =
  if asc then
    HP.attr (AttrName "aria-sort") "ascending"
  else
    HP.attr (AttrName "aria-sort") "descending"

-- }}}

noSort ∷ ∀ r i. Array (IProp (class ∷ String | r) i)
noSort =
  [ HP.classes [ ClassName "no-sort" ] ]

-- {{{sortedTh 
sortedTh :: forall w. SortField -> SortField -> String -> Boolean -> HTML w MainAction
sortedTh curSortField sortField title isAsc =
  if curSortField == sortField then
    HH.th [ HE.onClick (TableSort sortField), thSortAsc isAsc ] [ HH.text title ]
  else
    HH.th [ HE.onClick (TableSort sortField) ] [ HH.text title ]

-- }}}

unSortedTh :: forall w. String -> HTML w MainAction
unSortedTh title =
  HH.th noSort [ HH.text title ]

--{{{ tableHead 
tableHead :: forall w. SortField -> Boolean -> HTML w MainAction
tableHead sf isAsc =
  let
    thTicker = sortedTh sf SfTicker "Ticker" isAsc
    thIvBid = sortedTh sf SfIvBid "IvBid" isAsc
    thIvAsk = sortedTh sf SfIvAsk "IvAsk" isAsc
  in
  HH.thead_
    [ HH.tr_
        [ unSortedTh "Lnr"
          , unSortedTh "Selected"
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
  --}}}

foreign import setRisc_ :: Fn2 TableItem Number (Effect Unit)

-- {{{setRisc 
setRisc :: TableItem -> Maybe Risc -> (Effect Unit)
setRisc item risc =
  let
    risc1 = case risc of
              Nothing -> 0.0
              Just (Risc risc2) -> risc2
  in
  runFn2 setRisc_ item risc1

-- }}}

foreign import setSelected_ :: Fn2 TableItem Boolean (Effect Unit)

setSelected :: TableItem -> Boolean -> Effect Unit
setSelected =
  runFn2 setSelected_

foreign import setCalcRiscResult_ :: Fn3 TableItem Number Number (Effect Unit)

setCalcRiscResult :: TableItem -> Number -> Number -> Effect Unit
setCalcRiscResult =
  runFn3 setCalcRiscResult_

-- {{{tableItemCheck 
tableItemCheck :: forall w. Int -> Boolean -> HTML w MainAction
tableItemCheck lnr isChecked =
  HH.div [ HP.classes [ ClassName "form-check form-switch" ]]
    [ HH.input [ HP.type_ InputCheckbox
                , HP.classes [ ClassName "form-check-input" ]
                , HP.checked isChecked
                , HE.onChecked (TableItemChecked lnr)]
    ]

purchase :: forall w. TableItem -> HTML w MainAction
purchase item =
  HH.button [HE.onClick (PDA <<< XOpen item), HP.classes [ ClassName "ps-btn btn btn-outline-success"]] [HH.text "Purchase"]

-- }}}

-- {{{ createRow 
createRow :: forall w. TableItem -> HTML w MainAction
createRow item =
  HH.tr_
    [ HH.td_ [ HH.text $ show item.lnr ]
    , HH.td_ [ tableItemCheck item.lnr item.selected ]
    , HH.td_ [ purchase item ]
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

-- }}}

-- {{{createTable 
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

-- }}}
