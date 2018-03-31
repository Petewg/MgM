#include "minigui.ch"
#include "tsbrowse.ch"

*-----------------------------------
Function Main()
*-----------------------------------
   Local cTitle := "Test Browse: Right Click For Record View", ;
         bSetup := { |oBrw| SetMyBrowser( oBrw ) }

   CreateTable()

   USE Test NEW

   SET AUTOADJUST ON NOBUTTONS

   SET FONT TO "Tahoma", 9

   SET DEFAULT ICON TO GetStartupFolder() + "\demo.ico"

   DEFINE WINDOW sample AT 0,0 WIDTH 640 HEIGHT 480 ;
      TITLE "Open Table via SBrowse" ;
      MAIN ;
      NOSHOW ;
      ON INIT SBrowse( "Test", cTitle, bSetup ) ;
      ON RELEASE ( dbCloseArea( "Test" ), hb_dbDrop( "Test" ) )

      DEFINE TIMER t_1 INTERVAL 1000 ACTION iif( Empty(CountChildWindows()), ThisWindow.Release(), )

   END WINDOW

   sample.Center()
   sample.Activate()

Return Nil

*-----------------------------------
Function CreateTable
*-----------------------------------

   DBCREATE("Test", {{"CODE", "C", 3, 0},{"NAME", "C", 50, 0},{"RESIDENTS", "N", 11, 0},{"NOTES", "M", 10, 0}},,.T.)

   DBAPPEND()
   REPLACE CODE WITH 'LTU', NAME WITH 'Lithuania', RESIDENTS WITH 3369600
   DBAPPEND()
   REPLACE CODE WITH 'USA', NAME WITH 'United States of America', RESIDENTS WITH 305397000
   DBAPPEND()
   REPLACE CODE WITH 'POR', NAME WITH 'Portugal', RESIDENTS WITH 10617600
   DBAPPEND()
   REPLACE CODE WITH 'POL', NAME WITH 'Poland', RESIDENTS WITH 38115967
   DBAPPEND()
   REPLACE CODE WITH 'AUS', NAME WITH 'Australia', RESIDENTS WITH 21446187
   DBAPPEND()
   REPLACE CODE WITH 'FRA', NAME WITH 'France', RESIDENTS WITH 64473140
   DBAPPEND()
   REPLACE CODE WITH 'RUS', NAME WITH 'Russia', RESIDENTS WITH 141900000
   USE

Return Nil

*-----------------------------------
Function SetMyBrowser( oBrw )
*-----------------------------------
Local cFormName := oBrw:cParentWnd

   SetProperty( cFormName, "MinWidth", 920 )
   SetProperty( cFormName, "MinHeight", 480 )

   oBrw:nHeightCell += 5
   oBrw:nHeightHead += 12
   oBrw:nClrFocuFore := CLR_BLACK
   oBrw:nClrFocuBack := COLOR_GRID

Return .T. // editable browse (return .F. is readonly)

*-----------------------------------
Function CountChildWindows
*-----------------------------------
Local i, nFormCount := Len (_HMG_aFormHandles), nCnt := 0

   FOR i := 1 TO nFormCount
      IF _HMG_aFormType [i] <> "A"
	IF _IsWindowDefined ( _HMG_aFormNames [i] )
		nCnt++
	ENDIF
      ENDIF
   NEXT

Return nCnt
