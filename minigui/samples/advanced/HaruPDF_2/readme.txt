PDFClass

Class to make report in Matrix or PDF using Harupdf (fixed size)


Constructor

PDFClass():New()


Description

Only a sample.

You can use same matrix coordinates to make report.

Options are PDF portrait, PDF landscape and matrix.

There are some graphics methods available too.

Note:

Check printer codes to compress/expand - example uses Chr(15)/Chr(18)

Check how to open txt/pdf - example uses some Windows default

MyTempFile() need a unique name, change it by your function for temporary files


Data

:nAngle

:nBottomMargin

:nCol

:cCodePage

:cFileName

:cFontName

:nFontSize

:acHeader

:nLeftMargin

:nLineHeight

:oPage

:nPageNumber

:oPDF

:nPdfPage

:nPrinterType

:nRow

:nRightMargin

:nTopMargin


Methods

:AddPage()

:Begin()

:Cancel()

:ColToPdfCol( nCol )

:DrawLine( nRowi, nColi, nRowf, nColf, nPenSize )

:DrawImage( cJPEGFile, nRow, nCol, nWitdh, nHeight )

:DrawRetangle( nTop, nLeft, nWidth, nHeight, nPenSize, nFillType, anRGB )

:DrawText( nRow, nCol, xValue, [ xPicture ], [ nFontSize ], [ cFontName ], [ nAngle ], [ anRGB ] )

:End()

:MaxCol()

:MaxRow()

:MaxRowTest( nRows )

:RowToPdfRow( nRow )

:PageFooter()

:PageHeader()

:PrnToPdf( cInputFile )

:SetInfo( cAuthor, cCreator, cTitle, cSubject )

:SetType( nPrinterType )


Library

www.harbourdoc.com.br


Author

José M. C. Quintas
