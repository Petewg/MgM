*****
* Manejo de Errores
* Extraido de ErrorSys.prg
* Adalberto del Rosario
*****

#include <minigui.ch>
#include "error.ch"

FUNCTION MyErrorFunc( MyObjError )
    LOCAL cErrorMsg, HtmArch, cText, i := 2

    cErrorMsg := MyErrorMessage( MyObjError )

    SET ERRORLOG TO GetStartupFolder() + "\MyErrors.htm"

    HtmArch := Html_ErrorLog()
    Html_LineText( HtmArch, '<p class="updated">Date: ' + Dtoc(Date()) + "  " + "Time: " + Time() )
    Html_LineText( HtmArch, cErrorMsg + "</p>" )
    
    cErrorMsg += CRLF + CRLF
    
    WHILE ! Empty( ProcName( i ) )
        cText := "Called from " + ProcName( i ) + "(" + AllTrim( Str( ProcLine( i++ ) ) ) + ")" + CRLF
        cErrorMsg += cText
        Html_LineText( HtmArch, cText )
    ENDDO
    Html_Line( HtmArch )
    Html_End( HtmArch )

    MsgStop( cErrorMsg, 'Program Error...' )

RETURN .T.


STATIC FUNCTION MyErrorMessage( oError )
   LOCAL cMessage

   // start error message
   cMessage := iif( oError:severity > ES_WARNING, "Error", "Warning" ) + " "

   // add subsystem name if available
   IF ISCHARACTER( oError:subsystem )
      cMessage += oError:subsystem()
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code if available
   IF ISNUMBER( oError:subCode )
      cMessage += "/" + LTrim( Str( oError:subCode ) )
   ELSE
      cMessage += "/???"
   ENDIF

   // add error description if available
   IF ISCHARACTER( oError:description )
      cMessage += "  " + oError:description
   ENDIF

   // add either filename or operation
   DO CASE
   CASE !Empty( oError:filename )
      cMessage += ": " + oError:filename
   CASE !Empty( oError:operation )
      cMessage += ": " + oError:operation
   ENDCASE

RETURN cMessage
