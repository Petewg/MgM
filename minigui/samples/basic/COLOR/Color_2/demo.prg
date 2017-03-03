*
 * Name...: CAS
 * E-mail.: cas.soft@gmail.com
 * Country: Brazil
 *
 * dd/mm/yy
 * Date...: 03/Jun/2004  14:30
 * Modify.: 04/Jun/2004  17:25
 * .......: Test color
*

#include "MiniGUI.ch"

Function main_cas()
Local n, x_var, v_val, f_action

Memvar a_cor
Private a_cor := {}

SET NAVIGATION EXTENDED   && or STANDARD

aadd( a_cor , {0,0,0} )
aadd( a_cor , {128,128,128} )
aadd( a_cor , {255,255,255} )

aadd( a_cor , {0,0,255} )
aadd( a_cor , {0,255,0} )
aadd( a_cor , {255,0,0} )

aadd( a_cor , {0,0,128} )
aadd( a_cor , {0,128,0} )
aadd( a_cor , {128,0,0} )

aadd( a_cor , {0,255,255} )
aadd( a_cor , {255,255,0} )
aadd( a_cor , {255,0,255} )

aadd( a_cor , {0,128,128} )
aadd( a_cor , {128,128,0} )
aadd( a_cor , {128,0,128} )


DEFINE WINDOW Form_1 AT 0,0 WIDTH 410 HEIGHT 350 MAIN ;
	TITLE "Color RGB  -  by CAS <cas.soft@gmail.com>" ;
	NOMAXIMIZE NOSIZE ;
	ON INIT (f_cor( a_cor[3] ), f_cor2( a_cor[3] ))

	ON KEY ESCAPE    action ThisWindow.Release
	ON KEY ALT+X     action ThisWindow.Release
	ON KEY CONTROL+X action ThisWindow.Release


	@ 14,5 SPINNER Spn_1 RANGE 0,255 VALUE 000 ;
		ON LOSTFOCUS f_cor() ;
		ON CHANGE f_cor()

	@ 46,5 SPINNER Spn_2 RANGE 0,255 VALUE 255 ;
		ON LOSTFOCUS f_cor() ;
		ON CHANGE f_cor()

	@ 77,5 SPINNER Spn_3 RANGE 0,255 VALUE 000 ;
		ON LOSTFOCUS f_cor() ;
		ON CHANGE f_cor()

	@ 130,5 SLIDER Sld_1 RANGE 0,255 VALUE 000 ;
		WIDTH 250 HEIGHT 30 NOTICKS ;
		ON SCROLL f_cor2() ;
		ON CHANGE f_cor2()

	@ 170,5 SLIDER Sld_2 RANGE 0,255 VALUE 255 ;
		WIDTH 250 HEIGHT 30 NOTICKS ;
		ON SCROLL f_cor2() ;
		ON CHANGE f_cor2()

	@ 210,5 SLIDER Sld_3 RANGE 0,255 VALUE 000 ;
		WIDTH 250 HEIGHT 30 NOTICKS ;
		ON SCROLL f_cor2() ;
		ON CHANGE f_cor2()

	@ 14,134 LABEL Label_1 VALUE "Click Here" ;
		WIDTH 120 HEIGHT 86 ;
		BORDER ACTION f_GetColor()

	for n=1  to  len( a_cor )

		x_var := 'lb_c' + alltrim( str( n ) )

		v_val := 'Color {' + ;
			strzero( a_cor[n,1] , 3 ) + ',' +;
			strzero( a_cor[n,2] , 3 ) + ',' +;
			strzero( a_cor[n,3] , 3 ) + '}'

		f_action := 'f_cor( a_cor[' + alltrim(str(n)) + '] )'

		@ 20 * n - 6, 270 LABEL &x_var ;
			VALUE v_val ;
			BACKCOLOR a_cor[n] BORDER ;
			ACTION &f_action ;
			HEIGHT 18

		if a_cor[n,1] == 0 .and. a_cor[n,2] == 0 .and. a_cor[n,3] == 0
			SetProperty ( 'form_1' , x_var , 'FONTCOLOR' , {255,255,255} )
		endif
	next

END WINDOW
Form_1.Center ; Form_1.Activate
Return Nil

*______________________________________________________________________________________*

proc f_cor( m_cor )
local m_form, c1, c2, c3

m_form := thiswindow.name

if pcount() = 1
	SetProperty ( m_form , 'spn_1' , 'value' , m_cor[1] )
	SetProperty ( m_form , 'spn_2' , 'value' , m_cor[2] )
	SetProperty ( m_form , 'spn_3' , 'value' , m_cor[3] )
	f_cor()
	return
endif

c1 := GetProperty ( m_form , 'spn_1' , 'value' )
c2 := GetProperty ( m_form , 'spn_2' , 'value' )
c3 := GetProperty ( m_form , 'spn_3' , 'value' )

SetProperty ( m_form , 'sld_1' , 'value' , c1)
SetProperty ( m_form , 'sld_2' , 'value' , c2)
SetProperty ( m_form , 'sld_3' , 'value' , c3)

if c1 == 0 .and. c2 == 0 .and. c3 == 0
	SetProperty ( 'form_1' , 'label_1' , 'FONTCOLOR' , {255,255,255} )
else
	SetProperty ( 'form_1' , 'label_1' , 'FONTCOLOR' , {0,0,0} )
endif

SetProperty ( m_form , 'label_1' , 'BACKCOLOR' , {c1,c2,c3} )

return

*______________________________________________________________________________________*

proc f_cor2( m_cor )
local m_form, c1, c2, c3

m_form := thiswindow.name

if pcount() = 1
	SetProperty ( m_form , 'sld_1' , 'value' , m_cor[1] )
	SetProperty ( m_form , 'sld_2' , 'value' , m_cor[2] )
	SetProperty ( m_form , 'sld_3' , 'value' , m_cor[3] )
	return
endif

c1 := GetProperty ( m_form , 'sld_1' , 'value' )
c2 := GetProperty ( m_form , 'sld_2' , 'value' )
c3 := GetProperty ( m_form , 'sld_3' , 'value' )

SetProperty ( m_form , 'spn_1' , 'VALUE' , c1 )
SetProperty ( m_form , 'spn_2' , 'VALUE' , c2 )
SetProperty ( m_form , 'spn_3' , 'VALUE' , c3 )

if c1 == 0 .and. c2 == 0 .and. c3 == 0
	SetProperty ( 'form_1' , 'label_1' , 'FONTCOLOR' , {255,255,255} )
else
	SetProperty ( 'form_1' , 'label_1' , 'FONTCOLOR' , {0,0,0} )
endif

SetProperty ( m_form , 'label_1' , 'BACKCOLOR' , {c1,c2,c3} )

return

*______________________________________________________________________________________*

proc f_GetColor
local m_form, cor_atual, m_cor

m_form := thiswindow.name

cor_atual := GetProperty ( m_form , 'label_1' , 'backcolor' )
m_cor := GetColor( cor_atual )

if valtype(m_cor[1]) # 'N'
	return
endif

SetProperty ( m_form , 'label_1' , 'backcolor' , m_cor )

SetProperty ( m_form , 'spn_1' , 'value' , m_cor[1] )
SetProperty ( m_form , 'spn_2' , 'value' , m_cor[2] )
SetProperty ( m_form , 'spn_3' , 'value' , m_cor[3] )

f_cor()

return

*______________________________________________________________________________________*
