/*
 * Example of cell locking and formula hiding in an Excel worksheet.
 *
 */

#include "minigui.ch"
#include "hblxw.ch"

PROCEDURE main()

   LOCAL cWorkBook := "protection.xlsx", cErrMsg := "Error in workbook_close()."

   LOCAL nError := CreateSpreadsheet( cWorkBook )

   IF nError == LXW_NO_ERROR 
	ShellExecute( 0, "open", cWorkBook,,, SW_SHOW ) 
   ELSE
	cErrMsg += ( CRLF + hb_strFormat( "Error %d: %s", nError, lxw_strError( nError ) ) )

	MsgStop( cErrMsg ) 
   ENDIF
		
   RETURN


FUNCTION CreateSpreadsheet( cName )

   LOCAL workbook, worksheet, unlocked, hidden

   workbook  := workbook_new( cName )
   worksheet := workbook_add_worksheet( workbook )

   unlocked := workbook_add_format( workbook )
   format_set_unlocked( unlocked )

   hidden := workbook_add_format( workbook )
   format_set_hidden( hidden )

   /* Widen the first column to make the text clearer. */
   worksheet_set_column( worksheet, 0, 0, 40, NIL )

   /* Turn worksheet protection ON without a password. */
   worksheet_protect( worksheet, NIL, NIL )

   /* Write a locked, unlocked and hidden cell. */
   worksheet_write_string( worksheet, 0, 0, "B1 is locked. It cannot be edited.",       NIL )
   worksheet_write_string( worksheet, 1, 0, "B2 is unlocked. It can be edited.",        NIL )
   worksheet_write_string( worksheet, 2, 0, "B3 is hidden. The formula isn't visible.", NIL )

   worksheet_write_formula( worksheet, 0, 1, "=1+2", NIL )     /* Locked by default. */
   worksheet_write_formula( worksheet, 1, 1, "=1+2", unlocked )
   worksheet_write_formula( worksheet, 2, 1, "=1+2", hidden )

   RETURN workbook_close( workbook )
