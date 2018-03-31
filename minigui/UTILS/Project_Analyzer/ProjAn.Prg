#include <minigui.ch>

static cIniFile
static ApplicPath
static aPrg

*--------------------------------------------------------
Function Main
local bColor := { |val| if ( val[4] == '+' , RGB( 255,255,255 ) , RGB( 255,255,128 ) ) }	

	cIniFile:='ProjAn.ini'
	ApplicPath:=cFilePath( GetExeFileName() )
	aPrg:={}
	cIniFile:=ApplicPath+"\"+cIniFile
	
	SET AUTOADJUST ON NOBUTTONS

	Load Window wMain
	//Center Window wMain
	Activate Window wMain

Return Nil
*--------------------------------------------------------
static function wInit()
local p, s, cFile:='ProjAn.txt'

    BEGIN INI FILE cIniFile
    	GET p SECTION "wMain" ENTRY "wMainRow" DEFAULT 130 
    	wMain.Row:=p
    	GET p SECTION "wMain" ENTRY "wMainCol" DEFAULT 240
    	wMain.Col:=p
        GET s SECTION "Tuning" ENTRY "PrjFile" DEFAULT ''
        wMain.txt_PrjFile.Value:=s
    END INI
    if file(cFile)
    	wMain.Edit_3.Value:=MEMOREAD(cFile)
    else
    	wMain.Edit_3.Value:='Description file "'+cFile+'" is not found'
    endif

return Nil
*--------------------------------------------------------
static function wClose()
local s

    BEGIN INI FILE cIniFile
    	SET SECTION "wMain" ENTRY "wMainRow" TO wMain.Row
    	SET SECTION "wMain" ENTRY "wMainCol" TO wMain.Col
    	s:=wMain.txt_PrjFile.Value
        SET SECTION "Tuning" ENTRY "PrjFile" to s
    END INI

return Nil
*--------------------------------------------------------
static function GetPrjFile()
local c_File := GetFile({{'Hpj File','*.hpj'}, ;
	{'Mpm File','*.mpm'}, {'Hbp File','*.hbp'}, {'All Files','*.*'}}, ;
	'Select a project file', wMain.txt_PrjFile.Value)

	SET DEFAULT to (ApplicPath)
	if empty(c_File)
		Return Nil
	endif
	wMain.txt_PrjFile.Value:=c_File
	//clear
	wMain.PrBar_1.Value:=0
	wMain.PrBar_2.Value:=0
	wMain.List_1.DeleteAllItems 
	wMain.Grid_1.DeleteAllItems 

return Nil
*--------------------------------------------------------
#ifndef __XHARBOUR__
	#xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif
*--------------------------------------------------------
Function Start()
local txt, PrjPath, cFile, aFmg:={}, n:=1, n1, n2, nstr
local fn, fs, t, s, i, j, k

	wMain.PrBar_1.Value:=0
	wMain.PrBar_2.Value:=0
	wMain.List_1.DeleteAllItems 
	wMain.Grid_1.DeleteAllItems 

	aPrg:={} 
	if Empty(wMain.txt_PrjFile.Value)
		return Nil
	endif
	if !File(wMain.txt_PrjFile.Value)
		Msgbox('File "'+wMain.txt_PrjFile.Value+'" is not found')
		return Nil
	endif
	if empty(txt:=MEMOREAD(wMain.txt_PrjFile.Value))
		Msgbox('File "'+wMain.txt_PrjFile.Value+'" is wrong or empty')
		return Nil
	endif
	PrjPath:=cFilePath(wMain.txt_PrjFile.Value)
	//select and creating list of modules
	do while (n1:=at(CRLF,txt,n))>0
		t:=Substr(txt,n,n1-n)
		if '<ProjectFolder>\' $ t
			t := StrTran(t,'<ProjectFolder>\','')
		endif
		if '/ ' $ t
			t := StrTran(t,'/ ','')
		endif
		if upper(right(t,4))='.PRG'
			aAdd(aPrg,{t,{},{}})
		endif
		if upper(right(t,4))='.FMG'
			aAdd(aFmg,t)
		endif
		n:=n1+2
	enddo
	t:=Substr(txt,n)
	if '<ProjectFolder>\' $ t
		t := StrTran(t,'<ProjectFolder>\','')
	endif
	if '/ ' $ t
		t := StrTran(t,'/ ','')
	endif
	if upper(right(t,4))='.PRG'
		aAdd(aPrg,{t,{},{}})
	endif
	if upper(right(t,4))='.FMG'
		aAdd(aFmg,t)
	endif
	//list of modules is create
	//first pass - create list of functions
	wMain.PrBar_1.RangeMax:=len(aPrg)
	wMain.PrBar_1.RangeMin:=0
	wMain.PrBar_1.Value:=0
	for i:=1 to len(aPrg)
		wMain.PrBar_1.Value:=wMain.PrBar_1.Value+1
		do events
		cFile:=PrjPath+"\"+aPrg[i,1]
		if !File(cFile)
			Msgbox('File "'+cFile+'" is not found')
			return Nil
		endif
		if empty(txt:=MEMOREAD(cFile))
			Msgbox('File "'+cFile+'" is wrong or empty')
			return Nil
		endif
		nstr:=0
		n:=1
		do while (n1:=at(CRLF,txt,n))>0
			nstr++
			s:=upper(Substr(txt,n,n1-n))
			if len(t:=GetFuncName(s))>0 //function definition in this string
				aAdd(t,nstr)
				aAdd(t,'')
				aAdd(aPrg[i,2],t)
			endif
			n:=n1+2
		enddo
		// find for forms by command Load window ...
		txt:=upper(txt)
		n:=1
		do while (n1:=at('LOAD WINDOW ',txt,n))>0
			n2:=at(CRLF,txt,n1) //end of string
			s:=Substr(txt,n1+12,n2-n1-12) //form name
				aAdd(aPrg[i,3],s)
			n:=n2
		enddo
	next
	//list of functions is create
	//second pass - search for unused functions
	wMain.PrBar_2.RangeMax:=len(aPrg)
	wMain.PrBar_2.RangeMin:=0
	wMain.PrBar_2.Value:=0
	for i:=1 to len(aPrg)
		wMain.PrBar_2.Value:=wMain.PrBar_2.Value+1
		do events
		for j:=1 to len(aPrg[i,2]) //touching functions
			fn:=aPrg[i,2,j,1] //name
			fs:=aPrg[i,2,j,2] //static
			if !empty(fs) //static - check only module and calling windows
				if FindFunc(fn,fs,PrjPath+"\"+aPrg[i,1])
					aPrg[i,2,j,4]:='+'
				else
					for k:=1 to len(aPrg[i,3])
						if FindFunc(fn,fs,PrjPath+"\"+aPrg[i,3,k]+'.FMG')
							aPrg[i,2,j,4]:='+'
							exit
						endif
					next
				endif
			else //check for all modules and windows
				for n:=1 to len(aPrg)
					if FindFunc(fn,fs,PrjPath+"\"+aPrg[n,1])
						aPrg[i,2,j,4]:='+'
					else
						for k:=1 to len(aPrg[n,3])
							if FindFunc(fn,fs,PrjPath+"\"+aPrg[n,3,k]+'.FMG')
								aPrg[i,2,j,4]:='+'
								exit
							endif
						next
					endif
				next
			endif
		next
	next 
	//Bezel
	wMain.List_1.DeleteAllItems 
	for i:=1 to len(aPrg)
		wMain.List_1.AddItem(aPrg[i,1]) 
	next
	wMain.List_1.Value:=1
	List_1_Change()

return Nil
*--------------------------------------------------------
Function GetFuncName(s)
local aRet:={}, n1, n2, f:='', f1:=''

	s:=alltrim(s)
	if left(s,4)='STAT'
		if (n1:=at(' ',s))>0
			f1:=left(s,n1-1)
			if f1='STAT' .or. f1='STATI' .or. f1='STATIC' 
				s:=alltrim(substr(s,n1))
			endif
		endif
	endif
	if left(s,4)='FUNC' .or. left(s,4)='PROC'
		if (n1:=at(' ',s))>0
			s:=strtran(s,' (','(')
			if (n2:=at('(',s,n1))>0
				f:=substr(s,n1+1,n2-n1)
			endif
		endif
	endif
	if !empty(f)
		aRet:={f,f1}
	endif

return aRet
*--------------------------------------------------------
Function List_1_Change()
local i, n:=wMain.List_1.Value

	if n > 0
		wMain.Grid_1.DisableUpdate
		wMain.Grid_1.DeleteAllItems 
		for i:=1 to len(aPrg[n,2])
			wMain.Grid_1.AddItem ( {aPrg[n,2,i,1]+')',;
				if(len(aPrg[n,2,i,2])>0,left(aPrg[n,2,i,2],1),' '), ;
				alltrim(str(aPrg[n,2,i,3])),aPrg[n,2,i,4]} )
		next
		wMain.Grid_1.EnableUpdate
	endif

return Nil
*--------------------------------------------------------
Function List_1_Enter()
local n:=wMain.List_1.Value
local PrjPath:=cFilePath(wMain.txt_PrjFile.Value)

	EXECUTE FILE '"'+PrjPath+"\"+aPrg[n,1]+'"'

return Nil
*--------------------------------------------------------
Function FindFunc(fn,fs,filename)
local txt:=upper(MEMOREAD(filename)), n, n1, ok:=.f.

	fs:=nil
	fn:=upper(fn)
	do while at('  ',txt)>0 //delete double spaces
		txt:=STRTRAN(txt, '  ', ' ')
	enddo
	n:=1
	do while (n1:=at(fn,txt,n))>0
		if at('FUNC '+fn,txt)=n1-5 .or. ;
			at('FUNCT '+fn,txt)=n1-6 .or. ;
			at('FUNCTI '+fn,txt)=n1-7 .or. ;
			at('FUNCTIO '+fn,txt)=n1-8 .or. ;
			at('FUNCTION '+fn, txt)=n1-9 
			//omit - string with function definition
		else
			ok:=.t.
			exit
		endif
		n:=n1+len(fn)
	enddo

return ok
