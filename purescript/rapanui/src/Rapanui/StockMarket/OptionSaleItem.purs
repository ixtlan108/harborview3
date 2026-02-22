module Rapanui.StockMarket.OptionSaleItem where

import Rapanui.Common (Bid(..), Cid(..), Oid(..), Log)

import Data.Maybe (Maybe(..))
-- import Data.Show (class Show)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Array as Ar
import Data.Array ((:))

import Prelude


type SalePayload =
  { critterId :: Cid
  , price :: Bid
  }

type ErrorSalePayload =
  { oid :: Oid
  , error :: String
  }

data OptionSale
  = NotActive
  | NoSale
  | Sale SalePayload
  | SaleError ErrorSalePayload

derive instance Eq OptionSale

derive instance Generic OptionSale _

instance Show OptionSale where
  show = genericShow

--findOptionSale :: Array OptionSale -> Maybe OptionSale
--findOptionSale ax =
--  Ar.head $ Ar.filter (\x -> x  /= NoSale && x /= NotActive) ax

validOptionSales :: Array OptionSale -> Array OptionSale
validOptionSales ax = go ax [] where
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
          Sale _ ->
            case tx of
              Nothing ->
                hx1 : result
              Just tx1 ->
                go tx1 (hx1 : result)
          SaleError _  ->
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


mapOptionSaleToLog :: Int -> String -> OptionSale -> Log
mapOptionSaleToLog tick tm (Sale { critterId: (Cid cid), price: (Bid bid) }) =
  { tick: tick
    , tm: tm
    , oid: "-"
    , cid: show cid
    , log: "Price: " <> show bid
  }
mapOptionSaleToLog tick tm (SaleError { oid: (Oid oid), error }) =
  { tick: tick
    , tm: tm
    , oid: show oid
    , cid: "-"
    , log: error
  }
mapOptionSaleToLog _ _ _ =
  { tick: 0
    , tm: "-"
    , oid: "-"
    , cid: "-"
    , log: "-"
  }
