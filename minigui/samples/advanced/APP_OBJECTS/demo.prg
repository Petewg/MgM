 /*
  * Harbour MiniGUI Demo
  * (c) 2017 SergKis
 */

#include "minigui.ch"
#include "hbclass.ch"

MEMVAR oApp, oMain, oWnd

///////////////////////////////////////////////////////////////////////////
FUNCTION Main( ... )

   LOCAL cTx, nY := 10, nX := 10

   SET OOP ON

   PUBL oApp := oAppData( "DataBase", "MyProg", 100 )

   IF oApp:Error
      MsgStop( "Application events are not created !", "ERROR" )
      QUIT
   ENDIF

   WITH OBJECT oApp

      :Event( 1, {| oa, ky| cTx := '', AEval( { oa:Desktop,      ;
                                                oa:MyDocuments,  ;
                                                oa:ProgramFiles, ;
                                                oa:System,       ;
                                                oa:Windows,      ;
                                                oa:Temp },       ;
         {| ct, ni| cTx += hb_ntos( ni ) + '. ' + ct + CRLF } ), ;
         MsgBox( cTx, "System path. Event=" + hb_ntos( ky ) ) } )

      :Event( 2, {| oa, ky| cTx := '', AEval( { oa:Exe,          ;
                                                oa:ExePath,      ;
                                                oa:ExeName,      ;
                                                oa:ExeIni,       ;
                                                oa:ExeCfg },     ;
         {| ct, ni| cTx += hb_ntos( ni ) + '. ' + ct + CRLF } ), ;
         MsgBox( cTx, "Exe property. Event=" + hb_ntos( ky ) ) } )

      :Event( 3, {| oa, ky| cTx := '', AEval( { oa:Name,         ;
                                                oa:CurDir,       ;
                                                oa:CurIni,       ;
                                                oa:CurCfg },     ;
         {| ct, ni| cTx += hb_ntos( ni ) + '. ' + ct + CRLF } ), ;
         MsgBox( cTx, "Current property. Event=" + hb_ntos( ky ) ) } )

      :Event( 4, {| oa, ky| cTx := '', AEval( { oa:Name,         ;
                                                oa:Path,         ;
                                                oa:PathIni,      ;
                                                oa:PathCfg },    ;
         {| ct, ni| cTx += hb_ntos( ni ) + '. ' + ct + CRLF } ), ;
         MsgBox( cTx, "Path property. Event=" + hb_ntos( ky ) ) } )

   END WITH

   DEFINE WINDOW Win_1 ;
      CLIENTAREA 400, 400 ;
      TITLE 'Demo App objects' ;
      MAIN ;
      ON INTERACTIVECLOSE oApp:Destroy()

   PRIV oWnd  := ThisWindow.Object
   PUBL oMain := oWnd

   DEFINE BUTTONEX Button1
     ROW      nY
     COL      nX
     CAPTION  "Event 1"
     ACTION   oApp:Event( 1 )
     TOOLTIP  "System path. Event=1"
   END BUTTONEX

   nY += This.Button1.Height + 10
   DEFINE BUTTONEX Button2
     ROW      nY
     COL      nX
     CAPTION  "Event 2"
     ACTION   oApp:Event( 2 )
     TOOLTIP  "Exe property. Event=2"
   END BUTTONEX

   nY += This.Button2.Height + 10
   DEFINE BUTTONEX Button3
     ROW      nY
     COL      nX
     CAPTION  "Event 3"
     ACTION   oApp:Event( 3 )
     TOOLTIP  "Current property. Event=3"
   END BUTTONEX

   nY += This.Button3.Height + 10
   DEFINE BUTTONEX Button4
     ROW      nY
     COL      nX
     CAPTION  "Event 4"
     ACTION   oApp:Event( 4 )
     TOOLTIP  "Path property. Event=4"
   END BUTTONEX

   nY += This.Button4.Height + 10
   DEFINE BUTTONEX Button5
     ROW      nY
     COL      nX
     CAPTION  "PostMsg 1"
     ACTION   oApp:SendMsg( 1 )
   END BUTTONEX

   nY += This.Button5.Height + 10
   DEFINE BUTTONEX Button6
     ROW      nY
     COL      nX
     CAPTION  "PostMsg 2"
     ACTION   oApp:SendMsg( 2 )
   END BUTTONEX

   nY += This.Button6.Height + 10
   DEFINE BUTTONEX Button7
     ROW      nY
     COL      nX
     CAPTION  "PostMsg 3"
     ACTION   oApp:SendMsg( 3 )
   END BUTTONEX

   nY += This.Button7.Height + 10
   DEFINE BUTTONEX Button8
     ROW      nY
     COL      nX
     CAPTION  "PostMsg 4"
     ACTION   oApp:PostMsg( 4 )
   END BUTTONEX

   END WINDOW

   Win_1.Center
   Win_1.Activate

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
CLASS TAppData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR cExe                          INIT hb_ProgName()
   VAR cName                         INIT hb_FNameName( hb_ProgName() )
   VAR nApp                          INIT 100
   VAR hWnd                          INIT 0
   VAR lErr                          INIT .F.
   VAR oEvent            AS OBJECT

   EXPORTED:
   VAR cPath                         INIT ''
   VAR oCargo            AS OBJECT

   METHOD New( nApp ) INLINE ( ::nApp := iif( HB_ISNUMERIC( nApp ), nApp, ::nApp ), ;
      Self )          CONSTRUCTOR

   METHOD Def( cPath, cName )  INLINE ( ::Name := cName, ::Path := cPath,  ;
      ::oEvent := oKeyData( Self ), ::oCargo := oKeyData(), Self )

   ASSIGN Handle( hWnd )        INLINE ( ::hWnd := hWnd, ::lErr := Empty( hWnd ) )
   ACCESS Error                 INLINE ::lErr
   ACCESS WmApp                 INLINE ( WM_USER + ::nApp )

   ACCESS Name                  INLINE ::cName
   ASSIGN Name( cName )         INLINE ( cName := iif( HB_ISCHAR( cName ), cName, ::cName ), ;
      ::cName := iif( Empty( cName ), ::cName, cName ) )

   ACCESS Desktop               INLINE GetDesktopFolder()      + hb_ps()
   ACCESS MyDocuments           INLINE GetMyDocumentsFolder()  + hb_ps()
   ACCESS ProgramFiles          INLINE GetProgramFilesFolder() + hb_ps()
   ACCESS System                INLINE GetSystemFolder()       + hb_ps()
   ACCESS Temp                  INLINE GetTempFolder()         + hb_ps()
   ACCESS Windows               INLINE GetWindowsFolder()      + hb_ps()

   ACCESS Exe                   INLINE ::cExe
   ACCESS ExePath               INLINE hb_FNameDir ( ::cExe )
   ACCESS ExeName               INLINE hb_FNameName( ::cExe )
   ACCESS ExeIni                INLINE ::ExePath + ::ExeName + ".ini"
   ACCESS ExeCfg                INLINE ::ExePath + ::ExeName + ".cfg"

   ACCESS CurDir                INLINE hb_DirBase()
   ACCESS CurIni                INLINE ::CurDir + ::cName + ".ini"
   ACCESS CurCfg                INLINE ::CurDir + ::cName + ".cfg"

   ACCESS Path                  INLINE ::cPath
   ASSIGN Path( cPath )         INLINE ( cPath := iif( HB_ISCHAR( cPath ), cPath, ::cName ), ;
      cPath := iif( Empty( cPath ), ::cName, cPath ), ;
      cPath := iif( hb_ps() $ cPath, cPath, ::CurDir + cPath ), ;
      ::cPath := cPath + iif( Right( cPath, 1 ) == hb_ps(), "", hb_ps() ) )

   ACCESS PathIni               INLINE ::cPath + ::cName + ".ini"
   ACCESS PathCfg               INLINE ::cPath + ::cName + ".cfg"

   ACCESS DesktopWidth          INLINE GetDesktopWidth ()
   ACCESS DesktopHeight         INLINE GetDesktopHeight() - GetTaskBarHeight()

   METHOD Create()              INLINE _App_Wnd_Events_( Self )

   METHOD Event   ( Key, Block, p2, p3 )  INLINE iif( HB_ISBLOCK( Block ), ;
      ::oEvent:Set( Key, Block ), ;
      ::oEvent:Do ( Key, Block, p2, p3 ) )

   METHOD PostMsg( nKey, nPar )  INLINE PostMessage( ::hWnd, ::WmApp, nKey, hb_defaultValue( nPar, 0 ) )
   METHOD SendMsg( nKey, nPar )  INLINE SendMessage( ::hWnd, ::WmApp, nKey, hb_defaultValue( nPar, 0 ) )

   METHOD Destroy()  INLINE ( ::Cargo := Nil,                              ;
      ::oCargo := iif( HB_ISOBJECT( ::oCargo ), ::oCargo:Destroy(), Nil ), ;
      ::oEvent := iif( HB_ISOBJECT( ::oEvent ), ::oEvent:Destroy(), Nil ) )
#ifndef __XHARBOUR__
   DESTRUCTOR DestroyObject()
#endif

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

#ifndef __XHARBOUR__
METHOD PROCEDURE DestroyObject()  CLASS TAppData

   ::Destroy()

RETURN
#endif

*-----------------------------------------------------------------------------*
FUNCTION oAppData( cPathBase, cName, nApp )
*-----------------------------------------------------------------------------*

   LOCAL o := TAppData():New( nApp ):Def( cPathBase, cName )

   o:Create()

RETURN o

*-----------------------------------------------------------------------------*
FUNCTION _App_Wnd_Events_( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*

   LOCAL  h, r := 0
   STATIC o_app

   IF HB_ISOBJECT( hWnd )
      MESSAGEONLY _App_Wnd_App_  EVENTS _App_Wnd_Events_  TO h
      o_app        := hWnd
      o_app:Handle := h
      RETURN r
   ELSEIF ! HB_ISOBJECT( o_app )
      RETURN r
   ENDIF

   IF nMsg == o_app:WmApp
      o_app:Event( wParam, lParam )
      r := 1
   ENDIF

RETURN r
