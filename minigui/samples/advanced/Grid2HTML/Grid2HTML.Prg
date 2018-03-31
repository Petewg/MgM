#include <hmg.ch>

function _grid2html( cGrid, cWindow, cHTMLFile, aHeaders )
   local i, j
   local nDecimals := Set( _SET_DECIMALS )
   local aec := ""
   local aItems := {}
   local printdata := {}
   local nTotalColumns := 0
   local nRows := 0
   local cFontName := 'Arial'
   local nFontSize := 12
   local aData := {}
   local aPrintData := {}
   local aColumnJustify := {}
   local aColumnWidths := {}
   local aColumnHeaders := {}
   local aColumnControls := {}
   local nTopMargin := 20.0
   local nBottomMargin := 20.0
   local nLeftMargin := 20.0
   local nRightMargin := 20.0 
   local aEditcontrols := {}
   local xRes := {}
   local aJustify := {}
   local nWidth := 0
   local cPrintData := ''
   local aLineData
   local cType
   local fHandle := 0
   local cHTML := ''
   local cHeader1 := ''
   local cHeader2 := ''
   local cHeader3 := ''
   local aFinalData := {}
   local cTimeString
   local nColumnCount

   default aHeaders := { '', '', '' }
   default cWindow := ""
   default cGrid := ""
   default cHTMLFile := ''

   do case
      case len( aHeaders ) == 3
         cHeader1 := aHeaders[ 1 ]
         cHeader2 := aHeaders[ 2 ]
         cHeader3 := aHeaders[ 3 ]
      case len( aHeaders ) == 2
         cHeader1 := aHeaders[ 1 ]
         cHeader2 := aHeaders[ 2 ]
      case len( aHeaders ) == 1
         cHeader1 := aHeaders[ 1 ]
   endcase

   if len( alltrim( cHTMLFile ) ) == 0
      cTimeString := time()
      cTimeString := hb_usubstr( cTimeString, 1, 2 ) + hb_usubstr( cTimeString, 4, 2 ) + hb_usubstr( cTimeString, 7, 2 )
      cHTMLFile   := iif( len( alltrim( cHTMLFile ) ) == 0, 'Report_' + dtos( date() ) + '_' + cTimeString  + '.html', cHTMLFile )
   endif

   nRows      := getproperty( cWindow, cGrid, "ITEMCOUNT" )
   if nRows == 0
      return nil
   endif

   cFontName  := iif( getproperty( cWindow, cGrid, 'FONTNAME' ) <> nil, getproperty( cWindow, cGrid, 'FONTNAME' ), cFontName )
   nFontSize  := iif( getproperty( cWindow, cGrid, 'FONTSIZE' ) <> nil, getproperty( cWindow, cGrid, 'FONTSIZE' ), nFontSize )
   nColumnCount := _GetColumnCount( cGrid, cWindow )
   for i := 1 to nColumnCount
      aadd( aColumnWidths,  getproperty( cWindow, cGrid, 'COLUMNWIDTH', i ) )
      aadd( aColumnJustify, _HTMLAlign( _GetColumnJustify( cGrid, cWindow, i ) ) )
      aadd( aColumnHeaders, _GetColumnHeader( cGrid, cWindow, i ) )
      aadd( aColumnControls, _GetColumnControl( cGrid, cWindow, i ) )
      nTotalColumns += aColumnWidths[ i ]
   next i
   nWidth := nTotalColumns
   FOR i := 1 TO nRows
      cPrintData := ''
      aLineData := getproperty( cWindow, cGrid, 'ITEM', i )
      asize( aPrintData, 0 )
      cType := ''
      FOR j := 1 TO nColumnCount
         cType := ValType( aLineData[ j ] )
         do case
            case cType == "N"
               if valtype( aColumnControls[ j ] ) == 'A'
                  if upper( aColumnControls[ j, 1 ] ) == 'COMBOBOX'
                     aItems := aColumnControls[ j, 2 ]
                     cPrintdata := aItems[ aLineData[ j ] ]
                  else   
                     cPrintdata := LTrim( Str( aLineData[ j ] ) )
                  endif   
               else      
                  cPrintdata := LTrim( Str( aLineData[ j ] ) )
               endif
            case cType == "D"
               cPrintdata := dtoc( aLineData[ j ] )
            case cType == "L"
               if valtype( aColumnControls[ j ] ) == 'A'
                  if upper( aColumnControls[ j, 1 ] ) == 'CHECKBOX'
                     cPrintdata := if( aLineData[ j ], aColumnControls[ j, 2 ], aColumnControls[ j, 3 ] )
                  else
                     cPrintdata := if( aLineData[ j ], "T", "F" )
                  endif
               else   
                  cPrintdata := if( aLineData[ j ], "T", "F" )
               endif   
            otherwise
               cPrintdata := aLineData[ j ]
         endcase
         aadd( aPrintData, cPrintData )
      NEXT j
      aadd( aFinalData, aclone( aPrintData ) )
   NEXT i

   if file( cHTMLFile )
      if .not. msgyesno( "File Exists! Are you sure to overwrite?", 'Report Writer' )
         return nil
      endif
   endif

   fHandle := fcreate( cHTMLFile )

   if fHandle < 0
      msgstop( "File "+ cHTMLFile + " could not be created!" )
      return nil
   endif

   cHTML := '<HTML>' + CRLF
   if len( cHeader1 ) > 0
      cHTML := cHTML + '<HEAD><TITLE>' + cHeader1 + '</TITLE></HEAD>' + CRLF
   endif
   cHTML := cHTML + '<STYLE>' + CRLF
   cHTML := cHTML + '.td1 { font-family:"' + cFontName + '", "Arial"; font-size:' + alltrim( str( nFontSize ) ) + 'pt; border-style:outset; border-width:0 }' + CRLF
   cHTML := cHTML + 'table { border-collapse: collapse }' + CRLF
   cHTML := cHTML + 'td, th { font-family:"' + cFontName + '", "Arial"; font-size:' + alltrim( str( nFontSize ) ) + 'pt; border-style:outset; border-width:1; padding: 2px }' + CRLF
   cHTML := cHTML + 'tr:hover {background-color: #f5f5f5}' + CRLF
   cHTML := cHTML + 'table-layout: fixed' + CRLF 
   cHTML := cHTML + '</STYLE>'
   cHTML := cHTML + '<BODY TOPMARGIN=' + alltrim( str( nTopMargin ) ) + ' LEFTMARGIN=' + alltrim( str( nLeftMargin ) ) + ' RIGHTMARGIN=' + alltrim( str( nRightMargin ) ) + ' BOTTOMMARGIN=' + alltrim( str( nBottomMargin ) ) + '>' + CRLF
   
   // report headers table   
   cHTML := cHTML + '<TABLE Width="' + alltrim( str( nWidth ) ) + '">' + CRLF
   if len( cHeader1 ) > 0
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=5><u>' + cHeader1 + '</u></font></TD></TR>' + CRLF
   endif
   if len( cHeader2 ) > 0
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=4>' + cHeader2 + '</font></TD></TR>' + CRLF
   endif
   if len( cHeader3 ) > 0
      cHTML := cHTML + '<TR><TD align="CENTER" class="TD1"><font size=4>' + cHeader3 + '</font></TD></TR>' + CRLF
   endif
   cHTML := cHTML + '</TABLE>' + CRLF
   
   // Main Table
   
   cHTML := cHTML + '<TABLE Width="' + alltrim( str( nWidth ) ) + '">' + CRLF
   // Column Headers
   cHTML := cHTML + '<TR>' + CRLF
   for i := 1 to nColumnCount
      if aColumnWidths[ i ] > 0
         cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aColumnWidths[ i ] ) ) + ' ALIGN="' + aColumnJustify[ i ] + '" border-width=0><B>' + aColumnHeaders[ i ] + '</B></TD>' + CRLF
      endif
   next i
   cHTML := cHTML + '</TR>' + CRLF
   
   // Now it is time for data
   
   for i := 1 to nRows
      aLineData := aFinalData[ i ]
      cHTML := cHTML + '<TR>' + CRLF
      for j := 1 to nColumnCount
         if aColumnWidths[ j ] > 0
            cHTML := cHTML + '<TD WIDTH=' + alltrim( str( aColumnWidths[ j ] ) ) + ' ALIGN="' + aColumnJustify[ j ] + '">' + aLineData[ j ] + '</TD>' + CRLF
         endif
      next i
      cHTML := cHTML + '</TR>' + CRLF
   next i         
   cHTML := cHTML + '</TABLE>' + CRLF
   cHTML := cHTML + '</HTML>' + CRLF
   fWrite( fHandle, cHTML )   
   if .not. fclose( fhandle )
      msgstop( 'Error in Saving the Report!', 'Report Writer' )
   endif   

return cHTMLFile

function _HTMLAlign( nAlign )
   default nAlign := 0
   do case
   case nAlign == 1 // right
      return 'RIGHT'
   case nAlign == 2 // Center    
      return 'CENTER'
   endcase
return 'LEFT'

function _GetColumnCount( ControlName , ParentForm )
   local i, ColumnCount

   i := GetControlIndex( ControlName , ParentForm )
   ColumnCount := Len( _HMG_aControlCaption [i] )

return ColumnCount

function _GetColumnHeader( ControlName , ParentForm , i )
   local idx

   idx := GetControlIndex( ControlName , ParentForm )

return _HMG_aControlCaption [idx][i]

function _GetColumnJustify( ControlName , ParentForm , i )
   local idx

   idx := GetControlIndex( ControlName , ParentForm )

return _HMG_aControlMiscData1 [idx] [3] [i]

function _GetColumnControl( ControlName , ParentForm , i )
   local idx

   idx := GetControlIndex( ControlName , ParentForm )

   if valtype(_HMG_aControlMiscData1 [idx] [13]) == 'A'
      return _HMG_aControlMiscData1 [idx] [13] [i]
   endif

return ''