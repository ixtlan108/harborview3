module Derivatives.Actions
  where

import Web.UIEvent.MouseEvent (MouseEvent)

data MainAction
  = PageChange String
  | TickerChange String
  | FetchDerivatives String
  | CalcRisc MouseEvent
  | RiscChange String
