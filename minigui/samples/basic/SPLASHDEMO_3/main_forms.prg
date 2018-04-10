/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * The idea of 2013 Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "minigui.ch"
#include "metrocolor.ch"

Declare Window Form_Main   // необходимо объявить / you must declare here

/////////////////////////////////////////////////////////////////////////
// Функция дорисовки главной формы задачи 
// Function additional drawings main task form
FUNCTION Addition_MainForms()    
     LOCAL cTitle

     cTitle := /*"Пример собранный из трех частей (модулей): запуск логотипа программы, проверка и главная форма программы." +*/ CRLF
     cTitle += "Example assembled from three parts (modules): Starting logo program, testing and show the main form of the program."

     Form_Main.Width  := 800   // задать новые размеры формы окна
     Form_Main.Height := 540   // set the new size of the form window

     Form_Main.Sizable   := .F.  // NOSIZE
     Form_Main.MaxButton := .F.  // NOMAXIMIZE

     Form_Main.BackColor := COLOR_DESKTOP_DARK_CYAN  // color of the form window

     // добавить объект на форму / add an object to a form
     DEFINE MAIN MENU OF Form_Main
        Popup 'File'
           Item 'Dummy' Action MsgInfo('Sample')
           Separator
           Item 'Exit' Action ReleaseAllWindows()
        End Popup
        Popup 'Setting'
           Item 'Dummy' Action MsgInfo('Sample')
        End Popup
        Popup 'Help'
           Item 'About' Action MsgInfo( MiniguiVersion() )
        End Popup
     END MENU

     // добавить объект на форму / add an object to a form
     @ 10,20 LABEL label_1 VALUE cTitle ;
       PARENT Form_Main ;
       WIDTH 760 HEIGHT 48 SIZE 10 ;
       FONTCOLOR WHITE TRANSPARENT CENTERALIGN

     // добавить объект на форму / add an object to a form
     DEFINE BUTTONEX ButtonEX_1
            PARENT Form_Main  
            ROW    130
            COL    310
            WIDTH  180
            HEIGHT 124
            CAPTION "Sample 1"
            ICON "iPiople"
            FONTSIZE 16
            VERTICAL .T.
            FONTCOLOR BLACK
            NOXPSTYLE  .T.
            BACKCOLOR YELLOW
     END BUTTONEX

     DEFINE BUTTONEX ButtonEX_2
            PARENT Form_Main  
            ROW    330
            COL    20
            WIDTH  180
            HEIGHT 124
            CAPTION "Sample 2"
            ICON "iMessage"
            FONTSIZE 16
            VERTICAL  .T.
            FONTBOLD  .T.
            FONTCOLOR M->aBtnColor
            NOXPSTYLE .T.
            BACKCOLOR COLOR_BUTTONE_ORANGE
     END BUTTONEX

     DEFINE BUTTONEX ButtonEX_3
            PARENT Form_Main  
            ROW    330
            COL    210
            WIDTH  180
            HEIGHT 124
            CAPTION "Sample 3"
            ICON "iMusic"
            FONTSIZE 16
            VERTICAL  .T.
            FONTBOLD  .T.
            FONTCOLOR M->aBtnColor
            NOXPSTYLE .T.
            BACKCOLOR COLOR_BUTTONE_BRIGHT_GREEN
     END BUTTONEX

     DEFINE BUTTONEX ButtonEX_4
            PARENT Form_Main  
            ROW    330
            COL    400
            WIDTH  180
            HEIGHT 124
            CAPTION "Sample 4"
            ICON "iAbout"
            FONTSIZE 16
            VERTICAL  .T.
            FONTBOLD  .T.
            FONTCOLOR M->aBtnColor
            NOXPSTYLE .T.
            BACKCOLOR COLOR_BUTTONE_PURPLE
     END BUTTONEX

     DEFINE BUTTONEX ButtonEX_5
            PARENT Form_Main  
            ROW    330
            COL    590
            WIDTH  180
            HEIGHT 124
            CAPTION "Exit"
            ICON "iExit"
            ACTION MyExit(.T.)
            FONTSIZE 14
            VERTICAL  .T.
            FONTBOLD  .T.
            FONTCOLOR M->aBtnColor
            NOXPSTYLE .T.
            BACKCOLOR COLOR_BUTTONE_RED
     END BUTTONEX

    DEFINE LISTBOX List_1
            PARENT Form_Main  
            ROW    70
            COL    140
            WIDTH  155
            HEIGHT 230
            ITEMS M->aDirFrom
            FONTSIZE 12
            FONTBOLD .T.
            FONTCOLOR RED
            BACKCOLOR COLOR_BUTTONE_BLUE_SKYPE
     END LISTBOX
 
     DEFINE LISTBOX List_2
            PARENT Form_Main  
            ROW    70
            COL    500
            WIDTH  155
            HEIGHT 230
            ITEMS M->aDirTo
            FONTSIZE 12
            FONTBOLD .T.
            FONTCOLOR BLUE
            BACKCOLOR COLOR_BUTTONE_BLUE_SKYPE
     END LISTBOX

   // центрируем главную форму / center the main form
   Form_Main.Center
   // показываем главную форму / show the main form
   Form_Main.Show

   RETURN NIL

///////////////////////////////////////////////////////////
// Функция инициализация данных на форме
// This function initializes the data on the form
FUNCTION MyInitForm()
   LOCAL aDim, nI, cPath := M->cPubMainFolder
 
   M->aDirFrom := {}
   aDim := Directory( cPath + "*.prg" )
   IF Len( aDim ) > 0
      FOR nI := 1 TO Len( aDim )
         AAdd( M->aDirFrom, aDim[ nI, 1 ] )
      NEXT
   
      Form_Main.List_1.DeleteAllItems()
      FOR nI:=1 TO Len(M->aDirFrom)
          Form_Main.List_1.AddItem(M->aDirFrom[nI])
      Next

   ENDIF

   M->aDirTo := {}
   aDim := Directory( cPath + "*.exe" )
   IF Len( aDim ) > 0
      FOR nI := 1 TO Len( aDim )
         AAdd( M->aDirTo, aDim[ nI, 1 ] )
      NEXT
   
      Form_Main.List_2.DeleteAllItems()
      FOR nI:=1 TO Len(M->aDirTo)
          Form_Main.List_2.AddItem(M->aDirTo[nI])
      Next

   ENDIF

   RETURN Nil
