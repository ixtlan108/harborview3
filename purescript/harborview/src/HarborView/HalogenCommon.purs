module HarborView.HalogenCommon
  ( timer
  ) where

import Halogen as H
import Control.Monad.Rec.Class (forever)
import Effect.Aff.Class (class MonadAff)
import Halogen.Subscription (Emitter)
import Effect.Aff as Aff
import Halogen.Subscription as HS
import Effect.Aff (Milliseconds)

import Prelude

timer :: forall m a. MonadAff m => Milliseconds -> a -> m (Emitter a)
timer ms val =
  H.liftEffect HS.create >>= \{ emitter, listener } ->
    H.liftAff
      ( Aff.forkAff
          ( forever
              ( Aff.delay ms *>
                  H.liftEffect (HS.notify listener val)
              )
          )
      ) *>
      pure emitter