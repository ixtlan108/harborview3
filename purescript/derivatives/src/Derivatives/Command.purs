module Derivatives.Command
  where

import Prelude

import Control.Monad.State.Class (class MonadState)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Derivatives.Actions (MainAction(..))
import Derivatives.Adapter as Adapter
import Derivatives.State (State)
import Derivatives.Table.SortField (SortField)
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
  (H.modify_ \stx -> stx { risc = risc }) *>
  case risc of
    Nothing ->
      pure unit
    Just risc1 ->
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
          _ =  Table.setTableItemSelected curOpx1 isChecked
        in
        (H.modify_ \stx -> stx { opx = [] }) *>
        (H.modify_ \stx -> stx { opx = items })

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
    pure unit
  RiscChange s ->
    handleRiscChange $ HC.umap Risc s
  IvChecked b ->
    pure unit
  TableItemChecked lnr b ->
    handleTableItemChecked lnr b
  TableSort sf _ ->
    handleTableSort sf
