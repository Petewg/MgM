#include 'minigui.ch'
#include "TSBrowse.ch"

static zox
static zoy

memvar buf, br_f, br_zaw
field first, last, street

*------------------------------------------------------------------------
procedure main
*------------------------------------------------------------------------
zox := GetDesktopWidth()
zoy := GetDesktopHeight() - GetTaskbarHeight()

private buf := '', br_f, br_zaw

rddsetdefault( "DBFNTX" )

dbusearea(.t.,,'employee','test')

dbcreateindex('test1','left(first,1)+last',{|| left(first,1)+last }) // first letter of the name + last name
dbcreateindex('test2','left(first,2)+last',{|| left(first,2)+last }) // first two letters of the name + surname
dbcreateindex('test3','left(first,3)+last',{|| left(first,3)+last }) // first three 
dbcreateindex('test4','left(first,4)+last',{|| left(first,4)+last }) // first four 
dbcreateindex('test5','left(first,5)+last',{|| left(first,5)+last }) // first five 
dbcreateindex('test6','left(first,6)+last',{|| left(first,6)+last }) // first six 
dbcreateindex('test7','left(first,7)+last',{|| left(first,7)+last }) // first seven 
dbcreateindex('test8','left(first,8)+last',{|| left(first,8)+last }) // first eight 

dbcreateindex('test9','first+last',{|| first+last }) // name + surname
dbcreateindex('test10','last+first',{|| last+first }) // surname + name

dbcreateindex('test11','left(fword(street,2),1)+fword(street,3)+street',{|| left(fword(street,2),1)+fword(street,3)+street }) // the first letter of second word
dbcreateindex('test12','left(fword(street,2),2)+fword(street,3)+street',{|| left(fword(street,2),2)+fword(street,3)+street })
dbcreateindex('test13','left(fword(street,2),3)+fword(street,3)+street',{|| left(fword(street,2),3)+fword(street,3)+street })
dbcreateindex('test14','left(fword(street,2),4)+fword(street,3)+street',{|| left(fword(street,2),4)+fword(street,3)+street })
dbcreateindex('test15','left(fword(street,2),5)+fword(street,3)+street',{|| left(fword(street,2),5)+fword(street,3)+street })

test->(dbclearindex()) // Closes all indexes open in the current work area. 

test->(dbsetindex('test1')) // join indexes in order
test->(dbsetindex('test2'))
test->(dbsetindex('test3'))
test->(dbsetindex('test4'))
test->(dbsetindex('test5'))
test->(dbsetindex('test6'))
test->(dbsetindex('test7'))
test->(dbsetindex('test8'))
test->(dbsetindex('test9'))
test->(dbsetindex('test10'))
test->(dbsetindex('test11'))
test->(dbsetindex('test12'))
test->(dbsetindex('test13'))
test->(dbsetindex('test14'))
test->(dbsetindex('test15'))

test->(dbsetorder(9)) // name + surname

DEFINE WINDOW o_test AT 0,0 WIDTH zox HEIGHT zoy TITLE 'TsBrowse Find Demo' MAIN ICON "demo.ico" FONT 'Arial' SIZE 12 ON RELEASE CleanIndex()

	@ (zoy-90),10	BUTTONex wyjdz	CAPTION 'Esc exit'	WIDTH 100 HEIGHT 45 ACTION o_test.release NOTABSTOP
	@ (zoy-90),120	BUTTONex bf1	CAPTION 'F1 left'	WIDTH 100 HEIGHT 45 ACTION ( br_zaw:enabled(.t.),br_f:enabled(.f.),br_zaw:reset(),o_test.br_zaw.SetFocus ) NOTABSTOP
	@ (zoy-90),230	BUTTONex bf2	CAPTION 'F2 right'	WIDTH 100 HEIGHT 45 ACTION ( br_f:enabled(.t.),br_zaw:enabled(.f.),br_f:reset(),o_test.br_f.SetFocus ) NOTABSTOP

	@ (zoy-130),(30) LABEL L0 VALUE 'press any letter or number' WIDTH 300 FONT 'Arial' SIZE 12 BOLD
	@ (zoy-130),(zox/2) LABEL LBUF VALUE '' WIDTH 180 BOLD FONTCOLOR RED CLIENTEDGE

	DEFINE TBROWSE Br_f AT 10, (zox/2)-10 OF o_test ALIAS "test" WIDTH (zox/2)-10 HEIGHT (zoy-150) ON CHANGE (buf := '',o_test.lbuf.value := '')

	 	br_f:SetColor( { 2 }, { { | | IIf( test->(OrdKeyNo()) % 2 = 0, Rgb(255,255,255),rgb(220, 230, 210) ) }})

		ADD COLUMN TO  br_f DATA {|| test->first } ALIGN DT_LEFT, DT_CENTER, DT_CENTER TITLE 'First' SIZE 150
		ADD COLUMN TO  br_f DATA {|| test->last } ALIGN DT_LEFT, DT_CENTER, DT_CENTER TITLE 'Last' SIZE 150
		ADD COLUMN TO  br_f DATA {|| test->street } ALIGN DT_LEFT, DT_CENTER, DT_CENTER TITLE 'Street' SIZE 300

		br_f:bUserKeys := {|nKey,nFlags| if(((nkey>47) .and. (nkey<58)) .or.((nkey>63) .and. (nkey<91)) .or. (nkey=32) ,fszuk2(nkey,nflags),nil) } //== VK_RETURN .and. nFlags > 0, VK_RIGHT, nKey ) }
		br_f:nHeightCell += 6
		br_f:nHeightFoot += 7
		br_f:nHeightHead += 6
		br_f:nWheelLines := 1
		br_f:lNoHScroll := .T.
		br_f:setfocus()
		br_f:DrawSelect()
  		br_f:Gotop()
		br_f:reset()

	END TBROWSE

	DEFINE TBROWSE Br_zaw AT 10, 1 OF o_test ALIAS "test" WIDTH (zox/2)-10 HEIGHT (zoy-150)

	 	br_zaw:SetColor( { 2 }, { { | | iif( test->(OrdKeyNo()) % 2 = 0, Rgb(255,255,255),rgb(220, 230, 210) ) }})

		ADD COLUMN TO  br_zaw DATA {|| test->first } ALIGN DT_LEFT, DT_CENTER, DT_CENTER TITLE 'First' SIZE 150
		ADD COLUMN TO  br_zaw DATA {|| test->last } ALIGN DT_LEFT, DT_CENTER, DT_CENTER TITLE 'Last' SIZE 150
		ADD COLUMN TO  br_zaw DATA {|| test->street } ALIGN DT_LEFT, DT_CENTER, DT_CENTER TITLE 'Street' SIZE 300

		br_zaw:bUserKeys := {|nKey,nFlags| fszuk1(nkey,nflags) }
		br_zaw:nHeightCell += 6
		br_zaw:nHeightFoot += 7
		br_zaw:nHeightHead += 6
		br_zaw:nWheelLines := 1
		br_zaw:lNoHScroll := .T.
		br_zaw:setfocus()
		br_zaw:DrawSelect()
  		br_zaw:Gotop()
		br_zaw:reset()

	END TBROWSE

	ON KEY F1 OF o_test ACTION ( br_f:enabled(.f.),br_zaw:enabled(.t.),br_zaw:reset(),o_test.br_zaw.SetFocus )
	ON KEY F2 OF o_test ACTION ( br_zaw:enabled(.f.),br_f:enabled(.t.),br_f:reset(),o_test.br_f.SetFocus )
	ON KEY ESCAPE OF o_test ACTION o_test.release

   END WINDOW

   br_zaw:SetNoHoles()
   br_f:SetNoHoles()
	
   br_f:enabled(.f.)
   o_test.br_zaw.setfocus

   ACTIVATE WINDOW o_test

return
*------------------------------------------------------------------------
static procedure CleanIndex()
local nidx

   close all
   for nidx:=1 to 15
      ferase('test'+hb_ntos(nidx)+'.ntx')
   next

return
*------------------------------------------------------------------------
procedure fszuk1( nkey, nflags )
local zszuk1 := chr(nkey)
local zpp := at(zszuk1,'ACELNOSXZ') // Polish diacritics

if ((nkey>47) .and. (nkey<58)) .or. ((nkey>63) .and. (nkey<91)) // determine the range of characters (letters and numbers)
else
	return
endif

if zpp > 0 .and. nflags > 4000000 			// flag set to Alt
	zszuk1 := substr('¥ÆÊ£ÑÓŒ¯',ZPP,1) // left ALT+char   Polish diacritics to display
endif

DEFINE WINDOW o_szuk AT 0,0 WIDTH 300 HEIGHT 150 TITLE ' Find text' ICON "MAIN" MODAL 
	@ 10,10 label L0 VALUE 'space separating the words' WIDTH 280 FONT 'Arial' SIZE 10 CENTERALIGN
	@ 30,10 label L1 VALUE 'Text or number' WIDTH 120 HEIGHT 30 FONT 'Arial' SIZE 12 RIGHTALIGN
	@ 30,135 textbox cszuk value zszuk1	WIDTH 130 UPPERCASE ON ENTER find_szuk()

	SetProperty( 'o_szuk', 'cszuk', "CaretPos", 1 )

	ON KEY ESCAPE OF o_szuk ACTION o_szuk.release
	ON KEY return OF o_szuk ACTION if(find_szuk(),o_szuk.release,o_szuk.cszuk.SetFocus)
	
	@ 80,25 BUTTONEX bt_zapisz CAPTION 'Enter find'	WIDTH 120 PICTURE 'BR_OK' ACTION if(find_szuk(),o_szuk.release,o_szuk.cszuk.SetFocus)
	@ 80,150 BUTTONEX bt_odrzuc CAPTION 'Esc exit'	WIDTH 120 PICTURE 'BR_NO' ACTION o_szuk.release
END WINDOW

CENTER WINDOW o_szuk
ACTIVATE WINDOW o_szuk

br_zaw:setfocus()
br_zaw:reset()
br_zaw:DrawSelect()
br_zaw:UpStable()

return
*------------------------------------------------------------
function find_szuk()
local zszuk0 := upper(alltrim(o_szuk.cszuk.value))
local zpoz := test->(recno())
local zord := test->(indexord())
local n_word := at(' ',zszuk0)
local zszuk1 := ''
local zszuk2 := ''
local len1 := 0
local aszuk := {}
local zlen, zszuk_d

if n_word # 0
	aszuk  :=str2arr(zszuk0,' ')	// separation of the words
	zszuk1 := aszuk[1]		// first word
	zszuk2 := aszuk[2]		// second word
	
	len1 := len(zszuk1)		// length of the first word, determines the selection index
	if len1 > 8			// if no index
		zlen := 9		// set index to first name
	else
		zlen := len1		// selection index
	endif
else
	zlen := 9			// if the length of the first words, exceeds the number of indexes, primary index set.
endif

test->(dbsetorder(zlen)) // choice of index data

zszuk_d := strtran(zszuk0,' ') // addition of the words

if !test->(dbseek( zszuk_d ))
	test->(dbsetorder(10))
	if !test->(dbseek( zszuk_d ))
		test->(dbsetorder(11))
		if !test->(dbseek( zszuk_d ))
			test->(dbsetorder(12))
			if !test->(dbseek( zszuk_d ))
				test->(dbsetorder(13))
				if !test->(dbseek( zszuk_d ))
					test->(dbsetorder(14))
					if !test->(dbseek( zszuk_d ))
						test->(dbsetorder(15))
						if !test->(dbseek( zszuk_d ))
							msginfo(' Not found "'+trim(zszuk_d)+'" '+CRLF+test->(indexkey()),"")
							test->(dbsetorder(zord))
							test->(dbgoto(zpoz))
							return .f.
						endif
					endif
				endif
			endif
		endif
	endif
endif
o_test.br_zaw.value := test->(recno())

return .t.
*------------------------------------------------------------------------
function fszuk2( nkey, nflags )
local zpoz := test->(recno())
local zord := test->(indexord())
local ckey := chr(nkey)
local zpp := at(ckey,'ACELNOSXZ')
local n_word := 0
local zszuk1 := ''
local zszuk2 := ''
local len1 := 0
local aszuk := {}
local zszuk0, zszuk_d
local zlen

if zpp > 0 .and. nflags > 4000000  // right ALT+char   polish version
	ckey := substr('¥ÆÊ£ÑÓŒ¯',ZPP,1)
endif
buf += ckey

zszuk0 := trim(buf)

n_word := at(' ',zszuk0)

if n_word # 0
	aszuk  :=str2arr(zszuk0,' ')	// separation of the words
	zszuk1 := aszuk[1]		// first word
	zszuk2 := aszuk[2]		// second word
	
	len1 := len(zszuk1)		// length of the first word, determines the selection index
	if len1 > 8			// if no index
		zlen := 9		// set index to first name
	else
		zlen := len1		// selection index
	endif
ELSE
	zlen := 9			// if the length of the first words, exceeds the number of indexes, primary index set.
endif

test->(dbsetorder(zlen)) // choice of index data

zszuk_d := strtran(zszuk0,' ') // addition of the words

o_test.lbuf.value := strtran(buf,' ','_')

if !test->(dbseek( zszuk_d ))
	test->(dbsetorder(10))
	if !test->(dbseek( zszuk_d ))
		test->(dbsetorder(11))
		if !test->(dbseek( zszuk_d ))
			test->(dbsetorder(12))
			if !test->(dbseek( zszuk_d ))
				test->(dbsetorder(13))
				if !test->(dbseek( zszuk_d ))
					test->(dbsetorder(14))
					if !test->(dbseek( zszuk_d ))
						test->(dbsetorder(15))
						if !test->(dbseek( zszuk_d ))
							test->(dbsetorder(zord))
							test->(dbgoto(zpoz))
							buf := ''
							o_test.lbuf.value := ''
							tone(500,.01)
							msginfo(' Not found "'+trim(zszuk_d)+'" '+CRLF+test->(indexkey()),"")
							return .f.
						endif
					endif
				endif
			endif
		endif
	endif
endif
br_f:setfocus()
br_f:reset()
br_f:DrawSelect()
br_f:UpStable()

return .t.
*--------------------------------------------------------------------------
static function str2arr( clist, cdelimiter )
local npos
local alist := {}

if cdelimiter = nil
   cdelimiter := ";"
endif
while (npos := at(cdelimiter, clist)) != 0
   aadd(alist, alltrim(substr(clist, 1, npos - 1)))
   clist := substr(clist, npos + 1)
enddo
aadd(alist, alltrim(clist))

return alist
*------------------------------------------------------------------------
function fword( zstreet, ico )
local aszuk	:= str2arr(zstreet,' ') // separation of the words
local zszuk1	:= ''
local zszuk2	:= ''

if len(aszuk) > ico
	zszuk1 := aszuk[ico]		// first word
	zszuk2 := aszuk[ico+1]		// second word
	return zszuk1
elseif len(aszuk) = ico
	zszuk1 := aszuk[ico]		// first word
	zszuk2 := 'ZZ'			// second word
	return zszuk1
elseif len(aszuk) > 0
	zszuk1 := aszuk[1]		// first word
	zszuk2 := 'ZZ'			// second word
	return zszuk1
else
	return zstreet
endif

return 'ZZ'
