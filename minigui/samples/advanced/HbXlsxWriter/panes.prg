/*
 * A simple example to create worksheets with panes.
 *
 */

#include "minigui.ch"
#include "hblxw.ch"

PROCEDURE main()

   LOCAL cWorkBook := "panes.xlsx", cErrMsg := "Error in workbook_close()."

   LOCAL nError := CreateSpreadsheet( cWorkBook )

   IF nError == LXW_NO_ERROR 
	ShellExecute( 0, "open", cWorkBook,,, SW_SHOW ) 
   ELSE
	cErrMsg += ( CRLF + hb_strFormat( "Error %d: %s", nError, lxw_strError( nError ) ) )

	MsgStop( cErrMsg ) 
   ENDIF
		
   RETURN


FUNCTION CreateSpreadsheet( cName )

   LOCAL row, col, workbook, worksheet1, worksheet2, worksheet3, worksheet4, header, center

    /* Create a new workbook and add some worksheets. */
    workbook   := workbook_new( cName )

    worksheet1 := workbook_add_worksheet(workbook, "Panes 1")
    worksheet2 := workbook_add_worksheet(workbook, "Panes 2")
    worksheet3 := workbook_add_worksheet(workbook, "Panes 3")
    worksheet4 := workbook_add_worksheet(workbook, "Panes 4")

    /* Set up some formatting and text to highlight the panes. */
    header := workbook_add_format(workbook)
    format_set_align(header, LXW_ALIGN_CENTER)
    format_set_align(header, LXW_ALIGN_VERTICAL_CENTER)
    format_set_fg_color(header, 0xD7E4BC)
    format_set_bold(header)
    format_set_border(header, LXW_BORDER_THIN)

    center := workbook_add_format(workbook)
    format_set_align(center, LXW_ALIGN_CENTER)


    /*
     * Example 1. Freeze pane on the top row.
     */
    worksheet_freeze_panes(worksheet1, 1, 0)

    /* Some sheet formatting. */
    worksheet_set_column(worksheet1, 0, 8, 16, NIL)
    worksheet_set_row(worksheet1, 0, 20, NIL)
    worksheet_set_selection(worksheet1, 4, 3, 4, 3)

    /* Some worksheet text to demonstrate scrolling. */
    for col = 0 to 8
        worksheet_write_string(worksheet1, 0, col, "Scroll down", header)
    next

    for row = 1 to 99
        for col = 0 to 8
            worksheet_write_number(worksheet1, row, col, row + 1, center)
        next
    next


    /*
     * Example 2. Freeze pane on the left column.
     */
    worksheet_freeze_panes(worksheet2, 0, 1)

    /* Some sheet formatting. */
    worksheet_set_column(worksheet2, 0, 0, 16, NIL)
    worksheet_set_selection(worksheet2, 4, 3, 4, 3)

    /* Some worksheet text to demonstrate scrolling. */
    for row = 0 to 49
        worksheet_write_string(worksheet2, row, 0, "Scroll right", header)

        for col = 1 to 25
            worksheet_write_number(worksheet2, row, col, col, center)
        next
    next


    /*
     * Example 3. Freeze pane on the top row and left column.
     */
    worksheet_freeze_panes(worksheet3, 1, 1)

    /* Some sheet formatting. */
    worksheet_set_column(worksheet3, 0, 25, 16, NIL)
    worksheet_set_row(worksheet3, 0, 20, NIL)
    worksheet_write_string(worksheet3, 0, 0, "", header)
    worksheet_set_selection(worksheet3, 4, 3, 4, 3)


    /* Some worksheet text to demonstrate scrolling. */
    for col = 1 to 25
        worksheet_write_string(worksheet3, 0, col, "Scroll down", header)
    next

    for row = 1 to 49
        worksheet_write_string(worksheet3, row, 0, "Scroll right", header)

        for col = 1 to 25
            worksheet_write_number(worksheet3, row, col, col, center)
        next
    next


    /*
     * Example 4. Split pane on the top row and left column.
     *
     * The divisions must be specified in terms of row and column dimensions.
     * The default row height is 15 and the default column width is 8.43
     */
    worksheet_split_panes(worksheet4, 15, 8.43)

    /* Some sheet formatting. */

    /* Some worksheet text to demonstrate scrolling. */
    for col = 1 to 25
        worksheet_write_string(worksheet4, 0, col, "Scroll", center)
    next

    for row = 1 to 49
        worksheet_write_string(worksheet4, row, 0, "Scroll", center)

        for col = 1 to 25
            worksheet_write_number(worksheet4, row, col, col, center)
        next
    next

   RETURN workbook_close( workbook )
