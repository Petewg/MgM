#include "minigui.ch"
#include "ide.ch"
#include "fileio.ch"
 
DECLARE WINDOW Hbmk2Win
*------------------------------------------------------------------------------*
FUNCTION ShowInfo( uMessage AS USUAL )
*------------------------------------------------------------------------------*
    LOCAL lHide                 AS LOGICAL
    LOCAL nLen                  AS NUMERIC
    LOCAL lOldCenterWindowStyle AS LOGICAL

    lHide := iif( Upper( ValType( uMessage ) ) == "L", ! uMessage, .F. )

    IF lHide
       IF IsWindowDefined( Hbmk2Win )
          Hbmk2Win.Hide
       ENDIF
       RETURN NIL
    ENDIF

    uMessage := iif( uMessage == NIL, "Processing! Please wait.", HB_ValToStr( uMessage ) )

    nLen     := Len( uMessage ) * 10

    IF !IsWindowDefined( Hbmk2Win )

       LOAD WINDOW Hbmk2WIn
       Hbmk2Win.MessageLabel.Value := uMessage

    ELSE

       Hbmk2Win.MessageLabel.Value := uMessage
       Hbmk2Win.Edit_1.Value := ""
       Hbmk2Win.Hide

    ENDIF

    CENTER WINDOW Hbmk2Win

    Hbmk2Win.Edit_1.Value := "Hbmk2 compilation started..."

    Hbmk2Win.Show

    RETURN NIL


********************************************************************************
Function Hbmk2Process( cCommand )
********************************************************************************
   LOCAL cOutErr
   LOCAL cOutStd

   LOCAL hProc
   LOCAL hOutStd
   LOCAL hOutErr
   LOCAL cDataRead
   LOCAL nLen
   LOCAL nExitCode

   cOutErr := cOutStd := ""

  // cCommand := "CMD.EXE /c " + cCommand

   hProc := hb_processOpen( cCommand, , @hOutStd, /*@hOutErr*/ @hOutStd , .t. )

   IF hProc != F_ERROR

      // cDataRead := Space( Int( Hbmk2Win.Edit_1.Width / 7.2 )+1 )

      cDataRead := Space( 1024 )

      /*NOTE!  below used Function FRead() must probably be replaced by PRead()
               but currently the PRead() is not available in harbour bundled with minigui.
               probably it would be in a newer MiniGUI release.
               -Pete : 26/03/2013
      */
      DO WHILE ( nLen := FRead( hOutStd, @cDataRead, hb_BLen( cDataRead ) ) ) > 0

         cOutStd += hb_BLeft( cDataRead, nLen )

        // MsgInfo(cOutStd, "cOutStd" )
        /*
         cDataRead := Space( 1024 )
         IF (nLen := FRead( hOutErr, @cDataRead, hb_BLen( cDataRead ) ) ) > 0
            cOutErr += hb_BLeft( cDataRead, nLen )
         ENDIF
        */
        // MsgInfo(cOutErr, "cOutErr" )

         // cOutErr += cDataRead
         // Hbmk2Win.Edit_1.Value := StrTran(/*cDataRead*/ cOutErr , hb_EoL(), hb_OSNewLine())
         
         IF !IsWindowDefined( Hbmk2Win )
            LOAD WINDOW Hbmk2WIn
         ENDIF  
         
         Hbmk2Win.Edit_1.Value := cOutStd + cOutErr
         /* actually cOutErr above is currently always empty,
            but since it's not harmful I put it here as reminder
            for possible future use if it is needed  -Pete 26/03/2013
         */
         Hbmk2Win.Edit_1.CaretPos := Len(Hbmk2Win.Edit_1.Value)

        ProcessMessages()

      ENDDO

      nExitCode := hb_processValue( hProc )

      FClose( hOutStd )
//      FClose( hOutErr )

      Hbmk2Win.Edit_1.Value :=  /*hb_OSNewLine() + "**** " + hb_OSNewLine() + cOutErr +*/ ;
                                hb_OSNewLine() + "**** " + hb_OSNewLine() + cOutStd + hb_OSNewLine()
      Hbmk2Win.Edit_1.CaretPos := Len(Hbmk2Win.Edit_1.Value)

      hb_processClose( hProc )

   ELSE

      nExitCode := -1

   ENDIF

   Hbmk2Win.Edit_1.Value := Hbmk2Win.Edit_1.Value + "****" + hb_OSNewLine() + ;
                            IF( nExitCode == 0, "Success!", "Failure!" + hb_OSNewLine() )
   Hbmk2Win.Edit_1.CaretPos := Len(Hbmk2Win.Edit_1.Value)

   MemoWrit( "_temp" , Hbmk2Win.Edit_1.Value )

   RETURN nExitCode
