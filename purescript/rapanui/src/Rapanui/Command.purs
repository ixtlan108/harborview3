module Rapanui.Command
  ( handleAction
  ) where

import Prelude

import Control.Monad.State.Class (class MonadState)
import Data.Array as A
import Data.Either (Either(..))
import Data.Maybe (Maybe(..),fromMaybe)
import Data.Number (fromString)
import Effect.Aff (Milliseconds(..))
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Halogen (SubscriptionId)
import Halogen as H
import Halogen.Subscription (Emitter)
--import HarborView.Common (handleError)
import HarborView.HalogenCommon (timer)
import HarborView.ModalDialog (ModalState(..))
import HarborView.AppStatus (AppStatus)
import HarborView.AppStatus as AppStat
import Rapanui.Common (MainAction(..))
import Rapanui.Critter.Core as Core
import Rapanui.Nordnet.Adapter as Nordnet
import Rapanui.Nordnet.CoreJson (CritterResponse)
import Rapanui.Nordnet.Transform as Transform
import Rapanui.State (State)
import Rapanui.StockMarket.OptionSaleItem (OptionSale)
import Rapanui.StockMarket.OptionSaleItem as OSI

handleAppStatus
  :: forall m
   . MonadState State m
  => MonadAff m
  => AppStatus
  -> String
  -> m Unit
handleAppStatus appStatus msg =
  let
    myModal = AppStat.modalStateFor appStatus msg
  in
    H.modify_
      \stx ->
        stx { modalStateBottom = myModal }

handleAppStatus2
  :: forall r m.
     MonadState State m
  => MonadAff m
  => { status :: Int, msg :: Maybe String | r}
  -> m Unit
handleAppStatus2 response =
  let
    myModal = AppStat.modalStateFor (AppStat.fromInt response.status) (fromMaybe "" response.msg)
  in
  H.modify_
    \stx ->
      stx { modalStateBottom = myModal }

mapJsonResult
  :: forall m
   . MonadState State m
  => CritterResponse
  -> m Unit
mapJsonResult result =
  case result.payload of
    [] ->
      pure unit
    items ->
      H.modify_
        \stx ->
          stx
            { stockOptions = Transform.mapPayloads items
            }

unsubscribeTimer
  :: forall slots output m r
  . H.HalogenM { subId :: Maybe SubscriptionId
                | r
                } MainAction slots output m Unit
unsubscribeTimer =
  H.get >>= \st ->
    case st.subId of
      Nothing ->
        pure unit
      Just su ->
        H.unsubscribe su

handleTimer
  :: forall cs o m r
  . MonadAff m
  => Boolean
  -> H.HalogenM { emitter :: Maybe (Emitter MainAction)
                , interval :: Maybe Number
                , subId :: Maybe SubscriptionId
                | r
                } MainAction cs o m Unit
handleTimer subs =
  if subs == true then
    H.get >>= \st ->
      case st.emitter of
        Nothing ->
          case st.interval of
            Nothing ->
              pure unit
            Just i1 ->
              timer (Milliseconds (i1 * 1000.0)) Tick >>= \tx ->
                H.subscribe tx >>= \sx ->
                  H.modify_
                    \stx -> stx { subId = Just sx, emitter = Just tx }
        Just em ->
          case st.subId of
            Nothing ->
              H.subscribe em >>= \sx ->
                H.modify_
                  \stx -> stx { subId = Just sx }
            Just su ->
              H.unsubscribe su *>
                H.subscribe em >>= \sx ->
                H.modify_
                  \stx -> stx { subId = Just sx }
  else
    unsubscribeTimer

handleFetchCritters
  :: forall m
   . MonadState State m
  => MonadAff m
  => m Unit
handleFetchCritters =
  H.get >>= \st ->
    H.liftAff Nordnet.fetchCritters >>= \result ->
      case result of
        Left err ->
          handleAppStatus err "Nordnet.fetchCritters"
        Right result1 ->
          if result1.status > 0 then
            handleAppStatus2 result1
          else
            mapJsonResult result1
    -- case st.stockOptions of
    --   [] ->
    --     H.liftAff Nordnet.fetchCritters >>= \result ->
    --       case result of
    --         Left err ->
    --           handleAppStatus err "Nordnet.fetchCritters"
    --         Right result1 ->
    --           if result1.status > 0 then
    --             handleAppStatus2 result1
    --           else
    --             mapJsonResult result1
    --   _ ->
    --     pure unit

handleTickResult
  :: forall m
   . MonadState State m
  => MonadAff m
  => Array OptionSale
  -> m Unit
handleTickResult items =
  if A.null items then
    pure unit
  else
    let
      vs = OSI.validOptionSales items
    in
    if A.null vs then
      pure unit
    else
      H.liftAff (Nordnet.registerSales vs) >>= \result ->
        case result of
          Left err ->
            handleAppStatus err "Nordnet.registerSales"
          Right result1 ->
            if result1.status > 0 then
              handleAppStatus2 result1
            else
              (liftEffect $ logShow $ "REGISTER SALES: " <> show result) *>
              handleAppStatus2 { status: 0, msg: Just "registerSales OK" }

handleTickErrors
  :: forall m
   . MonadState State m
  => MonadAff m
  => Array OptionSale
  -> m Unit
handleTickErrors sales =
  pure unit

handleTick
  :: forall m
   . MonadState State m
  => MonadAff m
  => m Unit
handleTick =
  H.get >>= \st ->
    H.liftAff (Core.applyPurchases st.stockOptions) >>= \result ->
      --(liftEffect $ logShow $ result) *>
      (H.modify_
        \stx ->
          stx { tickCounter = stx.tickCounter + 1, optionSales = result }) *>
      handleTickErrors result *>
      handleTickResult result


handleAction
  :: forall cs o m
   . MonadAff m
  => MainAction
  -> H.HalogenM State MainAction cs o m Unit
handleAction = case _ of
  Initialize ->
    pure unit
  FetchPurchases _ ->
    handleFetchCritters
  IsActive accOid checked ->
    H.liftAff (Nordnet.toggleAccActive accOid checked) >>= \result ->
      case result of
        Left err ->
          handleAppStatus err "Nordnet.toggleAccActive"
        Right result1 ->
          if result1.status > 0 then
            handleAppStatus2 result1
          else
            pure unit
  Timer subs _ ->
    handleTimer subs
  Tick ->
    handleTick
  Noop _ ->
    pure unit
  IntervalChange s ->
    unsubscribeTimer *>
      H.modify_
        \stx -> stx { interval = fromString s, emitter = Nothing }
  ModalDialogBottomClose _ ->
    H.modify_ \stx -> stx { modalStateBottom = ModalHidden }
