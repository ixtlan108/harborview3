module Rapanui.Command
  ( handleAction
  ) where

import Prelude

import Control.Monad.State.Class (class MonadState)
import Halogen.Subscription (Emitter)
import Halogen (SubscriptionId)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Number (fromString)
import Effect.Aff (Milliseconds(..))
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Halogen as H
import HarborView.Common (handleError)
import HarborView.HalogenCommon (timer)
import Rapanui.Common (MainAction(..))
import Rapanui.Nordnet.Adapter as Nordnet
import Rapanui.Nordnet.CoreJson (CritterResponse)
import Rapanui.Nordnet.Transform as Transform
import Rapanui.State (State)

--import Web.UIEvent.MouseEvent (MouseEvent)

-- data MainAction
--   = Initialize
--   | Demo MouseEvent
--   | Timer Boolean MouseEvent
--   | IsActive Int Boolean
--   | Tick
--   | Noop String

-- timer :: forall m a. MonadAff m => a -> m (HS.Emitter a)
-- timer val = do
--   { emitter, listener } <- H.liftEffect HS.create
--   _ <- H.liftAff $ Aff.forkAff $ forever do
--     Aff.delay $ Milliseconds 1000.0
--     H.liftEffect $ HS.notify listener val
--   pure emitter

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
  :: forall slots output m r
  . MonadAff m
  => Boolean
  -> H.HalogenM { emitter :: Maybe (Emitter MainAction)
                , interval :: Maybe Number
                , subId :: Maybe SubscriptionId
                | r
                } MainAction slots output m Unit
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
    case st.stockOptions of
            [] ->
              H.liftAff Nordnet.fetchCritters >>= \result ->
                case result of
                  Left err ->
                    liftEffect $ handleError err
                  Right result1 ->
                    mapJsonResult result1
            _ ->
              pure unit

handleTick
  :: forall m
    . MonadState State m
  => MonadAff m
  => m Unit
handleTick =
  H.modify_
    \stx ->
      let
        oldVal = stx.tickDemo
      in
        stx { tickDemo = oldVal + 1 }

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
          liftEffect $ handleError err
        Right result1 ->
          (liftEffect $ logShow $ result1)
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

{-
    (liftEffect $ logShow accOid)
      *> (liftEffect $ logShow checked)
      *>
        pure unit
-}
