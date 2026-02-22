module HarborView.ModalDialog where

import Prelude

import Web.UIEvent.MouseEvent (MouseEvent)
import Halogen.HTML.Events as HE
import Halogen.HTML as HH
import Halogen.HTML (HTML, ClassName(..))
import Halogen.HTML.Properties as HP
-- import Data.Array ((:))

import HarborView.UI.Common (Title(..))

{- data AlertCategory
    = Info
    | Warn
    | Error -}

data ModalState
  = ModalHidden
  | ModalInfo String
  | ModalError String
  | ModalWarn String
  | ModalNotFound String

instance Show ModalState where
  show ModalHidden = "ModalHidden"
  show (ModalInfo s) = "ModalInfo " <> s
  show (ModalError s) = "ModalError " <> s
  show (ModalWarn s) = "ModalWarn " <> s
  show (ModalNotFound s) = "ModalNotFound " <> s

modalDialogBottomDiv :: forall w i. String -> String -> String -> (MouseEvent -> i) -> HTML w i
modalDialogBottomDiv title headerClass msg evt =
  HH.div [ HP.id "myModal", HP.classes [ ClassName "modal-bottom" ], HP.style "display:block" ]
    [ HH.div [ HP.classes [ ClassName "modal-bottom--content" ] ]
        [ HH.div [ HP.classes [ ClassName headerClass ] ]
            [ HH.span [ HP.classes [ ClassName "modal-bottom--close" ], HE.onClick evt ] [ HH.text "x" ]
            , HH.h5 [ HP.classes [ ClassName "modal-bottom--title" ]]
                [ HH.text title
                ]
            ]
        , HH.div [ HP.classes [ ClassName "modal-bottom--body" ] ]
            [ HH.p [] [ HH.text msg ] ]
        ]
    ]

modalDialogBottom :: forall w i. ModalState -> (MouseEvent -> i) -> HTML w i
modalDialogBottom ModalHidden _ =
  HH.div [ HP.style "display:none" ] []
modalDialogBottom (ModalInfo msg) evt =
  modalDialogBottomDiv  "Info" "modal-bottom--header-info" msg evt
modalDialogBottom (ModalError msg) evt =
  modalDialogBottomDiv "Error" "modal-bottom--header-err" msg evt
modalDialogBottom (ModalWarn msg) evt =
  modalDialogBottomDiv "Warning" "modal-bottom--header-warn" msg evt
modalDialogBottom (ModalNotFound msg) evt =
  modalDialogBottomDiv "Not found" "modal-bottom--header-warn" msg evt

data DialogState
    = DialogHidden
    | DialogVisible

    --DialogVisibleAlert String String AlertCategory

dlgStateToClass :: DialogState -> ClassName
dlgStateToClass DialogHidden = ClassName "dlg-hide"
dlgStateToClass DialogVisible = ClassName "dlg-show"

instance Show DialogState where
  show DialogHidden = "DialogHidden"
  show DialogVisible = "DialogVisible"

okButton :: forall w i. (MouseEvent -> i) -> HTML w i
okButton evt =
  HH.button
    [ HE.onClick evt
    , HP.disabled false
    , HP.classes [ ClassName "ps-w-100 btn btn-success ps-mt-1 ps-mr-1" ]
    ]
    [ HH.text "Ok" ]

cancelButton :: forall w i. (MouseEvent -> i) -> HTML w i
cancelButton evt =
  HH.button
    [ HE.onClick evt
    , HP.disabled false
    , HP.classes [ ClassName "ps-w-100 btn btn-danger ps-mt-1" ]
    ]
    [ HH.text "Cancel" ]

modalDialogDiv :: forall w i. Title -> (MouseEvent -> i) -> (MouseEvent -> i) -> HTML w i -> HTML w i
modalDialogDiv (Title header) ok cancel content =
  let
    headerDiv =
      HH.h6_ [ HH.text header ]
  in
  HH.div
    [ HP.classes [ ClassName "modalDialog" ]
    ]
    [ HH.div [ HP.classes [ ClassName "modaldialog--div"] ]
      [ headerDiv
      , content
      , okButton ok
      , cancelButton cancel
      ]
    ]

modalDialog :: forall w i. DialogState -> Title -> (MouseEvent -> i) -> (MouseEvent -> i) -> HTML w i -> HTML w i
modalDialog DialogHidden _ _ _ _ =
  HH.div [ HP.style "display:none" ] []
modalDialog DialogVisible title ok cancel content =
  modalDialogDiv title ok cancel content
