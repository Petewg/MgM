/*
   Aníbal Villalobos Guillén, Septiembre de 2007
   PDFViewer, Basado en Ejemplo Flash Player

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
   Copyright 2007 Walter Formigoni <walter.formigoni@uol.com.br>
   Adapted from sample of flash from Fivewin to Minigui
   ---------------------------------------------
*/

SET PROCEDURE TO "TAxPrg.prg"

#include "minigui.ch"

STATIC oWActiveX
STATIC oActiveX

********************
FUNCTION Main()

SET NAVIGATION EXTENDED

DEFINE WINDOW FORMPDFREADER ;
       AT 0, 0 ;
       WIDTH 800 HEIGHT 600 ;
       TITLE "PDF Reader" ;
       MAIN ;
       ICON 'adobe.ico' ;
       ON INIT fOpenActivex() ;
       ON SIZE Adjust() ;
       ON MAXIMIZE Adjust() ;
       ON RELEASE fCloseActivex()

END WINDOW

FORMPDFREADER.Maximize()
FORMPDFREADER.Activate()

RETURN NIL
********************
STATIC PROCEDURE fOpenActivex()
LOCAL cPDF

cPDF := GetStartUpFolder()+"\PDFOpenParameters.PDF"

IF FILE(cPDF)
   oWActiveX := TActiveX():New(ThisWindow.Name, ;
                               "AcroPDF.PDF.1", ;
                               0, ;
                               0, ;
                               GetProperty(ThisWindow.Name, "width") -  2 * GetBorderWidth() - 1 , ;
                               GetProperty(ThisWindow.Name, "height") - 2 * GetBorderHeight() - ;
                                                                             GetTitleHeight() )

   oActiveX := oWActiveX:Load()
   ******************** begin of user settings
   oActiveX:setPageMode("none")            // hide bookmarks
   oActiveX:setLayoutMode("TwoColumnLeft")
   oActiveX:setShowToolbar(.f.)            // hide toolbar
   oActiveX:setZoom(68)
   ******************** end of user settings
   oActiveX:LoadFile(cPDF)
   FORMPDFREADER.Width:=(FORMPDFREADER.Width)-20
   FORMPDFREADER.Width:=(FORMPDFREADER.Width)+20
ELSE
   MsgStop("No se encuentra el Archivo PDF")
   FORMPDFREADER.Release()
ENDIF

RETURN
********************
STATIC FUNCTION fCloseActivex()

IF VALTYPE(oWActivex) <> "U" .AND. VALTYPE(oActivex) <> "U"
   oWActiveX:Release()
   oWActivex := Nil
   oActivex := Nil
ENDIF

RETURN NIL
********************
STATIC PROCEDURE adjust()

oWActiveX:Adjust()

RETURN
********************
/*

Methods for Adobe PDF Reader

  VT_BOOL LoadFile( VT_BSTR fileName )
  VT_VOID setShowToolbar( VT_BOOL On )
  VT_VOID gotoFirstPage( )
  VT_VOID gotoLastPage( )
  VT_VOID gotoNextPage( )
  VT_VOID gotoPreviousPage( )
  VT_VOID setCurrentPage( VT_I4 n )
  VT_VOID goForwardStack( )
  VT_VOID goBackwardStack( )
  VT_VOID setPageMode( VT_BSTR pageMode )
  VT_VOID setLayoutMode( VT_BSTR layoutMode )
  VT_VOID setNamedDest( VT_BSTR namedDest )
  VT_VOID Print( )
  VT_VOID printWithDialog( )
  VT_VOID setZoom( VT_R4 percent )
  VT_VOID setZoomScroll( VT_R4 percent, VT_R4 left, VT_R4 top )
  VT_VOID setView( VT_BSTR viewMode )
  VT_VOID setViewScroll( VT_BSTR viewMode, VT_R4 offset )
  VT_VOID setViewRect( VT_R4 left, VT_R4 top, VT_R4 width, VT_R4 height )
  VT_VOID printPages( VT_I4 from, VT_I4 to )
  VT_VOID printPagesFit( VT_I4 from, VT_I4 to, VT_BOOL shrinkToFit )
  VT_VOID printAll( )
  VT_VOID printAllFit( VT_BOOL shrinkToFit )
  VT_VOID setShowScrollbars( VT_BOOL On )
  VT_VARIANT GetVersions( )
  VT_VOID setCurrentHightlight( VT_I4 a, VT_I4 b, VT_I4 c, VT_I4 d )
  VT_VOID setCurrentHighlight( VT_I4 a, VT_I4 b, VT_I4 c, VT_I4 d )
  VT_VOID postMessage( VT_VARIANT strArray )


Properties for Adobe PDF Reader

  src                     VT_BSTR         Get, Put
  messageHandler          VT_VARIANT      Get, Put


Events for Adobe PDF Reader

  OnError
  OnMessage

*/
