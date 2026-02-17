module Rapanui.Nordnet.Transform
  ( mapPayloads
  , mapStockOptionResponse
  ) where

import Prelude

import Rapanui.Common (Ask(..), Bid(..), Cid(..), Msg(..), Oid(..), OptionTicker(..), Pid(..), Rtyp(..), Spot(..), Status(..), StatusCode(..))
import Rapanui.Critter.Rules (AcceptRule, Critter, StockOptionPurchase)
import Rapanui.Nordnet.CoreJson (JsonCritter, JsonPayload, JsonAccRule, StockOptionPayload)
import Rapanui.StockMarket.StockOption (StockOption)

--import Rapanui.State (State)

{-
mapAccRule :: Array JsonAccRule -> AcceptRule
mapAccRule { oid, pid, cid, rtyp, value, active } =
  { oid: Oid oid
  , pid: Pid pid
  , cid: Cid cid
  , rtyp: Rtyp rtyp
  , value: value
  , active: active
  }
  -}

mapRtyp :: Int -> Rtyp
mapRtyp ji =
  case ji of
    7 -> DIFF_BOUGHT
    _ -> NA

mapStatusCode :: Int -> StatusCode
mapStatusCode si =
  case si of
    7 -> CRITTER_ACTIVE
    _  -> SNA

mapAccRule :: JsonAccRule -> AcceptRule
mapAccRule ja =
  { active: true
  , cid: Cid ja.cid
  , oid: Oid ja.oid
  , pid: Pid ja.pid
  , rtyp: mapRtyp ja.rtyp
  , value: ja.value
  }

mapCritter :: JsonCritter -> Critter
mapCritter jc =
  { oid: Oid jc.oid
  , vol: jc.vol
  , status: jc.status -- mapStatusCode jc.status
  , accRules: map mapAccRule jc.accRules
  }

mapCritters :: Array JsonCritter -> Array Critter
mapCritters critters =
  map mapCritter critters

mapPayload :: JsonPayload -> StockOptionPurchase
mapPayload payload =
  { oid: Oid payload.oid
  , ticker: OptionTicker payload.ticker
  , price: Ask payload.price
  , critters: mapCritters payload.critters
  , isSold: false
  }

mapPayloads :: Array JsonPayload -> Array StockOptionPurchase
mapPayloads payloads =
  map mapPayload payloads

mapStockOptionResponse :: StockOptionPayload -> StockOption
mapStockOptionResponse response =
  let
    pl = response.payload
    item =
      { bid: Bid pl.option.bid
      , ask: Ask pl.option.ask
      }
  in
    { spot: Spot pl.spot
    , option: item
    , optionStatus: Status pl.optionStatus
    , msg: Msg <$> pl.msg
    }

{-
  case response.payload of
    [] ->
      defaultState
    ->
      defaultState

      let
        critters = map mapCritter p1.
      in
        defaultState
-}

--{ accRule: Just $ mapAccRule response.payload.accRule }

{-
{
  "appStatusCode": 1,
  "error": null,
  "payload": [
    {
      "ticker": "NHY9E30",
      "oid": 47,
      "price": 5.8,
      "critters": [
        {
          "vol": 10,
          "status": 7,
          "oid": 45,
          "accRules": [
            {
              "oid": 72,
              "pid": 47,
              "cid": 45,
              "rtyp": 1
              "value": 3,
              "active": true,
            },
            {
              "oid": 73,
              "pid": 47,
              "cid": 45,
              "rtyp": 7
              "value": 2,
              "active": false,
            }
          ]
        }
      ]
    }
  ]
}
-}
