module Test.RapanuiTestMain where

import Prelude

import Effect (Effect)

import Test.Rapanui.Critter.AcceptRuleTest (testAccRuleSuite)
import Test.Rapanui.Critter.CoreTest (testCoreSuite)
import Test.Rapanui.OptionSale.OptionSaleItemTest (testOptionSaleSuite)
import Test.Unit.Main (runTest)

main :: Effect Unit
main = runTest do
  testAccRuleSuite
  testOptionSaleSuite
  testCoreSuite
