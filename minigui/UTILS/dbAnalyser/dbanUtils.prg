/*****************************
* Source : dbanUtils.prg
* System : <unkown>
* Author : Phil Ide
* Created: 18/02/2004
*
* Purpose:
* ----------------------------
* History:
* ----------------------------
*    18/02/2004 11:49 PPI - Created
*****************************/

#include "Common.ch"
#include "fileio.ch"
#include "dbanalyser.ch"

#define COL_SIZE 14

STATIC FUNCTION MakeCol( cTxt )
   DEFAULT cTxt TO ''

   RETURN PadR( cTxt, COL_SIZE ) + iif( Empty( cTxt ), '  ', ': ' )

STATIC FUNCTION Bin2U( c )

   LOCAL l := Bin2L( c )

   RETURN iif( l < 0, l + 4294967296, l )

FUNCTION hex( n, i )

   LOCAL c := '0123456789ABCDEF'
   LOCAL x
   LOCAL cHex := ''

   WHILE n > 0
      x := n % 16
      cHex := SubStr( c, x + 1, 1 ) + cHex
      n := Int( n / 16 )
   ENDDO
   IF ValType( i ) == 'N'
      cHex := PadL( cHex, i, '0' )
   ENDIF

   RETURN ( cHex )

FUNCTION h2dec( c )

   LOCAL h := '0123456789ABCDEF'
   LOCAL i
   LOCAL x
   LOCAL n
   LOCAL nRet := 0
   LOCAL z := 0

   FOR i := Len( c ) TO 1 STEP -1
      x := SubStr( c, i, 1 )
      n := At( x, h ) -1
      IF z > 0 .AND. n > 0
         n := n * ( 16 ^ z )
      ENDIF
      nRet += n
      z++
   NEXT

   RETURN ( nRet )

FUNCTION idByte()

   LOCAL aType := DBF_TYPE
   LOCAL n
   LOCAL i
   LOCAL v
   LOCAL lOk := TRUE
   LOCAL nH := FHandle()
   LOCAL cBuff := Space( 1 )
   LOCAL c := 'Compatibility'

   FRead( nH, @cBuff, 1 )
   n := Asc( cBuff )

   i := AScan( aType, {| e| e[ 1 ] == n } )


   ? MakeCol( 'FileType' ) + '0x' + hex( n, 2 )
   IF i > 0
      FOR v := 1 TO Len( aType[ i ][ 2 ] )
         ? MakeCol( c ) + aType[ i ][ 2 ][ v ]
         IF v == 1
            c := ''
         ENDIF
      NEXT
      ?
      ? MakeCol( 'Memo' ) + MEMO_TYPE_DESC[ aType[ i ][ 3 ] ][ 2 ]
   ELSE
      ? 'Invalid type descriptor!'
      lOk := FALSE
   ENDIF

   RETURN lOk

FUNCTION LastUpdated()

   LOCAL nH := FHandle()
   LOCAL cBuff := Space( 6 )
   LOCAL nYY
   LOCAL nMM
   LOCAL nDD
   LOCAL dDate

   FRead( nH, @cBuff, 3 )
   nYY := Bin2I( SubStr( cBuff, 1, 1 ) )
   nMM := Bin2I( SubStr( cBuff, 2, 1 ) )
   nDD := Bin2I( SubStr( cBuff, 3, 1 ) )

   dDate := CToD( StrZero( nYY, 2 ) + '-' + StrZero( nMM, 2 ) + '-' + StrZero( nDD, 2 ) )
   ? MakeCol( 'Last Updated' ) + DToC( dDate )

   RETURN TRUE

FUNCTION NumRecsReported()

   LOCAL nH := FHandle()
   LOCAL cBuff := Space( 4 )

   FRead( nH, @cBuff, 4 )

   ? Replicate( '-', COL_SIZE ) + ' Report from Header'
   ? MakeCol( '# Records' ) + Str( Bin2U( cBuff ), 9 )

   RETURN TRUE


FUNCTION ReportHeaderSize()

   LOCAL nH := FHandle()
   LOCAL cBuff := Space( 2 )

   FRead( nH, @cBuff, 2 )
   ? MakeCol( 'Header Size' ) + Str( Bin2U( cBuff ), 9 )

   RETURN TRUE

FUNCTION ReportRecordSize()

   LOCAL nH := FHandle()
   LOCAL cBuff := Space( 2 )

   FRead( nH, @cBuff, 2 )
   ? MakeCol( 'Record Size' ) + Str( Bin2U( cBuff ), 9 )

   RETURN TRUE

FUNCTION IsEncrypted()

   LOCAL nH := FHandle()
   LOCAL cBuff := Space( 1 )

   FSeek( nH, 16, FS_SET )
   FRead( nH, @cBuff, 1 )
   ? MakeCol( 'Encrypted' ) + iif( Asc( cBuff ) > 0, 'Yes', 'No' )

   RETURN TRUE


FUNCTION RecordDetails()

   LOCAL nH := FHandle()
   LOCAL cBuff := Space( 32 )
   LOCAL aFields := Array( 300, 4 )
   LOCAL i
   LOCAL nOff := 1
   LOCAL nRec := 0
   LOCAL nPos
   LOCAL nSize := 1
   LOCAL x
   LOCAL aSFld
   LOCAL nT, nL, nB, nR
   LOCAL cClr

   FSeek( nH, 32, FS_SET )

   WHILE ( x := FRead( nH, @cBuff, 32 ) ) == 32
      IF Asc( SubStr( cBuff, 1, 1 ) ) == 0x0D
         EXIT
      ENDIF

      i := hb_At( Chr( 0 ), cBuff, nOff )
      IF i > 0
         nRec++
         aFields[ nRec ][ 1 ] := SubStr( cBuff, 1, i - 1 )
         aFields[ nRec ][ 2 ] := SubStr( cBuff, 12, 1 )
         aFields[ nRec ][ 3 ] := Asc( SubStr( cBuff, 17, 1 ) )
         aFields[ nRec ][ 4 ] := Asc( SubStr( cBuff, 18, 1 ) )
      ELSE
         EXIT
      ENDIF
   ENDDO
   ASize( aFields, nRec )
   IF Asc( SubStr( cBuff, 1, 1 ) ) == 0x0D // no errors
      nOff := FSeek( nH, -x, FS_RELATIVE )
      nOff := FSeek( nH, 2, FS_RELATIVE )
      nPos := FSeek( nH, 0, FS_END )
      FClose( nH )
      AEval( aFields, {| e| nSize += e[ 3 ] } )
      i := Int( ( nPos - nOff ) / nSize )
      ? MakeCol( 'Fields/Record' ) + Str( Len( aFields ), 9 )
      ? Replicate( '-', COL_SIZE ) + ' Physical'
      ? MakeCol( '# Records' ) + Str( i, 9 )
      ? MakeCol( 'Header Size' ) + Str( nOff, 9 )
      ? MakeCol( 'Record Size' ) + Str( nSize, 9 )
      aSFld := Array( Len( aFields ) )
      FOR i := 1 TO Len( aFields )
         aSFld[ i ] := ' ' + PadR( aFields[ i ][ 1 ], 12 ) + ;
            PadC( aFields[ i ][ 2 ], 3 ) + ;
            PadL( aFields[ i ][ 3 ], 4 ) + ;
            PadL( aFields[ i ][ 4 ], 4 )
      NEXT
      nT := 0
      nL := MaxCol() - Len( aSFld[ 1 ] )
      nB := MaxRow()
      nR := MaxCol()
      cClr := SetColor( 'w/b,n/w' )
      AChoice( nT, nL, nB, nR, aSFld, TRUE )
      SetColor( cClr )
   ENDIF

   RETURN TRUE
