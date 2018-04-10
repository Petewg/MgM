#include "minigui.ch"
#include "TSBrowse.ch"

#define ntrim( n ) hb_ntos( n )
#define C_SYS GetSysColor( COLOR_INACTIVECAPTION )	//current color system
#define C_TEK GetSysColor( COLOR_CAPTIONTEXT )			//current color system
#define CLR_SYS GetSysColor( COLOR_BTNFACE )				//current color system

Memvar afont
Memvar MEG
Memvar zox
Memvar zoy
Memvar zpp
Memvar ztsm_szer
Memvar zhotkey
Memvar sc_color
Memvar st_color

Memvar ts_ob1,ts_ob2,ts_ob3,ts_ob4,ts_ob5,ts_ob6,ts_ob7,ts_ob8,ts_ob9 // handles the main menu must be PUBLIC
Memvar SYS_COLOR, tatx, ob, zzob

Memvar Y,X,TABL,ckno // parameters  menu: row, col, array menu, cform
memvar atab,tss_wyb, mob
memvar tss_zwie, zkol, ax, ctitle

*------------------------------------------------------------------------------------------------
STATIC tss_nmenu := 1, ts_zx_poz := 0, tss_zx_poz := 0,ts_nkla := 0,tss_nkla := 0,ts_dpl := 1,tss_dpl := 1,atsm_count := 0,ts_okno
STATIC ts_y := 0, ts_x := 0,ts_color1,ts_color2,ts_color3
*------------------------------------------------------------------------------------------------
procedure TsMenu
local dlug,se,i,iv,v, dp, rrtt, cwybor := '',tab_m := {},o
private zpp := 1
private ztsm_szer := 1
private zhotkey := ''
private sc_color := { GetRed(C_SYS), GetGreen(C_SYS), GetBlue(C_SYS) }
private st_color := { GetRed(C_TEK), GetGreen(C_TEK), GetBlue(C_TEK) }

PUBLIC ts_ob1,ts_ob2,ts_ob3,ts_ob4,ts_ob5,ts_ob6,ts_ob7,ts_ob8,ts_ob9 // handles the main menu must be PUBLIC
PUBLIC SYS_COLOR := { GetRed(CLR_SYS), GetGreen(CLR_SYS), GetBlue(CLR_SYS) }

PARAMETERS Y,X,TABL,ckno // parameters  menu: row, col, array menu, cform
ts_color1 := st_color
ts_color2 := {0,0,0}
ts_color3 := sc_color
ts_y := y
ts_x := x

ts_okno := ckno
atsm_count := len(tabl) // counter arrays

DECLARE tatx[atsm_count] // columns position, menu arrays

for o := 1 to atsm_count 																																// counter arrays
   tatx[o] := if(o > 1, (10+(len(strtran(tabl[o-1,1],'&',''))*10)+tatx[o-1]), 10+x)				// assignment the position arrays
	zpp := at('&',TABL[o,1]) 																															// looking for a hot key
	if zpp > 0
		zhotkey += upper(substr(TABL[o,1],zpp+1,1)) 																				// assignment hot keys
		cwybor += '`Alt+'+lower(substr(TABL[o,1],zpp+1,1))+'`-'+lower(strtran(tabl[o,1],'&',''))+' '	// description of the hot keys, to remove
	endif
	v := 'L'+ltrim(str(o)) 		// menu label handle
	ob := 'ts_ob'+ntrim(o)		// menu array handle
	iv := ntrim(o)
	zzob := 'f_ts_lr('+iv+',.t.)'	// parameters  of the procedure, called by the label
																		
 	@ y,tatx[o] LABEL &v OF &ts_okno WIDTH ((LEN(STRTRAN(TABL[o,1],'&',''))*10)) HEIGHT 20 VALUE TABL[o,1] ; // labels horizontal menu
 			FONT "MS Sans Serif" SIZE 10 BOLD BACKCOLOR GRAY FONTCOLOR WHITE CENTERALIGN ACTION &zzob
 		
	SetProperty(ts_okno,v,'backcolor',SYS_COLOR)	// horizontal menu, background color
  	SetProperty(ts_okno,V,'Fontcolor',BLACK)	// horizontal menu, fonts
	tab_m := {} 												// temporary array
	for i := 1 to len(tabl[o,2])
		if left(tabl[o,2,i,1],1) = '_'								// looking for separator
 			tabl[o,2,i,1] := strtran(padc(trim(tabl[o,2,i,1]),50,chr(151)),'_',chr(151)) // replace the underscore separator
			aadd(tab_m,{'',padc('',50,chr(151)),'' })
		else
			zpp := at('&',TABL[o,2,i,1])						// looking for a hot key
			if zpp > 0
				aadd(tab_m,{substr(TABL[o,2,i,1],zpp+1,1),alltrim(substr(TABL[o,2,i,1],zpp+2)),if(valtype(tabl[o,2,i,2])='A',chr(238),' ')} ) //adding an arrow when submenu
			else
				aadd(tab_m,{'',alltrim(substr(TABL[o,2,i,1],zpp+2)),if(valtype(tabl[o,2,i,2])='A',chr(238),'\') } )
			endif
			ztsm_szer := max(ztsm_szer,len(tab_m[i,2])+if(valtype(tabl[o,2,i,2])='A',5,2))
		endif
	next

   IF !_IsControlDefined (ob,ts_okno) // vertical menu
   
		DEFINE TBROWSE &(ob) AT y+20,tatx[o] OF &ts_okno WIDTH (ztsm_szer*10)+25 HEIGHT (len(TAB_m)*25)+1 FONT "Arial" SIZE 12 BOLD VALUE 1 ON CHANGE f_ts_change() ;
			ON DBLCLICK f_tsrun()

         &ob:SetArray( tab_m,,.f. )
         ADD COLUMN TO TBROWSE &ob DATA ARRAY ELEMENT 1 ALIGN DT_CENTER, DT_CENTER SIZE 20 COLORS C_TEK, C_SYS
         ADD COLUMN TO TBROWSE &ob DATA ARRAY ELEMENT 2 ALIGN DT_LEFT, DT_CENTER SIZE ((ztsm_szer*10)-20)
         ADD COLUMN TO TBROWSE &ob DATA ARRAY ELEMENT 3 ALIGN DT_LEFT, DT_CENTER SIZE (20)
			&ob:lDrawHeaders := .f.
			&ob:nHeightCell := 25
			&ob:nLineStyle := 0
			&ob:nWheelLines := 1
			&ob:lNoHScroll := .t.
			&ob:lNoVScroll := .t.
			&ob:ChangeFont( afont[8], 1, 1 )
			&ob:bUserKeys := {|ts_nkey,nFlags| f_ts_key(ts_nkey,nflags) } // use a key
			&ob:ChangeFont( afont[11], 3, 1 ) 

      End TBROWSE
     	&ob:hide()
   endif
   ztsm_szer := 1
next
 
ts_ob1:show()
ts_ob1:reset()
ts_ob1:setfocus()
ts_ob1:DrawSelect()
SetProperty(ts_okno,'L1','BackColor',ts_color3) // first LABEL horizontal menu
SetProperty(ts_okno,'L1','FontColor',ts_color1)

for i := 1 to len(zhotkey) // horizontal menu, declare the hot keys
	v := ntrim(i)
	zzob := '{|| f_ts_lr('+v+',.t.) }'
	_DefineHotKey ( ts_okno , 1 , asc(substr(zhotkey,i,1)) , &zzob  ) // hot key of labels
next
SetProperty(ts_okno,'ts_ob1','show') // show first vertical menu

ON KEY RETURN OF &ts_okno ACTION f_tsrun()								// selected items - letter - enter - DBLCLICK
ON KEY ESCAPE OF &ts_okno ACTION DoMethod ( ts_okno , "release" )	// exit
DoMethod ( ts_okno , "restore" )
SetProperty(ts_okno,'ts_ob1','show')
return
*------------------------------------------------------------------------------------------------------------
static procedure f_tsrun() // selected items
local zob := 'ts_ob'+str(ts_dpl,1)
local tx := MEG[ts_dpl,2,&zob:nat,2]
local zKol, oCol, nRow,ax,zp
if valtype(tx) = 'B'
	eval(tx)					// procedure to perform
else
	if valtype(tx) = 'A'
 		zKol			:= GetProperty(ts_okno,zob,'col')
		oCol		:= &zob:aColumns[ &zob:nCell ]
		nRow		:= &zob:nRowPos - 1 
   	nRow		:= ( nRow * &zob:nHeightCell ) + &zob:nHeightHead + &zob:nHeightSuper + &zob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
   	
		fmenu(ts_y+nRow+45,ts_x+zKol+30,TX) // show submenu
	else
		msginfo('Selected '+str(tx),'Info.') // info if number, main menu
	endif
endif
return
*------------------------------------------------------------------------------------------------------------
static procedure f_ts_key(ts_nkey,nflags)	// pressed a key, main menu
local zob := 'ts_ob'+str(ts_dpl,1)					// assignment  handle array
local tx := MEG[ts_dpl,2,&zob:nat,1]			// load array elements
local nl := len(MEG[ts_dpl,2]),ax,zp
if ts_nkey = 40 .and. ts_zx_poz = nl 	// if the cursor down and the pointer to the end
	ts_zx_poz := -1								// pointer to the beginning position of the negative
	&zob:gotop()
 	&zob:UpAStable()
	ts_nkey := 38
	ts_nkla := 38
	ts_zx_poz := -1
	return
elseif ts_nkey = 38 .and. ts_zx_poz = 1	// if the cursor up and the pointer to the beginning
	&zob:nat := nl
 	&zob:UpAStable()
	ts_zx_poz := -nl							// pointer position at the end of the negative
	ts_nkey := 40
	ts_nkla := 40
	return
else
	ts_nkla := ts_nkey
endif
if ts_nkey = 37					// if the cursor to the left
	ts_zx_poz := 0				// pointer to zero position
	f_ts_lr(-1,.f.)				// transfer to another menu to the left
	return
elseif ts_nkey = 39			// if the cursor to the right
	ts_zx_poz := 0				// pointer to zero position
	f_ts_lr(1,.f.)					// transfer to another menu to the right
	return
endif

if ts_nkey > 47 // if asci
	ax := MEG[ts_dpl,2]
	zp := ascan(ax,{|x| left(ltrim(strtran( x[1] ,'&','')),1) =chr(ts_nkey) })	// find a hot character
	if zp > 0 						// includes a hot character
		&zob:nat := zp
		&zob:UpAStable()
		f_tsrun() 					// selected items
	endif
endif
if (ts_nkey = 40) .and. left(tx,1) == chr(151) // cursor down and separator
 		&zob:godown()
 		SetProperty(ts_okno,zob,'Refresh')
endif
return
*------------------------------------------------------------------------------------------------------------
static procedure f_ts_change				// If the pointer change
local nl := 0
local zob := 'ts_ob'+str(ts_dpl,1)			// assignment  handle array
local tx := MEG[ts_dpl,2,&zob:nat,1]	// load array elements

if ts_zx_poz < 0										// if the position of negative
	ts_nkla := 0											// reset subcode
	&zob:nat := abs(ts_zx_poz)				// new position
	&zob:UpAStable()								// show cursor menu
	ts_zx_poz := abs(ts_zx_poz)			// save old position
	return
endif

ts_zx_poz := &zob:nat			// read new position

if (ts_nkla = 40) 						// if cursor down
	if left(tx,1) == chr(151) 	// if separator
 		&zob:godown()				// cursor down
 		ts_nkla := 0						// reset subcode
 	endif
elseif (ts_nkla = 38) 				// if cursor up
	if left(tx,1) == chr(151) 	// if separator
 		&zob:goup()						// cursor up
 		ts_nkla := 0						// reset subcode
 	endif
else 									// if mouse
	if left(tx,1) == chr(151) 	// if separator
 		&zob:goup()						// cursor up
 		ts_nkla := 0						// reset subcode
 	endif
endif
return
*------------------------------------------------------------------------------------------------------------
procedure f_ts_lr(zco,jak)					// transfer to other menu, right or left
local lob := 'L'+str(ts_dpl,1)				// label holder
local zob := 'ts_ob'+str(ts_dpl,1)			// array holder

SetProperty(ts_okno,lob,'Fontcolor',BLACK)			// label color standard
SetProperty(ts_okno,lob,'Backcolor',SYS_COLOR)	// label color standard

SetProperty(ts_okno,zob,'Enabled',.f.)	// access denied to the array
&zob:hide()													// hide the current array
if jak = .f.														// if .F. change the number array
	ts_dpl += zco											// change number array
else
	ts_dpl := zco											// set the indicated array
endif
if ts_dpl > atsm_count								// If the index exceeds the amount of tables set the first
	ts_dpl := 1
elseif ts_dpl < 1											// If the index smaller than the one set last
	ts_dpl := atsm_count
endif
zob := 'ts_ob'+str(ts_dpl,1)											// handle new array
lob := 'L'+str(ts_dpl,1)												// handle new label
SetProperty(ts_okno,lob,'Backcolor',ts_color3)		// color label selected
SetProperty(ts_okno,lob,'Fontcolor',ts_color1)		// color label selected

SetProperty(ts_okno,zob,'Enabled',.t.)		// access restored
zpp := &zob:nat												// store old array pointer

&zob:show()														// show new array
&zob:Refresh()													// 
&zob:Reset()													// 

DoMethod(ts_okno,zob,'Refresh')
DoMethod(ts_okno,zob,"SetFocus")

&zob:nat := zpp											// restoration of the old array pointer settings
&zob:UpAStable()										//
ts_zx_poz := &zob:nat								// recording a pointer array
return
*---------------------------------------------------------------
*---------------------------------------------------------------
*---------------------------------------------------------------
function fmenu()		// submenu or menu from key
local zsze := 1,zcenter := .f., o_pm,ncap := 0,nszy := 0,i
private atab := {},tss_wyb := 0, mob

parameters tss_zwie, zkol, ax, ctitle  // parameters  submenu: [row], [col], array submenu, [ctitle]
tss_nmenu += 1

mob := 'obm'+str(tss_nmenu,1)
o_pm := 'okm'+str(tss_nmenu,1)
for i := 1 to len(ax)
	if left(ax[i,1],1) = '_'
		aadd(atab,{'',padc('',50,chr(151)),''} )
	else
		zpp := at('&',ax[i,1])
		if zpp > 0
			aadd(atab,{substr(ax[i,1],zpp+1,1),alltrim(substr(ax[i,1],zpp+2)),if(valtype(ax[i,2])='A',chr(238),' ')})
		else
			aadd(atab,{'',alltrim(ax[i,1]),if(valtype(ax[i,2])='A',chr(238),' ')})
		endif
		zsze := max(zsze,len(atab[i,2])+if(valtype(ax[i,2])='A',5,2))
	endif
next
if empty(zkol)
	zkol := ((zox/2) - (((zsze*10)+5))/2)
endif
if empty(tss_zwie )
	tss_zwie := ((zoy/2)-((len(ax)/2)*20))
endif
if (zkol +((zsze*10)+15) > zox)
	zkol := zox-((zsze*10)+25)
endif
if empty(ctitle)
	ctitle := ''
else
	zsze := max(zsze,len(ctitle))
	ncap := 1
	nszy := 30
endif
_DefineModalWindow ( o_pm, ctitle, zkol, tss_zwie, (zsze*10)+25, (len(ax)*25)+5+nszy+ncap+iif(isseven(),GetBorderHeight(),0), "" , .F., .F.,.T., {,}, {,},, , , , ,, , , "MAIN" , "ARIAL" , 12 ,, , , , , , , , , , .F. , , .F. , .F. , , , )
	if len(ctitle) > 0
		_DefineLabel ( "L1",, 2, 2, ctitle, (zsze*10)-4+20, 25, "Arial" , 12 , .T., .F. , .F. , .F. , .F. , .F. ,ts_color3,ts_color1,,,, .F., .F., .F., .F. , .F. , .f. , .T. , .F. ,,, )
	endif
	&mob :=_DefineTBrowse (mob , "o_pm", 0,nszy, (zsze*10)+45, (len(ax)*25)+1, , ,, 1, "Arial", 12,, {|| f_tss_change()}, {|nRow,nCol,nFlags|f_tss_run()},,,,,,,,, , .T.,,,, ,,,,,,,,,,,,,,, .F. ,,,,,,,,,,, ); with object &mob

		&mob:SetArray( atab,,.F. )
		&mob:AddColumn( TSColumn():New(, {|x| If(PCount() > 0, &mob:aArray[&mob:nAt, 1] := x, &mob:aArray[&mob:nAt, 1])},, {GetSysColor( 9 ), GetSysColor( 3 )}, {1, 1}, 20,,,,, Nil,,,,,,,, &mob,,,,,,,,) )
		&mob:AddColumn( TSColumn():New(, {|x| If(PCount() > 0, &mob:aArray[&mob:nAt, 2] := x, &mob:aArray[&mob:nAt, 2])},,, {0, 1}, ((zsze*10)-20),,,,, Nil,,,,,,,, &mob,,,,,,,,) )
		ADD COLUMN TO TBROWSE &mob DATA ARRAY ELEMENT 3 ALIGN DT_LEFT, DT_CENTER SIZE (20)
		&mob:lDrawHeaders := .F.
		&mob:nHeightCell := 25
		&mob:nLineStyle := 6
		&mob:nWheelLines := 1
		&mob:lNoHScroll := .T.
		&mob:lNoVScroll := .T.
		&mob:ChangeFont( afont[8], 1, 1 )
		
		&mob:bUserKeys := {|ts_nkey,nFlags| f_ts_key_pod(ts_nkey,nflags) }
		&mob:ChangeFont( afont[11], 3, 1 ) 
		&mob:reset()
		&mob:setfocus()
		&mob:DrawSelect()
	_EndTBrowse (); end
	_DefineHotKey ( , 0 , 27 , {|| f_tss_close(o_pm)} )
_EndWindow ()

_ActivateWindow ( {o_pm}, .F. )
tss_nmenu-=1
return (tss_wyb)
*--------------------------------------------------------------------------------------
procedure f_tss_close()
local o_pm := 'okm'+str(tss_nmenu,1)

RELEASE WINDOW &o_pm

Return
*--------------------------------------------------------------------------------------
static procedure f_ts_key_pod(ts_nkey,nflags)
local zpp,zkol,nrow,ocol,ncrow,nl
local mob		:= 'obm'+str(tss_nmenu,1)
local o_pm		:= 'okm'+str(tss_nmenu,1)
local zsze		:= getProperty(o_pm,mob,'width')

tss_nkla	:= ts_nkey

if ts_nkey = 13						// call procedure, key ENTER
	zpp := &mob:nat
	if valtype(ax[zpp,2]) = 'B'
		eval(ax[zpp,2])
	elseif valtype(ax[zpp,2]) = 'A'
 		zkol			:= getProperty(o_pm,'col')
 		nrow		:= getProperty(o_pm,'row')
		oCol		:= &mob:aColumns[ &mob:nCell ]
		ncRow	:= &mob:nRowPos - 1 
   	ncRow	:= ( ncRow * &mob:nHeightCell ) + &mob:nHeightHead + &mob:nHeightSuper + &mob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
		nrow		+= ncrow
		
		fmenu(nrow+25,zkol+25,ax[zpp,2])	// parameters  submenu: row, col, array submenu
	else
		tss_wyb := ax[zpp,2]
		f_tss_close()
		return
	endif
endif
nl := len(ax)
if ts_nkey = 40 .and. tss_zx_poz = nl
	tss_zx_poz := -1
	&mob:gotop()
 	&mob:UpAStable()
	ts_nkey := 38
	tss_nkla := 38
	tss_zx_poz := -1
	return
elseif ts_nkey = 38 .and. tss_zx_poz = 1
	&mob:nat := nl
 	&mob:UpAStable()
	tss_zx_poz := -nl
	ts_nkey := 40
	tss_nkla := 40
	return
else
	tss_nkla := ts_nkey
endif
if ts_nkey > 47
	zpp := ascan(ax,{|x| left(ltrim(strtran( x[1] ,'&','')),1) =chr(ts_nkey) })
	if zpp > 0
		&mob:nat := zpp
		&mob:UpAStable()
		if valtype(ax[zpp,2]) = 'B'
			eval(ax[zpp,2])
		elseif valtype(ax[zpp,2]) = 'A'
	 		zkol			:= getProperty(o_pm,'col')
	 		nrow		:= getProperty(o_pm,'row')
			oCol		:= &mob:aColumns[ &mob:nCell ]
			ncRow	:= &mob:nRowPos - 1 
	   	ncRow	:= ( ncRow * &mob:nHeightCell ) + &mob:nHeightHead + &mob:nHeightSuper + &mob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
			nrow		+= ncrow
			
			fmenu(nrow+25,zkol+25,ax[zpp,2])
		else
			tss_wyb := ax[zpp,2]
			f_tss_close()
			return
		endif
	endif
endif
return
*------------------------------------------------------------------------------------------------------------
static procedure f_tss_run()
local zkol,nrow,ocol,ncrow
local zob := 'obm'+str(tss_nmenu,1)
local o_pm := 'okm'+str(tss_nmenu,1)
local zsze := getProperty(o_pm,zob,'width')
local zpp := &zob:nat

if valtype(ax[zpp,2]) = 'B'
	eval(ax[zpp,2])
else
	if valtype(ax[zpp,2]) = 'A'
		zkol			:= getProperty(o_pm,'col')
		nrow		:= getProperty(o_pm,'row')
		oCol		:= &zob:aColumns[ &zob:nCell ]
		ncRow	:= &zob:nRowPos - 1 
		ncRow	:= ( ncRow * &zob:nHeightCell ) + &zob:nHeightHead + &zob:nHeightSuper + &zob:nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
		nrow		+= ncrow
		
		fmenu(nrow+25,zkol+25,ax[zpp,2])
	else
		tss_wyb := ax[zpp,2]
 		f_tss_close()
		return
	endif
endif
return
*--------------------------------------------------------------------------------------
procedure f_tss_change()
local nl := 0
local mob := 'obm'+str(tss_nmenu,1)
if tss_zx_poz < 0
	tss_nkla := 0
	&mob:nat := abs(tss_zx_poz)
	&mob:UpAStable()
	tss_zx_poz := abs(tss_zx_poz)
	return
endif
if (tss_nkla = 40)
	if left(&mob:aArray[ &mob:nAt,2 ],1) = chr(151)
 		&mob:godown()
 	endif
elseif (tss_nkla = 38) 
	if left(&mob:aArray[ &mob:nAt,2 ],1) = chr(151)
 		&mob:goup()
 	endif
elseif left(&mob:aArray[ &mob:nAt,2 ],1) = chr(151)
	&mob:goup()
endif
tss_zx_poz := &mob:nat
return
