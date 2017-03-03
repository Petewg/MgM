***Creado por Jose Miguel -Valencia (España) <josemisu@yahoo.com.ar>***

#include "minigui.ch"
#include "winprint.ch"

memvar aDatosFac

PROCEDURE main()
   local N

   ***CODIGO DE PAGINA español***
   REQUEST HB_CODEPAGE_ESWIN
   HB_SETCODEPAGE("ESWIN")

   ***Inicializacion RDD DBFCDX Nativo***
   REQUEST DBFCDX , DBFFPT
   RDDSETDEFAULT( "DBFCDX" )
   SET AUTOPEN OFF //no abrir los indices automaticamente

   ***DATOS DE INICIALIZACION***
   Set Navigation Extended //TAB y ENTER
   SET DATE FORMAT "dd-mm-yyyy"
   SET EPOCH TO YEAR(DATE())-50

   ***crear datos para este ejemplo***
   aDatosFac:={}
   FOR N=1 TO 7
      AADD(aDatosFac,{"Codigo "+LTRIM(STR(N)),"Articulo "+LTRIM(STR(N)),N,N*10,N+7})
   NEXT
   ***fin crear datos para este ejemplo***

factura()

RETURN

Function Factura()

   DEFINE WINDOW W_Imp1 ;
      AT 10,10 ;
      WIDTH 400 HEIGHT 275 ;
      TITLE 'SUIZO Factura v1.0' ;
      MAIN

      @ 10,10 LABEL Texto1 VALUE "Impresion de una factura"       AUTOSIZE FONT "Arial" SIZE 14 TRANSPARENT
      @ 40,10 LABEL Texto2 VALUE "con una mascara de Open Office" AUTOSIZE FONT "Arial" SIZE 14 TRANSPARENT

      @ 80,10 BUTTON B_Acerca CAPTION 'Aceca de' WIDTH 90 HEIGHT 25 ;
              ACTION Acercade()

      @210, 10 BUTTON B_Imprimir CAPTION 'Imprimir' WIDTH 90 HEIGHT 25 ;
               ACTION Facturai()

      @210,110 BUTTON B_Salir CAPTION 'Salir'  WIDTH 80 HEIGHT 25 ;
               ACTION W_Imp1.release

      END WINDOW
      CENTER WINDOW W_Imp1
      ACTIVATE WINDOW W_Imp1

Return Nil

procedure Facturai()
local oServiceManager,oDesktop,oDocument,oVCurs,oPageStyleName,oPageStyles,oStyle,oCursor
local MARGENSUP:=10,MARGENINF:=10,MARGENIZQ:=10,MARGENDER:=10,TOTAL1:=0
local FicheroMas2, N, TOTLIN

   // inicializa
   oServiceManager := TOleAuto():New("com.sun.star.ServiceManager")
   oDesktop := oServiceManager:createInstance("com.sun.star.frame.Desktop")
   IF oDesktop = NIL
      MsgStop('OpenOffice Writer no esta disponible')
      RETURN
   ENDIF

   FicheroMas2:=GetCurrentFolder()+"\factura.odt"
   IF FILE(FicheroMas2)
      FicheroMas2:="file:///"+FicheroMas2
      oDocument := oDesktop:loadComponentFromURL(FicheroMas2,"_blank", 0, {})
   ELSE
      oDocument := oDesktop:loadComponentFromURL("private:factory/swriter","_blank", 0, {})
   ENDIF

   oVCurs:= oDocument:CurrentController:getViewCursor() 
   oPageStyleName:= oVCurs:PageStyleName
   oPageStyles:= oDocument:StyleFamilies:getByName("PageStyles")
   oStyle := oPageStyles:getByName(oPageStyleName)
   oStyle:TopMargin   := MARGENSUP*100
   oStyle:BottomMargin:= MARGENINF*100
   oStyle:LeftMargin  := MARGENIZQ*100
   oStyle:RightMargin := MARGENDER*100

   oCursor := oDocument:Text:CreateTextCursor()
   oCursor:CharFontName:="Courier"
   oCursor:CharHeight:=10
   oCursor:CharWeight:=150

   FOR N=1 TO 10
      oDocument:Text:InsertString(oCursor, CHR(13) , .F.)
   NEXT

   oCursor:CharHeight:=10
   oDocument:Text:InsertString(oCursor, SPACE(45)+"Nombre comercial"+CHR(13) , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(45)+"Nombre fiscal"+CHR(13) , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(45)+"Direccion"+CHR(13) , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(45)+"Poblacion"+CHR(13) , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(45)+"Provincia"+CHR(13) , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(45)+"A/A Sr. Nombre persona"+CHR(13) , .F.)

   FOR N=1 TO 6
      oDocument:Text:InsertString(oCursor, CHR(13) , .F.)
   NEXT

   *** DATOS CABECERA ***
   oCursor:CharHeight:=8
   oDocument:Text:InsertString(oCursor, CHR(13) , .F.)

   oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
   oDocument:Text:InsertString(oCursor, "Albaran numero    " , .F.)
   oDocument:Text:InsertString(oCursor, PADR("125-A",8," ") , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(9) , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Cliente codigo  " , .F.)
   oDocument:Text:InsertString(oCursor, STR(16,5) , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(16) , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Agencia  " , .F.)
   oDocument:Text:InsertString(oCursor, "Transporte"+CHR(13) , .F.)

   oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
   oDocument:Text:InsertString(oCursor, "Albaran fecha     " , .F.)
   oDocument:Text:InsertString(oCursor, "22-05-2009" , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(7) , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Cliente NIF     " , .F.)
   oDocument:Text:InsertString(oCursor, "12345678A" , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(12) , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Portes   " , .F.)
   oDocument:Text:InsertString(oCursor, "Debidos"+CHR(13) , .F.)

   oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
   oDocument:Text:InsertString(oCursor, "Hoja numero       " , .F.)
   oDocument:Text:InsertString(oCursor, STR(1,3) , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(14) , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Cliente Telef.  " , .F.)
   oDocument:Text:InsertString(oCursor, "555 555 555" , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(10) , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Bultos   " , .F.)
   oDocument:Text:InsertString(oCursor, STR(1,3)+CHR(13) , .F.)


   oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
   oDocument:Text:InsertString(oCursor, "Vendedor          " , .F.)
   oDocument:Text:InsertString(oCursor, PADR("7-Pedro",17," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Cliente Fax     " , .F.)
   oDocument:Text:InsertString(oCursor, "555 555 556" , .F.)
   oDocument:Text:InsertString(oCursor, SPACE(10) , .F.)
   oDocument:Text:InsertString(oCursor, " "+"Telef.   " , .F.)
   oDocument:Text:InsertString(oCursor, "555 555 557"+CHR(13) , .F.)

   *** CABECERA ***

   oDocument:Text:InsertString(oCursor, CHR(13) , .F.)

   oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
   oDocument:Text:InsertString(oCursor,     PADC("PEDIDO",7," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADC("CODIGO",11," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADC("ARTICULO",31," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADC("GRUPOS",12," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADC("UNIDADES",14," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADC("PRECIO",14," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADC("IMPORTE",15," ")+CHR(13) , .F.)


   oDocument:Text:InsertString(oCursor, CHR(13) , .F.)

   *** CUERPO ***
   FOR N=1 TO LEN(aDatosFac)
      oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
      oDocument:Text:InsertString(oCursor, PADL("45",7," ") , .F.)
      oDocument:Text:InsertString(oCursor, " "+PADR(aDatosFac[N,1],11," ") , .F.)
      oDocument:Text:InsertString(oCursor, " "+PADR(aDatosFac[N,2],30," ") , .F.)
      oDocument:Text:InsertString(oCursor, " "+STR(aDatosFac[N,3],11)+SPACE(3) , .F.)
      oDocument:Text:InsertString(oCursor, " "+STR(aDatosFac[N,4],13,2)+" " , .F.)
      oDocument:Text:InsertString(oCursor, " "+STR(aDatosFac[N,5],13,2)+" " , .F.)
      TOTLIN:=ROUND(aDatosFac[N,4]*aDatosFac[N,5],2)
      TOTAL1:=TOTAL1+TOTLIN
      oDocument:Text:InsertString(oCursor, " "+STR(TOTLIN,13,2) , .F.)
      oDocument:Text:InsertString(oCursor, CHR(13) , .F.)
   NEXT

   FOR N=1 TO 20-LEN(aDatosFac)
      oDocument:Text:InsertString(oCursor, CHR(13) , .F.)
   NEXT

   oDocument:Text:InsertString(oCursor, CHR(13) , .F.)

   oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
   oDocument:Text:InsertString(oCursor, PADR("FORMA DE PAGO:",27," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADL("S U M A ",12," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADL("DESCUENTO",12," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADL("BASE IMP. ",12," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADL("I.V.A. 16%",12," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADL("REC.EQUIV.",12," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+PADL("TOTAL FACTURA",17," ") , .F.)
   oDocument:Text:InsertString(oCursor, CHR(13) , .F.)

   oDocument:Text:InsertString(oCursor, SPACE(1) , .F.)
   oDocument:Text:InsertString(oCursor, PADR("Giro 60 dias",27," ") , .F.)
   oDocument:Text:InsertString(oCursor, " "+STR(TOTAL1,12,2) , .F.)
   oDocument:Text:InsertString(oCursor, " "+STR(0,12,2) , .F.)
   oDocument:Text:InsertString(oCursor, " "+STR(TOTAL1,12,2) , .F.)
   oDocument:Text:InsertString(oCursor, " "+STR(TOTAL1*0.16,12,2) , .F.)
   oDocument:Text:InsertString(oCursor, " "+STR(0,12,2) , .F.)
   oDocument:Text:InsertString(oCursor, " "+STR(TOTAL1*1.16,12,2) , .F.)
   oDocument:Text:InsertString(oCursor, " euro" , .F.)
   oDocument:Text:InsertString(oCursor, CHR(13) , .F.)
   oDocument:Text:InsertString(oCursor, CHR(13) , .F.)


Function Acercade()
RETURN MSGINFO("Creado por Jose Miguel -Valencia (España)"+HB_OsNewLine()+"<josemisu@yahoo.com.ar>"+HB_OsNewLine()+HB_OsNewLine()+ ;
   hb_compiler()+HB_OsNewLine()+Version()+HB_OsNewLine()+MiniGuiVersion(),W_Imp1.Title)
