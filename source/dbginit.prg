/*

  _DbgInit

  Initializes console screen dimensions from init.mgd.
  Used in debug mode to control debug screen dimensions.
  init.mgd is a text file similar to init.cld and supports one command:
  SCREEN SIZE <nRows> <nCols>

*/

INIT PROCEDURE _DbgInit

   LOCAL cIniCont
   LOCAL cIniFile := 'init.mgd'
   LOCAL cLine
   LOCAL nCols    := 0
   LOCAL nLine
   LOCAL nLineLen := 0x1000
   LOCAL nLines
   LOCAL nPos
   LOCAL nRows    := 0

   IF hb_FileExists( cIniFile )
      cIniCont := MemoRead( cIniFile )
      nLines   := MLCount( cIniCont, nLineLen )
      FOR nLine := 1 TO nLines
         cLine := Upper( AllTrim( MemoLine( cIniCont, nLineLen, nLine ) ) )
         IF Left( cLine, 7 ) == 'SCREEN '
            nPos  := At( ' ', cLine )
            cLine := AllTrim( SubStr( cLine, nPos + 1 ) )
            IF Left( cLine, 5 ) == 'SIZE '
               nPos  := At( ' ', cLine )
               cLine := AllTrim( SubStr( cLine, nPos + 1 ) )
               IF ' ' $ cLine
                  nRows := Max( Val( AllTrim( Left( cLine, nPos - 1 ) ) ), 25 )
                  nCols := Max( Val( AllTrim( SubStr( cLine, nPos + 1 ) ) ), 80 )
               ENDIF
            ENDIF
         ENDIF
      NEXT
   ENDIF

   IF !Empty( nRows ) .AND. !Empty( nCols )
      SetMode( nRows, nCols )
   ENDIF

RETURN

//***************************************************************************
