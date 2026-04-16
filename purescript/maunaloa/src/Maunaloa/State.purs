module Maunaloa.State
  where

import HarborView.Maunaloa.Common
  ( ChartType
  , Take
  )

type State =
  { ct :: ChartType
  , selectedTicker :: String
  , takeAmt :: Take
  , dropAmt :: Int
  }
