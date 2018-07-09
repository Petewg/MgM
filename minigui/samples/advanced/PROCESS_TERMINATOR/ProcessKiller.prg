/*
 * MINIGUI Extended - Harbour Win32 GUI library Demo
 *
*/

ANNOUNCE RDDSYS

#include "Minigui.ch"

#define PROGRAM 'Kill last instance (Press Esc or Alt+X to exit)'
#define VERSION ' version 1.2'
#define CREATOR ' Pierpaolo Martinello 2018 '
#define IDI_MAIN 1001

MEMVAR Arg1,Kill
/*
*/
*-----------------------------------------------------------------------------*
Procedure Main(Exe, delThis)
*-----------------------------------------------------------------------------*
   SET MULTIPLE OFF

   Public Arg1,kill
   Default Exe to "", DelThis to .F.
   If !Empty(exe)
      Arg1 := cFileNoExt(Exe)+".exe"
   Endif

   Kill := iif(ValType(DelThis) == "C", .T., DelThis)

   IF !isVistaOrlater()
      Msgstop("This program require Vista or later!")
      Return
   Endif

   SET FONT TO _GetSysFont(), 10

   DEFINE WINDOW frmProcInfo ;
      WIDTH 880 + iif( IsWinNT(), GetBorderWidth() / 2, 0 ) ;
      HEIGHT 480 + iif( IsWinNT(), GetBorderHeight(), 0 ) ;
      TITLE 'Process Information' ;
      ICON IDI_MAIN ;
      MAIN NOMAXIMIZE NOMINIMIZE

      DEFINE STATUSBAR
         STATUSITEM '  Pierpaolo Martinello '+Chr(169)+' - Copyright 2018 - '+PROGRAM WIDTH 250
         CLOCK WIDTH 80
         DATE WIDTH 100
         STATUSITEM ' Refresh ' WIDTH 80 ACTION ( kill := .F., FillGrid( Arg1 ) )
      END STATUSBAR

      ON KEY ESCAPE ACTION ThisWindow.Release
      ON KEY ALT+X ACTION frmProcInfo.Release

      @ 10, 10 GRID grdProcInfo ;
         WIDTH 850 ;
         HEIGHT 407 ;
         HEADERS { 'Img', 'PID', 'Creation Date Time', 'Full Path' } ;
         WIDTHS { 130,70, 150, 475 };
         ITEMS {} ;
         TOOLTIP "Double click to kill the selected process." ;
         JUSTIFY { 0, 1, 0, 0 } ;
         ON DBLCLICK CloseFile( arg1 ) ;
         COLUMNSORT { 1, 0, 0, 0 } ;
         PAINTDOUBLEBUFFER

      DEFINE CONTEXT MENU CONTROL grdProcInfo
            MENUITEM "Kill This instance" ACTION CloseFile() ICON IDI_MAIN
            SEPARATOR
            MENUITEM "Filter instance" ACTION Filter()
            MENUITEM "Show all instances" ACTION ( arg1 := "", FillGrid( Arg1 ) )
      END MENU

   END WINDOW // frmProcInfo

   FillGrid( Arg1 )

   CENTER Window frmProcInfo

   ACTIVATE Window frmProcInfo

RETURN
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION KillExe( Pid, cResult )
*-----------------------------------------------------------------------------*
   LOCAL cCommand := "wmic process " + pid + " delete"

   RETURN SysCmd( cCommand, @cResult )
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION SysCmd( cCommand, /*@*/ cResult )
*-----------------------------------------------------------------------------*
   LOCAL hProcess
   LOCAL hStdOut, hStderr, nState, nBytes
   LOCAL cBuff := Space( 1024 )

// hProcess := HB_PROCESSOPEN( <cCommand>, NIL, @hStdOut, @hStderr, lDetach )
   hProcess := hb_ProcessOpen( cCommand, NIL, @hStdOut, @hStdErr, .T. )

   IF hProcess != -1

   // nState := hb_ProcessValue( hProcess, lWait )
      nState := hb_ProcessValue( hProcess, .T. )

      WHILE nState <> -1

         nBytes := FRead( hStdOut, @cBuff, 1024 /* cBuff length */ )

         IF nBytes == 0
            EXIT
         ENDIF

         nState := hb_ProcessValue( hProcess, .T. )

      END

      cBuff   := StrTran( cBuff, Chr( 13 ) )
      cBuff   := StrTran( cBuff, Chr( 10 ) )
      cResult := CharRem( " ", cBuff )

      hb_ProcessClose( hProcess )

   ENDIF

RETURN hProcess
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION GetExePid(ExeName, last)
*-----------------------------------------------------------------------------*
   LOCAL oWmi, oItem , aRtv :={}, cQry, cSW_CreationDate
   Default ExeName to "", last to .F.

   cQry := "SELECT * FROM Win32_Process " + iif(!Empty(ExeName), "Where Name = '"+ExeName+"'", "")

   oWmi := WmiService()

   FOR EACH oItem IN oWmi:ExecQuery( cQry )
       cSW_CreationDate := "  " ;
                         + left(oItem:CreationDate,4)+"/" ;
                         + substr(oItem:CreationDate,5,2)+"/" ;
                         + substr(oItem:CreationDate,7,2)+"   ";
                         + substr(oItem:CreationDate,09,2)+":";
                         + substr(oItem:CreationDate,11,2)+":";
                         + substr(oItem:CreationDate,13,2)

       aadd(aRtv,{oItem:Caption,hb_valtostr(oItem:ProcessId),cSW_CreationDate,oitem:ExecutablePath})
   NEXT

   IF !Empty(ExeName)
      // sort by time
      asort(aRtv ,,, { |x,y| x[3] < y[3] } )
   Endif

   IF last
      aRtv := { atail(aRtv) }
   Endif

   IF atail(aRtv) == NIL
      aRtv := {{"","","",""}}
      MessageBoxTimeout("No instance named "+Arg1+" are active now!","", 0 ,1500)
   Endif

Return aRtv
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION WMIService()
*-----------------------------------------------------------------------------*
   LOCAL oLocator
   STATIC oWmi

   IF oWmi == NIL
         oLocator := CreateObject( "wbemScripting.SwbemLocator" )
         oWmi     := oLocator:ConnectServer()
   ENDIF

RETURN oWmi
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE CloseFile()
*-----------------------------------------------------------------------------*

   KillExe( frmProcInfo.grdProcInfo.Item( frmProcInfo.grdProcInfo.Value )[ 2 ] )
   FillGrid( Arg1 )

RETURN
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE FillGrid( Arg1 )
*-----------------------------------------------------------------------------*
   Local Instances
   IF Empty(arg1)
      kill := .F.
   Endif
   Instances := GetExePid( Arg1, kill )

   frmProcInfo.grdProcInfo.DisableUpdate()

   frmProcInfo.grdProcInfo.DeleteAllItems()

   AEval( instances, { |x| frmProcInfo.grdProcInfo.AddItem( x ) } )

   _SetMultiImage( 'grdProcInfo', 'frmProcInfo', 1, HDR_IMAGE_NONE, .F. )

   frmProcInfo.grdProcInfo.EnableUpdate()

   frmProcInfo.grdProcInfo.SetFocus()

   If Kill
      KillExe( Instances[1,2] )
      kill := .F.
      FillGrid( Arg1 )
   Endif

RETURN // FillGrid()
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE Filter( )
*-----------------------------------------------------------------------------*
   Local aValor_IW, c_Valor
   c_Valor := frmProcInfo.grdProcInfo.Item( frmProcInfo.grdProcInfo.Value )[ 1 ]
   aValor_IW := InputWindow ( 'Blank = remove the filter.', { 'Img instance :' }, { c_Valor }, { 30 } )
   If aValor_IW [1] != Nil
      Arg1 := cFileNoExt(aValor_IW [1])
      If !Empty(Arg1)
          Arg1 += ".exe"
      Endif
      FillGrid( Arg1 )
   Endif

RETURN