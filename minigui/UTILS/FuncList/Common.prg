/******
*
*       Common procedures
*
*/


#include "Common.ch"


/******
*
*       CenterInsife( cMainWindow, cClientWindow )
*
*       Centring the child windows inside parent window
*
*/

Procedure CenterInside( cMainWindow, cClientWindow )
Local nColMain      := GetProperty( cMainWindow  , 'Col'    ), ;
      nRowMain      := GetProperty( cMainWindow  , 'Row'    ), ;
      nWidthMain    := GetProperty( cMainWindow  , 'Width'  ), ;
      nHeightMain   := GetProperty( cMainWindow  , 'Height' ), ;
      nWidthClient  := GetProperty( cClientWindow, 'Width'  ), ;
      nHeightClient := GetProperty( cClientWindow, 'Height' ), ;
      nCol                                                   , ;
      nRow

nCol := ( nColMain + Int( ( nWidthMain  - nWidthClient  ) / 2 ) )
nRow := ( nRowMain + Int( ( nHeightMain - nHeightClient ) / 2 ) )

SetProperty( cClientWindow, 'Col', nCol )
SetProperty( cClientWindow, 'Row', nRow )

Return

****** End of CenterInside ******



/******
*
*       CheckPath( cPath [, lCreate ] ) --> lSuccess
*
*       Path's verify, absent folders is created, 
*       if specify lCreate = .T.
*
*       Remark: The verify is maked for folder with lower level
*          than current folder.
*
*/

Function CheckPath( cPath, lCreate )
Local cCurrDisk   := DiskName(), ;
      cCurrDir    := CurDir()  , ;
      lDiskChange := .F.       , ;
      lSuccess    := .F.       , ;
      nError                   , ;
      aDirs                    , ;
      Cycle                    , ;
      nLen

If ( !( Valtype( 'cPath' ) == 'C' ) .or. ;
      Empty( cPath )                     ;
   )
   Return .F.
Endif

If Empty( cPath )
   Return .T.
Endif

Default lCreate to .F.

cPath    := AllTrim( cPath )
cCurrDir := AllTrim( cCurrDisk + ':\' + cCurrDir )

If ( Right( cPath, 1 ) == '\' )
   cPath := Substr( cPath, 1, ( Len( cPath ) - 1 ) )
Endif

If ( Left( cPath, 1 ) == '\' )
   cPath := Substr( cPath, 2 )
Endif

nLen := Len( aDirs := StrToArray( cPath, '\' ) )

Begin Sequence

   For Cycle := 1 to nLen

     // The each folders are verify successively.
     // Firstly check for designated disk.
     // If it is true and disk is available, pass to
     // the root directory of this disk.

     If ( Right( aDirs[ Cycle ], 1 ) == ':' )

        If IsDisk( aDirs[ Cycle ] )

           If DiskChange( aDirs[ Cycle ] )

             DirChange( '\' )
             lDiskChange := .T.
             Loop

           Else
             Break

           Endif

        Else
          Break

        Endif

     Endif

     // If the folder is not exist and parameter lCreate = .T., try
     // to create this folder and pass to it. If it is unsuccessful attempt
     // the further operations are breaked.

     nError := DirChange( aDirs[ Cycle ] )
     If !Empty( nError )

        If lCreate
           If Empty( MakeDir( aDirs[ Cycle ] ) )

              If !Empty( DirChange( aDirs[ Cycle ] ) )
                 Break
              Endif

           Else
              Break

           Endif

        Else
          Break

        Endif

     Endif

   Next

   lSuccess := .T.

End

// Return to current folder

If lDiskChange
   DiskChange( cCurrDisk )
   DirChange( '\' )
Endif

DirChange( cCurrDir )

Return lSuccess

****** End of CheckPath ******


/******
*
*       StrToArray( cString, cDelimiter ) --> aResult
*
*       Converting the string to array.
*
*       Parameters:
*
*          cString     - processed string
*          cDelimiter  - one or a few delimiters. Default value is
*                        defined for functions Token() and NumToken().
*
*/

Function StrToArray( cString, cDelimiter )
Local aResult := {}                             , ;
      nCount  := NumToken( cString, cDelimiter ), ;
      Cycle

For Cycle := 1 to nCount
  AAdd( aResult, Token( cString, cDelimiter, Cycle ) )
Next

Return aResult

****** End of StrToArray ******


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

/******
*
*       Blocking window close button
*
*/

HB_FUNC( DISABLECLOSEBUTTON )
{
  HWND hWnd;
  HMENU hMenu; 
  
  hWnd = (HWND) hb_parnl( 1 );
  hMenu = GetSystemMenu( hWnd, FALSE );
   
  if (hMenu != 0)
  { 
	DeleteMenu( hMenu, SC_CLOSE, MF_BYCOMMAND);
  } 

}

#pragma ENDDUMP
