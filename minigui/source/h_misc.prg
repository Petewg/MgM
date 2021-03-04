/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2021, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#include 'minigui.ch'

*-----------------------------------------------------------------------------*
FUNCTION GetData()
*-----------------------------------------------------------------------------*
   LOCAL PacketNames [ aDir ( _HMG_CommPath + _HMG_StationName + '.*' ) ]
   LOCAL i, Rows, Cols, RetVal := Nil, aItem, aTemp := {}, r, c
   LOCAL DataValue, DataType, DataLength, Packet
   LOCAL bd := Set ( _SET_DATEFORMAT )

   SET DATE TO ANSI

   ADir ( _HMG_CommPath + _HMG_StationName + '.*' , PacketNames )

   IF Len ( PacketNames ) > 0

      Packet := MemoRead ( _HMG_CommPath + PacketNames [1] )

      Rows := Val ( SubStr ( MemoLine ( Packet , , 1 ) , 11 , 99 ) )
      Cols := Val ( SubStr ( MemoLine ( Packet , , 2 ) , 11 , 99 ) )

      DO CASE

      // Single Data
      CASE Rows == 0 .AND. Cols == 0

         DataType := SubStr ( MemoLine ( Packet ,  , 3 ) , 12 , 1 )
         DataLength := Val ( SubStr ( MemoLine ( Packet , , 3 ) , 14 , 99 ) )

         DataValue := MemoLine ( Packet , 254 , 4 )

         DO CASE
         CASE DataType == 'C'
            RetVal := Left ( DataValue , DataLength )
         CASE DataType == 'N'
            RetVal := Val ( DataValue )
         CASE DataType == 'D'
            RetVal := CToD ( DataValue )
         CASE DataType == 'L'
            RetVal := ( AllTrim ( DataValue ) == 'T' )
         END CASE

      // One Dimension Array Data
      CASE Rows != 0 .AND. Cols == 0

         i := 3

         DO WHILE i < MLCount ( Packet )

            DataType   := SubStr ( MemoLine ( Packet , , i ) , 12 , 1 )
            DataLength := Val ( SubStr ( MemoLine ( Packet , , i ) , 14 , 99 ) )

            i++

            DataValue  := MemoLine ( Packet , 254 , i )

            DO CASE
            CASE DataType == 'C'
               aItem := Left ( DataValue , DataLength )
            CASE DataType == 'N'
               aItem := Val ( DataValue )
            CASE DataType == 'D'
               aItem := CToD ( DataValue )
            CASE DataType == 'L'
               aItem := ( AllTrim ( DataValue ) == 'T' )
            END CASE

            AAdd ( aTemp , aItem )

            i++

         ENDDO

         RetVal := aTemp

      // Two Dimension Array Data
      CASE Rows != 0 .AND. Cols != 0

         i := 3

         aTemp := Array ( Rows , Cols )

         r := 1
         c := 1

         DO WHILE i < MLCount ( Packet )

            DataType   := SubStr ( MemoLine ( Packet , , i ) , 12 , 1 )
            DataLength := Val ( SubStr ( MemoLine ( Packet , , i ) , 14 , 99 ) )

            i++

            DataValue  := MemoLine ( Packet , 254 , i )

            DO CASE
            CASE DataType == 'C'
               aItem := Left ( DataValue , DataLength )
            CASE DataType == 'N'
               aItem := Val ( DataValue )
            CASE DataType == 'D'
               aItem := CToD ( DataValue )
            CASE DataType == 'L'
               aItem := ( AllTrim ( DataValue ) == 'T' )
            END CASE

            aTemp [r] [c] := aItem

            c++
            IF c > Cols
               r++
               c := 1
            ENDIF

            i++

         ENDDO

         RetVal := aTemp

      END CASE

      DELETE File ( _HMG_CommPath + PacketNames [1] )

   ENDIF

   SET ( _SET_DATEFORMAT , bd )

RETURN ( RetVal )

*-----------------------------------------------------------------------------*
FUNCTION SendData ( cDest , Data )
*-----------------------------------------------------------------------------*
   LOCAL cData, i, j
   LOCAL pData, cLen, cType, FileName, Rows, Cols

   FileName := _HMG_CommPath + cDest + '.' + _HMG_StationName + '.' + hb_ntos ( ++_HMG_SendDataCount )

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
               MsgMiniGuiError( 'SendData: Type Not Supported.' )
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
                  MsgMiniGuiError( 'SendData: Type Not Supported.' )
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
         MsgMiniGuiError( 'SendData: Type Not Supported.' )
      ENDIF

      cData := '#DataRows=0' + Chr( 13 ) + Chr( 10 )
      cData += '#DataCols=0' + Chr( 13 ) + Chr( 10 )

      cData += '#DataBlock=' + cType + ',' + cLen + Chr( 13 ) + Chr( 10 )
      cData += pData + Chr( 13 ) + Chr( 10 )

      MemoWrit ( FileName , cData )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION HMG_ClrToHTML( nClr )
*-----------------------------------------------------------------------------*

   LOCAL cHex := Lower( hb_NumToHex( nClr, 6 ) )

RETURN "#" + Right( cHex, 2 ) + SubStr( cHex, 3, 2 ) + Left( cHex, 2 )
