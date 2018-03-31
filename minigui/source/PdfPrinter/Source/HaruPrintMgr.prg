/*
 * Proyecto: PdfPrinter
 * Fichero: HaruPrintMgr.prg
 * Descripción:
 * Autor:
 * Fecha: 22/02/2017
 */

STATIC oPrint

FUNCTION PrtMgrObject( oPrintObj )

   IF oPrintObj != NIL
      oPrint := oPrintObj
   ENDIF

RETURN oPrintObj

FUNCTION PrtMgrStartPage()
RETURN oPrint:StartPage()

FUNCTION PrtMgrEndPage()
RETURN oPrint:EndPage()

FUNCTION PrtMgrEnd()
RETURN oPrint:End()
