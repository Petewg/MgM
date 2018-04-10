/****************************************************
* Rutinas que nos permiten averiguar y/o modificar la
* velocidad que parpadea el cursor en controles como:
* TEXTBOX, etc.
* autor : WALTER <walhug@yahoo.com.ar>
* Fecha de creaci¢n: 29/10/2005
****************************************************/

/*
 *  GetCaretBlinkTime()
 *  Rutina para averiguar a que velocidad
 *  parpadea el cursor.
 *
 *  Devuelve:
 *  --------
 *  <nNbr> => Un numero (Milisegundos) que representan
 *  la velocidad que parpadea el cursor.
 *
 *  Sintaxis:
 *  --------
 *  GetCaretBlinkTime() -> <nNbr>
 *
 *  Ejemplo:
 *  ---------
 *  Ver Blinky.prg
 *
 *  Fuente:
 *  -------
 *  H_V_CRS.PRG
 *
 */
DECLARE DLL_TYPE_LONG GetCaretBlinkTime() IN User32.Dll

/*
 *  SetCaretBlinkTime()
 *  Rutina para cambiar la velocidad con que  parpadea
 *  el Cursos. Si se le pasa un n£mero <nNbr> negativo
 *  anula el parpadeo.
 *  Los numeros <nNbr> mas chicos aceleran el parpadeo
 *  y los m s grandes lo relentizan.
 *
 *  Devuelve:
 *  --------
 *  Nada.
 *
 *  Sintaxis:
 *  --------
 *  SetCaretBlinkTime( <nNbr> ) -> <Nil>
 *
 *  Ejemplo:
 *  ---------
 *  Ver Blinky.prg
 *
 *  Fuente:
 *  -------
 *  H_V_CRS.PRG
 *
 */
DECLARE DLL_TYPE_LONG SetCaretBlinkTime(DLL_TYPE_LONG wMSeconds) ;
	IN User32.dll
