/* 
   TSimpleDlg.prg
 */ 
 
#include "minigui.ch" 
#include "hbclass.ch" 
#include "TaskDlgs.ch" 


PROCEDURE main() 

   LOCAL oSimpleDialog := SimpleTaskDialog()

   WITH OBJECT oSimpleDialog
      :Title       := 'Simple TaskDialog'
      :Content     := 'A simple text only function of SimpleTaskDialog()'

      IF :Execute()
         ShowDialogResult( oSimpleDialog )
      ELSE
         IF :nResult == E_NOTIMPL // Not implemented
            MsgInfo( "Your's OS is " + OS() + CRLF + "TaskDialog() works only on Vista (or later version of Windows)", , , .F. )
         ELSEIF :nResult == E_INVALIDARG
            // Wow! Again?!
         ENDIF
      ENDIF
   ENDWITH

   RETURN

/*
*/ 
STATIC PROCEDURE ShowDialogResult( obj ) 

   LOCAL msg, msg1, msg2

   IF HB_ISOBJECT( obj ) .AND. obj:ClassName() == "TSIMPLETASKDIALOG"
      WITH OBJECT obj
         msg  := hb_StrFormat( "Button with ID %d was pressed on exit.", :nButtonResult )
         msg1 := hb_StrFormat( "SimpleDialog:lError == %s", If( :lError, ".T.", ".F." ) )
         msg2 := hb_StrFormat( "and SimpleDialog:nResult == %s", If( :nResult == 0, "S_OK", hb_nToS( :nResult ) ) )

         MsgInfo( msg + CRLF + CRLF + msg1 + CRLF + msg2, "MsgInfo", , .F. )

         // And now we can try emulate the MsgInfo(..) with TaskDialog() 

         WITH OBJECT TaskDialog()   // Yep, it's not so simple as SimpleTaskDialog() ;)
            :New( "TaskDialog", msg, msg1 + CRLF + msg2, Nil, Nil, TD_INFORMATION_ICON )
            :Flags := TDF_ALLOW_DIALOG_CANCELLATION
            /* Or
            :Title       := "TaskDialog"
            :Instruction := msg
            :Content     := msg1 + CRLF + msg2
            :MainIcon    := TD_INFORMATION_ICON
            :Flags       := TDF_ALLOW_DIALOG_CANCELLATION
            */
            :Execute()
         ENDWITH
      ENDWITH
   ENDIF

   RETURN
