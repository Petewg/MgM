/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/
-----------------------------------------------------------------------------

#include "minigui.ch"

#define NOFOUND  -1     //Indicates a duplicate entry was not found
#define NOMRUS    0     //Indicates no MRUs are currently defined

/*--------------------------------------------------
FUNCTION MRU_Load()
*--------------------------------------------------
    // Initialize the count of MRUs
    MRUCount := NOMRUS
    // Call sub to retrieve the MRU filenames
    GetMRUFileList()
RETURN NIL

*--------------------------------------------------
FUNCTION MRU_Unload()
*--------------------------------------------------
   // Call to save the MRU filenames
   SaveMRUFileList()
RETURN Nil
*/
#include "ide.ch"
*--------------------------------------------------
FUNCTION mnuMRU_Click( NewItem AS STRING )
*--------------------------------------------------
    CurrentProject := NewItem
    SetCurrentFolder( cFilePath( NewItem ) )
    OpenProject()
RETURN( NIL )

/*--------------------------------------------------
FUNCTION mnuOpen_Click( NewItem )
*--------------------------------------------------
    // Call to add this file as an MRU
    AddMenuElement( NewItem )
RETURN Nil

*--------------------------------------------------
FUNCTION AddMRUItem( NewItem )
*--------------------------------------------------
    LOCAL result
    result = CheckForDuplicateMRU( NewItem )
    IF result <> NOFOUND
        ReorderMRUList( NewItem, result )
    ENDIF
    if result != 1 .OR. MRUCount == 0
        AddMenuElement( NewItem )
    ENDIF
RETURN Nil

*--------------------------------------------------
FUNCTION CheckForDuplicateMRU( NewItem )
*--------------------------------------------------
    LOCAL i , DuplicateMRU := -1

    if !Empty(NewItem)
        // Uppercase newitem for string comparisons
        NewItem := Upper(NewItem)
        // Check all existing MRUs for duplicate
        i := aScan( aMRU_File , {|y| Upper(y[2])==NewItem})
        if i != 0
            DuplicateMRU = i
        ENDIF
    ENDIF
RETURN DuplicateMRU

*--------------------------------------------------
FUNCTION AddMenuElement( NewItem  )
*--------------------------------------------------
    LOCAL i , x:=1 , n , cx
    LOCAL action , cAction , Caption, xCaption, cyMRU_Id, cxMRU_Id

    if Len(NewItem) < 40
        Caption := NewItem
    ELSE
        Caption := SubStr(NewItem,1,3)+'...'+ SubStr(NewItem,Len(NewItem)-34)
    ENDIF
    cAction := '{|| mnuMRU_Click( "'+NewItem + '" ) }'
    action := &cAction

        // Check if this is the first item
        IF MRUCount == 0
            // Modify a first element the menu
            cxMRU_Id := cMRU_Id
            _ModifyMenuItem( cxMRU_Id , 'Controls' ,'&1 '+caption , action  )
            aAdd( aMRU_File , { caption, NewItem, cxMRU_Id, action, 1 })

        ELSE
            // Add a new element to the menu
            for n:=1 to Len( aMRU_File )+1
                X := aScan( aMRU_File , {|y| y[5]==n})
                if X == 0
                    x :=n
                    exit
                ENDIF
            next

            cx:=  AllTrim(str( x ))   //strzero(x,2)
            cyMRU_Id := cMRU_Id +'_'+ cx
            cxMRU_Id := aMRU_File[1,3]
            _InsertMenuItem( cxMRU_Id , 'Controls' ,'&1 '+caption , action, cyMRU_Id  )
            ASIZE(aMRU_File, Len(aMRU_File)+1)
            AINS( aMRU_File, 1 )
            aMRU_File [ 1 ] := {caption,NewItem,cyMRU_Id,action,x}
            for n:= 1 to Len(aMRU_File)
                cx:= AllTrim(str(n))
                cxMRU_Id := aMRU_File[n,3]
                xCaption := '&'+cx+' '+aMRU_File[n,1]
                _ModifyMenuItem( cxMRU_Id , 'Controls' , xCaption , aMRU_File[n,4] )
            next
            if Len(aMRU_File) > maxMRU_Files
                cxMRU_Id := aMRU_File[ Len(aMRU_File) , 3 ]
                ASIZE( aMRU_File , maxMRU_Files )
                _RemoveMenuItem( cxMRU_Id , 'Controls')
            ENDIF

        ENDIF
        //Increment the menu count
        MRUCount++

RETURN Nil

*--------------------------------------------------
FUNCTION ReorderMRUList(DuplicateMRU , DuplicateLocation )
*--------------------------------------------------
    LOCAL i, cxMRU_Id

    // Move entries previously "more recent" than the
    // duplicate down one in the MRU list
    if DuplicateLocation > 1
        cxMRU_Id := aMRU_File[ DuplicateLocation , 3 ]
        _RemoveMenuItem( cxMRU_Id , 'Controls')
        ADEL( aMRU_File, DuplicateLocation )
        ASIZE(aMRU_File, Len(aMRU_File)-1)
    ENDIF

RETURN Nil

*--------------------------------------------------
FUNCTION ClearMRUList( )
*--------------------------------------------------
    LOCAL n, cxMRU_Id, xCaption

    for n:= Len(aMRU_File) to 1 step -1
        if n > 1
            cxMRU_Id := aMRU_File[ n , 3 ]
            _RemoveMenuItem( cxMRU_Id , 'Controls')
        ELSE
            cxMRU_Id := aMRU_File[n,3]
            cMRU_Id := cxMRU_Id
            xCaption := ' (Empty) '
            _ModifyMenuItem( cMRU_Id , 'Controls' , xCaption , {|| Nil } )
            aMRU_File :={}
            MRUCount := 0
           SetProperty('Controls',cMRU_Id,'Enabled',.F.)
        ENDIF
    next
RETURN Nil

*--------------------------------------------------
FUNCTION GetMRUFileList()
*--------------------------------------------------
    LOCAL i := 1, aTmp:={}
    LOCAL result

    BEGIN INI FILE cIniFile

    Do while i <= maxMRU_Files
      // Retrieve entry from registry (INI)

      result = GetSetting("MRUFiles", lTrim(Str(i)))
      // Check if a value was returned
      IF !Empty(result)
         aAdd(aTmp, result)
      ELSE
         exit
      ENDIF
      i++
    enddo
    END INI
    for i := Len(aTmp) to 1 step -1
         AddMRUItem(aTmp[i] )
    next
RETURN Nil

*--------------------------------------------------
FUNCTION SaveMRUFileList()
*--------------------------------------------------
    LOCAL i, cFile

    BEGIN INI FILE cIniFile
    // Loop through all MRU
    For i = 1 To maxMRU_Files

      // Write MRU to registry with key as it's position in list
        if i <= Len(aMRU_File)
            cFile := aMru_File[ i , 2 ]
        ELSE
            cFile := ""
        ENDIF
        SET SECTION "MRUFiles" ENTRY lTrim(Str(i)) TO cFile
    Next
    END INI
RETURN Nil

*--------------------------------------------------
FUNCTION GetSetting(cSec, cEnt)
*--------------------------------------------------
    LOCAL cVal := ""

    GET cVal SECTION cSec ENTRY cEnt DEFAULT ""

RETURN cVal
*------------------------------------------------------------------------------*
FUNCTION _InsertMenuItem( ItemName , FormName ,caption , action , name , Image )
*------------------------------------------------------------------------------*
LOCAL i , h , x
LOCAL Id , Controlhandle

   x := GetControlIndex( ItemName , FormName )
   h := _HMG_aControlpageMap [ x ]

   IF _HMG_aControlType [ x ] == "MENU"
      i := _HMG_aControlIds [ x ]
   ELSEIF _HMG_aControlType [ x ] == "POPUP"
      i := _HMG_aControlSpacing [ x ]
   ENDIF


      Id := _GetId()

      if ValType(name) != 'U'

         mVar := '_' + _HMG_xMainMenuParentName + '_' + Name
         Public &mVar. := Len(_HMG_aControlNames) + 1

      ELSE

         mVar := '_MenuDummyVar'
         Public &mVar. := 0

      ENDIF

      Controlhandle :=  InsertMenuItem( h , i ,id ,  caption  )

      if ValType( image ) != 'U'
         MenuItem_SetBitMaps( h , Id , image , "" )
      ENDIF

      aAdd( _HMG_aControlType , "MENU" )
      aAdd( _HMG_aControlNames , Name )
      aAdd( _HMG_aControlHandles , Controlhandle )
      aAdd( _HMG_aControlParentHandles , _HMG_xMainMenuParentHandle)
      aAdd( _HMG_aControlIds , id )
      aAdd( _HMG_aControlProcedures , action )
      aAdd( _HMG_aControlPageMap , h  )
      aAdd( _HMG_aControlValue , Nil )
      aAdd( _HMG_aControlInputMask , "" )
      aAdd( _HMG_aControllostFocusProcedure , "" )
      aAdd( _HMG_aControlGotFocusProcedure , "" )
      aAdd( _HMG_aControlChangeProcedure , "" )
      aAdd( _HMG_aControlDeleted , .F. )
      aAdd( _HMG_aControlBkColor , Nil )
      aAdd( _HMG_aControlFontColor , Nil )
      aAdd( _HMG_aControlDblClick , "" )
      aAdd( _HMG_aControlHeadClick , {} )
      aAdd( _HMG_aControlRow , 0 )
      aAdd( _HMG_aControlCol , 0 )
      aAdd( _HMG_aControlWidth , 0 )
      aAdd( _HMG_aControlHeight , 0 )
      aAdd( _HMG_aControlSpacing , 0 )
      aAdd( _HMG_aControlContainerRow , -1 )
      aAdd( _HMG_aControlContainerCol , -1 )
      aAdd( _HMG_aControlPicture , "" )
      aAdd( _HMG_aControlContainerHandle , 0 )
      aAdd( _HMG_aControlFontName , "" )
      aAdd( _HMG_aControlFontSize , 0 )
      aAdd( _HMG_aControlFontAttributes , {.F.,.F.,.F.,.F.} )
      aAdd( _HMG_aControlToolTip  , ""  )
      aAdd( _HMG_aControlRangeMin  , 0  )
      aAdd( _HMG_aControlRangeMax  , 0  )
      aAdd( _HMG_aControlCaption  , Caption  )
      aAdd( _HMG_aControlVisible  , .T. )
      aAdd( _HMG_aControlHelpId  , 0 )
      aAdd( _HMG_aControlFontHandle  , 0 )
      aAdd( _HMG_aControlBrushHandle  , 0 )
      aAdd( _HMG_aControlEnabled  , .T. )
      aAdd( _HMG_aControlMiscDatA1  , 0 )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _ModifyMenuItem( ItemName , FormName ,Caption , action , name , Image )
*------------------------------------------------------------------------------*
LOCAL i , h , x
LOCAL Id , Controlhandle

   x := GetControlIndex( ItemName , FormName )
   h := _HMG_aControlPageMap [ x ]

   IF _HMG_aControlType [ x ] == "MENU"
      i := _HMG_aControlIds [ x ]
   ELSEIF _HMG_aControlType [ x ] == "POPUP"
      i := _HMG_aControlSpacing [ x ]
   ENDIF


   Id := _HMG_aControlIds [ x ]

      if ValType(name) != 'U'

         mVar := '_' + _HMG_xMainMenuParentName + '_' + Name
         Public &mVar. := x

      ELSE

         mVar := '_MenuDummyVar'
         Public &mVar. := 0

      ENDIF

      Controlhandle :=  ModifyMenuItem( h , i ,id ,  Caption  )

      if ValType( image ) != 'U'
         MenuItem_SetBitMaps( h , Id , image , "" )
      ENDIF
      _HMG_aControlNames [ x ] := Name
      _HMG_aControlProcedures [ x ] := action
      _HMG_aControlHandles [ x ] := Controlhandle
      _HMG_aControlCaption  [ x ] := Caption



RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _RemoveMenuItem( ItemName , FormName  )
*------------------------------------------------------------------------------*
LOCAL i , h , x

   x := GetControlIndex( ItemName , FormName )
   h := _HMG_aControlpageMap [ x ]

   IF _HMG_aControlType [ x ] == "MENU"
      i := _HMG_aControlIds [ x ]
   ELSEIF _HMG_aControlType [ x ] == "POPUP"
      i := _HMG_aControlSpacing [ x ]
   ENDIF
    RemoveMenuItem( h , i )

RETURN Nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( MODIFYMENUITEM )
{
   hb_retnl( ModifyMenu( (HMENU) hb_parnl(1), hb_parni(2) , MF_BYCOMMAND | MF_STRING, hb_parni(3),  hb_parc(4) )) ;
}

HB_FUNC ( INSERTMENUITEM )
{
   hb_retnl( InsertMenu( (HMENU) hb_parnl(1), hb_parni(2) , MF_BYCOMMAND | MF_STRING,  hb_parni(3) ,  hb_parc(4))) ;
}

HB_FUNC ( REMOVEMENUITEM )
{
   hb_retnl( RemoveMenu( (HMENU) hb_parnl(1), hb_parni(2) , MF_BYCOMMAND  )) ;
}

#pragma ENDDUMP

*********************************************************************/
