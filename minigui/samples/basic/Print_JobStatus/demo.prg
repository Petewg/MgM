#include "hmg.ch"

MEMVAR aJobData
MEMVAR aColor

*------------------------------------------------------------------------------*
FUNCTION Main()
*------------------------------------------------------------------------------*
   PRIVATE aJobData   // aJobData must be declared as Public or Private
   PRIVATE aColor[10 ]

   aColor[1 ] := YELLOW
   aColor[2 ] := PINK
   aColor[3 ] := RED
   aColor[4 ] := FUCHSIA
   aColor[5 ] := BROWN
   aColor[6 ] := ORANGE
   aColor[7 ] := GREEN
   aColor[8 ] := PURPLE
   aColor[9 ] := BLACK
   aColor[10 ] := BLUE

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'MiniPrint Library Test' ;
      MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Default Printer' ACTION PrintTest1()
            MENUITEM 'User Selected Printer' ACTION PrintTest2()
            MENUITEM 'User Selected Printer And Settings' ACTION PrintTest3()
            MENUITEM 'User Selected Printer And Settings (Preview)' ACTION PrintTest4()
         END POPUP
      END MENU

      @ 10, 10 LABEL Label_1 VALUE "" WIDTH 500 HEIGHT 100
      @ 120, 10 EDITBOX EditBox_1 VALUE "" WIDTH 700 HEIGHT 500 FONT "Courier New" SIZE 10

      DEFINE TIMER Timer_1 INTERVAL 250 ACTION DisplayJobInfo()

   END WINDOW

   MAXIMIZE WINDOW Win_1

   ACTIVATE WINDOW Win_1

RETURN NIL
*------------------------------------------------------------------------------*
PROCEDURE PrintTest1()
*------------------------------------------------------------------------------*

   SELECT PRINTER DEFAULT ;
      ORIENTATION PRINTER_ORIENT_PORTRAIT ;
      PAPERSIZE PRINTER_PAPER_LETTER ;
      QUALITY  PRINTER_RES_MEDIUM

   PrintDoc()

   MsgInfo( 'Print Finished' )

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintTest2()
*------------------------------------------------------------------------------*
   LOCAL cPrinter

   cPrinter := GetPrinter()

   IF Empty ( cPrinter )
      RETURN
   ENDIF

   SELECT PRINTER cPrinter ;
      ORIENTATION PRINTER_ORIENT_PORTRAIT ;
      PAPERSIZE PRINTER_PAPER_LETTER ;
      QUALITY  PRINTER_RES_MEDIUM

   PrintDoc()

   MsgInfo( 'Print Finished' )

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintTest3()
*------------------------------------------------------------------------------*
   LOCAL lSuccess

   // Measure Units Are Millimeters

   SELECT PRINTER DIALOG TO lSuccess

   IF lSuccess == .T.
      PrintDoc()
      MsgInfo( 'Print Finished' )
   ENDIF

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintTest4()
*------------------------------------------------------------------------------*
   LOCAL lSuccess

   SELECT PRINTER DIALOG TO lSuccess PREVIEW

   IF lSuccess == .T.
      PrintDoc()
      MsgInfo( 'Print Finished' )
   ENDIF

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintDoc
*------------------------------------------------------------------------------*
   LOCAL i

   Win_1.EditBox_1.Value := ""   // clean EditBox

   START PRINTDOC STOREJOBDATA aJobData

   FOR i := 1 TO 10

      START PRINTPAGE

      @ 20, 20 PRINT RECTANGLE ;
         TO 50, 190 ;
         PENWIDTH 0.1

      @ 25, 25 PRINT IMAGE "hmg.gif" ;
         WIDTH 20 ;
         HEIGHT 20

      @ 30, 85 PRINT "PRINT DEMO" ;
         FONT "Courier New" ;
         SIZE 24 ;
         BOLD ;
         COLOR aColor[i ]

      @ 140, 60 PRINT "Page Number : " + hb_ntos( i ) ;
         FONT "Arial" ;
         SIZE 20 ;
         COLOR aColor[i ]

      @ 260, 20 PRINT LINE ;
         TO 260, 190 ;
         PENWIDTH 0.1

      END PRINTPAGE

   NEXT i

   END PRINTDOC

RETURN

#define JOB_STATUS_PAUSED              0x00000001
#define JOB_STATUS_ERROR               0x00000002
#define JOB_STATUS_DELETING            0x00000004
#define JOB_STATUS_SPOOLING            0x00000008
#define JOB_STATUS_PRINTING            0x00000010
#define JOB_STATUS_OFFLINE             0x00000020
#define JOB_STATUS_PAPEROUT            0x00000040
#define JOB_STATUS_PRINTED             0x00000080
#define JOB_STATUS_DELETED             0x00000100
#define JOB_STATUS_BLOCKED_DEVQ        0x00000200
#define JOB_STATUS_USER_INTERVENTION   0x00000400
#define JOB_STATUS_RESTART             0x00000800
#define JOB_STATUS_COMPLETE            0x00001000


#define PRINTER_STATUS_OK                    0
#define PRINTER_STATUS_PAUSED                0x00000001
#define PRINTER_STATUS_ERROR                 0x00000002
#define PRINTER_STATUS_PENDING_DELETION      0x00000004
#define PRINTER_STATUS_PAPER_JAM             0x00000008
#define PRINTER_STATUS_PAPER_OUT             0x00000010
#define PRINTER_STATUS_MANUAL_FEED           0x00000020
#define PRINTER_STATUS_PAPER_PROBLEM         0x00000040
#define PRINTER_STATUS_OFFLINE               0x00000080
#define PRINTER_STATUS_IO_ACTIVE             0x00000100
#define PRINTER_STATUS_BUSY                  0x00000200
#define PRINTER_STATUS_PRINTING              0x00000400
#define PRINTER_STATUS_OUTPUT_BIN_FULL       0x00000800
#define PRINTER_STATUS_NOT_AVAILABLE         0x00001000
#define PRINTER_STATUS_WAITING               0x00002000
#define PRINTER_STATUS_PROCESSING            0x00004000
#define PRINTER_STATUS_INITIALIZING          0x00008000
#define PRINTER_STATUS_WARMING_UP            0x00010000
#define PRINTER_STATUS_TONER_LOW             0x00020000
#define PRINTER_STATUS_NO_TONER              0x00040000
#define PRINTER_STATUS_PAGE_PUNT             0x00080000
#define PRINTER_STATUS_USER_INTERVENTION     0x00100000
#define PRINTER_STATUS_OUT_OF_MEMORY         0x00200000
#define PRINTER_STATUS_DOOR_OPEN             0x00400000
#define PRINTER_STATUS_SERVER_UNKNOWN        0x00800000
#define PRINTER_STATUS_POWER_SAVE            0x01000000

*------------------------------------------------------------------------------*
PROCEDURE DisplayJobInfo()
*------------------------------------------------------------------------------*
   STATIC flag := .F.
   LOCAL i, nPos, cStatusPrinter, nStatusPrinter, cStatusJob, aJobInfo, t

   LOCAL aStatusPrinter := { { PRINTER_STATUS_PAUSED,              "PRINTER_STATUS_PAUSED" }, ;
      { PRINTER_STATUS_ERROR,               "PRINTER_STATUS_ERROR" }, ;
      { PRINTER_STATUS_PENDING_DELETION,    "PRINTER_STATUS_PENDING_DELETION" }, ;
      { PRINTER_STATUS_PAPER_JAM,           "PRINTER_STATUS_PAPER_JAM" }, ;
      { PRINTER_STATUS_PAPER_OUT,           "PRINTER_STATUS_PAPER_OUT" }, ;
      { PRINTER_STATUS_MANUAL_FEED,         "PRINTER_STATUS_MANUAL_FEED" }, ;
      { PRINTER_STATUS_PAPER_PROBLEM,       "PRINTER_STATUS_PAPER_PROBLEM" }, ;
      { PRINTER_STATUS_OFFLINE,             "PRINTER_STATUS_OFFLINE" }, ;
      { PRINTER_STATUS_IO_ACTIVE,           "PRINTER_STATUS_IO_ACTIVE" }, ;
      { PRINTER_STATUS_BUSY,                "PRINTER_STATUS_BUSY" }, ;
      { PRINTER_STATUS_PRINTING,            "PRINTER_STATUS_PRINTING" }, ;
      { PRINTER_STATUS_OUTPUT_BIN_FULL,     "PRINTER_STATUS_OUTPUT_BIN_FULL" }, ;
      { PRINTER_STATUS_NOT_AVAILABLE,       "PRINTER_STATUS_NOT_AVAILABLE" }, ;
      { PRINTER_STATUS_WAITING,             "PRINTER_STATUS_WAITING" }, ;
      { PRINTER_STATUS_PROCESSING,          "PRINTER_STATUS_PROCESSING" }, ;
      { PRINTER_STATUS_INITIALIZING,        "PRINTER_STATUS_INITIALIZING" }, ;
      { PRINTER_STATUS_WARMING_UP,          "PRINTER_STATUS_WARMING_UP" }, ;
      { PRINTER_STATUS_TONER_LOW,           "PRINTER_STATUS_TONER_LOW" }, ;
      { PRINTER_STATUS_NO_TONER,            "PRINTER_STATUS_NO_TONER" }, ;
      { PRINTER_STATUS_PAGE_PUNT,           "PRINTER_STATUS_PAGE_PUNT" }, ;
      { PRINTER_STATUS_USER_INTERVENTION,   "PRINTER_STATUS_USER_INTERVENTION" }, ;
      { PRINTER_STATUS_OUT_OF_MEMORY,       "PRINTER_STATUS_OUT_OF_MEMORY" }, ;
      { PRINTER_STATUS_DOOR_OPEN,           "PRINTER_STATUS_DOOR_OPEN" }, ;
      { PRINTER_STATUS_SERVER_UNKNOWN,      "PRINTER_STATUS_SERVER_UNKNOWN" }, ;
      { PRINTER_STATUS_POWER_SAVE,          "PRINTER_STATUS_POWER_SAVE" } }

   LOCAL aStatusJob := { { JOB_STATUS_PAUSED,              "JOB_STATUS_PAUSED"             }, ;
      { JOB_STATUS_ERROR,               "JOB_STATUS_ERROR"              }, ;
      { JOB_STATUS_DELETING,            "JOB_STATUS_DELETING"           }, ;
      { JOB_STATUS_SPOOLING,            "JOB_STATUS_SPOOLING"           }, ;
      { JOB_STATUS_PRINTING,            "JOB_STATUS_PRINTING"           }, ;
      { JOB_STATUS_OFFLINE,             "JOB_STATUS_OFFLINE"            }, ;
      { JOB_STATUS_PAPEROUT,            "JOB_STATUS_PAPEROUT"           }, ;
      { JOB_STATUS_PRINTED,             "JOB_STATUS_PRINTED"            }, ;
      { JOB_STATUS_DELETED,             "JOB_STATUS_DELETED"            }, ;
      { JOB_STATUS_BLOCKED_DEVQ,        "JOB_STATUS_BLOCKED_DEVQ"       }, ;
      { JOB_STATUS_USER_INTERVENTION,   "JOB_STATUS_USER_INTERVENTION"  }, ;
      { JOB_STATUS_RESTART,             "JOB_STATUS_RESTART"            }, ;
      { JOB_STATUS_COMPLETE,            "JOB_STATUS_COMPLETE"           } }

   IF flag == .T.
      RETURN
   ENDIF
   flag := .T.

   IF Type ( '_HMG_MINIPRINT[22]' ) == "U"
      _hmg_printer_InitUserMessages()  // initialize of the miniprint vars at startup
   ENDIF

   nStatusPrinter := HMG_PrinterGetStatus ( OpenPrinterGetJobData() [ 2 ] )

   cStatusPrinter := "cStatusPrinter (# " + hb_ntos( nStatusPrinter ) + " ) --> " + iif ( nStatusPrinter == PRINTER_STATUS_OK, "PRINTER_STATUS_OK", "" )
   FOR i := 1 TO Len ( aStatusPrinter )
      IF hb_bitAnd ( nStatusPrinter, aStatusPrinter[ i ][ 1 ] ) == aStatusPrinter[ i ][ 1 ]
         cStatusPrinter := cStatusPrinter + aStatusPrinter[ i ][ 2 ] + " & "
      ENDIF
   NEXT

   nPos := RAt ( "&", cStatusPrinter )
   IF nPos <> 0
      cStatusPrinter = SubStr ( cStatusPrinter, 1, nPos - 1 )
   ENDIF

   t := cStatusPrinter + hb_eol() + hb_eol()

   aJobInfo := HMG_PrintGetJobInfo ( aJobData )

   IF Len ( aJobInfo ) > 0 .AND. nStatusPrinter == PRINTER_STATUS_OK

      cStatusJob := " --> "
      FOR i := 1 TO Len ( aStatusJob )
         IF hb_bitAnd ( aJobInfo[ 8 ], aStatusJob[ i ][ 1 ] ) == aStatusJob[ i ][ 1 ]
            cStatusJob := cStatusJob + aStatusJob[ i ][ 2 ] + " & "
         ENDIF
      NEXT

      nPos := RAt ( "&", cStatusJob )
      IF nPos <> 0
         cStatusJob = SubStr ( cStatusJob, 1, nPos - 1 )
      ENDIF

      t += "nJobID                " + hb_ntos( aJobInfo[  1 ] ) + hb_eol()
      t += "cPrinterName          " +          aJobInfo[  2 ]   + hb_eol()
      t += "cMachineName          " +          aJobInfo[  3 ]   + hb_eol()
      t += "cUserName             " +          aJobInfo[  4 ]   + hb_eol()
      t += "cDocument             " +          aJobInfo[  5 ]   + hb_eol()
      t += "cDataType             " +          aJobInfo[  6 ]   + hb_eol()
      t += "cStatus               " +          aJobInfo[  7 ]   + hb_eol()
      t += "nStatus               " + hb_ntos( aJobInfo[  8 ] ) + cStatusJob + hb_eol()
      t += "nPriorityLevel        " + hb_ntos( aJobInfo[  9 ] ) + hb_eol()
      t += "nPositionPrintQueue   " + hb_ntos( aJobInfo[ 10 ] ) + hb_eol()
      t += "nTotalPages           " + hb_ntos( aJobInfo[ 11 ] ) + hb_eol()
      t += "nPagesPrinted         " + hb_ntos( aJobInfo[ 12 ] ) + hb_eol()
      t += "cSubmittedDate        " +          aJobInfo[ 13 ]   + hb_eol()
      t += "cSubmittedTime        " +          aJobInfo[ 14 ]   + hb_eol() + hb_eol()
      t += "**************************************************************" + hb_eol() + hb_eol()

      Win_1.EditBox_1.Value := Win_1.EditBox_1.Value + t
      Win_1.EditBox_1.CaretPos := Len( Win_1.EditBox_1.Value )
   ELSE
      t += "Not Job Info, last job: " + hb_eol()
      t += "nJobID         : " + hb_ntos( OpenPrinterGetJobData() [ 1 ] ) + hb_eol()
      t += "cPrinterName   : " +          OpenPrinterGetJobData() [ 2 ]   + hb_eol()

      Win_1.Label_1.Value := t
   ENDIF

   flag := .F.

RETURN
