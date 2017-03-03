
HbXlsxWriter is a Harbour library for creating Excel XLSX files.

HbXlsxWriter  is a port  of the Libxlsxwriter (please see below ). As original
library it can only create new files. It cannot read or modify existing files!

Here is an example that was used to create the simple spreadsheet:
>>>---------------------------------------------------------------
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
>>>---------------------------------------------------------------

* Libxlsxwriter  is  a  C library  that  can  be  used to write text, numbers,
formulas and hyperlinks to multiple worksheets in an Excel 2007+ XLSX file.

See  the  full documentation on http://libxlsxwriter.github.io for the getting
started guide, a tutorial, the main API documentation and examples.
