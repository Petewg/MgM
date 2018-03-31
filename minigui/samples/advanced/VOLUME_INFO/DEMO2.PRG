/*
 *
 * MiniGUI DLL Demo
 *
*/

#include "minigui.ch"

#define TAB Chr(9)
#define MsgInfo( c ) MsgInfo( c, , , .f. )

PROCEDURE Main

   LOCAL cInfo := ""
   LOCAL aInfo := GetVolumeInfo( "c:\" )

   IF !Empty( aInfo[ 2 ] )
      cInfo += "Drive Name :" + TAB + "C:" + CRLF
      cInfo += "Volume Name :" + TAB + aInfo[ 1 ] + CRLF
      cInfo += "Serial Number :" + TAB + aInfo[ 2 ] + CRLF
      cInfo += "File System :" + TAB + aInfo[ 3 ]
   ENDIF

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 300 ;
      TITLE 'Volume Information' ;
      ICON "HD.ICO" ;
      MAIN NOMAXIMIZE NOSIZE

      @ 10, 10 BUTTON Button1 CAPTION "Get Info" ACTION IF( Empty( cInfo ), MsgStop( "Error!" ), MsgInfo( cInfo ) ) DEFAULT

      @ 50, 10 BUTTON Button2 CAPTION "Close" ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN

/*
*/
FUNCTION GetVolumeInfo( cDrive )

   LOCAL lpRoot    := cDrive
   LOCAL lpVolName := Space( 200 )
   LOCAL nVolName  := 201
   LOCAL nSysName  := 201
   LOCAL lpSerial  := Space( 16 )
   LOCAL lpMaxLen  := 0
   LOCAL lpFlags   := 0
   LOCAL lpSysName := Space( 240 )
   LOCAL aInfo     := Array( 3 )

   LOCAL i
   LOCAL cTemp := ""

   IF GetVolInfo( lpRoot, @lpVolName, nVolName, ;
         @lpSerial, lpMaxLen, ;
         lpFlags, @lpSysName, ;
         nSysName ) > 0

      aInfo[ 1 ] := sz2Str( lpVolName )
      lpSerial := sz2Str( lpSerial )

      FOR i := Len( lpSerial ) TO 1 STEP -1
         cTemp += PadL( DecToHexA( Asc( SubStr( lpSerial, i, 1 ) ) ), 2, "0" )
      NEXT

      aInfo[ 2 ] := Left( cTemp, 4 ) + "-" + SubStr( cTemp, 5, 4 )
      aInfo[ 3 ] := sz2Str( lpSysName )

   ENDIF

RETURN aInfo

/*
*/
FUNCTION SZ2Str( cStr )
RETURN StrTran( RTrim( cStr ), Chr( 0 ), "" )

/*
*/
DECLARE DLL_TYPE_BOOL GetVolumeInformationA( DLL_TYPE_LPCSTR lpRoot, DLL_TYPE_LPCSTR lpVolName, ;
      DLL_TYPE_LONG nVolName, DLL_TYPE_LPCSTR lpSerial, ;
      DLL_TYPE_LONG lpMaxLen, DLL_TYPE_LONG lpFlags, ;
      DLL_TYPE_LPCSTR lpSysName, DLL_TYPE_LONG nSysName ) ;
      IN KERNEL32.DLL ;
      ALIAS GetVolInfo

#ifdef __XHARBOUR__
  #include <hex.prg>
#endif
