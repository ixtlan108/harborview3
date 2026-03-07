module Derivatives.Actions
  where

import Web.UIEvent.MouseEvent (MouseEvent)
import Derivatives.Table.SortField (SortField)
import Derivatives.Table.TableItem (TableItem)

data PurchaseAction
  = XOk MouseEvent
  | XCancel MouseEvent
  | XOpen TableItem MouseEvent
  | XAsk String
  | XBid String
  | XVolume String
  | XSpot String

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
  | PDA PurchaseAction
