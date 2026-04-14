module Derivatives.View where

-- {{{ Prelude
import Prelude

import Data.Maybe (Maybe(..))
import Derivatives.Actions (MainAction(..), PurchaseAction(..))
import Derivatives.Command (handleAction)
import Derivatives.State (State, defaultState)
-- import Derivatives.Table.SortField (SortField(..))
import Derivatives.Table.TableItem (TableItem)
import Derivatives.Table.Table as Table
import Derivatives.UI as UI
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML (HTML, ClassName(..))
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import HarborView.Common as HC
import HarborView.ModalDialog as DLG
import HarborView.UI.Common (Title(..))
import HarborView.Common (Amount)

-- }}}

component :: forall q i o m. MonadAff m => H.Component q i o m
component =
  H.mkComponent
    { initialState: \_ ->
        defaultState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

-- {{{ render
render :: forall cs m. State -> H.ComponentHTML MainAction cs m
render st =
  HH.div [ HP.classes [ ClassName "containerx" ] ]
    [ HH.div [ HP.classes [ ClassName "inputs" ] ]
        [ (UI.pageSelect $ show st.page)
        , UI.tickerSelect (HC.toSelect st.ticker)
        , UI.calcRisc
        , UI.inpRisc Nothing
        , UI.ivCheck st.ivNotZero
        , UI.calcRiscOnSelectedCheck st.calcRiscSelected
        ]
    , HH.div [ HP.classes [ ClassName "derivatives" ] ]
        [ Table.createTable st.opx st.sortField st.sortOrderAsc ]
    , DLG.modalDialog st.modalPurchase
        (Title $ "PURCHASE OPTION")
        (PDA <<< XOk)
        (PDA <<< XCancel)
        (modalContent st)
    , DLG.modalDialogBottom st.modalBottom ModalBottomClose
    ]
 
-- }}}

modalContent :: forall w r. { purchaseItem :: Maybe TableItem, volume :: Maybe Amount | r } -> HTML w MainAction
modalContent st =
  let 
    title = case st.purchaseItem of 
              Nothing -> "?"
              Just item -> item.ticker
  in
  HH.div_
    [ HH.p_ [ HH.text title ]
    , UI.purchaseVolume $ HC.mapx st.volume 
    ]
