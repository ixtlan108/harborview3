module Derivatives.Command
  where

import Prelude

import Control.Monad.State.Class (class MonadState)
import Data.Function.Uncurried (runFn2)
import Data.Foldable as Foldable
import Data.Traversable as Traversable
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Derivatives.Actions (MainAction(..))
import Derivatives.Adapter as Adapter
import Derivatives.State (State)
import Derivatives.Table.SortField (SortField)
import Derivatives.Table.Table (TableItem)
import Derivatives.Table.Table as Table
import Derivatives.Table.TableSort as TableSort
import Derivatives.Transform as Transform
import Derivatives.Types (Risc(..))
import Derivatives.Types as T
import Effect.Aff.Class (class MonadAff)
import Effect.Console (logShow)
import Halogen as H
import HarborView.AppStatus (AppStatus)
import HarborView.AppStatus as AppStat
import HarborView.Common (StockTicker(..))
import HarborView.Common as HC


-- handleAppStatus
--   :: forall m.
--      MonadState State m
--   => AppStatus
--   -> m Unit

handleAppStatus
  :: forall m
   . MonadState State m
  => AppStatus
  -> m Unit
handleAppStatus s =
  let
    myModal = AppStat.modalStateFor s "msg"
  in
  (H.modify_
    \stx ->
      stx { risc = Just (T.Risc 12.3) }
  ) *> pure unit

handleTickerChange
  :: forall m
   . MonadState State m
  => MonadAff m
  => Maybe StockTicker
  -> m Unit
handleTickerChange ticker =
  case ticker of
    Nothing ->
      (H.modify_ \stx -> stx { ticker = ticker }) *>
      pure unit
    Just ticker1 ->
      H.get >>= \st ->
        Adapter.fetchDerivatives ticker1 st.page >>= \result ->
          case result of
            Left err ->
              H.liftEffect (logShow err) *>
              handleAppStatus err
            Right result1 ->
              let
                tableItems = Transform.transform result1.payload
              in
              H.liftEffect (logShow tableItems) *>
              (H.modify_ \stx -> stx { ticker = ticker, opx = tableItems }) *>
              pure unit

handleRiscChange
  :: forall m
   . MonadState State m
  => MonadAff m
  => Maybe Risc
  -> m Unit
handleRiscChange risc =
  H.get >>= \st ->
    let
      items = Array.filter (\x -> x.selected == true) st.opx
      riscFn = (\x -> Table.setRisc x risc)
      origOpx = st.opx
    in
    H.liftEffect (Traversable.traverse_ riscFn items) *>
    (H.modify_ \stx -> stx { opx = origOpx, risc = risc }) *>
    pure unit


handleTableSort
  :: forall m
   . MonadState State m
  => MonadAff m
  => SortField
  -> m Unit
handleTableSort sf =
  H.get >>= \st ->
    let
      so = not st.sortOrderAsc
      sortedItems = TableSort.sortResponse sf so st.opx
    in
    H.modify_ \stx -> stx { opx = sortedItems, sortOrderAsc = so, sortField = sf }

  -- (H.modify_ \stx -> stx { risc = risc }) *>

calcRiscSingle
  :: forall  m
   . MonadState State m
  => MonadAff m
  => TableItem
  -> m Unit
calcRiscSingle item =
  pure unit

handleTableItemChecked
  :: forall m
   . MonadState State m
  => MonadAff m
  => Int
  -> Boolean
  -> m Unit
handleTableItemChecked lnr isChecked =
  H.get >>= \st ->
    let
      curOpx = Array.find (\x -> x.lnr == lnr) st.opx
    in
    case curOpx of
      Nothing ->
        pure unit
      Just curOpx1 ->
        let
          items = st.opx
        in
        H.liftEffect
          (Table.setSelected curOpx1 isChecked *>
           Table.setRisc curOpx1 st.risc) *>
        (H.modify_ \stx -> stx { opx = items })


handleCalcRisc
  :: forall m
   . MonadState State m
  => MonadAff m
  => m Unit
handleCalcRisc =
  let
    riscItems = [ { ticker: "YAR6L320", risc: 4.0 }
                  , { ticker: "YAR6L300", risc: 5.0 }
                ]
  in
  Adapter.calcRisc riscItems >>= \result ->
    H.liftEffect (logShow result) *>
    pure unit

handleAction
  :: forall cs o m
    . MonadAff m
  => MainAction
  -> H.HalogenM State MainAction cs o m Unit
handleAction = case _ of
  PageChange s ->
    H.modify_ \stx -> stx { page = (T.fromString s) }
  TickerChange s ->
    handleTickerChange $ HC.fromSelectI StockTicker s
  FetchDerivatives s ->
    pure unit
  CalcRisc _ ->
    handleCalcRisc
  RiscChange s ->
    handleRiscChange $ HC.umap Risc s
  IvChecked b ->
    H.modify_ \stx -> stx { ivNotZero = b }
  CalcRiscSelectedChecked b ->
    H.modify_ \stx -> stx { calcRiscSelected = b }
  TableItemChecked lnr b ->
    handleTableItemChecked lnr b
  TableSort sf _ ->
    handleTableSort sf
