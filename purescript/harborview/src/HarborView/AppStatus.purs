module HarborView.AppStatus
  where

import HarborView.ModalDialog (ModalState(..))

import Prelude

data AppStatus
  = Ok
  | GeneralError Int
  | SqlError Int
  | ApplicationWarning Int
  | AffjaxError String
  | HttpError Int
  | JsonError String

fromInt :: Int -> AppStatus
fromInt status =
  case status of
    11 -> GeneralError 1
    12 -> GeneralError 2
    21 -> SqlError 1
    22 -> SqlError 2
    23 -> SqlError 3
    24 -> SqlError 4
    25 -> SqlError 5
    31 -> ApplicationWarning 1
    32 -> ApplicationWarning 2
    _ -> Ok

instance Show AppStatus where
  show Ok = "Ok"
  show (GeneralError i) = "GeneralError " <> show i
  show (SqlError i) = "SqlError " <> show i
  show (ApplicationWarning i) = "ApplicationWarning " <> show i
  show (AffjaxError s) = "AffjaxError " <> s
  show (HttpError i) = "HttpError " <> show i
  show (JsonError s) = "JsonError " <> s

-- type AppStatusResponse =
--   { appStatus :: AppStatus
--   , msg :: String
--   }

modalStateFor :: AppStatus -> String -> ModalState
modalStateFor st msg =
  case st of
    Ok ->
      ModalInfo msg
    GeneralError 11 ->
      ModalError  $ "Authentication Error: " <> msg
    GeneralError _ ->
      ModalError  $ "GeneralError: " <> msg
    SqlError errorStatus ->
      let
        msg1 = "SqlError [" <> show errorStatus <> "] : " <> msg
      in
      ModalError msg1
    ApplicationWarning 2 ->
      ModalWarn msg
    ApplicationWarning errorStatus ->
      let
        msg1 = "ApplicationWarning [" <> show errorStatus <> "] : " <> msg
      in
      ModalWarn msg1
    AffjaxError s ->
      ModalError $ "(" <> s <> ") " <> msg
    HttpError statusCode  ->
      ModalError $ "(http staus code: " <> show statusCode <> ") " <> msg
    JsonError s ->
      ModalError $ "(" <> s <> ") " <> msg
