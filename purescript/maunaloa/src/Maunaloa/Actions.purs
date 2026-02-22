module Maunaloa.Actions
  where

import Web.UIEvent.MouseEvent (MouseEvent)

data Action
  = SelectChange String
  | Initialize
  | ResetChart MouseEvent
  | AddLevelLine MouseEvent
  | FetchRiscLines MouseEvent
  | Previous MouseEvent
  | Next MouseEvent
  | Last MouseEvent
  | DeleteNonPersistent MouseEvent
  | DeleteAll MouseEvent
  | FetchSpot MouseEvent
