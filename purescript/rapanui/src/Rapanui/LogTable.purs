module Rapanui.LogTable
  where

--import Data.Maybe (fromMaybe,Maybe)
import Halogen.HTML.Properties (IProp)
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import Halogen.HTML (ClassName(..), HTML)
import Web.HTML.Common (AttrName(..))
import Rapanui.Common (Log)

import Prelude

-- foreign import curTime :: Int -> String
--import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
--import Rapanui.Common (MainAction)

tdAlignLeft :: forall r i. Boolean -> IProp r i
tdAlignLeft isLeft =
  if isLeft then
    HP.attr (AttrName "align") "left"
  else
    HP.attr (AttrName "align") "right"

tableHead :: forall w i. HTML w i
tableHead =
  HH.thead_
    [ HH.tr_
        [ HH.th_ [ HH.text "Oid" ]
        , HH.th_ [ HH.text "Cid" ]
        , HH.th_ [ HH.text "Tick" ]
        , HH.th_ [ HH.text "Time" ]
        , HH.th_ [ HH.text "Log" ]
        ]
    ]

createRow :: forall w i. Log -> HTML w i
createRow log =
  HH.tr_
    [ HH.td [ tdAlignLeft false ] [ HH.text log.oid]
    , HH.td [ tdAlignLeft false ] [ HH.text log.cid ]
    , HH.td [ tdAlignLeft false ] [ HH.text $ show log.tick ]
    , HH.td [ tdAlignLeft true ] [ HH.text log.tm ]
    , HH.td [ tdAlignLeft true ] [ HH.text log.log ]
    ]

createTable :: forall w i. Array Log -> HTML w i
createTable logs =
  let
    rows = map createRow logs
  in
    HH.table
      [ HP.classes [ ClassName "sortable ps-mt-1" ] ]
      [ tableHead
      , HH.tbody_ rows
      ]
