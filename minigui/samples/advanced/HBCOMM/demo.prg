/*         IDE: HMI+
 * Description: Serial Port sample
 *      Author: Marcelo Torres <lichitorres@yahoo.com.ar>
 *        Date: 2006.08.29
*/

#include 'minigui.ch'

Static nHandle
Static lConectado := .f.
Static lOcupado   := .f.
Static cRecibe    := ""
Static buffer     := 0
Static cTemp      := ""

*------------------------------------------------------*
Function Main()
*------------------------------------------------------*

Load window main
Center window main
Activate window main

Return NIL


*------------------------
Static Procedure fConecta()
*------------------------
local f_Com       := "COM1"
local f_BaudeRate := 19200 
local f_databits  := 8
local f_parity    := 0  //ninguno
local f_stopbit   := 1
local f_Buff      := 8000

nHandle := Init_Port( f_Com, f_BaudeRate, f_databits, f_parity, f_stopbit, f_Buff  )
If nHandle > 0
   MsgInfo("Conectado...","hbcomm")
   main.timer_1.enabled := .t.
   main.button_1.enabled :=.f.
   lConectado := .t.
   OutBufClr(nHandle)
Else
   MsgStop("Verifique los valores, no se puede establecer la conexion","hbcomm")
   lConectado := .f.
EndIf

Return


*------------------------
Static Procedure fEnvia()
*------------------------
local cEnvio := main.edit_2.value

If lConectado .and. !Empty(cEnvio) .and. IsWorking(nHandle)
   OutChr(nHandle,cEnvio)
Else
   MsgStop("No se pueden enviar datos","Envio")   
Endif   

Return


*------------------------
Static Procedure fRecibe()
*------------------------

While lOcupado
  do events
Enddo

buffer  := InbufSize(nHandle)

If buffer > 0

  lOcupado := .t.
  
  cRecibe := main.edit_1.value 
  cTemp := Substr(InChr(nHandle,buffer),1,buffer)
     
  cRecibe += cTemp   
  main.edit_1.value := cRecibe
  
  lOcupado := .f.
  
Endif  

Return


*------------------------
Static Procedure fDesconecta()
*------------------------
lConectado := .f.
main.timer_1.enabled := .f.
main.button_1.enabled :=.t.
UnInt_Port(nHandle)
main.edit_1.value := Space(32000)

Return


*------------------------
Static Procedure fSale()
*------------------------
If lConectado
   fDesconecta()
Endif

Release Window Main

Return
