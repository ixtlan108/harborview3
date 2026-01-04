module Test.Rapanui.Critter.CoreTest
  ( testCoreSuite
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Rapanui.Common (Ask(..), Bid(..), Cid(..), Msg(..), Oid(..), OptionTicker(..), Pid(..), Rtyp(..), Spot(..), Status(..))
import Rapanui.Critter.Core as Core
import Rapanui.Critter.CritterRule as Critter
import Rapanui.Critter.Rules (StockOptionPurchase, AcceptRule, Critter)
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption, StockOptionItem)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert


crAccRule :: Cid -> Number -> AcceptRule
crAccRule cid value =
  { oid: Oid 1
    , pid: Pid 100
    , cid: cid -- Cid 12
    , rtyp: DIFF_BOUGHT
    , value: value
    , active: true
  }

a1 :: AcceptRule
a1 = crAccRule (Cid 12) 2.0

crCritter_ :: Oid -> Int -> AcceptRule -> Critter
crCritter_ oid status acc =
  { oid: oid
    , vol: 10
    , status: status -- CRITTER_ACTIVE
    , accRules: [acc]
  }

crCritter :: Int -> Critter
crCritter status =
  crCritter_ (Oid 12) status a1

crPurchase :: Array Critter -> StockOptionPurchase
crPurchase critters =
  { ticker: OptionTicker "YAR"
    , oid: Oid 100
    , price: Ask 12.0
    , critters: critters
    , isSold: false
  }

crStockOption :: Bid -> StockOption
crStockOption bid =
  { spot: Spot 0.0
    , option: { bid: bid, ask: Ask 0.0 }
    , optionStatus: Status 7
    , msg: Just $ Msg ""
  }

critWithAcc :: Oid -> Int -> Number -> Critter
critWithAcc oid1@(Oid oid) status accVal =
  let
    acc = crAccRule (Cid oid) accVal
  in
  crCritter_ oid1 status acc


testCoreSuite :: TestSuite
testCoreSuite =
  suite "TestCoreSuite" do
    test "is100PctSold == false" do
      let c1 = [crCritter 7, crCritter 9]
      let p1 = crPurchase c1
      Assert.equal (Core.is100PctSold p1) false
    test "is100PctSold == true" do
      let c2 = [crCritter 9, crCritter 9]
      let p2 = crPurchase c2
      Assert.equal (Core.is100PctSold p2) true
    test "Critter setStatus" do
      let c3 = crCritter 7
      let _ = Critter.setStatus c3 9
      Assert.equal c3.status 9
    test "Core.applyPurchase_ [NoSale]" do
      let so1 = crStockOption (Bid 10.0)
      let acc1 = crAccRule (Cid 12) 2.0
      let c4 = crCritter_ (Oid 12) 9 acc1
      let p3 = crPurchase [c4]
      let actual = Core.applyPurchase_ so1 p3
      Assert.equal [NoSale] actual
    test "Core.applyPurchase_ [Sale Bid 9.0]" do
      let so2 = crStockOption (Bid 9.0)
      let acc2 = crAccRule (Cid 12) 2.0
      let c5 = crCritter_ (Oid 12) 7 acc2
      let p4 = crPurchase [c5]
      let actual = Core.applyPurchase_ so2 p4
      Assert.equal [Sale { critterId: Cid 12, price: Bid 9.0 }] actual
    test "Core.applyPurchase_ Multiple Critters, only one sale [Sale Bid 9.0]" do
      let so3 = crStockOption (Bid 9.0)
      let c6_1 = critWithAcc (Oid 10) 7 2.0
      let c6_2 = critWithAcc (Oid 11) 7 5.0
      let c6_3 = critWithAcc (Oid 12) 9 2.0
      let p5 = crPurchase [c6_1,c6_2,c6_3]
      let actual = Core.applyPurchase_ so3 p5
      Assert.equal [Sale { critterId: Cid 10, price: Bid 9.0 },NoSale,NoSale] actual
      let actual2 = Core.applyPurchase_ so3 p5
      Assert.equal [NoSale,NoSale,NoSale] actual2
    test "Core.applyPurchase_ Multiple Critters, multiple sales [2 x Sale Bid 9.0]" do
      let so4 = crStockOption (Bid 9.0)
      let c7_1 = critWithAcc (Oid 10) 7 2.0
      let c7_2 = critWithAcc (Oid 11) 7 1.0
      let c7_3 = critWithAcc (Oid 12) 9 2.0
      let p6 = crPurchase [c7_1,c7_2,c7_3]
      let actual = Core.applyPurchase_ so4 p6
      Assert.equal [ Sale { critterId: Cid 10, price: Bid 9.0 }
                    , Sale { critterId: Cid 11, price: Bid 9.0 }
                    , NoSale] actual
      let actual2 = Core.applyPurchase_ so4 p6
      Assert.equal [NoSale,NoSale,NoSale] actual2
