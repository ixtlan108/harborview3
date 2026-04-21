module HarborView.Maunaloa.View where

--import Data.Tuple ( Tuple(..) )
--import Effect.Class (class MonadEffect, liftEffect)
import Control.Monad.State.Class (class MonadState)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (logShow)
import Data.Maybe (Maybe(..))
--import HarborView.Maunaloa.Common as Common
--import HarborView.UI as UI
--import HarborView.UI
--  ( SelectItems
--  )
import Web.UIEvent.MouseEvent (MouseEvent)
--import Web.Event.Event as E
--import DOM.HTML.Indexed.InputType (InputType(..))
import Halogen as H
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import Halogen.HTML (HTML, ClassName(..))
import Halogen.HTML.Events as HE

import HarborView.Maunaloa.Core as Core
import HarborView.Maunaloa.Common (ChartType, Drop(..), Take(..), StockTicker(..))
import Maunaloa.Command (handleAction)
import Maunaloa.Actions (Action(..))
import Maunaloa.State (State)
import Maunaloa.UI as UI

import Prelude

component :: forall q i o m. MonadAff m => ChartType -> H.Component q i o m
component c =
  H.mkComponent
    { initialState: \_ ->
        { ct: c
        , selectedTicker: "-" --UI.emptySelectItem
        , takeAmt: Take 90
        , dropAmt: 0
        }
    , render
    , eval: H.mkEval H.defaultEval
        { handleAction = handleAction
        , initialize = Just Initialize
        }
    }

mainClass :: ClassName
mainClass = ClassName "grid-menu-bar-ps"

menuBarClass :: ClassName
menuBarClass = ClassName "form-group form-group--menu-bar"

type Icon =
  { iconClass :: String
  , title :: String
  }

icon :: forall w i. Icon -> (MouseEvent -> i) -> HTML w i
icon { iconClass, title } evt =
  let
    cn = "fa-solid " <> iconClass <> " fa-fw"
  in
    HH.span
      [ HP.classes [ ClassName "scrap-span" ] ]
      [ HH.i
          [ HE.onClick evt, HP.classes [ ClassName cn ], HP.title title ]
          []
      ]

resetChart :: Icon
resetChart =
  { iconClass: "fa-ghost", title: "Reset Chart" }

arrowRight :: Icon
arrowRight =
  { iconClass: "fa-arrow-right", title: "Next" }

arrowLeft :: Icon
arrowLeft =
  { iconClass: "fa-arrow-left", title: "Previous" }

arrowLast :: Icon
arrowLast =
  { iconClass: "fa-arrow-right-to-bracket", title: "Last" }

levelLine :: Icon
levelLine =
  { iconClass: "fa-ruler-vertical", title: "Level Line" }

persistentLevelLine :: Icon
persistentLevelLine =
  { iconClass: "fa-pen-ruler", title: "Persistent Level Line" }

-- deleteLevelLine :: Icon
-- deleteLevelLine =
--   { iconClass: "fa-ruler-combined", title: "Delete Level Lines" }

deleteNonPersistentLevelLines :: Icon
deleteNonPersistentLevelLines =
  { iconClass: "fa-trash-can", title: "Delete non-persistent Level Lines" }

deleteAllLevelLines :: Icon
deleteAllLevelLines =
  { iconClass: "fa-trash-can-arrow-up", title: "Delete all Level Lines" }

fetchSpot :: Icon
fetchSpot =
  { iconClass: "fa-bullseye", title: "Fetch Spot" }

render :: forall cs m. State -> H.ComponentHTML Action cs m
render st =
  let
    tickers = UI.tickerSelect st.selectedTicker 
  in
    HH.div
      [ HP.classes [ mainClass ] ]
      [ HH.div
          [ HP.classes [ menuBarClass ] ]
          [ icon resetChart ResetChart
          , icon arrowLeft Previous
          , icon arrowRight Next
          , icon arrowLast Last
          , icon levelLine AddLevelLine
          , icon persistentLevelLine FetchRiscLines
          , icon deleteNonPersistentLevelLines DeleteNonPersistent
          , icon deleteAllLevelLines DeleteAll
          , icon fetchSpot FetchSpot
          , tickers
          ]
      ]


