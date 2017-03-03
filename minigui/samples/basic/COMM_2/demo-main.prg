/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Reception data from another program 
 *
 * Copyright 2015 Verchenko Andrey <verchenkoag@gmail.com>
 * And SergKis  http://clipper.borda.ru
 *
*/

#include "minigui.ch"

Static cAppTitle, cAppExe, cStaticMsg, nStaticI := 0
Static hStaticHandleWinDataClient, nStaticMainCol, nStaticMainRow

FUNCTION Main()
    LOCAL aBackColor := {231,178, 30}

    SET DATE FORMAT "DD.MM.YYYY"

    SET STATIONNAME TO "MAINPROC" 
    _HMG_Commpath := _GetShortPathName(GetCurrentFolder())+"\"

        cStaticMsg := "Start program - " + DTOC(DATE()) + " " + TIME() + CRLF + CRLF
        cAppTitle  := "Data Client"
        cAppExe    := "demo-client.exe"
        nStaticMainRow := 0  // to compare the movement of the main window
        nStaticMainCol := 0  // to compare the movement of the main window

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 500 HEIGHT 400 ;
		TITLE "SERVER" ;
		MAIN TOPMOST ;
                BACKCOLOR aBackColor ;
                ON INIT  ReadGetIt() ;
		ON RELEASE CloseIt()

		define timer t_1 interval 100 action TakeCustomerData()
		define timer t_2 interval 500 action MoveWinMain()

                @ 10, 10 LABEL Label_1 VALUE "Reception data from another program: " + cAppTitle ; 
                  WIDTH 480 HEIGHT 28 CENTERALIGN VCENTERALIGN ;
                  SIZE 11 BOLD FONTCOLOR BLACK TRANSPARENT 

                @ 30, 10 LABEL Label_Id VALUE "Path server ID - " + _HMG_Commpath ; 
                  WIDTH 480 HEIGHT 18 CENTERALIGN VCENTERALIGN ;
                  SIZE 9 BOLD FONTCOLOR RED TRANSPARENT 

                @ 50, 20 EDITBOX Edit_Result WIDTH 450 HEIGHT 230 ;
                  VALUE cStaticMsg  NOHSCROLL READONLY        

                @ 320, 20 LABEL Label_2 VALUE "Reception data:" ; 
                  WIDTH 120 HEIGHT 22 ;
                  SIZE 11 BOLD FONTCOLOR RED TRANSPARENT 

                @ 320, 140 GETBOX Text_1 WIDTH 5 HEIGHT 20 VALUE '' ;
                  BACKCOLOR { aBackColor, aBackColor, aBackColor }  ;
                  FONTCOLOR { aBackColor, aBackColor, aBackColor }  ;
                  INVISIBLE
                
                @ 320, 280  BUTTONEX Button_3  WIDTH 190 ;
                  CAPTION 'Exit' BACKCOLOR MAROON FONTCOLOR WHITE ;
                  SIZE 11 BOLD NOXPSTYLE HANDCURSOR ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_Main
	ACTIVATE WINDOW Form_Main

RETURN Nil

/////////////////////////////////////////////////////////////////////////
FUNCTION TakeCustomerData()  // Receiving data from a window cAppTitle
Local r, cStr

r := GETDATA()
if r != NIL

     cStr := "Received " + DTOC(DATE()) + "  " + TIME() + "  (" + HB_NtoS(nStaticI++) + ") - "
     cStaticMsg += cStr + VALTYPE(r) + ": " + hb_ValToExp(r) + CRLF
     Form_Main.Edit_Result.Value := cStaticMsg
     My_Message( VALTYPE(r) + ":" + hb_ValToExp( r ) )

endif

RETURN Nil

///////////////////////////////////////////////////////////////
// Moving the window relative to the window cAppTitle
FUNCTION MoveWinMain() 
     LOCAL FormName := _HMG_ThisFormName
     LOCAL aMainPos := {0,0,0,0}, aDCPos := {0,0,0,0}
     LOCAL nMainWidth := Form_Main.Width, nMainHeight := Form_Main.Height

     GetWindowRect( GetFormHandle( FormName ), aMainPos ) // the position of the window 

     IF hStaticHandleWinDataClient # 0

        GetWindowRect( hStaticHandleWinDataClient, aDCPos ) // window position cAppTitle

        IF aDCPos[1] == nStaticMainCol .AND. aDCPos[2] == nStaticMainRow
           // there was no movement of the window cAppTitle
        ELSE
           nStaticMainRow := aDCPos[2]
           nStaticMainCol := aDCPos[3] 
           // new coordinates of the window
           aMainPos[2] := nStaticMainRow
           aMainPos[1] := nStaticMainCol
           aMainPos[3] := nMainWidth
           aMainPos[4] := nMainHeight
           // move the window next to the window cAppTitle
           MoveWindow( GetFormHandle( FormName ) , aMainPos[1], aMainPos[2], aMainPos[3] , aMainPos[4] , .t. )
        ENDIF

     ENDIF

RETURN Nil

///////////////////////////////////////////////////////////////
// Close window cAppTitle
#define WM_CLOSE           0x0010

FUNCTION CloseIt()
     LOCAL hWnd

     hWnd := FindWindowEx( ,,, cAppTitle )

     IF hWnd # 0

	PostMessage ( hWnd, WM_CLOSE, 0, 0 )  

     ENDIF

RETURN Nil

/////////////////////////////////////////////////////////////////
FUNCTION ReadGetIt()
     LOCAL hWnd

     hWnd := FindWindowEx( ,,, cAppTitle )
     IF hWnd == 0
        _Execute ( 0, , cAppExe, , , 5 )
     ENDIF

     INKEYGUI(100)

     hWnd := FindWindowEx( ,,, cAppTitle )
     IF hWnd == 0

        cStaticMsg += "Can not found the window: " + cAppTitle + CRLF

        Form_Main.Edit_Result.Value := cStaticMsg 

     ELSE

        cStaticMsg += "The client is running, the window: " + cAppTitle + CRLF

        Form_Main.Edit_Result.Value := cStaticMsg

     ENDIF

     hStaticHandleWinDataClient := hWnd // handle monitored window cAppTitle

RETURN Nil

//////////////////////////////////////////////////////////////////////
FUNCTION My_Message(cVal)
LOCAL cNam := 'Text_1', cC := chr(10)
LOCAL hWnd := GetControlHandle(cNam, ThisWindow.Name)
LOCAL cTxt := "Data came from program: " + cAppTitle 
DEFAULT cVal := "NIL"
 
 cTxt :=  cC + cTxt + cC + "Value = " + cVal + " !" + cC 
 // "E" - error
 // "I" - information
 // "W" - warning
 // ------- Debugging file ---------------
 //MsgLog(procname()+str(procline(),5),cTxt,GetProperty(ThisWindow.Name, cNam, 'Visible'))

 SetProperty(ThisWindow.Name, cNam, 'Visible', .T.)
 DoMethod(ThisWindow.Name, cNam, 'SetFocus')
 InkeyGui(10)    // otherwise it does not have time to respond

 ShowGetValid( hWnd, cTxt, 'Information', 'I' )

 InkeyGui(3000)    // 3 sec.

 SetProperty(ThisWindow.Name, cNam, 'Visible', .F.)

 Form_Main.Edit_Result.Setfocus

Return Nil

//////////////////////////////////////////////////////////////////////
// SergKis  http://clipper.borda.ru
FUNCTION MsgLog( ... )
LOCAL i, j, hFile, cStr, cFile:="_MsgLog.txt"
LOCAL aParams := hb_aParams()
LOCAL nParams := PCount()

 IF nParams < 1 ; RETURN NIL
 ENDIF

 hFile := iif( File(cFile), FOpen(cFile,2) , FCreate(cFile) )

 FSeek( hFile, 0, 2)
 FWrite( hFile, CRLF, 2 )

 FOR i := 1 TO nParams
     cStr := hb_valtoexp(aParams[ i ])
     cStr := StrTran( cStr,"\n","" )
     cStr := StrTran( cStr,"\r","" )
     cStr := StrTran( cStr,"e" ,"" )
     FWrite( hFile, cStr )
 NEXT
 FWrite( hFile, CRLF, 2 )

 FClose( hFile )

RETURN NIL

//////////////////////////////////////////////////////////////////////
// SergKis  http://clipper.borda.ru

#pragma BEGINDUMP

// #define _WIN32_WINNT 0x0600

#include <windows.h>

#include "hbapi.h"
#include "hbapicdp.h"

#include <commctrl.h>
/*
typedef struct _tagEDITBALLOONTIP
{
    DWORD   cbStruct;
    LPCWSTR pszTitle;
    LPCWSTR pszText;
    INT     ttiIcon; // From TTI_*
} EDITBALLOONTIP, *PEDITBALLOONTIP;
*/
#define EM_SHOWBALLOONTIP   (ECM_FIRST + 3)     // Show a balloon tip associated to the edit control
#define Edit_ShowBalloonTip(hwnd, peditballoontip) \
        (BOOL)SNDMSG((hwnd), EM_SHOWBALLOONTIP, 0, (LPARAM)(peditballoontip))
#define EM_HIDEBALLOONTIP   (ECM_FIRST + 4)     // Hide any balloon tip associated with the edit control
#define Edit_HideBalloonTip(hwnd) \
        (BOOL)SNDMSG((hwnd), EM_HIDEBALLOONTIP, 0, 0)

// ToolTip Icons (Set with TTM_SETTITLE)
#define TTI_NONE                0
#define TTI_INFO                1
#define TTI_WARNING             2
#define TTI_ERROR               3
//#if (_WIN32_WINNT >= 0x0600)
#define TTI_INFO_LARGE          4
#define TTI_WARNING_LARGE       5
#define TTI_ERROR_LARGE         6
//#endif  // (_WIN32_WINNT >= 0x0600)

#define ECM_FIRST               0x1500      // Edit control messages

/*
   ShowGetValid( hWnd, cText [ , cTitul ]   [ , cTypeIcon ] )
*/

#if ( HB_VER_MAJOR == 3 )
   #define _hb_cdpGetU16( cdp, fCtrl, ch)  hb_cdpGetU16(cdp, ch )
   #define _hb_cdpGetChar(cdp, fCtrl, ch)  hb_cdpGetChar(cdp, ch)
#else
   #define _hb_cdpGetU16( cdp, fCtrl, ch)  hb_cdpGetU16(cdp, fCtrl, ch )
   #define _hb_cdpGetChar(cdp, fCtrl, ch)  hb_cdpGetChar(cdp, fCtrl, ch)
#endif

HB_FUNC( SHOWGETVALID )
{
  int i,k;
  char *tp, *s;
  WCHAR Text[512];  
  WCHAR Title[512];

  EDITBALLOONTIP   bl; 
  
  PHB_CODEPAGE  s_cdpHost = hb_vmCDP();

  HWND hWnd = ( HWND ) hb_parnl( 1 );

  if( ! IsWindow( hWnd ) ) return;


  bl.cbStruct = sizeof( EDITBALLOONTIP ); 
  bl.pszTitle = NULL;
  bl.pszText  = NULL;
  bl.ttiIcon  = TTI_NONE;

  if( HB_ISCHAR( 2 ) ){

      ZeroMemory( Text,  sizeof(Text) );               

      k = hb_parclen(2);
      s = (unsigned char *) hb_parc(2);
      for(i=0;i<k;i++) Text[i] = _hb_cdpGetU16( s_cdpHost, TRUE, s[i] );
      bl.pszText  = Text;
  } 

  if( HB_ISCHAR( 3 ) ){

      ZeroMemory( Title,  sizeof(Title) );               

      k = hb_parclen(3);
      s = (unsigned char *) hb_parc(3);
      for(i=0;i<k;i++) Title[i] = _hb_cdpGetU16( s_cdpHost, TRUE, s[i] );
      bl.pszTitle  = Title;
  } 


  tp  = ( char * ) hb_parc(4);    

  switch( *tp ){
      case 'E' :  bl.ttiIcon  = TTI_ERROR_LARGE;   break;
      case 'e' :  bl.ttiIcon  = TTI_ERROR;         break;

      case 'I' :  bl.ttiIcon  = TTI_INFO_LARGE;    break;
      case 'i' :  bl.ttiIcon  = TTI_INFO;          break;

      case 'W' :  bl.ttiIcon  = TTI_WARNING_LARGE; break;
      case 'w' :  bl.ttiIcon  = TTI_WARNING;       break;

  }


  Edit_ShowBalloonTip( hWnd, &bl );

}

#pragma ENDDUMP
