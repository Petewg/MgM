#include "minigui.ch"
#include "i_rptgen.ch"

Set Procedure To h_rptgen

Memvar Drv, Htitle
Memvar i
Memvar aRows

Procedure Main

	Public _HMG_RPTDATA := Array( 168 ), Drv := "M", Htitle := ''

	Public i
	Public aRows [ 20 ] [ 3 ]
	aRows [1]	:= {'Simpson','Homer','555-5555'}
	aRows [2]	:= {'Mulder','Fox','324-6432'}
	aRows [3]	:= {'Smart','Max','432-5892'}
	aRows [4]	:= {'Grillo','Pepe','894-2332'}
	aRows [5]	:= {'Kirk','James','346-9873'}
	aRows [6]	:= {'Barriga','Carlos','394-9654'}
	aRows [7]	:= {'Flanders','Ned','435-3211'}
	aRows [8]	:= {'Smith','John','123-1234'}
	aRows [9]	:= {'Pedemonti','Flavio','000-0000'}
	aRows [10]	:= {'Gomez','Juan','583-4832'}
	aRows [11]	:= {'Fernandez','Raul','321-4332'}
	aRows [12]	:= {'Borges','Javier','326-9430'}
	aRows [13]	:= {'Alvarez','Alberto','543-7898'}
	aRows [14]	:= {'Gonzalez','Ambo','437-8473'}
	aRows [15]	:= {'Batistuta','Gol','485-2843'}
	aRows [16]	:= {'Vinazzi','Amigo','394-5983'}
	aRows [17]	:= {'Pedemonti','Flavio','534-7984'}
	aRows [18]	:= {'Samarbide','Armando','854-7873'}
	aRows [19]	:= {'Pradon','Alejandra','???-????'}
	aRows [20]	:= {'Reyes','Monica','432-5836'}

	Set Century On
	Set Date Ansi

	DEFINE WINDOW Win_1 ;
		ROW 0 ;
		COL 0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Report Generator: I can print in multimode!' ;
		MAIN  

		DEFINE MAIN MENU
			POPUP 'File'
				ITEM '&1 MiniPrint Test'   ACTION Test("M")
				ITEM '&2 HbPrinter Test'   ACTION Test("H")
				ITEM '&3 Pdf Output Test'  ACTION Test("P")
				ITEM '&4 Html Output Test' ACTION Test("T")
				ITEM '&5 Rtf Output Test'  ACTION Test("R") NAME RTF //Work in progress...
				SEPARATOR
				ITEM '&6 Array Report by Miniprint'	ACTION Test("M",2)
				ITEM '&7 Array Report by Hbprinter'	ACTION Test("H",2)
				SEPARATOR
				ITEM '&Exit'               ACTION Win_1.Release
			END POPUP
		END MENU

		ON KEY ESCAPE ACTION Win_1.Release
		Win_1.Rtf.Enabled := .f.

	END WINDOW

	Win_1.Center

	Win_1.Activate

Return

Procedure Test(arg1,itest)

	default itest to 1

	Use Test

	drv := arg1

	if itest = 1
		LOAD REPORT Test
	Else
		LOAD REPORT DEMO8
	Endif

	do case

	case drv = "P"
           Htitle:='Report Header using Pdf driver'
           if file("demo2.pdf")
              Ferase("demo2.pdf")
           Endif
           ExecuteReport( 'Test',.F.,.F.,'demo2.pdf' )
           if file("demo2.pdf")
              EXECUTE FILE "demo2.pdf" 
           Endif
           
	case drv = "T"
           Htitle:='Report Header using Html driver'
           if file("demo2.html")
              Ferase("demo2.html")
           Endif
           ExecuteReport( 'Test',.F.,.F.,'demo2.Html' )
           if file("demo2.Html")
              EXECUTE FILE "demo2.html"
           Endif

	otherwise
           Htitle:='Report Header using '+if(drv="M", "Miniprint","Hbprinter")+" driver"
           if itest = 1
              EXECUTE REPORT Test PREVIEW SELECTPRINTER
           Else
              i := 1	;	ExecuteReport( 'Demo8',.t.,.t. )
           Endif

	Endcase

	Use

Return
