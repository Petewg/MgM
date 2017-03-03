/*
	Roberto M Manini
   Copyright 2008 Roberto M Manini <manini@terra.com.br>
   Google Trace/Route
   Re-Adaptação do GoogleMaps by Walter Formigoni, December of 2007
   Google Map, Adapted from sample of <Rafael Clemente> (Barcelona, Spain) and  <shrkod> from Fivewin to Minigui
   ---------------------------------------------     
   Marcelo Torres, Noviembre de 2006.
   TActivex para [x]Harbour Minigui.
   Adaptacion del trabajo de:
   ---------------------------------------------
   Lira Lira Oscar Joel [oSkAr]
   Clase TAxtiveX_FreeWin para Fivewin
   Noviembre 8 del 2006
   email: oscarlira78@hotmail.com
   http://freewin.sytes.net
   CopyRight 2006 Todos los Derechos Reservados
   
   ---------------------------------------------
*/

SET PROCEDURE TO "TAxPrg.prg"

#include "minigui.ch"

DECLARE WINDOW GoogleDirections

#define OLECMDID_PRINT 6
#define OLECMDID_PRINTPREVIEW 7
#define OLECMDEXECOPT_DODEFAULT 0


STATIC  oActiveX
STATIC  oWActiveX

memvar lPreview
*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*
   public lPreview:=.f.
   LOAD WINDOW GoogleDirections

   GoogleDirections.Center()
   GoogleDirections.Activate()

RETURN


*--------------------------------------------------------*
Static Procedure fOpenActivex()
*--------------------------------------------------------*

   Local cfromAddress := PadR( "CURITIBA,PR", 80 )
   Local ctoAddress := PadR( "MATINHOS,PR", 80 )

   GoogleDirections.TEXT_1.VALUE  := cfromAddress
   GoogleDirections.TEXT_2.VALUE  := ctoAddress 

   oWActiveX := TActiveX():New( "GoogleDirections", "Shell.Explorer.2" , 0 , 0 , ;
                GetProperty( "GoogleDirections" , "width" ) - 8 , GetProperty( "GoogleDirections" , "height" ) - 150 )
                
   oActiveX := oWActiveX:Load()

   SHOW( cfromAddress, ctoAddress )

Return


*--------------------------------------------------------*
PROCEDURE SEARCH()
*--------------------------------------------------------*
  Local cfromAddress := GoogleDirections.TEXT_1.VALUE
  Local ctoAddress := GoogleDirections.TEXT_2.VALUE

  SHOW( cfromAddress, ctoAddress )

RETURN   


*--------------------------------------------------------*
Function Show( cfromAddress, ctoAddress)
*--------------------------------------------------------*
   Local cHtml := MemoRead( "GoogleDirections.html" )

   cHtml = StrTran( cHtml, "<<cfromAddress>>", AllTrim( cfromAddress ) )
   cHtml = StrTran( cHtml, "<<ctoAddress>>", AllTrim( ctoAddress ) )
    
   MemoWrit( "rtemp.html", cHtml )

   oActiveX:Navigate(CurDrive() + ":\" + CurDir() + "\rtemp.html" )

RETURN NIL


*-----------------------------------------------------------------------------*
Static Function fCloseActivex()
*-----------------------------------------------------------------------------*

   IF VALTYPE(oWActivex) <> "U" .AND. VALTYPE(oActivex) <> "U"
      oWActiveX:Release()
   ENDIF

RETURN NIL


*-----------------------------------------------------------------------------*
Static Procedure fPrint(lPreview)
*-----------------------------------------------------------------------------*

   If Valtype(oWActiveX) <> "U"
      If lPreview
         oActiveX:ExecWB( OLECMDID_PRINTPREVIEW, OLECMDEXECOPT_DODEFAULT )
      Else
         oActiveX:ExecWB( OLECMDID_PRINT, OLECMDEXECOPT_DODEFAULT )
      EndIf
   EndIf

Return
