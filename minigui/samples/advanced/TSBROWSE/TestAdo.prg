#include "MiniGui.ch"
#include "TSBrowse.ch"

#ifndef __XHARBOUR__           //V90
   #xcommand TRY              => BEGIN SEQUENCE WITH {|__o| break(__o) }
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
   #xcommand FINALLY          => ALWAYS
#endif

#ifndef __XHARBOUR__
   Static oConx, oRSet
#endif

//--------------------------------------------------------------------------------------------------------------------//

Function TestAdo(met)
   Local oBrw, Font_1

   Local cStr := "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + cFilePath( hb_argv( 0 ) ) + ;
                 "\Sbtest.mdb;User Id=admin;Password=;"
   LOCAL nWinWidth  := getdesktopwidth() * 0.8
   LOCAL nWinHeight := getdesktopheight() * 0.8
   LOCAL nBrwWidth := nWinWidth-30
   LOCAL nBrwHeight:= nWinHeight-60

   oConx := TOleAuto():new( "ADODB.connection" )
   oConx:ConnectionString := cStr
   oConx:Open()
   oRSet := TOleAuto():New( "ADODB.RecordSet" )

   With Object oRSet
      :CursorLocation   := adUseClient
      :CursorType       := adOpenDynamic
      :LockType         := adLockOptimistic
      :ActiveConnection := oConx
      :Source           := "SELECT * FROM CUSTOMER"
      :Open()
      :Sort             := :Fields( 0 ):Name
   End With

   IF ! _IsControlDefined ("Font_1","Main")
      DEFINE FONT Font_1  FONTNAME "Arial" SIZE 10
   endif

   IF Met == 0 .or. Met == 3 .or. Met == 4

         DEFINE WINDOW Child1 At 0,0 ;
         WIDTH nWinWidth HEIGHT nWinHeight ;
         TITLE   "ADO With TSBrowse - All Fields";
         ICON "Demo.ico";
         CHILD;
         ON INIT  oBrw:SetFocus()

      DO CASE
      CASE  Met == 0
         @  10,  10 TBROWSE oBrw RECORDSET oRSet  EDITABLE AUTOCOLS SELECTOR .T. ;
            WIDTH nBrwWidth HEIGHT nBrwHeight  ;
            FONT Font_1 ;
            COLORS CLR_BLACK, CLR_WHITE, CLR_BLACK, { CLR_WHITE, COLOR_GRID }, CLR_BLACK, -CLR_HRED  ;

      CASE  Met == 3
         @  10,  10 TBROWSE oBrw RECORDSET oRSet  EDITABLE AUTOCOLS SELECTOR .T. ;
            WIDTH nBrwWidth HEIGHT nBrwHeight  ;
            FONT Font_1 ;
            COLORS CLR_BLACK, CLR_WHITE, CLR_BLACK, { CLR_WHITE, COLOR_GRID }, CLR_BLACK, -CLR_HRED  ;
            AUTOSEARCH
      CASE  Met == 4
         @  10,  10 TBROWSE oBrw RECORDSET oRSet  EDITABLE AUTOCOLS SELECTOR .T. ;
            WIDTH nBrwWidth HEIGHT nBrwHeight  ;
            FONT Font_1 ;
            COLORS CLR_BLACK, CLR_WHITE, CLR_BLACK, { CLR_WHITE, COLOR_GRID }, CLR_BLACK, -CLR_HRED  ;
            AUTOFILTER
      ENDCASE

      oBrw:aColumns[ 1 ]:lEdit := .F.
      oBrw:nClrLine := COLOR_GRID

   ELSE
         DEFINE WINDOW Child1 At 0,0 ;
         WIDTH nWinWidth+8 HEIGHT nWinHeight ;
         TITLE   "ADO With TSBrowse - Selected Fields";
         ICON "Demo.ico";
         CHILD;
         ON INIT  oBrw:SetFocus()

         @  10,  10 TBROWSE oBrw RECORDSET oRSet EDITABLE AUTOCOLS FONT Font_1 SELECTOR .T. ;
            WIDTH nBrwWidth HEIGHT nBrwHeight  ;
            COLUMNS "First", "City", "State", "Married", "HireDate", "Age", "Salary" ;
            HEADERS "Apellido", "Ciudad", "Estado", "Casado", "Ingreso", "Edad", "Salario" ;
            SIZES 100, 120, 20, 25, 74, 25, 80 ;
            COLORS CLR_BLACK, CLR_WHITE, CLR_BLACK, { CLR_WHITE, COLOR_GRID }, CLR_BLACK, -CLR_HBLUE;


   oBrw:nClrLine := COLOR_GRID


endif
   END WINDOW
   ACTIVATE WINDOW Child1

   RELEASE FONT Font_1

Return Nil

//----------------------------------------------------------------------------//
/*
static function ConnectToAccess()

   local lConnect := .f.
   local cStr := "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + ;
            cFilePath( hb_argv( 0 ) ) + "xbrtest.mdb;User Id=admin;Password=;"

   oConx := TOleAuto():New("ADODB.Connection")
   oConx:ConnectionString := cStr

   TRY
      oConx:Open()
      lConnect := .T.
   CATCH
      oConx := Nil
      MsgInfo('Connect Fail')
      Return nil
   END

Return lConnect
*/

