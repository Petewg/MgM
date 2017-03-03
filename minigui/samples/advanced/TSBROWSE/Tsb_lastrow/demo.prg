#include 'minigui.ch'
#include "TSBrowse.ch"

#translate dbcreate(<file>, <struct>) => hb_dbcreatetemp(<file>, <struct>)

procedure main
local i, br_zaw

	dbcreate('test',{{'nazwa','C',30,0},;
		{'ilosc','N',12,2},;
		{'cena','N',14,2}})

	if select('test') == 0
		dbusearea(.t.,,'test')
	endif
	for i := 1 to 100
		test->(dbappend())
		test->nazwa := str(i)
		test->ilosc := test->(recno())
		test->cena := (test->ilosc * HB_Random(100))
	next
	test->(dbgotop())

	DEFINE WINDOW o_dlu AT 0,0 WIDTH 600 HEIGHT 400;
		TITLE 'TsBrowse last row sticking workaround';
		MAIN ICON "MAIN" ;
		FONT 'Arial' SIZE 12

		ON KEY ESCAPE OF o_dlu ACTION o_dlu.RELEASE

		@ 50,500 SPINNER Sp RANGE 0,100 value 25 WIDTH 60 ON CHANGE ( br_zaw:nHeightHead := o_dlu.sp.value, br_zaw:reset() )

		DEFINE TBROWSE Br_zaw AT 15, 10 OF o_dlu ALIAS "test" WIDTH 450 HEIGHT 330 ;
			ON CHANGE { || CorrectionFirstLast( Br_zaw ) }

		ADD COLUMN TO br_zaw DATA {|| test->nazwa } ALIGN DT_LEFT, DT_CENTER, DT_CENTER ;
			TITLE 'Nazwa' SIZE 150 FOOTER 'Pozycji '+LTrim( str(test->(lastrec())) )
		ADD COLUMN TO br_zaw DATA {|| test->ilosc } ALIGN DT_RIGHT, DT_CENTER,DT_CENTER TITLE 'Ilosc' SIZE 100
		ADD COLUMN TO br_zaw DATA {|| test->cena } ALIGN DT_RIGHT, DT_CENTER, DT_CENTER TITLE 'Cena' SIZE 100

		br_zaw:SetColor( { 2 }, { { | | IIf( test->(OrdKeyNo()) % 2 == 0, RGB(255,255,255), RGB(230, 230, 230) ) }})

		br_zaw:nHeightCell += 6
		br_zaw:nHeightFoot += 4
		br_zaw:nWheelLines := 1

		br_zaw:nHeightHead := o_dlu.sp.value

		END TBROWSE

	END WINDOW

	o_dlu.br_zaw.setfocus

	CENTER WINDOW o_dlu
	ACTIVATE WINDOW o_dlu

return

*--------------------------------------------------------------------------------*
procedure CorrectionFirstLast(oBrw)
*--------------------------------------------------------------------------------*

  IF oBrw:nRowCount() == oBrw:nRowPos()
    oBrw:Refresh( .F. )
  ENDIF

  IF oBrw:nLogicPos() > 0 .and. oBrw:nRowPos() == 1
    oBrw:Refresh( .F. )
  ENDIF

RETURN
