/*
 * MINIGUI - Harbour Win32 GUI library source code
 *
 * Copyright 2016 P.Chornyj <myorg63@mail.ru>
 */

#include "hbclass.ch"
#include "TaskDlgs.ch"
#include "i_var.ch"

////////////////////////////////////////////////////////////////////////////////
CREATE CLASS TSimpleTaskDialog FUNCTION SimpleTaskDialog
////////////////////////////////////////////////////////////////////////////////

   EXPORTED:
   VAR    Cargo
   VAR    lError                       READONLY   INIT .T.
   VAR    nButtonResult                READONLY   INIT NIL
   VAR    nResult                      READONLY   INIT E_FAIL

   METHOD New( cTitle, cInstruction, cContent, nCommonButtons, nMainIcon )
   METHOD Execute()

   METHOD Title( cTitle )              SETGET
   METHOD Instruction( cInstruction )  SETGET
   METHOD Content( cContent )          SETGET
   METHOD CommonButtons( nCBs )        SETGET
   METHOD MainIcon( nIcon )            SETGET

   PROTECTED:
   VAR    cTitle                       INIT       NIL
   VAR    cInstruction                 INIT       NIL
   VAR    cContent                     INIT       NIL
   VAR    nCommonButtons               INIT       TDCBF_OK_BUTTON
   VAR    nMainIcon                    INIT       TD_NO_ICON

ENDCLASS
////////////////////////////////////////////////////////////////////////////////

METHOD New( cTitle, cInstruction, cContent, nCommonButtons, nMainIcon ) CLASS TSimpleTaskDialog

   ::cTitle       := iif( HB_ISNUMERIC( cTitle ), cTitle, iif( ! HB_ISSTRING( cTitle ), NIL, iif( HB_ISNULL( cTitle ), NIL, cTitle ) ) )
   ::cInstruction := iif( HB_ISNUMERIC( cInstruction ), cInstruction, iif( ! HB_ISSTRING( cInstruction ), NIL, iif( HB_ISNULL( cInstruction ), NIL, cInstruction ) ) )
   ::cContent     := iif( HB_ISNUMERIC( cContent ), cContent, iif( ! HB_ISSTRING( cContent ), NIL, iif( HB_ISNULL( cContent ), NIL, cContent ) ) )

   IF HB_ISNUMERIC( nCommonButtons )
      ::nCommonButtons := nCommonButtons
   ENDIF

   IF HB_ISNUMERIC( nMainIcon )
      ::nMainIcon := nMainIcon
   ENDIF

RETURN Self

METHOD Execute() CLASS TSimpleTaskDialog

   LOCAL nResult
   LOCAL nButton := NIL

   ::lError        := .T.
   ::nButtonResult := NIL
   ::nResult       := E_FAIL

   IF os_IsWinVista_Or_Later()
      nResult := win_TaskDialog0( ,, ::cTitle, ::cInstruction, ::cContent, ::nCommonButtons, ::nMainIcon, @nButton )
   ELSE
      nResult := E_NOTIMPL // Not implemented yet
   ENDIF

   ::lError        := !( nResult == NOERROR )
   ::nButtonResult := nButton
   ::nResult       := nResult

RETURN ( ! ::lError )

METHOD Title( cTitle ) CLASS TSimpleTaskDialog

   LOCAL cOldVal := ::cTitle

   IF HB_ISSTRING( cTitle ) .OR. HB_ISNUMERIC( cTitle )
      ::cTitle := iif( HB_ISSTRING( cTitle ) .AND. HB_ISNULL( cTitle ), NIL, cTitle )
   ENDIF

RETURN cOldVal

METHOD Instruction( cInstruction ) CLASS TSimpleTaskDialog

   LOCAL cOldVal := ::cInstruction

   IF HB_ISSTRING( cInstruction ) .OR. HB_ISNUMERIC( cInstruction )
      ::cInstruction := iif( HB_ISSTRING( cInstruction ) .AND. HB_ISNULL( cInstruction ), NIL, cInstruction )
   ENDIF

RETURN cOldVal

METHOD Content( cContent ) CLASS TSimpleTaskDialog

   LOCAL cOldVal := ::cContent

   IF HB_ISSTRING( cContent ) .OR. HB_ISNUMERIC( cContent )
      ::cContent := iif( HB_ISSTRING( cContent ) .AND. HB_ISNULL( cContent ), NIL, cContent )
   ENDIF

RETURN cOldVal

METHOD CommonButtons( nCBs ) CLASS TSimpleTaskDialog

   LOCAL nOldVal := ::nCommonButtons

   IF HB_ISNUMERIC( nCBs )
      ::nCommonButtons := nCBs
   ENDIF

RETURN nOldVal

METHOD MainIcon( nIcon ) CLASS TSimpleTaskDialog

   LOCAL nOldVal := ::nMainIcon

   IF HB_ISNUMERIC( nIcon )
      ::nMainIcon := nIcon
   ENDIF

RETURN nOldVal

////////////////////////////////////////////////////////////////////////////////
CREATE CLASS TTaskDialog FUNCTION TaskDialog
////////////////////////////////////////////////////////////////////////////////

   EXPORTED:
   VAR    Cargo
   VAR    lActive               READONLY   INIT .F.
   VAR    lError                READONLY   INIT .T.
   VAR    nButtonResult         READONLY   INIT NIL
   VAR    nRadioButtonResult    READONLY   INIT NIL
   VAR    nResult               READONLY   INIT E_FAIL
   VAR    lVerifyResult         READONLY   INIT .F.

   METHOD New( cTitle, cInstruction, cContent, cFooter, nCommonButtons, nMainIcon )
   METHOD Execute() INLINE ::ShowDialog()
   METHOD ShowDialog()
   METHOD DialogHandle()
   METHOD Showing( lState )
   METHOD OnCreated( hWnd, nNotify, nWParam, nLParam )
   METHOD OnDestroyed( hWnd, nNotify, nWParam, nLParam )
   METHOD Listener( hWnd, nNotify, nWParam, nLParam )
   METHOD CommonButtons( nCBs )                SETGET
   METHOD WindowTitle( cTitle )                SETGET
   METHOD Title( cTitle )                      SETGET
   METHOD MainIcon( nIcon )                    SETGET
   METHOD MainInstruction( cInstruction )      SETGET
   METHOD Instruction( cInstruction )          SETGET
   METHOD Content( cContent )                  SETGET
   METHOD CustomButtons( aCustButton )         SETGET
   METHOD DefaultButton( nDefaultButton )      SETGET
   METHOD CustomRadioButtons( aCustButton )    SETGET
   METHOD DefaultRadioButton( nDefaultButton ) SETGET
   METHOD VerificationText( cText )            SETGET
   METHOD ExpandedInfo( cText )                SETGET
   METHOD ExpandedControlText( cText )         SETGET
   METHOD ExpandedCtrlText( cText )            SETGET
   METHOD CollapsedControlText( cText )        SETGET
   METHOD CollapsedCtrlText( cText )           SETGET
   METHOD FooterIcon( nIcon )                  SETGET
   METHOD Footer( cFooter )                    SETGET
   METHOD Width( nWidth )                      SETGET
   METHOD Parent( cFormName )                  SETGET
   METHOD ParentHandle( nHandle )              SETGET
   METHOD CallBackBlock( bCode )               SETGET
   METHOD Flags( nFlags )                      SETGET
   METHOD AllowDialogCancellation( lNewVal )   SETGET
   METHOD CanBeMinimized( lNewVal )            SETGET
   METHOD EnableHyperlinks( lNewVal )          SETGET
   METHOD ExpandedByDefault( lNewVal )         SETGET
   METHOD ExpandFooterArea( lNewVal )          SETGET
   METHOD NoDefaultRadioButton( lNewVal )      SETGET
   METHOD PositionRelativeToWindow( lNewVal )  SETGET
   METHOD RightToLeftLayout( lNewVal )         SETGET
   METHOD VerificationEnabled( lNewVal )       SETGET
   METHOD timeoutMS( nMS )                     SETGET
   METHOD TimedOut( lOut )                     SETGET
   // NOTE: Next method returns valid (non NIL) result if a the dialog has been shown
   // The ID of the clicked button
   METHOD SelectedButton()      INLINE ::nButtonResult
   // The ID of the selected radio button
   METHOD SelectedRadioButton() INLINE ::nRadioButtonResult
   // The state of the verification checkbox (read only)
   METHOD VerificationChecked() INLINE ::lVerifyResult    /*TODO*/

   PROTECTED:
   VAR aConfig                  INIT Array( TDC_CONFIG )
   VAR HWND            READONLY INIT NIL
   VAR lTimeOut        READONLY INIT .F.
   VAR nTimeOutMS      READONLY INIT 0

ENDCLASS
////////////////////////////////////////////////////////////////////////////////

METHOD New( cTitle, cInstruction, cContent, cFooter, nCommonButtons, nMainIcon ) CLASS TTaskDialog

   ::aConfig[ TDC_WINDOWTITLE ]     := iif( HB_ISNUMERIC( cTitle ), cTitle, iif( ! HB_ISSTRING( cTitle ), NIL, iif( HB_ISNULL( cTitle ), NIL, cTitle ) ) )
   ::aConfig[ TDC_MAININSTRUCTION ] := iif( HB_ISNUMERIC( cInstruction ), cInstruction, iif( ! HB_ISSTRING( cInstruction ), NIL, iif( HB_ISNULL( cInstruction ), NIL, cInstruction ) ) )
   ::aConfig[ TDC_CONTENT ] := iif( HB_ISNUMERIC( cContent ), cContent, iif( ! HB_ISSTRING( cContent ), NIL, iif( HB_ISNULL( cContent ), NIL, cContent ) ) )
   ::aConfig[ TDC_FOOTER ]  := iif( HB_ISNUMERIC( cFooter ), cFooter, iif( ! HB_ISSTRING( cFooter ), NIL, iif( HB_ISNULL( cFooter ), NIL, cFooter ) ) )

   IF HB_ISNUMERIC( nCommonButtons )
      ::aConfig[ TDC_COMMON_BUTTON_FLAGS ] := nCommonButtons
   ENDIF

   IF HB_ISNUMERIC( nMainIcon )
      ::aConfig[ TDC_MAINICON ] := nMainIcon
   ENDIF

RETURN Self

/*
   Shows the dialog.

   NOTE: Returns true if everything worked right. Returns false if creation of dialog failed.
   Requires Windows Vista or newer.
 */
METHOD ShowDialog() CLASS TTaskDialog

   LOCAL nResult
   LOCAL nButton      := NIL
   LOCAL nRadioButton := NIL
   LOCAL lVerificationFlagChecked := .F.

   IF ! ::lActive
      ::lError             := .T.
      ::nButtonResult      := NIL
      ::nRadioButtonResult := NIL
      ::nResult            := E_FAIL
      ::TimedOut           := .F.

      IF ::timeoutMS() > 0 .OR. __objHasMethod( Self, "ONTIMER" )
         ::Flags := hb_bitOr( ::Flags, TDF_CALLBACK_TIMER )
      ENDIF

      IF ::timeoutMS() > 0
         ::AllowDialogCancellation := .T.
      ENDIF

      IF os_IsWinVista_Or_Later()
         ::aConfig[ 23 ] := self
         nResult := win_TaskDialogIndirect0( ::aConfig, @nButton, @nRadioButton, @lVerificationFlagChecked )
      ELSE
         nResult := E_NOTIMPL // Not implemented yet
      ENDIF

      ::lError             := !( nResult == NOERROR )
      ::nButtonResult      := nButton
      ::nRadioButtonResult := nRadioButton
      ::lVerifyResult      := lVerificationFlagChecked
      ::nResult            := nResult
   ENDIF

RETURN ( ! ::lError )

/*
   The handle of the dialog.

   NOTE: This is only valid (and non NIL) while dialog is visible (read only).
 */
METHOD DialogHandle() CLASS TTaskDialog
RETURN ::HWND

/*
   Whether dialog is currently showing (read/write).
 */
METHOD Showing( lState ) CLASS TTaskDialog

   hb_default( @lState, .F. )

   IF lState .AND. ! ::lActive
      ::ShowDialog()
   ENDIF

RETURN ::lActive

/*
   Indicates that the Task Dialog has been created.
*/
METHOD OnCreated( hWnd, nNotify, nWParam, nLParam ) CLASS TTaskDialog

   HB_SYMBOL_UNUSED( nWParam )
   HB_SYMBOL_UNUSED( nLParam )

   IF nNotify == TDN_CREATED
      ::lActive := .T.
      ::HWND := hWnd
   ENDIF

RETURN .F.

/*
   Indicates that the Task Dialog has been destroyed.
*/
METHOD OnDestroyed( hWnd, nNotify, nWParam, nLParam ) CLASS TTaskDialog

   HB_SYMBOL_UNUSED( hWnd )
   HB_SYMBOL_UNUSED( nWParam )
   HB_SYMBOL_UNUSED( nLParam )

   IF nNotify == TDN_DESTROYED
      ::lActive := .F.
      ::HWND := Nil
   ENDIF

RETURN .F.

/*
   The default Events Listener.
*/
METHOD Listener( hWnd, nNotify, nWParam, nLParam ) CLASS TTaskDialog

   HB_SYMBOL_UNUSED( hWnd )

   IF HB_ISEVALITEM( ::aConfig[ TDC_CALLBACK ] )
      RETURN ::aConfig[ TDC_CALLBACK ]:Eval( self, nNotify, nWParam, nLParam )
   ENDIF

RETURN .T.

/*
   Specifies the push buttons displayed in the task dialog (read/write).

   NOTE:  If  no  common  buttons  are  specified  and  no  custom buttons are
   specified through buttons array, the task dialog will contain the OK button
   by default.
 */
METHOD CommonButtons( nCBs ) CLASS TTaskDialog

   LOCAL nOldCBS := ::aConfig[ TDC_COMMON_BUTTON_FLAGS ]

   IF ! ::lActive
      IF HB_ISNUMERIC( nCBs )
         ::aConfig[ TDC_COMMON_BUTTON_FLAGS ] := nCBs
      ENDIF
   ENDIF

RETURN nOldCBS

/*
   The string to be used for the task dialog title (read/write, LIVE).
 */
METHOD WindowTitle( cTitle ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_WINDOWTITLE ]

   IF HB_ISSTRING( cTitle ) .OR. HB_ISNUMERIC( cTitle )
      ::aConfig[ TDC_WINDOWTITLE ] := iif( HB_ISSTRING( cTitle ) .AND. HB_ISNULL( cTitle ), NIL, cTitle )
      IF ::lActive
         _SetWindowTitle( ::HWND, ::aConfig[ TDC_WINDOWTITLE ] )
      ENDIF
   ENDIF

RETURN cOldVal

METHOD Title( cTitle ) CLASS TTaskDialog
RETURN ::WindowTitle( cTitle )

/*
   TODO
*/
METHOD MainIcon( nIcon ) CLASS TTaskDialog

   IF HB_ISNUMERIC( nIcon )
      ::aConfig[ TDC_MAINICON ] := nIcon
      IF ::lActive
         _UpdateMainIcon( ::HWND, ::aConfig[ TDC_MAINICON ] )
      ENDIF
   ENDIF

RETURN ::aConfig[ TDC_MAINICON ]

/* MainInstruction

   The string to be used for the main instruction (read/write, LIVE).
 */
METHOD MainInstruction( cInstruction ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_MAININSTRUCTION ]

   IF HB_ISSTRING( cInstruction ) .OR. HB_ISNUMERIC( cInstruction )
      ::aConfig[ TDC_MAININSTRUCTION ] := iif( HB_ISSTRING( cInstruction ) .AND. HB_ISNULL( cInstruction ), NIL, cInstruction )
      IF ::lActive
         _SetMainInstruction( ::HWND, ::aConfig[ TDC_MAININSTRUCTION ] )
      ENDIF
   ENDIF

RETURN cOldVal

METHOD Instruction( cInstruction ) CLASS TTaskDialog
RETURN ::MainInstruction( cInstruction )

/*
   The string to be used for the dialog's primary content (read/write, LIVE).
 */
METHOD Content( cContent ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_CONTENT ]

   IF HB_ISSTRING( cContent ) .OR. HB_ISNUMERIC( cContent )
      ::aConfig[ TDC_CONTENT ] := iif( HB_ISSTRING( cContent ) .AND. HB_ISNULL( cContent ), NIL, cContent )
      IF ::lActive
         _SetContent( ::HWND, ::aConfig[ TDC_CONTENT ] )
      ENDIF
   ENDIF

RETURN cOldVal

/*
   TODO
*/
METHOD CustomButtons( aCustButton ) CLASS TTaskDialog

   LOCAL aOldVal := ::aConfig[ TDC_TASKDIALOG_BUTTON ]

   IF ! ::lActive
      IF HB_ISARRAY( aCustButton ) .AND. Len( aCustButton ) > 0
         ::aConfig[ TDC_BUTTON ] := Len( aCustButton )
         ::aConfig[ TDC_TASKDIALOG_BUTTON ] := aCustButton
      ENDIF
   ENDIF

RETURN aOldVal

/*
   The default button for the task dialog (read/write).

   Note:  This may be any of the values specified in ID of one of the buttons,
   or   one  of  the  IDs  corresponding  to  the  buttons  specified  in  the
   CommonButtons property.
*/
METHOD DefaultButton( nDefaultButton ) CLASS TTaskDialog

   LOCAL nOldVal := ::aConfig[ TDC_DEFAULTBUTTON ]

   IF ! ::lActive
      IF HB_ISNUMERIC( nDefaultButton )
         ::aConfig[ TDC_DEFAULTBUTTON ] := nDefaultButton
      ENDIF
   ENDIF

RETURN nOldVal

/*
   TODO
*/
METHOD CustomRadioButtons( aCustButton ) CLASS TTaskDialog

   LOCAL aOldVal := ::aConfig[ TDC_TASKDIALOG_RADIOBUTTON ]

   IF ! ::lActive
      IF HB_ISARRAY( aCustButton ) .AND. Len( aCustButton ) > 0
         ::aConfig[ TDC_RADIOBUTTON ] := Len( aCustButton )
         ::aConfig[ TDC_TASKDIALOG_RADIOBUTTON ] := aCustButton
      ENDIF
   ENDIF

RETURN aOldVal

/*
   The button ID of the radio button that is selected by default (read/write).

   NOTE: If this value does not correspond to a button ID, the first button in the array is selected by default.
 */
METHOD DefaultRadioButton( nDefaultButton ) CLASS TTaskDialog

   LOCAL nOldVal := ::aConfig[ TDC_DEFAULTRADIOBUTTON ]

   IF ! ::lActive
      IF HB_ISNUMERIC( nDefaultButton )
         ::aConfig[ TDC_DEFAULTRADIOBUTTON ] := nDefaultButton
      ENDIF
   ENDIF

RETURN nOldVal

/*
   The string to be used to label the verification checkbox (read/write).
*/
METHOD VerificationText( cText ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_VERIFICATIONTEXT ]

   IF ! ::lActive
      IF HB_ISSTRING( cText ) .OR. HB_ISNUMERIC( cText )
         ::aConfig[ TDC_VERIFICATIONTEXT ] := cText
      ENDIF
   ENDIF

RETURN cOldVal

/* ExpandedInformation
   The string to be used for displaying additional information (read/write,
   LIVE).

   NOTE:  The additional information is displayed either immediately below the
   content  or below the footer text depending on whether the ExpandFooterArea
   flag  is  true.  If the EnableHyperlinks flag is true, then this string may
   contain   hyperlinks  in  the  form:

   <A  HREF="executablestring">Hyperlink Text</A>.

   WARNING:  Enabling  hyperlinks when using content from an unsafe source may
   cause security vulnerabilities.
 */
METHOD ExpandedInfo( cText ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_EXPANDEDINFORMATION ]

   IF HB_ISSTRING( cText ) .OR. HB_ISNUMERIC( cText )
      ::aConfig[ TDC_EXPANDEDINFORMATION ] := cText
      IF ::lActive
         _SetExpandedInformation( ::HWND, ::aConfig[ TDC_EXPANDEDINFORMATION ] )
      ENDIF
   ENDIF

RETURN cOldVal

/* ExpandedControlText
   The  string  to  be  used to label the button for collapsing the expandable
   information (read/write).

   NOTE: This member is ignored when the ExpandedInformation member is empty.
   If this member is empty and the CollapsedControlText is specified, then the
   CollapsedControlText value will be used for this member as well.
 */
METHOD ExpandedControlText( cText ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_EXPANDEDCONTROLTEXT ]

   IF ! ::lActive
      IF HB_ISSTRING( cText ) .OR. HB_ISNUMERIC( cText )
         ::aConfig[ TDC_EXPANDEDCONTROLTEXT ] := cText
      ENDIF
   ENDIF

RETURN cOldVal

METHOD ExpandedCtrlText( cText ) CLASS TTaskDialog
RETURN ::ExpandedControlText( cText )

/* CollapsedControlText
   The  string  to  be  used  to label the button for expanding the expandable
   information (read/write).

   NOTE: This member  is ignored when the ExpandedInformation member is empty.
   If this member is empty and the CollapsedControlText is specified, then the
   CollapsedControlText value will be used for this member as well.
 */
METHOD CollapsedControlText( cText ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_COLLAPSEDCONTROLTEXT ]

   IF ! ::lActive
      IF HB_ISSTRING( cText ) .OR. HB_ISNUMERIC( cText )
         ::aConfig[ TDC_COLLAPSEDCONTROLTEXT ] := cText
      ENDIF
   ENDIF

RETURN cOldVal

METHOD CollapsedCtrlText( cText ) CLASS TTaskDialog
RETURN ::CollapsedControlText( cText )

/*
   TODO
*/
METHOD FooterIcon( nIcon ) CLASS TTaskDialog

   LOCAL nOldVal := ::aConfig[ TDC_FOOTERICON ]

   IF HB_ISNUMERIC( nIcon )
      ::aConfig[ TDC_FOOTERICON ] := nIcon
      IF ::lActive
         _UpdateFooterIcon( ::HWND, ::aConfig[ TDC_FOOTERICON ] )
      ENDIF
   ENDIF

RETURN nOldVal

/*
   The string to be used in the footer area of the task dialog (read/write).

   NOTE: If EnableHyperlinks is true, this can show clickable links.
 */
METHOD Footer( cFooter ) CLASS TTaskDialog

   LOCAL cOldVal := ::aConfig[ TDC_FOOTER ]

   IF HB_ISSTRING( cFooter ) .OR. HB_ISNUMERIC( cFooter )
      ::aConfig[ TDC_FOOTER ] := cFooter
      IF ::lActive
         _SetFooter( ::HWND, ::aConfig[ TDC_FOOTER ] )
      ENDIF
   ENDIF

RETURN cOldVal

/*
   The width of the task dialog's client area, in dialog units (read/write).

   NOTE: If 0, the task dialog manager will calculate the ideal width.
 */
METHOD Width( nWidth ) CLASS TTaskDialog

   LOCAL nOldVal := ::aConfig[ TDC_WIDTH ]

   IF ! ::lActive .AND. HB_ISNUMERIC( nWidth )
      ::aConfig[ TDC_WIDTH ] := nWidth
   ENDIF

RETURN nOldVal

/*
   Parent window handle (read/write).
 */
METHOD ParentHandle( nHandle ) CLASS TTaskDialog

   LOCAL nOldVal := ::aConfig[ TDC_HWND ]

   IF ! ::lActive .AND. HB_ISNUMERIC( nHandle ) .AND. IsWindowHandle( nHandle )
      ::aConfig[ TDC_HWND ] := nHandle
   ENDIF

RETURN nOldVal

/*
   Parent window name (read/write).
 */
METHOD Parent( cFormName ) CLASS TTaskDialog
RETURN _HMG_aFormNames[ AScan ( _HMG_aFormHandles, ::ParentHandle( GetFormHandle( cFormName ) ) ) ]

/*
   NOTE: Method CallBackBlock will be deleted in future (not near)
*/
METHOD CallBackBlock( bCode ) CLASS TTaskDialog

   IF ! ::lActive
      IF HB_ISEVALITEM( bCode )
         ::aConfig[ TDC_CALLBACK ] := bCode
      ENDIF
   ENDIF

RETURN ::aConfig[ TDC_CALLBACK ]

////////////////////////////////////////////////////////////////////////////////
/*
   The flags (read/write).

   NOTE:  Maybe You should not need to set flags as we have properties for all
   relevant flags.
 */
METHOD Flags( nFlags ) CLASS TTaskDialog

   LOCAL nOldVal := ::aConfig[ TDC_TASKDIALOG_FLAGS ]
   IF ! ::lActive
      IF HB_ISNUMERIC( nFlags )
         ::aConfig[ TDC_TASKDIALOG_FLAGS ] := nFlags
      ENDIF
   ENDIF

RETURN nOldVal

/*
   Whether to allow cancel (read/write).

   NOTE: Indicates that the dialog  should be  able to be closed using Alt-F4,
   Escape,  and  the  title  bar's  close  button  even if no cancel button is
   specified  in  either the CommonButtons or Buttons members.
 */
METHOD AllowDialogCancellation( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_ALLOW_DIALOG_CANCELLATION ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_ALLOW_DIALOG_CANCELLATION )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_ALLOW_DIALOG_CANCELLATION ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   Indicates that the task dialog can be minimized (read/write).
 */
METHOD CanBeMinimized( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_CAN_BE_MINIMIZED ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_CAN_BE_MINIMIZED )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_CAN_BE_MINIMIZED ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   Whether to enable hyperlinks (read/write).

   NOTE:  Enables  hyperlink  processing  for  the  strings  specified  in the
   Content,  ExpandedInformation  and  Footer  members.  When  enabled,  these
   members may point to strings that contain hyperlinks in the following form:

   <A HREF="executablestring">Hyperlink Text</A>

   NOTE:  Task  Dialogs  will  not  actually execute any hyperlinks. Hyperlink
   execution _must be handled_ in the OnHyperlinkClicked event.

   WARNING:  Enabling  hyperlinks when using content from an unsafe source may
   cause security vulnerabilities.
 */
METHOD EnableHyperlinks( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_ENABLE_HYPERLINKS ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_ENABLE_HYPERLINKS )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_ENABLE_HYPERLINKS ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   Indicates  that  the  string specified by the ExpandedInformation member is
   displayed when the dialog is initially displayed (read/write).

   NOTE: This flag is ignored if the ExpandedInformation member is empty.
 */
METHOD ExpandedByDefault( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_EXPANDED_BY_DEFAULT ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_EXPANDED_BY_DEFAULT )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_EXPANDED_BY_DEFAULT ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   Whether expand footer area is displayed at the bottom (read/write).

   NOTE: Indicates that the string specified by the ExpandedInformation member
   is  displayed  at  the  bottom  of  the  dialog's  footer  area  instead of
   immediately  after  the  dialog's  content.  This  flag  is  ignored if the
   ExpandedInformation member is empty.
 */
METHOD ExpandFooterArea( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_EXPAND_FOOTER_AREA ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_EXPAND_FOOTER_AREA )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_EXPAND_FOOTER_AREA ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   Indicates that no default item will be selected (read/write)
 */
METHOD NoDefaultRadioButton( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_NO_DEFAULT_RADIO_BUTTON ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_NO_DEFAULT_RADIO_BUTTON )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_NO_DEFAULT_RADIO_BUTTON ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   Indicates  that  the  task  dialog is positioned (centered) relative to the
   window specified by parent.

   NOTE:  If  the flag is not supplied (or no parent member is specified), the
   task dialog is positioned (centered) relative to the monitor.
 */
METHOD PositionRelativeToWindow( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_POSITION_RELATIVE_TO_WINDOW ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_POSITION_RELATIVE_TO_WINDOW )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_POSITION_RELATIVE_TO_WINDOW ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   Indicates that text is displayed reading right to left (read/write).
 */
METHOD RightToLeftLayout( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_RTL_LAYOUT ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_RTL_LAYOUT )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_RTL_LAYOUT ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

/*
   The enable state of the verification checkbox.

   NOTE: Can be true to enable the checkbox or false to disable.
 */
METHOD VerificationEnabled( lNewVal ) CLASS TTaskDialog

   LOCAL nCurFlags := ::Flags(), lOldVal
   LOCAL nNewFlags

   hb_default( @nCurFlags, 0 )
   lOldVal := ( hb_bitAnd( nCurFlags, TDF_VERIFICATION_FLAG_CHECKED ) != 0 )

   IF ! ::lActive .AND. HB_ISLOGICAL( lNewVal )
      IF ( ( ! lOldVal ) .AND. lNewVal )
         nNewFlags := hb_bitOr( nCurFlags, TDF_VERIFICATION_FLAG_CHECKED )
      ELSEIF ( lOldVal .AND. ( ! lNewVal ) )
         nNewFlags := hb_bitAnd( nCurFlags, hb_bitNot( TDF_VERIFICATION_FLAG_CHECKED ) )
      ENDIF
      ::Flags( nNewFlags )
   ENDIF

RETURN lOldVal

////////////////////////////////////////////////////////////////////////////////
/*
   The timeout for the dialog (read/write).

   NOTE: In Milliseconds. The dialog closes after given time.
 */
METHOD timeoutMS ( nMS ) CLASS TTaskDialog

   LOCAL nOldVal := ::nTimeOutMS

   IF ! ::lActive .AND. HB_ISNUMERIC( nMS )
      ::nTimeOutMS := nMS
   ENDIF

RETURN nOldVal

/*
   Whether we got a timeout (read/write, read only in future, maybe)
 */
METHOD TimedOut( lOut ) CLASS TTaskDialog

   IF ::lActive .AND. HB_ISLOGICAL( lOut )
      ::lTimeOut := lOut
   ENDIF

RETURN ::lTimeOut
