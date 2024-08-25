module HarborView.UI.Common
  ( GridPosition(..)
  , HtmlId(..)
  , Style(..)
  , Title(..)
  , randomHtmlId
  ) where

import Prelude

foreign import randomHtmlIdStr :: String

newtype HtmlId =
  HtmlId String

randomHtmlId :: HtmlId
randomHtmlId =
  HtmlId randomHtmlIdStr

newtype GridPosition =
  GridPosition String

newtype Title =
  Title String

newtype Style =
  Style String

data ModalState
  = ModalHidden
  | ModalInfo String
  | ModalError String

instance Show ModalState where
  show ModalHidden = "ModalHidden"
  show (ModalInfo s) = "ModalInfo " <> s
  show (ModalError s) = "ModalError " <> s
