module Derivatives.Table.TableSort where

import Prelude

import Data.Array as Array
import Derivatives.Table.SortField (SortField(..))
import Derivatives.Table.Table (TableItem)
--import Report.Report1.Types (Report1Table)
--import Waimea.Util as WU


sortOrder :: Boolean -> Array TableItem -> Array TableItem
sortOrder asc tbl =
  if asc == true then
    tbl
  else
    Array.reverse tbl

sortResponse :: SortField -> Boolean -> Array TableItem -> Array TableItem
sortResponse SfNone _ tbl = tbl
sortResponse SfTicker asc tbl = sortOrder asc $ Array.sortWith _.ticker tbl
sortResponse SfIvBid asc tbl = sortOrder asc $ Array.sortWith _.ivBid tbl
sortResponse SfIvAsk asc tbl = sortOrder asc $ Array.sortWith _.ivAsk tbl

{-
sortResponse SfEdNum asc tbl = sortOrder asc $ WU.sortEdNum tbl
sortResponse SfEdType asc tbl = sortOrder asc $ Array.sortWith _.edt tbl
sortResponse SfPhoto asc tbl = sortOrder asc $ Array.sortWith _.photo tbl
sortResponse SfPwf asc tbl = sortOrder asc $ Array.sortWith _.pwf tbl
sortResponse SfShootDate asc tbl = sortOrder asc $ Array.sortWith _.shootDate tbl
-}
