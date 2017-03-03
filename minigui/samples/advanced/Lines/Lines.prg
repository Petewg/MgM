*
* MINIGUI - HARBOUR - Win32
* 
* Copyright 2003-2008 Grigory Filatov <gfilatov@inbox.ru>
*
ANNOUNCE RDDSYS

#define __SCRSAVERDATA__
#include "minigui.ch"

#define PROGRAM "Lines Screen Saver"
#define VERSION " v.1.2"
#define COPYRIGHT " 2003-2008 Grigory Filatov"

#define PS_SOLID   0
#define PIXELMOVE  2
#define CLR_DEFAULT  RGB( 255, 255, 0 )

Static hPen 
Static aX, aY 
Static aPX, aPY
Static aMX, aMY
Static aIX, aIY

Static lInit := .T.

Memvar cIniFile
Memvar nWidth, nHeight
Memvar nType, nPolig, nColor
*--------------------------------------------------------*
Procedure Main( cParameters )
*--------------------------------------------------------*

	PUBLIC cIniFile := GetWindowsFolder()+"\control.ini"

	PRIVATE nWidth := GetDesktopWidth(), nHeight := GetDesktopHeight()
	PRIVATE nType := 1, nPolig := 5, nColor := CLR_DEFAULT

	BEGIN INI FILE cIniFile

		GET nType SECTION "Screen Saver.Lines" ENTRY "Type" DEFAULT nType
		GET nPolig SECTION "Screen Saver.Lines" ENTRY "Number" DEFAULT nPolig
		GET nColor SECTION "Screen Saver.Lines" ENTRY "Color" DEFAULT nColor

	END INI

	IF cParameters # NIL .AND. ( LOWER(cParameters) $ "-p/p" .OR. ;
		LOWER(cParameters) = "/a" .OR. LOWER(cParameters) = "-a" .OR. ;
		LOWER(cParameters) = "/c" .OR. LOWER(cParameters) = "-c" )

		DEFINE SCREENSAVER ;
			WINDOW Form_SSaver ;
			MAIN ;
			NOSHOW
	ELSE

		DEFINE SCREENSAVER ;
			WINDOW Form_SSaver ;
			MAIN ;
			ON RELEASE (DeleteObject( hPen ), .T.) ;
			ON PAINT DoLines(nType) ;
			INTERVAL .02 ;
			BACKCOLOR BLACK
	ENDIF

	INSTALL SCREENSAVER FILENAME Lines.scr

	CONFIGURE SCREENSAVER ConfigureSaver()

	ACTIVATE SCREENSAVER ;
		WINDOW Form_SSaver ;
		PARAMETERS cParameters

Return

*--------------------------------------------------------*
Procedure DoLines( nType )
*--------------------------------------------------------*
  local hDC, hOldPen
  local n, nI

  if lInit
     hPen := CreatePen( PS_SOLID, 1, nColor )
     aX := Array( nPolig ); aY := Array( nPolig ) 
     AFill( aX, 0 ) ; AFill( aY, 0 )
     aPX := AClone( aX ); aPY := AClone( aY )
     aMX := AClone( aX ); aMY := AClone( aY )
     aIX := Array( nPolig ); aIY := Array( nPolig )
     lInit := .F.
  endif

  for n := 1 to nPolig
      if Abs( aX[ n ] - aPX[ n ] ) < PIXELMOVE .or. Abs( aY[ n ] - aPY[ n ] ) < PIXELMOVE
         aPX[ n ] := Random( nWidth )
         aPY[ n ] := Random( nHeight )
         nI := Min( Abs( aX[ n ] - aPX[ n ] ), Abs( aY[ n ] - aPY[ n ] ) ) / PIXELMOVE
         aIX[ n ] := ( aPX[ n ] - aX[ n ] ) / nI
         aIY[ n ] := ( aPY[ n ] - aY[ n ] ) / nI
      endif
      aX[ n ] += aIX[ n ]
      aX[ n ] := MinMax( aX[ n ], nWidth )
      aY[ n ] += aIY[ n ]
      aY[ n ] := MinMax( aY[ n ], nHeight )
  next

  hDC := GetDC( _HMG_MainHandle )
  hOldPen := SelectObject( hDC, hPen )

  IF nType = 1

      MoveTo( hDC, aMX[ nPolig ], aMY[ nPolig ] )  
      for n := 1 to nPolig
          LineTo( hDC, aMX[ n ], aMY[ n ] )
          aMX[ n ] := aX[ n ]
          aMY[ n ] := aY[ n ]
      next

      RedrawWindow( _HMG_MainHandle )

      MoveTo( hDC, aX[ nPolig ], aY[ nPolig ] )  
      for n := 1 to nPolig
          LineTo( hDC, aX[ n ], aY[ n ] )
      next

  ELSE

      MoveTo( hDC, aMX[ nPolig - 1 ], aMY[ nPolig - 1] )
      for n := 1 to nPolig - 1
          LineTo( hDC, aMX[ n ], aMY[ n ] )
      next
      for n := 1 to nPolig 
          MoveTo( hDC, aMX[ nPolig ], aMY[ nPolig ] )
          LineTo( hDC, aMX[ n ], aMY[ n ] )
          aMX[ n ] := aX[ n ]
          aMY[ n ] := aY[ n ]
      next

      RedrawWindow( _HMG_MainHandle )

      MoveTo( hDC, aX[ nPolig - 1 ], aY[ nPolig - 1 ] )  
      for n := 1 to nPolig - 1
          LineTo( hDC, aX[ n ], aY[ n ] )
      next
      for n := 1 to nPolig 
          MoveTo( hDC, aX[ nPolig ], aY[ nPolig ] )  
          LineTo( hDC, aX[ n ], aY[ n ] )
      next

  ENDIF

  SelectObject( hDC, hOldPen )
  ReleaseDC( _HMG_MainHandle, hDC )

Return

*--------------------------------------------------------*
Procedure ConfigureSaver()
*--------------------------------------------------------*
	LOCAL aColor, aCustColor := { RGB(255,255,0), RGB(0,255,0), RGB(0,255,255), ;
		RGB(0,128,255), RGB(255,128,255), RGB(240,240,240), RGB(192,192,192), RGB(255,128,0), ;
		RGB(225,225,0), RGB(0,225,0), RGB(0,225,225), ;
		RGB(0,128,225), RGB(225,128,225), RGB(140,140,140), RGB(216,216,216), RGB(225,128,0) }

	DEFINE WINDOW Form_Config ; 
        AT 0,0 ; 
        WIDTH 222 ; 
        HEIGHT 152 ; 
        TITLE 'Lines Settings' ; 
        ICON 'ICON_1' ;
        CHILD ;
        NOMINIMIZE NOMAXIMIZE NOSIZE ;
        ON INIT ShowCursor(.T.) ;
        ON PAINT DoMethod( "Form_Config", "Radio_1", "SetFocus" ) ;
        FONT 'MS Sans Serif' ; 
        SIZE 9

        @ 8, 8 FRAME Frame_1 ; 
            CAPTION 'Type' ; 
            WIDTH 66 ; 
            HEIGHT 72

        @ 24,20 RADIOGROUP Radio_1 ; 
            OPTIONS { "&One", "&Two" } ; 
            WIDTH 40 ; 
            VALUE nType ;
            ON CHANGE nType := Form_Config.Radio_1.Value

        @ 18, 86 LABEL Label_1 ; 
            VALUE 'Number of lines:' ; 
            WIDTH 80 ; 
            HEIGHT 23 ; 

        @ 14, 168 SPINNER Spinner_1 ; 
            RANGE 3, 30 ; 
            HEIGHT 23 ; 
            WIDTH 40 ; 
            VALUE nPolig ;
            ON CHANGE nPolig := Form_Config.Spinner_1.Value ;
            FONT 'MS Sans Serif' ; 
            SIZE 10

        @ 50,85 BUTTON Button_Clr ; 
            CAPTION 'Select the &Color of lines' ; 
            ACTION (aColor := GetColor(nColor, aCustColor), ; 
		if(aColor[1]==NIL, , nColor := RGB(aColor[1], aColor[2], aColor[3]))) ;
            WIDTH 122 ; 
            HEIGHT 28 ; 
            FLAT

        DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 66, 24 FLAT BOTTOM RIGHTTEXT

		BUTTON Button_1  ;
			CAPTION 'A&bout' ;
			PICTURE 'About' ;
			ACTION MsgAbout() SEPARATOR

		BUTTON Button_2 ;
			CAPTION '&Save' ;
			PICTURE 'Save' ;
			ACTION ( SaveConfig(), Form_Config.Release, Form_SSaver.Release )

		BUTTON Button_3 ;
			CAPTION 'C&ancel' ;
			PICTURE 'Cancel' ;
			ACTION ( Form_Config.Release, Form_SSaver.Release )

        END TOOLBAR

	END WINDOW

	CENTER WINDOW Form_Config

	ACTIVATE WINDOW Form_Config, Form_SSaver

Return

*--------------------------------------------------------*
Static Procedure SaveConfig()
*--------------------------------------------------------*

  BEGIN INI FILE cIniFile

	SET SECTION "Screen Saver.Lines" ENTRY "Type" TO nType
	SET SECTION "Screen Saver.Lines" ENTRY "Number" TO nPolig
	SET SECTION "Screen Saver.Lines" ENTRY "Color" TO nColor

  END INI

Return

*--------------------------------------------------------*
Static Function MinMax( nvalue, nRegion )
*--------------------------------------------------------*
Return Min( nRegion, Max( nvalue, 0 ) )

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	"eMail: gfilatov@inbox.ru" + CRLF + CRLF + ;
	"This Screen Saver is Freeware!" + CRLF + ;
	padc("Copying is allowed!", 36), "About", , .F. )
 
*-----------------------------------------------------------------------------*
Static Function GetColor(nInitColor, aCustomColors)
*-----------------------------------------------------------------------------*
Local aRetVal [3] , nColor 

	nColor := ChooseColor( NIL, nInitColor, aCustomColors )

	If nColor == -1
		aRetVal [1] := Nil
		aRetVal [2] := Nil
		aRetVal [3] := Nil
	Else
		aRetVal [1] := GetRed (nColor)
		aRetVal [2] := GetGreen (nColor)
		aRetVal [3] := GetBlue (nColor)
	EndIf

Return aRetVal


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( MOVETO )
{

   hb_retl( MoveToEx(
                    (HDC) hb_parnl(1),   // device context handle
                    hb_parni(2)      ,   // x-coordinate of line's ending point
                    hb_parni(3)      ,   // y-coordinate of line's ending point
                    NULL
                 ) );
}

HB_FUNC( LINETO )
{

   hb_retl( LineTo( (HDC) hb_parnl( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) ) ;

}

HB_FUNC ( CREATEPEN )
{

   hb_retnl( (LONG) CreatePen(
               hb_parni( 1 ),	// pen style 
               hb_parni( 2 ),	// pen width  
               (COLORREF) hb_parnl( 3 ) 	// pen color 
             ) );
}

#pragma ENDDUMP
