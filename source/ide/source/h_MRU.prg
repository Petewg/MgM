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
        i := AScan( aMRU_File , {|y| Upper(y[2])==NewItem})
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
            AAdd( aMRU_File , { caption, NewItem, cxMRU_Id, action, 1 })

        ELSE
            // Add a new element to the menu
            for n:=1 to Len( aMRU_File )+1
                X := AScan( aMRU_File , {|y| y[5]==n})
                if X == 0
                    x :=n
                    exit
                ENDIF
            next

            cx:=  AllTrim(Str( x ))   //StrZero(x,2)
            cyMRU_Id := cMRU_Id +'_'+ cx
            cxMRU_Id := aMRU_File[1,3]
            _InsertMenuItem( cxMRU_Id , 'Controls' ,'&1 '+caption , action, cyMRU_Id  )
            ASize(aMRU_File, Len(aMRU_File)+1)
            AIns( aMRU_File, 1 )
            aMRU_File [ 1 ] := {caption,NewItem,cyMRU_Id,action,x}
            for n:= 1 to Len(aMRU_File)
                cx:= AllTrim(Str(n))
                cxMRU_Id := aMRU_File[n,3]
                xCaption := '&'+cx+' '+aMRU_File[n,1]
                _ModifyMenuItem( cxMRU_Id , 'Controls' , xCaption , aMRU_File[n,4] )
            next
            if Len(aMRU_File) > maxMRU_Files
                cxMRU_Id := aMRU_File[ Len(aMRU_File) , 3 ]
                ASize( aMRU_File , maxMRU_Files )
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
        ADel( aMRU_File, DuplicateLocation )
        ASize(aMRU_File, Len(aMRU_File)-1)
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

      result = GetSetting("MRUFiles", LTrim(Str(i)))
      // Check if a value was returned
      IF !Empty(result)
         AAdd(aTmp, result)
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
        SET SECTION "MRUFiles" ENTRY LTrim(Str(i)) TO cFile
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

      AAdd( _HMG_aControlType , "MENU" )
      AAdd( _HMG_aControlNames , Name )
      AAdd( _HMG_aControlHandles , Controlhandle )
      AAdd( _HMG_aControlParentHandles , _HMG_xMainMenuParentHandle)
      AAdd( _HMG_aControlIds , id )
      AAdd( _HMG_aControlProcedures , action )
      AAdd( _HMG_aControlPageMap , h  )
      AAdd( _HMG_aControlValue , Nil )
      AAdd( _HMG_aControlInputMask , "" )
      AAdd( _HMG_aControllostFocusProcedure , "" )
      AAdd( _HMG_aControlGotFocusProcedure , "" )
      AAdd( _HMG_aControlChangeProcedure , "" )
      AAdd( _HMG_aControlDeleted , .F. )
      AAdd( _HMG_aControlBkColor , Nil )
      AAdd( _HMG_aControlFontColor , Nil )
      AAdd( _HMG_aControlDblClick , "" )
      AAdd( _HMG_aControlHeadClick , {} )
      AAdd( _HMG_aControlRow , 0 )
      AAdd( _HMG_aControlCol , 0 )
      AAdd( _HMG_aControlWidth , 0 )
      AAdd( _HMG_aControlHeight , 0 )
      AAdd( _HMG_aControlSpacing , 0 )
      AAdd( _HMG_aControlContainerRow , -1 )
      AAdd( _HMG_aControlContainerCol , -1 )
      AAdd( _HMG_aControlPicture , "" )
      AAdd( _HMG_aControlContainerHandle , 0 )
      AAdd( _HMG_aControlFontName , "" )
      AAdd( _HMG_aControlFontSize , 0 )
      AAdd( _HMG_aControlFontAttributes , {.F.,.F.,.F.,.F.} )
      AAdd( _HMG_aControlToolTip  , ""  )
      AAdd( _HMG_aControlRangeMin  , 0  )
      AAdd( _HMG_aControlRangeMax  , 0  )
      AAdd( _HMG_aControlCaption  , Caption  )
      AAdd( _HMG_aControlVisible  , .T. )
      AAdd( _HMG_aControlHelpId  , 0 )
      AAdd( _HMG_aControlFontHandle  , 0 )
      AAdd( _HMG_aControlBrushHandle  , 0 )
      AAdd( _HMG_aControlEnabled  , .T. )
      AAdd( _HMG_aControlMiscDatA1  , 0 )

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
