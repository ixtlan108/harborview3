module Test.Rapanui.Critter.AcceptRuleTest
  ( testAccRuleSuite
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Rapanui.Common (AccVal(..), Ask(..), Bid(..), Cid(..), Msg(..), Oid(..), Pid(..), Rtyp(..), Spot(..), Status(..))
import Rapanui.Critter.AcceptRule as Acc
import Rapanui.Critter.Rules (AcceptRule)
import Rapanui.Nordnet.CoreJson (StockOptionPayload)
import Rapanui.Nordnet.Transform as Transform
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)
import Test.Unit (suite, test, TestSuite)
import Test.Unit.Assert as Assert

acc1 :: Number -> AcceptRule
acc1 v =
  { oid: (Oid 1)
  , pid: (Pid 23)
  , cid: (Cid 47)
  , rtyp: DIFF_BOUGHT
  , value: v
  , active: true
  }

s1 :: StockOption
s1 =
  { spot: Spot 120.0
  , option: { bid: Bid 9.0, ask: Ask 11.0 }
  , optionStatus: Status 7
  , msg: Nothing
  }


c1 :: Cid
c1 = Cid 47

createResponse :: Number -> Number -> Int -> StockOptionPayload
createResponse bid ask status =
  { status : 0
    , payload: { spot: 120.0
                 , option: {  bid: bid, ask: ask }
                 , optionStatus: status
                 , msg: Nothing
                 }
    , msg: Just "-"
  }

testAccRuleSuite :: TestSuite
testAccRuleSuite =
  suite "TestAccRuleSuite" do
    test "apply' 1 NoSale" do
      let actual = Acc.applyAcc' (Ask 12.0) s1 c1 DIFF_BOUGHT (AccVal 5.0)
      Assert.equal NoSale actual
    test "apply' 2 Sale" do
      let actual = Acc.applyAcc' (Ask 12.0) s1 c1 DIFF_BOUGHT (AccVal 2.5)
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
