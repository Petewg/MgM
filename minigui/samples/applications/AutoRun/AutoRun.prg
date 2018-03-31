/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include <minigui.ch>
#include "i_qhtm.ch"

#define CLR_BLUE { 0, 0, 136 }
#define IDI_MAIN 1001

Static aIni

PROCEDURE Main

LOCAL cCfgFile := GetStartUpFolder() + "\" + cFileNoExt( GetExeFileName() ) + ".ini"
LOCAL aEntry := {}, aView := {}, nBorderWidth, nBorderHeight, cPicture, i
LOCAL nCol_Play1 := 36, nCol_Play2 := 172, nCol_Driver := 309
LOCAL aClr_Pen, aClr_Fore, aClr_Back, aBtn_Fore, aBtn_Back

aAdd( aEntry, "FilmName" )
aAdd( aEntry, "Info_File" )
aAdd( aEntry, "Info_Type" )
aAdd( aEntry, "Picture" )
aAdd( aEntry, "FilmName_File" )
aAdd( aEntry, "Command_Line" )
aAdd( aEntry, "Images_Dir" )
aAdd( aEntry, "PathXviD" )
aAdd( aEntry, "Info_Aligment" )
aAdd( aEntry, "Exit_Button_Click" )

aAdd( aView, "Button_Exit_Text" )
aAdd( aView, "Button_Exit_Hint" )
aAdd( aView, "Button_Play1_Text" )
aAdd( aView, "Button_Play1_Hint" )
aAdd( aView, "Button_Play1_Visible" )
aAdd( aView, "Button_Play2_Text" )
aAdd( aView, "Button_Play2_Hint" )
aAdd( aView, "Button_Play2_Visible" )
aAdd( aView, "Button_Driver_Text" )
aAdd( aView, "Button_Driver_Hint" )
aAdd( aView, "Button_Driver_Visible" )
aAdd( aView, "Form_Height" )
aAdd( aView, "Form_Width" )
aAdd( aView, "Border_Color" )
aAdd( aView, "Background_Color" )
aAdd( aView, "Font_Color" )
aAdd( aView, "Buttons_Color" )
aAdd( aView, "Buttons_Font_Color" )

	aIni := Array(28)

	DEFAULT aIni[1] TO "Film"
	DEFAULT aIni[2] TO ""
	DEFAULT aIni[3] TO ""
	DEFAULT aIni[4] TO ""
	DEFAULT aIni[5] TO ""
	DEFAULT aIni[6] TO ""
	DEFAULT aIni[7] TO ""
	DEFAULT aIni[8] TO ""
	aIni[9] := 0
	aIni[10] := 0
	DEFAULT aIni[11] TO "Exit"
	DEFAULT aIni[12] TO ""
	DEFAULT aIni[13] TO "Play by LA"
	DEFAULT aIni[14] TO ""
	aIni[15] := 1
	DEFAULT aIni[16] TO "Play"
	DEFAULT aIni[17] TO ""
	aIni[18] := 1
	DEFAULT aIni[19] TO "Setup"
	DEFAULT aIni[20] TO ""
	aIni[21] := 1
	aIni[22] := 0
	aIni[23] := 0
	aIni[24] := 65535
	aIni[25] := 8388672
	aIni[26] := 65535
	aIni[27] := 10494032
	aIni[28] := 65535

	IF FILE(cCfgFile)

		BEGIN INI FILE cCfgFile

			For i := 1 To Len(aEntry)
				GET aIni[i] SECTION "Data" ENTRY aEntry[i]
			Next i
			For i := 1 To Len(aView)
				GET aIni[i+10] SECTION "View" ENTRY aView[i]
			Next i

		END INI

	ENDIF

	nBorderWidth  := GetBorderWidth()
	nBorderHeight := GetBorderHeight()

	cPicture := IF(FILE(aIni[4]), aIni[4], "LOGO")

	IF !EMPTY(aIni[15]) .AND. EMPTY(aIni[18]) .AND. !EMPTY(aIni[21])
		nCol_Play1 := 172
	ELSEIF !EMPTY(aIni[15]) .AND. EMPTY(aIni[18]) .AND. EMPTY(aIni[21])
		nCol_Play1 := 309
	ELSEIF EMPTY(aIni[15]) .AND. !EMPTY(aIni[18]) .AND. EMPTY(aIni[21])
		nCol_Play2 := 309
	ELSEIF !EMPTY(aIni[15]) .AND. !EMPTY(aIni[18]) .AND. EMPTY(aIni[21])
		nCol_Play1 := 172
		nCol_Play2 := 309
	ENDIF

	aClr_Pen  := { GetRed( aIni[24] ), GetGreen( aIni[24] ), GetBlue( aIni[24] ) }
	aClr_Back := { GetRed( aIni[25] ), GetGreen( aIni[25] ), GetBlue( aIni[25] ) }
	aClr_Fore := { GetRed( aIni[26] ), GetGreen( aIni[26] ), GetBlue( aIni[26] ) }
	aBtn_Back := { GetRed( aIni[27] ), GetGreen( aIni[27] ), GetBlue( aIni[27] ) }
	aBtn_Fore := { GetRed( aIni[28] ), GetGreen( aIni[28] ), GetBlue( aIni[28] ) }

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH Max(586, aIni[23]) HEIGHT Max(423, aIni[22]) ;
		TITLE aIni[1] ;
		ICON IDI_MAIN ;
		MAIN ;
		NOSIZE NOMAXIMIZE NOMINIMIZE NOSYSMENU NOCAPTION ;
		ON INIT SetHandCursor(GetControlHandle("Label_3", "Form_1")) ;
		BACKCOLOR aClr_Back ;
		FONT "Tahoma" SIZE 9

		DRAW LINE IN WINDOW Form_1 AT 0, 0 TO 0,Form_1.Width ;
			PENCOLOR aClr_Pen ;
			PENWIDTH nBorderWidth

		DRAW LINE IN WINDOW Form_1 AT Form_1.Height, 0 TO Form_1.Height,Form_1.Width ;
			PENCOLOR aClr_Pen ;
			PENWIDTH nBorderWidth

		DRAW LINE IN WINDOW Form_1 AT 0, 0 TO Form_1.Height,0 ;
			PENCOLOR aClr_Pen ;
			PENWIDTH nBorderWidth

		DRAW LINE IN WINDOW Form_1 AT 0, Form_1.Width TO Form_1.Height,Form_1.Width ;
			PENCOLOR aClr_Pen ;
			PENWIDTH nBorderWidth

		@ 8,nBorderWidth LABEL Label_1 OF Form_1 VALUE aIni[1] WIDTH Form_1.Width - nBorderWidth * 2 HEIGHT 28 CENTERALIGN ;
			BACKCOLOR aClr_Back ;
			FONTCOLOR aClr_Fore ;
			ACTION MoveActiveWindow() ;
			FONT "Tahoma" SIZE 13

                @ 36 + aIni[9]/10,nBorderWidth - 1 IMAGE Image_1 OF Form_1 ;
                        PICTURE cPicture ;
                        WIDTH 318 - aIni[9] ;
                        HEIGHT 324 - aIni[9]/5 ;
			ACTION m_about() ;
			STRETCH

	IF UPPER(aIni[3]) == "HTML"

		@ 36,nBorderWidth + 320 - aIni[9] QHTM Html_1 OF Form_1 ;
			VALUE MemoRead( aIni[2] ) ;
			WIDTH Form_1.Width - nBorderWidth * 2 - 318 + aIni[9];
			HEIGHT 324

	ELSE

		@ 36,nBorderWidth + 320 - aIni[9] LABEL Label_2 OF Form_1 ;
			VALUE MemoRead( aIni[2] ) ;
			WIDTH Form_1.Width - nBorderWidth * 2 - 318 + aIni[9];
			HEIGHT 324 ;
			BACKCOLOR CLR_BLUE ;
			FONTCOLOR aClr_Fore ;
			FONT "Tahoma" SIZE 8
	ENDIF

		@ 362,nBorderWidth + 320 LABEL Label_3 OF Form_1 ;
			VALUE "Copyright " + CHR(169) + " 2006 Grigory Filatov" WIDTH 250 HEIGHT 16 RIGHTALIGN ;
			BACKCOLOR aClr_Back ;
			FONTCOLOR aClr_Fore ;
			ACTION ShellExecute(0, "open", "rundll32.exe", "url.dll,FileProtocolHandler " + ;
			"mailto:gfilatov@inbox.ru?cc=&bcc=&subject=Harbour%20AutoRun%20Feedback:", , 1) ;
			BOLD TOOLTIP "E-mail me if you have any comments or suggestions"

	IF !EMPTY(aIni[15])

		@ 386,nBorderWidth + nCol_Play1  BUTTONEX Button_1 OF Form_1 CAPTION aIni[13] ;
			ACTION m_playLA( aIni[6] ) WIDTH 128 HEIGHT 23 TOOLTIP lTrim(aIni[14]) ;
			BACKCOLOR aBtn_Back ;
			FONTCOLOR aBtn_Fore NOXPSTYLE DEFAULT
	ENDIF

	IF !EMPTY(aIni[18])

		@ 386,nBorderWidth + nCol_Play2 BUTTONEX Button_2 OF Form_1 CAPTION aIni[16] ;
			ACTION m_play( aIni[5] ) WIDTH 128 HEIGHT 23 TOOLTIP lTrim(aIni[17]) ;
			BACKCOLOR aBtn_Back ;
			FONTCOLOR aBtn_Fore NOXPSTYLE
	ENDIF

	IF !EMPTY(aIni[21])

		@ 386,nBorderWidth + nCol_Driver BUTTONEX Button_3 OF Form_1 CAPTION aIni[19] ;
			ACTION m_play( aIni[8] ) WIDTH 128 HEIGHT 23 TOOLTIP lTrim(aIni[20]) ;
			BACKCOLOR aBtn_Back ;
			FONTCOLOR aBtn_Fore NOXPSTYLE
	ENDIF

		@ 386,nBorderWidth + 445 BUTTONEX Button_4 OF Form_1 CAPTION aIni[11] ;
			ACTION Form_1.Release WIDTH 128 HEIGHT 23 TOOLTIP lTrim(aIni[12] + " (Esc)") ;
			BACKCOLOR aBtn_Back ;
			FONTCOLOR aBtn_Fore NOXPSTYLE

		ON KEY ESCAPE ACTION ReleaseAllWindows()

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

RETURN


STATIC PROCEDURE m_playLA( cRun )
Local cParameter

	IF !EMPTY(cRun)

		cParameter := Chr(34) + Trim( Token( cRun, " ", 2 ) + " " + Token( cRun, " ", 3 ) + " " + Token( cRun, " ", 4 ) ) + Chr(34)
		_Execute ( 0, , Token( cRun, " " ), cParameter, , 5 )

	ENDIF

	IF !EMPTY(aIni[10])
		Form_1.Release
	ENDIF

RETURN


STATIC PROCEDURE m_play( cRun )

	_Execute ( 0, , cRun , , , 5 )

	IF !EMPTY(aIni[10])
		Form_1.Release
	ENDIF

RETURN


STATIC FUNCTION m_about()
RETURN MsgInfo("Harbour AutoRun version 1.01 - Freeware" + CRLF + ;
	"Copyright (c) 2006 Grigory Filatov" + CRLF + CRLF + ;
	padc("Email: gfilatov@inbox.ru", 38) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	substr(MiniGuiVersion(), 1, 38), "About", IDI_MAIN, .f.)


#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

Static Procedure MoveActiveWindow(hWnd)
	default hWnd := GetActiveWindow()

	PostMessage(hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0)
	CursorArrow()

Return

Static Function Token( cStr, cDelim, nToken )
   LOCAL nPos, cToken := "", nCounter := 1

   DEFAULT nToken := 1

   WHILE .T.

      IF ( nPos := At( cDelim, cStr ) ) == 0

         IF nCounter == nToken
            cToken := cStr
         ENDIF

         EXIT

      ENDIF

      IF ++ nCounter > nToken
         cToken := LEFT( cStr, nPos - 1 )
         EXIT
      ENDIF

      cStr := Substr( cStr, nPos + 1 )

   ENDDO

RETURN cToken


Static Function drawline(window,row,col,row1,col1,penrgb,penwidth)
Local i := GetFormIndex ( Window )
Local FormHandle := _HMG_aFormHandles [i]

	if formhandle > 0

		if valtype(penrgb) == "U"
			penrgb = {0,0,0}
		endif
	
		if valtype(penwidth) == "U"
			penwidth = 1
		endif

		linedraw( formhandle,row,col,row1,col1,penrgb,penwidth)

		aadd ( _HMG_aFormGraphTasks [i] , { || linedraw( formhandle,row,col,row1,col1,penrgb,penwidth) } )

	endif

return nil


#pragma BEGINDUMP

/*
 * QHTM wrappers for Harbour
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://www.geocities.com/alkresin/
*/

#define HB_OS_WIN_USED

#define _WIN32_WINNT 0x0400
#include <windows.h>

#ifdef __EXPORT__
   #define HB_NO_DEFAULT_API_MACROS
   #define HB_NO_DEFAULT_STACK_MACROS
#endif

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbvm.h"
#include "qhtm.h"

extern  BOOL WINAPI QHTM_Initialize( HINSTANCE hInst );
extern  int WINAPI QHTM_MessageBox(HWND hwnd, LPCTSTR lpText, LPCTSTR lpCaption, UINT uType );

typedef BOOL (WINAPI *QHTM_INITIALIZE)( HINSTANCE hInst );
typedef int (WINAPI *QHTM_MESSAGEBOX)(HWND hwnd, LPCTSTR lpText, LPCTSTR lpCaption, UINT uType );
typedef QHTMCONTEXT (WINAPI *QHTM_PRINTCREATECONTEXT)( UINT uZoomLevel );
typedef BOOL (WINAPI *QHTM_ENABLECOOLTIPS)( void );
typedef BOOL (WINAPI *QHTM_SETHTMLBUTTON)( HWND hwndButton );
typedef BOOL (WINAPI *QHTM_PRINTSETTEXT)( QHTMCONTEXT ctx, LPCTSTR pcszText );
typedef BOOL (WINAPI *QHTM_PRINTSETTEXTFILE)( QHTMCONTEXT ctx, LPCTSTR pcszText );
typedef BOOL (WINAPI *QHTM_PRINTSETTEXTRESOURCE)( QHTMCONTEXT ctx, HINSTANCE hInst, LPCTSTR pcszName );
typedef BOOL (WINAPI *QHTM_PRINTLAYOUT)( QHTMCONTEXT ctx, HDC dc, LPCRECT pRect, LPINT nPages );
typedef BOOL (WINAPI *QHTM_PRINTPAGE)( QHTMCONTEXT ctx, HDC hDC, UINT nPage, LPCRECT prDest );
typedef void (WINAPI *QHTM_PRINTDESTROYCONTEXT)( QHTMCONTEXT );

static HINSTANCE  hQhtmDll = NULL;

BOOL qhtmInit( char* cLibname )
{
   if( !hQhtmDll )
   {
      if( !cLibname )
         cLibname = "qhtm.dll";
      hQhtmDll = LoadLibrary( (LPCTSTR)cLibname );
      if( hQhtmDll )
      {
         QHTM_INITIALIZE pFunc = (QHTM_INITIALIZE) GetProcAddress( hQhtmDll,"QHTM_Initialize" );
         if( pFunc )
            return ( pFunc( GetModuleHandle( NULL ) ) )? 1:0;
      }
      else
      {
         MessageBox( GetActiveWindow(), "Library not loaded", cLibname, MB_OK | MB_ICONSTOP );
         return 0;
      }
   }
   return 1;
}

HB_FUNC( QHTM_INIT )
{
   char* cLibname = ( hb_pcount() < 1 )? NULL:(char*)hb_parc( 1 );
   hb_retl( qhtmInit( cLibname ) );
}

HB_FUNC( QHTM_END )
{
   if( hQhtmDll )
   {
      FreeLibrary( hQhtmDll );
      hQhtmDll = NULL;
   }
}

/*
   CreateQHTM( hParentWindow, nID, nStyle, x1, y1, nWidth, nHeight )
*/
HB_FUNC( CREATEQHTM )
{
   if( qhtmInit(NULL) )
   {
      HWND handle = CreateWindow( 
                       "QHTM_Window_Class_001",     /* predefined class  */
                       NULL,                        /* no window title   */
                       WS_CHILD | WS_VISIBLE | hb_parnl(3),    /* style  */
                       hb_parni(4), hb_parni(5),    /* x, y       */
                       hb_parni(6), hb_parni(7),    /* nWidth, nHeight */
                       (HWND) hb_parnl(1),           /* parent window    */ 
                       (HMENU) hb_parni(2),          /* control ID  */ 
                       GetModuleHandle( NULL ), 
                       NULL);

      hb_retnl( (LONG) handle );
   }
   else
      hb_retnl( 0 );
}

HB_FUNC( QHTM_GETNOTIFY )
{
   LPNMQHTM pnm = (LPNMQHTM) hb_parnl(1);

   hb_retc( (char*)pnm->pcszLinkText );
}

HB_FUNC( QHTM_SETRETURNVALUE )
{
   LPNMQHTM pnm = (LPNMQHTM) hb_parnl(1);
   pnm->resReturnValue = hb_parl(2);
}

void CALLBACK FormCallback( HWND hWndQHTM, LPQHTMFORMSubmit pFormSubmit, LPARAM lParam )
{
   PHB_DYNS pSymTest;
   PHB_ITEM aMetr = hb_itemArrayNew( pFormSubmit->uFieldCount );
   PHB_ITEM atemp, temp;
   int i;

   for( i=0;i<(int)pFormSubmit->uFieldCount;i++ )
   {
      atemp = hb_itemArrayNew( 2 );
      temp = hb_itemPutC( NULL, (char*)((pFormSubmit->parrFields+i)->pcszName) );
      hb_itemArrayPut( atemp, 1, temp );
      hb_itemRelease( temp );
      temp = hb_itemPutC( NULL, (char*)((pFormSubmit->parrFields+i)->pcszValue) );
      hb_itemArrayPut( atemp, 2, temp );
      hb_itemRelease( temp );

      hb_itemArrayPut( aMetr, i+1, atemp );
      hb_itemRelease( atemp );
   }

   HB_SYMBOL_UNUSED( lParam );

   if( ( pSymTest = hb_dynsymFind( "QHTMFORMPROC" ) ) != NULL )
   {
      hb_vmPushSymbol( pSymTest );
      hb_vmPushNil();
      hb_vmPushLong( (LONG ) hWndQHTM );
      hb_vmPushString( (char*) pFormSubmit->pcszMethod,strlen(pFormSubmit->pcszMethod) );
      hb_vmPushString( (char*) pFormSubmit->pcszAction,strlen(pFormSubmit->pcszAction) );
      if( pFormSubmit->pcszName )
         hb_vmPushString( (char*) pFormSubmit->pcszName,strlen(pFormSubmit->pcszName) );
      else
         hb_vmPushNil();
      hb_vmPush( aMetr );
      hb_vmDo( 5 );
   }
   hb_itemRelease( aMetr );
}

// Wrappers to QHTM Functions

HB_FUNC( QHTM_MESSAGE )
{
   if( qhtmInit(NULL) )
   {
      const char* cTitle = ( hb_pcount() < 2 )? "":hb_parc( 2 );
      UINT uType = ( hb_pcount() < 3 )? MB_OK:(UINT)hb_parni( 3 );
      QHTM_MESSAGEBOX pFunc = (QHTM_MESSAGEBOX) GetProcAddress( hQhtmDll,"QHTM_MessageBox" );

      if( pFunc )
         pFunc( GetActiveWindow(), hb_parc(1), cTitle, uType );
   }
}

HB_FUNC( QHTM_LOADFILE )
{
   if( qhtmInit(NULL) )
   {
      hb_retl( SendMessage( (HWND) hb_parnl(1), QHTM_LOAD_FROM_FILE, 0, (LPARAM)hb_parc(2) ) );
   }
}

HB_FUNC( QHTM_LOADRES )
{
   if( qhtmInit(NULL) )
   {
      hb_retl( SendMessage( (HWND) hb_parnl(1), QHTM_LOAD_FROM_RESOURCE,
                  (WPARAM)GetModuleHandle( NULL ), (LPARAM)hb_parc(2) ) );
   }
}

HB_FUNC( QHTM_ADDHTML )
{
   if( qhtmInit(NULL) )
   {
      SendMessage( (HWND) hb_parnl(1), QHTM_ADD_HTML, 0, (LPARAM)hb_parc(2) );
   }
}

HB_FUNC( QHTM_GETTITLE )
{
   if( qhtmInit(NULL) )
   {
      char szBuffer[ 256 ];
      SendMessage( (HWND) hb_parnl(1), QHTM_GET_HTML_TITLE, 256, (LPARAM)szBuffer );
      hb_retc( szBuffer );
   }
}

HB_FUNC( QHTM_GETSIZE )
{
   if( qhtmInit(NULL) )
   {
      SIZE size;

      if( SendMessage( (HWND) hb_parnl(1), QHTM_GET_DRAWN_SIZE, 0, (LPARAM)&size ) )
      {
          PHB_ITEM aMetr = hb_itemArrayNew( 2 );
          PHB_ITEM temp;

          temp = hb_itemPutNL( NULL, size.cx );
          hb_itemArrayPut( aMetr, 1, temp );
          hb_itemRelease( temp );

          temp = hb_itemPutNL( NULL, size.cy );
          hb_itemArrayPut( aMetr, 2, temp );
          hb_itemRelease( temp );

          hb_itemReturn( aMetr );
          hb_itemRelease( aMetr );
      }
      else
         hb_ret();
   }
}

HB_FUNC( QHTM_FORMCALLBACK )
{
   if( qhtmInit(NULL) )
   {
      hb_retl( SendMessage( (HWND) hb_parnl(1), QHTM_SET_OPTION, (WPARAM)QHTM_OPT_SET_FORM_SUBMIT_CALLBACK, (LPARAM)FormCallback ) );
   }
   else
      hb_retl(0);
}

#pragma ENDDUMP

#include "h_qhtm.prg"

