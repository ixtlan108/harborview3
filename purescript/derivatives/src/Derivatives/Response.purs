module Derivatives.Response
  where

import HarborView.CommonJson (PayloadResponse(..))

{-
  optionDecoder : JD.Decoder Option
  optionDecoder =
      JD.succeed buildOption
          |> JP.required "ticker" JD.string
          |> JP.required "x" JD.float
          |> JP.required "days" JD.float
          |> JP.required "bid" JD.float
          |> JP.required "ask" JD.float
          |> JP.required "ivBid" JD.float
          |> JP.required "ivAsk" JD.float
          |> JP.required "brEven" JD.float
          |> JP.required "expiry" JD.string


  stockDecoder : JD.Decoder Stock
  stockDecoder =
      JD.succeed Stock
          |> JP.required "unixtime" JD.int
          |> JP.required "o" JD.float
          |> JP.required "h" JD.float
          |> JP.required "l" JD.float
          |> JP.required "c" JD.float


  stockAndOptionsDecoder : JD.Decoder StockAndOptions
  stockAndOptionsDecoder =
      JD.succeed StockAndOptions
          |> JP.required "stockprice" stockDecoder
          |> JP.required "opx" (JD.list optionDecoder)
-}
