/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  'Mini Agenda' is Open Source/Freeware HMG Demo / Sample.

  All bug reports and suggestions are welcome.

  Developed with MiniGUI  - Harbour Win32 GUI library (HMG),
  Compiled and Linked with Harbour Compiler and MinGW.

  Thanks to "Le Roy" Roberto Lopez.

  Copyright 2008-2010 © Bicahi Esgici <esgici @ gmail.com>

  History : 
            2010-6 : Changed : Nested definition of frmAbout converted to separate definition.
            2009-5 : Added : - Cell Navigation,
                             - Three way ( Natural, Ascending, Descending) sorting columns 
                             - Preserve current item after sort
                             - INPLACE Editing 
                             - Incremental Search
                             - .ini File for keeping record of last used data file
                             - Main and Context Menu :
                                File : New, Open, ReOpen, Close, Save, Save as, Print  
                                Rows : Append, Delete, Insert
            2008-  : First Release                                               

  Notes : 

   - Thanks to S. Rathinagiri for GridPrint

*/

#include "minigui.ch"
#include "gridprint.ch"

#define FFFDELIMITER ","   // Flat File Field Delimiter
#define c1Tab CHR(9)

MEMVAR aData     ,;
       aList     ,;
       aColOrder ,;
       nCurFRN   ,;
       cDefInFN  ,;
       cBegFoldr ,;
       cDataFNam

PROCEDURE Main()

    LOCAL   aHeaders  := {'Last Name','First Name','Phone'},;
            aImages   := { 'AscImg', 'DscImg' }

    PRIVATE aData     := {{'','','',1}},;
            aList     := {},;
            aColOrder := ARRAY( 4 ),;
            nCurFRN   := 0,;               // Current Physical Row Number
            cDefInFN  := "MAgenda.ini",;   // Default .ini File Name
            cBegFoldr := GetCurrentFolder(),;
            cDataFNam := ''
            
    AFILL( aColOrder, 0 )

    DEFINE WINDOW frmMiniAgenda ;
        AT 0,0 ;
        WIDTH 470 ;
        HEIGHT 414 ;
        TITLE 'Mini Agenda' ;
        MAIN ;
        ON INIT MA_Initialize() 
        
        DEFINE MAIN MENU
           
           DEFINE POPUP "&File" 
              MENUITEM "&New" +     c1Tab + "^N"  ACTION MA_FilOpers( 'N' )    // File\New     
              MENUITEM "&Open" +    c1Tab + "^O"  ACTION MA_FilOpers( 'O' )    // File\Open    
              MENUITEM "&ReOpen" +  c1Tab + "^R"  ACTION MA_FilOpers( 'R' )    // File\ReOpen  
              MENUITEM "&Close" +   c1Tab + "^C"  ACTION MA_FilOpers( 'C' )    // File\Close  
              SEPARATOR
              MENUITEM "&Save" +    c1Tab + "^S"  ACTION MA_FilOpers( 'S' )    // File\Save   
              MENUITEM "Save &as" + c1Tab + "^A"  ACTION MA_FilOpers( 'A' )    // File\Save As
              SEPARATOR
              MENUITEM "&Print" +   c1Tab + "^P"  ACTION MA_FilOpers( 'P' )    // File\Print  
              SEPARATOR
              MENUITEM "E&xit" +    c1Tab + "Esc" ACTION ThisWindow.Release    // File\Exit              
           END POPUP  // File 

           DEFINE POPUP "&Rows" 
              MENUITEM "Append" +   c1Tab + "Alt-A"  ACTION MA_RowOpers( 'A' )    // Row\Append
              MENUITEM "Delete" +   c1Tab + "^Del"   ACTION MA_RowOpers( 'D' )    // Row\Delete
              MENUITEM "Insert" +   c1Tab + "^Ins"   ACTION MA_RowOpers( 'I' )    // Row\Insert
           END POPUP  // Rows 

           POPUP "&?"
              MENUITEM "&About"  ACTION SayAbout()
           END POPUP // ?

        END MENU

	DEFINE CONTEXT MENU 
              MENUITEM "&New File" +     c1Tab + "^N"  ACTION MA_FilOpers( 'N' )    // File\New     
              MENUITEM "&Open File" +    c1Tab + "^O"  ACTION MA_FilOpers( 'O' )    // File\Open    
              MENUITEM "&ReOpen File" +  c1Tab + "^R"  ACTION MA_FilOpers( 'R' )    // File\ReOpen  
              MENUITEM "&Close File" +   c1Tab + "^C"  ACTION MA_FilOpers( 'C' )    // File\Close  
              SEPARATOR
              MENUITEM "&Save File" +    c1Tab + "^S"  ACTION MA_FilOpers( 'S' )    // File\Save   
              MENUITEM "Save &as File" + c1Tab + "^A"  ACTION MA_FilOpers( 'A' )    // File\Save As
              SEPARATOR
              MENUITEM "&Print File" +   c1Tab + "^P"  ACTION MA_FilOpers( 'P' )    // File\Print  
              SEPARATOR
              MENUITEM "Append Row" +   c1Tab + "Alt-A"  ACTION MA_RowOpers( 'A' )    // Row\Append
              MENUITEM "Delete Row" +   c1Tab + "^Del"   ACTION MA_RowOpers( 'D' )    // Row\Delete
              MENUITEM "Insert Row" +   c1Tab + "^Ins"   ACTION MA_RowOpers( 'I' )    // Row\Insert
              SEPARATOR
              MENUITEM "E&xit" +        c1Tab + "Esc"  ACTION ThisWindow.Release    // File\Exit              
	END MENU

        DEFINE GRID grdMAgenda
           ROW             10
           COL             10
           WIDTH           440
           HEIGHT          298
           HEADERS         aHeaders  
           WIDTHS          {150, 150, 118}
           ONCHANGE        MA_SetFRN()
           TOOLTIP         "Click Header for sort on this column"
           ONHEADCLICK     { { || MA_SortColumn( 1 ) }, { || MA_SortColumn( 2 ) }, { || MA_SortColumn( 3 ) } }
           HEADERIMAGES    aImages
           INPLACEEDIT     {}
           CELLNAVIGATION  .T.
           ALLOWEDIT       .T.
        END GRID  // grdMAgenda

        DEFINE TEXTBOX txbSrcC1
           ROW         310
           COL         10
           WIDTH       150
           HEIGHT      20
           ONCHANGE    MA_Search( 1, this.value )
           ONLOSTFOCUS this.value := ''
           TOOLTIP     "Search string for this column"
        END TEXTBOX // txbSrcC1   

        DEFINE TEXTBOX txbSrcC2
           ROW         310
           COL         162
           WIDTH       150
           HEIGHT      20
           ONCHANGE    MA_Search( 2, this.value )
           ONLOSTFOCUS this.value := ''
           TOOLTIP     "Search string for this column"
        END TEXTBOX // txbSrcC2   

        DEFINE TEXTBOX txbSrcC3
           ROW         310
           COL         314
           WIDTH       118
           HEIGHT      20
           ONCHANGE    MA_Search( 3, this.value )
           ONLOSTFOCUS this.value := ''
           TOOLTIP     "Search string for this column"
        END TEXTBOX // txbSrcC3   

        DEFINE STATUSBAR
           STATUSITEM "" WIDTH 300
           DATE
           CLOCK
        END STATUSBAR   

    END WINDOW // frmMiniAgenda

    frmMiniAgenda.Center

    frmMiniAgenda.Activate

RETURN // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_FillGrid()

   frmMiniAgenda.grdMAgenda.DeleteAllItems
   AEVAL( aData, { | a1 |  frmMiniAgenda.grdMAgenda.AddItem( { a1[ 1 ], a1[ 2 ], a1[ 3 ] } ) } )
   
RETURN // MA_FillGrid()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_SortColumn(;
                nColumnNo,; 
                nOrder )
                
  LOCAL aCurVal := frmMiniAgenda.grdMAgenda.Value
        
  LOCAL nCurRow /*:= aCurVal[ 1 ]*/,;
        nCurCol := aCurVal[ 2 ]
  
  LOCAL aImages := ARRAY(3),;
        lAscend
        
  DEFAULT nOrder := aColOrder[ nColumnNo ]  // 0: Natural, 1: Ascend, 2: Descend    
  
  MA_Grd2Data()
  
  nOrder := IF( nOrder < 2, nOrder + 1, 0 ) 
  
  aColOrder[ nColumnNo ] := nOrder
  
  AEVAL( aImages, { | x, i1 | aImages[ i1 ] := 0 } )
  
  IF nOrder < 1 
     ASORT( aData, , , { | x, y | x[ 4 ] < y[ 4 ] } )
  ELSE   
    lAscend := ( nOrder < 2 )
    IF lAscend
       ASORT( aData, , , { | x, y | UPPER( x[ nColumnNo ] ) < UPPER( y[ nColumnNo ] ) } )
    ELSE
       ASORT( aData, , , { | x, y | UPPER( y[ nColumnNo ] ) < UPPER( x[ nColumnNo ] ) } )
    ENDIF
    aImages[ nColumnNo ] := IF( lAscend, 1, 2 )
  ENDIF nOrder < 1 
    
  nCurRow := ASCAN( aData, { | a1 | a1[ 4 ] == nCurFRN } )
  
  MA_FillGrid()
    
  frmMiniAgenda.grdMAgenda.Value := { nCurRow, nCurCol }
     
  AEVAL( aImages, { | c1, i1 | frmMiniAgenda.grdMAgenda.HeaderImage( i1 ) := c1 } )

RETURN // MA_SortColumn()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_Grd2Data()

   LOCAL nRowNo :=  0,;
         a1Row
         
   MA_SetFRN()
   
   FOR nRowNo := 1 TO frmMiniAgenda.grdMAgenda.ItemCount
   
     a1Row := frmMiniAgenda.grdMAgenda.Item( nRowNo )
     
     AEVAL( a1Row, { | c1, i1 | aData[ nRowNo, i1 ] := c1 } )
       
   NEXT nInds 
      
RETURN // MA_Grd2Data()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROCEDURE MA_SetFRN()

   LOCAL aGrdValue := frmMiniAgenda.grdMAgenda.Value
   
   LOCAL nGrdRowNo := aGrdValue[ 1 ] /*,;
         nGrdColNo := aGrdValue[ 2 ] */

   nCurFRN := aData[ nGrdRowNo, 4 ]
      
RETURN // MA_SetFRN()
  
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_RowOpers(;                        // Mini Agenda Row Operations
                  cROper )                // Operation 
          
   LOCAL aGrdValue := frmMiniAgenda.grdMAgenda.Value
   
   LOCAL nGrdRowNo := aGrdValue[ 1 ],;
         nGrdColNo := aGrdValue[ 2 ],;
         nRowCount := LEN( aData ) 

   MA_Grd2Data()                              
   
   DO CASE
      CASE cROper == 'A'        // Row\Append
         AADD( aData, { '','','', ++nRowCount } )
         nGrdRowNo := nRowCount
      CASE cROper == 'D'        // Row\Delete
         IF nRowCount > 1
            ADEL( aData, nGrdRowNo )
            ASIZE( aData, --nRowCount )      
            AEVAL( aData, { | a1, i1 | aData[ i1, 4 ] := i1 } )  
         ELSE
            aData := { { '','','', 1 } }
         ENDIF   
         nGrdRowNo := MAX( nGrdRowNo - 1, 1 )
      CASE cROper == 'I'        // Row\Insert
         AEVAL( aData, { | a1, i1 | aData[ i1, 4 ] := IF( i1 < nGrdRowNo, i1, i1 + 1 ) } )
         ASIZE( aData, ++nRowCount )
         AINS( aData,  nGrdRowNo )
         aData[ nGrdRowNo ] := { '','','', nGrdRowNo }
   ENDCASE nOper             
   
   MA_FillGrid()
   frmMiniAgenda.grdMAgenda.Value := { nGrdRowNo, nGrdColNo }         
   MA_SetFRN()
   
RETURN // MA_RowOpers()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_Search( ;
                nColumNo,;
                cSStr )
                
   LOCAL nFound
   
   IF !EMPTY( cSStr )
      nFound := ASCAN( aData, { | a1 | UPPER( cSStr ) == UPPER( LEFT( a1[ nColumNo ], LEN( cSStr ) ) ) } )
      IF nFound < 1
         nFound := ASCAN( aData, { | a1 | UPPER( cSStr ) $ UPPER( a1[ nColumNo ] ) } )
      ENDIF
      IF nFound > 0
         frmMiniAgenda.grdMAgenda.Value := { nFound, nColumNo }               
      ENDIF nFound > 0
   ENDIF !EMPTY( cSStr )

RETURN // MA_Search()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_LoadItems()

   LOCAL a1Row  := {},;
         c1Line      ,;
         n1Line :=  0,; 
         oFile 
   
   IF !EMPTY( cDataFNam ) .AND. FILE( cDataFNam )
   
      cBegFoldr := IF( "\" $ cDataFNam, TOKEN( cDataFNam, "\" ), GetCurrentFolder() )
      
      oFile := TFileRead():New( cDataFNam )
      
      oFile:Open()
  
      IF oFile:Error()
         MsgStop( oFile:ErrorMsg( "FileRead: " ), "Data File Open Error" )
      ELSE
         aData     := {}
         WHILE oFile:MoreToRead()
            c1Line := oFile:ReadLine()                 
            IF !EMPTY( c1Line )
               a1Row  := HB_ATOKENS( c1Line, FFFDELIMITER ) 
               ASIZE( a1Row, 3 )
               AEVAL( a1Row, { | x1, i1 | a1Row[ i1 ] := IF( HB_ISNIL( x1 ), '', LTRIM( x1 ) ) } )
               AADD( a1Row, ++n1Line ) 
               AADD( aData, a1Row  )
            ENDIF !EMPTY( c1Line )
         ENDDO oFile:MoreToRead()
    
         oFile:Close()
         
         IF !EMPTY( aData )
            MEMOWRIT( cDefInFN, cDataFNam ) 
         ENDIF !EMPTY( aData )
                           
      ENDIF oFile:Error()
   ELSE
      cDataFNam := ''
      aData     := {{'','','',1}}
   ENDIF !EMPTY( cDataFNam ...
   
   FOR EACH a1Row IN aData
      AEVAL( a1Row, { | x1, i1 | IF( HB_ISNIL( x1 ), a1Row[ i1 ] := '', ) } )
   NEXT
          
   MA_FillGrid()
   
   frmMiniAgenda.grdMAgenda.Value := { 1, 1 }
   frmMiniAgenda.StatusBar.Item( 1 ) := cDataFNam 
     
RETURN // MA_LoadItems()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_Initialize()                      

   LOCAL cFrmName := ThisWindow.Name

   SET CENT ON
   SET DATE GERM
   
*  REQUEST HB_LANG_...
*  HB_LANGSELECT( ".." )      
                         
   ON KEY CONTROL+N      OF &cFrmName ACTION MA_FilOpers( 'N' )    // File\New
   ON KEY CONTROL+O      OF &cFrmName ACTION MA_FilOpers( 'O' )    // File\Open 
   ON KEY CONTROL+R      OF &cFrmName ACTION MA_FilOpers( 'R' )    // File\ReOpen 
   ON KEY CONTROL+C      OF &cFrmName ACTION MA_FilOpers( 'C' )    // File\Close
   ON KEY CONTROL+S      OF &cFrmName ACTION MA_FilOpers( 'S' )    // File\Save
   ON KEY CONTROL+A      OF &cFrmName ACTION MA_FilOpers( 'A' )    // File\Save As
   ON KEY CONTROL+P      OF &cFrmName ACTION MA_FilOpers( 'P' )    // File\Print
   ON KEY ALT+A          OF &cFrmName ACTION MA_RowOpers( 'A' )    // Row\Append
   ON KEY CONTROL+DELETE OF &cFrmName ACTION MA_RowOpers( 'D' )    // Row\Delete
   ON KEY CONTROL+INSERT OF &cFrmName ACTION MA_RowOpers( 'I' )    // Row\Insert
   ON KEY ESCAPE         OF &cFrmName ACTION ThisWindow.Release
   
   IF FILE( cDefInFN )
      cDataFNam := MEMOREAD( cDefInFN ) 
   ENDIF FILE( "MAgenda.ini" )
   
   MA_LoadItems()
   
RETURN // MA_Initialize() 
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_FileOpen()

   LOCAL cNDName             // New Data File Name

   IF !(EMPTY( cNDName := GetFile( { { "List Files", "*.lst" },;     // File Select Filters 
                                     { "Text Files", "*.txt" },; 
                                     { "Data Files", "*.dta" },;
                                     { "All Files",   "*.*"  } } ,;   
                                   "Open Agenda File" ,;             // Get_File Window Title
                                   cBegFoldr ,;                      // Beginning folder
                                   .F. ,;                            // Multiple Select
                                   .T. ) ) )                         // Change Folder right
      cDataFNam := cNDName                              
      MA_LoadItems()
   ENDIF

RETURN // MA_FileOpen()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_SaveData()

   LOCAL c1Line := '',;
         a1Row       ,;
         nDInds      ,;
         nFOfst := 0
         
   IF EMPTY( cDataFNam )
      cDataFNam := PutFile( { { "List Files", "*.lst" },;     // File Select Filters 
                              { "Text Files", "*.txt" },; 
                              { "Data Files", "*.dta" },;
                              { "All Files",   "*.*"  } } ,;   
                              "Save Agenda File :" ,;             // Get_File Window Title
                              cBegFoldr ,;                        // Beginning folder
                              .F. )                               // Change Folder right
   ENDIF EMPTY( cDataFNam )
   
      
   IF !EMPTY( cDataFNam )      
      STRFILE( c1Line, cDataFNam, .F. )      
      
      FOR nDInds := 1 TO LEN( aData )
         a1Row   := aData[ nDInds ]
         IF !EMPTY( a1Row[ 1 ] + a1Row[ 2 ] + a1Row[ 3 ] )
            c1Line  := ALLTRIM( a1Row[ 1 ] ) + FFFDELIMITER + ;
                       ALLTRIM( a1Row[ 2 ] ) + FFFDELIMITER + ;
                       ALLTRIM( a1Row[ 3 ] ) + CRLF       
            STRFILE( c1Line, cDataFNam , .T., nFOfst  )
            nFOfst += LEN( c1Line )
         ENDIF !EMPTY( ...
      NEXT nDInds
      frmMiniAgenda.StatusBar.Item( 1 ) := cDataFNam 
   ENDIF !EMPTY( cDataFNam )      
   
RETURN // MA_SaveData()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE MA_FilOpers(;                        // Mini Agenda File Operations
                  cFOper )                // Operation 
                  
   DO CASE
      CASE cFOper == 'N'        // File\New
         cDataFNam := ''
         MA_LoadItems()
      CASE cFOper == 'O'        // File\Open 
         MA_FileOpen()
      CASE cFOper == 'R'        // File\ReOpen
         MA_LoadItems() 
      CASE cFOper == 'C'        // File\Close
         cDataFNam := ''
         MA_LoadItems()
      CASE cFOper == 'S'        // File\Save
         MA_Grd2Data()                              
         MA_SaveData()
      CASE cFOper == 'A'        // File\Save As
         MA_Grd2Data()                              
         cDataFNam := ''
         MA_SaveData()
      CASE cFOper == 'P'        // File\Print
         PRINT GRID grdMAgenda OF frmMiniAgenda SHOWWINDOW
   ENDCASE nOper             
   
RETURN // MA_FilOpers()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SayAbout()

   LOCAL cAbFName := GetCurrentFolder() + "\MA_About.htm"

   IF !IsWindowDefined( frmAbout )

      DEFINE WINDOW frmAbout ;
         AT 0, 0 ;
         WIDTH  320 ;
         HEIGHT 304 ;
         MODAL ;
         NOSIZE ;
         NOCAPTION ;
         ON INIT ShowAbout( cAbFName )

         ON KEY ESCAPE ACTION frmAbout.Hide

         DEFINE FRAME freAbout
            ROW    0
            COL    0
            WIDTH  320
            HEIGHT 340
         END FRAME // freAbout

         DEFINE ACTIVEX acxAbout
            ROW    5
            COL    5
            WIDTH  310
            HEIGHT 280
            PROGID "shell.explorer.2"
         END ACTIVEX // acxAbout

         @ 285, 130 BUTTON btnAboClos ;
            CAPTION " Close (Esc)" ;
            WIDTH 75 ;
            HEIGHT 18 ;
            ACTION { || frmAbout.Hide } ;
            FONT "Verdana" ;
            SIZE 8 ;
            DEFAULT

      END WINDOW // frmAbout

      frmAbout.Center
      frmAbout.Activate

   ENDIF

   frmAbout.Show  

RETURN // SayAbout()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE ShowAbout( cAbFName )
Local oObject

   oObject := GetProperty( 'frmAbout', 'acxAbout', 'XObject' )
   oObject:Navigate( cAbFName )

RETURN // ShowAbout()

