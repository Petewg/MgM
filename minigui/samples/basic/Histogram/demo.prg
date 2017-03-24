/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 MigSoft <fugaz_cl@yahoo.es>
*/

#include <hmg.ch>

#xtranslate PRINT GRAPH [ OF ] <windowname> ;
	[ <lpreview : PREVIEW> ] ;
	[ <ldialog : DIALOG> ] ;
=>;
	printgraph ( <"windowname"> , <.lpreview.> , <.ldialog.> )

Static aSer, aClr, aSern, aYVal, cTit

*-----------------------------------------------------------------------------*
Function Main
*-----------------------------------------------------------------------------*
   Set Navigation extended

   Load Window Grafico
   Center Window Grafico
   Activate Window Grafico

Return Nil

*-----------------------------------------------------------------------------*
Procedure Presenta(nTipo)
*-----------------------------------------------------------------------------*
   Do Case
      Case nTipo = 0         //  Histogram

           aSer:= {{Grafico.Text_5.value,Grafico.Text_9.value,Grafico.Text_13.value}, ;
                   {Grafico.Text_6.value,Grafico.Text_10.value,Grafico.Text_14.value},;
                   {Grafico.Text_7.value,Grafico.Text_11.value,Grafico.Text_15.value},;
                   {Grafico.Text_8.value,Grafico.Text_12.value,Grafico.Text_16.value} }

           aClr:= {Grafico.Label_5.Fontcolor,Grafico.Label_6.Fontcolor, ;
                   Grafico.Label_7.Fontcolor,Grafico.Label_8.Fontcolor}

           aSern:={Grafico.Text_1.value,Grafico.Text_2.value, ;
                   Grafico.Text_3.value,Grafico.Text_4.value }

           aYVal:={Grafico.Text_17.value,Grafico.Text_18.value,Grafico.Text_19.value }

           cTit:= Grafico.Text_20.value

           Set Font To "Arial", 14
           Load Window Veamos
           On Key Escape Of Veamos Action Veamos.Release
           Center Window Veamos
           Activate Window Veamos

      Case nTipo = 1       //  Pie 1

           cTit:= Grafico.Text_1.value
           aSer:= {Grafico.Text_5.value,Grafico.Text_9.value,Grafico.Text_13.value}

      Case nTipo = 2       //  Pie 2

           cTit:= Grafico.Text_2.value
           aSer:= {Grafico.Text_6.value,Grafico.Text_10.value,Grafico.Text_14.value}

      Case nTipo = 3       //  Pie 3

           cTit:= Grafico.Text_3.value
           aSer:= {Grafico.Text_7.value,Grafico.Text_11.value,Grafico.Text_15.value}

      Case nTipo = 4       //  Pie 4

           cTit:= Grafico.Text_4.value
           aSer:= {Grafico.Text_8.value,Grafico.Text_12.value,Grafico.Text_16.value}

      Case nTipo = 5       //  Pie 5

           cTit:= Grafico.Text_17.value
           aSer:= {Grafico.Text_5.value,Grafico.Text_6.value,;
                   Grafico.Text_7.value,Grafico.Text_8.value }

      Case nTipo = 6       //  Pie 6

           cTit:= Grafico.Text_18.value
           aSer:= {Grafico.Text_9.value ,Grafico.Text_10.value,;
                   Grafico.Text_11.value,Grafico.Text_12.value }

      Case nTipo = 7       //  Pie 7

           cTit:= Grafico.Text_19.value
           aSer:= {Grafico.Text_13.value,Grafico.Text_14.value,;
                   Grafico.Text_15.value,Grafico.Text_16.value }

   EndCase

   If nTipo > 0 .and. nTipo < 8
      IF nTipo < 5
         aYVal:={Grafico.Text_17.value,Grafico.Text_18.value,Grafico.Text_19.value}
         aClr:= {Grafico.Label_3.Fontcolor,Grafico.Label_4.Fontcolor, ;
                                           Grafico.Label_11.Fontcolor }
      Else
          aYVal:={Grafico.Text_1.value,Grafico.Text_2.value,;
                  Grafico.Text_3.value,Grafico.Text_4.value }
          aClr:= {Grafico.Label_5.Fontcolor,Grafico.Label_6.Fontcolor,;
                  Grafico.Label_7.Fontcolor,Grafico.Label_8.Fontcolor }
      Endif
      Set Font To "Arial", 12
      Load Window Veamos2
      Center Window Veamos2
      Activate Window Veamos2
   Endif

Return

*-----------------------------------------------------------------------------*
Procedure elGrafico()
*-----------------------------------------------------------------------------*
Local nTop := 20, nLeft := 20, nBottom := 400, nRight := 610

	ERASE WINDOW Veamos

	DRAW GRAPH							;
		IN WINDOW Veamos                                        ;
		AT nTop, nLeft						;
		TO nBottom, nRight					;
		TITLE cTit                                              ;
		TYPE BARS						;
		SERIES aSer                                             ;
  		YVALUES aYval                                           ;
		DEPTH 15						;
		BARWIDTH 15						;
		HVALUES 5						;
		SERIENAMES aSern                                        ;
		COLORS aClr                                             ;
		3DVIEW    						;
		SHOWGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		SHOWLEGENDS 						;
		NOBORDER DATAMASK "9999"

	App.Cargo := { nTop , nLeft , nRight - nLeft , nBottom - nTop }

Return

*-----------------------------------------------------------------------------*
Procedure PieGraph()
*-----------------------------------------------------------------------------*

   ERASE Window Veamos2

   DRAW GRAPH IN WINDOW Veamos2 AT 20,20 TO 400,610	;
        TITLE cTit TYPE PIE				;
        SERIES aSer					;
        DEPTH 15					;
        SERIENAMES aYVal				;
        COLORS aClr					;
        3DVIEW						;
        SHOWXVALUES					;
        SHOWLEGENDS					;
	NOBORDER

Return

*-----------------------------------------------------------------------------*
Function printgraph ( cWindowName , lPreview , lDialog )
*-----------------------------------------------------------------------------*
local aLocation

	If .Not. _IsWindowDefined ( cWindowName )
		MsgMiniGUIError ("Window: "+ cWindowName + " is not defined.")
	Endif

	If ValType ( App.Cargo ) <> 'A' .And. Len ( App.Cargo ) <> 4
		MsgMiniGUIError ("Window: "+ cWindowName + " have not a graph.")
	Endif

	if ValType ( lPreview ) == 'U'
		lPreview := .F.
	endif

	if ValType ( lDialog ) == 'U'
		lDialog := .F.
	endif

	aLocation := App.Cargo

	PrintWindow ( cWindowName , lPreview , lDialog , aLocation [1] , aLocation [2] , aLocation [3] , aLocation [4] )

return nil
