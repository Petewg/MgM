/*
  with GAL edition (Alexey L. Gustow <gustow33 [dog] mail.ru>)
  2011.Oct.01-Nov.01
*/


#include "MiniGUI.ch"
#include "Stock.ch"

/// GAL added
#ifndef __XHARBOUR__
   #xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif
///

Declare window wStock

Memvar agugu, gugupath  // GAL

/******
*
*       CallsTable()
*
*       Manipulation table for procedures/functions
*
*/

Procedure CallsTable
Memvar aOptions
Local aLangStrings := GetLangStrings( GET_CALLSTABLE_LANG, aOptions[ OPTIONS_LANGFILE ] )

// GAL added (for export to HTML)
private agugu

Define window wConsole            ;
       At 132, 235                ;
       Width 380                  ;
       Height 390                 ;  /* was 350 */
       Title aLangStrings[ 1, 2 ] ;
       Icon 'STOCK'               ;
       Modal                      ;
       On init BuildList()

   @ 5, 5 EditBox edtConsole              ;
          Height ( wConsole.Height - 80 ) ;  /* was 40 */
          Width ( wConsole.Width - 20 )   ;
          ReadOnly

   // GAL added (with what .PRG we're working now?)
   @ wConsole.edtConsole.Row + wConsole.edtConsole.Height + 5, 5 ;
     Label guworkConsole ;
     Value "" ;
     Width ( wConsole.Width - 20 )

   @ wConsole.guworkConsole.Row + wConsole.guworkConsole.Height + 5, 5 ;
     ProgressBar guPbConsole ;
     Range 1, 100 ;
     Value 0 ;
     Width ( wConsole.Width - 20 ) ;
     Height 10
   // GAL

End Window

CenterInside( 'wStock', 'wConsole' )
DisableCloseButton( GetFormHandle( 'wConsole' ) )

Define window wCallsTable         ;
       At 132, 235                ;
       Width 500                  ;
       Height 380                 ;  /* was 350 */
       Title aLangStrings[ 1, 2 ] ;
       Icon 'STOCK'               ;
       Modal

   @ 5, 5 Grid grdList                                          ;
          Width 480                                             ;
          Height 310                                            ;
          Headers { aLangStrings[ 3, 2 ], aLangStrings[ 4, 2 ], ;
                    aLangStrings[ 5, 2 ], aLangStrings[ 6, 2 ]  ;
                  }                                             ;
          Widths { 130, 100, 130, 130 }                        ;
          Font 'Tahoma' Size 10

   // GAL added
   @ wCallsTable.grdList.Row + wCallsTable.grdList.Height + 5, 5 ;
     Button guExpAll ;
     Caption "Export To HTML (all)" ;
     Action ExpHTML( 0, aLangStrings ) ;
     Width 200

   @ wCallsTable.guExpAll.Row, ;
      wCallsTable.guExpAll.Col + wCallsTable.guExpAll.Width + 5 ;
     Button ExpNone ;
     Caption "Export To HTML (UNcalled only)" ;
     Action ExpHTML( 1, aLangStrings ) ;
     Width 200
   //

   On key Escape of wCallsTable Action wCallsTable.Release
   On key Alt+X  of wCallsTable Action ReleaseAllWindows()
       
End Window
CenterInside( 'wStock', 'wCallsTable' )

Activate window wConsole
Activate window wCallsTable

Return

****** End of CallsTable ******

/*****
*
*       BuildList()
*
*       Array of shared procedures/functions
*
*/

Static Procedure BuildList
Local nCount := wStock.grdContent.ItemCount, ;
      Cycle                                , ;
      cFile  := ''                         , ;
      cName                                , ;
      cType                                , ;
      aList  := {}

wCallsTable.grdList.DeleteAllItems
wCallsTable.grdList.DisableUpdate

For Cycle := 1 to nCount

    cName := RTrim( wStock.grdContent.Item( Cycle )[ 1 ] )
    cType := wStock.grdContent.Item( Cycle )[ 2 ]
    
    If !Empty( Left( cName, 1 ) )
       cFile := cName
    Endif

    /// GAL edition
    If ( ( Upper( cType ) == 'PROCEDURE' ) .or. ;
         ( Upper( cType ) == 'FUNCTION'  ) .or. ;
         ( Upper( cType ) == 'HB_FUNC'   ) .or. ;
         ( Upper( cType ) == 'STATIC  PROCEDURE' ) .or. ;
         ( Upper( cType ) == 'STATIC  FUNCTION'  ) .or. ;
         ( Upper( cType ) == 'STATIC  HB_FUNC'   )      ;
       )
    ///

       AAdd( aList, { LTrim( cName ), cType, cFile, '' } )
    Endif

Next

// Fill a list

aList := FillList( aList )

////
agugu := aList // GAL added (for export to HTML)
               // because after import "aList" to grid and "ColumnsAutoFit"
               // 4th element of grid is not empty (?? but visible as empty ??)
               // (when 4th element of "aList" is empty)
////

AEval( aList, { | elem | wCallsTable.grdList.AddItem( elem ) } )

wCallsTable.grdList.ColumnsAutoFit
wCallsTable.grdList.EnableUpdate

wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + 'Finished' + CRLF )
wConsole.Release

Return

****** End of BuildList ******


/******
*
*       FillList( aList ) --> aList
*
*       Fill a list
*
*/

Static Function FillList( aList )
Memvar aOptions
Local aFiles   := {}, ;
      aNewList := {}, ;
      aTmp          , ;
      nLen          , ;
      nLen1         , ;
      Cycle         , ;
      Cycle1        , ;
      oFile         , ;
      cString := '' , ;
      cMsg          , ;
      cName         , ;
      nPos

// GAL added
Local cType, lLongComment, guPos

// Sort by function & path

ASort( aList, , , { | x, y | Upper( x[ 3 ] + x[ 1 ] ) < Upper( y[ 3 ] + y[ 1 ] ) } )
aTmp := AClone( aList )

// Build list of all program files

nLen := Len( aList )

For Cycle := 1 to nLen

  If !( aList[ Cycle, 3 ] == cString )
     cString := aList[ Cycle, 3 ]
     AAdd( aFiles, cString )
  Endif
  
Next

// Functions search

nLen  := Len( aFiles )
nLen1 := Len( aList )

For Cycle := 1 to nLen

   oFile := TFileRead() : New( aOptions[ OPTIONS_GETPATH ] + '\' + aFiles[ Cycle ] )
   
   oFile : Open()
   If !oFile : Error()

      // Check proceedures/functions entry
      // for each string of program file

      wConsole.edtConsole.Value := ( wConsole.edtConsole.Value + aFiles[ Cycle ] )

      // GAL added (indicate working process - what .PRG we proceed now?)
      wConsole.guworkConsole.Value := "Processing file: " + aFiles[ Cycle ]
      wConsole.guPbConsole.Value := int( 100 * Cycle / nLen )
      //

      cMsg := GetProperty( 'wConsole', 'edtConsole', 'Value' )
      
      lLongComment := .F.   // GAL added (to skip a long comment)

      guPos := 0    // GAL added

      Do while oFile : MoreToRead()
      
         cString := oFile : ReadLine()

         SetProperty( 'wConsole', 'edtConsole', 'Value', ( cMsg + ' - ' + LTrim( Str( guPos ) ) ) )
         // GAL added
         wConsole.guworkConsole.Value := "Processing file: " + aFiles[ Cycle ] + ' - ' + LTrim( Str( guPos ) )
         //
         DoMethod( 'wConsole', 'Show' )
         Do Events
         guPos ++

         //// GAL added (find end of long MULTI-line comment "*/")
         If lLongComment
           If ( "*/" $ cString )
             lLongComment := .F.
             cString := Iif( At( cString, "*/" ) < Len( cString ), ;
                             Substr( cString, At( cString, "*/" ) + 2 ), "" )
           Endif
           If Empty( cString )
             Loop
           Endif
         Endif

         //// GAL added (skip comments - WHY IT WASN'T USED BEFORE ???)

         // delete leading (and ending) spaces and tabs
         cString := strtran( cString, Chr( 9 ), " " )   // tabs to spaces

         If ( "//" $ cString )         // skip endind comments
           cString := iif( At( "//", cString ) > 1, ;
                           Left( cString, At( "//", cString ) - 1 ), "" )
         Endif

         cString := AllTrim( cString )
         Do while ( "  " $ cString )
           cString := Strtran( cString, "  ", " " )
         Enddo

         // skip comments
         If Left( cString, 1 ) == "*"
           Loop
         Endif

         If Left( cString, 2 ) == "//"
           Loop
         Endif

         // skip "/*" - "*/" comments
         If Left( cString, 2 ) == "/*"
           If ( "*/" $ cString )      // if "/* .... */" into one line
             Loop
           Endif
           lLongComment := .T.
           Loop
         Endif
         ////

         // GAL 20111101 - skip while lLongComment = . T.
         If lLongComment
           Loop
         Endif

         // GAL added
         cString := AllTrim( cString )
         If Empty( cString )
           Loop
         Endif
         //
         
         For Cycle1 := 1 to nLen1

           // Search is not make in files with determined function

           //// GAL - if STATIC, don't look to other files (only to own)
           If !( Upper( aList[ Cycle1, 3 ] ) == Upper( aFiles[ Cycle ] ) ) ;
              .and. ( Upper( Left( aList [ Cycle1, 2 ], 6 ) ) == "STATIC" )
              Loop
           Endif
           ////

           cName := Upper( aList[ Cycle1, 1 ] )

           // GAL 20111101 - don't analyze func/proc header lines
           If ( ;
               ( Upper( Left( cString,  9 ) ) == "FUNCTION " ) .or. ;
               ( Upper( Left( cString, 16 ) ) == "STATIC FUNCTION " ) .or. ;
               ( Upper( Left( cString, 10 ) ) == "PROCEDURE " ) .or. ;
               ( Upper( Left( cString, 17 ) ) == "STATIC PROCEDURE " ) .or. ;
               ( Upper( Left( cString,  7 ) ) == "HB_FUNC" ) .or. ;
               ( Upper( Left( cString, 14 ) ) == "STATIC HB_FUNC" ) ;
              )

              Loop

           Endif

           //// GAL edition (to skip func/proc definition)
           If ( ( ( cName + '(' ) $ Upper( cString ) ) .or. ;
                ( ( cName + ' (' ) $ Upper( cString ) ) .or. ;
                ( ( Upper( Left( cString, 8 ) ) == "SET KEY " ) .and. ;
                  ( Upper( Right( cString, Len( cName ) + 4 ) ) == " TO " + cName) ) ;
              )

              If !Empty( nPos := AScan( aTmp, { | elem | Upper( elem[ 1 ] ) == cName } ) )

                 If Empty( aTmp[ nPos, 4 ] )
                    aTmp[ nPos, 4 ] := aFiles[ Cycle ]
                 Else
                    aTmp := ASize( aTmp, ( Len( aTmp ) + 1 ) )
                    AIns( aTmp, ( nPos + 1 ) )
                    aTmp[ nPos + 1 ] := { '', '', '', aFiles[ Cycle ] }
                 Endif
              
              Endif
           
           Endif

         Next
         
      Enddo

      oFile : Close()

      cMsg += CRLF
      SetProperty( 'wConsole', 'edtConsole', 'Value', cMsg )
      // GAL added
      wConsole.guworkConsole.Value := ""
      //
     
   Endif
   
Next

// Table compacting

nLen := Len( aTmp )

//// GAL added (for last func/proc name - if we have 2 or more calls from one file)
cType := {}
////

For Cycle := 1 to nLen

  //// GAL added
  If !( Empty( aTmp[ Cycle, 1 ] ) )
     cType := { aTmp[ Cycle, 4 ] }
  Endif
  ////

  If ( Cycle == 1 )
     AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
  Else

     /*
     If !( Upper( aTmp[ Cycle, 4 ] ) == Upper( ATail( aNewList )[ 4 ] ) )
        AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
     Endif
     */

     //// GAL edition (if _next_ func called from the same file as _previous_)

     If ( Empty( aTmp[ Cycle, 1 ] ) )
        If ( Ascan( cType, aTmp[ Cycle, 4 ] ) == 0 )
           Aadd( cType, aTmp[ Cycle, 4 ] )
           AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
        Else
        Endif
     Else
        AAdd( aNewList, { aTmp[ Cycle, 1 ], aTmp[ Cycle, 2 ], aTmp[ Cycle, 3 ], aTmp[ Cycle, 4 ] } )
     Endif

  Endif
  
Next

Return aNewList

****** End of FillList ******

/*+*+*+*
*
*       ExpHTML()    by GAL
*
*       Export of shared procedures/functions to HTML
*       parameters: gupar = 0 - all, = 1 - UNcalled only
*                   guheads = "aLangStrings" array from "CallsTable" procedure
*
*+*+*+*/

Static Function ExpHTML( gupar, guheads )

Local ii, filehtml

if gupar<0 .or. gupar>1
  MsgStop( "Bad parameter! gupar=" + ltrim(str(gupar)) + ". Must be 0 or 1." )
  Return Nil
endif

if wCallsTable.grdList.ItemCount = 0
  MsgStop( "Empty list of function calls..." )
  Return Nil
endif

//// gugupath = path where sources is
if gupar=0
 filehtml := gugupath + "\Func_Calls_All.html"
else
 filehtml := gugupath + "\Func_Calls_UnCalled.html"
endif

set alter to &(filehtml)
set alter on

? "<HTML>" + CRLF + ;
  "<HEAD>" + CRLF + ;
  iif( guHeads[ 5, 2 ] == "Определена", ;  // for Russian
   '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">' + CRLF, ;
   "" )
? "<TITLE>List of Function Calls (" + ;
  iif( gupar=0, "all", "UNcalled only" ) + ")</TITLE>" + CRLF + ;
  "</HEAD>" + CRLF
? "<BODY>" + CRLF
? "<center>Project folder: <b>" + gugupath + "</b></center>" + CRLF
? "<H2><center>" + ;
  "List of Function Calls (" + ;
  iif( gupar=0, "all", "UNcalled only" ) + ")</center></H2>" + CRLF
? "<center>" + CRLF + "<table width=90% border=1 cellspacing=0>" + CRLF
? "<tr><th>" + guHeads[ 5, 2 ] + "</th>" + ;            // "Defined"
      "<th>" + guHeads[ 3, 2 ] + "</th>" + ;            // "Name"
      "<th>" + guHeads[ 4, 2 ] + "</th>" + ;            // "Type"
      "<th>" + guHeads[ 6, 2 ] + "</th></tr>" + CRLF    // "Called from"

for ii := 1 to len( agugu )
  if gupar=1    // UNcalled only
    if .not.empty( agugu[ ii, 4 ] )
      loop
    endif
  endif

  //// 20101013 - if .PRG is the same as in previous,
  ////            print '- " -' in 1st column ("Defined")
  ? "<tr>" + CRLF + ;
    "<td>" + iif( empty( agugu[ ii, 3 ] ), "&nbsp;", ;
      iif( ii>1, ;
        iif( agugu[ ii, 3 ] == agugu[ ii-1, 3 ], '&nbsp;- " - ', agugu[ ii, 3 ] ), ;
        agugu[ ii, 3 ] ) ;
      ) + "</td>" + CRLF + ;
    "<td>" + iif( empty( agugu[ ii, 1 ] ), "&nbsp;", agugu[ ii, 1 ] ) + "</td>" + CRLF + ;
    "<td>" + iif( empty( agugu[ ii, 2 ] ), "&nbsp;", agugu[ ii, 2 ] ) + "</td>" + CRLF + ;
    "<td>" + iif( empty( agugu[ ii, 4 ] ), "&nbsp;", agugu[ ii, 4 ] ) + "</td>" + CRLF + ;
    "</tr>" + CRLF

next ii

? "</table></center>" + CRLF + ;
  "</BODY>" + CRLF + "</HTML>" + CRLF
?

set alter off
set alter to

MsgInfo( "Export " + iif( gupar=0, "(all)", "(UNcalled only)" ) + ;
         " to" + CRLF + filehtml + CRLF + "is over!" )

// run browser

// GAL - it must be write better!! (_NEW_ browser window - not uses now!)
ShellExecute( 0, "open", "rundll32.exe", "url.dll,FileProtocolHandler " + filehtml, , 1 )

Return Nil

*+*+*+* End of ExpHTML *+*+*+*
