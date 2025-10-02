module HarborView.ModalDialog where

import Prelude

import Web.UIEvent.MouseEvent (MouseEvent)
import Halogen.HTML.Events as HE
import Halogen.HTML as HH
import Halogen.HTML (HTML, ClassName(..))
import Halogen.HTML.Properties as HP
-- import Data.Array ((:))

import HarborView.UI as UI
import HarborView.UI (Title(..))

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


modalDialog :: forall w i.
  Title
  -> DialogState
  -> (MouseEvent -> i)
  -> (MouseEvent -> i)
  -> HTML w i
  -> HTML w i
modalDialog (Title header) dlgState ok cancel content =
  let
    headerDiv =
      HH.h4_ [ HH.text header ]
  in
  HH.div
    [ HP.classes
      [ ClassName "modalDialog"
      , dlgStateToClass dlgState
      ]
    ]
    [ HH.div_
      [ headerDiv
      , content
      , UI.mkButton (Title "OK") ok
      , UI.mkButton (Title "Cancel") cancel
      ]
    ]
