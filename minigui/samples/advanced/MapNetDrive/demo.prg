/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Map Network Drive
 * Demo was contributed to HMG forum by KDJ 09/May/2017
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include "hmg.ch"

FUNCTION Main()
  LOCAL cDrive    := "Z:"
  LOCAL cResource := "\\MYSERVER\HOMES"
  LOCAL cUser     := ""
  LOCAL cPassword := ""

  SET FONT TO 'MS Shell Dlg', 8

  DEFINE WINDOW Main;
    MAIN;
    ROW     100;
    COL     100;
    WIDTH   350;
    HEIGHT  170;
    TITLE   "Map Network Drive";
    ICON "net.ico";
    ON INIT MainUpdate(cDrive)

    DEFINE LABEL Drive
      ROW    10
      COL    10
      WIDTH  300
      HEIGHT 13
      VALUE  "Drive: " + cDrive
    END LABEL

    DEFINE LABEL Resource
      ROW    30
      COL    10
      WIDTH  300
      HEIGHT 13
      VALUE  "Resource: " + cResource
    END LABEL

    DEFINE LABEL User
      ROW    50
      COL    10
      WIDTH  300
      HEIGHT 13
      VALUE  "User: " + cUser
    END LABEL

    DEFINE LABEL Password
      ROW    70
      COL    10
      WIDTH  300
      HEIGHT 13
      VALUE  "Password: " + cPassword
    END LABEL

    DEFINE BUTTON Connect
      ROW     100
      COL     10
      WIDTH   100
      HEIGHT  25
      CAPTION "Connect (Map)"
      ACTION  Connect(cDrive, cResource, cUser, cPassword)
    END BUTTON

    DEFINE BUTTON Disconnect
      ROW     100
      COL     120
      WIDTH   100
      HEIGHT  25
      CAPTION "Disconnect"
      ACTION  Disconnect(cDrive)
    END BUTTON

    DEFINE BUTTON Browse
      ROW     100
      COL     230
      WIDTH   100
      HEIGHT  25
      CAPTION "Browse"
      ACTION  Browse(cDrive)
    END BUTTON

    ON KEY ESCAPE ACTION Main.RELEASE
  END WINDOW

  Main.ACTIVATE

RETURN NIL


FUNCTION MainUpdate(cDrive)
  LOCAL nType := GetDriveType(hb_DirSepAdd(cDrive))

  Main.Drive.VALUE := "Drive: " + cDrive + If(nType == 1, "", " (connected)")

  Main.Disconnect.ENABLED := (nType != 1 /*DRIVE_NO_ROOT_DIR*/)
  Main.Browse.ENABLED     := (nType != 1 /*DRIVE_NO_ROOT_DIR*/)

  Main.Connect.SETFOCUS

RETURN NIL


FUNCTION Connect(cDrive, cRes, cUser, cPass)
  LOCAL nType := GetDriveType(hb_DirSepAdd(cDrive))
  LOCAL nError

  IF (nType == 1 /*DRIVE_NO_ROOT_DIR*/)
    nError := NetAddConnection(cDrive, cRes, cUser, cPass)

    IF nError != 0
      MsgBox("Can not connect." + CRLF + "Error code: " + HB_NtoS(nError) + CRLF + GetSystemErrorMessage(nError))
    ENDIF
  ELSE
    MsgBox("Can not connect, drive is already connected!")
  ENDIF

  MainUpdate(cDrive)

RETURN NIL


FUNCTION Disconnect(cDrive)

  NetCancelConnection(cDrive, .T. /*force disconnect*/)
  MainUpdate(cDrive)

RETURN NIL


FUNCTION Browse(cDrive)

  EXECUTE FILE 'explorer.exe' PARAMETERS '/e, ' + cDrive

RETURN NIL


#pragma BEGINDUMP

#include <mgdefs.h>


      // https://msdn.microsoft.com/en-us/library/windows/desktop/aa364939(v=vs.85).aspx
      // GetDriveType(cRootPathName)
HB_FUNC( GETDRIVETYPE )
{
  hb_retni(GetDriveType(hb_parc(1)));
}


      // https://msdn.microsoft.com/en-us/library/windows/desktop/aa385413(v=vs.85).aspx
      // NetAddConnection(cDrive, cResource, cUser, cPass)
HB_FUNC( NETADDCONNECTION )
{
  NETRESOURCE NetRes;

  NetRes.dwType       = RESOURCETYPE_DISK;
  NetRes.lpLocalName  = ( char * ) hb_parc(1);
  NetRes.lpRemoteName = ( char * ) hb_parc(2);
  NetRes.lpProvider   = NULL;

  hb_retni(WNetAddConnection2(&NetRes, hb_parc(4), hb_parc(3), CONNECT_UPDATE_PROFILE));
}


      // https://msdn.microsoft.com/en-us/library/windows/desktop/aa385427(v=vs.85).aspx
      // NetCancelConnection(cDrive, lForce)
HB_FUNC( NETCANCELCONNECTION )
{
  hb_retni(WNetCancelConnection2(hb_parc(1), CONNECT_UPDATE_PROFILE, (BOOL) hb_parl(2)));
}


      // https://msdn.microsoft.com/en-us/library/windows/desktop/aa385453(v=vs.85).aspx
      // NetGetConnection(cDrive)
HB_FUNC( NETGETCONNECTION )
{
  TCHAR lpName[MAX_PATH];
  DWORD nBufLen = MAX_PATH;

  if (WNetGetConnection(hb_parc(1), lpName, &nBufLen) == NO_ERROR)
    hb_retc(lpName);
  else
    hb_retc(NULL);
}


      // https://msdn.microsoft.com/en-us/library/windows/desktop/aa385476(v=vs.85).aspx
      // NetGetUser(cDrive)
HB_FUNC( NETGETUSER )
{
  TCHAR lpName[MAX_PATH];
  DWORD nBufLen = MAX_PATH;

  if (WNetGetUser(hb_parc(1), lpName, &nBufLen) == NO_ERROR)
    hb_retc(lpName);
  else
    hb_retc(NULL);
}


      // https://msdn.microsoft.com/en-us/library/windows/desktop/ms679351(v=vs.85).aspx
      // GetSystemErrorMessage(nError)
HB_FUNC( GETSYSTEMERRORMESSAGE )
{
  DWORD  dwError = hb_parni(1);
  LPVOID lpMsgBuf;

  FormatMessage(
    FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS | 72,
    NULL,
    dwError,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL),
    (LPTSTR) &lpMsgBuf,
    0,
    NULL);

  hb_retc(lpMsgBuf);

  //HeapFree(GetProcessHeap(), 0, lpMsgBuf);
  LocalFree(lpMsgBuf);
}

#pragma ENDDUMP
