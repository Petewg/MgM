/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'INI File Editor'
#define VERSION ' version 1.0.2'
#define COPYRIGHT ' 2006 by Grigory Filatov'

#define IDI_MAIN 1001
#define ErrorMsg( c ) MsgStop( c, "Error", , .f. )

Static cIniFile := "", cSaveIni := ""

Procedure Main(cFile)
Local lFlat := .F.

SET HELPFILE TO 'Inife.chm'

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 684 HEIGHT IF(IsXPThemeActive(), 504, 498) ;
		TITLE PROGRAM + VERSION ;
		ICON IDI_MAIN ;
		MAIN ;
		ON INIT OnInit(cFile) ;
		ON MAXIMIZE OnResize() ;
		ON SIZE OnResize() ;
		FONT "MS Sans Serif" SIZE 9
		
		DEFINE BUTTONEX Button_1
			ROW    03
			COL    09
			WIDTH  97
			HEIGHT 29
			CAPTION "Open Ini File"
			PICTURE "OPEN"
			ACTION OpenIni()
			NOHOTLIGHT .T.
			NOXPSTYLE .F.
			TABSTOP .F.
			VISIBLE .T.
		END BUTTONEX

		@ 11, 114 LABEL Label_1 VALUE "Current File: " + cIniFile ;
			WIDTH 500 ;
			HEIGHT 14 ;
			BOLD

		@ 00, 604 LABEL Label_Help VALUE "Help/Info" ;
			AUTOSIZE FONTCOLOR BLUE ;
			ACTION _Execute( _HMG_MainHandle, "open", GetStartupFolder() + "\INIFE.Chm" )

		DEFINE TAB Tab_1 ;
			AT 35, 09 ;
			WIDTH 658 ;
			HEIGHT 29 ;
			HOTTRACK ;
			ON CHANGE OnTabChange() ;
			NOTABSTOP

		END TAB

		@ 68, 08 LABEL Label_2 VALUE "Section:" ;
			WIDTH 300 ;
			HEIGHT 14 ;
			BOLD

		@ 87,05 GRID Grid_1 ;
			WIDTH 323 ;
			HEIGHT 372 ;
			WIDTHS { 300 }	;
			NOLINES NOHEADERS ;
			ON GOTFOCUS SetContextMenu() ;
			ON CHANGE SetContextMenu() ;
			ON DBLCLICK EditIniVal()

		DRAW RECTANGLE ;
			IN WINDOW Form_1 ;
			AT 66, 333 ;
			TO Form_1.Height - GetTitleHeight() - 2*GetBorderHeight() - IF(IsXPThemeActive(), 2, 0), 337 ;
			FILLCOLOR GRAY

		DEFINE BUTTONEX Btn_Sort
			ROW    68
			COL    476
			WIDTH  88
			HEIGHT 22
			CAPTION "Sort Tabs"
			PICTURE "SORT"
			ACTION TabSort()
			NOHOTLIGHT .T.
			NOXPSTYLE .F.
			FLAT lFlat
			TABSTOP .F.
			VISIBLE .T.
		END BUTTONEX

		DEFINE BUTTONEX Btn_Jump
			ROW    68
			COL    576
			WIDTH  90
			HEIGHT 22
			CAPTION "Tab Jumper"
			PICTURE "JUMP"
			ACTION TabJump()
			NOHOTLIGHT .T.
			NOXPSTYLE .F.
			FLAT lFlat
			TABSTOP .F.
			VISIBLE .T.
		END BUTTONEX

		@ 89,339 FRAME Frame_1 ;
			CAPTION 'Scratch Pad' ;
			WIDTH 328 ;
			HEIGHT 328

		@ 105, 344 EDITBOX Edit_1 WIDTH 317 HEIGHT 263 VALUE ""

		DEFINE BUTTONEX Button_2
			ROW    374
			COL    344
			WIDTH  134
			HEIGHT 38
			CAPTION "Copy to Clipboard"
			PICTURE "COPY"
			ACTION ( IF( Empty(Form_1.Edit_1.Value), , CopyToClipboard( Form_1.Edit_1.Value ) ), Form_1.Edit_1.Setfocus )
			NOHOTLIGHT .T.
			NOXPSTYLE .F.
			FLAT lFlat
			TABSTOP .F.
			VISIBLE .T.
		END BUTTONEX

		DEFINE BUTTONEX Button_3
			ROW    374
			COL    508
			WIDTH  138
			HEIGHT 38
			CAPTION "Clear Scratch Pad"
			PICTURE "CLEAR"
			ACTION ( Form_1.Edit_1.Value := "", Form_1.Edit_1.Setfocus )
			NOHOTLIGHT .T.
			NOXPSTYLE .F.
			FLAT lFlat
			TABSTOP .F.
			VISIBLE .T.
		END BUTTONEX

		DEFINE BUTTONEX Button_4
			ROW    422
			COL    344
			WIDTH  224
			HEIGHT 38
			CAPTION "Append ScratchPad to Other Ini File"
			PICTURE "APPEND"
			ACTION Export2Ini()
			NOHOTLIGHT .T.
			NOXPSTYLE .F.
			FLAT lFlat
			TABSTOP .F.
			VISIBLE .T.
		END BUTTONEX

		DEFINE BUTTON Button_5
			ROW    422
			COL    608
			WIDTH  38
			HEIGHT 38
			ICON "MAIN"
			ACTION MsgAbout()
			FLAT .T.
			TABSTOP .F.
			VISIBLE .T.
		END BUTTON

	END WINDOW

	DEFINE CONTEXT MENU CONTROL Grid_1 OF Form_1
		ITEM '&Send to Scratch Pad'	ACTION Send2SP() IMAGE 'SEND'

		SEPARATOR

		ITEM '&Add Section'		ACTION AddSection() IMAGE 'ADD'
		ITEM '&Delete Section'		ACTION DelSection() IMAGE 'DELETE'

		SEPARATOR

		ITEM 'Add &Key'			ACTION AddIniKey() IMAGE 'ADDKEY'
		ITEM '&Edit Value'		ACTION EditIniVal() IMAGE 'EDIT' NAME EditVal
		ITEM 'De&lete Key'		ACTION DelIniKey() IMAGE 'DELKEY' NAME DelKey
	END MENU

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure OnInit( cFile )
*--------------------------------------------------------*
Local lVisible

	If Valtype(cFile) == "C" .AND. File(cFile)

		OpenIni(cFile)

	Else

		lVisible := !Empty(cIniFile)
		Form_1.Label_1.Visible := lVisible
		Form_1.Btn_Sort.Visible := lVisible
		Form_1.Btn_Jump.Visible := lVisible
		Form_1.Edit_1.Setfocus

	EndIf

Return

#xcommand ERASE WINDOW <windowname> ;
	AT <nT>,<nL>	;
	TO <nB>,<nR>	;
	=> EraseWindow(<"windowname">,<nT>,<nL>,<nB>,<nR>)

*--------------------------------------------------------*
Procedure OnResize()
*--------------------------------------------------------*

	IF Form_1.Width < 684
		Form_1.Width := 684
	ENDIF
	IF Form_1.Height < IF(IsXPThemeActive(), 469, 463)
		Form_1.Height := IF(IsXPThemeActive(), 469, 463)
	ENDIF

	ERASE WINDOW Form_1		;
		AT 66, 333		;
		TO Form_1.Height - GetTitleHeight(), 337	;

	DRAW RECTANGLE			;
		IN WINDOW Form_1	;
		AT 66, 333		;
		TO Form_1.Height - GetTitleHeight() - 2*GetBorderHeight() - IF(IsXPThemeActive(), 2, 0), 337	;
		FILLCOLOR GRAY

	Form_1.Label_Help.Col := Form_1.Width-80
	Form_1.Tab_1.Width := Form_1.Width-26
	Form_1.Grid_1.Height := Form_1.Height-IF(IsXPThemeActive(), 132, 126)

	Form_1.Btn_Sort.Col := Form_1.Width-208
	Form_1.Btn_Jump.Col := Form_1.Width-108

	Form_1.Frame_1.Width := Form_1.Width-356
	Form_1.Frame_1.Height := Form_1.Height-IF(IsXPThemeActive(), 176, 170)

	Form_1.Edit_1.Width := Form_1.Width-367
	Form_1.Edit_1.Height := Form_1.Height-IF(IsXPThemeActive(), 241, 235)

	Form_1.Button_2.Row := Form_1.Height-IF(IsXPThemeActive(), 130, 124)
	Form_1.Button_3.Row := Form_1.Height-IF(IsXPThemeActive(), 130, 124)
	Form_1.Button_4.Row := Form_1.Height-IF(IsXPThemeActive(), 82, 76)
	Form_1.Button_5.Row := Form_1.Height-IF(IsXPThemeActive(), 82, 76)
	Form_1.Button_5.Col := Form_1.Width-76

Return

*--------------------------------------------------------*
Procedure SetContextMenu()
*--------------------------------------------------------*
Local lEnabled := ( Form_1.Grid_1.Value > 0 )

	IF Empty(cIniFile)
		SET CONTEXT MENU CONTROL Grid_1 OF Form_1 OFF
	ELSE
		SET CONTEXT MENU CONTROL Grid_1 OF Form_1 ON
		Form_1.EditVal.Enabled := lEnabled
		Form_1.DelKey.Enabled  := lEnabled
	ENDIF

Return

*--------------------------------------------------------*
Procedure Send2SP()
*--------------------------------------------------------*
Local i, aItem, cText := "", cSP := Form_1.Edit_1.Value

	IF Form_1.Tab_1.Value > 0

		cText := "[" + Form_1.Tab_1.Header( Form_1.Tab_1.Value ) + "]" + CRLF

		For i := 1 To Form_1.Grid_1.ItemCount
			aItem := Form_1.Grid_1.Item( i )
			IF !Empty( aItem[1] )
				cText += aItem[1] + CRLF
			ENDIF
		Next

		Form_1.Edit_1.Value := cSP + cText
		ShowFinalRow()
		DO EVENTS
		Form_1.Edit_1.CaretPos := Len(Form_1.Edit_1.Value)
		Form_1.Edit_1.Setfocus
	ENDIF

Return

#define WM_VSCROLL   0x0115
#define SB_VERT	1
#define SB_PAGEDOWN	3
*--------------------------------------------------------*
Procedure ShowFinalRow()
*--------------------------------------------------------*
Local i, h := GetControlHandle( "Edit_1" , "Form_1" )

	for i=1 to GetScrollRangeMax ( h , SB_VERT ) / 17
		SendMessage( h , WM_VSCROLL , SB_PAGEDOWN , 0 )
	next

Return

*--------------------------------------------------------*
Procedure AddSection()
*--------------------------------------------------------*

	DEFINE WINDOW Form_AddSec AT 0,0 ;
		WIDTH 330 HEIGHT 361 - IF(IsXPThemeActive(), 0, 6) ;
		TITLE "Add Section" ;
		ICON "MAIN" ;
		MODAL ;
		NOSIZE ;
		FONT "MS Sans Serif" SIZE 9

		@ 08, 08 LABEL Label_1 VALUE "Section Name:" ;
			AUTOSIZE

		DEFINE TEXTBOX Text_1
			ROW    6
			COL    90
			WIDTH  220
			HEIGHT 21
			VALUE ""
		END TEXTBOX

		@ 40, 08 LABEL Label_2 VALUE 'Keys and Values in Format: "Key=Value"' ;
			WIDTH 260 ;
			HEIGHT 14

		@ 60, 08 EDITBOX Edit_1 WIDTH 304 HEIGHT 236 VALUE ""

		DEFINE BUTTONEX Button_1
			ROW    Form_AddSec.Height - 54
			COL    40
			WIDTH  140
			HEIGHT 24
			CAPTION "Add to Current Ini File"
			PICTURE "OK"
			ACTION SaveNewSec( Form_AddSec.Text_1.Value, Form_AddSec.Edit_1.Value )
			TABSTOP .T.
			VISIBLE .T.
		END BUTTONEX

		DEFINE BUTTONEX Button_2
			ROW    Form_AddSec.Height - 54
			COL    206
			WIDTH  70
			HEIGHT 24
			CAPTION "Cancel"
			PICTURE "NO"
			ACTION Form_AddSec.Release
			TABSTOP .T.
			VISIBLE .T.
		END BUTTONEX

	END WINDOW

	Form_AddSec.Center
	Form_AddSec.Activate

Return

*--------------------------------------------------------*
Procedure SaveNewSec( cSectionName, cNewEntries )
*--------------------------------------------------------*
Local cEntryName, cItem, nItemCount, i, nAt

	IF !Empty(cSectionName)
		nItemCount := MLcount(cNewEntries)
		for i=1 to nItemCount
			cItem := MemoLine( cNewEntries, , i )
			if (nAt := At('=', cItem)) > 0
				cEntryName := Left( cItem, nAt - 1 )
				cItem := Right( cItem, Len(cItem) - nAt )
				BEGIN INI FILE cIniFile
					SET SECTION cSectionName ENTRY cEntryName TO cItem
				END INI
			endif
		next
		Form_1.Tab_1.AddPage( Len( _GetSectionNames( cIniFile ) ), cSectionName )
	ENDIF
	Form_AddSec.Release

Return

#xcommand DEL SECTION <cSection> TO <result>;
       => ;
          <result> := _DelIniSection( <cSection> )

*--------------------------------------------------------*
Procedure DelSection()
*--------------------------------------------------------*
Local nSec := Form_1.Tab_1.Value, cSectionName, lResult

	IF nSec > 0

		IF MsgYesNo( "Are you sure you want to delete the entire section?", PROGRAM, , , .f. )
			cSectionName := Form_1.Tab_1.Header( nSec )
			BEGIN INI FILE cIniFile
				DEL SECTION cSectionName TO lResult
			END INI
			IF lResult
				Form_1.Tab_1.DeletePage( nSec )
				Form_1.Tab_1.Value := IF(nSec > 1, nSec - 1, 1)
				OnTabChange()
			ENDIF
		ENDIF

	ENDIF

Return

*--------------------------------------------------------*
Procedure AddIniKey()
*--------------------------------------------------------*
Local cSectionName := Form_1.Tab_1.Header( Form_1.Tab_1.Value )

	DEFINE WINDOW Form_AddKey AT 0,0 ;
		WIDTH 377 HEIGHT 82 - IF(IsXPThemeActive(), 0, 6) ;
		TITLE "Add Key and Value to Section" ;
		ICON "MAIN" ;
		MODAL ;
		NOSIZE ;
		FONT "MS Sans Serif" SIZE 9

		@ 04, 2 LABEL Label_1 VALUE "New Key:" ;
			WIDTH 52 ;
			HEIGHT 14 RIGHTALIGN

		DEFINE TEXTBOX Text_1
			ROW    2
			COL    60
			WIDTH  222
			HEIGHT 20
			VALUE ""
		END TEXTBOX

		@ 30, 2 LABEL Label_2 VALUE "Key Value:" ;
			WIDTH 52 ;
			HEIGHT 14 RIGHTALIGN

		DEFINE TEXTBOX Text_2
			ROW    28
			COL    60
			WIDTH  222
			HEIGHT 20
			VALUE ""
		END TEXTBOX

		DEFINE BUTTONEX Button_1
			ROW    2
			COL    296
			WIDTH  68
			HEIGHT 22
			CAPTION "Save"
			PICTURE "OK"
			ACTION SaveNewKey( cSectionName, Form_AddKey.Text_1.Value, Form_AddKey.Text_2.Value )
			TABSTOP .T.
			VISIBLE .T.
		END BUTTONEX

		DEFINE BUTTONEX Button_2
			ROW    27
			COL    296
			WIDTH  68
			HEIGHT 22
			CAPTION "Cancel"
			PICTURE "NO"
			ACTION Form_AddKey.Release
			TABSTOP .T.
			VISIBLE .T.
		END BUTTONEX

	END WINDOW

	Form_AddKey.Center
	Form_AddKey.Activate

Return

*--------------------------------------------------------*
Procedure SaveNewKey( cSectionName, cNewEntry, cNewVal )
*--------------------------------------------------------*

	BEGIN INI FILE cIniFile
		SET SECTION cSectionName ENTRY cNewEntry TO cNewVal
	END INI
	Form_1.Grid_1.AddItem( { cNewEntry + "=" + cNewVal } )
	Form_1.Grid_1.Value := Form_1.Grid_1.ItemCount
	Form_AddKey.Release

Return

*--------------------------------------------------------*
Procedure DelIniKey()
*--------------------------------------------------------*
Local nKey := Form_1.Grid_1.Value, cSectionName, cEntryName, cItem

	IF nKey > 0

		IF MsgYesNo( "Are you sure you want to delete the Key and Value?", PROGRAM, , , .f. )
			cSectionName := Form_1.Tab_1.Header( Form_1.Tab_1.Value )
			cItem := Form_1.Grid_1.Item( nKey )[1]
			cEntryName := Left( cItem, At('=', cItem) - 1 )
			BEGIN INI FILE cIniFile
				DEL SECTION cSectionName ENTRY cEntryName
			END INI
			Form_1.Grid_1.DeleteItem( nKey )
			Form_1.Grid_1.Value := IF(nKey > 1, nKey - 1, 1)
		ENDIF

	ENDIF

Return

*--------------------------------------------------------*
Procedure EditIniVal()
*--------------------------------------------------------*
Local nKey := Form_1.Grid_1.Value, cSectionName, cEntryName, cItem, nAt

	IF nKey > 0
		cSectionName := Form_1.Tab_1.Header( Form_1.Tab_1.Value )
		cItem := Form_1.Grid_1.Item( nKey )[1]
		nAt := At( '=', cItem )
		cEntryName := Left( cItem, nAt - 1 )
		cItem := Right( cItem, Len(cItem) - nAt )

		DEFINE WINDOW Form_Edit AT 0,0 ;
			WIDTH 317 HEIGHT 82 - IF(IsXPThemeActive(), 0, 6) ;
			TITLE "Edit Value" ;
			ICON "MAIN" ;
			MODAL ;
			NOSIZE ;
			FONT "MS Sans Serif" SIZE 9

			@ 02, 09 LABEL Label_1 VALUE cEntryName ;
				WIDTH 220 ;
				HEIGHT 14

			DEFINE TEXTBOX Text_1
				ROW    18
				COL    7
				WIDTH  222
				HEIGHT 21
				VALUE cItem
				ONENTER SaveNewValue( cSectionName, cEntryName, Form_Edit.Text_1.Value )
			END TEXTBOX

			DEFINE BUTTONEX Button_1
				ROW    2
				COL    236
				WIDTH  68
				HEIGHT 22
				CAPTION "Save"
				PICTURE "OK"
				ACTION SaveNewValue( cSectionName, cEntryName, Form_Edit.Text_1.Value )
				TABSTOP .T.
				VISIBLE .T.
			END BUTTONEX

			DEFINE BUTTONEX Button_2
				ROW    27
				COL    236
				WIDTH  68
				HEIGHT 22
				CAPTION "Cancel"
				PICTURE "NO"
				ACTION Form_Edit.Release
				TABSTOP .T.
				VISIBLE .T.
			END BUTTONEX

		END WINDOW

		Form_Edit.Center
		Form_Edit.Activate
	ENDIF

Return

*--------------------------------------------------------*
Procedure SaveNewValue( cSectionName, cEntryName, cNewVal )
*--------------------------------------------------------*

	BEGIN INI FILE cIniFile
		SET SECTION cSectionName ENTRY cEntryName TO cNewVal
	END INI
	Form_1.Grid_1.Cell( Form_1.Grid_1.Value, 1 ) := cEntryName + "=" + cNewVal
	Form_Edit.Release

Return

#define ITEM_NAME	1
#define ITEM_VALUE	2
*--------------------------------------------------------*
Procedure OpenIni( cOpenFile )
*--------------------------------------------------------*
Local aTab := {}, aList := {}, i

	Default cOpenFile := ""

	IF Empty(cOpenFile)
		cOpenFile := Getfile( { {"Ini Files", "*.ini"} } )
	ENDIF

	IF !Empty(cOpenFile)
		IF !Empty(cIniFile)
			for i=1 to len( _GetSectionNames( cIniFile ) )
				Form_1.Tab_1.DeletePage( 1 )
			next
		ENDIF

		Form_1.Grid_1.DeleteAllItems
		Form_1.Label_1.Value := "Current File:"
		Form_1.Label_2.Value := "Section:"

		cIniFile := cOpenFile
		aTab := _GetSectionNames( cIniFile )

		IF Len(aTab) > 0
			for i=1 to len(aTab)
				Form_1.Tab_1.AddPage( i , aTab[i] )
			next

			aList := _GetSection( aTab[1], cIniFile )

			IF Len(aList) > 0
				Form_1.Grid_1.DisableUpdate
				for i=1 to len(aList)
					Form_1.Grid_1.AddItem( { aList[i][ITEM_NAME] + "=" + aList[i][ITEM_VALUE] } )
				next
				Form_1.Grid_1.EnableUpdate
			ENDIF
 
			Form_1.Label_1.Value := "Current File: " + cIniFile
			Form_1.Label_2.Value := "Section: [" + aTab[1] + "]"
			Form_1.Tab_1.Value   := 1

			Form_1.Label_1.Visible  := .T.
			Form_1.Btn_Sort.Visible := .T.
			Form_1.Btn_Jump.Visible := .T.
			Form_1.Edit_1.Setfocus
		ELSE
			cIniFile := ""
			ErrorMsg( "Failed to retrieve a Tab Section" )
		ENDIF

	ENDIF

Return

*--------------------------------------------------------*
Procedure OnTabChange()
*--------------------------------------------------------*
Local aList := {}, i
Local nSec := Form_1.Tab_1.Value, cSectionName

	IF nSec > 0

		cSectionName := Form_1.Tab_1.Header( nSec )

		aList := _GetSection( cSectionName, cIniFile )

		Form_1.Grid_1.DeleteAllItems
		IF Len(aList) > 0
			Form_1.Grid_1.DisableUpdate
			for i=1 to len(aList)
				Form_1.Grid_1.AddItem( { aList[i][ITEM_NAME] + "=" + aList[i][ITEM_VALUE] } )
			next
			Form_1.Grid_1.EnableUpdate
		ENDIF
 
		Form_1.Label_2.Value := "Section: [" + cSectionName + "]"

	ELSE

		Form_1.Grid_1.DeleteAllItems
		Form_1.Label_2.Value := "Section:"

	ENDIF

Return

*--------------------------------------------------------*
Procedure TabSort()
*--------------------------------------------------------*
Local cSectionName := Form_1.Tab_1.Header( Form_1.Tab_1.Value )
Local aTab := aSort( _GetSectionNames( cIniFile ), , , {|a,b| UPPER(a) < UPPER(b)} )

	aEval( aTab, { |e,i| Form_1.Tab_1.Header( i ) := e } )

	Form_1.Tab_1.Value := aScan( aTab, { |e,i| Form_1.Tab_1.Header( i ) == cSectionName } )

	Form_1.Edit_1.Setfocus

Return

*--------------------------------------------------------*
Procedure TabJump()
*--------------------------------------------------------*
Local cSectionName
Local aTab := aSort( _GetSectionNames( cIniFile ), , , {|a,b| UPPER(a) < UPPER(b)} )

	DEFINE WINDOW Form_Jump AT 0,0 ;
		WIDTH 239 HEIGHT 330 - IF(IsXPThemeActive(), 0, 6) ;
		TITLE "Tab Jumper" ;
		ICON "TABJUMP" ;
		MODAL ;
		NOSIZE ;
		FONT "MS Sans Serif" SIZE 9

		DEFINE LISTBOX List_1	
			ROW	3
			COL	2
			WIDTH Form_Jump.Width - 10
			HEIGHT Form_Jump.Height - GetTitleHeight() - GetBorderHeight() - 8
			ITEMS aTab
			VALUE 0
			FONTBOLD .T.
			ONDBLCLICK ( cSectionName := Form_Jump.List_1.Item( Form_Jump.List_1.Value ), ;
				Form_1.Tab_1.Value := aScan( aTab, { |e,i| Form_1.Tab_1.Header( i ) == cSectionName } ), ;
				OnTabChange(), Form_Jump.Release, Form_1.Edit_1.Setfocus )
		END LISTBOX

	END WINDOW

	Form_Jump.Center
	Form_Jump.Activate

Return

*--------------------------------------------------------*
Procedure Export2Ini()
*--------------------------------------------------------*
Local cText := "", cIni := ""

	cSaveIni := PutFile( { {"Ini Files", "*.ini"} }, , , .f., cSaveIni )

	IF !Empty(cSaveIni)

		IF File(cSaveIni)
			cIni := MemoRead( cSaveIni )
			IF Len(cIni) > 0
				cText += cIni
			ENDIF
		ENDIF

		cText += Form_1.Edit_1.Value

		IF !Empty(cText)

			IF MemoWrit( cSaveIni, cText, .f. )

				MsgBox( "Information is saved successfully", PROGRAM, .f. )

			ENDIF

		ENDIF

	ENDIF

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About " + PROGRAM, IDI_MAIN, .f. )

*--------------------------------------------------------*
Function EraseWindow( window, t, l, b, r )
*--------------------------------------------------------*
Local i := GetFormIndex( Window )
Local FormHandle := _HMG_aFormHandles[i]

	if formhandle > 0

		if _HMG_aFormDeleted [i] == .F.

			If ValType ( _HMG_aFormGraphTasks [i] ) == 'A'

				asize( _HMG_aFormGraphTasks[i], 0 )
				RedrawWindowControlRect( formhandle, t, l, b, r )

			endif

		endif

	endif

return nil

*--------------------------------------------------------*
function drawrect(window,row,col,row1,col1,penrgb,penwidth,fillrgb)
*--------------------------------------------------------*
Local i := GetFormIndex ( Window )
Local FormHandle := _HMG_aFormHandles [i] , fill

if formhandle > 0

   if valtype(penrgb) == "U"
      penrgb = {0,0,0}
   endif

   if valtype(penwidth) == "U"
      penwidth = 1
   endif

   if valtype(fillrgb) == "U"
      fillrgb := {255,255,255}
      fill := .f.
   else
      fill := .t.   
   endif

   rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill )

   aadd ( _HMG_aFormGraphTasks [i] , { || rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill ) } )

endif
return nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#if defined(__XHARBOUR__) 

#include "hbapifs.h"

HB_FUNC( MEMOWRIT )
{
   PHB_ITEM pFileName = hb_param( 1, HB_IT_STRING );
   PHB_ITEM pString = hb_param( 2, HB_IT_STRING );
   BOOL bWriteEof = TRUE; /* write Eof !, by default is .T. */
   BOOL bRetVal = FALSE;

   if( hb_parinfo(0) == 3 && ISLOG( 3 ) )
	bWriteEof = hb_parl( 3 );

   if( pFileName && pString )
   {
      FHANDLE fhnd = hb_fsCreate( ( BYTE * ) pFileName->item.asString.value, FC_NORMAL );

      if( fhnd != FS_ERROR )
      {
         ULONG ulSize = pString->item.asString.length;

         bRetVal = ( hb_fsWriteLarge( fhnd, ( BYTE * ) pString->item.asString.value, ulSize ) == ulSize );

         /* NOTE: CA-Clipper will add the EOF even if the write failed. [vszakats] */
         /* NOTE: CA-Clipper will not return .F. when the EOF could not be written. [vszakats] */
         #if ! defined(OS_UNIX_COMPATIBLE)
         {
            if( bWriteEof ) /* if true, then write EOF */
            {
               BYTE byEOF = HB_CHAR_EOF;

               hb_fsWrite( fhnd, &byEOF, sizeof( BYTE ) );
            }
         }
         #endif

         hb_fsClose( fhnd );
      }
   }

   hb_retl( bRetVal );
}

#endif

HB_FUNC( INITIMAGE )
{
	HWND  h;
	HBITMAP hBitmap;
	HWND hwnd;
	int Style;

	hwnd = (HWND) hb_parnl(1);

	Style = WS_CHILD | SS_BITMAP | SS_NOTIFY ;

	if ( ! hb_parl (8) )
	{
		Style = Style | WS_VISIBLE ;
	}

	h = CreateWindowEx( 0, "static", NULL, Style,
		hb_parni(3), hb_parni(4), 0, 0,
		hwnd, (HMENU) hb_parni(2), GetModuleHandle(NULL), NULL ) ;

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_CREATEDIBSECTION);
	}

	SendMessage( h, (UINT) STM_SETIMAGE, (WPARAM) IMAGE_BITMAP, (LPARAM) hBitmap );

	hb_retnl( (LONG) h );
}

HB_FUNC( C_SETPICTURE )
{
	HBITMAP hBitmap;

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_CREATEDIBSECTION);
	}

	SendMessage( (HWND) hb_parnl (1), (UINT) STM_SETIMAGE, (WPARAM) IMAGE_BITMAP, (LPARAM) hBitmap );

	hb_retnl( (LONG) hBitmap );
}

#pragma ENDDUMP
