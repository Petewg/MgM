#xcommand DEFINE LBLTEXTBOX <name> ROW <nRow> COL <nCol> [ WIDTH <nW> ] CAPTION <cCaption> ;
      => ;
      CreateTextboxWithLabel( <(name)>, <nRow>, <nCol>, <cCaption>, <nW> )

#xcommand END LBLTEXTBOX =>;

#include "hmg.ch"

FUNCTION Main

   LOCAL nWidth  := 400 + GetBorderWidth() - iif( IsSeven(), 2, 0 )
   LOCAL nHeight := 170 + GetTitleHeight() + GetBorderHeight() - iif( IsSeven(), 2, 0 )

   IF ! _IsControlDefined( "DlgFont", "Main" )
      DEFINE FONT DlgFont FONTNAME "Segoe UI" SIZE 10
   ENDIF

   SET WINDOW MAIN OFF
   SET NAVIGATION EXTENDED

   DEFINE WINDOW MainForm ;
      AT 0, 0 WIDTH nWidth HEIGHT nHeight ;
      TITLE "Labeled TextBox Demo" ;
      MODAL ;
      NOSIZE ;
      FONT "Segoe UI" SIZE 10

      DEFINE LBLTEXTBOX Text_1 ;
         ROW 10 ;
         COL 135 ;
         WIDTH 250 ;
         CAPTION "Enter your name:"
      END LBLTEXTBOX
        
      DEFINE LBLTEXTBOX Text_2 ;
         ROW 40 ;
         COL 135 ;
         WIDTH 250 ;
         CAPTION "Enter your address:"
      END LBLTEXTBOX
        
      DEFINE LBLTEXTBOX Text_3 ;
         ROW 70 ;
         COL 135 ;
         WIDTH 250 ;
         CAPTION "Enter your city:"
      END LBLTEXTBOX
        
      DEFINE TEXTBOX Text_4
         ROW 100 
         COL 135 
         WIDTH 250 
         VALUE "textbox without 'caption'"
      END TEXTBOX
        
      DEFINE BUTTON Button_1
         ROW nHeight - GetTitleHeight() - GetBorderHeight() - iif(IsSeven(), 2, 0) - 35
         COL nWidth  - GetBorderWidth() - iif(IsSeven(), 2, 0) - 80
         WIDTH 70
         CAPTION "Close"
         ACTION ThisWindow.Release
      END BUTTON

   END WINDOW

   MainForm.Text_1.Value := "User Name"
   MainForm.Text_2.Value := "User Address"
   MainForm.Text_3.Value := "User City"
   MainForm.Text_1.SetFocus()

   MainForm.Center()
   MainForm.Activate()

RETURN NIL


STATIC FUNCTION CreateTextboxWithLabel( textboxname, nR, nC, cCaption, nW )

   LOCAL lbl :=  textboxname + "_Label"
   LOCAL hWnd := ThisWindow.Handle
   LOCAL hDC := GetDC( hWnd )
   LOCAL hDlgFont := GetFontHandle( "DlgFont" )
   LOCAL nLabelLen := GetTextWidth( hDC, cCaption, hDlgFont )

   hb_default( @nW, 120 )
   ReleaseDC( hWnd, hDC )

   DEFINE LABEL &( lbl )
      ROW nR
      COL nC - nLabelLen - GetBorderWidth()
      VALUE cCaption
      HEIGHT 24
      AUTOSIZE .T.
      VCENTERALIGN .T.
   END LABEL

   DEFINE TEXTBOX &( textboxname )
      ROW nR
      Col nC
      WIDTH nW
      HEIGHT 24
      //ONGOTFOCUS SetProperty( ThisWindow.Name, textboxname, "FontColor", BLACK )
      //ONLOSTFOCUS SetProperty( ThisWindow.Name, textboxname, "FontColor", GRAY )
   END TEXTBOX

RETURN NIL
