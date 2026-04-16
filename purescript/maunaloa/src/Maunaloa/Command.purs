module Maunaloa.Command 
  where

import Prelude

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Maunaloa.Actions (Action(..))
import Maunaloa.State (State)

handleAction :: forall cs o m. MonadAff m => Action -> H.HalogenM State Action cs o m Unit
handleAction = case _ of
  SelectChange s ->
    pure unit
  Initialize ->
    pure unit
  ResetChart _ ->
    pure unit
  AddLevelLine _ ->
    pure unit
  FetchRiscLines _ ->
    pure unit
  Previous _ ->
    pure unit
  Next _ ->
    pure unit
  Last _ ->
    pure unit
  DeleteNonPersistent _ ->
    pure unit
  DeleteAll _ ->
    pure unit
  FetchSpot _ ->
    pure unit

{-
handleAction :: forall cs o m. MonadAff m => Action -> H.HalogenM State Action cs o m Unit
handleAction = case _ of
  SelectChange s ->
    H.get >>= \st ->
      ( if s == "0" then
          liftEffect (Core.paintEmpty st.ct)
        else
          liftEffect (Core.paint st.ct (StockTicker s) (Drop st.dropAmt) st.takeAmt)
      ) *>
    H.modify_ \stx -> stx { selectedTicker = s }
  Initialize ->
    H.gets _.ct >>= \ct1 ->
      liftEffect (
        (logShow $ Common.chartTypeAsInt ct1) *>
        Core.initEvents ct1
      )
  ResetChart _ ->
    H.get >>= \st ->
      if st.selectedTicker  == "0" then
        pure unit
      else
        let
          ticker = StockTicker st.selectedTicker
        in
        liftEffect (
          Core.resetCharts *>
          Core.paint st.ct ticker (Drop 0) st.takeAmt
        ) *>
        H.modify_ \stx -> stx { dropAmt = 0 }
  AddLevelLine _ ->
    H.gets _.ct >>= \ct1 ->
      liftEffect (Core.addLevelLine ct1)
  FetchRiscLines _ ->
    H.get >>= \st ->
      H.liftAff $ Core.fetchLevelLines st.ct (StockTicker st.selectedTicker)
  Previous _ ->
    navigate 90
  Next _ ->
    navigate (-90)
  Last _ ->
    navigate 0
  DeleteNonPersistent _ ->
    -- H.get >>= \st ->
    --   if st.selectedTicker == "0" then
    --     pure unit
    --   else
    --     liftEffect $ Core.deleteNonPersistentLevelLines st.ct
    pure unit
  DeleteAll _ ->
    -- H.get >>= \st ->
    --   if st.selectedTicker == "0" then
    --     pure unit
    --   else
    --     H.liftAff $ Core.deleteAllLevelLines st.ct (StockTicker st.selectedTicker)
    pure unit
  FetchSpot _ ->
    -- H.get >>= \st ->
    --   if st.selectedTicker == "0" then
    --     pure unit
    --   else
    --     H.liftAff $ Core.fetchSpot st.ct (StockTicker st.selectedTicker)
    pure unit
-}
