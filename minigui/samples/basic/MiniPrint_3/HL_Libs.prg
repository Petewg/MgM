/*

  HL Library routines for PPTF Print
  
*/

#include "common.ch"
#define CRLF HB_OsNewLine()

FUNCTION HL_ShrinkString( ;                  // Shrink a string to given length
                     cString,; 
                     nLenght ) 
                     
   LOCAL cRVal := cString,;
         nSPos                      // Shrink Position
         
   IF ! EMPTY( cString )
      IF LEN( cString ) > nLenght
         nSPos := INT( nLenght / 2 ) - 3 
         cRVal := LEFT( cString, nSPos ) + "..." +;
                 RIGHT( cString, nSPos )
      ENDIF
   ENDIF !EMPTY( cString )
   
RETURN cRVal // HL_ShrinkString() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNCTION HL_LineWordWrap( ;                  // Splite a line to given portions without split last word
                     cLine,;
                     nLeng ) // of resulting (splitted) lines; in char
                     
   LOCAL cRVal  := '',;
         c1Line := '',;
         nTknPos := 0     // Last token position  
         
   WHILE LEN( cLine ) > nLeng
      c1Line := LEFT( cLine, nLeng ) 
      nTknPos := AtToken( c1Line ) // RAT( ' ', c1Line ) 
      IF nTknPos > 1      
         c1Line :=  LEFT( c1Line, nTknPos -1 ) 
      ENDIF      
      cRVal += c1Line + CRLF      
      cLine := SUBSTR( cLine,  LEN( c1Line ) + 1 )
   ENDDO
   
   IF !EMPTY( cLine )
      cRVal += cLine // + CRLF
   ENDIF
   
RETURN cRVal // HL_LineWordWrap()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
/*
   Convert a numeric value to "xxx Bytes / KB / MB" string form
*/
FUNCTION HL_BytesVerbal( ;                        // Bytes -- verbal
                       nBytes )  
                
   LOCAL cRetVal := ''
    
   IF nBytes # 0
      IF nBytes < 1024
         cRetVal := NTOC( nBytes ) + " Bytes"
      ELSEIF nBytes < 1024 * 1024
         cRetVal := LTRIM( STR( nBytes / 1024, 9, 3 ) ) + " KB"
      ELSE
         cRetVal := LTRIM( STR( nBytes / ( 1024 * 1024 ), 9, 3 ) ) + " MB"
      ENDIF
   ENDIF nBytes # 0
      
RETURN cRetVal // HL_BytesVerbal()       

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

function xPadC( cText, nPixels, cChar )

   local cRet    := If( ISCHARACTER( cText ), AllTrim( cText ), "" )
   local nLen    := Len( cText )
   local nPixLen
   local nPad

   DEFAULT cChar TO Chr(32)

   nPixLen := GetTextWidth( , cText )
   nPad    := GetTextWidth( , cChar )

   if nPixels > nPixLen
      cRet := PadC( cRet, Int( nLen + ( nPixels - nPixLen ) / nPad ), cChar )
   endif

return cRet
