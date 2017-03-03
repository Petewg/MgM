/* 
 * testres.prg 
 */ 

#define IDR_HELLO 1001 
  
PROCEDURE main()
   LOCAL cFileOut := hb_dirTemp() + "\" + "he$$o.tmp"
   LOCAL nSize, hProcess, nRet

   DELETE FILE cFileOut

   nSize := RCDataToFile( IDR_HELLO, cFileOut )

   IF nSize > 0

      hProcess := hb_processOpen( cFileOut ) ; nRet := hb_processValue( hProcess, .T. )

      MsgBox( nRet, "Return" )

   ENDIF

   RETURN
