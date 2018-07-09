/*
 * An example of creating an Excel pie chart.
 *
 */

#include "minigui.ch"
#include "hblxw.ch"

/* Pie chart. */
#define LXW_CHART_PIE  12

PROCEDURE main()

   LOCAL cWorkBook := "chart_pie.xlsx", cErrMsg := "Error in workbook_close()."

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

   LOCAL workbook, worksheet, chart, series, bold
    
   workbook  := workbook_new( cName )
   worksheet := workbook_add_worksheet( workbook )

   /* Add a bold format to use to highlight the header cells. */
   bold := workbook_add_format( workbook )
   format_set_bold( bold )

   /* Write some data for the chart. */
   write_worksheet_data( worksheet, bold )

   /*
    * Create a pie chart.
    */
   chart := workbook_add_chart( workbook, LXW_CHART_PIE )

   /* Add the first series to the chart. */
   series := chart_add_series( chart, "=Sheet1!$A$2:$A$4", "=Sheet1!$B$2:$B$4" )

   /* Set the name for the series instead of the default "Series 1". */
   chart_series_set_name( series, "Pie sales data" )

   /* Add a chart title. */
   chart_title_set_name( chart, "Popular Pie Types" )

   /* Set an Excel chart style. */
   chart_set_style( chart, 10 )

   /* Insert the chart into the worksheet. */
   worksheet_insert_chart( worksheet, CELL("D2"), chart )

   RETURN workbook_close( workbook )


/*
 * Write some data to the worksheet.
 */
FUNCTION write_worksheet_data(worksheet, bold)

   worksheet_write_string(worksheet, CELL("A1"), "Category", bold)
   worksheet_write_string(worksheet, CELL("A2"), "Apple",    NIL)
   worksheet_write_string(worksheet, CELL("A3"), "Cherry",   NIL)
   worksheet_write_string(worksheet, CELL("A4"), "Pecan",    NIL)

   worksheet_write_string(worksheet, CELL("B1"), "Values",   bold)
   worksheet_write_number(worksheet, CELL("B2"), 60,         NIL)
   worksheet_write_number(worksheet, CELL("B3"), 30,         NIL)
   worksheet_write_number(worksheet, CELL("B4"), 10,         NIL)
    
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
   hb_retptr( (void *) chart_add_series(chart, x_range, y_range) );
}

HB_FUNC( CHART_SERIES_SET_NAME )
{
   lxw_chart_series * series = hb_parptr(1);
   chart_series_set_name( series, (const signed char *) hb_parc(2) );
}

HB_FUNC( CHART_TITLE_SET_NAME )
{
   lxw_chart * chart = hb_parptr(1);
   chart_set_style( chart, (unsigned char) hb_parc(2) );
}

HB_FUNC( CHART_SET_STYLE )
{
   lxw_chart * chart = hb_parptr(1);
   chart_set_style( chart, hb_parnl(2) );
}

#pragma ENDDUMP
