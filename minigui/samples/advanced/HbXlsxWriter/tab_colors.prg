/*
 * Example of how to set Excel worksheet tab colors using hbxlsxwriter.
 *
 */

#include "minigui.ch"
#include "hblxw.ch"

PROCEDURE main()

   LOCAL cWorkBook := "tab_colors.xlsx", cErrMsg := "Error in workbook_close()."

   LOCAL nError := CreateSpreadsheet( cWorkBook )

   IF nError == LXW_NO_ERROR 
	ShellExecute( 0, "open", cWorkBook,,, SW_SHOW ) 
   ELSE
	cErrMsg += ( CRLF + hb_strFormat( "Error %d: %s", nError, lxw_strError( nError ) ) )

	MsgStop( cErrMsg ) 
   ENDIF
		
   RETURN


FUNCTION CreateSpreadsheet( cName )

    LOCAL workbook, worksheet1, worksheet2, worksheet3, worksheet4

    workbook := workbook_new( cName )

    /* Set up some worksheets. */
    worksheet1 := workbook_add_worksheet( workbook )
    worksheet2 := workbook_add_worksheet( workbook )
    worksheet3 := workbook_add_worksheet( workbook )
    worksheet4 := workbook_add_worksheet( workbook )

    /* Set the tab colors. */
    worksheet_set_tab_color( worksheet1, LXW_COLOR_RED )
    worksheet_set_tab_color( worksheet2, LXW_COLOR_GREEN )
    worksheet_set_tab_color( worksheet3, 0xFF9900 )   /* Orange. */

    /* worksheet4 will have the default color. */
    worksheet_write_string( worksheet4, 0, 0, "Hello", NIL )

   RETURN workbook_close( workbook )
