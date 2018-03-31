#include <hmg.ch>

memvar _cAnywhereSearchStr
   
function _HMGAnywhereSearch( cControlName, cWindowName, lAnywhereSearch )
   local lFound := .f.
   local cText := ''
   local nLineNo := 0
   local nItemCount := 0, i
   default lAnywhereSearch := .f.

   _HMGAnywhereSearchUpdate( cWindowName )
   nItemCount := GetProperty( cWindowName, cControlName, 'ITEMCOUNT' )

   for i := 1 to nItemCount
      // first check in the starting chars... or anywhere searching if enabled
      cText := _HMGAnywhereSearchGetText( cWindowName, cControlName, i )
      if upper( _cAnywhereSearchStr ) == left( upper( cText ), len( _cAnywhereSearchStr ) ) .or. i > _HMGAnywhereSearchGetRow( cWindowName, cControlName ) .and. if( lAnyWhereSearch, at( upper( _cAnywhereSearchStr ), upper( cText )  ) > 0, .f. )
         lFound := .t.
         _HMGAnywhereSearchSetRow( cWindowName, cControlName, i )
         exit
      endif
   next i
   if .not. lFound
      playbeep()
      _cAnywhereSearchStr := left( _cAnywhereSearchStr, max( 0, ( len( _cAnywhereSearchStr ) - 1 ) ) )
      _HMGAnywhereSearchUpdate( cWindowName )
      return 0
   endif
   return 1

function _HMGAnywhereSearchUpdate( cWindowName )
   if iscontroldefined( _anywherelabel, &cWindowName )
      if len( alltrim( _cAnywhereSearchStr ) ) > 0
         setproperty( cWindowName, '_anywherelabel', 'VISIBLE', .t. )
      else   
         setproperty( cWindowName, '_anywherelabel', 'VISIBLE', .f. )
      endif   
      setproperty( cWindowName, '_anywherelabel', 'VALUE', _cAnywhereSearchStr )
   endif
return nil

function _HMGAnywhereSearchClear( )
   local cWindowName := thiswindow.name
   _cAnywhereSearchStr := ''
   setproperty( cWindowName, '_anywherelabel', 'VALUE', _cAnywhereSearchStr )
return nil

function _HMGAnywhereSearchGetRow( cWindowName, cControlName )
   local cType := ''
   local nLineNo := 0
   local aValue := {}
   local aLineData := {}
   local i := 0
   cType := GetControlType( cControlName, cWindowName )
   do case
   case cType == 'GRID'
      if getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         aValue := getproperty( cWindowName, cControlName, 'VALUE' )
         if len( aValue ) > 0
            nLineNo := aValue[ 1 ]
         endif   
      else
         nLineNo := getproperty( cWindowName, cControlName, 'VALUE' )
      endif   
   case cType == 'MULTIGRID'
      if getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         aValue := getproperty( cWindowName, cControlName, 'VALUE' )
         if len( aValue ) > 0
            if len( aValue[ 1 ] ) > 0
               nLineNo := aValue[ 1 ][ 1 ]
            endif   
         endif   
      else
         aValue := getproperty( cWindowName, cControlName, 'VALUE' )
         if len( aValue ) > 0
            nLineNo := aValue[ 1 ]
         endif   
      endif
   case cType == 'TREE' 
      // careful! Trees can be with ITEMIDs too! Find ItemIDs position
      aValue := GetTreeProperty( cWindowName, cControlName, 'ALLVALUE' )
      for i := 1 to len( aValue )
         if aValue[ i ] == GetProperty( cWindowName, cControlName, 'VALUE' )
            // yes! this is the current position
            nLineNo := i
            exit
         endif
      next i
   case cType == 'COMBO' .or. cType == 'LIST'
      nLineNo := getproperty( cWindowName, cControlName, 'VALUE' )
   case cType == 'MULTILIST'
      aValue := getproperty( cWindowName, cControlName, 'VALUE' )
      if len( aValue ) > 0
         nLineNo := aValue[ 1 ]
      endif   
   endcase   
return nLineNo

function _HMGAnywhereSearchGetText( cWindowName, cControlName, nRow, nCol )
   local cText := ''
   local cType := ''
   local aValue := {}
   local aLineData := {}
   default nCol := 1
   cType := GetControlType( cControlName, cWindowName )
   do case
   case cType == 'GRID' .or. cType == 'MULTIGRID'
      cText := getproperty( cWindowName, cControlName, 'CELL', nRow, nCol )
   case cType == 'TREE' 
      // careful! Trees can be with ITEMIDs too! Find ItemID and get the text
      aValue := GetTreeProperty( cWindowName, cControlName, 'ALLVALUE' )
      cText := GetProperty( cWindowName, cControlName, 'ITEM', aValue[ nRow ] )
   case cType == 'COMBO' .or. cType == 'LIST' .or. cType == 'MULTILIST'
      cText := getproperty( cWindowName, cControlName, 'ITEM', nRow )
   endcase   
return cText

function _HMGAnywhereSearchSetRow( cWindowName, cControlName, nRow, nCol )
   local cType := ''
   local nLineNo := 0
   local aValue := {}
   local aLineData := {}
   default nCol := 1
   cType := GetControlType( cControlName, cWindowName )
   do case
   case cType == 'GRID'
      if getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         Setproperty( cWindowName, cControlName, 'VALUE', { nRow, 1 } )
      else
         setproperty( cWindowName, cControlName, 'VALUE', nRow )
      endif   
   case cType == 'MULTIGRID'
      if getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         setproperty( cWindowName, cControlName, 'VALUE', { { nRow, 1 } } )
      else
         setproperty( cWindowName, cControlName, 'VALUE', { nRow } )
      endif   
   case cType == 'TREE' 
      // careful! Trees can be with ITEMIDs too! Find ItemID and get the text
      aValue := GetTreeProperty( cWindowName, cControlName, 'ALLVALUE' )
      SetProperty( cWindowName, cControlName, 'VALUE', aValue[ nRow ] )
//      msginfo( str( aValue[ nRow ] ) + ', ' + str( nRow ) )
   case cType == 'COMBO' .or. cType == 'LIST'
      Setproperty( cWindowName, cControlName, 'VALUE', nRow )
   case cType == 'MULTILIST'
      setproperty( cWindowName, cControlName, 'VALUE', { nRow } )
   endcase   
return nil

static function getgridproperty( cWindowName, cControlName )
   local cType := ''
   local idx := 0
   idx := GetControlIndex( cControlName, cWindowName )
   cType := GetControlType( cControlName, cWindowName )
   do case
   case cType == 'GRID' .or. cType == 'MULTIGRID'
      return _HMG_aControlFontColor[idx]
   endcase   
return .f.

static function gettreeproperty( cWindowName, cControlName )
return TreeItemGetAllValue ( cControlName , cWindowName )

Function TreeItemGetAllValue ( ControlName , ParentForm )
LOCAL k, aAllValues := {}
LOCAL i := GetControlIndex  ( ControlName , ParentForm )
   If i > 0 .AND. GetProperty ( ParentForm, ControlName, "ItemCount" ) > 0
      If _HMG_aControlInputMask [i] == .F.
         FOR k = 1 TO GetProperty ( ParentForm, ControlName, "ItemCount" )
             AADD (aAllValues, k)
         NEXT
      Else
         aAllValues := _HMG_aControlPicture [i]   // nTreeItemID
      EndIf
   Endif
Return IF (EMPTY(aAllValues), NIL, aAllValues)
