#include <minigui.ch>

Function Main
Local aAvailImages := { '00.bmp' ,'01.bmp' , '02.bmp' , '03.bmp' , '04.bmp' , '05.bmp' , '06.bmp' , '07.bmp' , '08.bmp' , '09.bmp' }
Local aItems := {}
Local aImages := {}

	aadd ( aItems , 'Item 01' )
	aadd ( aItems , 'Item 02' )
	aadd ( aItems , 'Item 03' )
	aadd ( aItems , 'Item 04' )
	aadd ( aItems , 'Item 05' )
	aadd ( aItems , 'Item 06' )
	aadd ( aItems , 'Item 07' )
	aadd ( aItems , 'Item 08' )
	aadd ( aItems , 'Item 09' )
	aadd ( aItems , 'Item 10' )

	aadd ( aImages , aAvailImages[5] )
	aadd ( aImages , aAvailImages[3] )
	aadd ( aImages , aAvailImages[6] )
	aadd ( aImages , aAvailImages[2] )
	aadd ( aImages , aAvailImages[4] )
	aadd ( aImages , aAvailImages[8] )
	aadd ( aImages , aAvailImages[7] )
	aadd ( aImages , aAvailImages[9] )
	aadd ( aImages , aAvailImages[10] )
	aadd ( aImages , aAvailImages[1] )

	Load Window Main
	Center Window Main
	Activate Window Main

Return Nil
