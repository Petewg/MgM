****************************************************************************
* PROGRAMA: READ THE KEYBOARD 
* LENGUAJE: HARBOUR-MINIGUI
* FECHA:    13 ABRIL 2010
* AUTOR:    CLAUDIO SOTO
* PAIS:     URUGUAY
* E-MAIL:   srvet@adinet.com.uy
****************************************************************************

***************************************************************************************************
* DESCRIPTION
*
* Read keyboard input entries and returns information about the key pressed.
* These functions intercept keyboard messages from the system will send the application
* (WM_KEYUP and WM_KEYDOWN) and stores information about the virtual key generated.
*
***************************************************************************************************
* DESCRIPCION
*
* Lee las entradas entradas del teclado y devuelve informacion sobre la tecla presionada. 
* Estas funciones interceptan los mensajes de teclado que el sistema le envia a la aplicacion 
* (WM_KEYUP y WM_KEYDOWN) y almacena informacion sobre la tecla virtual generada.  
*
***************************************************************************************************

***************************************************************************************************
* SYNTAX:
*
* INSTALL_READ_KEYBOARD ()   // Install the "driver" that reads the keyboard (returns. T. if successful) 
* UNINSTALL_READ_KEYBOARD () // Uninstall the "driver" that reads the keyboard (returns. T. if successful)
*
* GET_LAST_VK()              // Returns the virtual value (VK Code) of the key pressed 
* GET_LAST_VK_NAME()         // Returns the name of the virtual key press
*
* GET_STATE_VK_SHIFT ()      // Returns. T. if SHIFT key is pressed
* GET_STATE_VK_CONTROL ()    // Returns. T. if CONTROL key is pressed
* GET_STATE_VK_ALT ()        // Returns. T. if ALT key is pressed
*
* PAUSE_READ_VK (.T.)        // Pause reading keyboard in order to process the key pressed
* PAUSE_READ_VK (.F.)        // Restore keyboard reading after the pause
*
***************************************************************************************************
* SINTAXIS:
*
* INSTALL_READ_KEYBOARD ()   // Instala el manejador que lee el teclado (Retorna .T. si tiene exito) 
* UNINSTALL_READ_KEYBOARD () // Desinstala el manejador que lee el teclado (Retorna .T. si tiene exito)
*
* GET_LAST_VK()              // Retorna el valor virtual (VK Code) de la tecla presionada 
* GET_LAST_VK_NAME()         // Retorna el nombre de la tecla virtual presionado
*
* GET_STATE_VK_SHIFT ()      // Retorna .T. si la tecla SHIFT esta presionada
* GET_STATE_VK_CONTROL ()    // Retorna .T. si la tecla CONTROL esta presionada
* GET_STATE_VK_ALT ()        // Retorna .T. si la tecla ALT esta presionada
*
* PAUSE_READ_VK (.T.)        // Pausa la lectura del teclado para poder procesar la tecla presionada
* PAUSE_READ_VK (.F.)        // Restablece la lectura del teclado luego de la pausa
*
***************************************************************************************************


#include "minigui.ch"

Procedure Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 600 ;
      TITLE 'READ THE KEYBOARD' ;
      MAIN ;
      ON RELEASE On_Release()

      @  10 , 10 LABEL Label_1 AUTOSIZE BOLD FONTCOLOR RED
      @  40 , 10 LABEL Label_2 AUTOSIZE BOLD FONTCOLOR RED

      @  80 , 10 LABEL Label_3 AUTOSIZE BOLD FONTCOLOR BLUE
      @ 120 , 10 LABEL Label_4 AUTOSIZE BOLD FONTCOLOR BLUE
      @ 160 , 10 LABEL Label_5 AUTOSIZE BOLD FONTCOLOR BLUE

      @ 200 , 10 LABEL Label_6 AUTOSIZE BOLD FONTCOLOR BROWN
      @ 240 , 10 LABEL Label_7 AUTOSIZE BOLD FONTCOLOR BROWN
      @ 280 , 10 LABEL Label_8 AUTOSIZE BOLD FONTCOLOR BROWN
    
      @ 380 , 10 LABEL Label_10 VALUE "Presionar SHIFT + A abre Caja Dialogo" AUTOSIZE BOLD
      
      @ 420 , 10 LABEL Label_9 AUTOSIZE BOLD
       
      @ 450 , 10 EDITBOX EditBox_1  WIDTH 200 HEIGHT 100 VALUE "Escribir algo" 

      IF INSTALL_READ_KEYBOARD() == .F.
         MsgInfo ("ERROR al instalar READ_KEYBOARD")
      ELSE
         DEFINE TIMER timer_1 OF Form_1 INTERVAL 100 ACTION Mostrar_Tecla()
      ENDIF
      
   END WINDOW

   Form_1.Center 

   Form_1.Activate 

Return


Procedure On_Release

   IF UNINSTALL_READ_KEYBOARD() == .F.
      MsgInfo ("ERROR al desinstalar READ_KEYBOARD")
   ENDIF
            
Return


Procedure Mostrar_Tecla

  Form_1.Label_1.Value := "VK Code:             " + hb_ntos (GET_LAST_VK())
  Form_1.Label_2.Value := "VK Name:             " + GET_LAST_VK_NAME()

  Form_1.Label_3.Value := "SHIFT presionado:    " + IF (GET_STATE_VK_SHIFT()   == .T., "Si", "No")
  Form_1.Label_4.Value := "CONTROL presionado:  " + IF (GET_STATE_VK_CONTROL() == .T., "Si", "No")
  Form_1.Label_5.Value := "ALT presionado:      " + IF (GET_STATE_VK_ALT()     == .T., "Si", "No")

  Form_1.Label_6.Value := "CAPS LOCK activado:  " + IF (IsCapsLockActive()     == .T., "Si", "No") // HMG function
  Form_1.Label_7.Value := "NUM LOCK activado:   " + IF (IsNumLockActive()      == .T., "Si", "No") // HMG function
  Form_1.Label_8.Value := "INSERT activado:     " + IF (IsInsertActive()       == .T., "Si", "No") // HMG function

  IF (GET_STATE_VK_SHIFT() == .T. .OR. IsCapsLockActive() == .T.) .AND. GET_LAST_VK() <> 0
      Form_1.Label_9.Value := "Escribiendo en MAYUSCULAS"
  ELSE
      Form_1.Label_9.Value := "Escribiendo en MINISCULAS"
  ENDIF

  IF GET_LAST_VK() == 65 .AND. GET_STATE_VK_SHIFT() == .T.  //  VK code de A = 65
      PAUSE_READ_VK (.T.) // pausa la lectura del teclado
      Form_1.Timer_1.Enabled := .F.
       
      Msginfo ("Procesar la accion de la tecla SHIFT + A")
      
      Form_1.Timer_1.Enabled := .T.
      PAUSE_READ_VK (.F.) // restablece la lectura del teclado
  ENDIF

Return


*##################################################################################################
*   FUNCIONES EN C        
*##################################################################################################

#pragma begindump

#include <windows.h>
#include "hbapi.h"

HB_BOOL flag_hhk = FALSE;
HB_BOOL PAUSE_hhk = FALSE;
HHOOK hhk = NULL;
HB_LONG VK_PRESIONADO = 0;
HB_LONG VK_lParam = 0;


LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
{
    if (nCode < 0) 
        return CallNextHookEx(hhk, nCode, wParam, lParam);
        
    if (PAUSE_hhk == FALSE)
    {   VK_PRESIONADO = (long) wParam;
        VK_lParam = (LONG) lParam;
    }
    else    
    {   VK_PRESIONADO = 0;
        VK_lParam = 0;
    }   
    
    return CallNextHookEx(hhk, nCode, wParam, lParam);
}


HB_FUNC (GET_STATE_VK_SHIFT)
{
   if (GetKeyState(VK_SHIFT) & 0x8000)
       hb_retl (TRUE); 
   else    
       hb_retl (FALSE);
}


HB_FUNC (GET_STATE_VK_CONTROL)
{
   if (GetKeyState(VK_CONTROL) & 0x8000)
       hb_retl (TRUE); 
   else    
       hb_retl (FALSE);
}


HB_FUNC (GET_STATE_VK_ALT)
{
   if (GetKeyState(VK_MENU) & 0x8000)
       hb_retl (TRUE); 
   else    
       hb_retl (FALSE);
}


HB_FUNC (GET_LAST_VK)
{
   if (flag_hhk == TRUE)
       hb_retnl (VK_PRESIONADO);
   else
      hb_retnl (0);    
}


HB_FUNC (GET_LAST_VK_NAME)
{
   CHAR cadena [128];

   if (flag_hhk == TRUE)
      {  GetKeyNameText (VK_lParam, (LPTSTR) &cadena, 128);
         hb_retc (cadena);
      }
   else
      hb_retc ("");    
}


HB_FUNC (PAUSE_READ_VK)
{
   if (hb_pcount () == 1 && hb_parinfo (1) == HB_IT_LOGICAL)   
   {   if (hb_parl (1) == TRUE) 
       {   VK_PRESIONADO = 0;
           VK_lParam = 0;
       }     
       PAUSE_hhk = hb_parl (1);
   }
}


HB_FUNC (INSTALL_READ_KEYBOARD)
{
   if (flag_hhk == FALSE)
   {    hhk = SetWindowsHookEx (WH_KEYBOARD, KeyboardProc, (HINSTANCE) NULL, GetCurrentThreadId());
        
        if (hhk == NULL) 
            hb_retl (FALSE);
        else
        {   flag_hhk = TRUE;    
            hb_retl (TRUE);                       
        }   
   }
   else
      hb_retl (TRUE);      
}


HB_FUNC (UNINSTALL_READ_KEYBOARD)
{
   if (flag_hhk == TRUE)
   {   if (UnhookWindowsHookEx (hhk) == TRUE)
       {   flag_hhk = FALSE;
           hb_retl (TRUE);           
       }
       else
           hb_retl (FALSE);   
   }
   else
      hb_retl (TRUE);      
}

#pragma enddump
