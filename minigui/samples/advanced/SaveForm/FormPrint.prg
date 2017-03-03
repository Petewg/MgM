/*
  Author..........: Mr. Grigory Filatov
  Contributions...: Mr. Ciro Vargas Clemov
  Adaptations.....: Mr. BP Dave 
*/

#include "hmg.ch"
/*
memvar _hmg_printer_name
memvar _hmg_printer_aprinterproperties
memvar _hmg_printer_preview
memvar _hmg_printer_timestamp
memvar _hmg_printer_hdc_bak
memvar _hmg_printer_pagecount
memvar _hmg_printer_copies
memvar _hmg_printer_collate
memvar _hmg_printer_hdc
memvar _hmg_printer_JobName
*/

*------------------------------------------------------------------------------*
FUNCTION FormPrint ( cWindowName , lPreview , ldialog , nRow , nCol , nWidth , nHeight )
*------------------------------------------------------------------------------*
LOCAL lSuccess
LOCAL TempName 
LOCAL W
LOCAL H
LOCAL HO
LOCAL VO
LOCAL bw , bh , r , tw , th , dc , wdif , hdif , dr
LOCAL ntop , nleft , nbottom , nright


   if   valtype ( nRow ) = 'U' ;
      .or. ;
      valtype ( nCol ) = 'U' ;
      .or. ;
      valtype ( nWidth ) = 'U' ;
      .or. ;
      valtype ( nHeight ) = 'U' 

      ntop   := -1
      nleft   := -1
      nbottom   := -1
      nright   := -1

   else

      ntop   := nRow
      nleft   := nCol
      nbottom   := nHeight + nRow
      nright   := nWidth + nCol

   endif

   if ValType ( lDialog ) = 'U'
      lDialog   := .F.
   endif

   if ValType ( lPreview ) = 'U'
      lPreview := .F.
   endif

   if lDialog 

      IF lPreview
         SELECT PRINTER DIALOG TO lSuccess PREVIEW
      ELSE
         SELECT PRINTER DIALOG TO lSuccess 
      ENDIF

      IF ! lSuccess
         RETURN NIL
      ENDIF
   
   else

      IF lPreview
         SELECT PRINTER DEFAULT TO lSuccess PREVIEW
      ELSE
         SELECT PRINTER DEFAULT TO lSuccess 
      ENDIF

      IF ! lSuccess
   //      MSGMINIGUIERROR ( "Can't Init Printer" )
         RETURN NIL
      ENDIF

   endif

   IF ! _IsWIndowDefined ( cWindowName )
 //     MSGMINIGUIERROR ( 'Window Not Defined' )
      RETURN NIL
   ENDIF

   TempName := GetTempFolder() + '\_hmg_printwindow_' + alltrim(str(int(seconds()*100))) + '.bmp' 

   SAVEWINDOWBYHANDLE ( GetFormHandle ( cWindowName ) , TempName , ntop , nleft , nbottom , nright )

   HO := GETPRINTABLEAREAHORIZONTALOFFSET()
   VO := GETPRINTABLEAREAVERTICALOFFSET()

   W := GETPRINTABLEAREAWIDTH() - 10 - ( HO * 2 ) 
   H := GETPRINTABLEAREAHEIGHT() - 10 - ( VO * 2 ) 

   if ntop = -1

      bw := GetProperty ( cWindowName , 'Width' ) 
      bh := GetProperty ( cWindowName , 'Height' ) - GetTitleHeight ( GetFormHandle (cWindowName) )

   else

      bw := nright - nleft
      bh := nbottom - ntop

   endif


   r := bw / bh

   tw := 0
   th := 0

   do while .t.

      tw ++   
      th := tw / r 

      if tw > w .or. th > h
         exit
      endif

   enddo

   wdif := w - tw 

   if wdif > 0
      dc := wdif / 2
   else
      dc := 0
   endif

   hdif := h - th 

   if hdif > 0
      dr := hdif / 2
   else
      dr := 0
   endif

   START PRINTDOC

      START PRINTPAGE

         @ VO + 10 + ( ( h - th ) / 2 ) , HO + 10 + ( ( w - tw ) / 2 ) PRINT IMAGE TempName WIDTH tW HEIGHT tH 

      END PRINTPAGE

   END PRINTDOC

   DO EVENTS
   Ferase(TempName)

RETURN NIL

