module HarborView.Maunaloa.Util.Misc
    ( plusArray
      , alphaNumericSort
    ) where

import Prelude
import Data.Int as DI
import Data.Maybe (Maybe(..),fromMaybe)
import Data.Tuple as T
import Data.Array as A
import Data.Array
  ( foldr
  , (:)
  )

plusArray :: forall a. Array a -> Array a -> Array a
plusArray xa xb =
  foldr (:) xb xa

intify :: forall r. { edn :: Maybe String | r } -> Int
intify e =
  let
    ei = e.edn >>= \e1 -> DI.fromString e1
  in
  fromMaybe 0 ei

alphaNumericSort :: forall r. Array { edn :: Maybe String | r } -> Array { edn :: Maybe String | r }
alphaNumericSort items =
  let
    index = map intify items
    zipped = A.zip index items
    itemsInt = A.filter (\x -> T.fst x > 0) zipped
    ari = map T.snd $ A.sortWith T.fst itemsInt
    itemsStr = A.filter (\x -> T.fst x == 0) zipped
    ars = A.sortWith _.edn $ map T.snd itemsStr
  in
  ars <> ari
