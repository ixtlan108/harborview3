module Derivatives.Command
  where

import Control.Monad.State.Class (class MonadState)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import HarborView.Common (StockTicker(..))
import Derivatives.State (State)
import Derivatives.Actions (MainAction(..))
import Derivatives.Types (Risc(..))
import Derivatives.Types as T
import HarborView.Common as HC

import Prelude

handleTickerChange
  :: forall m
   . MonadState State m
  => MonadAff m
  => Maybe StockTicker
  -> m Unit
handleTickerChange ticker =
  (H.modify_ \stx -> stx { ticker = ticker }) *>
  case ticker of
    Nothing ->
      pure unit
    Just ticker1 ->
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
