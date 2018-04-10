#include "MiniGui.ch"
#include "TSBrowse.ch"

//#define CLR_HBROWN  nRGB( 205, 192, 176 )

Function SBrwTest()

   Local cTitle := "Customer List", ;
         bSetup := { |oBrw| SetMyBrowser( oBrw ) }

   DbSelectArea( "Employee" )

   SBrowse( "Employee", cTitle, bSetup )

Return Nil

//----------------------------------------------------------------------------//

Function SetMyBrowser( oBrw )

       oBrw:nHeightCell += 5
       oBrw:nHeightHead += 5
       oBrw:nClrFocuFore := CLR_BLACK
       oBrw:nClrFocuBack := COLOR_GRID

Return .T.

