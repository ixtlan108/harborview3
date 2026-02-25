module Derivatives.Command
  where

import Control.Monad.State.Class (class MonadState)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import HarborView.Common (StockTicker(..))
import Derivatives.State (State)
import Derivatives.Actions (MainAction(..))
--import Derivatives.Types (Page(..))
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
  case ticker of
    Nothing ->
      pure unit
    Just ticker1 ->
      pure unit

handleAction
  :: forall cs o m
    . MonadAff m
  => MainAction
  -> H.HalogenM State MainAction cs o m Unit
handleAction = case _ of
  PageChange s ->
    let
      page = T.fromString s
    in
    pure unit
  TickerChange s ->
    let
      ticker = HC.fromSelectI StockTicker s
    in
    handleTickerChange ticker
  FetchDerivatives s ->
    pure unit
  CalcRisc _ ->
    pure unit
  RiscChange s ->
    pure unit
