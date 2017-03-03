/*
 * Harbour TGif Class Header
 * Copyright 2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#xcommand @ <row>,<col> ANIGIF <oGif> ;
   [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
   PICTURE <filename> ;
   [ WIDTH <nWidth> ] ;
   [ HEIGHT <nHeight> ] ;
   [ DELAY <nDelay> ] ;
 =>;
   <oGif> := TGif():New( <filename>, <row>, <col>, <nHeight>, <nWidth>, <nDelay>, <"parent"> )
