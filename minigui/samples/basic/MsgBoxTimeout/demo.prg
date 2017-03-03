/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

// by Dr. Claudio Soto (October 2013)

#define MB_USERICON 128
#define MB_ICONASTERISK 64
#define MB_ICONEXCLAMATION 0x30
#define MB_ICONWARNING 0x30
#define MB_ICONERROR 16
#define MB_ICONHAND 16
#define MB_ICONQUESTION 32
#define MB_OK 0
#define MB_ABORTRETRYIGNORE 2
#define MB_APPLMODAL 0
#define MB_DEFAULT_DESKTOP_ONLY 0x20000
#define MB_HELP 0x4000
#define MB_RIGHT 0x80000
#define MB_RTLREADING 0x100000
#define MB_DEFBUTTON1 0
#define MB_DEFBUTTON2 256
#define MB_DEFBUTTON3 512
#define MB_DEFBUTTON4 0x300
#define MB_ICONINFORMATION 64
#define MB_ICONSTOP 16
#define MB_OKCANCEL 1
#define MB_RETRYCANCEL 5

#define MB_SETFOREGROUND 0x10000
#define MB_SYSTEMMODAL 4096
#define MB_TASKMODAL 0x2000
#define MB_YESNO 4
#define MB_YESNOCANCEL 3
#define MB_ICONMASK 240
#define MB_DEFMASK 3840
#define MB_MODEMASK 0x00003000
#define MB_MISCMASK 0x0000C000
#define MB_NOFOCUS 0x00008000
#define MB_TYPEMASK 15
#define MB_TOPMOST 0x40000
#define MB_CANCELTRYCONTINUE 6

#define IDOK 1
#define IDCANCEL 2
#define IDABORT 3
#define IDRETRY 4
#define IDIGNORE 5
#define IDYES 6
#define IDNO 7
#define IDCLOSE 8
#define IDHELP 9
#define IDTRYAGAIN 10
#define IDCONTINUE 11

#define MB_TIMEDOUT 32000

Procedure Main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 320 ;
		HEIGHT 260 ;
		TITLE 'MessageBox Timeout Demo' ;
		MAIN ;
		TOPMOST ;
		ON INIT OnInit()

		@ 50 , 50 BUTTON Button_1 ;
			CAPTION "MsgInfo Timeout Test" ;
			ACTION MsgInfoTimeout(3) ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 100 , 50 BUTTON Button_2 ;
			CAPTION "MsgYesNo Timeout Test" ;
			ACTION MsgYesNoTimeout(5) ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 150 , 50 BUTTON Button_3 ;
			CAPTION "MsgOkCancel Timeout Test" ;
			ACTION MsgOkCancelTimeout(5) ;
	                WIDTH 200 ;
			HEIGHT 30

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return


Procedure MsgInfoTimeout( nTimeout )
Local nFlag, nMilliSeconds, nRet

   nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONINFORMATION
   nMilliSeconds := nTimeout * 1000
   nRet := MessageBoxTimeout ("Test a timeout of " + hb_ntos (nTimeout) + " seconds.", "MsgInfo Timeout", nFlag, nMilliSeconds)

DO CASE
   CASE nRet == IDOK
        MsgInfo ( "OK" , "Result" )
   CASE nRet == MB_TIMEDOUT
        MsgInfo ( "TimeOut in " + hb_ntos (nTimeout) + " seconds." , "Result" )
   OTHERWISE
        MsgInfo ( "TimeOut --> nRet = " + hb_ntos (nRet) , "Result" )
ENDCASE

Return


Procedure MsgYesNoTimeout( nTimeout )
Local nFlag, nMilliSeconds, nRet

   nFlag := MB_YESNO + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONQUESTION
   nMilliSeconds := nTimeout * 1000
   nRet := MessageBoxTimeout ("Test a timeout of " + hb_ntos (nTimeout) + " seconds.", "MsgYesNo Timeout", nFlag, nMilliSeconds)

DO CASE
   CASE nRet == IDYES
        MsgInfo ( "YES" , "Result" )
   CASE nRet == IDNO
        MsgInfo ( "NO" , "Result" )
   CASE nRet == MB_TIMEDOUT
        MsgInfo ( "TimeOut in " + hb_ntos (nTimeout) + " seconds." , "Result" )
   OTHERWISE
        MsgInfo ( "TimeOut --> nRet = " + hb_ntos (nRet) , "Result" )
ENDCASE

Return


Procedure MsgOkCancelTimeout( nTimeout )
Local nFlag, nMilliSeconds, nRet

   nFlag := MB_OKCANCEL + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONQUESTION
   nMilliSeconds := nTimeout * 1000
   nRet := MessageBoxTimeout ("Test a timeout of " + hb_ntos (nTimeout) + " seconds.", "MsgOkCancel Timeout", nFlag, nMilliSeconds)

DO CASE
   CASE nRet == IDOK
        MsgInfo ( "OK" , "Result" )
   CASE nRet == IDCANCEL 
        MsgInfo ( "CANCEL" , "Result" )
   CASE nRet == MB_TIMEDOUT
        MsgInfo ( "TimeOut in " + hb_ntos (nTimeout) + " seconds." , "Result" )
   OTHERWISE
        MsgInfo ( "TimeOut --> nRet = " + hb_ntos (nRet) , "Result" )
ENDCASE

Return


Static Procedure OnInit

	IF !IsWinXPorLater()
		MsgStop( 'This Program Runs In WinXP or Later Only!', 'Stop' )
		ReleaseAllWindows()
	ENDIF

Return
