module Test.Rapanui.Critter.CoreTest
  ( testCoreSuite
  ) where

import Prelude

import Rapanui.Common (Ask(..), Bid(..), Cid(..), Msg(..), Oid(..), OptionTicker(..), Pid(..), Rtyp(..), Spot(..), Status(..), StatusCode(..))
import Rapanui.Critter.Core as Core
import Rapanui.Critter.CritterRule as Critter
import Rapanui.Critter.Rules (StockOptionPurchase, AcceptRule, Critter)
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption, StockOptionItem)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert

o1 :: StockOption
o1 =
  { spot: Spot 100.0
    , option: { bid: Bid 10.0, ask: Ask 12.0 }
    , optionStatus: Status 7
    , msg: Msg ""
  }

a1 :: AcceptRule
a1 =
  { oid: Oid 1
    , pid: Pid 100
    , cid: Cid 12
    , rtyp: DIFF_BOUGHT
    , value: 12.0
    , active: true
  }

crCritter :: Int -> Critter
crCritter status =
  { oid: Oid 12
    , vol: 10
    , status: status -- CRITTER_ACTIVE
    , accRules: [a1]
  }

crPurchase :: Array Critter -> StockOptionPurchase
crPurchase critters =
  { ticker: OptionTicker "YAR"
    , oid: Oid 100
    , price: Ask 12.0
    , critters: critters
    , isSold: false
  }

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
      Assert.equal 1 1
