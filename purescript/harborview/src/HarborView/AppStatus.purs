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

type AppStatusResponse =
  { appStatus :: AppStatus
  , msg :: String
  }

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
      ModalError msg
    HttpError statusCode  ->
        ModalError msg
    JsonError s ->
      ModalError msg
