#include "MiniGUI.ch"
#include "WinPrint.ch"
#include "DbStruct.ch"
#include "Modest.ch"

// Paper size of format À4 at RowCol in HBPrinter
// MaxRow = 68
// MaxCol = 131
 
// Print margins

#define SH_TOP_MARGIN              1           // Top margin
#define SH_FIRST_LINE              1           // 1st row
#define SH_FIRST_COL               5           // Left margin
#define SH_PAGE_NUM               15           // Page numbering

// Print condition of next page

#define PAGE_FULL                 ( nLine > ( HBPRNMAXROW - SH_TOP_MARGIN - 2 ) )

// Quantity of symbols at printing at 1st row of general description of database
// and field's comments

#define DESCR_CHAR_COUNT          90
#define COMMENT_CHAR_COUNT        40


Memvar nLine, nPage                            // Counters of printed rows and pages


Declare window wModest


/******
*
*       PrintStructure()
*
*       Print of structure
*
*/

Procedure PrintStructure
Memvar aStat, oEditStru
Local Cycle, ;
      nLen

Private nLine := SH_FIRST_LINE, ;        // Counter of printed rows
        nPage := 1                       // Counter of pages

// If field name is absent in the first row when it means that
// the field's array is empty. The printing is not execute.
 
If Empty( oEditStru : aArray[ 1, DBS_NAME ] )
   Return
Endif

// Print system initialization and printer selection
// Warning! The all changes of printing parameters
// in this dialog are ignored.

Init PrintSys
Select by dialog

If !Empty( HBPRNError )
   Return
Endif

// Own settings for paper size and orientation

Set PaperSize DMPAPER_A4                                   // Page format A4
Set orientation PORTRAIT                                   // Page orientation is portrait
Set print margins Top SH_TOP_MARGIN Left SH_FIRST_COL      // Page margins

// Preview parameters

Set Preview on          // Preview is ON
Set Thumbnails on       // Thumbnails is ON
Set ClosePreview off    // Preview window is not closed after printing

// Preview window size is adjusted for desktop's width and height (without taskbar)

Set preview rect 0, 0, GetDesktopRealHeight(), GetDesktopRealWidth()
Set preview scale 2

// Print fonts

Define font 'fTitle' name 'Times New Roman' Size 12 Bold        // Page number font
Define font 'fBase'  name 'Times New Roman' Size 12             // Main font
Define font 'fAlert' name 'Times New Roman' Size 12 Italic      // Font for warnings

nLen := oEditStru : nLen

Start Doc name aStat[ 'FileName' ]
Start Page

TitlePrn()                    // Print of page header
HeaderPrn()                   // Print of database description
HeadTablePrn()                // Header of field table

For Cycle := 1 to nLen
  
  If ( nLine == SH_FIRST_LINE )
     Start Page
     TitlePrn()                    // Print of page header
     HeadTablePrn()                // Table header is repeated on the each page
  Endif

  DataPrn( Cycle )
  
Next

End Page
End Doc

Release font 'fTitle'
Release font 'fBase'
Release font 'fAlert'

Release PrintSys

Return

****** End of PrintStructure ******


/******
*
*       LineCounter( nStep )
*
*       Rows counter
*
*/

Static Procedure LineCounter( nStep )

If ( nStep == nil )
   nLine ++
Else
   nLine += nStep
Endif

// Pass to next page?

If PAGE_FULL
   LinePrn()
   End Page
   
   nLine := SH_FIRST_LINE
   nPage ++
   
   Start Page
   
Endif

Return

****** End of LineCounter ******


/******
*
*       LinePrn()
*
*       Print of horizontal line
*
*/

Static Procedure LinePrn
@ nLine, 0, nLine, ( HBPRNMAXCOL - 2 * SH_FIRST_COL ) Line
Return

****** End of LinePrn ******


/******
*
*       TitlePrn()
*
*       Print of page header
*
*/

Static Procedure TitlePrn
Memvar aStat
Local cTitle := ( 'Page ' + LTrim( Str( nPage ) ) )

// Show warning if structure or description changing was not saved before printing

If ( aStat[ 'ChStruct' ] .or. aStat[ 'ChDescript' ] )

   Do case
      Case ( aStat[ 'ChStruct' ] .and. aStat[ 'ChDescript' ] )
        @ nLine, 0 Say 'Structure and description no saved!' Font 'fAlert' Color RED to print
      Case aStat[ 'ChStruct' ]
        @ nLine, 0 Say 'Structure no saved!' Font 'fAlert' Color RED to print
      Case aStat[ 'ChDescript' ]
        @ nLine, 0 Say 'Description no saved!' Font 'fAlert' Color RED to print
   Endcase
   
Endif

@ nLine, ( HBPRNMAXCOL - SH_PAGE_NUM ) Say cTitle Font 'fTitle' to print
LineCounter( 2 )

Return

****** End of TitlePrn *****


/******
*
*       HeaderPrn()
*
*       Print of general description
*
*/

Static Procedure HeaderPrn
Memvar aStat
Local cText := AllTrim( wModest.edtGeneral.Value ), ;
      nLen                                         , ;
      Cycle

@ nLine,  0 Say 'Date:' Font 'fTitle' to print
@ nLine, 15 Say DtoC( Date() ) Font 'fBase' to print 
LineCounter()

@ nLine,  0 Say 'File:' Font 'fTitle' to print
@ nLine, 15 Say aStat[ 'FileName' ] Font 'fBase' to print 
LineCounter()

@ nLine, 0 Say 'Description:' Font 'fTitle' to print

nLen := MLCount( cText, DESCR_CHAR_COUNT,,, .T. )
For Cycle := 1 to nLen
  @ nLine, 15 Say LTrim( Memoline( cText, DESCR_CHAR_COUNT, Cycle,,, .T. ) ) Font 'fBase' to print
  LineCounter()
Next

Return

****** End of HeaderPrn ******


/******
*
*      HeadTablePrn()
*
*      Print of table header
*
*/

Static Procedure HeadTablePrn

LineCounter()
LinePrn()

@ nLine,  2 Say '#'       Font 'fTitle' to print
@ nLine, 20 Say 'Field'   Font 'fTitle' to print
@ nLine, 40 Say 'Type'    Font 'fTitle' to print
@ nLine, 50 Say 'Len'     Font 'fTitle' to print
@ nLine, 60 Say 'Dec'     Font 'fTitle' to print
@ nLine, 70 Say 'Comment' Font 'fTitle' to print

LineCounter()

LinePrn()
LineCounter()

Return

****** End of HeadTablePrn *****


/******
*
*       DataPrn( nRow )
*
*       Print of structure
*
*/

Static Procedure DataPrn( nRow )
Memvar oEditStru
Local cText, ;
      Cycle, ;
      nLen

@ nLine,  0 Say Str( nRow, 3 ) Font 'fBase' to print

If ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_INSERTED )
   @ nLine, 7 Say 'New' Font 'fAlert' Color RED to print
ElseIf ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_DELETED )
   @ nLine, 7 Say 'Deleted' Font 'fAlert' Color RED to print
Endif

@ nLine, 20 Say oEditStru : aArray[ nRow, DBS_NAME ] Font 'fBase' to print
@ nLine, 42 Say oEditStru : aArray[ nRow, DBS_TYPE ] Font 'fBase' to print
@ nLine, 54 Say Str( oEditStru : aArray[ nRow, DBS_LEN ], 3 ) Font 'fBase' Align TA_RIGHT to print
@ nLine, 64 Say Str( oEditStru : aArray[ nRow, DBS_DEC ], 3 ) Font 'fBase' Align TA_RIGHT to print

cText := oEditStru : aArray[ nRow, DBS_COMMENT ]

If !Empty( cText )

   nLen := MLCount( cText, COMMENT_CHAR_COUNT,,, .T. )
   
   For Cycle := 1 to nLen
       @ nLine, 70 Say LTrim( Memoline( cText, COMMENT_CHAR_COUNT, Cycle,,, .T. ) ) Font 'fBase' to print
       
       If !( Cycle == nLen )
          LineCounter()
       Endif
       
   Next

Endif

LineCounter()

Return

****** End of DataPrn ******
 


// C-level functions

#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT 0x0400
#include <windows.h>
#include "hbapi.h"


/******
*
*       Real width of desktop
*
*/

HB_FUNC_STATIC( GETDESKTOPREALWIDTH ) 
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_retni(rect.right - rect.left);

}

/******
*
*       Real height of desktop (without taskbar)
*
*/

HB_FUNC_STATIC( GETDESKTOPREALHEIGHT ) 
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_retni(rect.bottom - rect.top);
}

#pragma ENDDUMP
