module Derivatives.View where

import Prelude

import Data.Maybe (Maybe(..))
import Derivatives.Actions (MainAction(..),PurchaseAction(..))
import Derivatives.Command (handleAction)
import Derivatives.State (State, defaultState)
import Derivatives.Table.SortField (SortField(..))
import Derivatives.Table.Table as Table
import Derivatives.UI as UI
import Halogen.HTML (HTML)
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (ClassName(..))
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import HarborView.Common as HC
import HarborView.ModalDialog as DLG
import HarborView.UI (Title(..))


component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { initialState: \_ ->
        defaultState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }


render :: forall cs m. State -> H.ComponentHTML MainAction cs m
render st =
  HH.div [ HP.classes [ ClassName "containerx" ]]
    [ HH.div [ HP.classes [ ClassName "inputs" ]]
      [ (UI.pageSelect $ show st.page)
        , UI.tickerSelect (HC.toSelect st.ticker)
        , UI.calcRisc
        , UI.inpRisc Nothing
        --, UI.inpRisc st.risc
        , UI.ivCheck st.ivNotZero
        , UI.calcRiscOnSelectedCheck st.calcRiscSelected
      ]
    , HH.div [ HP.classes [ ClassName "derivatives" ]]
      [ Table.createTable st.opx st.sortField true ]
    , DLG.modalDialog
        (Title "Purchase Option")
        st.modalPurchase
        (PDA <<< XOk)
        (PDA <<< XCancel) $
        modalContent
    ]

modalContent :: forall w. HTML w MainAction
modalContent =
  HH.div_ []
