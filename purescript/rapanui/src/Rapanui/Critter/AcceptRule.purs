module Rapanui.Critter.AcceptRule
  ( applyAcc
  , applyAcc'
  )
  where

import Prelude

import Rapanui.Common (AccVal(..), Ask(..), Bid(..), Cid, Rtyp(..))
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)
import Rapanui.Critter.Rules (AcceptRule)

--import Prelude

{-
type AcceptRule =
  { oid :: Oid
  , pid :: Pid
  , cid :: Cid
  , rtyp :: Rtyp
  , value :: Number
  , active :: Boolean
  }
-}

applyAcc' :: Ask -> StockOption -> Cid -> Rtyp -> AccVal -> OptionSale
applyAcc'
  (Ask s)
  stock -- (StockOption{option: StockOptionItem{bid: (Bid b2)}})
  c
  rt
  (AccVal value) =
    let
      (Bid b2) = stock.option.bid
    in
    case rt of
      DIFF_BOUGHT ->
        let
          diffFromBought = s - b2
        in
          if diffFromBought > value
            then Sale { critterId: c,  price: Bid b2 }
            else NoSale
      _ -> NoSale

applyAcc :: Ask -> StockOption -> AcceptRule -> OptionSale
applyAcc ask opt rule =
  if rule.active == false then
    NoSale
  else
    applyAcc' ask opt rule.cid rule.rtyp (AccVal rule.value)
