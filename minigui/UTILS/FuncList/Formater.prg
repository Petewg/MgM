#include "MiniGUI.ch"
#include "Stock.ch"


// Processing range

#define FILE_CURRENT                 1             // Current file
#define FILE_ALL                     2             // All files


Declare window wStock


/******
*
*       Formater()
*
*       Start code formatting
*
*/

Procedure Formater
Memvar aOptions
Local lContinue := .F.                                                               , ;
      aStrings  := GetLangStrings( GET_FORMATTER_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      nRange    := FILE_CURRENT                                                      , ;
      nCharCase := KEYWORD_CAPITALIZE

Define window wReformat       ;
       At 132, 235            ;
       Width 280              ;
       Height 275             ;
       Title aStrings[ 1, 2 ] ;
       Icon 'STOCK'           ;
       Modal

   @ 5, 5 Frame frmFiles           ;
          Caption aStrings[ 2, 2 ] ;
          Width ( wReformat.Width - 20 ) ;
          Height 75                ;
          Bold                     ;
          Fontcolor BLUE

   @ ( wReformat.frmFiles.Row + 15 ), ( wReformat.frmFiles.Col + 10 ) ;
     RadioGroup rdgFiles                                              ;
     Options { aStrings[ 3, 2 ], aStrings[ 4, 2 ] }                   ;
     Value nRange                                                     ;
     Width ( wReformat.frmFiles.Width - 20 )

   @ ( wReformat.frmFiles.Row + wReformat.frmFiles.Height + 5 ), wReformat.frmFiles.Col ;
     Frame frmCase                  ;
     Caption aStrings[ 5, 2 ]       ;
     Width wReformat.frmFiles.Width ;
     Height 100                     ;
     Bold                           ;
     Fontcolor BLUE

   @ ( wReformat.frmCase.Row + 15 ), ( wReformat.frmCase.Col + 10 )   ;
     RadioGroup rdgCase                                               ;
     Options { aStrings[ 6, 2 ], aStrings[ 7, 2 ], aStrings[ 8, 2 ] } ;
     Width wReformat.rdgFiles.Width                                   ;
     Value nCharCase

   @ ( wReformat.frmCase.Row + wReformat.frmCase.Height + 20 ), ;
     ( wReformat.frmCase.Col + 15 )                             ;
     Button btnGoto                                             ;
     Caption aStrings[ 9, 2 ]                                   ;
     Action { || lContinue := .T.                    , ;
                 nRange := wReformat.rdgFiles.Value  , ;
                 nCharCase := wReformat.rdgCase.Value, ;
                 wReformat.Release                     ;
            } 

   @ wReformat.btnGoto.Row, ( wReformat.btnGoto.Col + wReformat.btnGoto.Width + 30 ) ;
     Button btnCancel                                                                ;
     Caption _HMG_MESSAGE[ 7 ]                                                       ;
     Action wReformat.Release 

   On key Escape of wReformat Action wReformat.Release
   On key Alt+X  of wReformat Action ReleaseAllWindows()
       
End Window

CenterInside( 'wStock', 'wReformat' )
Activate window wReformat

If lContinue
   
   // Formatting

   Define window wConsole       ;
        At 132, 235             ;
        Width 380               ;
        Height 350              ;
        Title aStrings[ 10, 2 ] ;
        Icon 'STOCK'            ;
        Modal                   ;
        On init Do_Format( nRange, nCharCase, aStrings )

     @ 5, 5 EditBox edtConsole              ;
            Height ( wConsole.Height - 90 ) ;
            Width ( wConsole.Width - 20 )   ;
            ReadOnly

    @ ( wConsole.edtConsole.Row + wConsole.edtConsole.Height + 15 ), ;
      ( wConsole.edtConsole.Col + 125 )                              ;
      Button btnOK                                                   ;
      Caption _HMG_MESSAGE[ 6 ]                                      ;
      Action wConsole.Release 
    
     On key Alt+X  of wConsole Action ReleaseAllWindows()

   End Window

   wConsole.btnOK.Enabled := .F.
  
   CenterInside( 'wStock', 'wConsole' )
   DisableCloseButton( GetFormHandle( 'wConsole' ) )
   Activate window wConsole
   
Endif

Return

****** End of Formater ******


/******
*
*       Do_Format( nRange, nCharCase, aLangStrings )
*
*       Start of processing
*
*/

Static Procedure Do_Format( nRange, nCharCase, aLangStrings )
Memvar aOptions, aCommands, aPhrases
Local cStartTime  := Time()                                                   , ;
      cFinishTime                                                             , ;
      cDir        := ( aOptions[ OPTIONS_GETPATH ] + '\' + APPTITLE + '.SRC' ), ;
      cFileInput                                                              , ;
      cFileOutput                                                             , ;
      nCount      := wStock.grdContent.ItemCount                              , ;
      Cycle

wConsole.edtConsole.SetFocus   
wConsole.edtConsole.Value := ( aLangStrings[ 11, 2 ] + ' ' + cStartTime + CRLF )
Do Events

// Folder for placing processed files

If !CheckPath( cDir, .T. )
   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + 'Error create ' + cDir )
   wConsole.btnOK.Enabled    := .T.
   Return   
Endif

// Load key words lists

Private aCommands := LoadKeywords( FILE_COMMANDS ), ;
        aPhrases  := LoadKeywords( FILE_PHRASES  )

wConsole.edtConsole.Value := ( wConsole.edtConsole.Value   + ;
                               Iif( !Empty( aCommands )    , ;
                                     aLangStrings[ 15, 2 ] , ;
                                     aLangStrings[ 16, 2 ]   ;
                                  )                        + ;
                                  CRLF                       ;
                             ) 
Do Events

wConsole.edtConsole.Value := ( wConsole.edtConsole.Value  + ;
                               Iif( !Empty( aPhrases )    , ;
                                    aLangStrings[ 17, 2 ] , ;
                                    aLangStrings[ 18, 2 ]   ;
                                  )                       + ;
                                  CRLF                      ;
                             ) 
Do Events

// Start of processing

If ( nRange == FILE_CURRENT )   // Current file

   cFileInput := CurrFileName()
   
   If IsPRG( cFileInput, aLangStrings )
   
      cFileOutput := ( cDir + '\' + cFileInput )
      cFileInput  := ( aOptions[ OPTIONS_GETPATH ] + '\' + cFileInput )
      PRG_Fine( cFileInput, cFileOutput, nCharCase, aLangStrings )
      
   Endif

Else
  
  // All files
  
  For Cycle := 1 to nCount
    
    cFileInput := RTrim( wStock.grdContent.Item( Cycle )[ 1 ] )
    
    If !Empty( Left( cFileInput, 1 ) )
       
       // Is it file?
       
       If IsPRG( cFileInput, aLangStrings )
         cFileOutput := ( cDir + '\' + cFileInput )
         cFileInput  := ( aOptions[ OPTIONS_GETPATH ] + '\' + cFileInput )
         PRG_Fine( cFileInput, cFileOutput, nCharCase, aLangStrings )
       Endif
       
    Endif
    
  Next
  
Endif

cFinishTime := Time()
wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + ;
                               aLangStrings[ 13, 2 ]     + ;
                               ' '                       + ;
                               cFinishTime + CRLF )
wConsole.edtConsole.Value := ( wConsole.edtConsole.Value           + ;
                               aLangStrings[ 14, 2 ]               + ;
                               ' '                                 + ;
                               ElapTime( cStartTime, cFinishTime ) + ;
                               CRLF                                  ;
                             )
wConsole.btnOK.Enabled := .T.
Do Events
 
Return

****** End of Do_Format ******


/******
*
*       LoadKeywords( cFile ) --> aWords
*
*       Load key words list
*
*/

Static Function LoadKeywords( cFile )
Local oFile   := TFileRead() : New( cFile ), ; 
      aWords  := {}                        , ;
      cString                              , ;
      aTmp

oFile : Open()

If !oFile : Error()

   Do while oFile : MoreToRead()
   
      // Ignore empty strings and strings, starting with ';' (COMMENT_CHAR)
      
      If !Empty( cString := oFile : ReadLine() )
         
         cString := AllTrim( cString )
         
         aTmp := Array( KEYWORD_ALEN )

         If !( Left( cString, 1 ) == COMMENT_CHAR )
            
            // Strings, starting with symbol '*' indicate, that necessary
            // to use the word/phrase at substitution without the register changing
            
            If ( Left( cString, 1 ) == '*' )
            
               cString := Substr( cString, 2 )
               
               aTmp[ KEYWORD_LONG   ] := cString
               aTmp[ KEYWORD_FREEZE ] := .T.
         
            Else
         
               aTmp[ KEYWORD_LONG   ] := cString
               aTmp[ KEYWORD_FREEZE ] := .F.

            Endif
            
            // If the short word (DO, for example), increase the length
            
            If ( Len( aTmp[ KEYWORD_LONG ] ) < MINKEYWORD_LEN )
               aTmp[ KEYWORD_LONG ] := PadR( aTmp[ KEYWORD_LONG ], MINKEYWORD_LEN )
            Endif
   
            AAdd( aWords, aTmp )
         
         Endif
         
      Endif
      
   Enddo
   
   oFile : Close()

   ASort( aWords,,, { | x, y | Upper(x[ 1 ] ) < Upper( y[ 1 ] ) } )
      
Endif

Return aWords

****** End of LoadKeywords ******


/******
*
*       IsPRG( cFile, aLangStrings ) --> lIsPRG
*
*       Check the file extension - processing for
*       the .PRG files only
*
*/

Static Function IsPRG( cFile, aLangStrings )
Local lIsPRG := ( Upper( Right( cFile, 4 ) ) == '.PRG' )

If !lIsPRG
   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + cFile + ' - ' + aLangStrings[ 13, 2 ] + CRLF )
Else
   wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + cFile )
Endif

Do Events

Return lIsPRG

****** End of lIsPRG ******
