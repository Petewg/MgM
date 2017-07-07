#include "minigui.ch"
#define CrLf       chr(13)+chr(10)
#define cAcercaDe  	"Editor de Menus"+CrLf+"A partir do exemplo de Roberto Sánchez"+CrLf+;
					chr(174)+" Abril 2006, André Luiz Neto Cobas"+CrLf+CrLf+ ;
					"----------------------------------------------------------"+CrLf+CrLf+ ;
					"Ejemplo de definición de menú"+CrLf+"en tiempo de ejecución"+CrLf+CrLf+cVersion+CrLf+CrLf+chr(174)+" Abril 2006, Roberto Sánchez"+CrLf+CrLf+MiniGUIVersion()+CrLf+Version()
#define cVersion   "Versión 00.00.01"
/*
ShellExecute(0,"open","rundll32.exe","url.dll,FileProtocolHandler"+"mailto:andrecobas@yahoo.com.br?cc=&bcc="+"&subject=Editor%20de%20Menus:"+"&body=How%20are%20you%2C%20André%3F", , 1)

ShellExecute(0, "open", "rundll32.exe","url.dll,FileProtocolHandler " + "mailto:andrecobas@yahoo.com.br?cc=&bcc=" + "&subject=Editor%20de%20Menus:" + "&body=Como%20vai%20você%2C%20André%3F", , 1)
*/					
Static Mitem:=0
Static qesp:=0
Static QTS:=0
Static MyMenu:="0"
Static MenuPai:="0"
Static MnuLn:={}
Static ITMAT:=0 
static Fpos:=0
Static Tag:=0
Static aListItens:={}
STATIC ATIVADO :=.F.
//------------------------------------------------------------------------------------
Function main()

	SET NAVIGATION EXTENDED 
	set dele on
	set exclusive off
	AADD(aListItens,{"-","","","","","","","","","","","","",.F.,.F.})
  	DEFINE 	WINDOW FORM1 ;
			AT 82,157 ;
			WIDTH 800 ;
			HEIGHT 610 ;
			TITLE "Editor de Menus " +chr(174)+" Abril 2006, André Luiz Neto Cobas" ;
			MAIN ;
			NOMAXIMIZE;
			NOSIZE;
			ON INIT formActivate() ;
			ON RELEASE NIL 

	    @ 10,10 LABEL Lbltxt WIDTH  770 HEIGHT 20 BACKCOLOR {255,255,206} FONTCOLOR Nil BORDER

	    @ 34, 10 FRAME Frame_1 WIDTH  120 HEIGHT 175 CAPTION ""
	    @ 34,138 FRAME Frame_2 WIDTH  122 HEIGHT 115 CAPTION ""
	    @ 210,10 FRAME Frame_3 WIDTH  253 HEIGHT 350 CAPTION ""
	    
		@ 150,138 FRAME Frame_4 WIDTH  122 HEIGHT 60 CAPTION ""
	 
	    @ 227,20 LABEL Lbl_P WIDTH   70 HEIGHT  24 VALUE "Caption Port.:"  TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE
	    @ 257,20 LABEL Lbl_E WIDTH   70 HEIGHT  24 VALUE "Caption Esp.:"  TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE
	    @ 287,20 LABEL Lbl_I WIDTH   70 HEIGHT  24 VALUE "Caption Ing.:"  TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE
		//-----------------------------------------------------------------------------
	    @ 317,20 LABEL LblAction WIDTH   70 HEIGHT  24 VALUE "Action:"   TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE
	    @ 347,20 LABEL LblName   WIDTH   70 HEIGHT  24 VALUE "Name:"     TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE
	    @ 377,20 LABEL LblImage  WIDTH   70 HEIGHT  24 VALUE "Image:"    TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE 
		//-----------------------------------------------------------------------------
		@ 407,20 LABEL LbMsg_P WIDTH   70 HEIGHT  20 VALUE "Message Port.:"  TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE
		@ 437,20 LABEL LbMsg_E WIDTH   70 HEIGHT  20 VALUE "Message Esp.:"   TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE
		@ 467,20 LABEL LbMsg_I WIDTH   70 HEIGHT  20 VALUE "Message Ing.:"   TRANSPARENT  FONTCOLOR {0,0,255} AUTOSIZE

		//-----------------------------------------------------------------------------
	    @ 50,20 BUTTONEX BtModifica  WIDTH  100  HEIGHT 30 CAPTION "Modificar Linha";
	            ACTION   Bt_Inc_Click(3)  FLAT fontcolor {0,0,255}

	    @ 80,20 BUTTONex BtLoad WIDTH  100 HEIGHT 30 CAPTION "Carregar Menu";
				ACTION   BtLoad_Click()  FLAT fontcolor {0,0,255}

	    @ 110,20 BUTTONex BtSalvar  WIDTH  100 HEIGHT 30 CAPTION "Salvar Menu";
				ACTION   BtSalvar_Click()  FLAT fontcolor {0,0,255}

	    @ 140, 20 BUTTONex BtApagar  WIDTH  100 HEIGHT 30 CAPTION "Apagar Tudo";
				ACTION   BtApagarTudo_Click(.t.)  FLAT fontcolor {255,0,0}

	    @ 170, 20 BUTTONEX BtRemover WIDTH  100 HEIGHT 30 CAPTION "Remover";
				ACTION   BtRemover_Click()  FLAT fontcolor {255,100,0}

		//-----------------------------------------------------------------------------
	    @ 50 , 150 BUTTONEX BtPopUp WIDTH  100 HEIGHT 30 CAPTION "&POPUP";
				ACTION   Bt_Inc_Click(0) FLAT fontcolor {0,0,255}

	    @ 80, 150 BUTTONEX BtMenuItem  WIDTH  100 HEIGHT 30 CAPTION "MENU&ITEM";
				ACTION   Bt_Inc_Click(1) FLAT fontcolor {0,0,255}

	    @ 110 ,150 BUTTONEX BtSeparator WIDTH  99 HEIGHT 30 CAPTION "&SEPARATOR";
				ACTION   Bt_Inc_Click(2) FLAT  fontcolor {0,0,255}

	    @ 170,150 BUTTONEX BtTestar WIDTH  99 HEIGHT 30 CAPTION "&Testar";
				ACTION   Bt_Testar_Click() FLAT  fontcolor {0,0,255}
				
		//-----------------------------------------------------------------------------
	    @ 225,105 TEXTBOX TxtCaptionP WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} value  space(50)

	    @ 255,105 TEXTBOX TxtCaptionE WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} value  space(50)
	    @ 285,105 TEXTBOX TxtCaptionI WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} value  space(50)
					
		//-----------------------------------------------------------------------------
	    @ 315,105 TEXTBOX TxtAction WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} VALUE  space(200)

	    @ 345,105 TextBox TxtNome WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} VALUE  space(50) // VALID {|| ValidaNome(this.value)}

	    @ 375,105 TEXTBOX TxtImage WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} VALUE space(100)  

	    @ 405,105 TEXTBOX TxtMessageP WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} VALUE  space(100)

	    @ 435,105 TEXTBOX TxtMessageE WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} VALUE  space(100)

		@ 465,105 TEXTBOX TxtMessageI WIDTH  150 HEIGHT 24 BACKCOLOR  {{255,255,255},{255,255,255},{  0,210,  0}};
					FONTCOLOR  {{  0,  0,  0},{  0,  0,  0},{250,  0,  0}} VALUE  space(100)
		//-----------------------------------------------------------------------------------------------------
		@ 490,20 CHECKBOX Chk_Checked CAPTION "Checked:" WIDTH  100 HEIGHT 28  VALUE .F. FONTCOLOR {0,0,255} TRANSPARENT LEFTJUSTIFY 
	    @ 490,155 CHECKBOX Chk_Disabled CAPTION "Disabled" WIDTH  100 HEIGHT 28  VALUE .F. FONTCOLOR {0,0,255} TRANSPARENT LEFTJUSTIFY 

	    @ 520,20 BUTTONEX BtOk WIDTH  110 HEIGHT 30 CAPTION "&Ok";
				ACTION   BtOk_Click() FLAT  fontcolor {0,0,255}

	    @ 520,139 BUTTONEX BtCancel WIDTH  110 HEIGHT 30 CAPTION "&Cancelar";
				ACTION   Bt_Cancel_Click() FLAT  fontcolor {0,0,255}
		
		
	    DEFINE GRID Grid1
	        ROW    41
	        COL    271
	        WIDTH  509 // 869
	        HEIGHT 520
	        VALUE  1
	        ITEMS aListItens
			HEADERS {"LINHA DO MENU",;
					 "ID",;
					 "MENU PAI",;
					 "TIPO",;
					 "CAPTION_P",;
					 "CAPTION_E",;
					 "CAPTION_I",;
					 "NOME",;
					 "ACTION",;
					 "IMAGE",;
					 "MESSAGE_P",;
					 "MESSAGE_E",;
					 "MESSAGE_I",;
					 "CHECKED",;
					 "DISABLED"}
			WIDTHS  { 449,30,30,50,50,50,50,50,50,50,50,50,50,30,30}
	        ONCHANGE  (IIF(ATIVADO = .T.,(E_D_Frame3(.f.),ChecaList() ),NIL)) 
			NOLINES .t.
			fontname "courier new"
			fontsize 10
	    END GRID
	END WINDOW
	ACTIVATE WINDOW Form1
return nil
//------------------------------------------------------------------------------------
Function ValidaNome(cNome)
	Local lRet:=.t., f
	
	cNome:=upper(ALLTRIM(cNome))
	if !Empt(cNome)
		for f:=1 to len(aListItens)
			If upper(ALLTRIM(aListItens[f][8])) == cNome
				lret:=.t.
				If aListItens[f][4] ="DEFINE POPUP"
					MsgInfo("Já Existe um POPUP com este nome","Atenção")
				Else
					MsgInfo("Já Existe um MENUITEM com este nome","Atenção")
				Endif
			Endif		
		Next
	Endif	
Return lret
//------------------------------------------------------------------------------------
Proc formActivate()
    QTS := 100
    Inicia()
return
//------------------------------------------------------------------------------------
Proc Inicia()
    MyMenu := Str(0)
    MenuPai := Str(0)
	BtApagarTudo_Click(.f.)
	
    form1.TxtCaptionP.value := "Menu PopUp P" + alltrim(Str(Val(MyMenu) + 1))
    form1.TxtCaptionE.value := "Menu PopUp E" + alltrim(Str(Val(MyMenu) + 1))
    form1.TxtCaptionI.value := "Menu PopUp I" + alltrim(Str(Val(MyMenu) + 1))
    form1.TxtNome.value := "MNU01"
	ATIVADO :=.t.
    InserePopUp()
    form1.Grid1.value:= 1
	E_D_Frame3(.f.)

return

//------------------------------------------------------------------------------------
Proc LimpaInFo()
        form1.TxtCaptionP.value := space(50)
        form1.TxtCaptionE.value := space(50)
        form1.TxtCaptionI.value := space(50)
        form1.TxtAction.value := space(200)
        form1.TxtNome.value := space(50)
        form1.TxtImage.value := space(100)
        form1.TxtMessageP.value := space(100)
        form1.TxtMessageE.value := space(100)
        form1.TxtMessageI.value := space(100)
        form1.Chk_Checked.Value := .f.
        form1.Chk_Disabled.Value := .f.
Return
//------------------------------------------------------------------------------------
Proc PegaInFo(I) 
        form1.TxtCaptionP.value  := iif (!Empt(aListItens[I][ 5]),aListItens[I][ 5],"") // "CAPTION_P"
		form1.TxtCaptionE.value := iif (!Empt(aListItens[I][ 6]),aListItens[I][ 6],"") // "CAPTION_E"
		form1.TxtCaptionI.value := iif (!Empt(aListItens[I][ 7]),aListItens[I][ 7],"") // "CAPTION_I"
		form1.TxtNome.value  := iif (!Empt(aListItens[I][ 8]),aListItens[I][ 8],"") // "NOME"
		form1.TxtAction.value  := iif (!Empt(aListItens[I][ 9]),aListItens[I][ 9],"") // "ACTION"
        form1.TxtImage.value  := iif (!Empt(aListItens[I][10]),aListItens[I][10],"") // "IMAGE"
        form1.TxtMessageP.value  := iif (!Empt(aListItens[I][11]),aListItens[I][11],"") // "MESSAGE_P"
        form1.TxtMessageE.value := iif (!Empt(aListItens[I][12]),aListItens[I][12],"") // "MESSAGE_E"
        form1.TxtMessageI.value := iif (!Empt(aListItens[I][13]),aListItens[I][13],"") // "MESSAGE_I"		
        form1.Chk_Checked.Value    := iif (!Empt(aListItens[I][14]),aListItens[I][14],.f.) // "CHECKED"
        form1.Chk_Disabled.Value    := iif (!Empt(aListItens[I][15]),aListItens[I][15],.f.) // "DISABLED"

    ITMAT := I
		
Return
//------------------------------------------------------------------------------------
Proc E_D_Frame3(lvalor)
        form1.TxtCaptionP.Enabled := lvalor
        form1.TxtCaptionE.Enabled := lvalor
        form1.TxtCaptionI.Enabled := lvalor
        form1.TxtAction.Enabled := lvalor
        form1.TxtNome.Enabled := lvalor
        form1.TxtImage.Enabled := lvalor
        form1.TxtMessageP.Enabled := lvalor
        form1.TxtMessageE.Enabled := lvalor
        form1.TxtMessageI.Enabled := lvalor
        form1.Chk_Checked.Enabled    := lvalor
        form1.Chk_Disabled.Enabled    := lvalor
		form1.BtOK.enabled 		 := lvalor
		form1.BtCancel.enabled 	 := lvalor
Return
//------------------------------------------------------------------------------------
Proc E_D_Frame1(lvalor)
        form1.BtModifica.Enabled := lvalor
        form1.BtLoad.Enabled      := lvalor
        form1.BtSalvar.Enabled    := lvalor
        form1.BtApagar.Enabled    := lvalor
        form1.BtRemover.Enabled   := lvalor
Return
//------------------------------------------------------------------------------------
Function PegaTabulacao(wpos) 
    Local Wdif:=0, ln, wtmp
    If empt(wpos)
	wpos := 0
    endif	
    If wpos > 0
        ln := form1.Grid1.CELL((wpos-1),1)
        wtmp := LTrim(ln)
        wdif := Len(ln) - Len(wtmp)
        If Left(wtmp, 12) = "DEFINE POPUP"
           wdif := wdif + 4
        End If
    End If
return wdif
//------------------------------------------------------------------------------------
Proc E_D_Frame2(valor)
	Form1.Btpopup.Enabled     := valor
	Form1.BtMenuitem.Enabled  := valor
	Form1.BtSeparator.Enabled := valor
return
//------------------------------------------------------------------------------------
Proc Bt_Inc_Click(nIndex)
    local Nm:=""
    local tx:=""
    local wp:=0
    local ln

	E_D_Frame1(.f.)
	E_D_Frame2(.f.)
	E_D_Frame3(.f.)
	form1.BtOK.enabled := .t.
	form1.BtCancel.enabled := .t.
	
    If nIndex # 3 
		limpaInfo()
		
    End If
    
    Do Case
         Case  nIndex = 0
			form1.TxtCaptionP.enabled := .t.
			form1.TxtCaptionE.enabled := .t.
			form1.TxtCaptionI.enabled := .t.
			form1.TxtNome.enabled := .t.
			
            form1.TxtCaptionP.value  := "Menu PopUp P" + alltrim(Str(Val(MyMenu) + 1))
            form1.TxtCaptionE.value := "Menu PopUp E" + alltrim(Str(Val(MyMenu) + 1))
            form1.TxtCaptionI.value := "Menu PopUp I" + alltrim(Str(Val(MyMenu) + 1))
            form1.TxtCaptionP.SetFocus()
            Tag := nIndex
         Case nIndex = 1
            E_D_Frame3(.T.)
            form1.TxtCaptionP.value  := "Menu Item P" + alltrim(Str(Val(MyMenu) + 1))
            form1.TxtCaptionE.value := "Menu Item E" + alltrim(Str(Val(MyMenu) + 1))
            form1.TxtCaptionI.value := "Menu Item I" + alltrim(Str(Val(MyMenu) + 1))
            form1.TxtCaptionP.SetFocus()
            Tag := nIndex
         Case nIndex = 2
            E_D_Frame1(.t.)
            E_D_Frame2(.t.)
            E_D_Frame3(.f.)
            MenuPai := PegaMenuPai()
            InsereMENUITEM ("-")
			ChecaList()
            
         Case nIndex = 3
            ln := AllTrim(form1.Grid1.cell(form1.Grid1.value,1))
            If Upper(Left(Ln, 12)) = "DEFINE POPUP"
                form1.TxtCaptionP.Enabled := .T.
                form1.TxtCaptionE.Enabled := .T.
                form1.TxtCaptionI.Enabled := .T.
                form1.TxtNome.Enabled := .T.
            Else
				E_D_Frame3(.T.)
            End If
            form1.TxtCaptionP.SetFocus()
            Tag := nIndex
    EndCase

return
//------------------------------------------------------------------------------------
Function PegaMenuPai()
    Local f, ln
    Local wret:="0"
    Local wp := form1.Grid1.value
    Local qEnd := 1
    
    For f := wp - 1 To 0 Step -1
        ln := LTrim(form1.Grid1.CELL(f,1))
        If Upper(Left(ln, 12)) = "DEFINE POPUP"
			qEnd := qEnd - 1
		Endif	
        If Upper(Left(ln, 3)) = "END" 
			qEnd := qEnd + 1
		Endif	
        If qEnd = 0 
		    wret:=form1.Grid1.cell(f,2)
            return wret
        End If
    Next
return wret
//------------------------------------------------------------------------------------
Proc ChecaList()
    Local it
    Local wp := form1.Grid1.value
    Local txt := form1.Grid1.cell(wp,1)
    
	
	IF FORM1.Grid1.ITEMCOUNT >0
		it:=form1.Grid1.cell(form1.Grid1.value,4) 
	    If Left(AllTrim(txt), 3) = "END" .Or. txt = "-"
	        form1.BtRemover.Enabled := .F.
	        form1.BtModifica.Enabled := .F.
	        LIMPAINFO()
	    Else
	        form1.BtRemover.Enabled := .T.
	        If ("SEPAR" $ it) 
	            form1.BtModifica.Enabled := .F.
	            LIMPAINFO()
	        Else
	            form1.BtModifica.Enabled := .T.
	        End If
	    End If
		
	    If Left(txt, 1) # " " .And. Upper(Left(txt, 1)) # "E"
	        form1.Btseparator.Enabled := .F.
	        form1.BtMenuItem.Enabled := .F.
	    Else
	        form1.Btseparator.Enabled := .T.
	        form1.BtMenuItem.Enabled := .T.
	    End If
		
	    If it = "DEFINE POPUP" .Or. it= "MENUITEM" 
			PEGAINFO (form1.Grid1.value)
	    End If
		
	    form1.Lbltxt.value := AllTrim(form1.Grid1.cell(form1.Grid1.value,1))
	ENDIF
return
//------------------------------------------------------------------------------------
Function PegaPos(wpos)
    Local wret:= -1
    Local ID := 0, ltmp

    Local ln := form1.Grid1.cell(wpos,1)
    If ln = "-" 
        MenuPai := Str(0)
        return wret
    End If
    
    ltmp := LTrim(ln)
    If Left(ltmp, 3) = "END" 
	    return wret
    endif
	
    wret := val(form1.Grid1.cell(wpos,2))
    
return wret
//------------------------------------------------------------------------------------
Proc ModificaMENUITEM()
    Local tipo
    Local TXT
	
	fPos   := form1.Grid1.value   // linha sendo modificada
	tipo := aListItens[fPos][4]
	TXT := space(PegaTabulacao(fPos)) +LinhaMenu(form1.TxtCaptionP.value,;
							form1.TxtCaptionE.value,;
							form1.TxtCaptionI.value,;
							form1.TxtAction.value,;
							form1.TxtNome.value,;
							form1.TxtImage.value,;
							form1.TxtMessageP.value,;
							form1.TxtMessageE.value,;
							form1.TxtMessageI.value,;
							form1.Chk_Checked.value,;
							form1.Chk_Disabled.value,;
							tipo)
	aListItens[fpos]:={	TXT ,;
						aListItens[fPos][2],;
						aListItens[fPos][3],;
						tipo,;
						Form1.TxtCaptionP.value,;
						Form1.TxtCaptionE.value,;
						Form1.TxtCaptionI.value,;
						form1.TxtNome.value,;
						form1.TxtAction.value,;
						form1.TxtImage.value,;
						form1.TxtMessageP.value,;
						form1.TxtMessageE.value,;
						form1.TxtMessageI.value,;
						form1.Chk_Checked.Value,; 
						form1.Chk_Disabled.Value}
	AtualList()
	form1.Grid1.value :=fpos
return
//------------------------------------------------------------------------------------
proc InsereMenuItem(txtsep)
    Local tipo
    Local TXT

    MyMenu      := Str(Val(MyMenu) + 1)
    MenuPai     := PegaMenuPai()
    
    If Form1.Grid1.cell(Form1.Grid1.ItemCount,1 ) = "-" 
        fpos := Form1.Grid1.value
    End If
    
    If fpos < 1 
		fpos := 1
	endif	
    
    If TXTSEP ="-" 
       Tipo := "SEPARATOR"
    Else
        Tipo:="MENUITEM"
    End If

    TXT := space(PegaTabulacao(fPos)) +LinhaMenu(form1.TxtCaptionP.value,;
												form1.TxtCaptionE.value,;
												form1.TxtCaptionI.value,;
												form1.TxtAction.value,;
												form1.TxtNome.value,;
												form1.TxtImage.value,;
												form1.TxtMessageP.value,;
												form1.TxtMessageE.value,;
												form1.TxtMessageI.value,;
												form1.Chk_Checked.value,;
												form1.Chk_Disabled.value,;
												tipo)

	AADD(aListItens,{"-","","","","","","","","","","","","",.F.,.F.})
	Ains(aListItens,fpos)
	
	aListItens[fpos]:={	TXT,;
						alltrim(MyMenu),;
						alltrim(MenuPai),;
						alltrim(Tipo),;
						Form1.TxtCaptionP.value,;
						Form1.TxtCaptionE.value,;
						Form1.TxtCaptionI.value,;
						form1.TxtNome.value,;
						form1.TxtAction.value,;
						form1.TxtImage.value,;
						form1.TxtMessageP.value,;
						form1.TxtMessageE.value,;
						form1.TxtMessageI.value,;
						form1.Chk_Checked.Value,; 
						form1.Chk_Disabled.Value}
    Mitem := Mitem + 1
	AtualList()
	form1.Grid1.value:=fpos

return
//------------------------------------------------------------------------------------
Proc InserePopUp()
    Local cTipo   := ""
    Local Texto, nome, tx

    MyMenu  := Str(Val(MyMenu) + 1)
    MenuPai := iif (form1.Grid1.ItemCOunt >0,PegaMenuPai(),str(0))
	
    fpos := Form1.Grid1.value
	
    If form1.Grid1.CELL((Form1.Grid1.value - 1),1) = "-" 
        fpos := Form1.Grid1.value
    End If
    
    Texto := Chr(34) + form1.TxtCaptionP.value + Chr(34)
    nome := alltrim(form1.TxtNome.value)
    
    If !Empt(nome) 
	    Texto := Texto + " NAME " + nome
	endif	
    
    If fpos < 1
		fpos := 1
	endif	
    qesp := PegaTabulacao(fpos)
    
    tx := Space(qesp) + "DEFINE POPUP " + Texto
	AADD(aListItens,{"-","","","","","","","","","","","","",.F.,.F.})
	Ains(aListItens,fpos)
	aListItens[fpos]:={	tx,;
						alltrim(MyMenu),;
						alltrim(MenuPai),;
						"DEFINE POPUP",;
						Form1.TxtCaptionP.value,;
						Form1.TxtCaptionE.value,;
						Form1.TxtCaptionI.value,;
						form1.TxtNome.value,;
						"","","","","",.F.,.F.}
    
	tx:=Space(qesp) + "END POPUP "
	AADD(aListItens,{"-","","","","","","","","","","","","",.F.,.F.})
	Ains(aListItens,fpos+1)
	aListItens[fpos+1]:={tx,;
						alltrim(MyMenu),;
						alltrim(MenuPai),;
						"END POPUP","","","","","","","","","",.F.,.F.}
	
    AtualList()
	form1.Grid1.value:=fpos
return
//------------------------------------------------------------------------------------
Proc Bt_Cancel_Click()
    E_D_Frame3(.F.)
    E_D_Frame2(.T.)
	E_D_Frame1(.T.)

    form1.Grid1.Enabled := .T.
    ChecaList()
return
//------------------------------------------------------------------------------------
Proc AtualList()
   Local f

	Form1.Grid1.deleteAllItems()

	for f:= 1 to len(aListItens)
		form1.Grid1.additem({aListItens[f][1],;
							 aListItens[f][2],;
							 aListItens[f][3],;
							 aListItens[f][4],;
							 aListItens[f][5],;
							 aListItens[f][6],;
							 aListItens[f][7],;
							 aListItens[f][8],;
							 aListItens[f][9],;
							 aListItens[f][10],;
							 aListItens[f][11],;
							 aListItens[f][12],;
							 aListItens[f][13],;
							 aListItens[f][14],;
							 aListItens[f][15]})
	next	
	
Return
//------------------------------------------------------------------------------------
Proc BtOk_Click()
    local tx :=""
    
    SelecionaTipo()
	E_D_FRAME2(.T.)
	E_D_FRAME3(.F.)
	E_D_FRAME1(.T.)
    FORM1.Grid1.Enabled := .T.
    ChecaList()
return
//------------------------------------------------------------------------------------
PROC SelecionaTipo()
    
    DO Case
	    Case Tag = 0
	        InserePopUp()
	    Case Tag = 1
	        InsereMENUITEM()
	    Case Tag = 2
	        InsereMENUITEM('-')
	    Case Tag =3
	        ModificaMENUITEM()
    End CASE
return
//------------------------------------------------------------------------------------
Function LinhaMenu(TxtCaptionP,TxtCaptionE,TxtCaptionI,TxtAction,TxtNome,TxtImage,TxtMessageP,TxtMessageE,TxtMessageI,Chk_Checked,Chk_Disabled,tipo)
    Local TXT:=""
    Local ctxtAction   := ""
    Local ctxtName     := ""		
    Local ctxtImage    := ""		
    Local ctxtMsg      := ""		
    Local ctxtChecked  := ""
    Local ctxtDisabled := ""
    Local ctipo:= ""

    If !Empt(AllTrim(TxtNome))
        ctxtName := " NAME " + AllTrim(TxtNome)
    End If

    if tipo ="MENUITEM"
        If Empt(AllTrim(TxtAction))
			ctxtAction := " ACTION Nil"
		Else
			ctxtAction := " ACTION " + AllTrim(TxtAction)
		End If
        
		If !empt(AllTrim(TxtImage))
			ctxtImage := " IMAGE " + Chr(34) + AllTrim(TxtImage) + Chr(34)
		End If
     
	    ctxtMsg:=AllTrim(TxtMessageP)
		if Empt(ctxtMsg)
			ctxtMsg:=AllTrim(TxtMessageE)
		endif	
		if Empt(ctxtMsg)
			ctxtMsg:=AllTrim(TxtMessageI)
		endif	
		If !Empt(AllTrim(ctxtMsg))
			ctxtMsg := " MESSAGE " + Chr(34) + AllTrim(ctxtMsg) + Chr(34)
		End If
		
		If Chk_Checked =.t.
			ctxtChecked := " CHECKED"
		Endif
		
		If Chk_Disabled = .t.
			ctxtDisabled := " DISABLED"
		End If
    ENDIF
	If tipo = "MENUITEM" .or. TIPO = "DEFINE POPUP"  
		TXT:= alltrim(tipo) +" " + Chr(34) + AllTrim(TxtCaptionP) + Chr(34)	
	Else
		TXT:=alltrim(tipo) 
	endif	

    TXT := TXT + ctxtAction + ctxtName + ctxtImage + ctxtChecked + ctxtDisabled + ctxtMsg
	
return Txt
//------------------------------------------------------------------------------------
Proc BtApagarTudo_Click(lpergunta)
	Local lescolha :=.f.
	
    If lpergunta
		lescolha:=msgyesno("Tem Certeza Que Deseja Apagar Tudo?","Atenção",.f.)
		if lescolha =.f.
		   return
		Endif
	Endif
	
	MyMenu := Str(0)
	MenuPai := Str(0)
	mItem:=1
	Apagatudo()
	AtualList()
	FORM1.Grid1.VALUE:=1
	FORM1.Grid1.SETFOCUS()
	
return
//------------------------------------------------------------------------------------
Proc ApagaTudo()
	Form1.Grid1.deleteAllItems()
	Asize(aListItens,0)
	AADD(aListItens,{"-","","","","","","","","","","","","",.F.,.F.})
	
Return
//------------------------------------------------------------------------------------
Proc BtLoad_Click()
	Local cFile, c1, c_dbf
	Local txt

    cFile:= GetFile ( { {"Arquivos DBF","*.DBF"}} , "Abrir Arquivo",GetCurrentFolder() , .f. , .f.)
	
	If !Empt(Alltrim(cFile))
		C1:=RAT(".",CFILE)
		C_DBF:=LEFT(CFILE,C1-1)
//		C1:=RAT("\",C_DBF)
//		C_NTAB:= RIGHT(C_DBF,LEN(C_DBF)-C1)
		Mitem:=1
		fpos:=1
		qesp:=0
		
		USE &C_DBF NEW
		INDEX ON descend(FIELD->LINHA) TO &C_DBF
	
		ApagaTudo()
		
		Do while !eof()
			AADD(aListItens,{"-","","","","","","","","","","","","",.F.,.F.})
			Ains(aListItens,fpos)
			txt:= "" 
			MyMenu:=(Alias())->ID
			MenuPai:=(Alias())->MNUPAI

			If (Alias())->TIPO ="DEFINE POPUP"
				qesp:=qesp - 4
			endif
			If qesp >0
				txt:=space(qesp)+txt
			endif
			
			TxT:=TxT +LinhaMenu((Alias())->CAPTIONP,;
								(Alias())->CAPTIONE,;
								(Alias())->CAPTIONI,;
								(Alias())->ACTION,;
								(Alias())->NOME,;
								(Alias())->IMAGE,;
								(Alias())->MESSAGEP,;
								(Alias())->MESSAGEE,;
								(Alias())->MESSAGEI,;
								(Alias())->CHECKED,;
								(Alias())->DISABLED,;
								(Alias())->TIPO)
								
			aListItens[fpos]:={	TXT,;
						alltrim(MyMenu),;
						alltrim(MenuPai),;
						(Alias())->TIPO,;
						(Alias())->CAPTIONP,;
						(Alias())->CAPTIONE,;
						(Alias())->CAPTIONI,;
						(Alias())->NOME,;
						(Alias())->ACTION,;
						(Alias())->IMAGE,;
						(Alias())->MESSAGEP,;
						(Alias())->MESSAGEE,;
						(Alias())->MESSAGEI,;
						(Alias())->CHECKED,; 
						(Alias())->DISABLED}
				
			If (Alias())->TIPO ="END POPUP"
				qesp:=qesp + 4
			Endif
			
			Mitem := Mitem + 1
			Skip
		EndDo	
		
		USE
		AtualList()
		FORM1.Grid1.VALUE:=1
		FORM1.Grid1.SETFOCUS()
	Endif	
	
Return
//------------------------------------------------------------------------------------
Proc BtSalvar_Click()
	Local cFile, x, c1, f
	LOCAL AaRQ    :={}
	LOCAL C_DBF:="" ,C_NTAB:=""

	cFile := Putfile ( { {"Arquivos DBF","*.DBF"} } ,;
						'Salvar Arquivo como...' , GetCurrentFolder() , .f., "MENU.DBF" )

	
						
						
	CFILE := UPPER(CFILE)
	
	If !EMPT(cFile)
		If FILE( cfile )
		    x:= msgyesno("Tem certeza que quer substituir este arquivo?","Arquivo já existe",.f.)
		    if x = .f.
			    return
			ELSE
				if ferase(cfile)  = -1
					msginfo("Arquivo Está Sendo Usado.","Erro ao Apagar o Arquivo")
					return
				endif
			endif	
		Endif
		
		if right(cfile,3) = "DBF"
		    C1:=RAT(".",CFILE)
			C_DBF:=LEFT(CFILE,C1-1)
			
			C1:=RAT("\",C_DBF)
		    C_NTAB:= RIGHT(C_DBF,LEN(C_DBF)-C1)
			
			Aadd( aArq , { 'LINHA'       , 'C' ,  6 , 0 } )
			Aadd( aArq , { 'ID'          , 'C' ,  6 , 0 } )
			Aadd( aArq , { 'MNUPAI'      , 'C' ,  6 , 0 } )
			Aadd( aArq , { 'TIPO'        , 'C' , 12 , 0 } ) // POPUP MENUITEM 	SEPARATOR
			Aadd( aArq , { 'CAPTIONP'    , 'C' , 50 , 0 } )
			Aadd( aArq , { 'CAPTIONE'    , 'C' , 50 , 0 } )
			Aadd( aArq , { 'CAPTIONI'    , 'C' , 50 , 0 } )
			Aadd( aArq , { 'NOME'        , 'C' , 50 , 0 } )
			Aadd( aArq , { 'ACTION'      , 'C' ,200 , 0 } )
			Aadd( aArq , { 'IMAGE'       , 'C' ,100 , 0 } )
			Aadd( aArq , { 'MESSAGEP'    , 'C' ,100 , 0 } )
			Aadd( aArq , { 'MESSAGEE'    , 'C' ,100 , 0 } )
			Aadd( aArq , { 'MESSAGEI'    , 'C' ,100 , 0 } )
			Aadd( aArq , { 'CHECKED'     , 'L' ,  1 , 0 } )
			Aadd( aArq , { 'DISABLED'    , 'L' ,  1 , 0 } )
			DBCreate ( CFILE , aArq  )	
			
			USE &C_DBF NEW
			INDEX ON FIELD->LINHA TO &C_DBF
			
			for F:=1 to len(aListItens)-1
				APPEND BLANK
				REPL LINHA		WITH	STRZERO(F,6)
				REPL ID			WITH	aListItens[f][2]
				REPL MNUPAI		WITH	aListItens[f][3]
				REPL TIPO		WITH	aListItens[f][4]
				REPL CAPTIONP	WITH	aListItens[f][5]
				REPL CAPTIONE	WITH	aListItens[f][6]
				REPL CAPTIONI	WITH	aListItens[f][7]
				REPL NOME		WITH    aListItens[f][8]
				REPL ACTION		WITH	aListItens[f][9]
				REPL IMAGE		WITH	aListItens[f][10]
				REPL MESSAGEP	WITH	aListItens[f][11]
				REPL MESSAGEE	WITH	aListItens[f][12]
				REPL MESSAGEI	WITH	aListItens[f][13]
				REPL CHECKED	WITH	aListItens[f][14]
				REPL DISABLED	WITH	aListItens[f][15]
				COMMIT
			next
			USE
			MSGINFO("GRAVAÇÃO COMPLETA","SALVAR COMO")
		Endif
	Endif
Return
//------------------------------------------------------------------------------------
Proc BtRemover_Click()
	Local fpos:=form1.Grid1.value
    Local ID  :=aListItens[fpos][2]	
    Local Tipo:=aListItens[fpos][4]
    Local fim :=.f., ItemID

	ApagaUmItem(fpos)
	If Tipo = "DEFINE POPUP"
		DO while fim = .f.
			ItemID:=aListItens[fpos][2]  // Id desta linha
			ApagaUmItem(fpos)
			IF ItemID = ID
			    fim := .t.
				// EXIT
			ENDIF
		EndDo		
	Endif
	AtualList()
	FORM1.Grid1.VALUE:=fpos
	FORM1.Grid1.SETFOCUS()
	
Return
//------------------------------------------------------------------------------------
Proc ApagaUmItem(fPos)
    Local f

	for f:=fpos+1 to len(aListItens)
		aListItens[f-1]:= {	aListItens[f][1],aListItens[f][2],aListItens[f][3],;
							aListItens[f][4],aListItens[f][5],aListItens[f][6],;
							aListItens[f][7],aListItens[f][8],aListItens[f][9],;
							aListItens[f][10],aListItens[f][11],aListItens[f][12],;
							aListItens[f][13],aListItens[f][14],aListItens[f][15]}
	Next
	Asize(aListItens,len(aListItens)-1)
return

//------------------------------------------------------------------------------------
Proc Bt_Testar_Click()
	local nIdioma :=QualIdioma()
	
	If nIdioma =0
		return
	Else
		nIdioma-=1
	Endif	
	
    DEFINE WINDOW WinModal AT 0, 0 ;
	WIDTH 500 HEIGHT 300 ;
	TITLE "Menu DBF en tempo de execução" ;
	MODAL
	    MontaMenu(nIdioma)
		DEFINE STATUSBAR
			STATUSITEM "" DEFAULT // area where the messages of the menu are shown
			CLOCK WIDTH 85
			DATE
		END STATUSBAR
		
    END WINDOW

    Center Window WinModal
    Activate Window WinModal
Return
//------------------------------------------------------------------------------------
Proc MontaMenu(nIdioma)
    Local f
    Local cm_tipo
    Local cm_caption
    Local cm_name
    Local cm_action
    Local cm_image
    Local cm_Message
    Local cm_checked
    Local cm_Disabled

		DEFINE MAIN MENU
	        FOR f:= 1 to len(aListItens)-1
				cm_tipo     :=aListItens[f][4]
				cm_caption  :=ALLTRIM(aListItens[f][5+nIdioma])
				cm_name     :=ALLTRIM(aListItens[f][8] )
				cm_action   := iif(EMPT(ALLTRIM(aListItens[f][9])),Nil,aListItens[f][9])
				cm_image    :=IIF(EMPT(ALLTRIM(aListItens[f][10])),NIL,ALLTRIM(aListItens[f][10]))
				cm_Message  :=IIF(EMPT(ALLTRIM(aListItens[f][11])),NIL,ALLTRIM(aListItens[f][11+nIdioma])) 
				cm_checked  :=aListItens[f][14]
				cm_Disabled :=aListItens[f][15]
				
		        If cm_tipo = "DEFINE POPUP"
					DEFINE POPUP cm_caption NAME cm_name
				ELSEIF cm_tipo = "MENUITEM"
					If !cm_checked
						IF cm_Disabled
							if cm_action = nil
								MENUITEM cm_caption ACTION nil NAME cm_name IMAGE cm_image DISABLED MESSAGE cm_Message
							else
								MENUITEM cm_caption ACTION &cm_action NAME cm_name IMAGE cm_image DISABLED MESSAGE cm_Message
							endif	
						Else
							if cm_action = nil
								MENUITEM cm_caption ACTION nil  NAME cm_name IMAGE cm_image MESSAGE cm_Message 
							else
								MENUITEM cm_caption ACTION &cm_action NAME cm_name IMAGE cm_image MESSAGE cm_Message 
							Endif
						Endif	
						
					Else
						IF cm_Disabled
							if cm_action = nil
								MENUITEM cm_caption ACTION nil NAME cm_name IMAGE cm_image CHECKED DISABLED MESSAGE cm_Message
							else
								MENUITEM cm_caption ACTION &cm_action NAME cm_name IMAGE cm_image CHECKED DISABLED MESSAGE cm_Message
							endif	
						ELSE	
							if cm_action = nil
								MENUITEM cm_caption ACTION nil NAME cm_name IMAGE cm_image CHECKED MESSAGE cm_Message 
							else	
								MENUITEM cm_caption ACTION &cm_action NAME cm_name IMAGE cm_image CHECKED MESSAGE cm_Message 
							endif	
						ENDIF	
					Endif
				ELSEIf cm_tipo = "SEPARATOR"
					SEPARATOR
				ELSEIF cm_tipo = "END POPUP"
					END POPUP
				Endif
			next	
			// Use
		END MENU
Return
//------------------------------------------------------------------------------------

Function QualIdioma()
	Local lRet:=0
	
	DEFINE WINDOW FrmIdioma AT 134 , 235 WIDTH 269 HEIGHT 169 TITLE "Escolha o Idioma" MODAL NOSIZE NOSYSMENU 
	    DEFINE FRAME Frame_1
	        ROW    10
	        COL    10
	        WIDTH  240
	        HEIGHT 120
	        FONTNAME "Arial"
	        FONTSIZE 9
	        FONTBOLD .F.
	        FONTITALIC .F.
	        FONTUNDERLINE .F.
	        FONTSTRIKEOUT .F.
	        CAPTION "Idioma"
	    END FRAME

	    DEFINE RADIOGROUP RgIdioma
	        ROW    30
	        COL    20
	        WIDTH  90
	        HEIGHT 75
	        OPTIONS { 'Português','Espanhol','Inglês'}
	        VALUE 1
	        FONTNAME "Arial"
	        FONTSIZE 9
	        TOOLTIP ""
	        FONTBOLD .F.
	        FONTITALIC .F.
	        FONTUNDERLINE .F.
	        FONTSTRIKEOUT .F.
	        SPACING 25
	        BACKCOLOR NIL
	        FONTCOLOR NIL
	    END RADIOGROUP


	    DEFINE BUTTON BtOk
	        ROW    30
	        COL    140
	        WIDTH  100
	        HEIGHT 28
	        CAPTION "Ok"
	        ACTION (lret:=frmIdioma.RgIdioma.value ,frmIdioma.release)
	        FONTNAME "Arial"
	        FONTSIZE 9
	        TOOLTIP ""
	        FONTBOLD .F.
	        FONTITALIC .F.
	        FONTUNDERLINE .F.
	        FONTSTRIKEOUT .F.
	    END BUTTON

	    DEFINE BUTTON BtCancel
	        ROW    70
	        COL    140
	        WIDTH  100
	        HEIGHT 28
	        CAPTION "Cancelar"
	        ACTION frmIdioma.Release
	        FONTNAME "Arial"
	        FONTSIZE 9
	        FONTBOLD .F.
	        FONTITALIC .F.
	        FONTUNDERLINE .F.
	        FONTSTRIKEOUT .F.
	    END BUTTON

	END WINDOW
	frmIdioma.center
	frmIdioma.activate

Return lret

*------------------------------------------------------------
* Ejemplo de definición de menú partiendo de una tabla
* (r) 2006, Roberto Sánchez
*------------------------------------------------------------
Function Salir()
  Release Window WinModal
Return Nil

*------------------------------------------------------------
* Ejemplo de definición de menú partiendo de una tabla
* (r) 2006, Roberto Sánchez
*------------------------------------------------------------
Function AcercaDe()
  MsgInfo(cAcercaDe)
Return Nil
