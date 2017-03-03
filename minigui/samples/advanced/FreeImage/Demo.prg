/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Joint usage of FreeImage & SQLite3 demo
 * (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "Directry.ch"
#include "FreeImage.ch"
#include "HBSQLit3.ch"
#include "MiniGUI.ch"

#define DB_NAME            'PicBase.s3db'   // Working database

#define WM_PAINT	     15             // To force a redraw window

// The output area of the image is fixed
// The Coordinates Of The

#define FI_TOP                5
#define FI_LEFT             260
#define FI_BOTTOM           470
#define FI_RIGHT            765

// Dimensions

#define FI_WIDTH            ( FI_RIGHT - FI_LEFT )
#define FI_HEIGHT           ( FI_BOTTOM - FI_TOP )



Static lCreateBase := .T.   // Flag: automatically create a new database
Static aParams              // An array of operating parameters 


/******
*
*       Demonstration of images stored in the image file 
*       and SQLite database
*
*/

Procedure Main

aParams := { 'StartDir'  => GetCurrentFolder(), ;        // The current directory
             'pDB'       => nil               , ;        // Handle Base
             'ReadFiles' => .T.               , ;        // Read the list of files
             'SavePos'   => .F.               , ;        // Save the position in the file list
             'Reload'    => .T.                 ;        // Sign of the necessity to re-read the database
           }






			  
If Empty( aParams[ 'pDB' ] := OpenBase() )
   MsgStop( "Can't open/create " + DB_NAME, "Error" )
   Quit
Endif

FI_Initialise()          // Initialize the library FreeImage

Set font to 'Tahoma', 9

Define window wMain                   ;
       At 0, 0                        ;
       Width 780                      ;
       Height 525                     ;
       Title 'FreeImage & SQLite3 Usage Demo' ;
       NoMaximize                     ;
       NoSize                         ;
       Icon 'main.ico'                ;
       Main                           ;
       On Release FI_DeInitialise()   ;
       On Paint ShowMe()

   // ShowMe() - procedure for image output. In the description window it better
   // specify only the On paint. This will update the content
   // the main window is redrawn at every. Additional indication
   // On init ShowMe () causes a flickering window at startup.
   
   Define tab tbData ;
          at 5, 5    ;
          Width 250  ;
          Height 470 ;
          On Change SwitchTab()
          
      Page 'Files'
      
         @ 32, 5 Grid grdFiles   ;
                 Width 235       ;
                 Height 340      ;
                 Widths { 200 }  ;
                 NoHeaders       ;
                 On Change ShowMe()

         @ 385, 5 ButtonEx btnChDir       ;
                  Caption 'Change folder' ;
                  Width 235               ;
                  Picture 'DIR'           ;
                  Action ChangeFolder()

         @ 430, 5 ButtonEx btnAdd        ;
                  Caption 'Copy to base' ;
                  Width 235              ;
                  Picture 'COPY'         ;          
                  Action AddToBase()

      End Page
      
      Page 'Records'

        @ 32, 5 Grid grdRecords          ;
                Width 235                ;
                Height 340               ;
                Widths { 50, 180 }       ;
                Headers { 'ID', 'Name' } ;
                On Change ShowMe()      

         @ 385, 5 ButtonEx btnDelete      ;
                  Caption 'Delete record' ;
                  Width 235               ;
                  Picture 'DELETE'        ;
                  Action DelRecord()

         @ 430, 5 ButtonEx btnSave       ;
                  Caption 'Save to file' ;
                  Width 235              ;
                  Picture 'SAVE'         ;
                  Action SaveToFile()
      
      End Page    
      
   End Tab

   Define StatusBar
      StatusItem aParams[ 'StartDir' ]
      StatusItem 'Exit Alt+X' Width 70
   End StatusBar
             
End window

On Key Alt+X of wMain Action ReleaseAllWindows()

ListFiles()     // Fill in file list

Center window wMain
Activate window wMain

Return

****** End of Main ******


/*****
*
*       OpenBase() --> pHandleDB
*
*       Open/create DATABASE
*
*/

Static Function OpenBase
Local lExistDB  := File( DB_NAME )                     , ;
      pHandleDB := SQLite3_Open( DB_NAME, lCreateBase ), ;
      cCommand

If !Empty( pHandleDB )
   
   // When auto_vacuum = 0 after you are finished deleting data does not change the database file size.
	// Freed blocks are marked as "free" and can be reused
   // Subsequent operations to add new records.
   // To reduce file size, you must run Vacuum
   
   SQLite3_Exec( pHandleDB, 'PRAGMA auto_vacuum = 0' )

   If !lExistDB
      
      // Create table
    
      cCommand := 'Create table if not exists Picts( Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Image BLOB );'
      SQLite3_Exec( pHandleDB, cCommand )

   Endif
   
Endif

Return pHandleDB

****** End of OpenBase ******


/******
*
*      SwitchTab()
*
*      Processing switch between lists (file records)
*
*/

Static Procedure SwitchTab
Local nValue := wMain.tbData.Value

// Setting the active item

If ( nValue == 1 )
   ListFiles()
   wMain.grdFiles.SetFocus       // Tab files
   
ElseIf( nValue == 2 )

   ListRecords()
   wMain.grdRecords.SetFocus     // Tab recordings
   
Endif

RefreshMe()

Return

****** End of SwitchTab ******


/******
*
*       ListFiles()
*
*       Creating a list of image files
*
*/
    
Static Procedure ListFiles
Local nPos   := wMain.grdFiles.Value, ; 
      aFiles := {}

If aParams[ 'ReadFiles' ]
 
   // Of the FreeImage supported file types, use only part

   AEval( Directory( aParams[ 'StartDir' ] + '\*.jpg'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.jpeg' ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.png'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.gif'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.bmp'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.ico'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )

   wMain.grdFiles.DeleteAllItems

   If !Empty( aFiles )
   
      ASort( aFiles, { | x, y | x < y } )       // Sort list

      wMain.grdFiles.DisableUpdate              // Disable the grid update (applicable for a large number of image files in a folder

      AEval( aFiles, { | elem | wMain.grdFiles.AddItem( { elem } ) } )

      wMain.grdFiles.EnableUpdate               // Allow show the changes in the grid

      // When the list of current directory pointer position are
   
      If !aParams[ 'SavePos' ]    
         
         wMain.grdFiles.Value := 1
         wMain.grdFiles.SetFocus
         
         aParams[ 'SavePos' ] := .T.
   
      Else
      
         If ( nPos > 0 )
            wMain.grdFiles.Value := nPos
         Endif
               
      Endif
      
   Endif
   
   aParams[ 'ReadFiles' ] := .F.

Endif

Return

****** End of ListFiles ******


/******
*
*       ListRecords()
*       
*       Populating a table with existing records in the database
*
*/

Static Procedure ListRecords
Local aData, ;
      aItem

If aParams[ 'Reload' ]

   wMain.grdRecords.DeleteAllItems

   aData := Do_SQL_Query( 'Select Id, Name from Picts Order by Name;' )

   If !Empty( aData )
   
      For each aItem in aData
         // In a sample of only 2 fields: ID and name of the file
         wMain.grdRecords.AddItem( { aItem[ 1 ], aItem[ 2 ] } )
      Next
   
      wMain.grdRecords.Value := 1
   
   Endif

   // You must overhaul the list of entries in the database
   // A sign is installed during initialization or added and
   // delete records
   
   aParams[ 'Reload' ] := .F.
   
   If ( wMain.grdRecords.ItemCount > 0 )
      wMain.btnDelete.Enabled := .T.
   Else
      wMain.btnDelete.Enabled := .F.
   Endif
      
Endif

Return

****** End of ListRecords ******


/******
*
*       ChangeFolder()
*
*       Change the current directory
*
*/

Static Procedure ChangeFolder
Local cFolder := GetFolder( 'Select folder', aParams[ 'StartDir' ] )

If !Empty( cFolder )

   aParams[ 'StartDir'  ] := cFolder
   aParams[ 'ReadFiles' ] := .T.
   aParams[ 'SavePos'   ] := .F.
   
   ListFiles()
   
   wMain.StatusBar.Item( 1 ) := aParams[ 'StartDir' ]
   
   ShowMe()
   
Endif

Return

****** End of ChangeFolder ******


/******
*
*       ShowMe()
*
*       Image output
*
*/

Static Procedure ShowMe
Static nHandleImg
Local nTabValue := wMain.tbData.Value, ;
      nTop      := FI_TOP            , ;
      nLeft     := FI_LEFT           , ;
      nBottom   := FI_BOTTOM         , ;
      nRight    := FI_RIGHT          , ;
      nPos                           , ; 
      cFile                          , ;
      cImage                         , ;
      pps                            , ;
      hDC                            , ;
      nWidth                         , ;
      nHeight                        , ;
      cID                            , ;
      aData                          , ;
      nKoeff                         , ;
      nHandleClone

If !( nHandleImg == nil )
   
   FI_Unload( nHandleImg )
   
   // Displaying smaller images after the great results in 
   // overlapping images. So you need to clear the area by declaring
   // it "null and void".
   // Better handle not all Window , but only a part,
   // that shows the picture.
     
   // Fitting cleaning: when you move the window off the screen from image
   // are the artifacts.
   
   InvalidateRect( Application.Handle, 1, FI_LEFT, 0, ( wMain.Width - 1 ), ( wMain.Height - 15 ) )
      
   nHandleImg := nil
   
Endif

If ( nTabValue == 1 )
   nPos := wMain.grdFiles.Value
Else
   nPos := wMain.grdRecords.Value
Endif

If Empty( nPos )
   Return
Endif

   // The picture we get from different sources, depending on the current tab
   
   If ( nTabValue == 1 )
   
      // From a file
      
      If !File( cFile := aParams[ 'StartDir' ] + '\' + wMain.grdFiles.Item( nPos )[ 1 ] )
         Return
      Endif

      cImage := MemoRead( cFile )         // Loading into memory
      
  Else
  
     cID := wMain.grdRecords.Item( nPos )[ 1 ]
     aData := Do_SQL_Query( 'Select Image from Picts Where Id = ' + cId + ';' )

     If !Empty( aData )
        cImage := aData[ 1, 1 ]
     Else
        Return
     Endif
  
  Endif
   
If Empty( cImage )
   Return
Endif

// This upload a picture directly from a file
// nHandleImg := FI_Load( FI_GetFileType( cFile ), cFile, 0 )

// Figure a is loaded into memory and displays from there

nHandleImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cImage, Len( cImage ) ), cImage, 0 )

// The original size of the image

nWidth  := FI_GetWidth( nHandleImg )
nHeight := FI_GetHeight( nHandleImg )

// FreeImage will try to fit in a specified area of an image, but
// this distortion. Therefore, for large drawings look forward
// reduction factor (zoom).

// ! ATTENTION
// Change the aspect ratio and calculation of large images slow down the video image

If ( ( nHeight > FI_HEIGHT ) .or. ( nWidth > FI_WIDTH )  )

   // Display the coefficient on the excess amount.
   // The image is sized proportionally.
   
   If ( ( nHeight - FI_HEIGHT ) > ( nWidth - FI_WIDTH ) )
      
      // Excess of the height. The calculation is performed on the
      // parameter.
      
      nKoeff := ( FI_HEIGHT / nHeight )
   Else
      nKoeff := ( FI_WIDTH / nWidth )
   Endif
   
   nHeight := Round( ( nHeight * nKoeff ), 0 )
   nWidth  := Round( ( nWidth  * nKoeff ), 0 )
   
   nHandleClone := FI_Clone( nHandleImg )
   FI_Unload( nHandleImg )
   
   nHandleImg := FI_Rescale( nHandleClone, nWidth, nHeight, FILTER_BICUBIC )
   FI_Unload( nHandleClone )
   
Endif

// Positioning of the image. If the size is smaller than the specified region
// output figure is centered on this axis.

If ( nWidth < FI_WIDTH )
   nLeft  += Int( ( FI_WIDTH - nWidth ) / 2 )
   nRight := ( nLeft + nWidth )
Endif

If ( nHeight < FI_HEIGHT )
   nTop    += Int( ( FI_HEIGHT - nHeight ) / 2 )
   nBottom := ( nTop + nHeight )
Endif

// Image output

hDC := BeginPaint( Application.Handle, @pps )

FI_WinDraw( nHandleImg, hDC, nTop, nLeft, nBottom, nRight )

EndPaint( Application.Handle, pps )
ReleaseDC( Application.Handle, hDC )

Return

****** End of ShowMe ******


/******
*
*       RefreshMe()
*
*       Image redrawing
*
*/

Static Procedure RefreshMe
   
	DoEvents()

	SendMessage( _HMG_MainHandle, WM_PAINT, 0, 0 )

Return

****** End of RefreshMe ******


/******
*
*       Do_SQL_Query( cQuery ) --> aResult
*
*       Fetch
*
*/

Static Function Do_SQL_Query( cQuery )
Local pStatement := SQLite3_Prepare( aParams[ 'pDB' ], cQuery ), ;
      aResult    := {}                                         , ;
      aTmp                                                     , ;
      nColAmount                                               , ;
      Cycle                                                    , ;
      nType

If !Empty( pStatement )

   Do while ( SQlite3_Step( pStatement ) == SQLITE_ROW )
   
      If ( ( nColAmount := SQLite3_Column_Count( pStatement ) ) > 0 )
      
         aTmp := Array( nColAmount )
         AFill( aTmp, '' )
      
         For Cycle := 1 to nColAmount
            
            nType := SQLite3_Column_Type( pStatement, Cycle )
            
            Do case
               Case ( nType == SQLITE_NULL )
               Case ( nType == SQLITE_FLOAT )
               Case ( nType == SQLITE_INTEGER )
                  aTmp[ Cycle ] := LTrim( Str( SQLite3_Column_Int( pStatement, Cycle ) ) )
                  
               Case ( nType == SQLITE_TEXT )
                  aTmp[ Cycle ] := SQLite3_Column_Text( pStatement, Cycle )
                  
               Case ( nType == SQLITE_BLOB )
                  aTmp[ Cycle ] := SQLite3_Column_Blob( pStatement, Cycle )
                  
            Endcase
            
         Next
         
         AAdd( aResult, aTmp )
          
      Endif
      
   Enddo
   
   SQLite3_Finalize( pStatement )
   
Endif
                
Return aResult

****** End of Do_SQL_Query ******


/******
*
*       AddToBase()
*
*       To add a picture to a base
*
*/

Static Procedure AddToBase
Local nPos       := wMain.grdFiles.Value, ;
      cFile                             , ;
      cImage                            , ;
      pStatement

If !Empty( nPos )

   cFile := wMain.grdFiles.Item( nPos )[ 1 ]
   
   If !File( aParams[ 'StartDir' ] + '\' + cFile )
      Return
   Endif
   
Else
   Return
      
Endif

pStatement := SQLite3_Prepare( aParams[ 'pDB' ], 'Insert into Picts( Name, Image ) Values( :Name, :Image )' )

If !Empty( pStatement )
   
   cImage := SQLite3_File_to_buff( aParams[ 'StartDir' ] + '\' + cFile )

   If ( ( SQLite3_Bind_text( pStatement, 1, cFile   ) == SQLITE_OK ) .and. ;
        ( SQLite3_Bind_blob( pStatement, 2, @cImage ) == SQLITE_OK )       ;
      )
      
     If ( SQLite3_Step( pStatement ) == SQLITE_DONE )
        aParams[ 'Reload' ] := .T.
        MsgInfo( ( 'File' + CRLF + cFile + CRLF + 'is copied in a base.' ), ;
                 'Success', , .F., .F. )
     Endif 

   Endif

   SQLite3_Clear_bindings( pStatement )
   SQLite3_Finalize( pStatement )

Endif

wMain.grdFiles.SetFocus

Return

****** End of AddToBase ******


/******
*
*       DelRecord()
*
*       Delete a record from a database
*
*/

Static Procedure DelRecord
Local nPos     := wMain.grdRecords.Value, ;
      cID                               , ;
      cCommand                          , ;
      nCount

If !Empty( nPos )

  If MsgYesNo( 'Delete current record?', 'Confirm', .T., , .F., .F.  )

     cID := wMain.grdRecords.Item( nPos )[ 1 ]
     cCommand := ( 'Delete from Picts Where Id = ' + cId + ';' )

     If ( SQLite3_Exec( aParams[ 'pDB' ], cCommand ) == SQLITE_OK )

        // To reduce the file size of the DATABASE, you must execute the command
        // Vacuum. But when a large DATABASE this may take
        // some time.
        
        If ( SQLite3_exec( aParams[ 'pDB' ], 'Vacuum' ) == SQLITE_OK )
        
           // Re-read the list
     
           aParams[ 'Reload' ] := .T.
           ListRecords()

           // If possible, leave the pointer in the same position
     
           nCount := wMain.grdRecords.ItemCount
     
           nPos := Iif( ( nPos >= nCount ), nCount, nPos )
           wMain.grdRecords.Value := nPos

           RefreshMe()
           
        Endif
        
     Endif
     
  EndIf

Endif

wMain.grdRecords.SetFocus

Return

****** End of DelRecord ******


/******
*
*       SaveToFile()
*
*       To export an image from the DATABASE to a file
*
*/

Static Procedure SaveToFile
Local nPos       := wMain.grdRecords.Value, ;
      cID                                 , ;
      aData                               , ;
      cImage                              , ;
      cFile                               , ;
      cExt                                , ;
      nHandleImg                          , ;
      nFIF                                , ;
      nFormat                             , ;
      lSuccess

If !Empty( nPos )

   cID   := wMain.grdRecords.Item( nPos )[ 1 ]
   cFile := wMain.grdRecords.Item( nPos )[ 2 ]
   aData := Do_SQL_Query( 'Select Image from Picts Where Id = ' + cId + ';' )
   
   If Empty( aData )
      Return
   Endif

   cImage := aData[ 1, 1 ]

   // Because the file's extension to determine the new image format
   // When the save operation, you must explicitly specify the file extension
   // (the default is the current format)

   cFile := PutFile( { { 'JPG files', '*.jpg' }, { 'JPEG files', '*.jpeg' }, ; 
                       { 'PNG files', '*.png' }, { 'GIF files' , '*.gif'  }, ;
                       { 'BMP files', '*.bmp' }, { 'ICO files', '*.ico'   }  ;
                     }                                                     , ;
                     'Save image'                                          , ;
                     aParams[ 'StartDir' ]                                 , ;
                     .T.                                                   , ;
                     cFile                                                   ;
                   )
                   
   If Empty( cFile )
      Return
      
   Else
      If File( cFile )
         If !MsgYesNo( ( 'File' + CRLF + ;
                         cFile  + CRLF + ;
                         'already exist. Rewrite it?' ;
                       ), 'Confirm', .T., , .F., .F.  )
            Return
         Endif
      Endif
   
   Endif

   nHandleImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cImage, Len( cImage ) ), cImage, 0 )
   
   If Empty( nHandleImg )
      Return
   Endif

   // By file extension define an image identifier and
   // constant for the save operation
   
   HB_FNameSplit( cFile, , , @cExt )
   cExt := Lower( cExt )
   
   Do case
      Case ( cExt == '.png' )
        nFIF    := FIF_PNG            // Image ID for input/output
        nFormat := PNG_DEFAULT 

      Case ( cExt == '.gif' )
        nFIF    := FIF_GIF
        nFormat := GIF_DEFAULT 
         
      Case ( cExt == '.bmp' )
        nFIF    := BMP_DEFAULT
        nFormat := GIF_DEFAULT 

      Case ( cExt == '.ico' )
        nFIF    := FIF_ICO
        nFormat := ICO_DEFAULT 

      Otherwise
      
        // Default is JPG or JPEG
        nFIF    := FIF_JPEG
        nFormat := JPEG_DEFAULT 

   Endcase
 
   lSuccess := FI_Save( nFIF, nHandleImg, cFile, nFormat )
   
   If !lSuccess
      MsgStop( ( "Can't save a file" + HB_OSNewLine() + cFile ), 'Error', , .F., .F. )
   Endif
   
   FI_Unload( nHandleImg )

   // If the entry is successful, you should re-read the list of files.
   // Position of the pointer does not change (to simplify), although the list is
   // file-name and here you can memorize the current file and look for it
   // position in pereform and topic list.
   
   If lSuccess
      aParams[ 'ReadFiles' ] := .T.
   Endif
   
Endif

Return

****** End of SaveToFile ******

// FUNCTION FI_Unload( nHandleImg )
// RETURN NIL
