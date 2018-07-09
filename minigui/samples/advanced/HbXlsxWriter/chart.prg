/*
 * An example of a simple Excel chart using the hbxlsxwriter library.
 *
 */

#include "minigui.ch"
#include "hblxw.ch"

/* Column chart. */
#define LXW_CHART_COLUMN  7

PROCEDURE main()

   LOCAL cWorkBook := "chart.xlsx", cErrMsg := "Error in workbook_close()."

   LOCAL nError := CreateSpreadsheet( cWorkBook )

   IF nError == LXW_NO_ERROR 
	ShellExecute( 0, "open", cWorkBook,,, SW_SHOW ) 
   ELSE
	cErrMsg += ( CRLF + hb_strFormat( "Error %d: %s", nError, lxw_strError( nError ) ) )

	MsgStop( cErrMsg ) 
   ENDIF
		
   RETURN


FUNCTION CreateSpreadsheet( cName )

   LOCAL workbook, worksheet, chart
    
   /* Create a worksheet with a chart. */
   workbook  = workbook_new( cName )
   worksheet = workbook_add_worksheet( workbook )

   /* Write some data for the chart. */
   write_worksheet_data( worksheet )

   /* Create a chart object. */
   chart = workbook_add_chart( workbook, LXW_CHART_COLUMN )

   /* Configure the chart. In simplest case we just add some value data
    * series. The NIL categories will default to 1 to 5 like in Excel.
    */
   chart_add_series( chart, NIL, "Sheet1!$A$1:$A$5" )
   chart_add_series( chart, NIL, "Sheet1!$B$1:$B$5" )
   chart_add_series( chart, NIL, "Sheet1!$C$1:$C$5" )

   /* Insert the chart into the worksheet. */
   worksheet_insert_chart( worksheet, CELL("B7"), chart )

   /* Save the workbook and free any allocated memory. */
   RETURN workbook_close( workbook )


/* Write some data to the worksheet. */
FUNCTION write_worksheet_data( worksheet )

   LOCAL data, row, col

    /* Three columns of data. */
   data:= {;
        {1,   2,   3},;
        {2,   4,   6},;
        {3,   6,   9},;
        {4,   8,  12},;
        {5,  10,  15};
   }

   FOR row := 0 TO 4

       FOR col := 0 TO 2

           worksheet_write_number(worksheet, row, col, data[row+1,col+1], NIL)

       NEXT

   NEXT

   RETURN NIL


/* C-level */
#pragma BEGINDUMP

#include "xlsxwriter.h"
#include "hbapi.h"

HB_FUNC( CHART_ADD_SERIES )
{
   lxw_chart * chart = hb_parptr(1);
   const signed char * x_range;
   const signed char * y_range;
   x_range = (HB_ISNIL(2)) ? NULL : hb_parc(2);
   y_range = (HB_ISNIL(3)) ? NULL : hb_parc(3);
   chart_add_series(chart, x_range, y_range);
}

#pragma ENDDUMP
