/*
*
* MiniGUI DLL Demo
*
*/

#include "minigui.ch"
#include "hbdyn.ch"

#define TAB	Chr(9)
#define MsgInfo( c ) MsgInfo( c, , , .f. )

Procedure Main

Local cInfo := ""
Local aInfo := GetVolumeInfo( "c:\" )

	If !Empty( aInfo[2] )
		cInfo += "Drive Name :" + TAB + "C:" + CRLF
		cInfo += "Volume Name :" + TAB + aInfo[1] + CRLF
		cInfo += "Serial Number :" + TAB + aInfo[2] + CRLF
		cInfo += "File System :" + TAB + aInfo[3]
	EndIf

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'Volume Information' ;
		ICON "HD.ICO" ;
		MAIN NOMAXIMIZE NOSIZE

		@ 10,10 BUTTON Button1 CAPTION "Get Info" ACTION IF(Empty(cInfo), MsgStop( "Error!" ), MsgInfo( cInfo )) DEFAULT

		@ 50,10 BUTTON Button2 CAPTION "Close" ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return

/*
*/
Function GetVolumeInfo(cDrive)

   Local VolName:= Space(201), nVol:= 200, Serial:= Space(4), MaxLen:= 0, Flags:= 0, SysName:= Space(241), nSys:= 240, aInfo:= Array(3), cTemp:= "", i

   If HMG_CallDLL("KERNEL32.DLL", HB_DYN_CTYPE_BOOL, "GetVolumeInformation", cDrive, @VolName, nVol, @Serial, @MaxLen, Flags, @SysName, nSys)

      aInfo[1] := Rtrim(VolName)

      aInfo[3] := Rtrim(SysName)

      For i := 4 To 1 Step -1

          cTemp += PadLeft(DecToHexA(Asc(SubStr(Serial, i, 1))), 2, "0")

      Next

      aInfo[2]:= Left(cTemp, 4) + "-" + SubStr(cTemp, 5, 4)

   Endif

Return aInfo
