module Rapanui.Table
  where

--import Data.Maybe (fromMaybe,Maybe)
import Halogen.HTML.Properties (IProp)
import Halogen.HTML.Properties as HP
import Halogen.HTML as HH
import Halogen.HTML (ClassName(..), HTML)
import Web.HTML.Common (AttrName(..))

--import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
--import Rapanui.Common (MainAction)
import Rapanui.Log (Log)

tdAlign :: forall r i. Boolean -> IProp r i
tdAlign isLeft =
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
        , HH.th_ [ HH.text "Log" ]
        ]
    ]

createRow :: forall w i. Log -> HTML w i
createRow _ =
  HH.div_ []
