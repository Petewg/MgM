/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * DATEPICKER & TIMEPICKER demo
 * (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl> 
*/

#include "minigui.ch"

Function Main
   SET DATE ANSI
   SET CENTURY ON
   SET NAVIGATION EXTENDED
   SET DELETED ON
   SET BROWSESYNC ON

   OPEN_TABLE()

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 490 HEIGHT 380 ;
      TITLE "MiniGUI DatePicker & TimePicker Demo" ;
      MAIN ;
      ON INIT {|| DoMethod('Form_1','Date_5','Refresh') , DoMethod('Form_1','Time_4','Refresh') , DoMethod('Form_1','Time_5','Refresh') } ;
      FONT "Arial" SIZE 10

   DEFINE MAIN MENU
   POPUP "Values"
   ITEM "Get value Time_1" ACTION MsgBox(Form_1.Time_1.Value)
   ITEM "Get value Time_2" ACTION MsgBox(Form_1.Time_2.Value)
   ITEM "Get value Time_3" ACTION MsgBox(Form_1.Time_3.Value)
   SEPARATOR
   ITEM "Get value Date_1" ACTION MsgBox(DTOC(Form_1.Date_1.Value))
   ITEM "Get value Date_2" ACTION MsgBox(DTOC(Form_1.Date_2.Value))
   SEPARATOR
   ITEM "Set value Time_1" ACTION {|| (Form_1.Time_1.Value:=TIME()) }
   ITEM "Set value Time_2 to NULL" ACTION {|| (Form_1.Time_2.Value:="")}
   ITEM "Set value Time_2 to TIME()" ACTION {|| (Form_1.Time_2.Value:=TIME())}
   END POPUP
   POPUP "Get Format"
   ITEM  "Get Format String Time_1 " ACTION MsgBox(Form_1.Time_1.FormatString)
   ITEM  "Get Format String Time_2 " ACTION MsgBox(Form_1.Time_2.FormatString)
   ITEM  "Get Format String Time_3 " ACTION MsgBox(Form_1.Time_3.FormatString)
   SEPARATOR
   ITEM "Get Format String Date_1 " ACTION MsgBox(Form_1.Date_1.FormatString)
   ITEM "Get Format String Date_2 " ACTION MsgBox(Form_1.Date_2.FormatString)
   END POPUP
   POPUP "Set Format"
   ITEM "Set Format String Time_1 to 'hh:MM'" ACTION  {|| (Form_1.Time_1.FormatString:='hh:MM')}
   ITEM "Set Format String Time_2 to default" ACTION  {|| (Form_1.Time_2.FormatString:='')}
   ITEM "Set Format String Time_3 to HH:mm:ss" ACTION {|| (Form_1.Time_3.FormatString:='HH:mm:ss')}
   SEPARATOR
   ITEM "Set Format Date_1 to default " ACTION {|| (Form_1.Date_1.FormatString:='')}
   ITEM "Set Format Date_2 to default" ACTION {|| (Form_1.Date_2.FormatString:='')}
   END POPUP
   POPUP "Enable/Disable"
   ITEM "Disable Date_1" ACTION {|| (Form_1.Date_1.Enabled:=.f.)}
   ITEM "Enable Date_1" ACTION {|| (Form_1.Date_1.Enabled:= .t.)}
   SEPARATOR
   ITEM "Disable Time_1" ACTION {|| (Form_1.Time_1.Enabled:=.f.)}
   ITEM "Enable Time_1" ACTION {|| (Form_1.Time_1.Enabled:= .t.)}
   END POPUP
   END MENU

      // altsyntax DATEPICKER
      DEFINE DATEPICKER Date_1
         ROW   10
         COL   10
         VALUE Date()
         TOOLTIP 'DatePicker Control Altsyntax'
         SHOWNONE .F.
         RIGHTALIGN .T.
         FONTCOLOR RED
         BACKCOLOR YELLOW
         TITLEBACKCOLOR BLACK
         TITLEFONTCOLOR YELLOW
         TRAILINGFONTCOLOR PURPLE
         DATEFORMAT "'Date 'dd.MM.yyy"
      END DATEPICKER

      @ 60,10 DATEPICKER Date_2 ;
      WIDTH 170;
      VALUE Date() ;
      TOOLTIP "DatePicker Control ShowNone Dateformat dd/MM/yyyy" ;
      SHOWNONE ;
      RIGHTALIGN ;
      DATEFORMAT "dd'.'MMMM' 'yyyy" 
      
      // altsyntax TIMEPICKER
      DEFINE TIMEPICKER Time_1
      ROW 230
      COL 10
      WIDTH 170
      TOOLTIP " Time_1 TimePicker Control ShowNone Altsyntax"
      SHOWNONE .t.
      VALUE "12:10:22"
      FONTBOLD  .t.
      TIMEFORMAT "'Time' HH:mm:ss"
      END TIMEPICKER

      @ 180,10 TIMEPICKER Time_2 ;
      WIDTH 80;
      TOOLTIP "Time_2 TimePicker Control ShowNone HH:mm" ;
      SHOWNONE ;
      TIMEFORMAT "HH:mm" ;
      VALUE "22:25"

      @ 130,10 TIMEPICKER Time_3 ;
      WIDTH 170;
      TOOLTIP " Time_3 TimePicker Control  " ;
      TIMEFORMAT "'Current Time 'HH:mm:ss"
      
      DEFINE TIMER Timer_1 ;
      INTERVAL 1000 ;
      ACTION {|| (Form_1.Time_3.Value := Time())}
      //

      @ 10,210 BROWSE Browse_1 WIDTH 260 HEIGHT 180 ;
               WORKAREA TEST ;
               HEADERS {"Date","TimeShort","TimeLong","Remarks"};
               WIDTHS {40,40,40,40};
               FIELDS { 'Test->Datev' , 'Test->Timev' , 'Test->Timev1' , 'Test->Remarks'} ;
               ON CHANGE {|| (  Form_1.Date_5.Refresh , Form_1.Time_4.Refresh , Form_1.Time_5.Refresh )} ;
               FONT "MS Sans serif" SIZE 09

      @ 210,210 DATEPICKER Date_5 ;
      WIDTH 180;
      TOOLTIP "Date_5 DatePicker Control ShowNone 'Date 'dd/MM/yyyy" ;
      FIELD test->Datev  ;
      DATEFORMAT "'Date 'dd/MM/yyyy" ;
      ON LOSTFOCUS {|| (This.Save,Form_1.Browse_1.Refresh) };
      ON CHANGE {|| (This.Save,Form_1.Browse_1.Refresh) }

      @ 250,210 TIMEPICKER Time_4 ;
      WIDTH 180;
      TOOLTIP "Time_4 TimePicker Control ShowNone HH:mm" ;
      SHOWNONE ;
      FIELD test->Timev  ;
      TIMEFORMAT "'Time Short' HH:mm " ;
      ON LOSTFOCUS {|| (This.Save,Form_1.Browse_1.Refresh) };
      ON CHANGE {|| (This.Save,Form_1.Browse_1.Refresh) }

      @ 290,210 TIMEPICKER Time_5 ;
      WIDTH 180;
      TOOLTIP "Time_5 TimePicker Control ShowNone HH:mm:ss" ;
      SHOWNONE ;
      FIELD test->Timev1  ;
      TIMEFORMAT "' Time Long 'HH:mm:ss" ;
      ON LOSTFOCUS {|| (This.Save,Form_1.Browse_1.Refresh) };
      ON CHANGE {|| (This.Save,Form_1.Browse_1.Refresh) }

   END WINDOW

   Form_1.Browse_1.ColumnsAutoFitH()
   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

Function OPEN_TABLE()
Local i

   If !FILE("test.dbf")
      DBTESTCREATE("test")
      USE TEST NEW EXCLUSIVE

      FOR i=1 to 10
         sele test
         APPEND BLANK
         test->Datev := date()+i
         test->Timev := TIME()
         test->Timev1 := TIME()
         test->Remarks := "remarks " + padl(i,2)
         COMMIT
         UNLOCK
      next i

      CLOSE test
   ENDIF

   USE TEST NEW EXCLUSIVE

Return NIL

Function DBTESTCREATE(ufile)
Local aDbf := {}

  AADD (aDbf,{"DATEV"      ,"D",  8,0})
  AADD (aDbf,{"TIMEV"      ,"C",  5,0})
  AADD (aDbf,{"TIMEV1"     ,"C",  8,0})
  AADD (aDbf,{"REMARKS"    ,"C", 20,0})
  dbcreate( ufile, aDbf, 'DBFNTX' )
  aDbf := {}

Return NIL