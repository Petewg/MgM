/*
 * DO REPORT DEMO
 * (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"

Function Main

	use country alias test
	index on padr(field->CONTINENT,20)+padr(field->NAME,28) to test

	Define Window Win1			;
		Row	10			;
		Col	10			;
		Width	400			;
		Height	400			;
		Title	'Do Report Demo'	;
		MAIN				;
		On Init	Win1.Center()  

		@ 40 , 40 Button Button1	;
			Caption 'Create Report'	;
			Width	120		;
			On Click ButtonClick()	;
			Default

	End Window

	Activate Window Win1

Return Nil


Procedure ButtonClick()

   DbGoTop()

   do report ;
      title  'COUNTRIES SUMMARY'                                   ;
      headers  {} , { padc('Name',28), padc('Capital',15),         ;
                      padc('Area',11), padc('Population',14) }     ;
      fields   {'Name', 'Capital', 'Area', 'Population'}           ;
      widths   {28,15,11,14}                                       ;
      totals   {.F.,.F.,.T.,.T.}                                   ;
      nformats {'','','999 999 999','99 999 999 999'}              ;
      workarea Test                                                ;
      lpp      55                                                  ;
      cpl      77                                                  ;
      lmargin  4                                                   ;
      tmargin  4                                                   ;
      papersize DMPAPER_A4                                         ;
      preview                                                      ;
      select                                                       ;
      multiple                                                     ;
      grouped by 'CONTINENT'                                       ;
      headrgrp padc('Continent',23)                                ;
      nodatetimestamp

Return
