module Test.Rapanui.OptionSale.OptionSaleItemTest
  ( testOptionSaleSuite
  ) where

import Prelude

import Test.Unit (suite, test, TestSuite)
import Test.Unit.Assert as Assert
import Rapanui.StockMarket.OptionSaleItem (OptionSale(..), validOptionSales)
import Rapanui.Common (Bid(..), Cid(..), Oid(..))


testSale1 :: OptionSale
testSale1  =
  Sale { critterId: Cid 1, price: Bid 10.0 }

errorSale1 :: OptionSale
errorSale1 =
  SaleError { oid: Oid 1, error: "Error 1" }


testOptionSaleSuite :: TestSuite
testOptionSaleSuite =
  suite "OptionSaleItemTest" do
    test "Result Empty" do
      let curAx = [ NoSale, NotActive, NoSale ]
      let actual = validOptionSales curAx
      Assert.equal actual []
    test "Result Sale" do
      let curAx = [ NoSale, testSale1, NotActive, NoSale ]
      let actual = validOptionSales curAx
      Assert.equal actual [ testSale1 ]
    test "Result Sale + SaleError" do
      let curAx = [ NoSale, errorSale1, NotActive, testSale1, NoSale ]
      let actual = validOptionSales curAx
      Assert.equal actual [ testSale1, errorSale1 ]
