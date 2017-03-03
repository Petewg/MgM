/*
*
* MiniGUI DLL Demo
*
*/

#include "hmg.ch"

#define TAB	Chr(9)
#define MsgInfo( c ) MsgInfo( c, , , .f. )

PROCEDURE Main()

   // LOCAL aDriveLetters := GetLogicalDriveLetters()
   LOCAL aDriveLetters := GetLogicalDriveStrings()
   LOCAL aImages := {}
   
   AEval( aDriveLetters, {|| AAdd( aImages, "HD.BMP" )} )

   
   
	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 320 ;
		HEIGHT 300 ;
		TITLE 'Volume Information' ;
		ICON "HD.ICO" ;
		MAIN NOMAXIMIZE NOSIZE

      @ 10 , 10 LABEL Label_1 VALUE "Select a Drive:"
      @ 10 , 95 COMBOBOXEX CbEx_1 ITEMS aDriveLetters VALUE 1 WIDTH 70 HEIGHT 200 LISTWIDTH 65 IMAGE aImages;
         ON LISTCLOSE NIL // DisplayVolumeInfo( aDriveLetters[This.Value] )
   
      @ 9,180 BUTTON Button1 CAPTION "Get Volume Info" HEIGHT 26 ACTION DisplayVolumeInfo( aDriveLetters[ Win_1.CbEx_1.Value], .T. )

		@ 220,180 BUTTON Button2 CAPTION "Close" ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

   RETURN



PROCEDURE DisplayVolumeInfo( cDrive )
   Local cInfo := ""
   Local aInfo := GetVolumeInfo( cDrive )
   LOCAL nType

   cInfo += "Drive Letter"  + TAB + ": " + cDrive   + hb_EoL()
   cInfo += "Volume Name"   + TAB + ": " + aInfo[1] + hb_EoL()
   cInfo += "Serial Number" + TAB + ": " + aInfo[2] + hb_EoL()
   cInfo += "File System"   + TAB + ": " + aInfo[3]

   nType := CallDll32( "GetDriveTypeA", "KERNEL32.DLL", cDrive )

   If nType == 1
      cInfo := "Drive Type " + TAB + ": " + "DRIVE_NO_ROOT_DIR" + hb_EoL() + cInfo
   ElseIf nType == 2
      cInfo := "Drive Type " + TAB + ": " + "DRIVE_REMOVABLE"   + hb_EoL() + cInfo
   ElseIf nType == 3
      cInfo := "Drive Type " + TAB + ": " + "DRIVE_FIXED"       + hb_EoL() + cInfo
   ElseIf nType == 4
      cInfo := "Drive Type " + TAB + ": " + "DRIVE_REMOTE"      + hb_EoL() + cInfo
   ElseIf nType == 5
      cInfo := "Drive Type " + TAB + ": " + "DRIVE_CDROM"       + hb_EoL() + cInfo
   ElseIf nType == 6
      cInfo := "Drive Type " + TAB + ": " + "DRIVE_RAMDISK"     + hb_EoL() + cInfo
   Else
      cInfo := "Drive Type " + TAB + ": " + "DRIVE_UNKNOWN"     + hb_EoL() + cInfo      
   Endif
   
   MsgInfo( cInfo )
   
   RETURN 
   

FUNCTION GetVolumeInfo( cDrive )

  LOCAL lpRoot    := cDrive + "\"
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

  if GetVolInfo( lpRoot, @lpVolName, nVolName, @lpSerial, lpMaxLen, lpFlags, @lpSysName, nSysName ) > 0

    aInfo[1] := sz2Str( lpVolName )
    lpSerial := sz2Str( RTrim( lpSerial ) )
  
    for i := Len( lpSerial ) to 1 step -1
      cTemp += PadL( DecToHexA( Asc( SubStr( lpSerial, i, 1 ) ) ), 2, "0" )
    next

    aInfo[2] := left(cTemp, 4) + "-" + substr(cTemp, 5, 4)
    aInfo[3] := sz2Str( lpSysName )
    
   else
      // msginfo("couldn't retrieve info..")
  endif

return aInfo


FUNCTION SZ2Str( cStr )
RETURN StrTran( RTrim( cStr ), Chr( 0 ), "" )


FUNCTION GetVolInfo( lpRoot,  lpVolName, nVolName,  lpSerial, lpMaxLen,  lpFlags, lpSysName,  nSysName )
RETURN CallDll32( "GetVolumeInformationA", "KERNEL32.DLL", lpRoot, @lpVolName, nVolName, ;
                   @lpSerial, lpMaxLen, lpFlags, @lpSysName, nSysName )




FUNCTION GetLogicalDriveLetters()

 LOCAL cBitMask := DecToBin( CallDll32( "GetLogicalDrives", "Kernel32.dll" ) )
 LOCAL n := 0
 LOCAL a := {}
 LOCAL c
 
 FOR EACH c IN cBitMask DESCEND
   n++
   IF c == "1"
      AAdd( a, Chr( 64 + n ) + ":" )
   ENDIF
 NEXT
 
 RETURN a
 
 
 
FUNCTION GetLogicalDriveStrings()
   LOCAL lpBuffer := Space( 260 )
   LOCAL nBufferLength := Len( lpBuffer ) 
   LOCAL nRetLen
   
   nRetLen := CallDll32( "GetLogicalDriveStringsA", "Kernel32.dll", nBufferLength, @lpBuffer )
   
   lpBuffer := StrTran( RTrim( lpBuffer ), Chr( 0 ), " " /*hb_EoL()*/ )
   
   RETURN  ( hb_ATokens(lpBuffer) )
   
   
   
 
 

                   

#ifdef __XHARBOUR__
  #include <hex.prg>
#endif