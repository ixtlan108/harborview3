module Rapanui.Demo where

demox :: Int
demox = 1

{-
import Prelude
import Data.Array as Ar
import Data.Array ((:))
import Data.Maybe (Maybe(..),fromMaybe )
import Rapanui.Critter.Rules (AcceptRule)
import Rapanui.Critter.AcceptRule as Acc

import Rapanui.Common (Ask(..), Oid(..), Pid(..), Cid(..), Rtyp(..))
import Rapanui.Nordnet.CoreJson (StockOptionResponse)
import Rapanui.Nordnet.Transform as Transform

acc1 :: Number -> AcceptRule
acc1 v =
  { oid: (Oid 1)
  , pid: (Pid 23)
  , cid: (Cid 47)
  , rtyp: (Rtyp 7)
  , value: v
  , active: true
  }

c1 :: Cid
c1 = Cid 47

createResponse :: Number -> Number -> Int -> StockOptionResponse
createResponse bid ask status =
  let
    item = { bid: bid, ask: ask }
  in
    { option: item
    , status: status
    , msg: ""
    }

demo1 =
  let
    r = Transform.mapStockOptionResponse $ createResponse 9.0 11.0 7
  in
  Acc.applyAcc (Ask 2.5) r (acc1 12.0)

data Jax = Jux | Jix Int | Jex String | NoSale

instance Show Jax where
  show Jux = "Jux"
  show (Jix x) = "(Jix " <> show x <> ")"
  show (Jex s) = "(Jex " <> s <> ")"
  show NoSale = "NoSale"

derive instance Eq Jax

--findJux :: Array Jax -> Maybe Jax
--findJux jax =
--  Nothing

-- len :: forall a. Array a -> Int
len :: Array Jax -> Int
len arr = go arr 0
  where
    go :: Array Jax -> Int -> Int
    go [] acc = acc
    go ar1 acc = go (fromMaybe [] $ Ar.tail ar1) (acc + 1)

-- findJux :: Array Jax -> Jax
-- findJux arr = go arr NoSale
--   where
--     go :: Array Jax -> Jax -> Jax
--     go [] acc = acc
--     go ar1 acc =
--       case acc of
--         NoSale ->
--           go (fromMaybe [] $ Ar.tail ar1) acc

axx :: Array Jax
axx = [Jux,Jix 23,Jex "jex", NoSale, Jex "jex 2", Jex "jex 3"]

xx :: Array Jax -> Maybe Jax
xx curAxx =
  Ar.head $ Ar.filter (\x -> x  /= NoSale && x /= Jux) curAxx

fx :: Array Jax -> Array Jax
fx ax = go ax [] where
  go :: Array Jax -> Array Jax -> Array Jax
  go items result =
    let
      hx = Ar.head items
    in
      case hx of
        Nothing ->
          result
        Just hx1 ->
          let
            tx = Ar.tail items
          in
          case hx1 of
            Jex _ ->
              case tx of
                Nothing ->
                  hx1 : result
                Just tx1 ->
                  go tx1 (hx1 : result)
            _ ->
              case tx of
                Nothing ->
                  result
                Just tx1 ->
                  go tx1 result
-}
