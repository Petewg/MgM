/*
 * An example of a simple Excel chart using the hbxlsxwriter library.
 *
 */

#include "minigui.ch"
#include "hblxw.ch"

/* Line chart. */
#define LXW_CHART_LINE  11

PROCEDURE main()

   LOCAL cWorkBook := "chart_line.xlsx", cErrMsg := "Error in workbook_close()."

   LOCAL nError := CreateSpreadsheet( cWorkBook )

   IF nError == LXW_NO_ERROR 
	ShellExecute( 0, "open", cWorkBook,,, SW_SHOW ) 
   ELSE
	cErrMsg += ( CRLF + hb_strFormat( "Error %d: %s", nError, lxw_strError( nError ) ) )

	MsgStop( cErrMsg ) 
   ENDIF
		
   RETURN


/*
 * Create a worksheet with examples charts.
 */
FUNCTION CreateSpreadsheet( cName )
 
   LOCAL workbook, worksheet, chart, series
    
   workbook  := workbook_new( cName )
   worksheet := workbook_add_worksheet( workbook )

   /* Write some data for the chart. */
   worksheet_write_number( worksheet, 0, 0, 10, NIL )
   worksheet_write_number( worksheet, 1, 0, 40, NIL )
   worksheet_write_number( worksheet, 2, 0, 50, NIL )
   worksheet_write_number( worksheet, 3, 0, 20, NIL )
   worksheet_write_number( worksheet, 4, 0, 10, NIL )
   worksheet_write_number( worksheet, 5, 0, 50, NIL )

   /* Create a chart object. */
   chart := workbook_add_chart( workbook, LXW_CHART_LINE )

   /* Configure the chart. */
   series := chart_add_series( chart, NIL, "Sheet1!$A$1:$A$6" )

   /* Do something with series in the real examples. */

   /* Insert the chart into the worksheet. */
   worksheet_insert_chart( worksheet, CELL("C1"), chart )

   RETURN workbook_close( workbook )


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
   hb_retptr( (void *) chart_add_series(chart, x_range, y_range) );
}

#pragma ENDDUMP
