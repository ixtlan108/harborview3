module RapanuiMain where

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Web.DOM.ParentNode (QuerySelector(..))
import Web.HTML (HTMLElement)

import Prelude

import Rapanui.View as View

run :: Maybe HTMLElement -> QuerySelector -> Aff Unit
run node qs =
  case node of
    Nothing ->
      let
        QuerySelector qs1 = qs
      in
        liftEffect (logShow $ "Skipping: " <> qs1)
    Just nodex ->
      runUI View.component unit nodex *>
        pure unit

main :: Effect Unit
main =
  HA.runHalogenAff
    $ HA.awaitLoad
        *>
          let
            qs1 = QuerySelector "#rapanui"
          in
            HA.selectElement qs1 >>= \node1 ->
              run node1 qs1