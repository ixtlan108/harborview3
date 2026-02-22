module HarborView.Common where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Either (Either(..))
import Data.Number.Format as Format
import Data.Int as DI
import Data.Number as DN
import Data.String as S
import Effect (Effect)
import Effect.Console (logShow)
import Web.Event.Event as Event
import HarborView.HarborViewError (err2string, HarborViewError (..))

foreign import alert :: String -> Effect Unit


--------------- StockTicker ---------------

newtype StockTicker = StockTicker Int

instance Show StockTicker where show (StockTicker s) = show s

--------------- Amount ---------------

newtype Amount =
  Amount Int

derive instance Newtype Amount _

--------------- Price ---------------

newtype Price =
  Price Number

newtype Oid =
  Oid Int

newtype Url =
  Url String

-- data HarborViewError
--   = AffjaxError String
--   | JsonError String

-- handleError :: HarborViewError -> Effect Unit
-- handleError (AffjaxError err) =
--   logShow $ "AffjaxError: " <> err
-- handleError (JsonError err) =
--   logShow $ "JsonError: " <> err

-- errToString :: HarborViewError -> String
-- errToString (AffjaxError err) =
--   "AffjaxError: " <> err
-- errToString (JsonError err) =
--   "JsonError: " <> err

numToString :: Number -> String
numToString num =
  Format.toStringWith (Format.fixed 2) num

fromInt :: Int -> String
fromInt i =
  if i < 0 then
    ""
  else
    show i

type JsonResult =
  { oid :: Int
  , msg :: String
  , statusCode :: Int
  }

jsonResultToString :: Either HarborViewError JsonResult -> String
jsonResultToString result =
  case result of
    Left err ->
      err2string err
    Right result1 ->
      result1.msg

defaultEventHandling :: Event.Event -> Effect Unit
defaultEventHandling event =
  Event.stopPropagation event *>
    Event.preventDefault event

dayInMillis :: Number
dayInMillis = 86400000.0

------------------------- UnixTime -------------------------
newtype UnixTime = UnixTime Number

derive instance eqUnixTime :: Eq UnixTime

instance showUnixTime :: Show UnixTime where
  show (UnixTime v) = "(UnixTime " <> show v <> ")"

instance ordUnixTime :: Ord UnixTime where
  compare (UnixTime u1) (UnixTime u2) = compare u1 u2

  ------------------------- Diverse -------------------------
mapx :: forall f a b. Functor f => Newtype a b => f a -> f b
mapx x = map (\v -> unwrap v) x

toSelect :: forall a. Show a => Maybe a -> String
toSelect (Just x) = show x
toSelect Nothing = "-"

isStringEmpty :: String -> Boolean
isStringEmpty s =
  S.null $ S.trim s

fromSelectI :: forall a. (Int -> a) -> String -> Maybe a
fromSelectI f s =
  if s == "-" then
    Nothing
  else
    f <$> DI.fromString s


smap :: forall a. (String -> a) -> String -> Maybe a
smap f s =
  if isStringEmpty s then
    Nothing
  else
    Just $ f s

imap :: forall a. (Int -> a) -> String -> Maybe a
imap f s =
  f <$> DI.fromString s

umap :: forall a. (Number -> a) -> String -> Maybe a
umap f s =
  f <$> DN.fromString s
