module Test.Rapanui.Critter.CoreTest
  ( testCoreSuite
  ) where

import Prelude

import Rapanui.Common (Ask(..), Bid(..), Cid(..), Msg(..), Oid(..), OptionTicker(..), Pid(..), Rtyp(..), Spot(..), Status(..))
import Rapanui.Critter.CritterRule as Critter
import Rapanui.Critter.Rules (StockOptionPurchase, AcceptRule, Critter)
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..))
import Rapanui.StockMarket.StockOption (StockOption)
import Test.Unit (TestSuite, suite, test, walkSuite)
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

c1 :: Critter
c1 =
  { oid: Oid 12
    , vol: 10
    , status: 7
    , accRules: []
  }

p1 :: StockOptionPurchase
p1 =
  { ticker: OptionTicker "YAR"
    , oid: Oid 100
    , price: Ask 12.0
    , critters: [] -- Array Critter
    , isSold: false
  }

testCoreSuite :: TestSuite
testCoreSuite =
  suite "TestCoreSuite" do
    test "NoSale:w'" do
      Assert.equal 1 1
