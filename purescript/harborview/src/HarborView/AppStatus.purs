module HarborView.AppStatus
  where

import HarborView.ModalDialog (ModalState(..))

import Prelude

data AppStatus
  = Ok
  | GeneralError Int
  | SqlError Int
  | ApplicationWarning Int
  | HarborViewErr

type AppStatusResponse =
  { appStatus :: AppStatus
  , msg :: String
  }

statusOk :: AppStatusResponse
statusOk =
  { appStatus: fromInt 0
  , msg: ""
  }

fromInt :: Int -> AppStatus
fromInt status =
  case status of
    0 -> Ok
    11 -> GeneralError 1
    12 -> GeneralError 2
    21 -> SqlError 1
    22 -> SqlError 2
    23 -> SqlError 3
    24 -> SqlError 4
    25 -> SqlError 5
    31 -> ApplicationWarning 1
    32 -> ApplicationWarning 2
    _ -> HarborViewErr -- 100

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
    HarborViewErr ->
      ModalError msg
