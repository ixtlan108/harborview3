module HarborView.Maunaloa.Repository where

import Prelude
    ( Unit
    )
import Effect
    ( Effect
    )
import Data.Maybe
    ( Maybe(..)
    )
import HarborView.Maunaloa.JsonCharts
    ( JsonChartPayload
    )

foreign import setJsonResponse :: String -> JsonChartPayload -> Effect Unit

foreign import getJsonResponseImpl ::
    (JsonChartPayload -> Maybe JsonChartPayload)
    -> Maybe JsonChartPayload
    -> String
    -> Maybe JsonChartPayload

getJsonResponse :: String -> Maybe JsonChartPayload
getJsonResponse key = getJsonResponseImpl Just Nothing key

foreign import resetChart :: String -> Effect Unit

foreign import resetCharts :: Effect Unit


{-
foreign import setDemo :: Ticker -> String -> Effect Unit
foreign import getDemoImpl ::
    (String -> Maybe String)
    -> Maybe String
    -> Ticker
    -> Maybe String

getDemo :: Ticker -> Maybe String
getDemo key = getDemoImpl Just Nothing key
--}
