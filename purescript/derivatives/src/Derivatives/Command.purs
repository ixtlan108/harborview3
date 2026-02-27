module Derivatives.Command
  where

import Prelude

import Control.Monad.State.Class (class MonadState)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Derivatives.Actions (MainAction(..))
import Derivatives.Adapter as Adapter
import Derivatives.State (State)
import Derivatives.Types (Risc(..))
import Derivatives.Types as T
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import HarborView.Common (StockTicker(..))
import HarborView.Common as HC
import HarborView.AppStatus (AppStatusResponse)
import HarborView.AppStatus as AppStat


handleAppStatus
  :: forall m.
     MonadState State m
  => AppStatusResponse
  -> m Unit
handleAppStatus s =
  let
    myModal = AppStat.modalStateFor s.appStatus s.msg
  in
  pure unit
  -- H.modify_
  --   \stx ->
  --     stx { modalStateBottom = myModal }

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
      H.get >>= \st ->
        Adapter.fetchDerivatives ticker1 st.page >>= \result ->
          case result of
            Left err ->
              handleAppStatus err
            Right result1 ->
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

-- handleFetchDerivatives s =
--   A.fetchDerivatives (StockTicker 3) true >>= \result ->
--     pure unit

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
  TableSort sf _ ->
    pure unit
