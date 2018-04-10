#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC T_GotoReco()                         // Table T_GotoReco

   LOCA nMaxRec  := LASTREC()
   
   DEFINE WINDOW frmGoReco;
      AT 0, 0 ;
      WIDTH  300 ;
      HEIGHT 100 ;
      MODAL ;
      NOCAPTION 
      
      ON KEY ESCAPE ACTION frmGoReco.Release
       
      DEFINE LABEL lblGoReco
         ROW    40
         COL    40
         AUTOSIZE .T.
         VALUE  "Record Number ( 1 .. " + NTrim( nMaxRec ) + " ) : "
      END LABEL // lblGoReco

      DEFINE TEXTBOX txtGoReco
         ROW    35
         COL    200
         WIDTH  50
         NUMERIC .T.
         VALUE  1
         RIGHTALIGN  .T.
         ONENTER { || DBGOTO( this.Value), frmGoReco.release, RefrBrow() }
      END TEXTBOX // txtGoReco
            
   END WINDOW // frmGoReco

   frmGoReco.txtGoReco.Setfocus
   CENTER   WINDOW frmGoReco
   ACTIVATE WINDOW frmGoReco

RETU // T_GotoReco()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC T_Locate()                           // Table Locate  

   DEFINE WINDOW frmLocate;
      AT 0, 0 ;
      WIDTH  500 ;
      HEIGHT 100 ;
      MODAL ;
      NOCAPTION 
      
      ON KEY ESCAPE ACTION frmLocate.Release
       
      DEFINE LABEL lblLocate
         ROW    40
         COL    20
         AUTOSIZE .T.
         VALUE  "Search Expression : "
      END LABEL // lblLocate

      DEFINE TEXTBOX txtLocate
         ROW    35
         COL    150
         WIDTH  330
         VALUE  ""
         ONENTER TC_Locate( this.Value ) 
      END TEXTBOX // txtLocate
            
   END WINDOW // frmLocate
   
   CENTER   WINDOW frmLocate
   ACTIVATE WINDOW frmLocate

RETU // T_Locate()       
 
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC TC_Locate( cExpress )                // Table Command : Locate 

   LOCA cExpErr := Exp1Chek( cExpress ),;
        nCurRec := RECN() 
   
   IF EMPTY( cExpress )
      frmLocate.release 
      RETU
   ENDIF   

   IF EMPTY( cExpErr )
      LOCATE FOR &cExpress 
      IF EOF()
         DBGOTO( nCurRec )
      ENDIF   
      frmLocate.release 
      RefrBrow() 
   ELSE
      MsgBox( "Invalid expression : " + CRLF2 + cExpErr, "Warning" ) 
   ENDIF   
   
RETU // TC_Locate()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC TC_Continue()                        // Table Command : Continue

   LOCA nCurRec := RECN() 

   CONTINUE
   IF EOF()
      DBGOTO( nCurRec )
   ELSE   
      RefrBrow()
   ENDIF !EOF()
   
RETU // TC_Continue()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_Skip()                             // Table Skip    

   DEFINE WINDOW frmSkip;
      AT 0, 0 ;
      WIDTH  200 ;
      HEIGHT 100 ;
      MODAL ;
      NOCAPTION 
      
      ON KEY ESCAPE ACTION frmSkip.Release
       
      DEFINE LABEL lblSkip
         ROW    40
         COL    30
         AUTOSIZE .T.
         VALUE  "Skip Count  : " 
      END LABEL // lblSkip

      DEFINE TEXTBOX txtSkip
         ROW    35
         COL    120
         WIDTH  50
         NUMERIC .T.
         VALUE  1
         ONENTER { || DBSKIP( this.Value ), frmSkip.release, RefrBrow() }
      END TEXTBOX // txtSkip
            
   END WINDOW // frmSkip

   frmSkip.txtSkip.Setfocus
   CENTER   WINDOW frmSkip
   ACTIVATE WINDOW frmSkip
   
RETU // T_Skip()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC T_Seek()                             // Table Seek    

   DEFINE WINDOW frmSeek;
      AT 0, 0 ;
      WIDTH  500 ;
      HEIGHT 100 ;
      MODAL ;
      NOCAPTION 
      
      ON KEY ESCAPE ACTION frmSeek.Release
       
      DEFINE LABEL lblSeek
         ROW    25
         COL    20
         AUTOSIZE .T.
         VALUE  "Seek Expression : "
      END LABEL // lblSeek

      DEFINE TEXTBOX txtSeek
         ROW    20
         COL    150
         WIDTH  330
         VALUE  ""
         ONENTER TC_Seek( this.Value, frmSeek.chkSeek.Value )
      END TEXTBOX // txtSeek
            
      DEFINE CHECKBOX  chkSeek
         ROW    60
         COL    150
         CAPTION "  Soft Seek"
         VALUE  .F.
      END CHECKBOX // chkSeek
      
   END WINDOW // frmSeek
   
   CENTER   WINDOW frmSeek
   ACTIVATE WINDOW frmSeek
   
RETU // T_Seek()     
     
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC TC_Seek( cSeekExp, lSoft )           // Table Command : Seek
   IF "(" $ cSeekExp
      DBSEEK( &cSeekExp, lSoft )
   ELSE
      DBSEEK( cSeekExp, lSoft )
   ENDIF "(" $ cSeekExp
   frmSeek.release 
   RefrBrow() 
RETU // TC_Seek() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
