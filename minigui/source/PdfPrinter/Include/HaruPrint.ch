/*
 * Proyecto: PdfPrinter
 * Fichero: HaruPrint.ch
 * Descripción:
 * Autor:
 * Fecha: 22/02/2017
 */

#xcommand PRINT <oPrint> TO HARU [ FILE <cFile> ] ;
          [ <lPreview: PREVIEW> ] ;
          [ USER PASS <cUserpass>  ] ;
          [ OWNER PASS <cOwnerpass>  ] ;
          [ PERMISION  <nPermision>  ] ;
       => ;
     PrtMgrObject( [<oPrint> := ] THaruPdf():New( <cFile>, <cUserpass>, <cOwnerpass>, [<nPermision>], <.lPreview.>  ) )

#xcommand PRINT OBJECT <oPrint> => PrtMgrObject( <oPrint> )
#xcommand PRINTPAGE => PrtMgrStartPage()
#xcommand ENDPAGE => PrtMgrEndPage()

#xcommand ENDPRINT  => PrtMgrEnd()
#xcommand ENDPRINTER  => PrtMgrEnd()
