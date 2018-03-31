#include <hmg.ch>

function  _addGridToolBar( cGrid, cWindow )
local nRow := getproperty( cWindow, cGrid, 'ROW' )
local nCol := getproperty( cWindow, cGrid, 'COL' )
local nWidth := getproperty( cWindow, cGrid, 'WIDTH' )
local nHeight := getproperty( cWindow, cGrid, 'HEIGHT' )
local nButtonSize := 36
local nInterval := 8
local nToolBarRow := nRow + nHeight + nInterval
local nToolBarCol := nCol + nWidth - ( ( 3 * nButtonSize ) + ( nInterval * 2 ) )
local cSuffix := alltrim( str( random() ) )
local cPdf := 'pdf' + cSuffix
local cCsv := 'csv' + cSuffix
local cPrint := 'print' + cSuffix
local cName := cWindow

define button &cpdf
   parent &cWindow
   row nToolBarRow
   col nToolBarCol
   width nButtonSize
   height nButtonSize
   picture 'pdf'
   tooltip 'Export to PDF file'
   action _grid2pdf( cGrid, cWindow )
end button
define button &cCsv
   parent &cWindow
   row nToolBarRow
   col nToolBarCol + nButtonSize + nInterval 
   width nButtonSize
   height nButtonSize
   picture 'csv'
   tooltip 'Export to CSV file'
   action _grid2csv( cGrid, cWindow )
end button
define button &cPrint
   parent &cWindow
   row nToolBarRow
   col nToolBarCol + nButtonSize + nInterval + nButtonSize + nInterval
   width nButtonSize
   height nButtonSize
   picture 'print'
   tooltip 'Print this table'
   action _gridprint( cGrid, cWindow )
end button
return nil

function _grid2pdf( cGrid, cWindow )
   local cFileName := ''
   cFileName :=  PutFile ( { {"Portable Document Format (*.pdf)", "*.pdf" } } , "Export to PDF file" ,  , .f. ) 
   if len(alltrim(cFileName)) == 0
      return nil
   endif

   if at( ".pdf", lower( cFileName ) ) > 0
      if .not. right( lower( cFileName ), 4 ) == ".pdf"
         cFileName := cFileName + ".pdf"
      endif
   else
      cFileName := cFileName + ".pdf"
   endif

   if file( cFileName )
      if .not. msgyesno("Are you sure to overwrite?","Export to PDF file")
         return nil
      endif
   endif
   _gridpdf( cGrid, cWindow, cFileName, , , , , .f. )
return nil