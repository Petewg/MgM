/*
 * Harbour Win32 Demo
 *
 * Data Client
 * Copyright 2015 Verchenko Andrey <verchenkoag@gmail.com>
 *
*/

#include "hbgtinfo.ch"
#include "common.ch"
#include "inkey.ch"

STATIC _HMG_Commpath, _HMG_StationName, _HMG_SendDataCount
////////////////////////////////////////////////////////////////////////////
FUNCTION Main()
   LOCAL nKey, cColor := "15/2", nRecno := 1
   LOCAL GetList := {}

    _HMG_Commpath := hb_CurDrive()+":\"+CurDir()+"\"
    _HMG_StationName := "DATACLIENT"
    _HMG_SendDataCount := 0

    hb_gtInfo( HB_GTI_CLOSABLE, .F. )
    hb_GTInfo( HB_GTI_WINTITLE, "Data Client" ) // Define the title of the window from the main menu
    //hb_GtInfo(HB_GTI_SETPOS_ROWCOL, 0, 0)
    hb_gtInfo( HB_GTI_ALTENTER, .F. )  // allow alt-enter for full screen
    hb_GtInfo(HB_GTI_SETPOS_XY, 0, 0)
    SETMODE(24,80)
    SET SCOREBOARD OFF
    SET CURSOR ON
    SETCOLOR(cColor)
    CLEAR SCREEN

    ? PADC(VERSION(),MAXCOL()) ; ?
    ? "  This example demonstrates the transfer of data"
    ? "  in a window of another program SERVER !"

    @  0, 0 TO MAXROW(),MAXCOL() DOUBLE
    @ MAXROW()-1,0 SAY "  ESC-exit  "
    @ MAXROW()-2,0 TO MAXROW(),11  DOUBLE
    COLORWIN(MAXROW()-2,0,MAXROW(),11,78)
    @ 15, 4 SAY "Built-in library MiniGui exchange data between applications using" COLOR("14/2")
    @ 16, 4 SAY "a temporary file." COLOR("14/2")
    INKEY(5)

    @ 6,5 SAY ' Transmit data: string ("Hi, text string")' COLOR("0/2")
       SENDDATA("MAINPROC", "Hi, text string")
       INKEY(1)
    @ 7,5 SAY ' Transmit data: number ( 2015 )' COLOR("0/2")
       SENDDATA("MAINPROC", 2015 )
       INKEY(1)
    @ 8,5 SAY ' Transmit data: date   ( '+DTOC(DATE())+' )' COLOR("0/2")
       SENDDATA("MAINPROC", DATE() )
       INKEY(1)
    @ 9,5 SAY ' Transmit data: logic  ( .F. )' COLOR("0/2")
       SENDDATA("MAINPROC",  .F.  )
       INKEY(1)
    @ 10,5 SAY ' Transmit data: array  { 1, "text", .F. }' COLOR("0/2")
       SENDDATA("MAINPROC", { 1, "text", .F. } )
       INKEY(1)


    DO WHILE .T.

       @ 12,5 SAY " Transmit data:" GET nRecno PICTURE "9999"
       READ
       TransferDATA(nRecno)

       nKey := INKEY(1, INKEY_ALL)
       IF nKey == K_ESC
            EXIT
       ENDIF

    ENDDO

    QUIT

    RETURN NIL

////////////////////////////////////////////////////////////////////////////
FUNCTION TransferDATA(xVal)

     IF LASTKEY() == K_ENTER

        // Data transfer window Server
	SENDDATA("MAINPROC",xVal)

     ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION SendData ( cDest , Data )
*-----------------------------------------------------------------------------*
   LOCAL cData, i, j
   LOCAL pData, cLen, cType, FileName, Rows, Cols

   FileName := _HMG_CommPath + cDest + '.' + _HMG_StationName + '.' + hb_ntos ( ++_HMG_SendDataCount )
   @ 17, 5 SAY "File - " + FileName COLOR("11/2")

   IF ValType ( Data ) == 'A'

      IF ValType ( Data [1] ) != 'A'

         cData := '#DataRows=' + hb_ntos( Len(Data ) ) + Chr( 13 ) + Chr( 10 )
         cData += '#DataCols=0' + Chr( 13 ) + Chr( 10 )

         FOR i := 1 TO Len ( Data )

            cType := ValType ( Data [i] )

            IF cType == 'D'
               pData := hb_ntos( Year( data[i] ) ) + '.' + hb_ntos( Month( data[i] ) ) + '.' + hb_ntos( Day( data[i] ) )
               cLen := hb_ntos( Len( pData ) )
            ELSEIF cType == 'L'
               pData := iif( Data [i] == .T. , 'T', 'F' )
               cLen := hb_ntos( Len( pData ) )
            ELSEIF cType == 'N'
               pData := Str ( Data [i] )
               cLen := hb_ntos( Len( pData ) )
            ELSEIF cType == 'C'
               pData := Data [i]
               cLen := hb_ntos( Len( pData ) )
            ELSE
               ALERT( 'SendData: Type Not Supported.' )
            ENDIF

            cData += '#DataBlock=' + cType + ',' + cLen + Chr( 13 ) + Chr( 10 )
            cData += pData + Chr( 13 ) + Chr( 10 )

         NEXT i

         MemoWrit ( FileName , cData )

      ELSE

         Rows := Len ( Data )
         Cols := Len ( Data [1] )

         cData := '#DataRows=' + hb_ntos( Rows ) + Chr( 13 ) + Chr( 10 )
         cData += '#DataCols=' + hb_ntos( Cols ) + Chr( 13 ) + Chr( 10 )

         FOR i := 1 TO Rows

            FOR j := 1 TO Cols

               cType := ValType ( Data [i] [j] )

               IF cType == 'D'
                  pData := hb_ntos( Year( data[i][j] ) ) + '.' + hb_ntos( Month( data[i][j] ) ) + '.' + hb_ntos( Day( data[i][j] ) )
                  cLen := hb_ntos( Len( pData ) )
               ELSEIF cType == 'L'
                  pData := iif( Data [i] [j] == .T. , 'T', 'F' )
                  cLen := hb_ntos( Len( pData ) )
               ELSEIF cType == 'N'
                  pData := Str ( Data [i] [j] )
                  cLen := hb_ntos( Len( pData ) )
               ELSEIF cType == 'C'
                  pData := Data [i] [j]
                  cLen := hb_ntos( Len( pData ) )
               ELSE
                  ALERT( 'SendData: Type Not Supported.' )
               ENDIF

               cData += '#DataBlock=' + cType + ',' + cLen + Chr( 13 ) + Chr( 10 )
               cData += pData + Chr( 13 ) + Chr( 10 )

            NEXT j
         NEXT i

         MemoWrit ( FileName , cData )

      ENDIF

   ELSE

      cType := ValType ( Data )

      IF cType == 'D'
         pData := hb_ntos( Year( data ) ) + '.' + hb_ntos( Month( data ) ) + '.' + hb_ntos( Day( data ) )
         cLen := hb_ntos( Len( pData ) )
      ELSEIF cType == 'L'
         pData := iif( Data == .T. , 'T', 'F' )
         cLen := hb_ntos( Len( pData ) )
      ELSEIF cType == 'N'
         pData := Str ( Data )
         cLen := hb_ntos( Len( pData ) )
      ELSEIF cType == 'C'
         pData := Data
         cLen := hb_ntos( Len( pData ) )
      ELSE
         ALERT( 'SendData: Type Not Supported.' )
      ENDIF

      cData := '#DataRows=0' + Chr( 13 ) + Chr( 10 )
      cData += '#DataCols=0' + Chr( 13 ) + Chr( 10 )

      cData += '#DataBlock=' + cType + ',' + cLen + Chr( 13 ) + Chr( 10 )
      cData += pData + Chr( 13 ) + Chr( 10 )

      MemoWrit ( FileName , cData )

   ENDIF

RETURN Nil
