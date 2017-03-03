#include "minigui.ch"

PROCEDURE Main()
   LOCAL aDir := {}

   SET DATE FORMAT "dd-mm-yyyy"
   SET EPOCH TO YEAR(DATE())-50

   SET NAVIGATION EXTENDED

   DEFINE WINDOW Ventana1 ;
      AT 0,0 ;
      WIDTH 800 ;
      HEIGHT 600 ;
      TITLE "Programa de aplicaciones" ;
      MAIN ;
      NOMAXIMIZE NOSIZE

      @015,020 LABEL L_Ruta1 VALUE 'Ruta:' AUTOSIZE TRANSPARENT
      @010,100 TEXTBOX T_Ruta1 ;
         WIDTH 670 ;
         VALUE GetCurrentFolder() ;
         TOOLTIP 'Ruta a buscar'

      @040,100 BUTTON Bt_Buscardir1 ;
         CAPTION 'Buscar direcctorio' ;
         WIDTH 175 HEIGHT 25 ;
         ACTION Ventana1.T_Ruta1.Value:= GetFolder("Carpetas",Ventana1.T_Ruta1.Value)

      @075,020 LABEL L_Extension VALUE 'Extension:' AUTOSIZE TRANSPARENT
      @070,100 TEXTBOX T_Extension ;
         WIDTH 100 ;
         VALUE '*.*' ;
         TOOLTIP 'Ruta a buscar'

      @070,300 BUTTON Bt_Buscarfic1 ;
         CAPTION 'Buscar ficheros' ;
         WIDTH 175 HEIGHT 25 ;
         ACTION llenarBR_Fic()

      AEval(Directory(Ventana1.T_Ruta1.Value + "\*.*"), {|e| Aadd( aDir, {GetCurrentFolder()+"\"+e[1],STR(e[2]),DTOC(e[3]),e[4],e[5]} )})

      @075,600 LABEL L_Total VALUE 'Total ficheros:'+LTRIM(STR(LEN(aDIR))) AUTOSIZE TRANSPARENT

      @100,020 GRID BR_Fic ;
      HEIGHT 400 ;
      WIDTH 750 ;
      TOOLTIP 'Ficheros' ;
      HEADERS { 'Fichero', 'Tamaño', 'Fecha', 'Hora', 'Atributos' } ;
      WIDTHS { 400, 100, 80, 70, 70 } ;
      ITEMS aDir ;
      JUSTIFY {BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER} ;
      VALUE 1

   END WINDOW

   CENTER WINDOW Ventana1
   ACTIVATE WINDOW Ventana1

RETURN

STATIC FUNCTION llenarBR_Fic()
   LOCAL n, cDir := IF(RIGHT(Ventana1.T_Ruta1.Value,1)=='\',LEFT(Ventana1.T_Ruta1.Value,LEN(Ventana1.T_Ruta1.Value)-1),Ventana1.T_Ruta1.Value)
   LOCAL aDir := DirectoryRecurse(cDir+"\"+Ventana1.T_Extension.Value)

   Ventana1.BR_Fic.DeleteAllItems
   Ventana1.L_Total.Value:='Total ficheros: '+LTRIM(STR(LEN(aDIR)))

   IF LEN(aDIR)>0
      Ventana1.BR_Fic.DisableUpdate
      FOR N=1 TO LEN(aDIR)
         Ventana1.BR_Fic.AddItem({aDIR[N,1],STR(aDIR[N,2]),DTOC(aDIR[N,3]),aDIR[N,4],aDIR[N,5]})
      NEXT
      Ventana1.BR_Fic.EnableUpdate
   ENDIF

   Ventana1.BR_Fic.Refresh

RETURN NIL
