module Derivatives.Command where

import Prelude

import Control.Monad.State.Class (class MonadState)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable as Traversable
import Derivatives.Actions (MainAction(..), PurchaseAction(..))
import Derivatives.Adapter as Adapter
import Derivatives.Response (RiscResponse)
import Derivatives.State (State)
import Derivatives.Table.SortField (SortField)
import Derivatives.Table.TableItem (TableItem)
import Derivatives.Table.Table as Table
import Derivatives.Table.TableSort as TableSort
import Derivatives.Transform as Transform
import Derivatives.Types (RiscRequest, Risc(..))
import Derivatives.Types as T
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Console (logShow)
import Halogen as H
import Halogen.HTML.Elements (p)
import HarborView.AppStatus (AppStatus)
import HarborView.AppStatus as AppStat
import HarborView.Common (StockTicker(..), Amount(..))
import HarborView.Common as HC
import HarborView.ModalDialog (DialogState(..))

-- handleAppStatus
--   :: forall m.
--      MonadState State m
--   => AppStatus
--   -> m Unit

handleAppStatus
  :: forall m
   . MonadState State m
  => AppStatus
  -> String
  -> m Unit
handleAppStatus s msg =
  let
    myModal = AppStat.modalStateFor s msg
  in
    ( H.modify_
        \stx ->
          stx { modalBottom = myModal }
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
                handleAppStatus err "handleTickerChange"
            Right result1 ->
              let
                tableItems = Transform.transform result1.payload
              in
                H.liftEffect (logShow tableItems)
                  *> (H.modify_ \stx -> stx { ticker = ticker, opx = tableItems })
                  *>
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
      H.liftEffect (Traversable.traverse_ riscFn items)
        *> (H.modify_ \stx -> stx { opx = origOpx, risc = risc })
        *>
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
  :: forall m
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
              ( Table.setSelected curOpx1 isChecked *>
                  Table.setRisc curOpx1 st.risc
              ) *>
              (H.modify_ \stx -> stx { opx = items })

toRiscRequest :: TableItem -> RiscRequest
toRiscRequest item =
  { ticker: item.ticker, risc: item.risc }

setRiscResult :: Array TableItem -> RiscResponse -> Effect Unit
setRiscResult items response =
  let
    curOpx = Array.find (\x -> x.ticker == response.ticker) items
  in
    case curOpx of
      Nothing ->
        pure unit
      Just curOpx1 ->
        Table.setCalcRiscResult curOpx1 response.stockprice response.optionprice

setRiscResults
  :: forall m
   . MonadAff m
  => Array TableItem
  -> Array RiscResponse
  -> m Unit
setRiscResults items responses =
  let
    riscFn = setRiscResult items
  in
    H.liftEffect (Traversable.traverse_ riscFn responses)

handleCalcRisc
  :: forall m
   . MonadState State m
  => MonadAff m
  => m Unit
handleCalcRisc =
  H.get >>= \st ->
    let
      riscItems = map toRiscRequest $ Array.filter (\x -> x.selected == true) st.opx
    in
      Adapter.calcRisc riscItems >>= \result ->
        case result of
          Left err ->
            H.liftEffect (logShow err) *>
              handleAppStatus err "handleCalcRisc"
          Right result1 ->
            let
              origItems = st.opx
            in
              setRiscResults st.opx result1.payload
                *> H.liftEffect (logShow result1.payload)
                *>
                  (H.modify_ \stx -> stx { opx = origItems })

handlePurchaseAction
  :: forall m
   . MonadState State m
  => MonadAff m
  => PurchaseAction
  -> m Unit
handlePurchaseAction = case _ of
  XOk _ ->
    (H.modify_ \stx -> stx { modalPurchase = DialogHidden }) *>
      H.get >>= \st -> 
        let 
          x = 
            st.purchaseItem >>= \item1 -> 
              st.volume >>= \(Amount vol1) -> 
                Just { ticker: item1.ticker, volume: vol1 }
        in
        case x of 
          Nothing ->
            pure unit
          Just x1 ->
            --H.liftEffect (logShow x1) *>
            Adapter.purchase x1.ticker x1.volume >>= \result ->
              case result of
                Left err ->
                  handleAppStatus err "handlePurchaseAction XOk"
                Right result1 ->
                  pure unit
  XCancel _ ->
    H.modify_ \stx -> stx { modalPurchase = DialogHidden }
  XOpen s _ ->
    H.modify_ \stx -> stx { modalPurchase = DialogVisible, purchaseItem = Just s }
  XVolume s ->
    H.modify_ \stx -> stx { volume = HC.imap Amount s }

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
  PDA act ->
    handlePurchaseAction act
