module Derivatives.Actions
  where

import Web.UIEvent.MouseEvent (MouseEvent)
import Derivatives.Table.SortField (SortField)

data MainAction
  = PageChange String
  | TickerChange String
  | FetchDerivatives String
  | CalcRisc MouseEvent
  | RiscChange String
  | IvChecked String
  | TableItemChecked Int Boolean
  | TableSort SortField MouseEvent
