#include <minigui.ch>
#define CrLf       chr(13)+chr(10)
#define cAcercaDe  "Ejemplo de definición de menú"+CrLf+"en tiempo de ejecución"+CrLf+CrLf+cVersion+CrLf+CrLf+chr(174)+" Abril 2006, Roberto Sánchez"+CrLf+CrLf+MiniGUIVersion()+CrLf+Version()
#define cFaltaMenu "Falta la tabla MenuDBF.DBF","Falta Archivo"
#define cVersion   "Versión 00.00.01"

Static aListItens:={}

Function Main()
	Local cm_tipo
	Local cm_caption
	Local cm_action
	Local cm_name
	Local cm_image
	Local cm_checked
	Local cm_Disabled
	Local cm_Message
	LOCAL bManejadorError, bUltimoManejador, objErr,wret:=.f.
	Local cFile:="Menu.DBF"
	Local c1, c_dbf, f
	Local cm_Idioma:=2
	local lescolha:= .t. 
	
	if !lescolha
		// se remover estas duas linhas vai ocorrer o erro ao clicar no menu current folder e get folder
		 msginfo(getcurrentfolder())
		 msginfo(getfolder())
	Endif	
	
    Set exclusive off
	If file(cfile)
		C1:=RAT(".",CFILE)
		C_DBF:=LEFT(CFILE,C1-1)
		
		USE &C_DBF NEW
		INDEX ON descend(FIELD->LINHA) TO &C_DBF

		Do while !eof()
			AADD(aListItens,{"","","","","","","","","","",.F.,.F.})
			Ains(aListItens,1)
			aListItens[1]:={(Alias())->TIPO,;		// 1
							(Alias())->CAPTIONP,;	// 2
							(Alias())->CAPTIONE,;	// 3
							(Alias())->CAPTIONI,;	// 4
							(Alias())->NOME,;		// 5
							(Alias())->ACTION,;		// 6
							(Alias())->IMAGE,;		// 7
							(Alias())->MESSAGEP,;	// 8	
							(Alias())->MESSAGEE,;	// 9
							(Alias())->MESSAGEI,;	// 10
							(Alias())->CHECKED,; 	// 11
							(Alias())->DISABLED}	// 12
			skip
		Enddo
		USE
	
		DEFINE WINDOW WinMain AT 0, 0 WIDTH 800 HEIGHT 600 TITLE "Menu DBF en tiempo de ejecución" MAIN 
			
			DEFINE MAIN MENU
	        FOR f:= 1 to len(aListItens)
				cm_tipo     :=aListItens[f][1]
				cm_caption  :=ALLTRIM(aListItens[f][2+cm_Idioma])
				cm_name     :=ALLTRIM(aListItens[f][5] )
				cm_action   := iif(EMPT(ALLTRIM(aListItens[f][6])),Nil,alltrim(aListItens[f][6]))
				cm_image    :=IIF(EMPT(ALLTRIM(aListItens[f][7])),NIL,ALLTRIM(aListItens[f][7]))
				cm_Message  :=IIF(EMPT(ALLTRIM(aListItens[f][8+cm_Idioma])),NIL,ALLTRIM(aListItens[f][8+cm_Idioma])) 
				cm_checked  :=aListItens[f][11]
				cm_Disabled :=aListItens[f][12]
				
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
				
			END MENU
			DEFINE STATUSBAR
				STATUSITEM "" DEFAULT 
				CLOCK WIDTH 85
				DATE
			END STATUSBAR
			
		END WINDOW
		
		Center Window WinMain
		Activate Window WinMain
	Else
		MsgStop(cFaltaMenu)
	Endif

Return Nil

*------------------------------------------------------------
* Ejemplo de definición de menú partiendo de una tabla
* (r) 2006, Roberto Sánchez
*------------------------------------------------------------
Function Salir()
  Release Window All
Return Nil

*------------------------------------------------------------
* Ejemplo de definición de menú partiendo de una tabla
* (r) 2006, Roberto Sánchez
*------------------------------------------------------------
Function AcercaDe()
  MsgInfo(cAcercaDe)
Return Nil
