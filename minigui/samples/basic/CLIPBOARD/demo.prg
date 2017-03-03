/*
 * Harbour MiniGUI Clipboard Test
 * (c) 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Revised by Vladimir Chumachenko <ChVolodymyr@yandex.ru>
*/

#include "MiniGUI.ch"


#translate MSGINFO_( <cMessage>, <cTitle> )        ;
           =>                                      ;
           MsgInfo( <cMessage>, <cTitle>, , .F., .F. )


/*****
*
*   Set tests for:
*   - clipboard (get/store text, clear)
*   - Desktop size (width, height)
*   - location of system folders (Desktop, My documents, Program Files,
*     Windows, System32, Tmp)
*   - the name of the default printer
*
*/

Procedure Main

Define window wDemo                    ;
      At 0, 0                          ;
      Width 400                        ;
      Height 400                       ;
      Title 'Clipboard & Others Tests' ;
      Main                             ;
      NoMaximize                       ;
      NoSize

   Define tab tbTest ;
          At 5, 5    ;
          Width 380  ;
          Height 360 ;
          HotTrack
   
     Page 'Clipboard'  // Operations with Clipboard
     
       @ 35, 20 ButtonEx btnGetClip                                      ;
                Caption 'Get'                                            ;
                Width 50                                                 ;
                FontColor BROWN                                          ;
                Action MSGINFO_( System.Clipboard, 'Text in clipboard' ) ;
                Backcolor WHITE

       @ 35, 80 ButtonEx btnSetClip                             ;
                Caption 'Set'                                   ;
                Width 50                                        ;
                FontColor BROWN                                 ;
                Action System.Clipboard := 'Hello Clipboard!!!' ;
                Backcolor WHITE

       @ 35, 180 ButtonEx btnClearClip                                                       ;
                 Caption 'Clear'                                                             ;
                 Width 50                                                                    ;
                 FontColor RED                                                               ;
                 Action { || ClearClipboard(), MSGINFO_( 'Clipboard cleaned!', 'Warning' ) } ;
                 Backcolor WHITE

       @ 35, 280 ButtonEx btnTag    ;
                 Caption '{...}'    ;
                 Width 50           ;
                 FontColor BLUE     ;
                 Bold               ;
                 Action Bracketed() ;
                 Backcolor WHITE

       @ 75, 20 EditBox edtText ;
                Width 340       ;
                Height 260      ;
                Value 'Highlight the text in a word or more, and then click button "{...}"'  ;
                NoHScroll
     End Page

     Page 'Desktop'   // Desktop sizes
       
       @ 60, 110 ButtonEx btnWidth                                       ;
                 Caption 'Get Desktop Width'                             ;
                 Width 140                                               ;
                 Action MSGINFO_( System.DesktopWidth, 'Desktop width' ) ;
                 FontColor BROWN                                         ;
                 Backcolor WHITE

       @ 130, 110 ButtonEx btnHeight                                        ;
                  Caption 'Get Desktop Height'                              ;
                  Width 140                                                 ;
                  Action MSGINFO_( System.DesktopHeight, 'Desktop height' ) ;
                  FontColor BROWN                                           ;
                  Backcolor WHITE

     End Page

     Page 'System Folders'  // System Folders location

       @ 60, 95 ButtonEx btnDesktopPath                                    ;
                Caption 'Get Desktop Folder'                               ;
                Width 170                                                  ;
                Action MSGINFO_( System.DesktopFolder, 'Path to Desktop' ) ;
                FontColor BROWN                                            ;
                Backcolor WHITE

       @ 105, 95 ButtonEx btnMyDocPath                                               ;
                 Caption 'Get MyDocuments Folder'                                    ;
                 Width 170                                                           ;
                 Action MSGINFO_( System.MyDocumentsFolder, 'Path to My Documents' ) ;
                 FontColor BROWN                                                     ;
                 Backcolor WHITE

       @ 150, 95 ButtonEx btnProgPath                                                  ;
                 Caption 'Get Program Files Folder'                                    ;
                 Width 170                                                             ;
                 Action MSGINFO_( System.ProgramFilesFolder, 'Path to Program Files' ) ;
                 FontColor BROWN                                                       ;
                 Backcolor WHITE

       @ 195, 95 ButtonEx btnWinPath                                               ;
                 Caption 'Get Windows Folder'                                      ;
                 Width 170                                                         ;
                 Action MSGINFO_( System.WindowsFolder, 'Path to Windows folder' ) ;
                 FontColor BROWN                                                   ;
                 Backcolor WHITE

       @ 240, 95 ButtonEx btnSysPath                                               ;
                 Caption 'Get System Folder'                                       ;
                 Width 170                                                         ;
                 Action MSGINFO_( System.SystemFolder, 'Path to System32 folder' ) ;
                 FontColor BROWN                                                   ;
                 Backcolor WHITE

       @ 285, 95 ButtonEx btnTempPath                                        ;
                 Caption 'Get Temp Folder'                                   ;
                 Width 170                                                   ;
                 Action MSGINFO_( System.TempFolder, 'Path to Temp folder' ) ;
                 FontColor BROWN                                             ;
                 Backcolor WHITE

     End Page

     Page 'Printer'  // Show Default Printer

       @ 60, 110 ButtonEx btnDefPrinter                                         ;
                 Caption 'Get Default Printer'                                  ;
                 Width 140                                                      ;
                 Action MSGINFO_( System.DefaultPrinter, 'Printer by default' ) ;
                 FontColor BROWN                                                ;
                 Backcolor WHITE

     End Page

   End Tab
   
   On Key Escape Action ThisWindow.Release()
   
End window

Center window wDemo
Activate window wDemo

Return


/******
*
*       Bracketed()
*
*       Cut text and paste it in the brackets
*
*/

Static Procedure Bracketed
Local nHandle  := GetControlHandle( 'edtText', 'wDemo' ), ;
      cNewText                                          , ;
      cText

wDemo.edtText.SetFocus

ClearClipboard( Application.Handle )
Cut_Text( nHandle )

cText := AllTrim( System.Clipboard )
// OR
// cText := AllTrim( RetrieveTextFromClipboard() )
cNewText := ( '{' + cText + '}' )
If !Empty( cText )
   cNewText += ' '
Endif

CopyToClipboard( cNewText )
Paste_Text( nHandle )

Return


#pragma BEGINDUMP


#include <windows.h>
#include "hbapi.h"


/*

   Cut_Text( nHandle )
   Cut the selected text to clipboard from window
   
*/

HB_FUNC( CUT_TEXT )
{
   SetFocus( (HWND) hb_parnl( 1 ) );
   SendMessage( ( HWND ) hb_parnl( 1 ), WM_CUT, 0 , 0 );
}

/*

   Paste_Text( nHandle )
   Paste text from the clipboard into the window

*/

HB_FUNC( PASTE_TEXT )
{
   SetFocus( ( HWND ) hb_parnl( 1 ) );
   SendMessage( ( HWND ) hb_parnl( 1 ), WM_PASTE, 0 , 0 );
}


#pragma ENDDUMP
