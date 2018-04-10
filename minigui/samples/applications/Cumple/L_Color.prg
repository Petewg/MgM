FUNCTION MiColor(NomColor)
LOCAL Numcolor
   ***COLORES***
   DO CASE
   CASE UPPER(NomColor)=="AMARILLO"
      Numcolor:={255,255,  0}
   CASE UPPER(NomColor)=="AMARILLOSUAVE"
      Numcolor:={255,255,100}
   CASE UPPER(NomColor)=="AMARILLOPALIDO"
      Numcolor:={255,255,150}
   CASE UPPER(NomColor)=="AMARILLOCLARO"
      Numcolor:={255,255,200}
   CASE UPPER(NomColor)=="AMARILLOHUEVO"
      Numcolor:={255,225,100}
   CASE UPPER(NomColor)=="AMARILLOCUMPLE"
      Numcolor:={255,225,150}
   CASE UPPER(NomColor)=="ARENA"
      Numcolor:={255,200,150}
   CASE UPPER(NomColor)=="AZUL"
      Numcolor:={  0,  0,255}
   CASE UPPER(NomColor)=="AZULCLARO"
      Numcolor:={200,200,255}
   CASE UPPER(NomColor)=="AZULPALIDO"
      Numcolor:={150,150,248}
   CASE UPPER(NomColor)=="BLANCO"
      Numcolor:={255,255,255}
   CASE UPPER(NomColor)=="CIAN"
      Numcolor:={  0,255,255}
   CASE UPPER(NomColor)=="GRIS"
      Numcolor:={225,225,225}
   CASE UPPER(NomColor)=="GRISCLARO"
      Numcolor:={200,200,200}
   CASE UPPER(NomColor)=="KAKI"
      Numcolor:={200,255,225}
   CASE UPPER(NomColor)=="NARANJA"
      Numcolor:={255,225,125}
   CASE UPPER(NomColor)=="NARANJAFUERTE"
      Numcolor:={255,100,  0}
   CASE UPPER(NomColor)=="MALVA"
      Numcolor:={225,225,255}
   CASE UPPER(NomColor)=="MARRON"
      Numcolor:={153,102, 51}
   CASE UPPER(NomColor)=="NEGRO"
      Numcolor:={  0,  0,  0}
   CASE UPPER(NomColor)=="ROJO"
      Numcolor:={255,  0,  0}
   CASE UPPER(NomColor)=="ROJOCLARO"
      Numcolor:={255,200,200}
   CASE UPPER(NomColor)=="ROJOCUMPLE"
      Numcolor:={255,150,150}
   CASE UPPER(NomColor)=="ROJORUBI"
      Numcolor:={153,  0,  0}
   CASE UPPER(NomColor)=="ROSACLARO"
      Numcolor:={255,225,225}
   CASE UPPER(NomColor)=="ROSAPALIDO"
      Numcolor:={255,153,153}
   CASE UPPER(NomColor)="TURQUESA"
      Numcolor:={100,255,200}
   CASE UPPER(NomColor)=="VERDE"
      Numcolor:={  0,255,  0}
   CASE UPPER(NomColor)=="VERDECLARO"
      Numcolor:={200,255,200}
   CASE UPPER(NomColor)=="VERDESUAVE"
      Numcolor:={100,255,100}
   CASE UPPER(NomColor)=="VERDEPALIDO"
      Numcolor:={150,255,150}
   CASE UPPER(NomColor)=="VIOLETACLARO"
      Numcolor:={255,200,255}
   OTHERWISE
      Numcolor:={255,255,255} //blanco
*      Numcolor:={236,233,216} //color windows
   ENDCASE
RETURN(Numcolor)

***COLORES PARA OPENOFFICE
*oCell:CellBackColor:=RGB(255,0,0) //AZUL
*oCell:CellBackColor:=RGB(0,255,0) //VERDE
*oCell:CellBackColor:=RGB(0,0,255) //ROJO
***FIN COLORES PARA OPENOFFICE


PROCEDURE PONER_COLOR()
LOCAL Ncolor
MEMVAR MiColor
public MiColor:={}
FOR Ncolor=0 TO 28
   AADD(MiColor,{ GetRed  ( GetSysColor(Ncolor) ) , ;
                  GetGreen( GetSysColor(Ncolor) ) , ;
                  GetBlue ( GetSysColor(Ncolor) ) } )
NEXT
/*
aColors := { "COLOR_SCROLLBAR" ,;
      "COLOR_BACKGROUND" ,;
      "COLOR_ACTIVECAPTION" ,;
      "COLOR_INACTIVECAPTION" ,;
      "COLOR_MENU" ,;
      "COLOR_WINDOW" ,;
      "COLOR_WINDOWFRAME" ,;
      "COLOR_MENUTEXT" ,;
      "COLOR_WINDOWTEXT" ,;
      "COLOR_CAPTIONTEXT" ,;
      "COLOR_ACTIVEBORDER" ,;
      "COLOR_INACTIVEBORDER" ,;
      "COLOR_APPWORKSPACE" ,;
      "COLOR_HIGHLIGHT" ,;
      "COLOR_HIGHLIGHTTEXT" ,;
      "COLOR_BTNFACE" ,;
      "COLOR_BTNSHADOW" ,;
      "COLOR_GRAYTEXT" ,;
      "COLOR_BTNTEXT" ,;
      "COLOR_INACTIVECAPTIONTEXT",;
      "COLOR_BTNHIGHLIGHT",;
      "COLOR_3DDKSHADOW",;
      "COLOR_3DLIGHT",;
      "COLOR_INFOTEXT",;  // tooltip text
      "COLOR_INFOBK",;  // tooltip background
      "COLOR_BTNALTERNATEFACE" ,;
      "COLOR_HOTLIGHT",;
      "COLOR_GRADIENTACTIVECAPTION",;
      "COLOR_GRADIENTINACTIVECAPTION";
       }
*/
RETURN
