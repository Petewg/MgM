/*

  MINIGUI - Harbour Win32 GUI library Demo/Sample
 
  Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
  
  <http://harbourminigui.googlepages.com>
  
  HexView is Freeware Hex Viewer for any file. 
  
  Using and distributing is totally free.

  All bug reports and suggestions are welcome.
    
  Developed under Harbour Compiler and 
  MINIGUI - Harbour Win32 GUI library (HMG),
  to intend a HMG User sample. 
  
  Thanks to "Le Roy" Roberto Lopez.
 
  Copyright 2006 - 2008 Bicahi Esgici <esgici@gmail.com>
 
  History :
  
           2006.02 : First Release
           2008.10 : Added "Go" and "Skip" commands
           
*/

#include <minigui.ch>

#define CRLF2 CRLF + CRLF
#define NTrim( n ) LTrim( TRAN( n,"999,999,999,999,999" ) )

MEMV cBegFoldr,;
     cTempFNam,;
     nFilSize,;
     aBrwHeds,;
     aBrwLens,;
     aBrwFlds,;
     aBrwROCs,;
     aTabStru,;
     lFSContnu

PROC Main()

   PUBL cBegFoldr := GetCurrentFolder(),;
        cTempFNam := '',;
        nFilSize  := 0,;
        aBrwHeds  := {},;    // Column Headers
        aBrwLens  := {},;    // Column Lengths ( in pixel )
        aBrwFlds  := {},;    // Field List
        aBrwROCs  := {},;    // Read-Only Columns  
        aTabStru  := {},;    // Table Structure 
        lFSContnu := .F.     // Find String Continue
          
   SET BROWSESYNC ON   
   SET DATE GERM
   SET CENT ON
    
   MakBrwArs()
    
   LOAD WINDOW HexVMain AS frmHVMain
   
   frmHVMain.mitClos.Enabled := .F. 
   
   frmHVMain.HexVwBrw.Hide
   frmHVMain.pbrPBar1.Hide 
      
   frmHVMain.CENTER
   frmHVMain.Activate

RETU // HexViewMain()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC ClosFile()
   CLOS DATA
   ERAS (cTempFNam)
   frmHVMain.mitClos.Enabled := .F.
   frmHVMain.HexVwBrw.Hide  
   frmHVMain.StatusBar.Item(1) := ''
   frmHVMain.StatusBar.Item(2) := ''
RETU // ClosFile()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC AFileSiz(;                        // Size of any given file
               cFFName )               // Full File Name

RETU DIRECTORY( cFFName ) [ 1 ] [ 2 ]  // AFileSiz()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC SayAbout()
   MsgInfo( PADC("Harbour MiniGUI Hex Viewer v.3.1", 50)  + CRLF2 + ;
            PADC("FREEWARE", 50)                          + CRLF2 + ; 
            PADC('Thanks to "Le Roy" Roberto Lopez ( HMG Builder )', 50) + CRLF2 + ;  
            PADC("<http://harbourminigui.googlepages.com>", 50 ) )
RETU // SayAbout()              

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC TmpFName( ;                               // Make a temp file name in given folder
                 cFolder,;                     // and build it in 0 length 
                 cExtns )   

   LOCA aTFiles := {},;
        cFSpec  := '',;
        cTFName := DTOC(DATE()) + TIME(),;
        cRVal   := '',;
        nHandle :=  0
   
   IF cExtns == NIL     
      cExtns := "tmp"
   ENDIF   
   
   cFSpec := cFolder + IF(RIGHT(cFolder,1) # "\", "\", "") + "*." + cExtns 
   
   aTFiles := DIRECTORY(cFSpec)  
   
    cTFName := RIGHT(STRTRAN(STRTRAN(STRTRAN(STRTRAN( cTFName, "/", ""),"-",""),".",""),":",""),8)

    cRVal := cFolder + IF(RIGHT(cFolder,1) # "\", "\", "") + cTFName + "." + cExtns
    
    WHILE FILE( cRVal )
       cTFName := STR(VAL(cTFName)+1,8)
       cRVal := cFolder + IF(RIGHT(cFolder,1) # "\", "\", "") + cTFName + "." + cExtns
    ENDDO
    
    nHandle := FCREATE( cRVal )
    
    FCLOSE( nHandle ) 

RETU cRVal // TmpFName() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC MakTable()

   LOCA cTempFold := GetTempFolder()
        
   cTempFNam := TmpFName( cTempFold )
                                                          
   DBCREATE( cTempFNam, aTabStru )
                                    
   USE (cTempFNam) ALIAS TEMP
   
   
RETU // MakTable()   
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC OpenFile()

   LOCA cOpFName := GetFile ( {{ "All Files", "*.*" }} ,;   // File Select Filter 
                                 "Open File" ,;             // Get File Window Title
                                 cBegFoldr ,;               // File Find Beginning folder
                                 .F. ,;                     // Multiple Select
                                 .T. )                      // Change Folder right
   LOCA cFileStr := '',;
        nFPntr   :=  0,;
        c1Line   :=  '',;
        nFldNum  :=  0
                                
   IF !EMPTY( cOpFName )
      
      nFilSize := AFileSiz( cOpFName ) 
      cFileStr := MEMOREAD( cOpFName )
      
      IF nFilSize - LEN( cFileStr ) > 1
         MsgExclamation( "Size Error ! " + CRLF + ;
                         NTrim(nFilSize)+"/"+NTrim(LEN( cFileStr )), "Error" )
      ELSE
        cBegFoldr := cOpFName
        ClosFile() 
        frmHVMain.StatusBar.Item(1) := IF( LEN( cOpFName ) > 70,;
                                           LEFT( cOpFName, 7 ) + '...' + RIGHT( cOpFName, 60 ),; 
                                           cOpFName ) 
        frmHVMain.StatusBar.Item(2) := PADC("0/"+NTrim(nFilSize),18)
        MakTable()
        frmHVMain.pbrPBar1.Show
            
            FOR nFPntr := 1 TO nFilSize STEP 16
               IF (nFPntr + 16 ) < nFilSize 
                    c1Line :=  SUBS( cFileStr, nFPntr, 16 )
               ELSE
                  c1Line :=  SUBS( cFileStr, nFPntr )
               ENDIF
               DBAPPEND()
               REPL     PT      WITH PADL(NTOC( nFPntr-1,16 ),8,'0'),;
                        ASCII   WITH c1Line
                FOR nFldNum  := 2 TO LEN( c1Line ) + 1
                    FIELDPUT( nFldNum, PADL(NTOC( ASC( SUBS( c1Line, nFldNum-1, 1 ) ), 16 ),2,"0") )
                NEXT nFldNum
                frmHVMain.pbrPBar1.Value := nFPntr * 100 / nFilSize
                DO EVENTS
            NEXT nFPntr
            
            frmHVMain.pbrPBar1.Hide
            frmHVMain.mitClos.Enabled := .T.
            
         DBGOTOP()
   
        frmHVMain.HexVwBrw.Refresh
        frmHVMain.HexVwBrw.Show

      ENDIF //nFilSize # LEN( cFileStr ) 
   ENDIF //!EMPTY( cOpFName )
     
RETU // OpenFile()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC MakBrwArs()

   LOCA nColNum := 0,;
        cFldNam := ''
   
   AADD( aTabStru, { "PT", "C",  8, 0 } )  // Hex Pointer
   AADD( aBrwHeds, '' )                      
   AADD( aBrwLens, 80 )                          
   AADD( aBrwFlds, 'PT' )                        
   AADD( aBrwROCs, .T. )                         
   
   FOR nColNum := 2 TO 17
      cFldNam := 'X' + PADL(NTOC(nColNum-2,16),1,'0')
      AADD(aTabStru, { cFldNam, 'C', 8, 0 } )   // Table Structure 
      AADD(aBrwHeds, '' )                       // Column Headers
      AADD(aBrwLens, 29 )                       // Column Lengths ( in pixel )
      AADD(aBrwFlds, cFldNam )                  // Field List
      AADD(aBrwROCs, .F. )                      // Read-Only Columns  
   NEXT nColNum
   
   AADD( aTabStru, { "ASCII",   "C",  16, 0 } ) // ASCII String
   AADD( aBrwHeds, '' )                                 
   AADD( aBrwLens, 145 )                                 
   AADD( aBrwFlds, 'ASCII' )                         
   AADD( aBrwROCs, .F. )                             
   
RETU // MakBrwArs()   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


FUNC GetOffset(; 
                 lSkip ) 

   LOCA nOffset := 0,;
        cOffset := InputBox( IF( lSkip, "Byte count to skip", "New Offset") + ;
                                        ' ( "0x" prefix for HEX values ) :',;
                             IF( lSkip, "Skip n bytes", "Go to offset" ) ),;
        lMinus  := .F. 
        
   IF !EMPTY( cOffset )
   
      cOffset := STRTRAN( cOffset, " ", "" )

      IF LEFT( cOffset, 1 ) == "-"   
         lMinus  := .T. 
         cOffset := SUBS( cOffset, 2 )
      ENDIF
          
      IF LEFT( UPPER( cOffset ), 2 ) == "0X"
         nOffset := CTON( SUBSTR( cOffset, 3 ), 16 ) 
      ELSE
         nOffset := VAL( cOffset )
      ENDIF
      
      IF lMinus
         nOffset := - nOffset
      ENDIF
         
   ENDIF !EMTPY( cOffset )

RETU nOffset // GetOffset()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GoOffset()

   LOCA nOffset := GetOffset( .F. ),;
        nRecNum := 0
   
   IF nOffset > 0
      nRecNum := INT(nOffset / 16 ) + 1
      nRecNum := MIN( MAX( 1, nRecNum ), RECC() )
      
      TEMP->( DBGOTO( nRecNum ) )
      
      frmHVMain.HexVwBrw.Value := RECN()
      
   ENDIF
      
RETU // GoOffset()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC SkipNBytes()

   LOCA nOffset := GetOffset( .T. ),;
        nRecNum := 0,;
        nRecNum1 := RECN() + INT( nOffset / 16 ) + 1,;
        nRecNum2 := MAX( 1, nRecNum1 )

   nRecNum  := MIN( nRecNum2 , RECC() )
   
   TEMP->( DBGOTO( nRecNum ) )
   
   frmHVMain.HexVwBrw.Value := RECN()

RETU // SkipNBytes()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FindString()
   LOAD WINDOW HexV_FS AS FS
   FS.CENTER
   FS.Activate
RETU // FindString()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC ApplyFS()

   LOCA cFindText  := ALLTRIM( FS.txtFS.Value ),;
        nDirection := FS.rgpDirect.Value ,;
        lExctMatch := FS.rgpMatch.Value < 2,;
        cHexString := '',;
        nHexStrLen :=  0,; 
        c1HexValue := '',;
        nHexStrPnt :=  0 
   
   LOCA nSkipValue := IF( nDirection < 2, -1, 1 ),;
        bSearch    := IF( lExctMatch, { || cFindText $ TEMP->ASCII }, { || UPPER( cFindText ) $ UPPER( TEMP->ASCII ) } )
   
   IF lFSContnu
      DBSKIP( nSkipValue )
   ENDIF
         
   IF UPPER( LEFT( cFindText, 2 ) ) == "0X"
   
      cHexString := SUBS( cFindText, 3 )
      nHexStrLen := LEN( cHexString )

      IF INT( nHexStrLen / 2 ) # nHexStrLen / 2
         cHexString := '0' + cHexString
         ++nHexStrLen
      ENDIF
      
      cFindText :=  ''
      
      FOR nHexStrPnt := 1 TO nHexStrLen STEP 2
         c1HexValue := SUBSTR( cHexString, nHexStrPnt, 2 )
         cFindText  += CHR( CTON( c1HexValue, 16 ) ) 
      NEXT  
      
   ENDIF   
   
   WHILE !EVAL( bSearch ) .AND. !EOF() .AND. !BOF()
      DBSKIP( nSkipValue )
   ENDDO   
   
   IF EOF() .OR. BOF()
      MsgInfo( IF( lFSContnu, "Further m" , 'M' ) + "atch not found." )
      IF EOF()
         DBGOBOTTOM()
      ELSE // BOF()
         DBGOTOP()
      ENDIF
   ENDIF   
   
   frmHVMain.HexVwBrw.Value := RECN()
   
   lFSContnu := .T.
          
RETU // ApplyFS()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FS_Init()
  FS.btnFNext.Enabled := .F.
  ON KEY ESCAPE OF FS ACTION FS.Release
RETU // FS_Init()  

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
