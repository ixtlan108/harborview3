module HarborView.UI.Common
  ( GridPosition(..)
  , HtmlId(..)
  , Style(..)
  , Title(..)
  , InputWrapperParams
  , randomHtmlId
  , mkInputWrapper
  ) where

import Prelude

--import Halogen.HTML (AttrName(..), ClassName(..), HTML)
import Halogen.HTML (ClassName, HTML)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

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

type InputWrapperParams =
  { title :: Title
  , lblClazz :: Array ClassName
  , spanClazz :: Array ClassName
  }

mkInputWrapper :: forall w i. InputWrapperParams -> HTML w i -> HTML w i
mkInputWrapper p inp =
  let
    Title t = p.title
  in
    HH.span [ HP.classes p.spanClazz ]
      [ HH.label [ HP.classes p.lblClazz ] [ HH.text t, inp ]
      ]
