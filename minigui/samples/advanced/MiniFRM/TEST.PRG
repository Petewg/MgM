#include "minigui.ch"

Set Procedure To MINIFRM

***************************************************************************
* Autor: Daniel Piperno (dpiperno@montevideo.com.uy)
* Descripci¢n: Incluyendo el programa MINIFRM.PRG en el proyecto, se
* podr n imprimir reportes con el comando REPORT FORM, utilizando los
* archivos FRM est ndar y todas las herramientas existentes.
* Se puede usar MINIPRINT o HBPRINTER, cambiando el #define correspondiente
***************************************************************************

Function Main

        DEFINE WINDOW Form_Main ;
                AT 0,0 ;
                WIDTH 300 ;
                HEIGHT 300 ;
                TITLE 'MiniFrm Demo' ;
                MAIN


                DEFINE MAIN MENU
                   POPUP 'Test '
                      ITEM 'REPORT FORM TEST1 (normal)'     ACTION PrintNormal()
                      ITEM 'REPORT FORM TEST2 (condensed)'  ACTION PrintCondensed()
                   END POPUP
                END MENU

        END WINDOW

        USE TEST
        INDEX ON Str(Field->GROUP,3) + Str(Field->CODE,5) TO TEST

        CENTER WINDOW Form_Main
        ACTIVATE WINDOW Form_Main

Return Nil


**********************
Function PrintNormal()
**********************

REPORT FORM TEST1 HEADING "PRUEBA 1"

Return Nil


*************************
Function PrintCondensed()
*************************

REPORT FORM TEST2 HEADING "PRUEBA 2"

Return Nil

