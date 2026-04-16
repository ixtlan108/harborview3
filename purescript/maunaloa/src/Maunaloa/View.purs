module HarborView.Maunaloa.View where


-- import Data.Tuple ( Tuple(..) )
--import Effect.Class (class MonadEffect, liftEffect)
import Control.Monad.State.Class (class MonadState)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect, liftEffect)
import Data.Maybe (Maybe(..))
import HarborView.Maunaloa.Common as Common
import HarborView.Maunaloa.Common
  ( ChartType
  , Drop(..)
  , Take(..)
  , StockTicker(..)
  )
--import HarborView.UI as UI
--import HarborView.UI
--  ( SelectItems
--  )
import HarborView.Maunaloa.Core as Core
import Web.UIEvent.MouseEvent (MouseEvent)
--import Web.Event.Event as E
--import DOM.HTML.Indexed.InputType (InputType(..))
import Halogen as H
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import Halogen.HTML
  ( HTML
  , ClassName(..)
  )
import Halogen.HTML.Events as HE
import Maunaloa.Command (handleAction)

import Effect.Console (logShow)

import Prelude


mkTickers :: SelectItems
mkTickers =
  [ { v: "18", t: "AKSO - Aker Solutions" }
  , { v: "27", t: "BAKKA - Bakkafrost" }
  , { v: "26", t: "BWLPG - BW LPG" }
  , { v: "19", t: "DNB - DNB" }
  , { v: "20", t: "DNO - DNO International" }
  , { v: "2", t: "EQNR - Equinor" }
  , { v: "21", t: "GJF - Gjensidige Forsikr" }
  , { v: "28", t: "GOGL - Golden Ocean Group" }
  , { v: "29", t: "NAS - Norw. Air Shuttle" }
  , { v: "1", t: "NHY - Norsk hydro" }
  , { v: "9", t: "ORK - Orkla" }
  , { v: "12", t: "PGS - Petroleum Geo-Serv" }
  , { v: "14", t: "STB - Storebrand" }
  , { v: "23", t: "SUBC - Subsea 7" }
  , { v: "6", t: "TEL - Telenor" }
  , { v: "16", t: "TGS - TGS-NOPEC" }
  , { v: "17", t: "TOM - Tomra" }
  , { v: "3", t: "YAR - Yara" }
  ]


component :: forall q i o m. MonadAff m => ChartType -> H.Component q i o m
component c =
  H.mkComponent
    { initialState: \_ -> { ct: c
                          , selectedTicker: "0" --UI.emptySelectItem
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
    [ HP.classes [ ClassName "scrap-span" ]]
    [ HH.i
        [ HE.onClick evt,  HP.classes [ ClassName cn ], HP.title title ]
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
    tickers = []  -- UI.mkSelect_ st.tickers SelectChange
  in
  HH.div
  [ HP.classes [ mainClass ]]
  [
    HH.div
    [ HP.classes [ menuBarClass ]]
    [ tickers
    ]
    , HH.div
    [ HP.classes [ menuBarClass ]]
    [ icon resetChart ResetChart
    , icon arrowLeft Previous
    , icon arrowRight Next
    , icon arrowLast Last
    , icon levelLine AddLevelLine
    , icon persistentLevelLine FetchRiscLines
    , icon deleteNonPersistentLevelLines DeleteNonPersistent
    , icon deleteAllLevelLines DeleteAll
    , icon fetchSpot FetchSpot
    ]
  ]

navigate :: forall m. MonadState State m => MonadEffect m => Int -> m Unit
navigate dropAmt =
  H.get >>= \st ->
    if st.selectedTicker == "0" then
      pure unit
    else
      let
        newDropAmt =
          if dropAmt == 0 then
            0
          else
            st.dropAmt + dropAmt
      in
      liftEffect (Core.paint st.ct (StockTicker st.selectedTicker) (Drop newDropAmt) st.takeAmt) *>
      H.modify_ \stx -> stx { dropAmt = newDropAmt }


