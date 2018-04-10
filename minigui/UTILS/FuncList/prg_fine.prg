#include "MiniGUI.ch"
#include "Stock.ch"


#define STEP_INDENT         3                 // Indention step


Declare window wConsole


/*****
*
*       PRG_Fine( cFileInput, cFileOutput, nCaseFormat, aLangStrings )
*
*       Formatting program code
*
*/

Procedure PRG_Fine( cFileInput, cFileOutput, nCaseFormat, aLangStrings )
Local oFile        , ;
      cMsg         , ;
      nHandle      , ;
      cString      , ;
      aTokens      , ;
      nCounter := 1

// Open processed file

oFile := TFileRead() : New( cFileInput )

Begin Sequence

   oFile : Open()
   If oFile : Error()
      cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )
      cMsg += ( aLangStrings[ 19, 2 ] + ' ' + cFileInput + CRLF )
      SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )
      Do Events
      Break
   Endif

   If ( ( nHandle := FCreate( cFileOutput ) ) < 0 )
      cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )
      cMsg += ( aLangStrings[ 20, 2 ] + ' ' + cFileOutput + CRLF )
      SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )
      Do Events
      Break
   Endif

   // Write a title

   WriteHeader( nHandle, { ( 'Source: ' + cFileInput )                             , ;
                             ''                                                    , ; 
                           ( 'Generate by Stock ' + DtoC( Date() ) + ' ' + Time() )  ;
                         } )

   // Rowwise reading and processing

   cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )

   Do while oFile : MoreToRead()

      cString := oFile : ReadLine()

      // Process indicator tweaking: complementary show window DoMethod( 'wConsole', 'Show' )
      
      SetProperty( 'wConsole', 'edtConsole', 'Value', ( cMsg + ' - ' + LTrim( Str( nCounter ) ) ) )
      DoMethod( 'wConsole', 'Show' )
      Do Events
      nCounter ++

      // Empty strings and strings, starting with #define, #command, #translate,
      // #xcommand, #xtranslate write without changing
      
      If ( !Empty( cString )                                                 .and. ;
           !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#DEFI' ) .and. ;
           !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#COMM' ) .and. ;
           !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#XCOM' ) .and. ;
           !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#TRAN' ) .and. ;
           !( Upper( Left( LTrim( cString ), MINKEYWORD_LEN ) ) == '#XTRA' )       ;
         )

         // String to array
         
         cString := LTrim( cString )      
         aTokens := StrToArray( cString, ' ' )
         
         If !Empty( aTokens )
         
            // Separate by a such delimiters as
            // brackets, '!' (function name allocation),  
            // analyse and write
            
            aTokens := SeparateByChar( aTokens, '!' )
            aTokens := SeparateByChar( aTokens, '(' )
            aTokens := SeparateByChar( aTokens, ')' )
            
            Analysis( nHandle, aTokens, nCaseFormat )
            
         Endif

      Else
         WriteString( nHandle, cString )
         
      Endif

   Enddo
   
   // Close result file

   CloseFile( nHandle )

   oFile : Close()
   
End

cMsg += CRLF
SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )

Return

****** End of PRG_Fine ******


/******
*
*       SeparateByChar( aTokens, cBracket ) --> aResult
*
*       Separate a string by delimiter ( '(',  ')', ... )
*       The function StrToArray() is inefficient because
*       will lose the delimiters yoursselves
*
*/

Static Function SeparateByChar( aTokens, cBracket )
Local aResult := {}            , ;
      nLen    := Len( aTokens ), ;
      Cycle                    , ;
      cString                  , ;
      nPos

For Cycle := 1 to nLen

  cString := aTokens[ Cycle ]

  Do while !Empty( nPos := At( cBracket, cString ) )
     AAdd( aResult, Left( cString, ( nPos - 1 ) ) )
     AAdd( aResult, cBracket )
     cString := LTrim( Substr( cString, ( nPos + 1 ) ) )
  Enddo
  
  If !Empty( cString )
     AAdd( aResult, cString )
  Endif
  
Next

Return aResult

****** End of SeparateByChar ******


/******
*
*       ArrayToStr( aTokens ) --> cString
*
*       Array to string
*
*/

Static Function ArrayToStr( aTokens )
Local nLen    := Len( aTokens ), ;
      Cycle                    , ;
      cString := ''

For Cycle := 1 to nLen

  If !Empty( aTokens[ Cycle ] )
  
     aTokens[ Cycle ] := AllTrim( aTokens[ Cycle ] )
  
     If ( aTokens[ Cycle ] == '(' )
        cString := ( RTrim( cString ) + aTokens[ Cycle ] + ' ' )
        
     ElseIf ( Left( aTokens[ Cycle ], 1 ) == ')' )
  
        If ( Right( cString, 2 ) == '( ' )
           cString := ( RTrim( cString ) + aTokens[ Cycle ] + ' ' )
        Else
           cString += ( aTokens[ Cycle ] + ' ' )
        Endif

     ElseIf ( aTokens[ Cycle ] == '!' )
        cString := ( RTrim( cString ) + ' ' + aTokens[ Cycle ] )
     
     Else
        cString += ( aTokens[ Cycle ] + ' ' ) 
     Endif  

  Endif
  
Next

Return cString

****** End of ArrayToStr ******


/******
*
*       CloseFile( nHandle )
*
*       Close file (masking descriptor check)
*
*/

Static Procedure CloseFile( nHandle )

If ( nHandle > -1 )
   FClose( nHandle )
Endif

Return

****** End of CloseFile ******


/******
*
*       WriteHeader( nHandle, aStrings )
*
*       Write header
*
*/

Static Procedure WriteHeader( nHandle, aStrings )

WriteString( nHandle, '/******' )
WriteString( nHandle, '*'  )

AEval( aStrings, { | elem | WriteString( nHandle, ( '*  ' + elem ) ) } )

WriteString( nHandle, '*'  )
WriteString( nHandle, '*/' )
WriteString( nHandle, '' )

Return

****** End of WriteHeader ******


/******
*
*       WriteString( nHandle, cString )
*
*       Write string to result file
*
*/

Static Procedure WriteString( nHandle, cString )

If ( nHandle > -1 )

   FWrite( nHandle, ( cString + HB_OSNewLine() ) )

Endif

Return

****** End of WriteString ******


/******
*
*       Analysis( nHandle, aTokens, nCaseFormat )
*
*       The analysis of string array.
*
*       Analysis and data output conditions:
*       1) The key words are distinguish by first 5 symbol
*          (set in MINKEYWORD_LEN, uncorrect detection for some words
*          at smaller value, for example, Next replace with NextKey)
*       2) The initial indent is zero
*       3) The headers [Static] Procedure|Function and HB_FUNC set up zero indent 
*       4) The indent increase after If, Begin [Sequence], For, Do case|while,
*          Switch, Define (for MiniGUI), Class, Method. And for testing into
*          Do case|Switch indent increase doubly for allocation of branchings
*          Case|Otherwise 
*       5) The indent is decrease after End[if|do|case|class], Next
*       6) The indent is decrease for Case, Otherwise, Else[If] only for string,
*          contained these commands
*
*/

Static Procedure Analysis( nHandle, aTokens, nCaseFormat )
Static nIndent   := 0  , ;
       lIsWinAPI := .F., ;
       lContinue := .F., ;
       nAddon    := 0
Local cFirstWord       , ;
      cSecondWord      , ;
      cString          , ;
      nPreInc     := 0 , ;
      nPostInc    := 0

cFirstWord := Upper( AllTrim( Left( aTokens[ 1 ], MINKEYWORD_LEN ) ) )

If !lIsWinAPI

   // String with sequel

   cString := Right( ATail( aTokens ), 1 )

   If !lContinue

      // The command is not proceed to next string
   
      If ( cString == ';' )
      
         // Processed string have a sequel
       
         nAddon := ( Len( aTokens[ 1 ] ) + 1 )
         cString := FineSyntax( aTokens, nCaseFormat )
         WriteString( nHandle, ( Space( nIndent ) + cString ) )
         lContinue := .T.
         Return
       
      Else
         nAddon := 0
      
      Endif
    
   Else
   
      // String sequel

      lContinue := ( cString == ';' )
      cString := FineSyntax( aTokens, nCaseFormat )
      WriteString( nHandle, ( Space( nIndent + nAddon ) + cString ) )
      Return
   
   Endif

Endif

cString := ''

Do case

   Case ( ( cFirstWord == 'PROCE' ) .or. ;
          ( cFirstWord == 'FUNCT' ) .or. ;
          ( cFirstWord == 'HB_FU' ) .or. ;
          ( cFirstWord == '#PRAG' )      ;
        )

     // Start for procedure/function or Ñ-function section.
     // Create a comment block with the name before procedure,
     // indents are dumped.
     
     If !( cFirstWord == '#PRAG' )
        AEval( aTokens, { | elem | cString += ( ' ' + elem ) } )        
        WriteString( nHandle, '' )
        WriteHeader( nHandle, { cString } )
     Endif
           
     nIndent := nPreInc := 0
     
     // Indention setup fixed for HB_FUNC, HB_FUNC_STATIC. Herewith
     // marks the satrt of block Ñ-function (his formatting, change
     // the register of key words is not make).
     
     If ( ( cFirstWord == '#PRAG' ) .or. ;
          ( cFirstWord == 'HB_FU' )      ;
        )
        nPostInc  := STEP_INDENT
        lIsWinAPI := .T.
     Else
        nPostInc  := 0
        lIsWinAPI := .F.
     Endif
        
   Case ( cFirstWord == 'STATI' )
     cSecondWord := Upper( AllTrim( Left( aTokens[ 2 ], MINKEYWORD_LEN ) ) )
     
     If ( ( cSecondWord == 'PROCE' ) .or. ;
          ( cSecondWord == 'FUNCT' )      ;
        )
        
        // Start of procedure or function. Similar to previous,
        // but intended for definition of Static Procedure|Function
        
        AEval( aTokens, { | elem | cString += ( ' ' + elem ) }, 2 )        
        WriteString( nHandle, '' )
        WriteHeader( nHandle, { cString } )
           
        nIndent := nPreInc := nPostInc := 0
        
     Endif

   Case ( ( cFirstWord == 'IF'    ) .or. ;
          ( cFirstWord == 'BEGIN' ) .or. ;
          ( cFirstWord == 'FOR'   ) .or. ;
          ( cFirstWord == 'WHILE' ) .or. ;
          ( cFirstWord == 'DEFIN' ) .or. ;
          ( cFirstWord == 'CLASS' ) .or. ;
          ( cFirstWord == 'METHO' ) .or. ;
          ( cFirstWord == '#IFDE' ) .or. ;
          ( cFirstWord == '{'     )      ;
        )

     // Cycles, control structures. MiniGUI commands and
     // preprocessor instructions are determined supementally.
     
     nPreInc  := 0
     nPostInc := STEP_INDENT
     
   Case ( cFirstWord == 'DO' )
   
     cSecondWord := Upper( AllTrim( Left( aTokens[ 2 ], MINKEYWORD_LEN ) ) )

     // Cycle Do while and structure Do case
     
     If ( ( cSecondWord == 'CASE'  ) .or. ;
          ( cSecondWord == 'WHILE' )      ;
        )
        
        nPreInc := 0
        
        If ( cSecondWord == 'CASE' )
           nPostInc := ( STEP_INDENT * 2 )
        Else
           nPostInc := STEP_INDENT
        Endif

     Endif

   Case ( ( cFirstWord == 'ENDIF' ) .or. ;
          ( cFirstWord == 'ENDDO' ) .or. ;
          ( cFirstWord == 'NEXT'  ) .or. ;
          ( cFirstWord == 'ENDCA' ) .or. ;
          ( cFirstWord == 'END'   ) .or. ;
          ( cFirstWord == '#ENDI' ) .or. ;
          ( cFirstWord == '}'     )      ;
        )

     // Closure of cucles and control structures, preprocessor instructions.

     If !( cFirstWord == 'ENDCA' )          // Endcase   
        nPreInc  := ( -1 ) * STEP_INDENT
     Else
        nPreInc  := ( -2 ) * STEP_INDENT
     Endif
     
     nPostInc := 0
     
   Case ( ( cFirstWord == 'CASE'  ) .or. ;
          ( cFirstWord == 'OTHER' ) .or. ;
          ( cFirstWord == 'ELSE'  ) .or. ;
          ( cFirstWord == 'ELSEI' ) .or. ;
          ( cFirstWord == '#ELSE' )      ;
        )

     // Branchings variants.
     
     nPreInc  := ( -1 ) * STEP_INDENT
     nPostInc := STEP_INDENT

Endcase

nIndent += nPreInc

If !lIsWinAPI
   cString := FineSyntax( aTokens, nCaseFormat )
   
Else

   // Code, belonging HB_FUNC() and HB_FUNC_STATIC() is not check for
   // key words.

   cString := ArrayToStr( aTokens )
   
Endif

cString := ( Space( nIndent ) + cString )

nIndent += nPostInc

WriteString( nHandle, cString )

Return

****** End of Analysis ******


/******
*
*       FineSyntax( aTokens, nCaseFormat ) --> cString
*
*       Formation of output string, transformation of command abbreviations
*
*/

Static Function FineSyntax( aTokens, nCaseFormat )
Memvar aCommands, aPhrases
Local nLen    := Len( aTokens ), ;
      Cycle                    , ;
      cString                  , ;
      cPhrase                  , ;
      nPos

// Processing the array of words for current string, replacement with determined in list

For Cycle := 1 to nLen
  
  cString := Upper( aTokens[ Cycle ] )
  
  If ( Len( cString ) < MINKEYWORD_LEN )
     cString := PadR( cString, MINKEYWORD_LEN )
  Endif
  
  // Word search in the array (ignore MINKEYWORD_LEN constant).
  // Reason - try to avoid of the error replacement.
  
  If !Empty( nPos := AScan( aCommands, { | elem | Upper( Left( elem[ KEYWORD_LONG ], Len( cString ) ) ) == cString } ) )
  
     // The register change for the permited words only

     If !aCommands[ nPos, KEYWORD_FREEZE ]
     
        Do case
           Case ( nCaseFormat == KEYWORD_LOWER )
             aTokens[ Cycle ] := Lower( aCommands[ nPos, KEYWORD_LONG ] )
             
           Case ( nCaseFormat == KEYWORD_UPPER )
             aTokens[ Cycle ] := Upper( aCommands[ nPos, KEYWORD_LONG ] )
             
           Case ( nCaseFormat == KEYWORD_CAPITALIZE )
             aTokens[ Cycle ] := ( Upper( Left( aCommands[ nPos, KEYWORD_LONG ], 1 ) )    + ;
                                   Lower( Substr( aCommands[ nPos, KEYWORD_LONG ], 2  ) )   ;
                                 )
             
           Otherwise
             aTokens[ Cycle ] := aCommands[ nPos, KEYWORD_LONG ]
             
        Endcase
        
     Else
        aTokens[ Cycle ] := aCommands[ nPos, KEYWORD_LONG ]
     Endif
     
  Endif
  
Next

cString := ArrayToStr( aTokens )

// Phrases replacement. Processing for phrases with exact tracing (marked * in the list)

nLen := Len( aPhrases )

For Cycle := 1 to nLen

  If aPhrases[ Cycle, KEYWORD_FREEZE ]
     
     cPhrase := ( Upper( aPhrases[ Cycle, KEYWORD_LONG ] ) + ' ' )
     
     If !Empty( nPos := At( cPhrase, Upper( cString ) ) )
        cString := Stuff( cString, nPos, Len( cPhrase ), ( aPhrases[ Cycle, KEYWORD_LONG ] + ' ' ) )
     Endif
     
  Endif
      
Next

Return cString

****** End of FineSyntax ******
