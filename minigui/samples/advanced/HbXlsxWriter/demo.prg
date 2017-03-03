/*
 * A simple example of some of the features of the hbxlsxwriter library.
 *
 */


#include "minigui.ch"
#include "hblxw.ch"

PROCEDURE main()

   LOCAL cWorkBook := "demo.xlsx", cErrMsg := "Error in workbook_close()."

   LOCAL nError := CreateSpreadsheet( cWorkBook )

   IF nError == LXW_NO_ERROR 
      ShellExecute( 0, "open", cWorkBook,,, SW_SHOW ) 
   ELSE
      cErrMsg += ( CRLF + hb_strFormat( "Error %d: %s", nError, lxw_strError( nError ) ) )

      MsgStop( cErrMsg ) 
   ENDIF
      
   RETURN


FUNCTION CreateSpreadsheet( cName )
   /* Create a new workbook and add a worksheet. */
   LOCAL workbook  := workbook_new( cName )
   LOCAL worksheet := workbook_add_worksheet( workbook )
   /* Add a format. */
   LOCAL format := workbook_add_format( workbook )

   /* Set the bold property for the format. */
   format_set_bold( format )

   /* Change the column width for clarity. */
   worksheet_set_column( worksheet, 0, 0, 20 )

   /* Write some simple text. */
   worksheet_write_string( worksheet, 0, 0, "Hello" )

   /* Text with formatting. */
   worksheet_write_string( worksheet, 1, 0, "World!", format )

   /* Write some numbers. */
   worksheet_write_number( worksheet, 2, 0, 123 )
   worksheet_write_number( worksheet, 3, 0, 123.456 )

   /* Insert an image. */
   worksheet_insert_image( worksheet, 1, 2, "logo.png" )

   /* Save the workbook and free any allocated memory. DON'T TRY DO IT TWICE! */
   RETURN workbook_close( workbook )
