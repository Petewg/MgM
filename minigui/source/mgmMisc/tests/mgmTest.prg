#include <hmg.ch>

#xcommand IsMaximized( <hWnd> ) => wapi_IsZoomed( win_N2P( <hWnd> ) )
#xcommand IsMinimized( <hWnd> ) => wapi_IsIconic( win_N2P( <hWnd> ) )

PROCEDURE Main()
   STATIC lBlur := .F. 

   DEFINE WINDOW MainForm AT 0,0 WIDTH 1024 HEIGHT 768 TITLE "MgmMisc library testing " ICON "MGM" MAIN ON INIT NIL ON RELEASE NIL // ON MINIMIZE msginfo( iif( IsWindow( MainForm.Handle, "ICONIC" ), "Minimized!", "No Minimized!" ) )

      @ 10, 010 BUTTON bt_1 Caption "LockDeskTop()" Width 100 ;
            ACTION Iif( MsgYesNo( e"Lock desktop! \n\r are you sure?" ), mgm_LockDeskTop(), NIL )

      @ 10, 110 BUTTON bt_2 Caption "SuspendMonitor()" Width 100 ;
            ACTION Iif( MsgYesNo( e"Suspend Monitor for 13 secs! \n\r are you sure?" ), mgm_SuspendMonitor(), NIL )

      @ 10, 210 BUTTON bt_3 Caption "SuspendSystem()" Width 100 ;
            ACTION Iif( MsgYesNo( e"Suspend System (hibernate) \n\r are you sure?" ), mgm_SuspendSystem( .T. ), NIL )

      @ 10, 310 BUTTON bt_4 Caption "Enumerate Wins" Width 100 ;
            ACTION GetAllWindows()

      @ 10, 410 BUTTON bt_5 Caption e"Error Description" Width 100 ;
            ACTION (wapi_SetLastError( val(inputbox("enter error code:",,"123"))), MsgInfo( mgm_ErrorDescription(), "Error Description" ) )

      @ 10, 510 BUTTON bt_6 Caption e"Process List" Width 100 ;
            ACTION GetAllProcesses()

      @ 10, 610 BUTTON bt_7 Caption e"Blur window?" Width 100 ;
            ACTION BLURWINDOW( MainForm.Handle, lBlur := !lBlur )
            
      @ 10, 710 BUTTON bt_8 Caption e"WW" Width 40 ;
            ACTION mgm_WaitWindow( {"Hello there!","(mgm_WaitWindow)","","press esc to close..."}, .F., {80,130,200}, {255,255,250} )
            //ACTION mgm_WaitWindow( hb_eol()+"Hello there!"+hb_eol()+hb_eol()+"(mgm_WaitWindow)"+hb_eol()+hb_eol()+"press esc to close...", .f., {80,130,200}, {255,255,250} )

      @ 10, 750 BUTTON bt_9 Caption e"WW2" Width 40 ;
            ACTION mgm_WaitWindow( "Hello there!"+hb_eol()+"(mgm_WaitWindow)"+hb_eol()+hb_eol()+"press esc to close...", .f., {80,130,200}, {255,255,250} )
      
      @ 10, 790 BUTTON bt_10 Caption e"BF" Width 40 ; //      ACTION win_GetOpenFileName( )*/
      ACTION mgm_WaitWindow( {"You selected: ", mgm_BrowseForFolder(_HMG_MainHandle, hb_CWD(), "Please choose a folder",;
                                          .f.,0x00004000+0x00000004      ), "", "press Esc... " } )

      @ 10, 830 BUTTON bt_11 Caption e"CPU" Width 40 ; //      ACTION win_GetOpenFileName( )*/
      ACTION  ( msgInfo( "CPU Speed (when idle): " + hb_ntoc( GetCpuSpeed(1), 3 ) + " GHz" + hb_eol() + ; 
                         "CPU Speed (when busy): " + hb_ntoc( GetCpuSpeed(2), 3 ) + " GHz", "GetCpuSpeed()" ) )
                                          
      //mgm_BrowseForFolder( [<hWnd>], [<cInitFolder>], [<cTitle>], [<lAllowCreateFolder>], [<nFlags>] )
            
   END WINDOW
   ON KEY ESCAPE OF MainForm ACTION ThisWindow.Release()
   CENTER  WINDOW MainForm
   ACTIVATE WINDOW MainForm

RETURN

PROCEDURE GetAllWindows()

   LOCAL aHeaders := { "Name", "Handle", "Process ID" ,"Thread ID", "ClassName", "HWND" }
   LOCAL aWidths := { 100, 100, 100, 100, 100, 100 }
   LOCAL aColumnCtrl := { {'TEXTBOX','CHARACTER'}, {'TEXTBOX','NUMERIC','999999999'}, ;
                          {'TEXTBOX','NUMERIC','999999999'}, {'TEXTBOX','NUMERIC','999999999'}, ;
                          {'TEXTBOX','CHARACTER'}, {'TEXTBOX','NUMERIC','999999999'} }
   LOCAL aColumnSrt := {2,1,1,1,1}
   LOCAL aGrid := {}
   LOCAL nI, hWnd, nThreadID, nProcessID, cFullName
   LOCAL aHWND := EnumWindows()
   LOCAL bDblClick

   // msgdebug( hb_BitShift( 255, 8 ), hb_BitShift( 0, 8 ), hb_BitShift( 0, 8 ) )

   MGM_WaitWindow( "Gathering info! please wait...", .T., , PURPLE )

   FOR nI := 1 TO Len( aHWND )
      hWnd := aHWND[nI]
      IF GetWindow( aHWND[nI], 4 /*GW_OWNER*/ ) > 0
         nThreadID := GetWindowThreadProcessId( hWnd , @nProcessID )
         cFullName := GetProcessFullName ( nProcessID )
         cFullName := IIf( cFullName == NIL, "?", cFullName )
         //if cFullName == "?" .OR. AScan( aGrid, {|a| a[1] == cFullName } ) == 0
            AAdd( aGrid, { AllTrim( cFullName ), hb_ntos(hWnd), hb_ntos(nProcessID), ;
                           hb_ntos(nThreadID), AllTrim( GetClassName2(hWnd) ), hWnd } )
         //endif
      ENDIF
   NEXT
   aGrid := ASort( aGrid,,, {|x,y| lower(x[1]) < lower(y[1]) } )

   bDblClick := {|| DblClick1( "MainForm", "Grid_1" ) }
   CreateGrid( "MainForm", "Grid_1", 40, 10, 1000, 680, ;
                             aHeaders, aWidths, aGrid, aColumnCtrl, aColumnSrt, bDblClick )

   DoMethod( "MainForm", "Grid_1", "ColumnsAutoFitH" )
   DoMethod( "MainForm", "Grid_1", "Show" )
   MGM_WaitWindow()
   
RETURN

PROCEDURE GetAllProcesses()
   // { cProcessName, nProcessID, nParentID, cUserName, cDomain (computername) }
   LOCAL aHeaders := { "ProcessName", "ProcessID", "ParentID" ,"UserName", "Domain" }
   LOCAL aWidths := {100, 100, 100, 100, 100 }
   LOCAL aColumnCtrl := { {'TEXTBOX','CHARACTER'}, {'TEXTBOX','NUMERIC','999999999'}, ;
                       {'TEXTBOX','NUMERIC','999999999'}, {'TEXTBOX','CHARACTER'}, ;
                       {'TEXTBOX','CHARACTER'} }
   LOCAL aColumnSrt := {2,1,1,1,1}
   LOCAL aGrid := {}


   MGM_WaitWindow( "Gathering info! please wait...", .T., {0,255,255} )
   win_GetProcessList( aGrid )
   AEval( aGrid, {|x| x[1] := lower(x[1]) } )
   aGrid := ASort( aGrid,,, {|x,y| x[1] < y[1] } )

   CreateGrid( "MainForm", "Grid_1", 40, 10, 1000, 680, ;
                             aHeaders, aWidths, aGrid, aColumnCtrl, aColumnSrt )

   DoMethod( "MainForm", "Grid_1", "ColumnsAutoFitH" )
   DoMethod( "MainForm", "Grid_1", "Show" )
   MGM_WaitWindow()
   
RETURN

STATIC PROCEDURE CreateGrid( cParent, cGridName, nRow, nCol, nWidth, nHeight, ;
                                aHeaders, aWidths, aItems, aColumnCtrl, aColumnSrt, bDblClick )

   IF IsControlDefined( &cGridName, &cParent )
      DoMethod( cParent, cGridName, "Release" )
   ENDIF

   DEFINE GRID &cGridName
         PARENT &cParent
         ROW            nRow
         COL            nCol
         WIDTH          nWidth
         HEIGHT         nHeight
         HEADERS        aHeaders
         WIDTHS         aWidths
         ITEMS          aItems
         VALUE          1
         FONTNAME       "Segoe UI"
         FONTSIZE       9
         ON DBLCLICK    Iif( HB_ISEVALITEM(bDblClick), Eval( bDblClick ), NIL )
         COLUMNCONTROLS aColumnCtrl
         COLUMNSORT     aColumnSrt
   END GRID

   DoMethod( cParent, cGridName, "ColumnsAutoFitH" )
   DoMethod( cParent, cGridName, "Show" )

RETURN

STATIC PROCEDURE DblClick1( cForm, cGrid )
   LOCAL hWnd1, hWnd2, nProcessID, cFullName
   
   hWnd1 := Getproperty( cForm, cGrid, "Cell", Getproperty( cForm, cGrid, "Value" ), 6 )
   hWnd2 := GetParent( hWnd1 )
   
   GetWindowThreadProcessId( hWnd2 , @nProcessID )
   cFullName := GetProcessFullName ( nProcessID )
  
   MsgDebug( "parent hwnd",hb_ntos( hWnd1 ), "process hwnd", hb_ntos( hWnd2 ), "name", cFullName, "ID", hb_ntos( nProcessID) )
   
RETURN

   

#pragma begindump

#include "mgdefs.h"
#include "Dwmapi.h"

HB_FUNC( GETCLASSNAME2 )
{
 HWND hWnd = (HWND) hb_parnl(1);
 char lpClassName[256];

 // GetClassName( hWnd, lpClassName, 256 );
 RealGetWindowClass( hWnd, lpClassName, 256 );

 hb_retc( (LPTSTR) lpClassName );
}

HB_FUNC( BLURWINDOW ) 
{
   HRESULT hr = S_OK;
   HWND hWnd = (HWND) hb_parnl(1);
   BOOL enable = hb_parl(2);

   // Create and populate the Blur Behind structure
   DWM_BLURBEHIND bb = {0};

   // Enable Blur Behind and apply to the entire client area
   bb.dwFlags = DWM_BB_ENABLE | DWM_BB_BLURREGION | DWM_BB_TRANSITIONONMAXIMIZED;
   bb.fEnable = enable;
   bb.hRgnBlur = NULL;
   bb.fTransitionOnMaximized = TRUE;

   // Apply Blur Behind
   hr = DwmEnableBlurBehindWindow(hWnd, &bb);

   hb_retl( hr );
}

HB_FUNC( GETPARENT )
{
   HWND hwnd = (HWND) hb_parnl( 1 );
   UINT gaFlags = GA_ROOT | GA_ROOTOWNER | GA_PARENT;
   
   hb_retnl( (HB_LONG) GetAncestor( hwnd, gaFlags ) );
}

/*
HRESULT FindExecutableAssociatedWithFileExtension( PCWSTR extension, PWSTR resultBuffer, DWORD bufferLength)
{
 return AssocQueryString(ASSOCF_INIT_INGORENUNKNOWN,
                         ASSOCSTR_EXECUTABLE,
                         fullPath,
                         nullptr,
                         resultBuffer,
                         &bufferLength);
}
*/









#pragma enddump

/*
int WINAPI GetClassName(
  _In_  HWND   hWnd,
  _Out_ LPTSTR lpClassName,
  _In_  int    nMaxCount
);
*/







* EnumWindows() -> aArray filled with handles of all top-level windows
* EnumChildWindows( hWnd ) -> aArray filled with handles of all child windows
*
* GetWindowThreadProcessId( hWnd, @nProcessID ) -> nThreadID
* GetProcessFullName ( [ nProcessID ] ) --> return cProcessFullName

