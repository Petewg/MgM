/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2018, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

 Parts of this code is contributed and used here under permission of his author:
 (C)2005 Janusz Pora <januszpora@onet.eu>
---------------------------------------------------------------------------*/

#include "minigui.ch"

#define NOFOUND  -1  //Indicates a duplicate entry was not found
#define NOMRUS    0  //Indicates no MRUs are currently defined

#define cFileIni      asMRU[1]
#define cSectionIni   asMRU[2]
#define MRUParentForm asMRU[3]
#define MRUCount      asMRU[4]
#define cMRU_Id       asMRU[5]
#define maxMRU_Files  asMRU[6]

STATIC asMRU := { Nil, Nil, Nil, Nil, Nil, Nil }
STATIC aMRU_File

*-----------------------------------------------------------------------------*
FUNCTION AddMRUItem( NewItem, action )
*-----------------------------------------------------------------------------*
   LOCAL result

   result := CheckForDuplicateMRU( NewItem )
   IF result <> NOFOUND
      ReorderMRUList( result )
   ENDIF
   IF result != 1 .OR. MRUCount == 0
      AddMenuElement( NewItem, action )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION CheckForDuplicateMRU( NewItem )
*-----------------------------------------------------------------------------*
   LOCAL i , DuplicateMRU := NOFOUND
    
   IF !Empty( NewItem )
      // Uppercase newitem for string comparisons
      NewItem := Upper( NewItem )
      // Check all existing MRUs for duplicate
      IF ( i := AScan( aMRU_File , { |y| Upper( y[2] ) == NewItem } ) ) != 0
         DuplicateMRU := i
      ENDIF
   ENDIF

RETURN DuplicateMRU

*-----------------------------------------------------------------------------*
FUNCTION AddMenuElement( NewItem , cAction )
*-----------------------------------------------------------------------------*
   LOCAL x , n , cx
   LOCAL action , Caption , xCaption , cyMRU_Id , cxMRU_Id

   Caption := iif( Len( NewItem ) < 40, NewItem, SubStr( NewItem, 1, 3 ) + '...' + SubStr( NewItem, Len( NewItem ) - 34 ) )
   action := iif( cAction == NIL, {|| Nil }, &( '{|| ' + Left( cAction, At("(",cAction ) ) + ' "' + NewItem + '" ) }' ) )

   // Check if this is the first item
   IF MRUCount == 0
      // Modify a first element the menu
      cxMRU_Id := cMRU_Id
      _ModifyMenuItem ( cxMRU_Id , MRUParentForm , '&1 ' + caption , action )
      AAdd( aMRU_File , { caption, NewItem, cxMRU_Id, action, 1 } )
   ELSE
      // Add a new element to the menu
      FOR n := 1 TO Len( aMRU_File ) + 1
         x := AScan( aMRU_File , {|y| y[5] == n } )
         IF x == 0
            x := n
            EXIT
         ENDIF
      NEXT

      cyMRU_Id := cMRU_Id + '_' + hb_ntos( x )
      cxMRU_Id := aMRU_File[1, 3]
      _InsertMenuItem ( cxMRU_Id , MRUParentForm , '&1 ' + caption , action, cyMRU_Id )
      // Insert a first element the menu
      AIns( aMRU_File, 1, { caption, NewItem, cyMRU_Id, action, x }, .T. )
      FOR n := 1 TO Len( aMRU_File )
         cx := hb_ntos( n )
         cxMRU_Id := aMRU_File[n, 3]
         xCaption := '&' + cx + ' ' + aMRU_File[n, 1]
         _ModifyMenuItem ( cxMRU_Id , MRUParentForm , xCaption , aMRU_File[n, 4] )
      NEXT
      IF Len( aMRU_File ) > maxMRU_Files
         cxMRU_Id := aMRU_File[ Len(aMRU_File), 3 ]
         ASize( aMRU_File , maxMRU_Files )
         _RemoveMenuItem( cxMRU_Id , MRUParentForm )
      ENDIF
   ENDIF
   // Increment the menu count
   MRUCount++
      
RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION ReorderMRUList( DuplicateLocation )
*-----------------------------------------------------------------------------*
   LOCAL cxMRU_Id

   // Move entries previously "more recent" than the
   // duplicate down one in the MRU list
   IF DuplicateLocation > 1
      cxMRU_Id := aMRU_File[ DuplicateLocation, 3 ]
      _RemoveMenuItem( cxMRU_Id , MRUParentForm )
      hb_ADel( aMRU_File, DuplicateLocation, .T. )
   ENDIF
   
RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION SaveMRUFileList()
*-----------------------------------------------------------------------------*
   LOCAL i , cFile
   
   BEGIN INI FILE cFileIni
   // Loop through all MRU
   FOR i := 1 TO maxMRU_Files
      // Write MRU to INI with key as it's position in list
      cFile := iif( i <= Len( aMRU_File ), aMru_File[i, 2], "" )
      SET SECTION cSectionIni ENTRY hb_ntos( i ) TO cFile
   NEXT

   END INI

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DefineMruItem ( caption , cIniFile , cSection , nMaxItems , action , name )
*-----------------------------------------------------------------------------*
   LOCAL n, cValue := "", lExist := .F., aTmp := {}

   DEFAULT caption := " (Empty) ", nMaxItems := 10, name := "MRU", cIniFile := "mru.ini", cSection := "MRU"

   cFileIni := cIniFile
   cSectionIni := cSection
   MRUParentForm := _HMG_xMainMenuParentName
   MRUCount  := 0
   aMRU_File := {}
   cMRU_Id := name
   maxMRU_Files := nMaxItems

   BEGIN INI FILENAME cIniFile

   FOR n := 1 TO nMaxItems  // Retrieve entry from INI

      GET cValue SECTION cSection ENTRY hb_ntos( n ) DEFAULT ""

      IF ! Empty( cValue )  // Check if a value was returned
         lExist := .T.
         AAdd( aTmp, cValue )
         IF n == 1
            MENUITEM caption NAME &name
         ENDIF
      ELSE
         EXIT
      ENDIF

   NEXT

   END INI

   IF lExist
      IF Empty( action )
         action := Nil
      ENDIF
      FOR EACH n IN aTmp DESCEND
         AddMRUItem( n, action )
      NEXT
   ELSE
      MENUITEM caption NAME &name DISABLED
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION ClearMRUList()
*-----------------------------------------------------------------------------*
   LOCAL n , cxMRU_Id

#ifndef __XHARBOUR__
   FOR EACH n IN aMRU_File DESCEND
      cxMRU_Id := n[ 3 ]
      IF n:__enumIsLast()
         _ModifyMenuItem( cxMRU_Id , MRUParentForm , ' (Empty) ' , {|| Nil } )
         SetProperty( MRUParentForm , cxMRU_Id , 'Enabled' , .F. )
         cMRU_Id := cxMRU_Id
         aMRU_File := {}
         MRUCount := 0
      ELSE 
         _RemoveMenuItem( cxMRU_Id , MRUParentForm )
      ENDIF
#else
   FOR n := Len( aMRU_File ) TO 1 STEP -1
      cxMRU_Id := aMRU_File[n,3]
      IF n > 1
         _RemoveMenuItem( cxMRU_Id , MRUParentForm )
      ELSE 
         _ModifyMenuItem( cxMRU_Id , MRUParentForm , ' (Empty) ' , {|| Nil } )
         SetProperty( MRUParentForm , cxMRU_Id , 'Enabled' , .F. )
         cMRU_Id := cxMRU_Id
         aMRU_File := {}
         MRUCount := 0
      ENDIF
#endif
   NEXT

RETURN Nil
