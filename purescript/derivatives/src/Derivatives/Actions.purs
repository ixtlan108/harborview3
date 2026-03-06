module Derivatives.Actions
  where

import Web.UIEvent.MouseEvent (MouseEvent)
import Derivatives.Table.SortField (SortField)

data PurchaseDlgAction
  = XOk MouseEvent
  | XCancel MouseEvent
  | XOpen MouseEvent

data MainAction
  = PageChange String
  | TickerChange String
  | FetchDerivatives String
  | CalcRisc MouseEvent
  | RiscChange String
  | IvChecked Boolean
  | CalcRiscSelectedChecked Boolean
  | TableItemChecked Int Boolean
  | TableSort SortField MouseEvent
  | PDA PurchaseDlgAction
