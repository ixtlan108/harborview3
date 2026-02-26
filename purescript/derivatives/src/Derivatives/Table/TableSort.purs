module Derivatives.Table.TableSort where

import Prelude

import Data.Array as Array
--import Oahu.SortField (SortField(..))
--import Report.Report1.Types (Report1Table)
--import Waimea.Util as WU

{-

sortOrder :: Boolean -> Report1Table -> Report1Table
sortOrder asc tbl =
  if asc == true then
    tbl
  else
    Array.reverse tbl

sortResponse :: SortField -> Boolean -> Report1Table -> Report1Table
sortResponse SfNone _ tbl = tbl
sortResponse SfGpo asc tbl = sortOrder asc $ Array.sortWith _.gpo tbl
sortResponse SfEdNum asc tbl = sortOrder asc $ WU.sortEdNum tbl
sortResponse SfEdType asc tbl = sortOrder asc $ Array.sortWith _.edt tbl
sortResponse SfPhoto asc tbl = sortOrder asc $ Array.sortWith _.photo tbl
sortResponse SfPwf asc tbl = sortOrder asc $ Array.sortWith _.pwf tbl
sortResponse SfShootDate asc tbl = sortOrder asc $ Array.sortWith _.shootDate tbl

-}
