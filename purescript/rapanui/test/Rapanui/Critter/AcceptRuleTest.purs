module Test.Rapanui.Critter.AcceptRuleTest
  ( testAccRuleSuite
  ) where

import Prelude

import Rapanui.Common (AccVal(..), Ask(..), Bid(..), Spot(..), Status(..), Msg(..), Oid(..), Pid(..), Cid(..), Rtyp(..))
import Rapanui.StockMarket.StockOption (StockOption)
import Rapanui.Critter.Rules (AcceptRule)
import Rapanui.Critter.AcceptRule as Acc
--import Rapanui.OptionSale.OptionSaleItem
--import Rapanui.StockOption

import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.Nordnet.CoreJson (StockOptionResponse)
import Rapanui.Nordnet.Transform as Transform
import Test.Unit (suite, test, TestSuite)
import Test.Unit.Assert as Assert

acc1 :: Number -> AcceptRule
acc1 v =
  { oid: (Oid 1)
  , pid: (Pid 23)
  , cid: (Cid 47)
  , rtyp: (Rtyp 7)
  , value: v
  , active: true
  }

s1 :: StockOption
s1 =
  { spot: Spot 120.0
  , option: { bid: Bid 9.0, ask: Ask 11.0 }
  , optionStatus: Status 7
  , msg: Msg ""
  }


c1 :: Cid
c1 = Cid 47

createResponse :: Number -> Number -> Int -> StockOptionResponse
createResponse bid ask status =
  { spot: 120.0
  , option: { bid: bid, ask: ask }
  , optionStatus: status
  , msg: ""
  }

testAccRuleSuite :: TestSuite
testAccRuleSuite =
  suite "TestAccRuleSuite" do
    test "apply' 1 NoSale" do
      let actual = Acc.applyAcc' (Ask 12.0) s1 c1 (Rtyp 7) (AccVal 5.0)
      Assert.equal NoSale actual
    test "apply' 2 Sale" do
      let actual = Acc.applyAcc' (Ask 12.0) s1 c1 (Rtyp 7) (AccVal 2.5)
      Assert.equal (Sale { critterId: c1, price: Bid 9.0 }) actual
    test "apply 1 NoSale" do
      let actual = Acc.applyAcc (Ask 12.0) s1 (acc1 2.0)
      Assert.equal (Sale { critterId: c1, price: Bid 9.0 }) actual
    test "apply 2 Sale" do
      let actual = Acc.applyAcc (Ask 12.0) s1 (acc1 3.5)
      Assert.equal NoSale actual
    test "Transform.mapStockOptionResponse NoSale" do
      let r = Transform.mapStockOptionResponse $ createResponse 9.0 11.0 7
      let actual = Acc.applyAcc (Ask 12.0) r (acc1 3.5)
      Assert.equal NoSale actual
    test "Transform.mapStockOptionResponse Sale" do
      let r = Transform.mapStockOptionResponse $ createResponse 9.0 11.0 7
      let actual = Acc.applyAcc (Ask 12.0) r (acc1 1.0)
      Assert.equal (Sale { critterId: c1, price: Bid 9.0 }) actual
