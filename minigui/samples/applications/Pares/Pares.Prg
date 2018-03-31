***********************************************************
* Programa de ejemplo para encontrar figuras pares
* (c) 2014, Roberto Sánchez
* eMail:  jrsancheze@gmail.com
***********************************************************
#include <hmg.ch>

#Define lVerdadero  .T.
#Define lFalso      .F.
#Define NuevaLinea  Chr(13)

Memvar acCargado
Memvar aImagenCtrl, aObjetoCtrl
Memvar nControl
***************************************************
** Función principal
***************************************************
Function Main
  Public acCargado   := Array(12)
  Public aImagenCtrl := Array(2), aObjetoCtrl := Array(2)
  Public nControl := 0
  AFill(aImagenCtrl,"")
  AFill(aObjetoCtrl,"")
  
  Set Language To Spanish
  Set Multiple Off
  Set Navigation Extended

  Load Window Main
  SetProperty("Main","Sizable",.F.)
  ArmarArreglo()
  Main.Center
  Main.Activate
Return Nil

***************************************************
** Función para salir de la aplicación
***************************************************
Procedure Salir()
  Release Window All
Return

***************************************************
** Función para llenar los arreglos de memoria
***************************************************
Procedure ArmarArreglo()
  Local cc, lBuscar, cNumero
  AFill(acCargado,"")
  For cc := 1 to 12
    lBuscar := lVerdadero
    Do While lBuscar
      cNumero := StrZero(Random(12),2)
      If Ascan(acCargado,cNumero) == 0
	  If cNumero<>"00"
            lBuscar := lFalso
          Endif
      Endif
    Enddo
    acCargado[cc] := cNumero
  Next cc
Return

***************************************************
** Función para mostrar las imágenes en la ventana
***************************************************
Procedure Mostrar(cCargado, cObjeto)
  Local cc, lCont, cFigura := "Fig"+cCargado
  SetProperty("Main",cObjeto,"Picture",cFigura)
  SetProperty("Main",cObjeto,"Enabled",lFalso)
  DoMethod("Main",cObjeto,"Refresh")

  If nControl < 2
    Do Case
      Case cCargado == "07"
        cCargado := "01"
      Case cCargado == "08"
        cCargado := "02"
      Case cCargado == "09"
        cCargado := "03"
      Case cCargado == "10"
        cCargado := "04"
      Case cCargado == "11"
        cCargado := "05"
      Case cCargado == "12"
        cCargado := "06"
    EndCase
    nControl += 1
    aImagenCtrl[nControl] := cCargado
    aObjetoCtrl[nControl] := cObjeto
  Endif

  InkeyGui(500)

  If aImagenCtrl[1] == aImagenCtrl[2] .And. nControl == 2
    SetProperty("Main",aObjetoCtrl[1],"Visible",lFalso)
    SetProperty("Main",aObjetoCtrl[2],"Visible",lFalso)
    AFill(aImagenCtrl,"")
    AFill(aObjetoCtrl,"")
    nControl := 0
  Endif

  If aImagenCtrl[1] <> aImagenCtrl[2] .And. nControl == 2
    SetProperty("Main",aObjetoCtrl[1],"Picture","Oculto")
    SetProperty("Main",aObjetoCtrl[2],"Picture","Oculto")
    SetProperty("Main",aObjetoCtrl[1],"Enabled",lVerdadero)
    SetProperty("Main",aObjetoCtrl[2],"Enabled",lVerdadero)
    AFill(aImagenCtrl,"")
    AFill(aObjetoCtrl,"")
    nControl := 0
  Endif

  For cc:=1 to 12
    lCont := GetProperty("Main","IMG_"+StrZero(cc,2),"Visible")
    If lCont
      Exit
    Endif
  Next cc
  If !lCont
    MsgBox("Game is Over!","Fin...")
  Endif
Return

***************************************************
** Función para reiniciar el juego
***************************************************
Procedure Reiniciar()
  Local cc, cObjeto
  AFill(aImagenCtrl,"")
  aFill(aObjetoCtrl,"")
  nControl := 0
  ArmarArreglo()
  For cc:=1 to 12
    cObjeto:=StrZero(cc,2)
	SetProperty("Main","IMG_"+cObjeto,"Picture","Oculto")
	SetProperty("Main","IMG_"+cObjeto,"Enabled",lVerdadero)
    SetProperty("Main","IMG_"+cObjeto,"Visible",lVerdadero)
  Next cc
Return

Procedure AcercaDe()
  MsgBox("(c) 2014, Roberto Sanchez"+NuevaLinea+"eMail: jrsancheze@gmail.com", "Derechos...")
Return
