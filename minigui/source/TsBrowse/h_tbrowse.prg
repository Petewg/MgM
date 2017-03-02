/*--------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code
 Adaptation FiveWin Class TSBrowse 9.0
---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

// 3.10.2012
// If it's uncommented:
// - select a row by Shift+DblClick
// - evaluate the block bPreSelect before selection (check of condition for selection)
// #define __EXT_SELECTION__

EXTERN OrdKeyNo, OrdKeyCount, OrdKeyGoto

#define SB_VERT             1
#define PBM_SETPOS       1026
#define EM_SETSEL         177

#define VK_CONTEXT         93
#define WS_3DLOOK           4    // 0x4L
#define WM_SETFONT         48    // 0x0030
#define WM_LBUTTONDBLCLK  515    // 0x203

// mouse wheel Windows message
#define WM_MOUSEWHEEL     522

// let's save DGroup space
// ahorremos espacio para DGroup
#define nsCol        asTSB[1]
#define nsWidth      asTSB[2]
#define nsOldPixPos  asTSB[3]
#define bCxKeyNo     asTSB[4]
#define bCmKeyNo     asTSB[5]
#define nGap         asTSB[6]
#define nNewEle      asTSB[7]
#define nKeyPressed  asTSB[8]
#define lNoAppend    asTSB[9]
#define nInstance    asTSB[10]

// api maximal vertical scrollbar position
#define MAX_POS 65535

#ifndef __XHARBOUR__
   #xcommand TRY              => BEGIN SEQUENCE WITH {|__o| break(__o) }
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
   #xcommand FINALLY          => ALWAYS
#endif

#ifdef __XHARBOUR__
   #xtranslate hb_Hour( [<x>] )             => Hour( <x> )
   #xtranslate hb_Minute( [<x>] )           => Minute( <x> )
   #xtranslate hb_Sec( [<x>] )              => Secs( <x> )
#endif

#xtranslate _DbSkipper => DbSkipper

// 27.09.2012
#ifndef __XHARBOUR__
   #xtranslate ARRDEL_( <aArray>, <uTemp> ) => hb_ADel( <aArray>, <uTemp>, .T. )
#else
   #xtranslate ARRDEL_( <aArray>, <uTemp> ) => ADel( <aArray>, <uTemp>, .T. )
#endif

MEMVAR _TSB_aControlhWnd
MEMVAR _TSB_aControlObjects
MEMVAR _TSB_aClientMDIhWnd

#define xlWorkbookNormal          -4143
#define xlContinuous                  1
#define xlHAlignCenterAcrossSelection 7

Static asTSB := { Nil, Nil, 0, Nil, Nil, 0, 0, Nil, Nil, Nil }
Static hToolTip := 0   //V90

*-----------------------------------------------------------------------------*
Function _DefineTBrowse ( ControlName, ParentFormName, nCol, nRow, nWidth, nHeight,;
         aHeaders, aWidths, bFields, value, fontname,fontsize, tooltip, change,;
         bDblclick , aHeadClick , gotfocus , lostfocus , uAlias , Delete, lNogrid,;
         aImages, aJust , HelpId , bold , italic , underline , strikeout , break ,;
         backcolor , fontcolor , lock , cell , nStyle , appendable , readonly ,;
         valid , validmessages , aColors , uWhen , nId , aFlds, cMsg, lRePaint,;
         lEnum, lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture,;
         lTransparent, uSelector, lEditable, lAutoCol, aColSel )
*-----------------------------------------------------------------------------*
Local oBrw, ParentFormHandle, mVar, k
Local ControlHandle, FontHandle, blInit, aBmp := {}
Local bRClick, bLClick, hCursor, update, nLineStyle := 1
Local aTmpColor := Array( 17 )
Local i, nColums, nLen

   Default nRow        := 0, ;
           nCol        := 0, ;
           nHeight     := 120, ;
           nWidth      := 240, ;
           value       := 0, ;
           aImages     := {}, ;
           aHeadClick  := {}, ;
           aFlds       := {},;
           aHeaders    := {},;
           aWidths     := {},;
           aPicture    := {},;
           aJust       := {},;
           hCursor     := 0, ;
           cMsg        := "", ;
           update      := .f., ;
           lNogrid     := .F.,;
           lock        := .F.,;
           appendable  := .F.,;
           lEnum       := .F.,;
           lAutoSearch := .F.,;
           lAutoFilter := .F.,;
           lAutoCol    := .F.

   HB_SYMBOL_UNUSED( break )
   HB_SYMBOL_UNUSED( validmessages )

   if lNogrid
      nLineStyle := 0
   endif
   if Len(aHeaders) > 0 .and. ValType(aHeaders[1]) == 'A'
      aHeaders := aHeaders[1]
   endif
   if Len(aWidths) > 0 .and. ValType(aWidths[1]) == 'A'
      aWidths := aWidths[1]
   endif
   if Len(aPicture) > 0 .and. ValType(aPicture[1]) == 'A'
      aPicture := aPicture[1]
   endif
   if Len(aFlds) > 0 .and. ValType(aFlds[1]) == 'A'
      aFlds := aFlds[1]
   endif
   if ValType(aColSel) != 'U' .and. ValType(aColSel) == 'A'
      if ValType(aColSel[1]) == 'A'
         aColSel := aColSel[1]
      endif
   endif

   IF valtype(uWhen) == 'B'                                         /* BK    18.05.2015 */
      IF valtype(readonly) != 'A'
         readonly := ! Eval( uWhen )
      ENDIF
      uWhen := Nil                                                  // its needed else will be crash
   ENDIF
   IF valtype(valid) == 'B'
      valid := Eval( valid )
   ENDIF                                                            /* BK end */

   if ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   endif

   If Type( '_TSB_aControlhWnd' ) != 'A'
      PUBLIC _TSB_aControlhWnd := {}, _TSB_aControlObjects := {}, _TSB_aClientMDIhWnd := {}
   EndIf

   If aColors != Nil .And. ValType( aColors ) == 'A'
      Aeval( aColors, { | bColor, nEle | aTmpColor[ nEle ] := bColor } )
   EndIf
   if ValType( fontcolor ) != "U"
      aTmpColor[1] := RGB( fontcolor[1], fontcolor[2], fontcolor[3] )
   endif
   if ValType( backcolor ) != "U"
      aTmpColor[2] := RGB( backcolor[1], backcolor[2], backcolor[3] )
   endif

   if _HMG_BeginWindowActive .or. _HMG_BeginDialogActive
      if _HMG_BeginWindowMDIActive
          ParentFormHandle := GetActiveMdiHandle()
          ParentFormName := _GetWindowProperty ( ParentFormHandle, "PROP_FORMNAME" )
      else
          ParentFormName := if( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      endif
      if .Not. Empty( _HMG_ActiveFontName ) .And. ValType( FontName ) == "U"
          FontName := _HMG_ActiveFontName
      EndIf
      if .Not. Empty( _HMG_ActiveFontSize ) .And. ValType( FontSize ) == "U"
          FontSize := _HMG_ActiveFontSize
      EndIf
   endif
   if _HMG_FrameLevel > 0
      nCol += _HMG_ActiveFrameCol [_HMG_FrameLevel]
      nRow += _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   EndIf

   If .Not. _IsWindowDefined (ParentFormName) .And. .Not. _HMG_DialogInMemory
      MsgMiniGuiError("Window: "+ ParentFormName + " is not defined." )
   Endif

   If _IsControlDefined (ControlName,ParentFormName) .And. .Not. _HMG_DialogInMemory
      MsgMiniGuiError ("Control: " + ControlName + " Of " + ParentFormName + " already defined." )
   EndIf

   If aImages != Nil .And. ValType( aImages ) == 'A'
      aBmp := Array( Len( aImages ) )
      Aeval( aImages, { | cImage, nEle | aBmp[ nEle ] := LoadImage( cImage ) } )
   EndIf

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   if _HMG_BeginDialogActive

        ParentFormHandle := _HMG_ActiveDialogHandle

        nStyle := WS_CHILD + WS_TABSTOP + WS_VISIBLE + WS_CAPTION + WS_BORDER + WS_SYSMENU + WS_THICKFRAME

        if _HMG_DialogInMemory         // Dialog Template
            if GetClassInfo( GetInstance(), ControlName ) == nil
                if !Register_Class(ControlName, CreateSolidBrush(GetRed ( GetSysColor ( COLOR_BTNFACE ) ) , GetGreen ( GetSysColor ( COLOR_BTNFACE ) ), GetBlue ( GetSysColor ( COLOR_BTNFACE ) ) ))
                    Return Nil
                endif
            endif
            blInit:= {|x,y,z| InitDialogBrowse(x,y,z) }
            aadd(_HMG_aDialogItems,{nId,k,ControlName,nStyle,0,nCol,nRow,nWidth,nHeight,"",HelpId,tooltip,FontName,FontSize,bold,italic,underline,strikeout,blInit,_HMG_BeginTabActive,.f.,_HMG_ActiveTabPage })
            if _HMG_aDialogTemplate[3]   // Modal
                Return Nil
            endif
        else

            ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )
            SetWindowStyle ( ControlHandle, nStyle, .t. )

            nCol := GetWindowCol ( Controlhandle )
            nRow := GetWindowRow ( Controlhandle )
            nWidth := GetWindowWidth  ( Controlhandle )
            nHeight := GetWindowHeight ( Controlhandle )
        endif

   else

        ParentFormHandle := GetFormHandle (ParentFormName)
        hToolTip := GetFormToolTipHandle (ParentFormName)

        oBrw := TSBrowse():New( ControlName, nRow, nCol, nWidth, nHeight,;
             bFields, aHeaders, aWidths, ParentFormName,;
             change , bDblClick, bRClick, fontname, fontsize, ;
             hCursor, aTmpColor , aBmp, cMsg, update, uAlias, uWhen, value, cell,;
             nStyle, bLClick, aFlds, aHeadClick, nLineStyle, lRePaint,;
             Delete, aJust, lock, appendable, lEnum,;
             lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture, ;
             lTransparent, uSelector, lEditable, lAutoCol, aColSel, tooltip )

        IF ( nColums := Len(oBrw:aColumns) ) > 0                           /* BK    18.05.2015 */
           IF Valtype(readonly) == 'A'                                     // sets oCol:bWhen 
              nLen := Min(Len(readonly), nColums)
              FOR i := 1 TO nLen
                 IF Valtype(readonly[i]) == 'B'
                    oBrw:aColumns[ i ]:bWhen := readonly[i]
                 ELSEIF readonly[i] == NIL .or. Empty(readonly[i])
                    oBrw:aColumns[ i ]:bWhen :=  {||.T.}
                    oBrw:aColumns[ i ]:cWhen := '{||.T.}'
                 ELSE
                    oBrw:aColumns[ i ]:bWhen :=  {||.F.}
                    oBrw:aColumns[ i ]:cWhen := '{||.F.}'
                 ENDIF
              NEXT
           ENDIF
           IF Valtype(valid) == 'A'                                        // sets oCol:bValid 
              nLen := Min(Len(valid), nColums)
              FOR i := 1 TO nLen
                 IF valtype(valid[ i ]) == 'B'
                    oBrw:aColumns[ i ]:bValid := valid[i]
                 ENDIF
              NEXT
           ENDIF
        ENDIF                                                              /* BK end */

        ControlHandle := oBrw:hWnd
        IF ValType(gotfocus) != "U"
            oBrw:bGotFocus := gotfocus
        ENDIF
        IF ValType(lostfocus) != "U"
            oBrw:bLostFocus := lostfocus
        ENDIF
        IF ! lRePaint
            _HMG_ActiveTBrowseName   := ControlName
            _HMG_ActiveTBrowseHandle := ControlHandle
            _HMG_BeginTBrowseActive  := .T.
        ENDIF

   endif

   if .Not. _HMG_DialogInMemory

       If _HMG_BeginTabActive
          aAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
       EndIf

       If FontHandle != 0
          _SetFontHandle(ControlHandle,FontHandle)
          oBrw:hFont := FontHandle
       Else
          if valtype(fontname) == "U"
             FontName := _HMG_DefaultFontName
          endif
          if valtype(fontsize) == "U"
             FontSize := _HMG_DefaultFontSize
          endif
          oBrw:hFont := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
       Endif

   endif

   Public &mVar. := k

   _HMG_aControlType [k] := "TBROWSE"
   _HMG_aControlNames [k] := ControlName
   _HMG_aControlHandles [k] := ControlHandle
   _HMG_aControlParenthandles [k] := ParentFormHandle
   _HMG_aControlIds  [k] := oBrw
   _HMG_aControlProcedures  [k] := bDblclick
   _HMG_aControlPageMap   [k] := aHeaders
   _HMG_aControlValue   [k] := Value
   _HMG_aControlInputMask   [k] := Lock
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted   [k] := .F.
   _HMG_aControlBkColor  [k] :=  aImages
   _HMG_aControlFontColor   [k] := Nil
   _HMG_aControlDblClick   [k] := bDblclick
   _HMG_aControlHeadClick   [k] := aHeadClick
   _HMG_aControlRow   [k] := nRow
   _HMG_aControlCol   [k] := nCol
   _HMG_aControlWidth   [k] := nWidth
   _HMG_aControlHeight   [k] := nHeight
   _HMG_aControlSpacing   [k] := uAlias
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture   [k] := Delete
   _HMG_aControlContainerHandle [k] := 0
   _HMG_aControlFontName   [k] := fontname
   _HMG_aControlFontSize   [k] := fontsize
   _HMG_aControlFontAttributes [k] := {bold,italic,underline,strikeout}
   _HMG_aControlToolTip    [k] := tooltip
   _HMG_aControlRangeMin   [k] := 0
   _HMG_aControlRangeMax   [k] :=  {}
   _HMG_aControlCaption  [k] :=   aHeaders
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  oBrw:hFont
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled   [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  0
   _HMG_aControlMiscData2 [k] :=  ''

Return oBrw

*-----------------------------------------------------------------------------*
Function _EndTBrowse()
*-----------------------------------------------------------------------------*
   Local i, oBrw, lBusy := .F.

   if _HMG_BeginTBrowseActive
      i := ascan ( _HMG_aControlHandles , _HMG_ActiveTBrowseHandle )
      if i > 0
         oBrw := _HMG_aControlIds [i]
         oBrw:lRePaint := .T.
         oBrw:Display()
         _HMG_ActiveTBrowseName    := ""
         _HMG_ActiveTBrowseHandle  := 0
         _HMG_BeginTBrowseActive   := .F.
      endif
   endif

Return Nil

*-----------------------------------------------------------------------------*
Function LoadFields( ControlName, ParentForm, lEdit, aFieldNames )
*-----------------------------------------------------------------------------*
   Local ix, oBrw

   Default lEdit := .F.
   ix := GetControlIndex (ControlName, ParentForm)
   oBrw := _HMG_aControlIds [ix]
   if ISARRAY(aFieldNames)
      oBrw:aColSel := aFieldNames
   endif
   oBrw:LoadFields(lEdit)

Return oBrw

*-----------------------------------------------------------------------------*
Function SetArray( ControlName, ParentForm, Arr, lAutoCols, aHead, aSizes )
*-----------------------------------------------------------------------------*
   Local ix, oBrw

   ix := GetControlIndex (ControlName, ParentForm)
   oBrw := _HMG_aControlIds [ix]
   oBrw:SetArray(Arr, lAutoCols, aHead, aSizes)

Return oBrw

*-----------------------------------------------------------------------------*
Function SetArrayTo( ControlName, ParentForm, Arr, uFontHF, aHead, aSizes, uFooter, aPicture, aAlign, aName )
*-----------------------------------------------------------------------------*
    Local ix, oBrw

    ix := GetControlIndex (ControlName, ParentForm)
    oBrw := _HMG_aControlIds [ix]
    oBrw:SetArrayTo(Arr, uFontHF, aHead, aSizes, uFooter, aPicture, aAlign, aName)

Return oBrw


* ============================================================================
* TSBrowse.PRG Version 9.0 Nov/30/2009
* ============================================================================

/* This Classs is a recapitulation of the code adapted by Luis Krause Mantilla,
   of FiveWin classes: TCBrowse, TWBrowse, TCColumn and Clipper Wrapers in C
   that support the visual Windows interface.

   Originally TCBrowse was a Sub-Class of TWBrowse, with this work, we have the
   new class "TSBrowse" that is no more a Sub-Class. Now, TSBrowse is an
   independent control that inherits directly from TControl class.

   My work has mainly consisted on putting pieces together with some extra from
   my own crop.

   Credits:
      Luis Krause Mantilla
      Selim Anter
      Stan Littlefield
      Marshall Thomas
      Eric Yang
      John Stolte
      Harry Van Tassell
      Martin Vogel
      Katy Hayes
      Jose Gimenez
      Hernan Diego Ceccarelli ( some ideas taked from his TWBrowse )
      Antonio Carlos Pantaglione ( Toninho@fwi.com.br )
      TSBtnGet is an adaptation of the Ricardo Ramirez TBtnGet Class
      Gianni Santamarina
      Ralph del Castillo
      Daniel Andrade
      Yamil Bracho
      Victor Manuel Tomás (VikThor)
      FiveTechSoft (original classes)

      Many thanks to all of them.

      Regards.

      Manuel Mercado.  July 15th, 2004

   ¡ Aquí vamos ! | ¡ Here we go !...  */

//----------------------------------------------------------------------------//

CLASS TSBrowse FROM TControl

   CLASSDATA lRegistered AS LOGICAL

   CLASSDATA aProperties AS ARRAY INIT { "aColumns", "cVarName", "nTop", "nLeft", "nWidth", "nHeight" }

   CLASSDATA lVScroll, lHScroll

   DATA   aActions                                   // actions to be executed on header's click
   DATA   aCheck                                     // stock bitmaps for check box
   DATA   aColors                                    // the whole colors kit
   DATA   aColSel                                    // automatic selected columns creation with databases or recordsets
   DATA   aArray        AS ARRAY                     // browsed array
   DATA   aBitmaps      AS ARRAY INIT {}             // array with bitmaps handles
   DATA   aDefault      AS ARRAY INIT {}             // default values in append mode
   DATA   aClipBoard                                 // used by RButtonDown method
   DATA   aColSizes, aColumns, aHeaders              // the core of TSBrowse
   DATA   aDefValue     AS ARRAY INIT {}             // for array in append mode
   DATA   aIcons        AS ARRAY INIT {}             // array with icons names
   DATA   aImages       AS ARRAY INIT {}             // array with bitmaps names
   DATA   aJustify                                   // compatibility with TWBrowse
   DATA   aLine                                      // bLine as array
   DATA   aMsg          AS ARRAY INIT {}             // multi languaje feature
   DATA   aKeyRemap     AS ARRAY INIT {}             // to prevalidate keys at KeyChar method
   DATA   aPostList                                  // used by ComboWBlock function
   DATA   aSelected                                  // selected items in select mode
   DATA   aSortBmp                                   // stock bitmaps for sort in headers
   DATA   aSuperHead                                 // array with SuperHeads properties
   DATA   aTags                                      // array with dbf index tags
   DATA   aFormatPic                                 // array of picture clause
   DATA   aPopupCol      AS ARRAY INIT {}            // User PopUp menu in Columns ({0} -> all)
   DATA   aEditCellAdjust AS ARRAY INIT { 0,0,0,0 }  // array for correction of edit cell position

   DATA   bBof                                       // codeblock to check if we are before the first record
   DATA   bEof                                       // codeblock to check if we are beyond the last record
   DATA   bAddRec                                    // custom function for adding record (with your own message)
   DATA   bBitMapH                                   // bitmap handle
   DATA   bContext                                   // evaluates windows keyboard context key
   DATA   bBookMark                                  // for xBrowse compatibility
   DATA   bDelete                                    // evaluated after user deletes a row with lCanDelete mode
   DATA   bEvents                                    // custom function for events processing
   DATA   bFileLock                                  // custom function for locking database (with your own message)
   DATA   bGoToPos                                   // scrollbar block
   DATA   bFilter                                    // a simple filter tool
   DATA   bIconDraw, bIconText                       // icons drawing directives
   DATA   bInit                                      // code block to be evaluated on init
   DATA   bKeyCount                                  // ADO keycount block
   DATA   bLine, bSkip, bGoTop, bGoBottom, ;
          bLogicLen, bChange                         // navigation codeblocks
   DATA   bKeyNo                                     // logical position on indexed databases
   DATA   bOnDraw                                    // evaluated in DrawSelect()
   DATA   bOnDrawLine                                // evaluated in DrawLine()
   DATA   bOnEscape                                  // to do something when browse ends through escape key
   DATA   bPostDel                                   // evaluated after record deletion
   DATA   bRecLock                                   // custom function for locking record (with your own message)
   DATA   bRecNo                                     // retrieves or changes physical record position
   DATA   bSeekChange                                // used by seeking feature
#ifdef __EXT_SELECTION__
   DATA   bPreSelect                                 // to be evaluated before selection for
                                                     // check of condition in select mode.
                                                     // Must return .T. or .F.
#endif
   DATA   bSelected                                  // to be evaluated in select mode
   DATA   bSetOrder                                  // used by seeking feature
   DATA   bTagOrder                                  // to restore index on GotFocus
   DATA   bLineDrag                                  // evaluated after a dividing line dragging
   DATA   bColDrag                                   // evaluated after a column dragging
   DATA   bUserSearch                                // user code block for AutoSearch
   DATA   bUserFilter                                // user code block for AutoFilter
   DATA   bUserPopupItem                             // user code block for UserPopup
   DATA   bUserKeys                                  // user code block to change the
                                                     // behavior of pressed keys
   DATA   cAlias                                     // data base alias or "ARRAY" or "TEXT_"
   DATA   cDriver                                    // RDD in use
   DATA   cField, uValue1, uValue2                   // SetFilter Params
   DATA   cOrderType                                 // index key type for seeking
   DATA   cPrefix                                    // used by TSBrowse search feature
   DATA   cSeek                                      // used by TSBrowse search feature
   DATA   cFont                                      // new
   DATA   cChildControl                              // new
   DATA   cArray                                     // new
   DATA   cToolTip                                   // tooltip when mouse is over Cells
   DATA   nToolTip      AS NUMERIC INIT 0 
   DATA   nToolTipRow   AS NUMERIC INIT 0 

   DATA   hBmpCursor    AS NUMERIC                   // bitmap cursor for first column
   DATA   hFontEdit     AS NUMERIC                   // edition font 
   DATA   hFontHead     AS NUMERIC                   // header font 
   DATA   hFontFoot     AS NUMERIC                   // footer font 
   DATA   hFontSpcHd    AS NUMERIC                   // special header font 

   DATA   l2007         AS LOGICAL INIT .F.          // new look
   DATA   l3DLook       AS LOGICAL INIT .F. READONLY // internally control state of ::Look3D() in "Phantom" column
   DATA   lHitTop, lHitBottom, lCaptured, lMChange   // browsing flags
   DATA   lAppendMode   AS LOGICAL INIT .F. READONLY // automatic append flag
   DATA   lAutoCol                                   // automatic columns generation from AUTOCOLS clause
   DATA   lAutoEdit     AS LOGICAL INIT .F.          // activates continuous edition mode
   DATA   lAutoSkip     AS LOGICAL INIT .F.          // compatibility with TCBrowse
   DATA   lCanAppend    AS LOGICAL INIT .F. READONLY // activates auto append mode
   DATA   lCanDelete    AS LOGICAL INIT .F. HIDDEN   // activates delete capability
   DATA   lCanSelect    AS LOGICAL INIT .F.          // activates select mode
   DATA   lCellBrw                                   // celled browse flag
   DATA   lCellStyle    AS LOGICAL INIT .F.          // compatibility with TCBrowse
   DATA   lChanged      AS LOGICAL INIT .F.          // field has changed indicator
   DATA   lClipMore     AS LOGICAL INIT .F.          // ClipMore RDD
   DATA   lColDrag      AS LOGICAL                   // dragging feature
   DATA   lConfirm      AS LOGICAL INIT .T. HIDDEN   // ask for user confirm to delete a row
   DATA   lDescend      AS LOGICAL INIT .F.          // descending indexes
   DATA   lDestroy                                   // flag to destroy bitmap created for selected records
   DATA   lDontChange                                // avoids user to change line with mouse or keyboard
   DATA   lDrawHeaders  AS LOGICAL INIT .T.          // condition for headers drawing
   DATA   lDrawFooters                               // condition for footers drawing
   DATA   lDrawSelect   AS LOGICAL INIT .F.          // flag for selected row drawing
   DATA   lEditable     AS LOGICAL                   // editabe cells in automatic columns creation
   DATA   lEditing      AS LOGICAL INIT .F. READONLY // to avoid lost focus at editing time
   DATA   lDrawSuperHd  AS LOGICAL INIT .F.          // condition for SuperHeader drawing
   DATA   lDrawSpecHd   AS LOGICAL INIT .F.          // condition for SpecHeader drawing
   DATA   lEditingHd    AS LOGICAL INIT .F. READONLY // to avoid lost focus at editing time SpecHd
   DATA   lEditableHd   AS LOGICAL INIT .F.          // activates edition mode of SpecHd on init
   DATA   lFilterMode   AS LOGICAL INIT .F. READONLY // index based filters with NTX RDD
   DATA   lAutoSearch   AS LOGICAL INIT .F. READONLY // condition for SuperHeader as AutoSearch
   DATA   lAutoFilter   AS LOGICAL INIT .F. READONLY // condition for SuperHeader as AutoFilter
   DATA   lHasChgSpec   AS LOGICAL INIT .F.          // SpecHeader data has changed flag for further actions
   DATA   lFirstFocus   HIDDEN                       // controls some actions on init
   DATA   lFirstPaint                                // controls some actions on init
   DATA   lFixCaret     AS LOGICAL                   // TSGet fix caret at editing time
   DATA   lFooting      AS LOGICAL                   // indicates footers can be drawn
   DATA   lNoPaint                                   // to avoid unnecessary painting
   DATA   lGrasp        AS LOGICAL INIT .F. READONLY // used by drag & drop feature
   DATA   lHasChanged   AS LOGICAL INIT .F.          // browsed data has changed flag for further actions
   DATA   lHasFocus     AS LOGICAL INIT .F.          // focused flag
   DATA   lIconView     AS LOGICAL INIT .F.          // compatibility with TCBrowse
   DATA   lInitGoTop                                 // go to top on init, default = .T.
   DATA   lIsArr                                     // browsing an array
   DATA   lIsDbf        AS LOGICAL INIT .F. READONLY // browsed object is a database
   DATA   lIsTxt                                     // browsing a text file
   DATA   lLineDrag     AS LOGICAL                   // TSBrowse dragging feature
   DATA   lLockFreeze   AS LOGICAL                   // avoids cursor positioning on frozen columns
   DATA   lMoveCols     AS LOGICAL                   // Choose between moving or exchanging columns (::moveColumn() or ::exchange())
   DATA   lNoChangeOrd  AS LOGICAL                   // avoids changing active order by double clicking on headers
   DATA   lNoExit       AS LOGICAL INIT .F.          // prevents edit exit with arrow keys
   DATA   lNoGrayBar    AS LOGICAL                   // don't show inactive cursor
   DATA   lNoHScroll    AS LOGICAL                   // disables horizontal scroll bar
   DATA   lNoLiteBar    AS LOGICAL                   // no cursor
   DATA   lNoMoveCols   AS LOGICAL                   // avoids resize or move columns by the user
   DATA   lNoPopup      AS LOGICAL INIT .T.          // avoids popup menu when right click the column's header
   DATA   lPopupActiv   AS LOGICAL INIT .F.          // defined popup menu when right click the column's header
   DATA   lPopupUser    AS LOGICAL INIT .F.          // activates user defined popup menu
   DATA   lNoResetPos   AS LOGICAL                   // prevents to reset record position on gotfocus
   DATA   lNoVScroll    AS LOGICAL                   // disables vertical scroll bar
   DATA   lLogicDrop    AS LOGICAL                   // compatibility with TCBrowse
   DATA   lPageMode     AS LOGICAL INIT .F.          // paging mode flag
   DATA   lPainted      AS LOGICAL                   // controls some actions on init
   DATA   lRePaint      AS LOGICAL                   // bypass paint if false
   DATA   lPostEdit                                  // to detect postediting
   DATA   lUndo         AS LOGICAL INIT .F.          // used by RButtonDown method
   DATA   lUpdated      AS LOGICAL INIT .F.          // replaces lEditCol return value
   DATA   lUpperSeek    AS LOGICAL INIT .T.          // controls if char expresions are seek in uppercase or not
   DATA   lSeek         AS LOGICAL INIT .T.          // activates TSBrowse seeking feature
   DATA   lSelector     AS LOGICAL INIT .F.          // automatic first column with pointer bitmap
   DATA   lInsertMode                                // flag for switching of Insert mode at editing   //Naz
   DATA   lTransparent                               // flag for transparent browses
   DATA   lEnabled      AS LOGICAL INIT .T.          // enable/disable TSBrowse for displaying data    //JP 1.55
   DATA   lPickerMode   AS LOGICAL INIT .T.          // enable/disable DatePicker Mode in inplace Editing  //MWS Sep 20/07
   DATA   lPhantArrRow  AS LOGICAL INIT .F.          // Flag for initial empty row in array
   DATA   lEnum         AS LOGICAL INIT .F.          // activates SpecHeader as Enumerator

   DATA   nAdjColumn    AS NUMERIC                   // column expands to flush table window right
   DATA   nAligBmp      AS NUMERIC INIT 0            // bitmap layout in selected cell
   DATA   nCell         AS NUMERIC                   // actual column
   DATA   nClrHeadBack, nClrHeadFore                 // headers colors
   DATA   nClrFocuBack, nClrFocuFore                 // focused cell colors
   DATA   nClrEditBack, nClrEditFore                 // editing cell colors
   DATA   nClrFootBack, nClrFootFore                 // footers colors
   DATA   nClrSeleBack, nClrSeleFore                 // selected cell no focused
   DATA   nClrOrdeBack, nClrOrdeFore                 // order control column colors
   DATA   nClrSpcHdBack,nClrSpcHdFore,nClrSpcHdActive // special headers colors
   DATA   nClrSelectorHdBack                         // special selector header background color
   DATA   nClrLine                                   // grid line color
   DATA   nColOrder     AS NUMERIC                   // compatibility with TCBrowse
   DATA   nColPos       AS NUMERIC INIT 0            // grid column position
   DATA   nColSel       AS NUMERIC INIT 0            // column to mark in selected records
   DATA   nColSpecHd    AS NUMERIC                   // activatec editing column of SpecHeader
   DATA   nDragCol      AS NUMERIC INIT 0 HIDDEN     // drag & drop  feature
   DATA   nFireKey                                   // key to start edition, defaults to VK_F2
   DATA   nFirstKey     AS NUMERIC INIT 0 HIDDEN     // First logic pos in filtered databases
   DATA   nFreeze       AS NUMERIC                   // 0,1,2.. freezes left most columns
   DATA   nHeightCell   AS NUMERIC INIT 0            // resizable cell height
   DATA   nHeightHead   AS NUMERIC INIT 0            //      "    header  "
   DATA   nHeightFoot   AS NUMERIC INIT 0            //      "    footer  "
   DATA   nHeightSuper  AS NUMERIC INIT 0            //      "    Superhead  "
   DATA   nHeightSpecHd AS NUMERIC INIT 0            //      "    Special header  "
   DATA   nIconPos                                   // compability with TCBrowse
   DATA   nLastPainted  AS NUMERIC INIT 0 HIDDEN     // last painted nRow
   DATA   nLastPos      AS NUMERIC                   // last record position before lost focus
   DATA   nLastnAt      AS NUMERIC INIT 0 HIDDEN     // last ::nAt value before lost focus
   DATA   nLen          AS NUMERIC                   // total number of browsed items
   DATA   nLineStyle                                 // user definable grid lines style
   DATA   nMaxFilter                                 // maximum number of records to count on index based filters
   DATA   nPopupActiv   AS NUMERIC                   // last activated user popup menu

   DATA   nMemoHE, nMemoWE, nMemoHV, nMemoWV         // memo sizes on edit and view mode
                                                     // Height in lines and Width in pixels
                                                     // default: 3 lines height and 200 pixels width
   DATA   nOldCell      HIDDEN                       // to control column bGotfocus
   DATA   nOffset       AS NUMERIC INIT 0 HIDDEN     // offset marker for text viewer
   DATA   nPaintRow     AS NUMERIC                   // row being painted in DrawLine Method
   DATA   nPhantom      AS NUMERIC INIT PHCOL_GRID   // controls drawing state for "Phantom" column (-1 or -2) inside ::Look3D()
   DATA   nPrevRec                                   // internally used to go previous record back
   DATA   nRowPos, nAt  AS NUMERIC INIT 0            // grid row positions
   DATA   nSelWidth                                  // Selector column's width
   DATA   nLenPos       AS NUMERIC INIT 0            // total number of browsed items in Window  JP 1.31
   DATA   nWheelLines                                // lines to scroll with mouse wheel action
   DATA   nFontSize                                  // New from HMG
   DATA   nMinWidthCols AS NUMERIC INIT 4            // minimal columns width at resizing  GF 1.96
   DATA   nUserKey                                   // user key to change the behavior of pressed keys
   DATA   nSortColDir   AS NUMERIC INIT 0            // Sorting table columns ascending or descending

   DATA   oGet                                       // get object
   DATA   oPhant                                     // phantom column
   DATA   oRSet                                      // recordset toleauto object
   DATA   oTxtFile      AS OBJECT                    // for text files browsing (TTxtFile() class)

   DATA   uBmpSel                                    // bitmap to show in selected records
   DATA   uLastTag                                   // last TagOrder before losing focus
   VAR    nLapsus       AS NUMERIC INIT 0 PROTECTED


   METHOD New( cControlName, nRow, nCol, nWidth, nHeight, bLine, aHeaders, aColSizes, cParentWnd,;
          bChange, bLDblClick, bRClick, cFont, nFontSize, hCursor, aColors, aImages, cMsg,;
          lUpdate, uAlias, bWhen, nValue, lCellBrw, nStyle, bLClick, aLine,;
          aActions, nLineStyle, lRePaint, lDelete, aJust, lLock, lAppend, lEnum,;
          lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture,;
          lTransparent, uSelector, lEditable, lAutoCol, aColSel, cTooltip ) CONSTRUCTOR

   METHOD AddColumn( oColumn )

   METHOD SetColumn( oColumn, nCol )

   METHOD AddSuperHead( nFromCol, nToCol, uHead, nHeight, aColors, l3dLook, ;
                        uFont, uBitMap, lAdjust, lTransp, ;
                        lNoLines, nHAlign, nVAlign )

   METHOD BeginPaint() INLINE If( ::lRepaint, ::Super:BeginPaint(), 0 )

   METHOD BugUp() INLINE ::UpStable()

   METHOD BiClr( uClrOdd, uClrPair )

   METHOD Bof() INLINE If( ::bBoF != Nil, Eval( ::bBof ), .F. )

   METHOD ChangeFont( hFont, nColumn, nLevel )

   METHOD DbSkipper( nToSkip )

   METHOD Default()

   METHOD Del( nItem )

   METHOD DeleteRow( lAll )

   METHOD DelColumn( nPos )

   METHOD Destroy()

   METHOD Display()

   METHOD DrawFooters() INLINE ::DrawHeaders( .T. )

//   MESSAGE DrawIcon METHOD _DrawIcon( nIcon, lFocused )

   METHOD DrawIcons()

   METHOD DrawLine( xRow )

   METHOD DrawPressed( nCell, lPressed )

   METHOD DrawSelect( xRow )

   METHOD DrawSuper()

   METHOD DrawHeaders( lFooters )

   METHOD Edit( uVar, nCell, nKey, nKeyFlags, cPicture, bValid, nClrFore, nClrBack )

   METHOD EditExit( nCol, nKey, uVar, bValid, lLostFocus )

   METHOD EndPaint()   INLINE If( ::lRePaint, ::Super:EndPaint(), ( ::lRePaint := .T., 0 ) )

   METHOD Eof() INLINE If( ::bEoF != Nil, Eval( ::bEof ), .F. )

   METHOD Excel2( cFile, lActivate, hProgress, cTitle, lSave, bPrintRow )

   METHOD ExcelOle( cXlsFile, lActivate, hProgress, cTitle, hFont, lSave, bExtern, aColSel, bPrintRow )

   METHOD Exchange( nCol1, nCol2 )  INLINE ::SwitchCols( nCol1, nCol2 ), ::SetFocus()

   METHOD ExpLocate( cExp, nCol )

   METHOD ExpSeek( cExp, lSoft )

   METHOD FreezeCol( lNext )

   METHOD GetAllColsWidth()

   METHOD GetColSizes() INLINE If( ValType( ::aColSizes ) == "A", ::aColSizes, Eval( ::aColSizes ) )

   METHOD GetColumn( nCol )

   METHOD GetDlgCode( nLastKey )

   METHOD GetRealPos( nRelPos )

   METHOD GetTxtRow( nRowPix ) INLINE RowFromPix( ::hWnd, nRowPix, ::nHeightCell, ;
                                                  If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
                                                  If( ::lFooting .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
                                                  If( ::lDrawHeaders, ::nHeightSuper, 0 ),;
                                                  If( ::lDrawSpecHd, ::nHeightSpecHd, 0 ))

   METHOD GoBottom()

   METHOD GoDown()

   METHOD GoEnd()

   METHOD GoHome()

   METHOD GoLeft()

   METHOD GoNext()

   METHOD GoPos( nNewRow, nNewCol )

   METHOD GoRight()

   METHOD GotFocus( hCtlLost )

   METHOD GoTop()

   METHOD GoToRec( nRec )

   METHOD GoUp()

   METHOD HandleEvent( nMsg, nWParam, nLParam )

   METHOD HiliteCell( nCol, nColPix )

   METHOD HScroll( nWParam, nLParam )

   METHOD HThumbDrag( nPos )

   METHOD InsColumn( nPos, oColumn )

   METHOD Insert( cItem, nAt )

   METHOD AddItem( cItem )

   METHOD IsColVisible( nCol )

   METHOD IsColVis2( nCol )

   METHOD IsEditable( nCol ) INLINE ::lCellBrw .and. ::aColumns[ nCol ]:lEdit .and. ;
                                    ( ::aColumns[ nCol ]:bWhen == Nil .or. Eval( ::aColumns[ nCol ]:bWhen, Self ) )

   METHOD KeyChar( nKey, nFlags )

   METHOD KeyDown( nKey, nFlags )

   METHOD KeyUp( nKey, nFlags )

   METHOD LButtonDown( nRowPix, nColPix, nKeyFlags )

   METHOD LButtonUp( nRowPix, nColPix, nFlags )

   METHOD lCloseArea() INLINE If( ::lIsDbf .and. ! Empty( ::cAlias ), ( ( ::cAlias )->( DbCloseArea() ), ;
                                 ::cAlias := "", .T. ), .F. )

   METHOD LDblClick( nRowPix, nColPix, nKeyFlags )

   METHOD lEditCol( uVar, nCol, cPicture, bValid, nClrFore, nClrBack )

   METHOD lIgnoreKey( nKey, nFlags )

   METHOD LoadFields( lEditable )

   METHOD LoadRecordSet()

   METHOD LoadRelated( cAlias, lEditable, aNames, aHeaders )

   METHOD Look3D( lOnOff, nColumn, nLevel, lPhantom )

   METHOD LostFocus( hCtlFocus )

   METHOD lRSeek( uData, nFld, lSoft )

   METHOD MButtonDown( nRow, nCol, nKeyFlags )

   METHOD MouseMove( nRowPix, nColPix, nKeyFlags )

   METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos )

   METHOD MoveColumn( nColPos, nNewPos )

   METHOD nAtCol( nColPixel, lActual )

   METHOD nAtColActual( nColPixel )  //SergKis & Igor Nazarov

   METHOD nAtIcon( nRow, nCol )

   METHOD nColCount() INLINE Len( ::aColumns )

   METHOD nColumn( cName ) INLINE _nColumn( Self, cName )

   METHOD nField( cName )

   METHOD nLogicPos()

   METHOD nRowCount() INLINE CountRows( ::hWnd, ::nHeightCell, If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
                                        If( ::lFooting .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
                                        If( ::lDrawHeaders, ::nHeightSuper, 0 ),;
                                        If( ::lDrawSpecHd, ::nHeightSpecHd, 0 ))

   METHOD PageUp( nLines )

   METHOD PageDown( nLines )

   METHOD Paint()

   METHOD PanHome()

   METHOD PanEnd()

   METHOD PanLeft()

   METHOD PanRight()

   METHOD PostEdit( uTemp, nCol, bValid )

   METHOD RButtonDown( nRowPix, nColPix, nFlags )

   METHOD Refresh( lPaint, lRecount )

   METHOD RelPos( nLogicPos )

   METHOD Report( cTitle, aCols, lPreview, lMultiple, lLandscape, lFromPos, aTotal )

   METHOD Reset( lBottom )

   METHOD ResetSeek()

   METHOD ResetVScroll( lInit )

   METHOD ReSize( nSizeType, nWidth, nHeight )

   METHOD TSBrwScroll( nDir ) INLINE TSBrwScroll( ::hWnd, nDir, ::hFont, ;
                                                  ::nHeightCell, If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
                                                  If( ValType( ::lDrawFooters ) == "L" .and. ;
                                                  ::lDrawFooters , ::nHeightFoot, 0 ), ::nHeightSuper, ::nHeightSpecHd )

   METHOD Seek( nKey )

   METHOD Selection()

   METHOD Set3DText( lOnOff, lRaised, nColumn, nLevel, nClrLight, nClrShadow )

   METHOD SetAlign( nColumn, nLevel, nAlign )

   METHOD SetAppendMode( lMode )

   METHOD SetArray( aArray, lAutoCols, aHead, aSizes )

   METHOD SetArrayTo( aArray, uFontHF, aHead, aSize, uFooter, aPicture, aAlign, cName )

   METHOD SetBtnGet( nColumn, cResName, bAction, nBmpWidth )

   METHOD SetColMsg( cMsg, cEditMsg, nCol )

   METHOD SetColor( xColor1, xColor2, nColumn )

   METHOD SetColSize( nCol, nWidth )

   METHOD SetColumns( aData, aHeaders, aColSizes )

   METHOD SetDeleteMode( lOnOff, lConfirm, bDelete, bPostDel )

   METHOD SetHeaders( nHeight, aCols, aTitles, aAlign , al3DLook, aFonts, aActions )

   METHOD SetData( nColumn, bData, aList )

   METHOD SetFilter( cField, uVal1, uVal2 )

   METHOD SetFont( hFont )

   METHOD SetIndexCols( nCol1, nCol2, nCol3, nCol4, nCol5 )

   METHOD SetItems( aItems ) INLINE ::SetArray( aItems, .T. )

   METHOD SetDBF( cAlias )

   METHOD SetOrder( nColumn, cPrefix, lDescend )

   METHOD SetRecordSet( oRSet )

   METHOD SetSelectMode( lOnOff, bSelected, uBmpSel, nColSel, nAlign )

   METHOD SetSpinner( nColumn, lOnOff, bUp, bDown, bMin, bMax )

#ifdef __DEBUG__
   METHOD ShowSizes()
#endif

   METHOD Skip( n )

   METHOD SortArray( nCol, lDescend )

   METHOD SwitchCols( nCol1, nCol2 )

   METHOD SyncChild( aoChildBrw, abAction )

   METHOD UpAStable()

   METHOD UpRStable( nRecNo )

   METHOD UpStable()

   METHOD Proper( cString )

   METHOD VertLine( nColPixPos, nColInit, nGapp )

   METHOD VScroll( nMsg, nPos )

   METHOD Enabled( lEnab )   //JP 1.55

   METHOD HideColumns( nColumn, lHide )  //JP 1.58

   METHOD AutoSpec(nCol)

   METHOD RefreshARow(xRow)  //JP 1.88

   METHOD UserPopup( bUserPopupItem, aColumn )  //JP 1.92

   METHOD GetCellInfo( nRowPos, nCell, lColSpecHd )  //SergKis

ENDCLASS

* ============================================================================
* METHOD TSBrowse:New() Version 9.0 Nov/30/2009
* ============================================================================

METHOD New( cControlName, nRow, nCol, nWidth, nHeight, bLine, aHeaders, aColSizes, cParentWnd, ;
            bChange, bLDblClick, bRClick, cFont, nFontSize, ;
            hCursor, aColors, aImages, cMsg, lUpdate, uAlias, ;
            bWhen, nValue, lCellBrw, nStyle, bLClick, aLine, ;
            aActions, nLineStyle, lRePaint, lDelete, aJust, ;
            lLock, lAppend, lEnum, lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture, ;
            lTransparent, uSelector, lEditable, lAutoCol, aColSel, cTooltip ) CLASS TSBrowse

   Local aSuperHeaders, ParentHandle, ;
         aTmpColor    := Array( 20 ), ;
         cAlias       := "", ;
         lSuperHeader := .f., ;
         hFont 

   If aColors != Nil
      Aeval( aColors, { | bColor, nEle | aTmpColor[ nEle ] := bColor } )
   EndIf

   Default nRow            := 0, ;
           nCol            := 0, ;
           nHeight         := 100, ;
           nWidth          := 100, ;
           nLineStyle      := LINES_ALL, ;
           aLine           := {},;
           aImages         := {},;
           cFont           := _HMG_ActiveFontName,;
           nFontSize       := _HMG_ActiveFontSize,;
           nValue          := 0,;
           lDelete         := .F., ;
           lAutoFilter     := .F., ;
           lRepaint        := .T., ;
           lAppend         := .F., ;
           lLock           := .F., ;
           lEnum           := .F., ;
           lAutoSearch     := .F., ;
           lTransparent    := .F., ;
           lEditable       := .F.

   if _HMG_BeginWindowActive
      cParentWnd := _HMG_ActiveFormName
   endif

   Default aTmpColor[ 1 ]  := GetSysColor( COLOR_WINDOWTEXT ), ;  // nClrText
           aTmpColor[ 2 ]  := GetSysColor( COLOR_WINDOW )    , ;  // nClrPane
           aTmpColor[ 3 ]  := GetSysColor( COLOR_BTNTEXT )   , ;  // nClrHeadFore
           aTmpColor[ 4 ]  := GetSysColor( COLOR_BTNFACE )   , ;  // nClrHeadBack
           aTmpColor[ 5 ]  := GetSysColor( COLOR_CAPTIONTEXT ), ; // nClrForeFocu
           aTmpColor[ 6 ]  := GetSysColor( COLOR_ACTIVECAPTION )  // nClrFocuBack

   Default aTmpColor[ 7 ]  := GetSysColor( COLOR_WINDOWTEXT ), ; // nClrEditFore
           aTmpColor[ 8 ]  := GetSysColor( COLOR_WINDOW )    , ; // nClrEditBack
           aTmpColor[ 9 ]  := GetSysColor( COLOR_BTNTEXT )   , ; // nClrFootFore
           aTmpColor[ 10 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrFootBack
           aTmpColor[ 11 ] := CLR_HGRAY                      , ; // nClrSeleFore inactive focused
           aTmpColor[ 12 ] := CLR_GRAY                       , ; // nClrSeleBack inactive focused
           aTmpColor[ 13 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrOrdeFore
           aTmpColor[ 14 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrOrdeBack
           aTmpColor[ 15 ] := GetSysColor( COLOR_BTNSHADOW ) , ; // nClrLine
           aTmpColor[ 16 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrSupHeadFore
           aTmpColor[ 17 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrSupHeadBack
           aTmpColor[ 18 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrSpecHeadFore
           aTmpColor[ 19 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrSpecHeadBack
           aTmpColor[ 20 ] := CLR_HRED                           // nClrSpecHeadActive

   Default lUpdate         := .F., ;
           aColSizes       := {}, ;
           lCellBrw        := lEditable

   Default nStyle := nOr( WS_CHILD, WS_BORDER, WS_VISIBLE,WS_CLIPCHILDREN, WS_TABSTOP, WS_3DLOOK )

   IF lAutoFilter
      aTmpColor[ 19 ] := GetSysColor( COLOR_INACTCAPTEXT )
   elseif lAutoSearch
      aTmpColor[ 19 ] := GetSysColor( COLOR_INFOBK )
   endif
   If ValType( uAlias ) == "A"
      cAlias := "ARRAY"
      ::cArray:= uAlias
      ::aArray:= {}
   ElseIf ValType( uAlias ) == "C" .and. "." $ uAlias
      cAlias := "TEXT_" + AllTrim( uAlias )
   ElseIf ValType( uAlias ) == "C"
      cAlias := Upper( uAlias )
   ElseIf ValType( uAlias ) == "O"

      If Upper( uAlias:ClassName() ) == "TOLEAUTO"
         cAlias  := "ADO_"
         ::oRSet := uAlias
      EndIf
   #ifdef __XHARBOUR__
   ElseIf ValType( uAlias ) == "H"
      cAlias := "ARRAY"
      uAlias := aHash2Array( uAlias )
   #endif
   EndIf
   If _HMG_BeginWindowMDIActive
      ParentHandle :=  GetActiveMdiHandle()
      cParentWnd   := _GetWindowProperty ( ParentHandle, "PROP_FORMNAME" )
   Else
      ParentHandle := GetFormHandle (cParentWnd)
   EndIf

   Do Case
      Case ValType( uSelector ) == "C"
         ::lSelector  := .T.
         ::hBmpCursor := LoadImage( uSelector )
      Case ValType( uSelector ) == "N"
         ::lSelector  := .T.
         ::hBmpCursor := StockBmp( 3 )
         ::nSelWidth  := uSelector
      Case ValType( uSelector ) == "L" .and. uSelector
         ::lSelector := .T.
         ::hBmpCursor := StockBmp( 3 )
      Case uSelector != Nil
         ::lSelector := .T.
   EndCase

   ::oWnd := Self

   ::cCaption    := ""
   ::cTooltip    := ctooltip
   ::nTop        := nRow
   ::nLeft       := nCol
   ::nBottom     := ::nTop + nHeight - 1
   ::nRight      := ::nLeft + nWidth - 1
   ::oWnd:hWnd   := ParentHandle                  //JP
   ::hWndParent  := ParentHandle                  //JP 1.45
   ::cControlName:= cControlName                  //JP
   ::cParentWnd  := cParentWnd                    //JP

   ::lHitTop     := .F.
   ::lHitBottom  := .F.
   ::lFocused    := .F.
   ::lCaptured   := .F.
   ::lMChange    := .T.
   ::nRowPos     := 1
   ::nAt         := 1
   ::nColPos     := 1
   ::nStyle      := nStyle
   ::lRePaint    := lRePaint
   ::lNoHScroll  := .F.
   ::lNoVScroll  := .F.
   ::lNoLiteBar  := .F.
   ::lNoGrayBar  := .F.
   ::lLogicDrop  := .T. //1.54
   ::lColDrag    := .F.
   ::lLineDrag   := .F.
   ::nFreeze     := 0
   ::aColumns    := {}
   ::nColOrder   := 0
   ::cOrderType  := ""
   ::lFooting    := .F.
   ::nCell       := 1
   ::lCellBrw    := lCellBrw
   ::lMoveCols   := .F.
   ::lLockFreeze := .F.
   ::lCanAppend  := lAppend
   ::lCanDelete  := lDelete
   ::lAppendMode := .F.
   ::aImages     := aImages
   ::aBitmaps    := aImages              //{} if aImages = array handles !!
   ::nId         := ::GetNewId()
   ::cAlias      := cAlias
   ::bLine       := bLine
   ::aLine       := aLine
   ::lAutoEdit   := .F.
   ::lAutoSkip   := .F.
   ::lIconView   := .F.
   ::lCellStyle  := .F.
   ::nIconPos    := 0
   ::lMChange    := .T.
   ::bChange     := bChange
   ::bLClicked   := bLClick
   ::bLDblClick  := bLDblClick
   ::bRClicked   := bRClick
   ::aHeaders    := aHeaders
   ::aColSizes   := aColSizes
   ::aFormatPic  := If( ISARRAY(aPicture), aPicture, {} )
   ::aJustify    := aJust
   ::nLen        := 0
   ::lCaptured   := .F.
   ::lPainted    := .F.
   ::lNoResetPos := .T.
   ::hCursor     := hCursor
   ::cMsg        := cMsg
   ::lUpdate     := lUpdate
   ::bWhen       := bWhen
   ::aColSel     := aColSel
   ::aActions    := aActions
   ::aColors     := aTmpColor
   ::nLineStyle  := nLineStyle
   ::aSelected   := {}
   ::aSuperHead  := {}
   ::lFixCaret   := .F.
   ::lEditable   := lEditable
   ::cFont       := cFont
   ::nFontSize   := nFontSize
   ::lTransparent:= lTransparent
   ::lAutoCol    := lAutoCol
   ::bRecLock    := If( lLock, {|| ( ::cAlias )->( RLock() ) } , ::bRecLock )
   ::lEnum       := lEnum
   ::lAutoSearch := lAutoSearch
   ::lAutoFilter := lAutoFilter
   ::lEditableHd := lAutoSearch .or. lAutoFilter
   ::lDrawSpecHd := lEnum .or. lAutoSearch .or. lAutoFilter
   ::bUserSearch := If( lAutoSearch, uUserSearch, ::bUserSearch )
   ::bUserFilter := If( lAutoFilter, uUserFilter, ::bUserFilter )

   ::SetColor( , aTmpColor )

   ::bBitMapH := &( "{|oBmp|If(oBmp!=Nil,oBmp:hBitMap,0)}" )

   ::lIsDbf := ! EmptyAlias( ::cAlias ) .and. ::cAlias != "ARRAY" .and. ;
               ! ( "TEXT_" $ ::cAlias ) .and. ::cAlias != "ADO_"

   ::lIsArr := ( ::cAlias == "ARRAY" )  // JP 1.66

   ::aMsg := LoadMsg()

   If Valtype( ::oWnd:hWnd ) != 'U'
      ::Create( ::cControlName )

      If ::hFont != Nil
         ::SetFont( ::hFont )
         ::nHeightCell := ::nHeightHead := SBGetHeight( ::hWnd, ::hFont, 0 )
      Else
         hFont := InitFont( ::cFont, ::nFontSize )  // SergKis addition
         ::nHeightCell := ::nHeightHead := GetTextHeight( 0, "B", hFont ) + 1
         DeleteObject( hFont )
      EndIf
      ::nHeightFoot := 0
      ::nHeightSpecHd := If( ::lEditableHd, ::nHeightHead, 0 )

      ::lVisible = .T.
      ::lValidating := .F.
      If ::lIsArr                // JP 1.66
         ::lFirstPaint := .T.
      EndIf

      If aHeaders != Nil .And. ValType( aHeaders ) == 'A'
         AEval( aHeaders, { | cHeader | lSuperHeader := ( At('~', cHeader) != 0 ) .or. lSuperHeader } )
         IF lSuperHeader
            aSuperHeaders := IdentSuper( aHeaders, Self )
         endif
      EndIf

      ::Default()

      If aSuperHeaders != Nil .And. ValType( aSuperHeaders ) == 'A'
         AEval( aSuperHeaders, { | aHead | ::AddSuperHead( aHead[2], aHead[3], aHead[1], ;
                       ::nHeightSuper, { aTmpColor[ 16 ], aTmpColor[ 17 ], aTmpColor[ 15 ] }, ;
                       .f., If( ::hFont != Nil, ::hFont, 0 ) ) } )

         ::SetColor( , aTmpColor )
      EndIf
   Else
      ::lVisible = .F.
   EndIf

   ctooltip := ::cToolTip
   If Valtype( ctooltip ) == "B"
      ctooltip := Eval( ctooltip, Self )
   EndIf

   SetToolTip( ::hWnd, cToolTip, hToolTip )

   if nValue > 0 .and. nValue <= ::nLen
      if Len( ::aColumns ) > 0                  //JP 1.59
         ::GoPos( nValue )
      else
         ::nAt := nValue
      endif
      if nValue > 0 .and. nValue <= Eval( ::bLogicLen )  // JP 1.59
          Eval( ::bGoToPos, nValue )
      endif
      ::lInitGoTop := .F.
      ::Super:Refresh( .T. )
   endif

Return Self

* ============================================================================
* METHOD TSBrowse:AddColumn() Version 9.0 Nov/30/2009
* ============================================================================

METHOD AddColumn( oColumn ) CLASS TSBrowse

   Local nHeight, nAt, cHeading, cRest, nOcurs, ;
         hFont := If( ::hFont != Nil, ::hFont, 0 )

   Default ::aColSizes := {}

   If ::lDrawHeaders
      cHeading := If( Valtype( oColumn:cHeading ) == "B", Eval( oColumn:cHeading ), oColumn:cHeading )

      If Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0
         nOcurs := 1
         cRest := Substr( cHeading, nAt + 2 )

         While ( nAt := At( Chr( 13 ), cRest ) ) > 0
            nOcurs++
            cRest := Substr( cRest, nAt + 2 )
         EndDo

         nHeight := SBGetHeight( ::hWnd, If( oColumn:hFontHead != Nil, oColumn:hFontHead, hFont ), 0 )
         nHeight *= ( nOcurs + 1 )

         If ( nHeight + 1 ) > ::nHeightHead
            ::nHeightHead := nHeight + 1
         EndIf
      EndIf
   EndIf

   If ValType( oColumn:cFooting ) $ "CB"
      ::lDrawFooters := If( ::lDrawFooters == Nil, .T., ::lDrawFooters )
      ::lFooting := ::lDrawFooters

      cHeading := If( Valtype( oColumn:cFooting ) == "B", Eval( oColumn:cFooting ), oColumn:cFooting )

      If Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0
         nOcurs := 1
         cRest := Substr( cHeading, nAt + 2 )

         While ( nAt := At( Chr( 13 ), cRest ) ) > 0
            nOcurs++
            cRest := Substr( cRest, nAt + 2 )
         EndDo

         nHeight := SBGetHeight( ::hWnd, If( oColumn:hFontFoot != Nil, oColumn:hFontFoot, hFont ), 0 )
         nHeight *= ( nOcurs + 1 )

         If ( nHeight + 1 ) > ::nHeightHead
            ::nHeightFoot := nHeight + 1
         EndIf
      Else
         nHeight := SBGetHeight( ::hWnd, If( oColumn:hFontFoot != Nil, oColumn:hFontFoot, hFont ), 0 ) + 1
         If nHeight > ::nHeightFoot .and. ::lFooting
            ::nHeightFoot := nHeight
         EndIf
      EndIf
   EndIf

   AAdd( ::aColumns , oColumn )

   If Len( ::aColSizes ) < Len( ::aColumns )
      AAdd( ::aColSizes, oColumn:nWidth )
   EndIf

   If ::aPostList != Nil // from ComboWBlock function

      If ATail( ::aColumns ):lComboBox

         If ValType( ::aPostList[ 1 ] ) == "A"
            ATail( ::aColumns ):aItems := ::aPostList[ 1 ]
            ATail( ::aColumns ):aData := ::aPostList[ 2 ]
            ATail( ::aColumns ):cDataType := ValType( ::aPostList[ 2, 1 ] )
         Else
            ATail( ::aColumns ):aItems := AClone( ::aPostList )
         EndIf
      EndIf

      ::aPostList := Nil

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetColumn() Version 7.0 Oct/10/2007
* ============================================================================
// Not included in V90 only for compatibility
METHOD SetColumn( oColumn, nCol ) CLASS TSBrowse

   ::InsColumn( nCol, oColumn )

RETURN Self

* ============================================================================
* METHOD TSBrowse:AddSuperHead() Version 9.0 Nov/30/2009
* ============================================================================

Method AddSuperHead( nFromCol, nToCol, uHead, nHeight, aColors, l3dLook, uFont, uBitMap, lAdjust, lTransp, ;
                     lNoLines, nHAlign, nVAlign ) CLASS TSBrowse

   Local cHeading, nAt, nLheight, nOcurs, cRest, nLineStyle, nClrText, nClrBack, nClrLine, ;
         hFont := If( ::hFont != Nil, ::hFont, 0 )

   Default lAdjust  := .F., ;
           l3DLook  := ::aColumns[ nFromCol ]:l3DLookHead, ;
           nHAlign  := DT_CENTER, ;
           nVAlign  := DT_CENTER, ;
           lTransp  := .T., ;
           uHead    := ""

   If Valtype( nFromCol ) == "C"
      nFromCol := ::nColumn( nFromCol )
   EndIf

   If Valtype( nToCol ) == "C"
      nToCol := ::nColumn( nToCol )
   EndIf

   uFont := If( uFont != Nil, If( ValType( uFont ) == "O", uFont:hFont, uFont ), uFont )

   If ! Empty( ::aColumns )
      hFont := If( ValType( ::aColumns[ nFromCol]:hFontHead ) == "O", ::aColumns[ nFromCol]:hFontHead, ;
               If( ::aColumns[ nFromCol]:hFontHead != Nil, ::aColumns[ nFromCol]:hFontHead, hFont ) )
   endif

   hFont := If( uFont != Nil, uFont, hFont )

   If ValType( aColors ) == "A"
      ASize( aColors, 3 )

      If ! Empty( ::aColumns )
         nClrText := If( aColors[ 1 ] != Nil, aColors[ 1 ], ::aColumns[ nFromCol ]:nClrHeadFore )
         nClrBack := If( aColors[ 2 ] != Nil, aColors[ 2 ], ::aColumns[ nFromCol ]:nClrHeadBack )
         nClrLine := If( aColors[ 3 ] != Nil, aColors[ 3 ], ::nClrLine )
      Else
         nClrText := If( aColors[ 1 ] != Nil, aColors[ 1 ], ::nClrHeadFore )
         nClrBack := If( aColors[ 2 ] != Nil, aColors[ 2 ], ::nClrHeadBack )
         nClrLine := If( aColors[ 3 ] != Nil, aColors[ 3 ], ::nClrLine )
      EndIf
   Else
      If ! Empty( ::aColumns )
         nClrText := ::aColumns[ nFromCol ]:nClrHeadFore
         nClrBack := ::aColumns[ nFromCol ]:nClrHeadBack
         nClrLine := ::nClrLine
      Else
         nClrText := ::nClrHeadFore
         nClrBack := ::nClrHeadBack
         nClrLine := ::nClrLine
      EndIf
   EndIf

   If uBitMap != Nil .and. ValType( uBitMap ) != "L"

      Default lNoLines := .T.
      cHeading := If( ValType( uBitMap ) == "B", Eval( uBitMap ), uBitMap )
      cHeading := If( ValType( cHeading ) == "O", Eval( ::bBitMapH, cHeading ), cHeading )
      If Empty( cHeading )
         MsgStop( "Image is not found!", "Error" )
         Return Nil
      EndIf
      nLHeight := SBmpHeight( cHeading )

      If nHeight != Nil
         If nHeight < nLHeight .and. lAdjust
            nLHeight := nHeight
         ElseIf nHeight > nLheight
            nLHeight := nHeight
         EndIf
      EndIf

      If ( nLHeight + 1 ) > ::nHeightSuper
         ::nHeightSuper := nLHeight + 1
      EndIf

   Else
      uBitMap := Nil
   EndIf

   cHeading := If( Valtype( uHead ) == "B", Eval( uHead ), uHead )

   Do Case

      Case Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0

         Default lNoLines := .F.

         nOcurs := 1
         cRest := Substr( cHeading, nAt + 2 )

         While ( nAt := At( Chr( 13 ), cRest ) ) > 0
            nOcurs++
            cRest := Substr( cRest, nAt + 2 )
         EndDo

         nLheight := SBGetHeight( ::hWnd, hFont, 0 )
         nLheight *= ( nOcurs + 1 )
         nLheight := If( nHeight == Nil .or. nLheight > nHeight, nLheight, nHeight )

         If ( nLheight + 1 ) > ::nHeightSuper
            ::nHeightSuper := nLHeight + 1
         EndIf

      Case Valtype( cHeading ) == "C"
         Default lNoLines := .F.

         nLheight := SBGetHeight( ::hWnd, hFont, 0 )
         nLheight := If( nHeight == Nil .or. nLheight > nHeight, nLheight, nHeight )

         If ( nLheight + 1 ) > ::nHeightSuper
            ::nHeightSuper := nLHeight + 1
         EndIf

      Case Valtype( cHeading ) == "N" .or. ValType( cHeading ) == "O"
         Default lNoLines := .T.
         uBitMap := uHead

         If ValType( cHeading ) == "O"
            uHead := Eval( ::bBitMapH, cHeading )
         EndIf

         nLheight := SBmpHeight( uHead )
         uHead    := ""

         If nHeight != Nil
            If nHeight < nLHeight .and. lAdjust
               nLheight := nHeight
            ElseIf nHeight > nLheight
               nLheight := nHeight
            EndIf
         EndIf

         If ( nLheight + 1 ) > ::nHeightSuper
            ::nHeightSuper := nLHeight + 1
         EndIf

   EndCase

   nLineStyle := If( lNoLines, 0, 1 )

   AAdd( ::aSuperHead, { nFromCol, nToCol, uHead, nClrText, nClrBack, l3dLook, hFont, uBitMap, lAdjust, nLineStyle, ;
                         nClrLine, nHAlign, nVAlign, lTransp } )

   IF Len(::aSuperHead) > 0
      ::lDrawSuperHd := .t.
   endif

Return Self

* ============================================================================
* METHOD TSBrowse:BiClr() Version 9.0 Nov/30/2009
* ============================================================================

METHOD BiClr( uClrOdd, uClrPair ) CLASS TSBrowse

   uClrOdd  := If( ValType( uClrOdd ) == "B", Eval( uClrOdd, Self ), ;
                   uClrOdd )

   uClrPair := If( ValType( uClrPair ) == "B", Eval( uClrPair, Self ), ;
                   uClrPair )

Return If( ::nAt % 2 > 0, uClrOdd, uClrPair )

* ============================================================================
* METHOD TSBrowse:ChangeFont() Version 9.0 Nov/30/2009
* ============================================================================

METHOD ChangeFont( hFont, nColumn, nLevel ) CLASS TSBrowse

   Local nEle, ;
         lDrawFooters := If( ::lDrawFooters != Nil, ::lDrawFooters, .F. )

   Default nColumn := 0   // all columns

   If nColumn == 0

      If nLevel == Nil

         For nEle := 1 TO Len( ::aColumns )
             ::aColumns[ nEle ]:hFont := hFont
         Next

         If ::lDrawHeaders

            For nEle := 1 TO Len( ::aColumns )
               ::aColumns[ nEle ]:hFontHead := hFont
            Next

         EndIf

         If ::lFooting .and. lDrawFooters

            For nEle := 1 TO Len( ::aColumns )
               ::aColumns[ nEle ]:hFontFoot := hFont
            Next

         EndIf

         If ::lDrawSuperHd

            For nEle := 1 TO Len( ::aSuperHead )
               ::aSuperHead[ nEle, 7 ] := hFont
            Next

         EndIf

      Else

         Do Case

            Case nLevel == 1                                      // nLevel 1 = Cells

               For nEle := 1 TO Len( ::aColumns )
                  ::aColumns[ nEle ]:hFont := hFont
               Next

            Case nLevel == 2  .and. ::lDrawHeaders                // nLevel 2 = Headers

               For nEle := 1 TO Len( ::aColumns )
                  ::aColumns[ nEle ]:hFontHead := hFont
               Next

            Case nLevel == 3 .and. ::lFooting .and. lDrawFooters  // nLevel 3 = Footers

               For nEle := 1 TO Len( ::aColumns )
                  ::aColumns[ nEle ]:hFontFoot := hFont
               Next

            Case nLevel == 4  .and. ::lDrawSuperHd                // nLevel 4 = SuperHeaders

               For nEle := 1 TO Len( ::aSuperHead )
                  ::aSuperHead[ nEle, 7 ] := hFont
               Next

         EndCase

      EndIf

   Else

      If nLevel == Nil

         ::aColumns[ nColumn ]:hFont := hFont

         If ::lDrawHeaders
            ::aColumns[ nColumn ]:hFontHead := hFont
         EndIf

         If ::lFooting .and. lDrawFooters
            ::aColumns[ nColumn ]:hFontFoot := hFont
         EndIf

         If ::lDrawSuperHd
            ::aSuperHead[ nColumn, 7 ] := hFont
         EndIf

      Else

         Do Case

            Case nLevel == 1                                      // nLevel 1 = Cells
               ::aColumns[ nColumn ]:hFont := hFont
            Case nLevel == 2 .and. ::lDrawHeaders                 // nLevel 2 = Headers
               ::aColumns[ nColumn ]:hFontHead := hFont
            Case nLevel == 3 .and. ::lFooting .and. lDrawFooters  // nLevel 3 = Footers
                ::aColumns[ nColumn ]:hFontFoot := hFont
            Case nLevel == 4 .and. ::lDrawSuperHd                 // nLevel 4 = SuperHeaders
                ::aSuperHead[ nColumn, 7 ] := hFont
          EndCase
      EndIf

   EndIf

   If ::lPainted
      SetHeights( Self )
      ::Refresh( .F. )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:DbSkipper() Version 9.0 Nov/30/2009
* ============================================================================

METHOD DbSkipper( nToSkip ) CLASS TSBrowse

   Local nSkipped := 0, ;
         nRecNo   := ( ::cAlias )->( RecNo() )

   Default nToSkip := 0, ;
           ::nAt := 1

   If nToSkip == 0 .or. ( ::cAlias )->( LastRec() ) == 0
//      ( ::cAlias )->( dbSkip( 0 ) )
   ElseIf nToSkip > 0 .and. ! ( ::cAlias )->( EoF() ) // going down

      While nSkipped < nToSkip

         ( ::cAlias )->( DbSkip( 1 ) )

         If ::bFilter != Nil
            While ! Eval( ::bFilter ) .and. ! ( ::cAlias )->( EoF() )
              ( ::cAlias )->( DbSkip( 1 ) )
            EndDo
         EndIf

         If ( ::cAlias )->( Eof() )

            If ::lAppendMode
               nSkipped ++
            Else
               ( ::cAlias )->( DbSkip( -1 ) )
            EndIf

            Exit
         EndIf

         nSkipped ++
      Enddo
   ElseIf nToSkip < 0 .and. ! ( ::cAlias )->( BoF() )  // going up

      While nSkipped > nToSkip

         ( ::cAlias )->( DbSkip( -1 ) )

         If ::bFilter != Nil .and. ! ( ::cAlias )->( BoF() )
            While ! Eval( ::bFilter ) .and. ! ( ::cAlias )->( BoF() )
               ( ::cAlias )->( DbSkip( -1 ) )
            EndDo

            If ( ::cAlias )->( BoF() )
               ( ::cAlias )->( DbGoTo( nRecNo ) )
               Return nSkipped
            EndIf
         EndIf

         If ( ::cAlias )->( Bof() )
            ( ::cAlias )->( DbGoTop() )
            Exit
         EndIf

         nSkipped --
      Enddo
   EndIf

   ::nAt += nSkipped

Return nSkipped

* ============================================================================
* METHOD TSBrowse:Default() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Default() CLASS TSBrowse

   Local nI, nTemp, nElements, aFields, nHeight, nMin, nMax, nPage, bBlock, aJustify, cBlock, ;
          nWidth    := 0, ;
          nTxtWid   := 0, ;
          cAlias    := Alias(), ;
          nMaxWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ), ;
          hFont     := If( ::oFont != Nil, ::oFont:hFont, 0 ), ;
          nAdj      := ::nAdjColumn, ;
          lAutocol  := If( ::lAutoCol == Nil, .F., ::lAutocol )

   Default ::aHeaders  := {}, ;
           ::aColSizes := {}, ;
           ::nOldCell  := 1, ;
           ::lIsTxt    := ("TEXT_" $ ::cAlias), ;
           ::lIsArr    := (::cAlias == "ARRAY")

   If ::bLine == Nil .and. Empty( ::aColumns )

      If Empty( ::cAlias )
         ::cAlias := cAlias
      Else
         cAlias := ::cAlias
      EndIf

      If ! EmptyAlias( ::cAlias )
         If ! ::lIsArr .and. ! ::lIsTxt .and. lAutoCol
            If ::lIsDbf
               If Empty( ::nLen )
                  ::SetDbf()
               EndIf
               ::LoadFields()
            ElseIf ::cAlias == "ADO_"
               If Empty( ::nLen )
                  ::SetRecordSet()
               EndIf
               ::LoadRecordSet()
            EndIf
         EndIf
         If ::lIsArr
            If Len( ::cArray ) == 0 .and. ValType( ::aHeaders ) == "A"
               ::cArray := Array( 1, Len( ::aHeaders ) )
               AEval( ::aHeaders, { | cHead, nEle | ::cArray[1, nEle] := "???", HB_SYMBOL_UNUSED( cHead ) } )
               ::lPhantArrRow := .T.
            EndIf
            If Len( ::cArray ) > 0
               If ValType( ::cArray[ 1 ] ) != "A"
                  ::SetItems( ::cArray )
               Else
                  ::SetArray( ::cArray, .t. )
               Endif
            EndIf
            If ::lPhantArrRow
               ::Deleterow( .t. )
            EndIf
         EndIf
      EndIf

   EndIf

   ::lFirstPaint := .F.

   If ::bLine != Nil .and. Empty( ::aColumns )

      Default nElements := Len( Eval( ::bLine ) )

      aJustify := Afill( Array( nElements ), 0 )

      If Len( ::aHeaders ) < nElements

            ::aHeaders := Array( nElements )
            For nI := 1 to nElements
               if At( '->', FieldName( nI ) ) == 0
                  ::aHeaders[ nI ] := ( cAlias )->( FieldName( nI ) )
               else
                  ::aHeaders[ nI ] := FieldName( nI )
               endif
            Next
      EndIf

      If ValType( ::aColSizes ) == "B"
         ::aColSizes := Eval( ::aColSizes )
      EndIf

      aFields := Eval( ::bLine )

      If Len( ::GetColSizes() ) < nElements
         ::aColSizes := Afill( Array( nElements ), 0 )

         nTxtWid := SBGetHeight( ::hWnd, hFont, 1 )

         For nI := 1 TO nElements
            ::aColSizes[ nI ] := If( ValType( aFields[ nI ] ) != "C", 16, ; // Bitmap handle
                                     ( nTxtWid * Max( Len( ::aHeaders[ nI ] ), Len( aFields[ nI ] ) ) + 1 ) )
         Next

      EndIf

      For nI := 1 To nElements

          If ValType( aFields[ nI ] ) == "N" .or. ValType( aFields[ nI ] ) == "D"
             aJustify[ nI ] := 2
          ElseIf ValType( aFields[ nI ] ) == "B"

             If ValType( Eval( aFields[ nI ] ) ) == "N" .or. ValType( Eval( aFields[ nI ] ) ) == "D"

                aJustify[ nI ] := 2
             Else
                aJustify[ nI ] := 0
             EndIf
          Else
             aJustify[ nI ] := 0
          EndIf
      Next

      ASize( ::aFormatPic, nElements )  // make sure they match sizes

      For nI := 1 To nElements

         bBlock := If( ValType( Eval( ::bLine )[ nI ] ) == "B", Eval( ::bLine )[ nI ], MakeBlock( Self, nI ) )
         cBlock := If( ValType( Eval( ::bLine )[ nI ] ) == "B", ::aLine[ nI ], ;
                                "{||" + cValToChar( ::aLine[ nI ] ) + "}" )
         ::AddColumn( TSColumn():New( ::aHeaders[ nI ], bBlock, ::aFormatPic[nI], { ::nClrText, ::nClrPane, ;
                                      ::nClrHeadFore, ::nClrHeadBack, ::nClrFocuFore, ::nClrFocuBack }, ;
                                      {aJustify[ nI ], 1}, ::aColSizes[ nI ],, ;
                                      ::lEditable .or. ValType( Eval( ::bLine )[ nI ] ) == "B",,,,,,, ;
                                      5,, {.F., .T.},, Self, cBlock ) )

         if At( '->', ::aLine[ nI ] ) == 0
            ATail( ::aColumns ):cData := ::cAlias + "->" + ::aLine[ nI ]
         else
            ATail( ::aColumns ):cData := ::aLine[ nI ]
         endif
      Next

   EndIf

   ::lIsDbf := ! EmptyAlias( ::cAlias ) .and. ! ::lIsArr .and. ! ::lIsTxt .and. ::cAlias != "ADO_"

   If ! Empty( ::aColumns )
      ASize( ::aColSizes, Len( ::aColumns ) ) // make sure they match sizes
   EndIf

   If ::lIsDbf
       If Empty( ::nLen )
          ::SetDbf()
       EndIf
   endif

   // rebuild build the aColSize, it's needed to Horiz Scroll etc
   // and expand selected column to flush table window right

   For nI := 1 To Len( ::aColumns )

      nTemp := ( ::aColSizes[ nI ] := IF(::aColumns[ nI ]:lVisible, ::aColumns[ nI ]:nWidth, 0) )  //JP 1.58

      If ! Empty( nAdj ) .and. ( nWidth + nTemp > nMaxWidth )

         If nAdj < nI
           ::aColumns[ nAdj ]:nWidth := ::aColSizes[ nAdj ] += ( nMaxWidth - nWidth )
         EndIf

         nAdj := 0

      EndIf

      nWidth += nTemp

      If ::lIsDbf .and. ! Empty( ::aColumns[ nI ]:cOrder ) .and. ! ::aColumns[ nI ]:lEdit

         If ::nColOrder == 0
            ::SetOrder( nI )
         EndIf

         ::aColumns[ nI ]:lIndexCol := .T.
      EndIf

      If ValType( ::aColumns[ nI ]:cFooting ) $ "CB" // informs browse that it has footings to display
         ::lDrawFooters := If( ::lDrawFooters == Nil, .T., ::lDrawFooters )
         ::lFooting := ::lDrawFooters
         nHeight := SBGetHeight( ::hWnd, If( ::aColumns[ nI ]:hFontFoot != Nil, ;
                                 ::aColumns[ nI ]:hFontFoot, hFont ), 0 ) + 1
         If nHeight > ::nHeightFoot .and. ::lFooting
            ::nHeightFoot := nHeight
         EndIf

      EndIf

   Next

   // now catch the odd-ball where last column doesn't fill box
   If ! Empty( nAdj ) .and. nWidth < nMaxWidth .and. nAdj < nI
      ::aColumns[ nAdj ]:nWidth := ::aColSizes[ nAdj ] += ( nMaxWidth - nWidth )
   EndIf

   If ::bLogicLen != Nil
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   EndIf

   If ! ::lNoVScroll
      If ::nLen <= ::nRowCount()
         nMin := nMax := 0
      Else
         nMax  := Min( ::nLen, MAX_POS )
         nPage := Min( ::nRowCount(), ::nLen )
      EndIf

      ::oVScroll := TSBScrlBar ():WinNew( nMin, nMax, nPage, .T., Self )
   EndIf

   If ! Empty( ::cAlias ) .and. ::cAlias != "ADO_" .and. ::bKeyNo != Nil
      ::ResetVScroll( .T. )
   EndIf

   If ! ::lNoHScroll
      If ! Empty( ::cAlias ) .and. ::lIsTxt .and. ::oTxtFile != Nil
         nTxtWid := Max( 1, GetTextWidth( 0, "B", hFont ) )
         nMin := 1
         nMax := ::oTxtFile:nMaxLineLength - Int( nMaxWidth / nTxtWid )
         ::oHScroll := TSBScrlBar ():WinNew( nMin, nMax,, .F., Self )
      Else
         nMin := Min( 1, Len( ::aColumns ) )
         nMax := Len( ::aColumns )
         ::oHScroll := TSBScrlBar ():WinNew( nMin, nMax,, .F., Self )
      EndIf

   EndIf

   For nI := 1 To Len( ::aColumns )

      If ::aColumns[ nI ]:hFont == Nil
         ::aColumns[ nI ]:hFont := ::hFont
      EndIf

      If ::aColumns[ nI ]:hFontHead == Nil
         ::aColumns[ nI ]:hFontHead := ::hFont
      EndIf

      If ::aColumns[ nI ]:hFontFoot == Nil
         ::aColumns[ nI ]:hFontFoot := ::hFont
      EndIf

      If ::lLockFreeze .and. ::nFreeze >= nI
         ::aColumns[ nI ]:lNoHilite := .T.
      EndIf

   Next

   ::nHeightHead   := If( ::lDrawHeaders, ::nHeightHead, 0 )
   ::nHeightFoot   := If( ::lFooting .and. ::lDrawFooters, ::nHeightFoot, 0 )
   ::nHeightSpecHd := IF( ::nHeightSpecHd ==0 , SBGetHeight( ::hWnd, hFont, 0 ),::nHeightSpecHd)
   ::nHeightSpecHd := If( ::lDrawSpecHd, ::nHeightSpecHd, 0 )

   If ! ::lNoVScroll
      nPage := Min( ::nRowCount(), ::nLen )
      ::oVScroll:SetPage( nPage, .T. )
   EndIf

   If ! ::lNoHScroll
      nPage := 1
      ::oHScroll:SetPage( nPage, .T. )
   EndIf

   If Len( ::aColumns ) > 0
      ::HiliteCell( Max( ::nCell, ::nFreeze + 1 ) )
   EndIf

   ::nOldCell := ::nCell
   ::nLapsus  := Seconds()

   If ::nLen == 0
      ::nLen := If( ::bLogicLen == Nil, Eval( ::bLogicLen := {||( cAlias )->( LastRec() ) } ), Eval( ::bLogicLen ) )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:Del() Version 9.0 Nov/30/2009
* Only for array browse. (ListBox behavior)
* ============================================================================

METHOD Del( nItem ) CLASS TSBrowse

   Default nItem := ::nAt

   If ! ::lIsArr
      Return Self
   EndIf

   ARRDEL_( ::aArray, nItem  )

   ::nLen := Eval( ::bLogicLen )
   ::Refresh( .T., .T. )

Return Self

* ============================================================================
* METHOD TSBrowse:DelColumn() Version 9.0 Nov/30/2009
* ============================================================================

METHOD DelColumn( nPos ) CLASS TSBrowse

   Local oCol, nMin, nMax, nI, ;
         nLen := Len( ::aSuperHead )

   Default nPos := 1

   If Len( ::aColumns ) == 1                     // cannot delete last column
      Return Nil                                 // ... or Nil if last column
   EndIf

   If Valtype( nPos ) == "C"
      nPos := ::nColumn( nPos )  // 23.07.2015
   EndIf

   If nPos < 1
      nPos := 1
   ElseIf nPos > Len( ::aColumns )
      nPos := Len( ::aColumns )
   EndIf

   oCol := ::aColumns[ nPos ]
   ARRDEL_( ::aColumns, nPos  )
   ARRDEL_( ::aColSizes, nPos )

   If ::lSelector .and. nPos == 1
      Return Nil
   EndIf

   If ::nColOrder == nPos                        // deleting a ::SetOrder() column
      ::nColOrder := 0                           // to avoid runtime error
      ::cOrderType := ""
   ElseIf ::nColOrder != 0 .and. ::nColOrder > nPos .and. ::nColOrder <= Len( ::aColumns )
      ::nColOrder --
   EndIf

   If ::nCell > Len( ::aColSizes )
      If ! ::IsColVisible( ::nCell - 1 )
         ::GoLeft()
      Else
         ::nCell--
      EndIf
   EndIf

   ::HiliteCell( ::nCell )                       // make sure we have a hilited cell

   If ! ::lNoHScroll
      nMin := Min( 1, Len( ::aColumns ) )
      nMax := Len( ::aColumns )
      ::oHScroll := TSBScrlBar ():WinNew( nMin, nMax,, .F., Self )
      ::oHScroll:SetRange( 1, Len( ::aColumns ) )
      ::oHScroll:SetPage( 1 , .T. )

      If ::nCell == Len( ::aColSizes )
         ::oHScroll:GoBottom()
      Else
         ::oHScroll:SetPos( ::nCell )
      EndIf

   EndIf

   If ! Empty( ::aSuperHead )

      For nI := 1 To nLen

         If nPos >= ::aSuperHead[ nI, 1 ] .and. nPos <= ::aSuperHead[ nI, 2 ]

            ::aSuperHead[ nI, 2 ] --

            If ::aSuperHead[ nI, 2 ] < ::aSuperHead[ nI, 1 ]
               ASize( ADel( ::aSuperHead, nI ), Len( ::aSuperHead ) - 1 )
            EndIf

         ElseIf nPos < ::aSuperHead[ nI, 1 ]
            ::aSuperHead[ nI, 1 ] --
            ::aSuperHead[ nI, 2 ] --
         EndIf

      Next

   EndIf

   ::SetFocus()
   ::Refresh( .F. )

Return oCol

* ============================================================================
* METHOD TSBrowse:DeleteRow() Version 9.0 Nov/30/2009
* ============================================================================

METHOD DeleteRow(lAll) CLASS TSBrowse

   Local lRecall, lUpStable, nAt, nRowPos, nRecNo, lRefresh, cAlias, lEval, uTemp

   DEFAULT lAll := .f.

   If ( ! ::lCanDelete .OR. ::nLen == 0 ) .and. ! ::lPhantArrRow  // Modificado por Carlos - Erro Keychar
      Return .f.
   EndIf

   If ::lIsDbf
      cAlias := ::cAlias
   EndIf

   nRecNo := ( cAlias  )->( RecNo() )

   lRecall := ! Set( _SET_DELETED )
   lUpStable := ! lRecall

   If ! ::lIsTxt

      If ::lConfirm .and. !lAll .and.;
         ! MsgYesNo( If( ::lIsDbf, ::aMsg[ 37 ], ::aMsg[ 38 ] ), ::aMsg[ 39 ] )
         Return .f.
      EndIf

      If ::lAppendMode
         Return .f.
      EndIf

      ::SetFocus()

      If ::lIsDbf
         ( cAlias )->( DbGoTo( nRecNo ) )
      EndIf

      Do Case

         Case ::lIsDbf
            lEval := .T.

            If ::bDelete != Nil
               lEval := Eval( ::bDelete, nRecNo, Self )
            EndIf

            If ValType( lEval ) == "L" .and. ! lEval
               Return .f.
            EndIf

            If !( "SQL" $ ::cDriver )
               If ! ( cAlias )->( RLock() )
                  MsgStop( ::aMsg[ 40 ] , ::aMsg[ 28 ] )
                  Return .f.
               EndIf
            EndIf

            If ! ( cAlias )->( Deleted() )
               ( cAlias )->( DbDelete() )
               if !("SQL" $ ::cDriver)
                  ( cAlias )->( DbUnlock() )
               endif
               ::nLen := ( cAlias )->( Eval( ::bLogicLen ) )

               If lUpStable
                  ( cAlias )->( DbSkip() )
                  lRefresh :=  ( cAlias )->( EOF() )
                  ( cAlias )->( DbSkip( -1 ) )
                  ::nRowPos -= If( lRefresh .and. ;
                                   ! ( cAlias )->( BOF() ), 1, 0 )
                  ::Refresh( .T. )
               EndIf

            ElseIf lRecall
               ( cAlias )->( DbRecall() )
               ( cAlias )->( DbUnlock() )
            EndIf

            If ::lCanAppend .and. ::nLen == 0
               ::nRowPos := ::nColPos := 1
               ::PostMsg( WM_KEYDOWN, VK_DOWN, nMakeLong( 0, 0 ) )
            EndIf

            If ::bPostDel != Nil
               Eval( ::bPostDel, Self )
            EndIf

            ::lHasChanged := .T.

         Case ::lIsArr

            nAt     := ::nAt
            nRowPos := ::nRowPos
            lEval   := .T.

            If ::bDelete != Nil .and. ! ::lPhantArrRow
               lEval := Eval( ::bDelete, nAt, Self, lAll )
            EndIf

            If ValType( lEval ) == "L" .and. ! lEval
               Return .f.
            EndIf

            If lAll
               ::aArray := {}
               ::aSelected := {}
               if  ::nColOrder != 0
                  ::aColumns[ ::nColOrder ]:cOrder := ""
                  ::aColumns[ ::nColOrder ]:lDescend := Nil
                  ::nColOrder := 0
               endif
            Else
               ARRDEL_( ::aArray, nAt )
               If ::lCanSelect .and. Len( ::aSelected ) > 0
                  If ( uTemp := AScan( ::aSelected, nAt ) ) > 0
                     ARRDEL_( ::aSelected, uTemp )
                  EndIf
                  AEval( ::aSelected, {|x,nEle| ::aSelected[nEle] := If(x > nAt, x-1, x)} )
               EndIf
            EndIf

            If Len( ::aArray ) == 0
               ::aArray := { AClone( ::aDefValue ) }
               ::lPhantArrRow := .T.
               If ::aArray[ 1, 1 ] == Nil
                  ARRDEL_( ::aArray[ 1 ], 1 )
               EndIf
            EndIf

            If ::bPostDel != Nil
               Eval( ::bPostDel, Self )
            EndIf

            ::lHasChanged := .T.
            ::nLen        := Len( ::aArray )
            ::nAt         := Min( nAt, ::nLen )
            ::nRowPos     := Min( nRowPos, ::nLen )

            ::Refresh( ::nLen < ::nRowCount() )
            ::DrawSelect()
            If lAll
               ::DrawHeaders()
            EndIf

      EndCase

   Else
      ::SetFocus()
      ::DrawSelect()
   EndIf

Return ::lHasChanged

* ============================================================================
* METHOD TSBrowse:Destroy() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Destroy() CLASS TSBrowse

   Local i

   Default ::lDestroy := .F.

   If ::uBmpSel != Nil .and. ::lDestroy
      DeleteObject ( ::uBmpSel )
   EndIf

   If ::hBrush != Nil   // Alen Uzelac 13.09.2012
      DeleteObject ( ::hBrush )
   EndIf

   If ::oCursor != Nil  // GF 29.02.2016
      ::oCursor:End()
   EndIf

   If ::hBmpCursor != Nil
      DeleteObject ( ::hBmpCursor )
   EndIf

   If ::aSortBmp != Nil
      DeleteObject ( ::aSortBmp[ 1 ] )
      DeleteObject ( ::aSortBmp[ 2 ] )
   EndIf

   If ::aCheck != Nil
      DeleteObject ( ::aCheck[ 1 ] )
      DeleteObject ( ::aCheck[ 2 ] )
   EndIf

   If Len( ::aColumns ) > 0
      For i := 1 To Len( ::aColumns )
         If Valtype( ::aColumns[ i ]:aCheck ) == "A"
            AEval( ::aColumns[ i ]:aCheck, {|hBmp| If( Empty( hBmp ), , DeleteObject( hBmp ) ) } )
         EndIf
         If Valtype( ::aColumns[ i ]:aBitMaps ) == "A"
            AEval( ::aColumns[ i ]:aBitMaps, {|hBmp| If( Empty( hBmp ), , DeleteObject( hBmp ) ) } )
         EndIf
      Next
   EndIf
#ifndef _TSBFILTER7_
   If ::lFilterMode
      ::lFilterMode := .F.
      If Select( ::cAlias ) != 0
         ::SetFilter()
      EndIf
   EndIf
#endif
   ::hWnd := 0

Return 0

* ============================================================================
* METHOD TSBrowse:Display() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Display() CLASS TSBrowse

   Default ::lFirstPaint := .T.

   If Empty( ::aColumns ) .and. ! ::lFirstPaint
      Return 0
   EndIf

   ::BeginPaint()
   ::Paint()
   ::EndPaint()

Return 0

* ============================================================================
* METHOD TSBrowse:DrawHeaders() Version 9.0 Nov/30/2009
* ============================================================================

METHOD DrawHeaders( lFooters ) CLASS TSBrowse

   Local nI, nJ, nBegin, nStartCol, oColumn, l3DLook, nClrFore, lAdjBmp, nAlign, nClrBack, hFont, cFooting, ;
         cHeading, hBitMap, nLastCol, lMultiLine, nVertText, nClrTo, lOpaque, lBrush, nClrToS, nClrBackS, lOrder, lDescend, ;
         nMaxWidth    := ::nWidth() , ;
         aColSizes    := AClone( ::aColSizes ), ;   // use local copies for speed
         nHeightHead  := ::nHeightHead, ;
         nHeightFoot  := ::nHeightFoot, ;
         nHeightSpecHd:= ::nHeightSpecHd

   Local nHeightSuper := ::nHeightSuper, ;
         nVAlign      := 1, ;
         l3DText, nClr3dL, nClr3dS

   Local hWnd         := ::hWnd, ;
         hDC          := ::hDc, ;
         nClrText     := ::nClrText, ;
         nClrPane     := ::nClrPane, ;
         nClrHeadFore := ::nClrHeadFore, ;
         nClrHeadBack := ::nClrHeadBack, ;
         nClrFootFore := ::nClrFootFore, ;
         nClrFootBack := ::nClrFootBack, ;
         nClrOrdeFore := ::nClrOrdeFore, ;
         nClrOrdeBack := ::nClrOrdeBack, ;
         nClrSpcHdFore:= IF(::lEnum,::nClrHeadFore,::nClrText),;
         nClrSpcHdBack:= IF(::lEnum,::nClrHeadBack,::nClrPane),;
         nClrSpcHdAct := ::nClrSpcHdActive,;
         nClrLine     := ::nClrLine

   Default lFooters := .F.

   If Empty( ::aColumns )
      Return Self
   EndIf

   If ::aColSizes == Nil .or. Len( ::aColSizes ) < Len( ::aColumns )
      ::aColSizes := {}
      For nI := 1 To Len( ::aColumns )
         AAdd( ::aColSizes, IF(::aColumns[ nI ]:lVisible, ::aColumns[ nI ]:nWidth, 0) )   //JP 1.58
      Next
   EndIf

   If ::lMChange   //GF 1.96
      For nI := 1 To Len( ::aColumns )
         If ::aColumns[ nI ]:lVisible
            aColSizes[ nI ] := Max(::aColumns[ nI ]:nWidth, ::nMinWidthCols)
            ::aColumns[ nI ]:nWidth := aColSizes[ nI ]
            ::aColSizes[ nI ] := aColSizes[ nI ]
         EndIf
      Next
   EndIf

   nClrBack := If( ::nPhantom == -1, ATail( ::aColumns ):nClrHeadBack, nClrPane )
   nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
   nClrFore := If( ::nPhantom == -1, ATail( ::aColumns ):nClrFootBack, nClrPane )
   nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore ), nClrFore )
   l3DLook  := If( ::nPhantom == -1, ATail( ::aColumns ):l3DLookHead, .F. )

   If ::oPhant == Nil
      // "Phantom" column; :nPhantom hidden IVar
      ::oPhant := TSColumn():New(   "", ; // cHeading
                              {|| "" }, ; // bdata
                                   nil, ; // cPicture
                 { nClrText, nClrPane,, ;
              nClrBack,,,,,,nClrFore }, ; // aColors
                                   nil, ; // aAlign
                            ::nPhantom, ; // nWidth
                                   nil, ; // lBitMap
                                   nil, ; // lEdit
                                   nil, ; // bValid
                                   .T., ; // lNoLite
                                   nil, ; // cOrder
                                   nil, ; // cFooting
                                   nil, ; // bPrevEdit
                                   nil, ; // bPostEdit
                                   nil, ; // nEditMove
                                   nil, ; // lFixLite
                  { l3DLook, l3DLook }, ;
                                   nil, ;
                                  Self  )
   Else
      ::oPhant:nClrFore := nClrText
      ::oPhant:nClrBack := nClrBack
      ::oPhant:nWidth   := ::nPhantom
      ::oPhant:l3DLookHead := l3DLook
   EndIf

   nLastCol := Len( ::aColumns ) + 1
   AAdd( aColSizes, ::nPhantom )

   nJ := nStartCol := 0

   nBegin := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ::nColPos - ::nFreeze ), ;
                      ::nColPos - ::nFreeze ), nLastCol )

   If Empty( ::aColumns )
      Return Self
   EndIf

   If ! Empty( ::aSuperHead ) .and. ! lFooters
      ::DrawSuper()
   EndIf

   For nI := nBegin To nLastCol

      If nStartCol > nMaxWidth
         Exit
      EndIf

      nJ := If( nI < ::nColPos, nJ + 1, nI )

      oColumn := If( nJ > Len( ::aColumns ), ::oPhant, ::aColumns[ nJ ] )
      If ::lDrawHeaders .and. ! lFooters

         nVertText := 0
         lOrder    := ::nColOrder == nJ
         lDescend  := oColumn:lDescend

         If LoWord( oColumn:nHAlign ) == DT_VERT
            cHeading := "Arial"

            hFont := InitFont ( cHeading, -11, .f., .f., .f. , .f. , 900 )

            nVAlign   := 2
            nVertText := 1

         Else
            hFont    := If( oColumn:hFontHead == Nil, ::hFont, oColumn:hFontHead )
            hFont    := If( ValType( hFont ) == "B", Eval( hFont, 0, nJ, Self ), ;
                           hFont )
         EndIf

         l3DLook := oColumn:l3DLookHead
         nAlign  := If( ValType( oColumn:nHAlign ) == "B", ;
                    Eval( oColumn:nHAlign, nJ, Self ), oColumn:nHAlign )

         If ( nClrFore := If( ::nColOrder == nI, oColumn:nClrOrdeFore, ;
                             oColumn:nClrHeadFore ) ) == Nil
            nClrFore := If( ::nColOrder == nI, nClrOrdeFore, ;
                         nClrHeadFore )
         EndIf

         nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore, nJ, Self ), nClrFore )
         If !( nJ == 1 .and. ::lSelector )
            If ( nClrBack := If( ::nColOrder == nI, oColumn:nClrOrdeBack, oColumn:nClrHeadBack ) ) == Nil
               nClrBack := If( ::nColOrder == nI, nClrOrdeBack, nClrHeadBack )
            EndIf
         else
            nClrBack := iif( ::nClrSelectorHdBack == Nil, ATail( ::aColumns ):nClrHeadBack, ::nClrSelectorHdBack )
         endif

         nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, nJ, Self ), nClrBack )

         lBrush   := Valtype( nClrBack ) == "O"

         If ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         Else
            nClrTo   := nClrBack
         EndIf
         If lOrder
            Default lDescend := .F., ::aSortBmp := { StockBmp( 4 ), StockBmp( 5 ) }
            hBitMap := ::aSortBmp[ If( lDescend, 2, 1 ) ]
            nAlign  := nMakeLong( If( nAlign == DT_RIGHT, DT_LEFT, nAlign ), DT_RIGHT )
         Else
            hBitMap    := If( ValType( oColumn:uBmpHead ) == "B", Eval( oColumn:uBmpHead, nJ, Self ), oColumn:uBmpHead )
            hBitMap    := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         EndIf

         cHeading   := If( Valtype( oColumn:cHeading ) == "B", Eval( oColumn:cHeading, nJ, Self ), oColumn:cHeading )
         lAdjBmp    := oColumn:lAdjBmpHead
         lOpaque    := .T. //oColumn:nOpaque == 2
         lMultiLine := ( Valtype( cHeading ) == "C" .and. At( Chr( 13 ), cHeading ) > 0 )
         Default hBitMap := 0

         If lMultiLine
            nVAlign := DT_TOP
         EndIf

         If oColumn:l3DTextHead != Nil
            l3DText := oColumn:l3DTextHead
            nClr3dL := oColumn:nClr3DLHead
            nClr3dS := oColumn:nClr3DSHead
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nJ, Self ), nClr3dS )
         Else
            l3DText := nClr3dL := nClr3dS := Nil
         EndIf

         TSDrawCell(      hWnd, ;  // 1
                           hDC, ;  // 2
                             0, ;  // 3
                     nStartCol, ;  // 4
               aColSizes[ nJ ], ;  // 5
                      cHeading, ;  // 6
                        nAlign, ;  // 7
                      nClrFore, ;  // 8
                      nClrBack, ;  // 9
                         hFont, ;  // 10
                       hBitMap, ;  // 11
                   nHeightHead, ;  // 12
                       l3DLook, ;  // 13
                             1, ;  // 14 nLineStyle
                      nClrLine, ;  // 15
                             1, ;  // 16 1=Header 2=Footer 3=Super 4=Special
                   nHeightHead, ;  // 17
                   nHeightFoot, ;  // 18
                  nHeightSuper, ;  // 19
                 nHeightSpecHd, ;  // 20
                       lAdjBmp, ;  // 21
                    lMulTiLine, ;  // 22
                       nVAlign, ;  // 23
                     nVertText, ;  // 24
                        nClrTo, ;  // 25
                       lOpaque, ;  // 26
                    If( lBrush, ;
          nClrBack:hBrush, 0 ), ;  // 27
                       l3DText, ;  // 28  3D text
                       nClr3dL, ;  // 29  3D text light color
                       nClr3dS )   // 30  3D text shadow color

         nVAlign := 1

         If LoWord( oColumn:nHAlign ) == DT_VERT
            DeleteObject( hFont )
         EndIf

      EndIf

      IF ::lDrawSpecHd

         hFont    := If( oColumn:hFontSpcHd == Nil, ::hFont, oColumn:hFontSpcHd )
         hFont    := If( ValType( hFont ) == "B", Eval( hFont, 0, nJ, Self ), hFont )

         l3DLook := oColumn:l3DLookHead
         nAlign  := If( ValType( oColumn:nSAlign ) == "B", Eval( oColumn:nSAlign, nJ, Self ), oColumn:nSAlign )

         If ( nClrFore := If( ::nColOrder == nI, oColumn:nClrOrdeFore, oColumn:nClrSpcHdFore ) ) == Nil
            nClrFore := If( ::nColOrder == nI, nClrOrdeFore, nClrSpcHdFore )
         EndIf

         nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore, nJ, Self ), nClrFore )

         nClrBacks := If( ::nPhantom == -1, ATail( ::aColumns ):nClrSpcHdBack, nClrPane )
         nClrBackS := If( ValType( nClrBackS ) == "B", Eval( nClrBackS, nJ, Self ), nClrBackS )
         lBrush := Valtype( nClrBackS ) == "O"

         If ValType( nClrBackS ) == "A"
            nClrToS   := nClrBackS[ 2 ]
            nClrBackS := nClrBackS[ 1 ]
            nClrToS := If( ValType( nClrToS ) == "B", Eval( nClrToS ), nClrToS )
            nClrBackS := If( ValType( nClrBackS ) == "B", Eval( nClrBackS ), nClrBackS )
         Else
            nClrToS := nClrBackS
         EndIf
         if ::lEnum
            cHeading   := AllTrim(Str(nI - iif(::lSelector, 1, 0)))
            if nI == nBegin .and. ::lSelector .or. nI == nLastCol
               cHeading := ""
            endif
         else
            cHeading := If( Valtype( oColumn:cSpcHeading ) == "B", Eval( oColumn:cSpcHeading, nJ, Self ), oColumn:cSpcHeading )
            If Empty( oColumn:cPicture  )
               cHeading := If( Valtype( cHeading ) != "C", cValToChar( cHeading ), cHeading )
            Else
               cHeading := If( cHeading == NIL, "", Transform( cHeading, oColumn:cPicture ) )
            EndIf

            nAlign := oColumn:nAlign
            nClrBackS := If(Empty(cHeading),nClrBackS,CLR_HRED)
            nClrBackS := IF(oColumn:lEditSpec,nClrBackS,nClrBack)
            nClrToS   := IF(oColumn:lEditSpec,nClrToS  ,nClrTo)
         ENDIF
         if nI == nLastCol
            nClrBackS := If( ::nPhantom == PHCOL_GRID, nClrBackS, ::nClrPane )
            nClrTo    := nClrBackS
         endif
         hBitMap := If( ValType( oColumn:uBmpSpcHd ) == "B", Eval( oColumn:uBmpSpcHd, nJ, Self ), oColumn:uBmpSpcHd )
         hBitMap := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         lAdjBmp := oColumn:lAdjBmpSpcHd
         lOpaque := .t.
         Default hBitMap := 0

         If oColumn:l3DTextHead != Nil
            l3DText := oColumn:l3DTextSpcHd
            nClr3dL := oColumn:nClr3DLSpcHd
            nClr3dS := oColumn:nClr3DSSpcHd
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nJ, Self ), nClr3dS )
         Else
            l3DText := nClr3dL := nClr3dS := Nil
         EndIf

         TSDrawCell(     hWnd, ;  // 1
                          hDC, ;  // 2
                            0, ;  // 3
                    nStartCol, ;  // 4
                aColSizes[nJ], ;  // 5
                     cHeading, ;  // 6
                       nAlign, ;  // 7
                     nClrFore, ;  // 8
                    nClrBackS, ;  // 9
                        hFont, ;  // 10
                      hBitMap, ;  // 11
                            0, ;  // 12  nHeightFoot
                      l3DLook, ;  // 13
                            1, ;  // 14  nLineStyle
                     nClrLine, ;  // 15
                            4, ;  // 16  1=Header 2=Footer 3=Super  4=Special
                  nHeightHead, ;  // 17
                  nHeightFoot, ;  // 18
                 nHeightSuper, ;  // 19
                nHeightSpecHd, ;  // 20
                      lAdjBmp, ;  // 21
                          .f., ;  // 22
                      nVAlign, ;  // 23
                            0, ;  // 24 nVertText
                      nClrToS, ;  // 25
                      lOpaque, ;  // 26
                   If( lBrush, ;
        nClrBackS:hBrush, 0 ), ;  // 27
                      l3DText, ;  // 28  3D text
                      nClr3dL, ;  // 29  3D text light color
                      nClr3dS )   // 30  3D text shadow color

      endif

      If ::lFooting .and. ::lDrawFooters

         hFont   := If( oColumn:hFontFoot == Nil, ::hFont, oColumn:hFontFoot )
         hFont   := If( ValType( hFont ) == "B", Eval( hFont, 0, nJ, Self ), hFont )
         l3DLook := oColumn:l3DLookFoot

         ::oPhant:l3DLookFoot := l3DLook

         nAlign   := If( ValType( oColumn:nFAlign ) == "B", Eval( oColumn:nFAlign ), oColumn:nFAlign )
         nClrFore := If( oColumn:nClrFootFore != Nil, oColumn:nClrFootFore , nClrFootFore )
         nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore, nJ, Self ), nClrFore )
         If !( nJ == 1 .and. ::lSelector )    //JP
            nClrBack := If( oColumn:nClrFootBack != Nil, oColumn:nClrFootBack, nClrFootBack )
         Else
            nClrBack := ATail( ::aColumns ):nClrFootBack
         EndIf
         nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, nJ, Self ), nClrBack )

         lBrush := Valtype( nClrBack ) == "O"

         If ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         Else
            nClrTo := nClrBack
         EndIf

         If nI == nBegin .and. ::lSelector   //JP
            cFooting := ""
         Else
            cFooting := If( Valtype( oColumn:cFooting ) == "B", Eval( oColumn:cFooting, nJ, Self ), oColumn:cFooting )
         EndIf

         If ValType( cFooting ) == "O"
            oColumn:uBmpFoot := cFooting
            cFooting := ""
         EndIf

         hBitMap    := If( ValType( oColumn:uBmpFoot ) == "B", Eval( oColumn:uBmpFoot, nJ, Self ), oColumn:uBmpFoot )
         hBitMap    := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         lOpaque    := .t.
         lAdjBmp    := oColumn:lAdjBmpFoot
         lMultiLine := Valtype( cFooting ) == "C" .and. At( Chr( 13 ), cFooting ) > 0
         Default hBitMap := 0

         If oColumn:l3DTextFoot != Nil
            l3DText := oColumn:l3DTextFoot
            nClr3dL := oColumn:nClr3DLFoot
            nClr3dS := oColumn:nClr3DSFoot
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nJ, Self ), nClr3dS )
         Else
            l3DText := nClr3dL := nClr3dS := Nil
         EndIf

         TSDrawCell(     hWnd, ;  // 1
                          hDC, ;  // 2
                ::nRowCount(), ;  // 3
                    nStartCol, ;  // 4
                aColSizes[nJ], ;  // 5
                     cFooting, ;  // 6
                       nAlign, ;  // 7
                     nClrFore, ;  // 8
                     nClrBack, ;  // 9
                        hFont, ;  // 10
                      hBitMap, ;  // 11
                  nHeightFoot, ;  // 12
                      l3DLook, ;  // 13
                            1, ;  // 14  nLineStyle
                     nClrLine, ;  // 15
                            2, ;  // 16  1=Header 2=Footer 3=Super
                  nHeightHead, ;  // 17
                  nHeightFoot, ;  // 18
                 nHeightSuper, ;  // 19
                nHeightSpecHd, ;  // 20
                      lAdjBmp, ;  // 21
                   lMultiLine, ;  // 22
                      nVAlign, ;  // 23
                            0, ;  // 24 nVertText
                       nClrTo, ;  // 25
                      lOpaque, ;  // 26
                   If( lBrush, ;
         nClrBack:hBrush, 0 ), ;  // 27
                      l3DText, ;  // 28  3D text
                      nClr3dL, ;  // 29  3D text light color
                      nClr3dS )   // 30  3D text shadow color
      EndIf

      nStartCol += aColSizes[nJ]

   Next

Return Self

* ============================================================================
* METHOD TSBrowse:DrawIcons() Version 9.0 Nov/30/2009
* ============================================================================

METHOD DrawIcons() CLASS TSBrowse

   Local cText,  ;
         nWidth := ::nWidth(), ;
         nHeight := ::nHeight(), ;
         nRow := 10, ;
         nCol := 10, ;
         n := 1

   Local nIcons := Int( nWidth / 50 ) * Int( nHeight / 50 ), ;
         hIcon := ExtractIcon( "user.exe", 0 )

   SetBkColor( ::hDC, CLR_BLUE )
   SetTextColor( ::hDC, CLR_WHITE )

   While n <= nIcons .and. ! ( ::cAlias )->( EoF() )
      If ::bIconDraw != nil .and. ::aIcons != nil
         hIcon := ::aIcons[ Eval( ::bIconDraw, Self ) ]
      EndIf

      DrawIcon( ::hDC, nRow, nCol, hIcon )

      If ::bIconText != nil
         cText := cValToChar( Eval( ::bIconText, Self ) )
      Else
         cText := Str( ( ::cAlias )->( RecNo() ) )
      EndIf

      DrawText( ::hDC, cText, { nRow + 35, nCol - 5, nRow + 48, nCol + 40 }, 1 )

      nCol += 50

      If nCol >= nWidth - 32
         nRow += 50
         nCol := 10
      EndIf

      ( ::cAlias )->( DbSkip() )
      n ++

   Enddo

   ( ::cAlias )->( DbSkip( 1 - n ) )

Return Nil

* ============================================================================
* METHOD TSBrowse:DrawLine() Version 9.0 Nov/30/2009
* ============================================================================

METHOD DrawLine( xRow ) CLASS TSBrowse

   Local nI, nJ, nBegin, nStartCol, oColumn, hBitMap, cPicture, hFont, nClrTo, nClrFore, nClrBack, uData, nLastCol, ;
         lAdjBmp, lMultiLine, nAlign, lOpaque, lBrush, lCheck, uBmpCell, ;
         nVertText   := 0, ;
         nVAlign     := 1, ;
         lSelected   := .F., ;
         nMaxWidth   := ::nWidth(), ;
         nRowPos     := ::nRowPos, ;
         nClrText    := ::nClrText, ;
         nClrPane    := ::nClrPane, ;
         lBrushed    := .f.  // ValType( ::oBrush ) == "O" .and. ::oBrush:hBitMap > 0

   Local l3DText, nClr3dL, nClr3dS, l3DLook
   Local aBitMaps, lCheckVal := .F. 

   Local aColSizes    := AClone( ::aColSizes ), ;
         hWnd         := ::hWnd, ;
         hDC          := ::hDC, ;
         nLineStyle   := ::nLineStyle, ;
         nClrLine     := ::nClrLine, ;
         nHeightCell  := ::nHeightCell, ;
         nHeightHead  := If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
         nHeightFoot  := If( ::lDrawFooters != Nil .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
         nHeightSuper := If( ::lDrawHeaders, ::nHeightSuper, 0 ), ;
         nHeightSpecHd:= If( ::lDrawSpecHd, ::nHeightSpecHd, 0 )

   If Empty( ::aColumns )
      Return Nil
   EndIf

   Default xRow := If( ::lDrawHeaders, Max( 1, ::nRowPos ), ::nRowPos )

   IF !::lEnabled
      RETURN SELF
   endif

   ::nPaintRow := xRow
   lSelected   := ::lCanSelect .and. ( AScan( ::aSelected, If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt ) ) ) > 0

   nClrBack := If( ::nPhantom = -1, ATail( ::aColumns ):nClrBack, nClrPane )
   nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, ::nAt, Len( ::aColumns ), Self ), nClrBack )
   l3DLook  := If( ::nPhantom == -1, ATail( ::aColumns ):l3DLook, .F. )

   If ::nLen > 0

      If ::oPhant == Nil
         //  "Phantom" column; :nPhantom hidden IVar
         ::oPhant := TSColumn():New(        "", ; // cHeading
                                 {|| "" }, ; // bdata
                                      Nil, ; // cPicture
                   { nClrText, nClrBack }, ; // aColors
                                      Nil, ; // aAlign
                               ::nPhantom, ; // nWidth
                                      Nil, ; // lBitMap
                                      Nil, ; // lEdit
                                      Nil, ; // bValid
                                      .T., ; // lNoLite
                                      Nil, ; // cOrder
                                      Nil, ; // cFooting
                                      Nil, ; // bPrevEdit
                                      Nil, ; // bPostEdit
                                      Nil, ; // nEditMove
                                      Nil, ; // lFixLite
                              { l3DLook }, ;
                                      Nil, ;
                                     Self )
      Else
         ::oPhant:nClrFore := nClrText
         ::oPhant:nClrBack := nClrBack
         ::oPhant:nWidth   := ::nPhantom
         ::oPhant:l3DLook  := l3DLook
      EndIf

      AAdd( aColSizes, ::nPhantom )

      nJ := nStartCol := 0
      nLastCol := Len( ::aColumns ) + 1
      nBegin := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ;
                  ::nColPos - ::nFreeze ), ::nColPos - ::nFreeze ), nLastCol )

      If ::bOnDrawLine != Nil
         Eval( ::bOnDrawLine, Self )
      EndIf

      For nI := nBegin To nLastCol

         If nStartCol > nMaxWidth
            Exit
         EndIf

         nJ := If( nI < ::nColPos, nJ + 1, nI )

         lSelected := If( nJ == nLastCol, .F., lSelected )
         oColumn  := If( nJ > Len( ::aColumns ), ::oPhant, ::aColumns[ nJ ] )
         cPicture := If( ValType( oColumn:cPicture ) == "B", Eval( oColumn:cPicture, ::nAt, nJ, Self ), ;
                         oColumn:cPicture )
         hFont    := If( oColumn:hFont == Nil, ::hFont, oColumn:hFont )
         hFont    := If( ValType( hFont ) == "B", Eval( hFont, ::nAt, nJ, Self ), ;
                        hFont )
         hFont    := If( hFont == Nil, 0, hFont )

         If ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) )
            uData := ""                     // append mode for arrays
         Else
            uData := Eval( oColumn:bData )
         EndIf

         nVertText := 0
         lCheck := ( oColumn:lCheckBox .and. ValType( uData ) == "L" .and. oColumn:lVisible )

         If lCheck .and. ValType( uData ) == "L"
            cPicture:= ""
            nVertText := If( uData, 3, 4 )
            lCheckVal := uData 
         EndIf

         nAlign := oColumn:nAlign

         uBmpCell := oColumn:uBmpCell

         If nJ == ::nColSel .and. ::uBmpSel != Nil .and. lSelected
            uBmpCell := ::uBmpSel
            nAlign   := nMakeLong( LoWord( nAlign ), ::nAligBmp )
         ElseIf oColumn:lBitMap .and. Valtype( uData ) == "N"
            aBitMaps := If( Valtype( oColumn:aBitMaps ) == "A", oColumn:aBitMaps, ::aBitMaps )
            If ! Empty( aBitMaps ) .and. uData > 0 .and. uData <= Len( aBitMaps )
               uBmpCell := aBitMaps[ uData ]
            EndIf
            nAlign := nMakeLong( oColumn:nAlign, oColumn:nAlign )
            uData  := ""
         ElseIf ! lCheck .and. oColumn:lEmptyValToChar .and. Empty( uData )
            uData := ""
         ElseIf Empty( cPicture  )
            uData := If( Valtype( uData ) != "C", cValToChar( uData ), uData )
         Else
            uData := If( uData == NIL, "", Transform( uData, cPicture ) )
         EndIf
         nAlign := If( ValType( nAlign ) == "B", Eval( nAlign, nJ, Self ), nAlign )

         If ( nClrFore := oColumn:nClrFore ) == Nil .or. ( lSelected .and. ::uBmpSel == Nil )
            nClrFore := If( ! lSelected, nClrText, ::nClrSeleFore )
         EndIf

         nClrFore := If( Valtype( nClrFore ) == "B", Eval( nClrFore, ::nAt, nJ, Self ), nClrFore )

         If ( nClrBack := oColumn:nClrBack ) == Nil .or. ;
            ( lSelected .and. ::uBmpSel == Nil )
            nClrBack := If( ! lSelected, nClrPane, ::nClrSeleBack )
         EndIf

         nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )

         If ::lTransparent .and. lBrushed //.or. ( ::lTransparent .and. ::oWnd:oBrush != Nil )
            If ! ( nJ == 1 .and. ! Empty( ::hBmpCursor ) )
               nClrBack := If( lBrushed, ::oBrush, ::oWnd:oBrush )
            EndIf
         EndIf

         lBrush := Valtype( nClrBack ) == "O"

         If ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )

            If nJ == 1 .and. ! Empty( ::hBmpCursor )
               nClrTo *= -1
            EndIf
         Else
            nClrTo := nClrBack
         EndIf

         hBitMap := If( ValType( uBmpCell ) == "B", Eval( uBmpCell, nJ, Self ), uBmpCell )
         hBitMap := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         Default hBitMap := 0
         lAdjBmp := oColumn:lAdjBmp
         lOpaque := .T.  //JP

         If lCheck
            Default ::aCheck := { StockBmp( 6 ), StockBmp( 7 ) }
            If Valtype( oColumn:aCheck ) == "A"
               hBitMap := oColumn:aCheck[ If( lCheckVal, 1, 2 ) ]
            Else
               hBitMap := ::aCheck[ If( lCheckVal, 1, 2 ) ]
            EndIf
            nAlign := nMakeLong( DT_CENTER, DT_CENTER )
            uData  := ""
         EndIf

         lMultiLine := Valtype( uData ) == "C" .and. At( Chr( 13 ), uData ) > 0

         If oColumn:l3DTextCell != Nil
            l3DText := oColumn:l3DTextCell
            nClr3dL := oColumn:nClr3DLCell
            nClr3dS := oColumn:nClr3DSCell
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, ::nAt, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, ::nAt, nJ, Self ), nClr3dS )
         Else
            l3DText := nClr3dL := nClr3dS := Nil
         EndIf

         TSDrawCell(                    hWnd, ; // 1
                                         hDC, ; // 2
                                        xRow, ; // 3
                                  nStartCol , ; // 4
                             aColSizes[ nJ ], ; // 5
                                       uData, ; // 6
                                     nAlign , ; // 7
                                    nClrFore, ; // 8
                                    nClrBack, ; // 9
                                       hFont, ; // 10
                                     hBitMap, ; // 11
                                 nHeightCell, ; // 12
                             oColumn:l3DLook, ; // 13
                                  nLineStyle, ; // 14
                                    nClrLine, ; // 15
                                           0, ; // 16 header/footer/super
                                 nHeightHead, ; // 17
                                 nHeightFoot, ; // 18
                                nHeightSuper, ; // 19
                               nHeightSpecHd, ; // 20
                                     lAdjBmp, ; // 21
                                  lMultiline, ; // 22
                                     nVAlign, ; // 23
                                   nVertText, ; // 24
                                      nClrTo, ; // 25
                                     lOpaque, ; // 26
            If( lBrush, nClrBack:hBrush, 0 ), ; // 27
                                    l3DText, ;  // 28  3D text
                                    nClr3dL, ;  // 29  3D text light color
                                    nClr3dS )   // 30  3D text shadow color
         nStartCol += aColSizes[ nJ ]

      Next

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:DrawPressed() Version 9.0 Nov/30/2009
* Header pressed effect
* ============================================================================

METHOD DrawPressed( nCell, lPressed ) CLASS TSBrowse

   Local nI, nLeft, nTop, nBottom, nRight, hDC, hOldPen
   Local hGrayPen  := CreatePen( PS_SOLID, 1, ::nClrLine ), ;
         hWhitePen := CreatePen( PS_SOLID, 1, GetSysColor( COLOR_BTNHIGHLIGHT ) )

   Default lPressed := .T.

   nKeyPressed := Nil

   If Empty( nCell ) .or. nCell > Len( ::aColumns ) .or. ! ::lDrawHeaders
      Return Self
   ElseIf ! lPressed .and. ! ::aColumns[ nCell ]:l3DLookHead
      ::DrawHeaders()
      Return Self
   EndIf

   hDC   := GetDC( ::hWnd )
   nLeft := 0

   If ::nFreeze > 0
      For nI := 1 To Min( ::nFreeze , nCell - 1 )
         nLeft += ::GetColSizes()[ nI ]
      Next
   EndIf

   For nI := ::nColPos To nCell - 1
      nLeft += ::GetColSizes()[ nI ]
   Next

   nTop    := ::nHeightSuper
   nTop    -= If( nTop > 0, 1, 0 )
   nRight  := nLeft + ::aColSizes[ nCell ]
   nBottom := nTop + ::nHeightHead
   hOldPen := SelectObject( hDC, If( lPressed, hGrayPen, hWhitePen ) )

   MoveTo( hDC, nLeft, nBottom )
   LineTo( hDC, nLeft, nTop )
   LineTo( hDC, nRight, nTop )
   SelectObject( hDC, If( lPressed, hWhitePen, hGrayPen ) )
   MoveTo( hDC, nLeft, nBottom - 1 )
   LineTo( hDC, nRight - 1, nBottom - 1 )
   LineTo( hDC, nRight - 1, nTop - 1 )
   SelectObject( hDC, hOldPen )
   DeleteObject( hGrayPen )
   DeleteObject( hWhitePen )
   ReleaseDC( ::hWnd, hDC )

   If lPressed
      nKeyPressed := nCell
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:DrawSelect()  Version 9.0 Nov/30/2009
* ============================================================================

METHOD DrawSelect( xRow ) CLASS TSBrowse

   Local nI, nJ, nBegin, nStartCol, oColumn, nLastCol, hBitMap, hFont, nAlign, cPicture, nClrFore, nClrBack, ;
         lNoLite, uData, l3DLook, lMulti, nClrTo, lOpaque, lBrush, nCursor, lCheck, uBmpCell, cMsg, lTrans, ;
         nVertText := 0, ;
         lAdjBmp   := .F., ;
         lSelected := .F., ;
         nMaxWidth := ::nWidth(), ;    // use local copies for speed
         nRowPos   := ::nRowPos, ;
         aColSizes := AClone( ::aColSizes ), ;
         hWnd      := ::hWnd, ;
         hDC       := ::hDc, ;
         lFocused  := ::lFocused := ( GetFocus() == ::hWnd ), ;
         nVAlign   := 1, ;
         lBrushed  := .f.

   Local l3DText, nClr3dL, nClr3dS
   Local aBitMaps, lCheckVal := .F. 

   Local nClrText     := ::nClrText, ;
         nClrPane     := ::nClrPane, ;
         nClrFocuFore := ::nClrFocuFore, ;
         nClrFocuBack := ::nClrFocuBack, ;
         nClrLine     := ::nClrLine, ;
         nLineStyle   := ::nLineStyle, ;
         nClrSeleBack := ::nClrSeleBack, ;
         nClrSeleFore := ::nClrSeleFore, ;
         nHeightCell  := ::nHeightCell, ;
         nHeightHead  := If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
         nHeightFoot  := If( ::lDrawFooters != Nil .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
         nHeightSuper := If( ::lDrawHeaders, ::nHeightSuper, 0 ),;
         nHeightSpecHd:= If( ::lDrawSpecHd, ::nHeightSpecHd, 0 )

   Default xRow := nRowPos

   ::nPaintRow := xRow

   If Empty( ::aColumns ) .or. ! ::lEnabled
      Return Self
   EndIf

   If _HMG_MainClientMDIHandle != 0 .and. ! lFocused .and. ::hWndParent == GetActiveMdiHandle()
      lFocused := .T.
   EndIf

   ::lDrawSelect := .T.
   lSelected := ::lCanSelect .and. ( AScan( ::aSelected, If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt ) ) > 0 )

   If ( ::lNoLiteBar .or. ( ::lNoGrayBar .and. ! lFocused ) ) .and. Empty( ::hBmpCursor )
      ::DrawLine()   // don't want hilited cursor bar of any color
   ElseIf ::nLen > 0

      nClrBack := If( ::nPhantom = -1 .and. ! Empty( ::aColumns ), ATail( ::aColumns ):nClrBack, nClrPane )
      nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, ::nAt, Len( ::aColumns ), Self ), nClrBack )
      l3DLook  := If( ::nPhantom = -1 .and. ! Empty( ::aColumns ), ATail( ::aColumns ):l3DLook, .F. )

      If ::oPhant == Nil
         // "Phantom" column; :nPhantom hidden IVar
         ::oPhant := TSColumn():New(        "", ; // cHeading
                                 {|| "" }, ; // bdata
                                      nil, ; // cPicture
                   { nClrText, nClrBack }, ; // aColors
                                      nil, ; // aAlign
                               ::nPhantom, ; // nWidth
                                      nil, ; // lBitMap
                                      nil, ; // lEdit
                                      nil, ; // bValid
                                      .T., ; // lNoLite
                                      nil, ; // cOrder
                                      nil, ; // cFooting
                                      nil, ; // bPrevEdit
                                      nil, ; // bPostEdit
                                      nil, ; // nEditMove
                                      nil, ; // lFixLite
                                {l3DLook}, ;
                                      nil, ;
                                     Self )
      Else
         ::oPhant:nClrFore := nClrText
         ::oPhant:nClrBack := nClrBack
         ::oPhant:nWidth   := ::nPhantom
         ::oPhant:l3DLook  := l3DLook
      EndIf

      AAdd( aColSizes, ::nPhantom )
      nJ := nStartCol := 0
      nLastCol := Len( ::aColumns ) + 1
      nBegin   := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ::nColPos - ::nFreeze ), ;
                       ::nColPos - ::nFreeze ), nLastCol )

      For nI := nBegin To nLastCol

         If nStartCol > nMaxWidth
            Exit
         EndIf

         nJ := If( nI < ::nColPos, nJ + 1, nI )
         oColumn := If( nJ > Len( ::aColumns ), ::oPhant, ::aColumns[ nJ ] )

         hFont    := If( oColumn:hFont == Nil, ::hFont, oColumn:hFont )
         hFont    := If( ValType( hFont ) == "B", Eval( hFont, ::nAt, nI, Self ), hFont )
         hFont    := If( hFont == Nil, 0, hFont )
         lAdjBmp  := oColumn:lAdjBmp
         nAlign   := oColumn:nAlign
         lOpaque  := .t.

         If nJ == 1 .and. ! Empty( ::hBmpCursor )
            uBmpCell := ::hBmpCursor
            uData    := ""
            nAlign   := nMakeLong( oColumn:nAlign, oColumn:nAlign )
            lNoLite  := .T.
            lAdjBmp  := .F.
            lTrans   := .F.
            lCheck   := .F.
         Else
            lTrans := ( ::lTransparent .and. lBrushed )

            If ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) )
               uData := ""                         // append mode for arrays
            Else
               uData := Eval( oColumn:bData )
            EndIf

            cPicture  := If( ValType( oColumn:cPicture ) == "B", Eval( oColumn:cPicture, ::nAt, nJ, Self ), ;
                            oColumn:cPicture )

            lCheck    := ( oColumn:lCheckBox .and. ValType( uData ) == "L" .and. oColumn:lVisible )
            lNoLite   := oColumn:lNoLite
            nVertText := 0

            If lCheck
               cPicture := ""
               nVertText := If( uData, 3, 4 )
               lCheckVal := uData 
            EndIf

            uBmpCell := oColumn:uBmpCell

            If nJ == ::nColSel .and. ::uBmpSel != Nil .and. lSelected
               uBmpCell := ::uBmpSel
               nAlign   := nMakeLong( LoWord( nAlign ), ::nAligBmp )
            ElseIf oColumn:lBitMap .and. Valtype( uData ) == "N" 
               aBitMaps := If( Valtype( oColumn:aBitMaps ) == "A", oColumn:aBitMaps, ::aBitMaps )
               If ! Empty( aBitMaps ) .and. uData > 0 .and. uData <= Len( aBitMaps )
                  uBmpCell := aBitMaps[ uData ]
               EndIf
               nAlign := nMakeLong( LoWord( nAlign ), nAlign )
               uData  := ""
            ElseIf ! lCheck .and. oColumn:lEmptyValToChar .and. Empty( uData )
               uData := ""
            ElseIf Empty( cPicture )
               uData := If( Valtype( uData ) != "C", cValToChar( uData ), uData )
            Else
               uData := If( uData == NIL, "", Transform( uData, cPicture ) )
            EndIf
         EndIf

         nAlign := If( ValType( nAlign ) == "B", Eval( nAlign, nJ, Self ), nAlign )

         If lNoLite
            If ( nClrFore := oColumn:nClrFore ) == Nil
               nClrFore := nClrText
            EndIf

            nClrFore := If( Valtype( nClrFore ) == "B", Eval( nClrFore, ::nAt, nJ, Self ), nClrFore )

            If ( nClrBack := oColumn:nClrBack ) == Nil
               nClrBack := nClrPane
            EndIf

            nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )
            nCursor  := 0
         Else
            If ( nClrFore := If( lFocused, oColumn:nClrFocuFore, oColumn:nClrSeleFore ) ) == Nil
               nClrFore := If( lFocused, nClrFocuFore, nClrSeleFore )
            EndIf

            nClrFore := If( Valtype( nClrFore ) == "B", Eval( nClrFore, ::nAt, nJ, Self ), nClrFore )

            If ( nClrBack := If( lFocused, oColumn:nClrFocuBack, oColumn:nClrSeleBack ) ) == Nil
               nClrBack := If( lFocused, nClrFocuBack, nClrSeleBack )
            EndIf

            nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )

            If ValType( nClrBack ) == "N" .and. nClrBack < 0

               nCursor := Abs( nClrBack )

               If ( nClrBack := oColumn:nClrBack ) == Nil
                  nClrBack := nClrPane
               EndIf

               nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )
            Else
               nCursor := 0
            EndIf
         EndIf

         If ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
            If nJ == 1 .and. ! Empty( ::hBmpCursor )
               nClrTo *= -1
            EndIf
         Else
            nClrTo := nClrBack
         EndIf

         lBrush := Valtype( nClrBack ) == "O"
         l3DLook := oColumn:l3DLook

         hBitMap := If( ValType( uBmpCell ) == "B" .and. ! ::lPhantArrRow, Eval( uBmpCell, nJ, Self ), uBmpCell )
         hBitMap := If( ValType( hBitMap ) == "O" .and. ! ::lPhantArrRow, Eval( ::bBitMapH, hBitMap ), hBitMap )

         Default hBitMap := 0
         lMulti  := Valtype( uData ) == "C" .and. At( Chr( 13 ), uData ) > 0

         If lCheck
            Default ::aCheck := { StockBmp( 6 ), StockBmp( 7 ) }
            If Valtype(oColumn:aCheck) == "A"
               hBitMap := oColumn:aCheck[ If( lCheckVal, 1, 2 ) ]
            Else
               hBitMap := ::aCheck[ If( lCheckVal, 1, 2 ) ]
            EndIf
            nAlign := nMakeLong( DT_CENTER, DT_CENTER )
            uData  := ""
         EndIf

         If oColumn:l3DTextCell != Nil
            l3DText := oColumn:l3DTextCell
            nClr3dL := oColumn:nClr3DLCell
            nClr3dS := oColumn:nClr3DSCell
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, ::nAt, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, ::nAt, nJ, Self ), nClr3dS )
         Else
            l3DText := nClr3dL := nClr3dS := Nil
         EndIf

         TSDrawCell(            hWnd, ; //  1
                                 hDC, ; //  2
                             nRowPos, ; //  3
                           nStartCol, ; //  4
                     aColSizes[ nJ ], ; //  5
                               uData, ; //  6
                              nAlign, ; //  7
                            nClrFore, ; //  8
                            nClrBack, ; //  9
                               hFont, ; // 10
                             hBitMap, ; // 11
                         nHeightCell, ; // 12
                             l3DLook, ; // 13
                          nLineStyle, ; // 14
                            nClrLine, ; // 15
                                   0, ; // 16 Header/Footer/Super
                         nHeightHead, ; // 17
                         nHeightFoot, ; // 18
                        nHeightSuper, ; // 19
                       nHeightSpecHd, ; // 20
                             lAdjBmp, ; // 21
                              lMulti, ; // 22 Multiline text
                             nVAlign, ; // 23
                           nVertText, ; // 24
                              nClrTo, ; // 25
                             lOpaque, ; // 26
                          If( lBrush, ;
                nClrBack:hBrush, 0 ), ; // 27
                             l3DText, ; // 28  3D text
                             nClr3dL, ; // 29  3D text light color
                             nClr3dS, ; // 30  3D text shadow color
                             nCursor, ; // 31  Rect cursor
    !(::lCellBrw .and. nJ != ::nCell) ) // 32  Invert color

         nStartCol += aColSizes[ nJ ]

      Next

   EndIf

   If ::bOnDraw != Nil
      Eval( ::bOnDraw, Self )
   EndIf

   If ::lCellBrw
      cMsg := If( ! Empty( ::AColumns[ ::nCell ]:cMsg ), ::AColumns[ ::nCell ]:cMsg, ::cMsg )
      cMsg := If( ValType( cMsg ) == "B", Eval( cMsg, Self, ::nCell ), cMsg )

      If ! Empty( cMsg )
         ::SetMsg( cMsg )
      EndIf
   EndIf

   ::lDrawSelect := .F.

Return Self

* ============================================================================
* METHOD TSBrowse:DrawSuper() Version 9.0 Nov/30/2009
* ============================================================================

METHOD DrawSuper() CLASS TSBrowse

   Local nI, nJ, nBegin, nStartCol, l3DLook, nClrFore, lAdjBmp, nClrTo, lOpaque, nClrBack, hFont, cHeading, hBitMap, ;
         lMulti, nHAlign, nVAlign, nWidth, nS, nLineStyle, lBrush, ;
         nMaxWidth    := ::nWidth() , ;
         aColSizes    := AClone( ::aColSizes ), ;   // use local copies for speed
         aSuperHead   := AClone( ::aSuperHead ), ;
         nHeightHead  := ::nHeightHead, ;
         nHeightFoot  := ::nHeightFoot, ;
         nHeightSuper := ::nHeightSuper, ;
         nHeightSpecHd:= ::nHeightSpecHd

   Local hWnd         := ::hWnd, ;
         hDC          := ::hDc, ;
         nClrText     := ::nClrText, ;
         nClrPane     := ::nClrPane, ;
         nClrLine     := ::nClrLine

   Local l3DText, nClr3dL, nClr3dS

   If Empty( ::aColumns )
       Return Nil
   EndIf

   nClrText   := aSuperHead[ 1, 4 ]
   nClrBack   := aSuperHead[ 1, 5 ]
   l3DLook    := aSuperHead[ 1, 6 ]
   hFont      := aSuperHead[ 1, 7 ]
   nLineStyle := aSuperHead[ 1, 10 ]
   nClrLine   := aSuperHead[ 1, 11 ]

   nBegin := nI := 1

   While nI <= Len( aSuperHead )

      If aSuperHead[ nI, 1 ] > nBegin
         nJ := aSuperHead[ nI, 1 ] - 1
         ASize( aSuperHead, Len( aSuperHead ) + 1 )
         AIns( aSuperHead, nI )
         aSuperHead[ nI ] := { nBegin, nJ, "", nClrText, nClrBack, l3DLook , hFont, .F., .F., nLineStyle, ;
                               nClrLine, 1, 1, .F. }
         nBegin := nJ + 1
      Else
         nBegin := aSuperHead[ nI++, 2 ] + 1
      EndIf

   EndDo

   nI := Len( aSuperHead )
   nClrText   := aSuperHead[ nI, 4 ]
   nClrBack   := aSuperHead[ nI, 5 ]
   l3DLook    := aSuperHead[ nI, 6 ]
   hFont      := aSuperHead[ nI, 7 ]
   nLineStyle := aSuperHead[ nI, 10 ]
   nClrLine   := aSuperHead[ nI, 11 ]

   If ( nI := ATail( aSuperHead )[  2 ] ) < Len( ::aColumns )
        AAdd( aSuperHead, { nI + 1, Len( ::aColumns ), "", nClrText, nClrBack, l3DLook, hFont, .F., .F., nLineStyle, ;
                            nClrLine, 1, 1, .F. } )
   EndIf

   nStartCol := nWidth := 0

   nBegin := If( ::nColPos == ::nFreeze + 1, ::nColPos - ::nFreeze, ::nColPos )

   For nS := 1 To Len( aSuperHead )

      If nBegin >= aSuperHead[ nS, 1 ] .and. nBegin <= aSuperHead[ nS, 2 ]
         Do Case
            Case nBegin > aSuperHead[ nS, 1 ] .and. nS == 1
               For nJ := aSuperHead[ nS, 1 ] To nBegin - 1
                  nStartCol -= ::aColSizes[ nJ ]
               Next

               For nJ := aSuperHead[ nS, 1 ]  To aSuperHead[ nS, 2 ]
                  nWidth += aColSizes[ nJ ]
               Next

            Case nBegin > aSuperHead[ nS, 1 ] .and. nS > 1
               For nJ := 1 To ::nFreeze
                  nStartCol += ::aColSizes[ nJ ]
               Next

               For nJ := nBegin  To aSuperHead[ nS, 2 ]
                   nWidth += aColSizes[ nJ ]
               Next

            OtherWise
               If nBegin > 1
                  For nJ := 1 To ::nFreeze
                     nStartCol += ::aColSizes[ nJ ]
                  Next
               EndIf

               For nJ := aSuperHead[ nS, 1 ]  To aSuperHead[ nS, 2 ]
                  nWidth += aColSizes[ nJ ]
               Next

         EndCase

         Exit

      EndIf

   Next

   For nI := nS To Len( aSuperHead ) + 1

      If nStartCol > nMaxWidth
         Exit
      EndIf

      If nI <= Len( aSuperHead )
         nClrFore := If( ValType( aSuperHead[ nI, 4 ] ) == "B", Eval( aSuperHead[ nI, 4 ] ), aSuperHead[ nI, 4 ] )
         nClrBack := If( ValType( aSuperHead[ nI, 5 ] ) == "B", Eval( aSuperHead[ nI, 5 ] ), aSuperHead[ nI, 5 ] )
         lBrush   := Valtype( nClrBack ) == "O"

         If ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         Else
            nClrTo   := nClrBack
         EndIf

         cHeading := aSuperHead[ nI, 3 ]
         cHeading := If( Valtype( cHeading ) == "B", Eval( cHeading ), cHeading )
         lMulti   := Valtype( cHeading ) == "C" .and. At( Chr( 13 ), cHeading ) > 0

         l3DLook    := aSuperHead[ nI, 6 ]
         hFont      := aSuperHead[ nI, 7 ]
         hBitMap    := aSuperHead[ nI, 8 ]
         hBitMap    := If( ValType( hBitMap ) == "B", Eval( hBitMap ), hBitMap )
         hBitMap    := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         lAdjBmp    := aSuperHead[ nI, 9 ]
         nLineStyle := aSuperHead[ nI, 10 ]
         nClrLine   := aSuperHead[ nI, 11 ]
         nHAlign    := aSuperHead[ nI, 12 ]
         nVAlign    := aSuperHead[ nI, 13 ]
         lOpaque    := aSuperHead[ nI, 14 ]

         Default hBitMap := 0, ;
                 lOpaque := .T.
         lOpaque := ! lOpaque
      Else
         cHeading := ""
         nWidth   := ::nPhantom
         hBitmap  := 0
         lOpaque  := .F.
         nClrBack := If( ::nPhantom == -2, nClrPane, Atail( aSuperHead)[ 5 ] )
         nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         If ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         Else
            nClrTo   := nClrBack
         endif
      EndIf

      If nI <= Len( aSuperHead ) .and. ::aColumns[ aSuperHead[ nI, 1 ] ]:l3DTextHead != Nil
         l3DText := ::aColumns[ aSuperHead[ nI, 1 ] ]:l3DTextHead
         nClr3dL := ::aColumns[ aSuperHead[ nI, 1 ] ]:nClr3DLHead
         nClr3dS := ::aColumns[ aSuperHead[ nI, 1 ] ]:nClr3DSHead
         nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nStartCol ), nClr3dL )
         nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nStartCol ), nClr3dS )
      Else
         l3DText := nClr3dL := nClr3dS := Nil
      EndIf

      TSDrawCell(      hWnd, ;  // 1
                        hDC, ;  // 2
                          0, ;  // 3
                  nStartCol, ;  // 4
                     nWidth, ;  // 5
                   cHeading, ;  // 6
                    nHAlign, ;  // 7
                   nClrFore, ;  // 8
                   nClrBack, ;  // 9
                      hFont, ;  // 10
                    hBitMap, ;  // 11
                nHeightHead, ;  // 12
                    l3DLook, ;  // 13
                 nLineStyle, ;  // 14
                   nClrLine, ;  // 15
                          3, ;  // 16 1=Header 2=Footer 3=Super
                nHeightHead, ;  // 17
                nHeightFoot, ;  // 18
               nHeightSuper, ;  // 19
              nHeightSpecHd, ;  // 20
                    lAdjBmp, ;  // 21
                     lMulTi, ;  // 22 Multiline text
                    nVAlign, ;  // 23
                          0, ;  // 24 nVertLine
                     nClrTo, ;  // 25
                    lOpaque, ;  // 26
                 If( lBrush, ;
       nClrBack:hBrush, 0 ), ;  // 27
                    l3DText, ;  // 28  3D text
                    nClr3dL, ;  // 29  3D text light color
                    nClr3dS )   // 30  3D text shadow color

      nStartCol += nWidth

      nWidth := 0

      If nI < Len( aSuperHead )
         For nJ := aSuperHead[ nI + 1, 1 ] To aSuperHead[ nI + 1, 2 ]
            nWidth += aColSizes[ nJ ]
         Next
      EndIf

   Next

Return Nil

* ============================================================================
* METHOD TSBrowse:Edit() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Edit( uVar, nCell, nKey, nKeyFlags, cPicture, bValid, nClrFore, ;
             nClrBack ) CLASS TSBrowse

   Local nRow, nHeight, cType, uValue, nI, aGet, oCol, cMsg, aRct, bChange, lSpinner, bUp, bDown, ;
         bMin, bMax, nStartX, nWidth, lCombo, lMulti, nCol, lLogicDrop, lPicker, nTxtHeight, hFont, ix
   Local cWnd := ::cControlName

   Default nCell       := ::nCell, ;
           ::lPostEdit := .F., ;
           ::lNoPaint  := .F.

   If ::lPhantArrRow
      Return Nil
   EndIf

   oCol := ::aColumns[ nCell ]

   Default ::nHeightSuper := 0, ;
           nKey           := VK_RETURN, ;
           nKeyFlags      := 0, ;
           uVar           := Eval( oCol:bData ), ;
           cPicture       := oCol:cPicture, ;
           bValid         := oCol:bValid, ;
           nClrFore       := oCol:nClrEditFore, ;
           nClrBack       := oCol:nClrEditBack

   If ValType( ::lInsertMode ) == "L"  //Igor Nazarov
      If IsInsertActive() != ::lInsertMode 
        iif( _HMG_IsXPorLater, KeyToggleNT( VK_INSERT ), KeyToggle( VK_INSERT ) )  
      EndIf
   EndIf

   uValue   := uVar
   cType    := If( Empty( oCol:cDataType ), ValType( uValue ), oCol:cDataType )
   If ::lIsArr .and. oCol:cDataType # ValType( uValue )  // GF 15/07/2009
      cType := ValType( uValue )
      oCol:cDataType := cType
   EndIf
   cMsg     := oCol:cMsgEdit
   bChange  := oCol:bChange
   lSpinner := oCol:lSpinner
   bUp      := oCol:bUp
   bDown    := oCol:bDown
   bMin     := oCol:bMin
   bMax     := oCol:bMax
   nStartX  := 0
   lCombo   := lMulti := .F.
   ::oGet   := ::bValid    //JP
   ::bValid := { || ! ::lEditing }
// JP 1.58
   If !oCol:lVisible
      ::lChanged := .F.
      ::lPostEdit := .F.
      ::oWnd:nLastKey := VK_RIGHT
      ::PostEdit( uVar, nCell, bValid )
      Return Nil
   EndIf
//End
   If oCol:bPassWord != Nil
      If ! Eval( oCol:bPassWord, uValue, nCell, ::nAt, Self )
         Return Nil
      EndIf
   EndIf

   lLogicDrop   := ::lLogicDrop
   lPicker      := ::lPickerMode   //MWS Sep 20/07
   If cType == 'T'
      lPicker := ( hb_Hour( uValue ) == 0 .and. hb_Minute( uValue ) == 0 .and. hb_Sec( uValue ) == 0 )
   EndIf

   ::lEditing   := .T.
   ::lHitBottom := .F.

   If ::nLen > 0
      ::lNoPaint := .T.
   EndIf

   If oCol:bPrevEdit != Nil
      If ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) ) // append mode for arrays
      ElseIf nKey != VK_RETURN // GF 15-10-2015
         Eval( oCol:bPrevEdit, uValue, Self )
      EndIf
   EndIf

   cMsg := If( ValType( cMsg ) == "B", Eval( cMsg, Self, nCell ), cMsg )

   If cType == "L" .and. oCol:lCheckBox

      If nKey != VK_RETURN

         If Upper( Chr( nKey ) ) $ "YCST1"
            ::lChanged := uVar == .F.
            uVar := .T.
         ElseIf Upper( Chr( nKey ) ) $ "FN0"
            ::lChanged := uVar == .T.
            uVar := .F.
         ElseIf nKey == VK_SPACE
            uVar := ! uVar
            ::lChanged := .T.
         Else
            Return 0
         EndIf

         ::lHasChanged := If( ::lChanged, .T., ::lHasChanged )
         ::oWnd:nLastKey := VK_RETURN
         ::PostEdit( uVar, nCell )
         ::lPostEdit := .F.
         Return 0
      Else
         ::lPostEdit := .T.
         ::lChanged := .F.
         ::oWnd:nLastKey := nKey
         ::PostEdit( uVar, nCell )
         ::lPostEdit := .F.
         Return 0
      EndIf
   EndIf

   If oCol:bExtEdit != Nil  // external edition
      ::lNoPaint := ::lEditing := .F.
      uVar := Eval( oCol:bExtEdit, uValue, Self )
      ::lChanged := ( ValType( uVar ) != ValType( uValue ) .or. uVar != uValue )
      ::lPostEdit := .T.
      ::oWnd:nLastKey := VK_RETURN
      ::PostEdit( uVar, nCell, bValid )
      Return Nil
    EndIf

   hFont := If( oCol:hFontEdit != Nil, oCol:hFontEdit, ;
                If( oCol:hFont != Nil, oCol:hFont, ::hFont ) )

   If oCol:oEdit != Nil
      oCol:oEdit:End()
      oCol:oEdit := Nil
   Endif

   If ::nFreeze > 0
      For nI := 1 To Min( ::nFreeze , nCell - 1 )
         nStartX += ::GetColSizes()[ nI ]
      Next
   EndIf

   For nI := ::nColPos To nCell - 1
      nStartX += ::GetColSizes()[ nI ]
   Next

   nClrFore := If( ValType( nClrFore ) == "B", ;
                   Eval( nClrFore, ::nAt, nCell, Self ), nClrFore )

   nClrBack := If( ValType( nClrBack ) == "B", ;
                   Eval( nClrBack, ::nAt, nCell, Self ), nClrBack )

   IF ::nColSpecHd != 0
      nRow    := ::nHeightHead + ::nHeightSuper + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 1 )
      nHeight := ::nHeightSpecHd - If( oCol:l3DLook, 1, -1 )
   else
      nRow    := ::nRowPos - 1
      nRow    := ( nRow * ::nHeightCell ) + ::nHeightHead + ;
                 ::nHeightSuper + ::nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 0 )
      nHeight := ::nHeightCell - If( oCol:l3DLook, 1, -1 )
   endif

   If oCol:cResName != Nil .or. oCol:lBtnGet

      ::cChildControl := GetUniqueName( "BtnBox" )

      oCol:oEdit := TBtnBox():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
                       bSETGET( uValue ), Self, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
                       cPicture, nClrFore, nClrBack, hFont, ::cChildControl, cWnd, ;
                       cMsg, bChange, bValid, oCol:cResName,oCol:bAction, ;
                       lSpinner .and. cType $ "ND", bUp, bDown, ;
                       bMin, bMax, oCol:nBmpWidth, nCell )

      oCol:oEdit:lAppend := ::lAppendMode
      oCol:oEdit:Hide()

   ElseIf ( cType == "C" .and. Chr( 13 ) $ uValue ) .or. cType == "M"

      Default uValue := ""

      If ::nMemoHE == Nil

         If ! Empty( uValue )
            nHeight := Max( 5, StrCharCount( uValue, Chr( 10 ) ) )
         Else
            nHeight := 5
         EndIf

      Else
         nHeight := ::nMemoHE
      EndIf

      aRct := ::GetCliRect( ::hWnd )
      If ::nMemoWE == Nil .or. Empty( ::nMemoWE )
         nWidth := Max( nWidth, GetTextWidth( 0, SubStr( uValue, 1, ;
                                              At( Chr( 13 ), uValue ) - 1 ), ;
                                              If( hFont != Nil, hFont, 0 ) ) )
         nWidth := Min( nWidth, Int( aRct[ 3 ] * .8 ) )
      Else
         nWidth := ::nMemoWE
      EndIf

      nTxtHeight := SBGetHeight( ::hWnd, If( hFont != Nil, hFont, 0 ), 0 )

      While ( nRow + ( nTxtHeight * nHeight ) ) > aRct[ 4 ]
         nRow -= nTxtHeight
      EndDo

      nI := nCol + nWidth - aRct[ 3 ]
      nCol -= If( nI <= 0, 0, nI )
      nCol := Max( 10, nCol )
      nHeight *= nTxtHeight
      ::cChildControl := GetUniqueName( "EditBox" )

      oCol:oEdit := TSMulti():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
                                   bSETGET( uValue ), Self, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
                                   hFont, nClrFore, nClrBack, ::cChildControl, cWnd )
      oCol:oEdit:bGotFocus := { || oCol:oEdit:HideSel(), oCol:oEdit:SetPos( 0 ) }
      lMulti := .T.
      oCol:oEdit:Hide()

   ElseIf ( cType == "L" .and. lLogicDrop ) .or. oCol:lComboBox

      lCombo := .T.

      If oCol:lComboBox

         aGet := oCol:aItems
         If Empty( aGet )
            Return Nil
         EndIf

         If nKey == VK_RETURN
            If oCol:cDataType != Nil .and. oCol:cDataType == "N"
               If oCol:aData <> NIL
                  uValue := Max( 1, AScan( aGet, uValue ) )
               Else
                  uValue := IIf(uValue < 1 .OR. uValue > Len(aGet), 1, uValue)
               EndIf
            Else
               uValue := Max( 1, AScan( aGet, uValue ) )
            EndIf
         Else
            uValue := Max( 1, AScan( aGet, Upper( Chr( nKey ) ) ) )
         EndIf

         If ValType( Eval( oCol:bData ) ) == "N"
            nWidth := 0
            Aeval( aGet, { |x| nWidth := Max( Len(x), nWidth ) } )
            nWidth := Max( GetTextWidth( 0, Replicate( 'B', nWidth ), hFont ), oCol:nWidth )
         EndIf

         nHeight := Max( 10, Min( 10, Len( aGet ) ) ) * ::nHeightCell

      Else

         aGet := { ::aMsg[ 1 ], ::aMsg[ 2 ] }

         If nKey == VK_RETURN
            uValue := iif( uValue, 1, 2 )
         Else
            uValue := Max( 1, AScan( aGet, Upper( Chr( nKey ) ) ) )
         EndIf

         nHeight := ::nHeightCell * 4  //1.54

      EndIf

      ::cChildControl := GetUniqueName( "ComboBox" )

      oCol:oEdit := TComboBox():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
                                   bSETGET( uValue ), aGet, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
                                   Self, bChange, nClrFore, nClrBack, hFont, cMsg, ::cChildControl, cWnd )

      oCol:oEdit:lAppend := ::lAppendMode

   ElseIf ( cType $ "DT" ) .and. lPicker     // MWS Sep 20/07

      nRow -= 2
      nHeight := Max( ::nHeightCell, 19 )
      ::cChildControl := GetUniqueName( "DatePicker" )

      oCol:oEdit := TDatePicker():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
                                 bSETGET( uValue ), Self, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
                                 cPicture,, nClrFore, nClrBack, hFont, ::cChildControl,, cWnd, ;
                                 cMsg,,,,, bChange,,, .T. )
      oCol:oEdit:Hide()

   Else

      ix := GetControlIndex ( cWnd, ::cParentWnd )
      if _HMG_aControlContainerRow [ix] == -1
         nRow += ::nTop - 1
         nCol += ::nLeft
      else
         nRow += _HMG_aControlRow [ix] - 1
         nCol += _HMG_aControlCol [ix]
      endif
      ::cChildControl := GetUniqueName( "GetBox" )

      oCol:oEdit := TGetBox():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
                       bSETGET( uValue ), Self, nWidth+2+::aEditCellAdjust[3], nHeight+2+::aEditCellAdjust[4], ;
                       cPicture,, nClrFore, nClrBack, hFont, ::cChildControl, cWnd, ;
                       cMsg,,,,, bChange, .T.,, lSpinner .and. cType $ "ND", bUp, bDown, ;
                       bMin, bMax, oCol:lNoMinus )

   EndIf

   If oCol:oEdit != Nil

      oCol:oEdit:bLostFocus := { | nKey | ::EditExit( nCell, nKey, uValue, bValid, .F. ) }

      oCol:oEdit:bKeyDown   := { | nKey, nFlags, lExit | If( lExit != Nil .and. lExit, ;
                                   ::EditExit( nCell, nKey, uValue, bValid ), Nil ), HB_SYMBOL_UNUSED( nFlags ) }
      DO CASE
         CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )
            oCol:oEdit:bLostFocus := Nil
         CASE "TGETBOX" $ Upper( oCol:oEdit:ClassName() )
            ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
            _HMG_InteractiveCloseStarted := .T.
            if ix > 0
                If oCol:lOnGotFocusSelect 
                   If ValType(uValue) == "C" 
                      _HMG_aControlGotFocusProcedure [ix] := {|| SendMessage( _HMG_aControlHandles [ix], EM_SETSEL, 0, If( Empty(uValue), -1, Len(Trim(uValue))) ) } 
                   ElseIf ValType(uValue) $ "ND" 
                      _HMG_aControlGotFocusProcedure [ix] := {|| SendMessage( _HMG_aControlHandles [ix], EM_SETSEL, 0, -1 ) } 
                   EndIf 
                EndIf
               _HMG_aControlLostFocusProcedure [ix] := { | nKey | ::EditExit( nCell, nKey, uValue, bValid, .F. ) }
            endif
            if Empty( ::bLostFocus )
               ::bLostFocus := { || iif( _HMG_InteractiveCloseStarted, _HMG_InteractiveCloseStarted := .F., ) }
            endif
      ENDCASE

      oCol:oEdit:SetFocus()

      If nKey != Nil .and. nKey > 31

         If ! lCombo .and. ! lMulti
            ::KeyChar( nKey, nKeyFlags )    //1.53
         EndIf

      Endif

      If oCol:oEdit != Nil
         oCol:oEdit:Show()
      Endif

      ::SetMsg( oCol:cMsgEdit )

      If oCol:bEditing != Nil
         Eval( oCol:bEditing, uVar, Self )
      EndIf

   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:EditExit() Version 7.0 Jul/15/2004
* ============================================================================

METHOD EditExit( nCol, nKey, uVar, bValid, lLostFocus ) CLASS TSBrowse

   Local uValue, cType, oCol, lCombo, cMsg, ix, lSpinner

   Default lLostFocus  := .F., ;
           ::lPostEdit := .F., ;
           nCol        := ::nCell,;
           nKey        := 0

   oCol     := ::aColumns[ nCol ]
   lSpinner := oCol:lSpinner
   lCombo   := ValType( oCol:oEdit ) == "O" .and. "COMBO" $ Upper( oCol:oEdit:ClassName() )

   If ValType( oCol:oEdit ) == "O"
      DO CASE
      CASE "TGETBOX" $ Upper( oCol:oEdit:ClassName() )
         ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
         nKey := _HMG_aControlMiscData1 [ix][3]
         SetFocus( ::hWnd )  // JP 1.59
      CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() ) .and. lSpinner
         if oCol:oEdit:hWndChild != Nil
            PostMessage( oCol:oEdit:hWndChild, WM_CLOSE )
         endif
         SetFocus( ::hWnd )
      ENDCASE
   EndIf
   If nKey == 0
      lLostFocus := .T.
   EndIf

   If ! lLostFocus .and. nKey > 0 .and. (nKey != VK_ESCAPE .or. ::nColSpecHd != 0) .and. ;
      ValType( oCol:oEdit ) == "O"

      ::lPostEdit := .T.
      HideCaret( oCol:oEdit:hWnd )

      If lCombo

         cType := If( oCol:cDataType != Nil, oCol:cDataType, ValType( uVar ) )

         If cType == "L"
            uValue := ( oCol:oEdit:nAt == 1 )
            uVar := If( ValType( uVar ) == "C", ( AScan( oCol:aItems, uVar ) == 1 ), ;
                    If( ValType( uVar ) == "N", ( uVar == 1 ), uVar ) )
         Else
            If oCol:aData != Nil
               If ValType( uValue ) == "N" .and. ValType( uVar ) == "C"
                  uVar := AScan( oCol:aData, uVar )
               EndIf
               ::lChanged := ( oCol:oEdit:nAt != uVar )    //JP 69
               uValue := oCol:aData[ oCol:oEdit:nAt ]
            Else
               If cType == "N"
                  uValue := oCol:oEdit:nAt
               Else
                  uValue := oCol:oEdit:aItems[ oCol:oEdit:nAt ]
                  uVar := Substr(oCol:oEdit:aItems[uVar],1,Len(uValue)) //1.54
               EndIf
               ::lChanged := ( uValue != uVar )            //JP 69
            EndIf
            ::lHasChanged := If( ::lChanged, .T., ::lHasChanged )
         EndIf

         ::oWnd:nLastKey := nKey

         If oCol:bEditEnd != Nil
            Eval( oCol:bEditEnd, uValue, Self, .T. )
         EndIf

         IF ::nColSpecHd != 0
            ::aColumns[ nCol ]:cSpcHeading := uValue
            oCol:oEdit:End()
            oCol:oEdit := Nil
            ::lEditing  := ::lPostEdit := ::lNoPaint := .F.
            ::nColSpecHd := 0
            Return Nil
         EndIf

         ::lAppendMode := oCol:oEdit:lAppend
         oCol:oEdit:Move( 1500,0 )
         oCol:oEdit:End()
         ::PostEdit( uValue, nCol, bValid )
         oCol:oEdit := Nil
         ::oWnd:bValid := ::oGet

         cMsg := If( ! Empty( oCol:cMsg ), oCol:cMsg, ::cMsg )
         If Valtype( cMsg ) == "B"
            cMsg := Eval( cMsg, Self, ::nCell )
         EndIf
         ::SetMsg( cMsg )
         Return Nil

      EndIf

      uValue := oCol:oEdit:VarGet()
      If ::nColSpecHd != 0
         uValue := IF(nKey != VK_ESCAPE, uValue, "")
         ::aColumns[ nCol ]:cSpcHeading := uValue
         ::lChanged := ValType( uValue ) != ValType( uVar ) .or. uValue != uVar
         oCol:oEdit:End()
         oCol:oEdit := Nil
         ::lEditing := ::lPostEdit := ::lNoPaint := .F.
         ::nColSpecHd := 0
         ::lHasChgSpec := ::lChanged
         ::AutoSpec( nCol )
         Return Nil
      Else
         If oCol:bCustomEdit != Nil
            uValue := Eval( oCol:bCustomEdit, uValue, oCol:oEdit, Self )
         EndIf

         If ::lAppendMode .and. Empty( oCol:oEdit:VarGet() ) .and. nKey != VK_RETURN
            bValid := {||.F.}
            IF ::nLenPos > ::nRowCount()   //JP 1.50
               ::nLenPos--
            Endif
            ::nRowPos := ::nLenPos       //JP 1.31
         EndIf

         If oCol:bEditEnd != Nil
            Eval( oCol:bEditEnd, uValue, Self, .T. )
         EndIf

         ::lChanged := ValType( uValue ) != ValType( uVar ) .or. uValue != uVar
         ::lHasChanged := If( ::lChanged, .T., ::lHasChanged )
         ::oWnd:nLastKey := nKey

         oCol:oEdit:End()
         ::PostEdit( uValue, nCol, bValid )
         oCol:oEdit := Nil
         ::oWnd:bValid := ::oGet

         cMsg := If( ! Empty( oCol:cMsg ), oCol:cMsg, ::cMsg )
         If Valtype( cMsg ) == "B"
            cMsg := Eval( cMsg, Self, ::nCell )
         EndIf
         ::SetMsg( cMsg )
      EndIf

   Else

      If ::lPostEdit
         Return Nil
      EndIf

      If oCol:bEditEnd != Nil .and. ValType( oCol:oEdit ) == "O"
         Eval( oCol:bEditEnd, uValue, Self, .F. )
      EndIf

      If lCombo
         ::lAppendMode := oCol:oEdit:lAppend
      EndIf

      If ValType( oCol:oEdit ) == "O"
         oCol:oEdit:End()
         oCol:oEdit := Nil
      EndIf

      ::oWnd:nLastKey := VK_ESCAPE
      ::lChanged := .F.
      ::lEditing := .F.

      If ::lAppendMode
         If ::lIsArr .and. ::nAt > Len( ::aArray )    //JP 74
            ::nAt--
            ::Refresh( .T. )
            ::HiliteCell( ::nCell )
         EndIf

         ::lAppendMode := .F.
         ::lHitBottom  := .F.
         ::lNoPaint    := .F.

         If ::nLen <= ::nRowCount()
            ::Refresh( .T. )
         ElseIf ! ::lCanAppend
            ::GoBottom()
         EndIf

      EndIf
      cMsg := If( ! Empty( oCol:cMsg ), oCol:cMsg, ::cMsg )
      cMsg := If( Valtype( cMsg ) == "B", Eval( cMsg, Self, ::nCell ), cMsg )
      ::SetMsg( cMsg )

   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:AutoSpec() Version 1.83 Adaption HMG  01/01/2010
* ============================================================================

METHOD AutoSpec( nCol )

   Local cExp, uExp, nPos, acSpecHdr := {}
   Local bError := ErrorBlock( { | x | Break( x ) } )

   IF ::lAutoSearch
      If ::bUserSearch != Nil
         AEval( ::aColumns, {|x| AAdd(acSpecHdr, x:cSpcHeading)} )
         Eval( ::bUserSearch, nCol, acSpecHdr, Self )
      Else
         cExp := BuildAutoSeek( Self )
         IF ! Empty(cExp)
            if ::cAlias != "ADO_"
               Begin Sequence
                  uExp := &( cExp )
               Recover
                  ErrorBlock( bError )
               End Sequence
            endif
            IF ::lIsArr
               IF ( nPos := Eval(uExp, Self) ) != 0
                  ::nAt := nPos
                  If ::bChange != Nil
                     Eval( ::bChange, Self, 0 )
                  EndIf
                  ::Refresh(.t.)
               ELSE
                  Tone( 500, 1 )
               ENDIF
             ENDIF
             IF ::lIsDbf .or. (!::lIsArr .and. ::cAlias == "ADO_" )
               IF ::lHasChgSpec
                  Eval( ::bGoTop )
               ENDIF
               IF ::ExpLocate( cExp, nCol )
                  ::Refresh(.t.)
               ELSE
                  Tone( 500, 1 )
               ENDIF
            ENDIF
         ENDIF
      EndIf
   ELSEIF ::lAutoFilter
      If ::bUserFilter != Nil
         AEval( ::aColumns, {|x| AAdd( acSpecHdr, x:cSpcHeading )} )
         cExp := Eval( ::bUserFilter, nCol, acSpecHdr, Self )
      Else
         cExp := BuildAutoFilter( Self )
      EndIf
      if ! Empty(cExp)
         if ::cAlias != "ADO_"
            Begin Sequence
               uExp := &( "{||(" + Trim( cExp ) + ")}" )
            Recover
               ErrorBlock( bError )
               Return Nil
            End SEQUENCE
         endif
         IF ::lIsDbf
            ::bFilter := uExp
            DbSetFilter( uExp, cExp )
            ( ::cAlias )->( DbGoTop() )
            ::GoTop()
            ::lHitBottom := .F.
            ::nRowPos    := ::nAt := ::nLastnAt := 1
            ::lHitTop    := .T.
            ::Refresh(.t.)
         ELSE
            if ::cAlias == "ADO_"
               ::nRowPos := RSetFilter( Self, cExp  )
               ::GoTop()
               ::ResetVScroll()
               ::Refresh(.t.)
            endif
         ENDIF
      else
         IF ::lIsDbf
            DbClearFilter()
            ::bFilter := Nil
            ::GoTop()
            ::UpStable()
            ::Refresh(.t.)
         ELSE
            if ::cAlias == "ADO_"
               ::nRowPos := RSetFilter( Self, ""  )
               ::GoTop()
               ::ResetVScroll()
               ::Refresh(.t.)
            endif
         ENDIF
      endif
   ENDIF
   ::lHasChgSpec := .f.

Return Nil

* ============================================================================
* METHOD TSBrowse:Excel2() Version 7.0 Jul/15/2004
* ============================================================================

METHOD Excel2( cFile, lActivate, hProgress, cTitle, lSave, bPrintRow ) CLASS TSBrowse

   Local i, nRow, uData, nAlign, nEvery, nPic, nFont, cWork, aFontTmp, nHandle, nTotal, nSkip, nCol, ;
         hFont  := iif( ::hFont != Nil, ::hFont, 0 ), ;
         nLine  := 1, ;
         nCount := 0, ;
         aLen   := {}, ;
         aPic   := {}, cPic, anPic := {}, cType, cc, cPic1, ;
         aFont  := {}, ;
         nRecNo := iif( ::lIsDbf, ( ::cAlias )->( RecNo() ), 0), ;
         nAt    := ::nAt,;
         nOldRow := ::nLogicPos(), ;
         nOldCol := ::nCell

   Default nInstance := 0

   Default cFile     := "Book1.xls", ;
           lActivate := .T., ;
           cTitle    := "", ;
           lSave     := .F.

   CursorWait()

   ::lNoPaint := .F.
   nInstance ++
   cWork := GetStartupFolder() + "\Book" + LTrim( Str( nInstance ) ) + ".xls"
   ::SetFocus()
   cFile  := ::Proper( StrTran( AllTrim( Upper( cFile ) ), ".XLS" ) + ".XLS" )
   cTitle := AllTrim( cTitle )

   For nCol := 1 To Len( ::aColSizes )

      AAdd( aLen, Max( 1, Round( ::aColSizes[ nCol ] / ;
                                  GetTextWidth( 0, "B", hFont ), 0 ) ) )

      cPic := ''
      cType := If( Empty( ::aColumns[ nCol ]:cDataType ), ValType(Eval(::aColumns[ nCol ]:bData)), ::aColumns[ nCol ]:cDataType )
      if cType == 'N' .and.  !Empty( ::aColumns[ nCol ]:cPicture )
         for i := 1 to LEN( ::aColumns[ nCol ]:cPicture )
           cc := substr( ::aColumns[ nCol ]:cPicture, i, 1 )
           if cc=='9';   cc := '0';   endif
           if cc=='.';   cc := ',';   endif
           if cc=='@' .or. cc=='K' .or. cc=='Z';   loop;   endif
           if !Empty(cPic);   cPic += cc
           elseif cc # '0';   cPic += ( '#0' + cc )
           endif
         next
         if Empty(cPic)
            cPic := '#0'
         endif
         if "@Z " $ ::aColumns[ nCol ]:cPicture .or. LEN(cPic) > 3
            if "," $ cPic
               cPic1 := SubStr( cPic, 2, At( ",", cPic ) - 2 )
               cPic := StrTran( cPic1, '0', '#' ) + SubStr( cPic, At( ",", cPic ) - 1, LEN(cPic) - 2 )
            else
               cPic1 := SubStr( cPic, 2, LEN(cPic) - 2 )
               cPic := StrTran( cPic1, '0', '#' ) + '0'
            endif
         endif
      endif
      nPic := iif( !Empty(cPic), AScan( aPic, {|x| x==cPic} ), 0 )
      if nPic == 0
         AAdd( aPic, cPic );  nPic := LEN(aPic)
      EndIf
      AADD( anPIC, nPic )
   Next

   If ( nHandle := FCreate( cWork, 0 ) ) < 0
      MsgStop( "Can't create XLS file", cWork )
      Return Nil
   EndIf

   FWrite( nHandle, BiffRec( 9 ) )
   // set CodePage
   FWrite( nHandle, BiffRec( 66, GetACP() ) )
   FWrite( nHandle, BiffRec( 12 ) )
   FWrite( nHandle, BiffRec( 13 ) )

   If ::hFont != Nil
      AAdd( aFont,  GetFontParam( ::hFont ) )
   Else
      if ( hFont := GetFontHandle( ::cFont ) ) != 0
         AAdd(aFont, GetFontParam( hFont ) )
      endif
   EndIf

   For nCol := 1 To Len( ::aColumns )

      If Empty( ::aColumns[ nCol ]:hFont ) .and. Empty( ::aColumns[ nCol ]:hFontHead )
         Loop
      EndIf

      hFont := ::aColumns[ nCol ]:hFont

      If hFont != Nil
         aFontTmp := GetFontParam( hFont )
         IF AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
                            e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
                            e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } ) == 0

            AAdd( aFont, aFontTmp )
         endif

      EndIf

      hFont := ::aColumns[ nCol ]:hFontHead

      If hFont != Nil
         aFontTmp := GetFontParam( hFont )
         IF AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
                            e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
                            e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } ) == 0

            AAdd( aFont, aFontTmp )
         endif

      EndIf

   Next

   If Len( aFont ) > 4
      ASize( aFont, 4 )
   EndIf

   If ! Empty( aFont )
      For nCol := 1 To Len( aFont )
         FWrite( nHandle, BiffRec( 49, aFont[ nCol ] ) )
      Next
   EndIf

   FWrite( nHandle, BiffRec( 31, 1 ) )
   FWrite( nHandle, BiffRec( 30, "General" ) )

   If ! Empty( aPic )
      AEval( aPic, {|e| FWrite( nHandle, BiffRec( 30, e ) ) } )
   EndIf

   AEval( aLen, { |e,n| FWrite( nHandle, BiffRec( 36, e, n - 1, n - 1 ) ) } )
   If hProgress != Nil
      nTotal := ( ::nLen + 1 ) * Len( ::aColumns )
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS,0,0)
      nEvery := Max( 1, Int( nTotal * .02 ) ) // refresh hProgress every 2 %
   EndIf

   IF ::lIsDbf
      ( ::cAlias )->( Eval( ::bGoTop ) )
   EndIf

   For nRow := 1 To ( ::nLen )

      If nRow == 1

         If ! Empty( cTitle )
            cTitle := StrTran( cTitle, CRLF, Chr( 10 ) )
            nAlign := If( Chr( 10 ) $ cTitle, 5, 1 )
            FWrite( nHandle, BiffRec( 4, cTitle, 0, 0,, nAlign ) )
            nLine := 3
         EndIf

         For nCol := 1 To Len( ::aColumns )

            uData := If( ValType( ::aColumns[ nCol ]:cHeading ) == "B", ;
                         Eval( ::aColumns[ nCol ]:cHeading ), ;
                         ::aColumns[ nCol ]:cHeading )

            If ValType( uData ) != "C"
               Loop
            EndIf

            uData  := Trim( StrTran( uData, CRLF, Chr( 10 ) ) )
            nAlign := Min( LoWord( ::aColumns[ nCol ]:nHAlign ), 2 )
            nAlign := If( Chr( 10 ) $ uData, 4, nAlign )
            hFont  := ::aColumns[ nCol ]:hFontHead
            aFontTmp := GetFontParam( hFont )
            nFont  := AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
                            e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
                            e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } )

            FWrite( nHandle, BiffRec( 4, uData, nLine - 1, nCol - 1, .T., nAlign + 1,, ;
                                      Max( 0, nFont - 1 ) ) )

            If hProgress != Nil

               If nCount % nEvery == 0
                  SendMessage(hProgress, PBM_SETPOS, nCount, 0)
               EndIf

               nCount ++

            EndIf

         Next

         ++nLine

      EndIf

      If bPrintRow != Nil .and. ! Eval( bPrintRow, nRow )
         ::Skip( 1 )
         Loop
      EndIf

      For nCol := 1 To Len( ::aColumns )

         If ::aColumns[ nCol ]:lBitMap
            Loop
         EndIf

         uData  := Eval( ::aColumns[ nCol ]:bData )
         nAlign := LoWord( ::aColumns[ nCol ]:nAlign )
         hFont  := ::aColumns[ nCol ]:hFont
         aFontTmp := GetFontParam( hFont )
         nFont  := AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
                            e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
                            e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } )

         nPic := If( ! Empty( ::aColumns[ nCol ]:cPicture ), anPIC[ nCol ], Nil )

         If ValType( uData ) == "N"
            FWrite( nHandle, BiffRec( 3, uData, nLine - 1, nCol - 1,, nAlign + 1, nPic, ;
                                      Max( 0, nFont - 1 ) ) )
         Else
            uData := Trim( StrTran( cValToChar( uData ), CRLF, Chr( 10 ) ) )
            nAlign := If( Chr( 10 ) $ uData, 4, nAlign )
            FWrite( nHandle, BiffRec( 4, uData, nLine - 1, nCol - 1,, nAlign + 1, nPic, ;
                                      Max( 0, nFont - 1 ) ) )
         EndIf

         If hProgress != Nil

            If nCount % nEvery == 0
               SendMessage(hProgress, PBM_SETPOS, nCount, 0)
            EndIf

            nCount ++

         EndIf

      Next

      nSkip := ::Skip( 1 )

      ++nLine
      SysRefresh()
      IF nSkip ==0
         EXIT
      ENDIF
   Next

   FWrite( nHandle, BiffRec( 10 ) )
   FClose( nHandle )

   If hProgress != Nil
      SendMessage(hProgress, PBM_SETPOS, nTotal, 0)
   EndIf

   If lSave
      FileRename( Self, cWork, cFile )
   EndIf

   CursorArrow()

   If ::lIsDbf
      ( ::cAlias )->( DbGoTo( nRecNo ) )
      ::GoPos(nOldRow, nOldCol)
   EndIf

   ::nAt := nAt

   If lActivate
      ShellExecute( 0, "Open", If( lSave, cFile, cWork ),,, 3 )
   EndIf

   ::Display()

Return Nil

* ============================================================================
* METHOD TSBrowse:ExcelOle() Version 9.0 Nov/30/2009
* Requires TOleAuto class
* Many thanks to Victor Manuel Tomás for the core of this method
* ============================================================================

METHOD ExcelOle( cXlsFile, lActivate, hProgress, cTitle, hFont, lSave, bExtern, aColSel, bPrintRow ) CLASS TSBrowse

   Local oExcel, oBook, oSheet, nRow, nCol, uData, nEvery, oRange, cRange, cCell, cLet, nColHead, nVar, ;
         bError, cText, nStart, nTotal, aFont, aRepl, ;
         nLine  := 1, ;
         nCount := 0, ;
         nRecNo := ( ::cAlias )->( RecNo() ), ;
         nAt    := ::nAt,;
         aCol := { 26, 52, 78, 104, 130, 156 }, ;
         aLet := { "", "A", "B", "C", "D", "E" }, ;
         nOldRow := ::nLogicPos(), ;
         nOldCol := ::nCell

   Default lActivate := Empty( cXlsFile ), ;
           cTitle    := ""

   Default lSave    := ! lActivate .and. ! Empty( cXlsFile ), ;
           cXlsFile := ""

   CursorWait()

   If ::lSelector
      ::aClipBoard := { ColClone( ::aColumns[ 1 ], Self ), 1, "" }
      ::DelColumn( 1 )
   EndIf

   cLet := aLet[ AScan( aCol, {|e| Len( If( aColSel != Nil, aColSel, ::aColumns ) ) <= e } ) ]

   If ! Empty( cLet )
      nCol := AScan( aLet, cLet ) - 1
      cLet += Chr( 64 + Len( If( aColSel != Nil, aColSel, ::aColumns ) ) - aCol[ Max( 1, nCol ) ] )
   Else
      cLet := Chr( 64 + Len( If( aColSel != Nil, aColSel, ::aColumns ) ) )
   EndIf

   aRepl      := {}

   ::lNoPaint := .F.

   If hProgress != Nil
      nTotal := ( ::nLen + 1 ) * Len( ::aColumns ) + 30
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * .02 ) ) // refresh hProgress every 2 %
   EndIf

   If ! Empty( cXlsFile )
      cXlsFile := AllTrim( StrTran( Upper( cXlsFile ), ".XLS" ) )
   EndIf

   cTitle   := AllTrim( cTitle )
   bError   := ErrorBlock( { | x | Break( x ) } )

   Begin Sequence
      oExcel := TOleAuto():New("Excel.Application")
   Recover
      ErrorBlock( bError )
      CursorArrow()
      MsgStop( "No Ole.lib searched", "Error" )
      Return Nil
   End Sequence

   ErrorBlock( bError )

   If hProgress != Nil
      nCount -= 15
      SendMessage(hProgress, PBM_SETPOS, nCount, 0)
   EndIf

   oExcel:WorkBooks:Add()
   oBook  := oExcel:Get( "ActiveWorkBook")
   oSheet := oExcel:Get( "ActiveSheet" )

   If hProgress != Nil
      nCount -= 15
      SendMessage(hProgress, PBM_SETPOS, nCount, 0)
   EndIf

   ( ::cAlias )->( Eval( ::bGoTop ) )

   cText := ""

   For nRow := 1 To ::nLen

      If nRow == 1

         If ! Empty( cTitle )
            oSheet:Cells( nLine++, 1 ):Value := AllTrim( cTitle )
            oSheet:Range( "A1:" + cLet + "1" ):Set( "HorizontalAlignment", xlHAlignCenterAcrossSelection )
            ++nLine
            nStart := nLine
         Else
            nStart := nLine
         EndIf

         If ! Empty( ::aSuperHead )

            For nCol := 1 To Len( ::aSuperHead )
               nVar := If( ::lSelector, 1, 0 )
               uData := If( ValType( ::aSuperhead[ nCol, 3 ] ) == "B", Eval( ::aSuperhead[ nCol, 3 ] ), ;
                                     ::aSuperhead[ nCol, 3 ] )
               oSheet:Cells( nLine, ::aSuperHead[ nCol, 1 ] - nVar ):Value := uData
               cRange :=  Chr( 64 + ::aSuperHead[ nCol, 1 ] - nVar ) + LTrim( Str( nLine ) ) + ":" + ;
                          Chr( 64 + ::aSuperHead[ nCol, 2 ] - nVar ) + LTrim( Str( nLine ) )
               oSheet:Range( cRange ):Borders():LineStyle := xlContinuous
               oSheet:Range( cRange ):Set( "HorizontalAlignment", xlHAlignCenterAcrossSelection )
            Next

            nStart := nLine ++
         EndIf

         nColHead := 0

         For nCol := 1 To Len( ::aColumns )

            If aColSel != Nil .and. AScan( aColSel, nCol ) == 0
               Loop
            EndIf

            uData := If( ValType( ::aColumns[ nCol ]:cHeading ) == "B", Eval( ::aColumns[ nCol ]:cHeading ), ;
                                  ::aColumns[ nCol ]:cHeading )

            If ValType( uData ) != "C"
               Loop
            EndIf

            uData := StrTran( uData, CRLF, Chr( 10 ) )
            nColHead ++
            oSheet:Cells( nLine, nColHead ):Value := uData

            If hProgress != Nil

               If nCount % nEvery == 0
                  SendMessage(hProgress, PBM_SETPOS,nCount,0)
               EndIf

               nCount ++
            EndIf
         Next

         nStart := ++ nLine

      EndIf

      If bPrintRow != Nil .and. ! Eval( bPrintRow, nRow )
         ::Skip( 1 )
         Loop
      EndIf

      For nCol := 1 To Len( ::aColumns )
         If aColSel != Nil .and. AScan( aColSel, nCol ) == 0
            Loop
         EndIf

         uData := Eval( ::aColumns[ nCol ]:bData )

         If ValType( uData ) == "C" .and. At( CRLF, uData ) > 0
            uData := StrTran( uData, CRLF, "&&" )

            If AScan( aRepl, nCol ) == 0
               AAdd( aRepl, nCol )
            EndIf
         EndIf

         If ::aColumns[ nCol ]:cPicture != Nil
            uData := Transform( uData, ::aColumns[ nCol ]:cPicture )
         EndIf

         uData  :=  If( ValType( uData )=="D", DtoC( uData ), If( ValType( uData )=="N", Str( uData ) , ;
                    If( ValType( uData )=="L", If( uData ,".T." ,".F." ), cValToChar( uData ) ) ) )

         cText += Trim( uData ) + Chr( 9 )

         If hProgress != Nil

            If nCount % nEvery == 0
               SendMessage(hProgress, PBM_SETPOS, nCount, 0)
            EndIf

            nCount ++
         EndIf
      Next

      ::Skip( 1 )
       cText += Chr( 13 )

      ++nLine

      /*
         Cada 20k volcamos el texto a la hoja de Excel , usando el portapapeles , algo muy rapido y facil ;-)
         Every 20k set text into excel sheet , using Clipboard , very easy and faster.
      */

      IF Len( cText ) > 20000
         CopyToClipboard( cText )
         cCell := "A" + Alltrim( Str( nStart ) )
         oRange := oSheet:Range( cCell )
         oRange:Select()
         oSheet:Paste()
         cText := ""
         nStart := nLine + 1

      EndIf

   Next

   If AScan( ::aColumns, { |o| o:cFooting != Nil  } ) > 0

      For nCol := 1 To Len( ::aColumns )

         If ( aColSel != Nil .and. AScan( aColSel, nCol ) == 0 ) .or. ::aColumns[ nCol ]:cFooting == Nil
            Loop
         EndIf

         uData := If( ValType( ::aColumns[ nCol ]:cFooting ) == "B", Eval( ::aColumns[ nCol ]:cFooting ), ;
                      ::aColumns[ nCol ]:cFooting )
         uData := cValTochar( uData )
         uData := StrTran( uData, CRLF, Chr( 10 ) )
         oSheet:Cells( nLine, nCol ):Value := uData
      Next
   EndIf

   If ::lIsDbf
      ( ::cAlias )->( DbGoTo( nRecNo ) )
      ::GoPos(nOldRow, nOldCol)

   EndIf

   ::nAt := nAt

   If Len( cText ) > 0
      CopyToClipboard( cText )
      cCell := "A" + Alltrim( Str( nStart ) )
      oRange := oSheet:Range( cCell )
      oRange:Select()
      oSheet:Paste()
      cText := ""
   EndIf

   nLine := If( ! Empty( cTitle ), 3, 1 )
   nLIne += If( ! Empty( ::aSuperHead ), 1, 0 )
   cRange := "A" + LTrim( Str( nLine ) ) + ":" + cLet + Alltrim( Str( oSheet:UsedRange:Rows:Count() ) )
   oRange := oSheet:Range( cRange )

   If hFont != NIL  // let the programmer to decide the font he wants, otherwise use Excel's default
         aFont := GetFontParam( hFont )
         oRange:Font:Name := aFont[ 1 ]
         oRange:Font:Size := aFont[ 2 ]
         oRange:Font:Bold := aFont[ 3 ]
   EndIf

   If ! Empty( aRepl )
      For nCol := 1 To Len( aRepl )
         oSheet:Columns( Chr( 64 + aRepl[ nCol ] ) ):Replace( "&&", Chr( 10 ) )
      Next
   EndIf

   If bExtern != Nil
      Eval( bExtern, oSheet, Self )
   EndIf

   oRange:Borders():LineStyle := xlContinuous
   oRange:Columns:AutoFit()

   If ! Empty( aRepl )
      For nCol := 1 To Len( aRepl )
         oSheet:Columns( Chr( 64 + aRepl[ nCol ] ) ):WrapText := .T.
      Next
   EndIf

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, nCount, 0 )
   EndIf

   If ::lSelector
      ::InsColumn( ::aClipBoard[ 2 ], ::aClipBoard[ 1 ] )
      ::lNoPaint := .F.
   EndIf

   If ! Empty( cXlsFile ) .and. lSave
      oBook:SaveAs( cXlsFile, xlWorkbookNormal )

      If ! lActivate
         CursorArrow()
         oExcel:Quit()
         ::Reset()
         Return Nil
      EndIf
   EndIf

   CursorArrow()

    If lActivate
      oSheet:Range( "A1" ):Select()
      oExcel:Visible := .T.
   EndIf

   ::Reset()

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:ExpLocate() Version 9.0 Nov/30/2009
* ============================================================================

METHOD ExpLocate( cExp, nCol ) CLASS TSBrowse

   Local uExp, bExp, ;
         nLines := ::nRowCount(), ;
         nRecNo := ( ::cAlias )->( RecNo() ), ;
         bError := ErrorBlock( { | x | Break( x ) } )

   ::lValidating := .T.

   if ::cAlias != "ADO_"
      Begin Sequence
         uExp := &( cExp )
      Recover
         ErrorBlock( bError )
         Tone( 500, 1 )
         Return .F.
      End Sequence

      ErrorBlock( bError )

      bExp := &( "{||(" + Trim( cExp ) + ")}" )

      If Eval( bExp )
         ::Skip( 1 )
      EndIf
   Endif

   if ::cAlias == "ADO_"
      RSetLocate( Self, cExp, ::aColumns[nCol]:lDescend )
   Else
      ( ::cAlias )->( __dbLocate( bExp,cExp,,, .T. ) )

      If ( ::cAlias )->( EoF() )
         ( ::cAlias)->( DbGoTo( nRecNo ) )
         Tone( 500, 1 )
         Return .F.
      EndIf
   Endif

   If nRecNo != ( ::cAlias )->( RecNo() ) .and. ::nLen > nLines

         nRecNo := ( ::cAlias )->( RecNo() )
         ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

         If ( ::cAlias )->( EoF() )

            Eval( ::bGoBottom )
            ::nRowPos := nLines
            ::nAt := ::nLogicPos()

            While ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
               ::Skip( -1 )
               ::nRowPos --
            EndDo
         Else
            ( ::cAlias )->( DbGoTo( nRecNo ) )
            ::nAt := ::nLogicPos()
         EndIf

         ::Refresh( .F. )
         ::ResetVScroll()
      ElseIf nRecNo != ( ::cAlias )->( RecNo() )
         nRecNo := ( ::cAlias )->( RecNo() )
         Eval( ::bGoTop )
         ::nAt := ::nRowPos := 1

         While nRecNo != ( ::cAlias )->( RecNo() )
            ::Skip( 1 )
            ::nRowPos++
         EndDo
         ::Refresh( .F. )
         ::ResetVScroll()
   EndIf

   If ::bChange != Nil
      Eval( ::bChange, Self, 0 )
   EndIf

   If ::lIsArr .and. ::bSetGet != Nil
      If ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ElseIf ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      Else
         Eval( ::bSetGet, "" )
      EndIf
   EndIf

   ::lHitTop := ::lHitBottom := .F.

Return .T.

* ============================================================================
* METHOD TSBrowse:GoToRec() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoToRec( nRec ) CLASS TSBrowse

   Local nRecNo, nLines

   If ::lIsDbf

      ::Reset()
      nRecNo := ( ::cAlias )->( RecNo() )
      nLines := ::nRowCount()

      ::lValidating := .T.

      ( ::cAlias )->( DbGoto( nRec ) )
  
      If ::nLen > nLines

           nRecNo := ( ::cAlias )->( RecNo() )
          ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

          If ( ::cAlias )->( EoF() )

             Eval( ::bGoBottom )
             ::nRowPos := nLines
             ::nAt := ::nLogicPos()
  
             While ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
                ::Skip( -1 )
                ::nRowPos --
             EndDo
          Else
             ( ::cAlias )->( DbGoTo( nRecNo ) )
             ::nLastPos := nRecNo
             ::nAt := ::nLogicPos()
          EndIf

          ::Refresh( .F. )
          ::ResetVScroll()

      ElseIf nRecNo != ( ::cAlias )->( RecNo() )

          nRecNo := ( ::cAlias )->( RecNo() )
          Eval( ::bGoTop )
          ::nAt := ::nRowPos := 1

          While nRecNo != ( ::cAlias )->( RecNo() )
             ::Skip( 1 )
             ::nRowPos ++
          EndDo

          ::Refresh( .F. )
          ::ResetVScroll()

      EndIf

      If ::bChange != Nil
         Eval( ::bChange, Self, 0 )
      EndIf

      ::lHitTop := ::lHitBottom := .F.

   EndIf

Return ::lValidating

* ============================================================================
* METHOD TSBrowse:ExpSeek() Version 9.0 Nov/30/2009
* ============================================================================

METHOD ExpSeek( cExp, lSoft ) CLASS TSBrowse

   Local nQuote, uExp, cType, ;
         nRecNo := ( ::cAlias )->( RecNo() ), ;
         nLines := ::nRowCount(), ;
         bError := ErrorBlock( { | x | Break( x ) } )

   If !( Alias() == ::cAlias )
      MsgInfo( "TsBrowse ExpSeek "+ ::aMsg[ 25 ] + "'" + Alias() + "' != '" + ::cAlias + "'", ::aMsg[ 28 ] )
   EndIf

   Begin Sequence
      cType := ValType( Eval( &("{||" + ( ::cAlias ) + "->(" + ( ::cAlias )->( IndexKey() ) + ")}") ) )
   Recover
      ErrorBlock( bError )
      Tone( 500, 1 )
      Return .F.
   End Sequence

   ::lValidating := .T.

   nQuote := At( '"', cExp )
   nQuote := If( nQuote == 0, At( "'", cExp ), nQuote )

   cExp := If( cType == "C" .and. nQuote == 0, '"' + Trim( cExp ) + '"', ;
           If( cType == "D" .and. At( "CTOD", Upper( cExp ) ) == 0, 'CtoD( "' + AllTrim( cExp ) + '")', ;
           If( cType == "N", AllTrim( cExp ), If( cType == "L", If( AllTrim( cExp ) == "T", ".T.", ".F." ), ;
               AllTrim( cExp ) ) ) ) )

   Begin Sequence
      uExp := &( cExp )
   Recover
      ErrorBlock( bError )
      Tone( 500, 1 )
      Return .F.
   End Sequence

   ErrorBlock( bError )

   ( ::cAlias )->( DbSeek( uExp, lSoft ) )

   If ( ::cAlias )->( EoF() )
      ( ::cAlias )->( DbGoTo( nRecNo ) )
      Tone( 500, 1 )
      Return .F.
   EndIf

   If nRecNo != ( ::cAlias )->( RecNo() ) .and. ::nLen > nLines

         nRecNo := ( ::cAlias )->( RecNo() )
         ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

         If ( ::cAlias )->( EoF() )

            Eval( ::bGoBottom )
            ::nRowPos := nLines
            ::nAt := ::nLogicPos()

            While ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
               ::Skip( -1 )
               ::nRowPos --
            EndDo
         Else
            ( ::cAlias )->( DbGoTo( nRecNo ) )
            ::nAt := ::nLogicPos()
         EndIf

         ::Refresh( .F. )
         ::ResetVScroll()

      ElseIf nRecNo != ( ::cAlias )->( RecNo() )

         nRecNo := ( ::cAlias )->( RecNo() )
         Eval( ::bGoTop )
         ::nAt := ::nRowPos := 1

         While nRecNo != ( ::cAlias )->( RecNo() )
            ::Skip( 1 )
            ::nRowPos ++
         EndDo

         ::Refresh( .F. )
         ::ResetVScroll()

   EndIf

   If ::bChange != Nil
      Eval( ::bChange, Self, 0 )
   EndIf

   If ::lIsArr .and. ::bSetGet != Nil
      If ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ElseIf ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      Else
         Eval( ::bSetGet, "" )
      EndIf
   EndIf

   ::lHitTop := ::lHitBottom := .F.

Return .T.

* ============================================================================
* METHOD TSBrowse:FreezeCol() Version 9.0 Nov/30/2009
* ============================================================================

METHOD FreezeCol( lNext ) CLASS TSBrowse

   Local nFreeze := ::nFreeze

   Default lNext := .T.

   If lNext                                      // freeze next available column
      ::nFreeze := Min( nFreeze + 1, Len( ::aColumns ) )
   Else                                          // unfreeze previous column
      ::nFreeze := Max( nFreeze - 1, 0 )
   EndIf

   If ::nFreeze != nFreeze                        // only update if necessary
      If( ! lNext, ::PanHome(), Nil )
      ::HiliteCell( ::nFreeze + 1 )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:GetAllColsWidth() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GetAllColsWidth() CLASS TSBrowse

   Local nWidth := 0, ;
         nPos := 1, ;
         nLen := Len( ::aColumns )

   For nPos := 1 To nLen
      nWidth += ::aColumns[ nPos ]:nWidth
   Next

Return nWidth

* ============================================================================
* METHOD TSBrowse:GetColumn() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GetColumn( nCol ) CLASS TSBrowse

   Default nCol := 1

   If hb_IsString( nCol )  // 14.07.2015
      nCol := ::nColumn( nCol )
   Else
      If nCol < 1
         nCol := 1
      ElseIf nCol > Len( ::aColumns )
         nCol := Len( ::aColumns )
      EndIf
   EndIf

Return ::aColumns[ nCol ]                       // returns a Column object

* ============================================================================
* METHOD TSBrowse:GetDlgCode() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GetDlgCode( nLastKey ) CLASS TSBrowse

   If nLastKey == VK_ESCAPE .and. ::bOnEscape != Nil
      Eval( ::bOnEscape, Self )
   EndIf

   If ! ::oWnd:lValidating
      If nLastKey == VK_UP .or. nLastKey == VK_DOWN .or. nLastKey == VK_RETURN .or. nLastKey == VK_TAB .or. ;
         nLastKey == VK_ESCAPE
         ::oWnd:nLastKey := nLastKey
      Else
         ::oWnd:nLastKey := 0
      EndIf
   EndIf

Return If( IsWindowEnabled( ::hWnd ) .and. nLastKey != VK_ESCAPE, DLGC_WANTALLKEYS, 0 )

* ============================================================================
* METHOD TSBrowse:GetRealPos() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GetRealPos( nRelPos ) CLASS TSBrowse

   Local nLen

   If ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   EndIf

   nLen := ::nLen

   nRelPos := If( nLen > MAX_POS, Int( ( nRelPos / MAX_POS ) * nLen ), nRelPos )

Return nRelPos

* ============================================================================
* METHOD TSBrowse:GoBottom() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoBottom() CLASS TSBrowse

   Local nLines := ::nRowCount()

   If ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   EndIf
   IF ::nLenPos ==0
      ::nLenPos := Min( nLines, ::nLen )
   endif
   If ::nLen < 1
      Return Self
   EndIf

   ::lAppendMode := .F.
   ::ResetSeek()

   If ! ::lHitBottom

      Eval( ::bGoBottom )

      If ::bFilter != Nil
         While ! Eval( ::bFilter ) .and. ! BoF()
           ( ::cAlias )->( DbSkip( -1 ) )
         EndDo
      EndIf

      ::lHitBottom := .T.
      ::lHitTop    := .F.
      ::nRowPos    := Min( nLines, ::nLen )
      ::nRowPos    := Min( nLines, ::nLenPos ) //JP 1.31
      ::nAt        := ::nLastnAt := ::nLogicPos()
      ::nLenPos := ::nRowPos

      If ::lIsDbf
         ::nLastPos := ( ::cAlias )->( RecNo() )
      EndIf

      If ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      EndIf

      If ::oVScroll != Nil
         ::oVScroll:SetPos( ::oVScroll:nMax )
      EndIf

      ::Refresh( ::nLen < nLines )

      If ::lIsArr .and. ::bSetGet != Nil
         If ValType( Eval( ::bSetGet ) ) == "N"
            Eval( ::bSetGet, ::nAt )
         ElseIf ::nLen > 0
            Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
         Else
            Eval( ::bSetGet, "" )
         EndIf
      EndIf

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:GoDown() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoDown() CLASS TSBrowse

   Local nFirst, ;
         nLines    := ::nRowCount(), ;
         lRePaint  := .F., ;
         lEditable := .F., ;
         lTranspar := ::lTransparent .and. ( ::hBrush != Nil .or. ::oWnd:hBrush != Nil )

   If ::nLen < 1       // for empty dbfs or arrays
      If ::lCanAppend
         ::nRowPos := 1
      Else
         Return Self
      EndIf
   EndIf

   ::ResetSeek()

   If ::nLen <= nLines .and. ::lNoLiteBar
      Return Self
   EndIf

   If ::lNoLiteBar
      nFirst := nLines - ::nRowPos
      ::Skip( nFirst )
      ::nRowPos := nLines
   EndIf

   ::nRowPos := Max( 1, ::nRowPos )
   AEval( ::aColumns, { |o| If( ::lCanAppend .and. o:lEdit, lEditable := .T., Nil ) } )

   If ! ::lAppendMode
      ::nPrevRec := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )
   EndIf

   If ! ::lHitBottom

      If ! ::lAppendMode .and. ::nRowPos < nLines .and. ! ::lIsTxt  // 14.07.2015
         ::DrawLine()
      EndIf

      If ::Skip( 1 ) == 1 .or. ::lAppendMode
         ::lHitTop := .F.

         If ::nRowPos < nLines
            ::nRowPos++
         Else
            If ::lPageMode
               lRePaint := If( ( ::nLogicPos + nLines - 1 ) > ::nLen, .T., .F. )
               ::nRowPos := 1
               ::Refresh( lRePaint )
            Else
               If lTranspar
                  ::Paint()
               Else
                  ::nRowPos := nLines
                  ::TSBrwScroll( 1 )
                  ::Skip( -1 )
                  ::DrawLine( ::nRowPos - 1 ) // added 10.07.2015
                  ::Skip( 1 )
               EndIf
            EndIf
         EndIf
#ifdef _TSBFILTER7_
      ElseIf ::lFilterMode .and. ::nPrevRec != Nil
         ( ::cAlias )->( DbGoTo( ::nPrevRec ) )
#else
      Else
         Eval( ::bGoBottom )
         ::lHitBottom := .T.
#endif
      EndIf

      If ! ::lAppendMode .and. ! ::lEditing
         ::DrawSelect()
      EndIf

      If ::oVScroll != Nil .and. ! ::lAppendMode
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      EndIf

      If ! ::lHitBottom .and. ! ::lAppendMode .and. ::bChange != nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      EndIf

      ::nAt := ::nLogicPos()

   ElseIf ::lCanAppend .and. lEditable .and. ! ::lAppendMode

      ::lAppendMode := .T.
      nFirst := 0
      Aeval( ::aColumns, { | oCol, nCol | nFirst := If( ::IsEditable( nCol ) .and. nFirst == 0, nCol, nFirst ),HB_SYMBOL_UNUSED( oCol ) } )
      If nFirst == 0
         ::lAppendMode := .F.
         ::lHitTop := ::lHitBottom := .F.
         Return Self
      elseif ::lSelector .and. nFirst == 1
         nFirst++
      EndIf

      If ::nCell != nFirst .and. ! ::IsColVisible( nFirst )

         While ! ::IsColVisible( nFirst )
            ::nColPos += If( nFirst < ::nCell, -1, 1 )
         EndDo
      EndIf

      ::lHitTop := ::lHitBottom := .F.
      ::nCell := nFirst
      ::nLenPos := ::nRowPos   //JP 1.31
      If ::lIsArr
         ::lAppendMode := .F.
         ::DrawLine()
         ::lAppendMode := .T.
      Else
         ::DrawLine()
      EndIf

      ::GoDown()             // recursive call to force entry to itself
      ::nLastKey := ::oWnd:nLastKey := VK_RETURN
      ::DrawLine()

      If ! ::lAutoEdit
         ::PostMsg( WM_KEYDOWN, VK_RETURN, nMakeLong( 0, 0 ) )
      EndIf

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:GoEnd() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoEnd() CLASS TSBrowse

   Local nTxtWid, nI, nLastCol, nBegin, ;
         nWidth   := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ), ;
         nWide    := 0, ;
         nCols    := Len( ::aColumns ), ;
         nPos     := ::nColPos

   If ::lIsTxt
      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != Nil, ::hFont, 0 ) ) )

      If ::nAt < ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
         ::nAt := ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
         ::Refresh( .F. )
         If ::oHScroll != Nil
            ::oHScroll:SetPos( ::nAt )
         EndIf
      EndIf

      Return Self
   EndIf

   nLastCol := Len( ::aColumns )
   nBegin := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ::nColPos - ::nFreeze ), ;
                      ::nColPos - ::nFreeze ), nLastCol )

   nWide := 0

   For nI := nBegin To nPos
       nWide += ::aColSizes[ nI ]
   Next

   nBegin := ::nCell

   For nI := nPos + 1 To nCols
      If nWide + ::aColSizes[ nI ] <= nWidth    // only if column if fully visible
         nWide += ::aColSizes[ nI ]
         ::nCell := nI
      Else
         Exit
      EndIf
   Next

   If nBegin == ::nCell
      Return Self
   EndIf

   If ::lCellBrw

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

   EndIf

   ::Refresh( .F. )

   If ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   EndIf

   ::nOldCell := ::nCell
   ::HiliteCell( ::nCell )

Return Self

* ============================================================================
* METHOD TSBrowse:GoHome() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoHome() CLASS TSBrowse

   ::nOldCell := ::nCell

   If ::lIsTxt

      If ::nAt > 1
         ::nAt := 1
         ::Refresh( .F. )
         If ::oHScroll != Nil
            ::oHScroll:SetPos( ::nAt )
         EndIf
      EndIf
      Return Self
   EndIf

   ::nCell := ::nColPos

   If ::nCell == ::nOldCell
      Return Self
   EndIf

   If ::lCellBrw

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

   EndIf

   ::Refresh( .F. )

   If ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   EndIf

   If ::aColumns[ ::nCell ]:lVisible == .F.
      ::GoRight()
   EndIf

   ::nOldCell := ::nCell
   ::HiliteCell( ::nCell )

Return Self

* ============================================================================
* METHOD TSBrowse:GoLeft() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoLeft() CLASS TSBrowse

   Local nCell, nSkip, ;
         lLock := ::nFreeze > 0 .and. ::lLockFreeze, ;
         lDraw := .F.

   ::nOldCell := ::nCell

   If ::lIsTxt
      If ::nOffset > 5
         ::nOffset -= 5
      Else
         ::nOffset := 1
      EndIf
      ::Refresh( .F. )

      If ::oHScroll != Nil
         ::oHScroll:SetPos( ::nOffset )
      EndIf
      Return Self
   EndIf

   ::ResetSeek()

   If ::lCellBrw

      nCell := ::nCell
      nSkip := 0

      While nCell > ( If( lLock, ::nFreeze + 1, 1 ) )

         nCell --
         nSkip ++

         If ! ::aColumns[ nCell ]:lNoHilite
            Exit
         EndIf

      EndDo

      If nSkip == 0
         Return Self
      EndIf

      While ::nColPos > ( ::nFreeze + 1 ) .and. ! ::IsColVisible( nCell )
         lDraw := .T.
         ::nColPos --
      EndDo

      ::nCell := nCell

      If lDraw
         ::Refresh( .F. )
      EndIf

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      If( ::oHScroll != Nil, ::oHScroll:SetPos( ::nCell ), Nil )
      ::nOldCell := ::nCell
      ::HiliteCell( ::nCell )
      ::DrawSelect()
      If ::aColumns[ ::nCell ]:lVisible == .F.
         If ::nCell == 1
            ::GoRight()
         Else
            ::GoLeft()
         Endif
      endif

    Else

      If ::nCell > ( ::nFreeze + 1 )

         ::nColPos := ::nCell := ::nFreeze + 1
         ::Refresh( .F. )

         If ::oHScroll != Nil
            ::oHScroll:GoTop()
         EndIf

      EndIf

   EndIf

Return Self

// ============================================================================
// METHOD TSBrowse:GoNext() Version 9.0 Nov/30/2009
// Post-edition cursor movement.  Cursor goes to next editable cell, right
// or first-down according to the position of the last edited cell.
// This method is activated when the MOVE clause of ADD COLUMN command is
// set to 5 ( DT_MOVE_NEXT )
// ============================================================================

METHOD GoNext() CLASS TSBrowse

   Local nEle, ;
         nFirst := 0

   ::nOldCell   := ::nCell

   For nEle := ( ::nCell  + 1 ) To Len( ::aColumns )

      If ::IsEditable( nEle ) .and. ! ::aColumns[ nEle ]:lNoHiLite .and. ::aColumns[ nEle ]:lVisible
         nFirst := nEle
         Exit
      EndIf
   Next

   If nFirst > 0
      If ::IsColVisible( nFirst )

         ::nCell := nFirst
         ::HiLiteCell( ::nCell )

         If ! ::lAutoEdit
            ::DrawSelect()
         Else
            ::DrawLine()
         EndIf
      Else
         While ! ::IsColVisible( nFirst ) .and. ::nColPos < nFirst
            ::nColPos ++
         EndDo

         ::lNoPaint := .F.
         ::nCell := nFirst
         ::HiliteCell( nFirst )
         ::Refresh( .F. )
      EndIf

      If ::oHScroll != Nil
         ::oHScroll:SetPos( ::nCell )
      EndIf

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      ::nOldCell := ::nCell
      Return Self
   EndIf

   Aeval( ::aColumns, { | oCol, nCol | nFirst := If( ::IsEditable( nCol ) .and. nFirst == 0, ;
                                       nCol, nFirst ),HB_SYMBOL_UNUSED( oCol ) } )

   If nFirst == 0
      Return Self
   EndIf

   If ::IsColVisible( nFirst )
      ::nCell := nFirst
      ::lNoPaint := .F.
   Else

      ::nColPos := Min( nFirst, ::nFreeze + 1 )
      ::nCell   := nFirst

      While ::nColPos < ::nCell .and. ! ::IsColVisible( ::nCell )
         ::nColPos ++
      EndDo

      ::lNoPaint := .F.
      ::Refresh( .F. )

   EndIf

   ::HiliteCell( ::nCell )

   If( ::oHScroll != Nil, ::oHScroll:SetPos( ::nCell ), Nil )

   If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
      Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
   EndIf

   If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
      Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
   EndIf

   If ::lAutoEdit
      SysRefresh()
   EndIf

   ::nOldCell := ::nCell
   ::lHitBottom := ( ::nAt == ::nLen )
   If ::lHitBottom
      SysRefresh()
   EndIf
   ::GoDown()

Return Self

// ============================================================================
// METHOD TSBrowse:GoPos() Version 9.0 Nov/30/2009
// ============================================================================

METHOD GoPos( nNewRow, nNewCol ) CLASS TSBrowse

   Local nSkip, cAlias, nRecNo, ;
         nTotRow := ::nRowCount(), ;
         nOldRow := ::nLogicPos(), ;
         nOldCol := ::nCell

   Default nNewRow := ::nLogicPos, ;
           nNewCol := ::nCell

   ::lNoPaint := ::lFirstFocus := .F.

   If ValType( nNewRow ) != "N" .or. ValType( nNewCol ) != "N" .or. ;
      nNewCol > Len( ::aColumns ) .or. nNewRow > ::nLen .or. ;
      nNewCol <= 0 .or. nNewRow <= 0

      Tone( 500, 1 )
      Return Nil

   EndIf

   cAlias := ::cAlias

   nSkip := nNewRow - nOldRow

   If ( ::nRowPos + nSkip ) <= nTotRow .and. ( ::nRowPos + nSkip ) >= 1

      ::Skip( nSkip )
      ::nRowPos += nSkip

   ElseIf ! ::lIsDbf
      ::nAt := nNewRow
   ElseIf Empty( ::nLogicPos() )

      While ::nAt != nNewRow

         If ::nAt < nNewRow
            ::Skip( 1 )
         Else
            ::Skip( -1 )
         EndIf

      EndDo

   ElseIf ! Empty( ::nLogicPos() )

      ( cAlias )->( DbSkip( nSkip ) )
      ::nAt := ::nLogicPos()

   Else
      ( cAlias )->( Eval( ::bGoToPos, nNewRow ) )
      ::nAt := ::nLogicPos()
   EndIf

   If nNewRow != nOldRow .and. ::nLen > nTotRow .and. nNewRow > nTotRow

      If ::lIsDbf

         nRecNo := ( cAlias )->( RecNo() )

         ( cAlias )->( DbSkip( nTotRow - ::nRowPos ) )

         If ( cAlias )->( EoF() )

            Eval( ::bGoBottom )
            ::nRowPos := nTotRow

            While ::nRowPos > 1 .and. ( cAlias )->( RecNo() ) != nRecNo
               ::Skip( -1 )
               ::nRowPos --
            EndDo

         Else
            ( cAlias )->( DbGoTo( nRecNo ) )
         EndIf

      Else

         If ( ::nAt + nTotRow - ::nRowPos ) > ::nLen

            Eval( ::bGoBottom )
            ::nRowPos := nTotRow

            While ::nRowPos > 1 .and. ::nAt != nNewRow
               ::Skip( -1 )
               ::nRowPos --
            EndDo

         EndIf

      EndIf

   ElseIf nNewRow != nOldRow .and. ::nLen > nTotRow

      If ::lIsDbf

         nRecNo := ( cAlias )->( RecNo() )
         Eval( ::bGoTop )
         ::nRowPos := ::nAt := 1

         While ::nRowPos < nTotRow .and. ( cAlias )->( RecNo() ) != nRecNo
            ::Skip( 1 )
            ::nRowPos ++
         EndDo

      Else

         Eval( ::bGoTop )
         ::nRowPos := ::nAt := 1

         While ::nRowPos < nTotRow .and. ::nAt != nNewRow
            ::Skip( 1 )
            ::nRowPos ++
         EndDo

      EndIf

   EndIf

   If nNewCol != nOldCol

      While ! ::IsColVisible( nNewCol ) .and. ::nColpos >= 1 .and. ::nColPos < Len( ::aColumns )

         If nNewCol < ::nCell
            ::nColPos --
         Else
            ::nColPos ++
         EndIf

      EndDo

   EndIf

   ::nCell := nNewCol
   ::HiliteCell( ::nCell )
   ::Refresh( .F. )

   If ::bChange != Nil .and. nNewRow != nOldRow
      Eval( ::bChange, Self, 0 )
   EndIf

   If ::oVScroll != Nil .and. nNewRow != nOldRow
      ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
   EndIf

   If ::oHScroll != Nil .and. nNewCol != nOldCol
      ::oHScroll:SetPos( nNewCol )
   EndIf

   ::lHitTop := ::nAt == 1

   If ::lIsArr .and. ::bSetGet != Nil
      If ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ElseIf ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      Else
         Eval( ::bSetGet, "" )
      EndIf
   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:GoRight() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoRight() CLASS TSBrowse

   Local nTxtWid, nWidth, nCell, nSkip, ;
         lRefresh := .F.

   ::nOldCell := ::nCell
   nWidth     := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   If ::lIsTxt
      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != nil, ::hFont, 0 ) ) )
      If ::nOffset < ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
         ::nOffset += 5
         ::Refresh( .F. )
         If ::oHScroll != Nil
            ::oHScroll:SetPos( ::nOffset )
         EndIf
      EndIf
      Return Self
   EndIf

   ::ResetSeek()

   If ::lCellBrw

      If ::nCell == Len( ::aColumns ) .and. ;  // avoid undesired displacement  //::GetColSizes()
         ::IsColVisible( ::nCell )
         Return Self
      EndIf

      nCell := ::nCell
      nSkip := 0

      While nCell < Len( ::aColumns )
         nCell ++
         nSkip ++
         If nCell <= Len( ::aColumns ) .and. ! ::aColumns[ nCell ]:lNoHilite
            Exit
         EndIf
      EndDo

      If nCell > Len( ::aColumns )
         Return Self
      EndIf

      While nSkip > 0
         ::nCell ++
         nSkip --
      EndDo

      lRefresh := ( ::lCanAppend .or. ::lIsArr )

      While ! ::IsColVisible( ::nCell ) .and. ::nColPos < ::nCell
         ::nColPos ++
         lRefresh := .T.
      EndDo

      ::HiliteCell( ::nCell )

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      If lRefresh
         ::lNoPaint := .F.
         ::Refresh( .F. )
      ElseIf ! ::lEditing
         ::DrawSelect()
      EndIf

      If( ::oHScroll != Nil, ::oHScroll:SetPos( ::nCell ), Nil )

      ::nOldCell := ::nCell
      If ::aColumns[ ::nCell ]:lVisible == .F.
         If ::nCell == Len( ::aColumns )
            ::GoLeft()
         Else
            ::GoRight()
         EndIf
      endif

   Else

      If ::nCell == Len( ::aColumns ) .and. ;  // avoid undesired displacement  //::GetColSizes()
         ::IsColVisible( ::nCell )
         Return Self
      EndIf

      If ::oHScroll != Nil
         ::HScroll( SB_PAGEDOWN )
      EndIf

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:GotFocus() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GotFocus( hCtlLost ) CLASS TSBrowse

   Local cMsg

   Default ::lPostEdit   := .F., ;
           ::lFirstFocus := .T., ;
           ::lNoPaint    := .F., ;
           ::lInitGoTop  := .T.

   If ::lEditing .or. ::lPostEdit
      Return 0
   EndIf

   ::lFocused       := .T.
   ::oWnd:hCtlFocus := ::hWnd

   If ::bGotFocus != Nil
      Eval( ::bGotFocus, Self, hCtlLost )
   EndIf

   If ::lIsDbf .and. ::lPainted .and. ! ::lFirstFocus .and. ! ::lNoResetPos .and. ! ::lValidating .and. ! ::lNoPaint .and. ! ::lCanAppend

      If ::uLastTag != Nil
         ( ::cAlias )->( Eval( ::bTagOrder, ::uLastTag ) )
      EndIf

      ( ::cAlias )->( DbGoTo( ::nLastPos ) )
      ::nAt := ::nLastnAt

   ElseIf ::lIsDbf .and. ::lFirstFocus .and. ! ::lNoResetPos .and. ! ::lValidating

      If ::lPainted
         ::GoTop()
      Else
         ( ::cAlias )->( Eval( ::bGoTop ) )
      EndIf

      ::nLastPos := ( ::cAlias )->( RecNo() )
      ::nAt := ::nLastnAt := ::nLogicPos()

   ElseIf ::lFirstFocus .and. ! ::lValidating  .and. ! ::lNoResetPos    //JP 1.70

      If ::lPainted
         ::GoTop()
      Else
         If ::lIsDbf
            ( ::cAlias )->( Eval( ::bGoTop ) )
         Else
            Eval( ::bGoTop )
         EndIf
      EndIf

   EndIf

   ::lFirstFocus := .F.

   If ::nLen > 0 .and. ! EmptyAlias( ::cAlias ) .and. ! ::lIconView .and. ::lPainted
      ::DrawSelect()
   EndIf

   ::lHasFocus   := .T.
   ::lValidating := .F.

   If ::lCellBrw .and. ::lPainted
      cMsg := If( ! Empty( ::AColumns[ ::nCell ]:cMsg ), ::AColumns[ ::nCell ]:cMsg, ::cMsg )
      cMsg := If( ValType( cMsg ) == "B", Eval( cMsg, Self, ::nCell ), cMsg )
      ::SetMsg( cMsg )
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:GoTop() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoTop() CLASS TSBrowse

   Local nAt     := ::nAt, ;
         nLines  := ::nRowCount()

   If ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   EndIf

   If ::nLen < 1
      Return Self
   EndIf

   ::lAppendMode := .F.
   ::ResetSeek()

   If ! ::lHitTop

      If ::lPainted .and. nAt < nLines
         ::DrawLine()
      EndIf

      Eval( ::bGoTop )

      If ::bFilter != Nil
         While ! Eval( ::bFilter ) .and. ! EoF()
           ( ::cAlias )->( DbSkip( 1 ) )
         EndDo
      EndIf

      ::lHitBottom := .F.
      ::nRowPos    := ::nAt := ::nLastnAt := 1
      ::lHitTop    := .T.

      If ::lIsDbf
         ::nLastPos := ( ::cAlias )->( RecNo() )
      EndIf

      If ::lPainted
         If nAt < nLines
            ::DrawSelect()
            ::Refresh( .F. )
         Else
            ::Refresh( ::nLen < nLines )
         EndIf
      EndIf

      If ::oVScroll != Nil
         ::oVScroll:GoTop()
      EndIf

      If ::lPainted .and. ::bChange != Nil
         Eval( ::bChange, Self, VK_UP )
      EndIf

      If ::lIsArr .and. ::bSetGet != Nil
         If ValType( Eval( ::bSetGet ) ) == "N"
            Eval( ::bSetGet, ::nAt )
         ElseIf ::nLen > 0
            Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
         Else
            Eval( ::bSetGet, "" )
         EndIf
      EndIf

      ::HiliteCell( ::nCell )

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:GoUp() Version 9.0 Nov/30/2009
* ============================================================================

METHOD GoUp() CLASS TSBrowse

   Local nSkipped, ;
         nLines := ::nRowCount(), ;
         lTranspar := ::lTransparent .and. ( ::hBrush != Nil .or. ::oWnd:hBrush != Nil )

   If ::nLen < 1

      If ::lCanAppend .and. ::lAppendMode        // append mode being canceled
         ::lAppendMode := ::lHitBottom := .F.
         ::nRowPos--                             // for empty dbfs
      Else
         Return Self
      EndIf
   EndIf

   ::ResetSeek()

   If ::nLen <= nLines .and. ::lNoLiteBar
      Return Self
   EndIf

   If ::lNoLiteBar
      nSkipped := 1 - ::nRowPos
      ::Skip( nSkipped )
      ::nRowPos := 1
   EndIf

   If ::lAppendMode .and. ::lFilterMode .and. ::nPrevRec != Nil
      ( ::cAlias )->( DbGoTo( ::nPrevRec ) )
   EndIf

   If ! ::lHitTop

      If ! ::lAppendMode .and. ::nRowPos > 1  // 14.07.2015
         ::DrawLine()
      EndIf

      If ::Skip( -1 ) == -1

         ::lHitBottom := .F.

         If ::nRowPos > 1

            If ! ::lAppendMode .or. ( ::lAppendMode .and. ::nLen < nLines )
               ::nRowPos--
            EndIf

            If ::lAppendMode

               If ::lFilterMode
                  ::Skip( 1 )
               EndIf

               ::Refresh( If( ::nLen < nLines, .T., .F. ) )
               ::HiliteCell( ::nCell )
            EndIf

         Else

            If ::lPageMode
               ::nRowPos := nLines
               ::Refresh( .F. )
            Else
               If ! lTranspar
                  ::lRePaint := .F.
                  ::TSBrwScroll( -1 )
                  ::Skip( 1 )
                  ::DrawLine( 2 )
                  ::Skip( -1 )
               Else
                  ::Paint()
               EndIf
            EndIf

         EndIf

      ElseIf ! ::lAppendMode
         ::lHitTop := .T.
      EndIf

      ::DrawSelect()

      If ::oVScroll != Nil .and. ! ::lAppendMode
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      EndIf

      If ::bChange != Nil
         Eval( ::bChange, Self, VK_UP )
      EndIf

   EndIf

   ::lAppendMode := .F.
   ::nPrevRec := Nil

Return Self

* ==============================================================================
* METHOD TSBrowse:KeyChar()  Version 9.0 Nov/30/2009
* ==============================================================================

METHOD KeyChar( nKey, nFlags )  CLASS TSBrowse

   /* Next lines were added to filter keys according with
      the data type of columns to start editing cells. Also were defined
      two static functions IsChar() and IsNumeric() to do the job */

   Local cComp, lProcess, cTypeCol
   Local ix

   Default ::nUserKey := nKey

   If ::nUserKey == 255  // from KeyDown() method
      Return 0
   EndIf

   If ::lAppendMode
      Return 0
   EndIf

   ::lNoPaint := .F.
   cTypeCol := iif( ::nLen == 0, "U", ValType( Eval( ::aColumns[ ::nCell ]:bData ) ) ) // Modificado por Carlos

   If Upper( ::aMsg[ 1 ] ) == "YES"
      cComp := "TFYN10"
   else
      cComp := "TF10" + SubStr( ::aMsg[ 1 ], 1, 1 ) + SubStr( ::aMsg[ 2 ], 1, 1 )
   EndIf

   lProcess := IF(( cTypeCol == "C" .or. cTypeCol == "M") .and. _IsChar( nKey ), .T., ;
               IF(( cTypeCol == "N" .or. cTypeCol == "D") .and. _IsNumeric( nKey ), .T., ;
               IF( ( cTypeCol == "L" .and. Upper( Chr( nKey ) ) $ cComp ) .or. ;
                   ( cTypeCol == "L" .and. ::aColumns[ ::nCell ]:lCheckBox .and. nKey == VK_SPACE ), .T., .F. ) ) )

   // here we process direct cell editing with keyboard, not just the Enter key !
   If lProcess .and. ::IsEditable( ::nCell ) .and. ! ::aColumns[ ::nCell ]:lSeek

      If ::aColumns[ ::nCell ]:oEdit == Nil
         ::Edit( , ::nCell, nKey, nFlags )
      Else
         ix := ::aColumns[ ::nCell ]:oEdit:Atx
         if ix > 0
            PostMessage( _HMG_aControlHandles [ix], WM_CHAR, nKey, nFlags )
         endif
      EndIf

   ElseIf ::aColumns[ ::nCell ]:lSeek .and. ( nKey >= 32 .or. nKey == VK_BACK )
      ::Seek( nKey )
   ElseIf lProcess .and. ::lEditableHd .and. nKey >= 32
      If ::aColumns[ ::nCell ]:oEditSpec == Nil
         if ::IsEditable( ::nCell )
            ::Edit( , ::nCell, nKey, nFlags )
         endif
      Else
         ix := ::aColumns[ ::nCell ]:oEditSpec:Atx
         if ix > 0
            PostMessage( _HMG_aControlHandles [ix], WM_CHAR, nKey, nFlags )
         endif
      EndIf
   Else
      ::Super:KeyChar( nKey, nFlags )
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:KeyDown() Version 7.0 Jul/15/2004
* ============================================================================

METHOD KeyDown( nKey, nFlags ) CLASS TSBrowse

   Local uTemp, uVal, uReturn, cType, ;
         lEditable := .F., ;
         nFireKey  := ::nFireKey, ;
         nCol      := ::nCell

   Default nFireKey := VK_F2

   ::lNoPaint := .F.
   ::oWnd:nLastKey := ::nLastKey := ::nUserKey := nKey

   If ::bUserKeys != Nil

      uReturn := Eval( ::bUserKeys, nKey, nFlags, Self )

      If uReturn != Nil .and. ValType( uReturn ) == "N" .and. uReturn < 200 // interpreted as a virtual key code to
         nKey := uReturn                                                    // change the original key pressed
      ElseIf uReturn != Nil .and. ValType( uReturn ) == "L" .and. ! uReturn
         ::nUserKey := 255  // want to inhibit the KeyDown and KeyChar Methods for key pressed
         Return 0
      EndIf
   EndIf

   lEditable := ::IsEditable( nCol )

   If ! lEditable .and. ::lCanAppend
      AEval( ::aColumns, { |o,n| If( ::IsEditable( n ), lEditable := .T., Nil ),HB_SYMBOL_UNUSED( o ) } )
   EndIf

   Do Case                                       // Maintain Clipper behavior for key navigation
      Case ::lIgnoreKey( nKey, nFlags )          // has to go before any other case statement
           ::SuperKeyDown( nKey, nFlags )

      Case _GetKeyState( VK_CONTROL ) .and. _GetKeyState( VK_SHIFT )    // Ctrl+Shift+key
         If nKey == VK_RIGHT                     // Ctrl+Shift+Right Arrow
            ::aColumns[ nCol ]:nEditMove := DT_MOVE_RIGHT
         ElseIf nKey == VK_DOWN                  // Ctrl+Shift+Down Arrow
            ::aColumns[ nCol ]:nEditMove := DT_MOVE_DOWN
         ElseIf nKey == VK_UP                    // Ctrl+Shift+Up Arrow
            ::aColumns[ nCol ]:nEditMove := DT_MOVE_UP
         ElseIf nKey == VK_LEFT                  // Ctrl+Shift+Left Arrow
            ::aColumns[ nCol ]:nEditMove := DT_MOVE_LEFT
         EndIf

      Case _GetKeyState( VK_CONTROL )
         If nKey == VK_HOME                      // Ctrl+Home
            ::GoTop()
            ::PanHome()
         ElseIf nKey == VK_END                   // Ctrl+End
            If ::lHitBottom
               ::PanEnd()
            Else
               ::GoBottom()
            EndIf
         ElseIf nKey == VK_PRIOR                 // Ctrl+PgUp
            ::GoTop()
         ElseIf nKey == VK_NEXT                  // Ctrl+PgDn
            ::GoBottom()
         ElseIf nKey == VK_LEFT                  // Ctrl+Left
            ::PanLeft()
         ElseIf nKey == VK_RIGHT                 // Ctrl+Right
            ::PanRight()
         ElseIf lEditable .and. nKey == VK_PASTE
            ::Edit( uTemp, nCol, VK_PASTE, nFlags )
         ElseIf ::lCellBrw .and. ( nKey == VK_COPY .or. nKey == VK_INSERT )
            uTemp := cValToChar( Eval( ::aColumns[ nCol ]:bData ) )
            CopyToClipboard( uTemp )
            SysRefresh()
         Else
            ::SuperKeyDown( nKey, nFlags )
         EndIf

      Case _GetKeyState( VK_SHIFT ) .and. nKey < 48 .and. nKey != VK_SPACE

         If nKey == VK_HOME                      // Shift+Home
            ::PanHome()
         ElseIf nKey == VK_END                   // Shift+End
            ::PanEnd()
         ElseIf lEditable .and. nKey == VK_INSERT
            ::Edit( uTemp, nCol, VK_PASTE, nFlags )
         ElseIf ( nKey == VK_DOWN .or. nKey == VK_UP ) .and. ::lCanSelect
            ::Selection()
            If nKey == VK_UP
               ::GoUp()
            ElseIf nKey == VK_DOWN
               ::GoDown()
            EndIf
         Else
            ::SuperKeyDown( nKey, nFlags )
         EndIf

      Case nKey == VK_HOME
         ::GoTop()

      Case nKey == VK_END
         ::GoBottom()

      Case ::lEditableHd .and. ( nKey == VK_RETURN .or. nKey == nFireKey ) .and. ::nColSpecHd != 0

         uTemp := ::aColumns[ ::nColSpecHd ]:cSpcHeading

         nCol := ::nColSpecHd
         If Empty(uTemp)
            cType := ValType( Eval( ::aColumns[ nCol ]:bData ) )
            If cType $ "CM"
               uTemp := Space( Len( Eval( ::aColumns[ nCol ]:bData ) ) )
            ElseIf cType == "N"
               uTemp := 0
            ElseIf cType == "D"
               uTemp := CToD( "" )
            ElseIf cType == "L"
               uTemp := .F.
            EndIf
         EndIf

         If ::nColSpecHd != 0
            ::Edit( uTemp, nCol, nKey, nFlags )
         endif

      Case lEditable .and. ( nKey == VK_RETURN .or. nKey == nFireKey )

         If nKey == nFireKey
            nKey := VK_RETURN
         EndIf

         IF ::nColSpecHd != 0
            RETURN 0
         ENDIF

         If ::nRowPos == 0

            If ::nLen == 0 .and. ! ::lCanAppend
               Return 0
            EndIf

         EndIf

         ::oWnd:nLastKey := nKey

         If ::aColumns[ nCol ]:bPrevEdit != Nil

            If ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) ) // append mode for arrays
            Else  // GF 16-05-2008
               uVal := Eval( ::aColumns[ nCol ]:bData )
               uVal := Eval( ::aColumns[ nCol ]:bPrevEdit, uVal, Self )

               If ValType( uVal ) == "L" .and. ! uVal
                  Return 0
               EndIf
            EndIf

         EndIf

         If ::lAppendMode .and. ::lIsArr

            If ! Empty( ::aDefault )

               If Len( ::aDefault ) < Len( ::aColumns )
                  ASize( ::aDefault, Len( ::aColumns ) )
               EndIf

               uTemp := If( ::aDefault[ nCol ] == Nil, ;
                            If( ::aDefValue[ 1 ] == Nil, ;
                                ::aDefValue[ nCol + 1 ], ;
                                ::aDefValue[ nCol ] ), ;
                        If( ValType( ::aDefault[ nCol ] ) == "B", ;
                           Eval( ::aDefault[ nCol ], Self ), ::aDefault[ nCol ] ) )
            Else
               uTemp := If( nCol <= Len( ::aDefValue ), ;
                            ::aDefValue[ nCol ], Space( 10 ) )
            EndIf

         ElseIf ::lAppendMode .and. ::aDefault != Nil

            If Len( ::aDefault ) < Len( ::aColumns )
               ASize( ::aDefault, Len( ::aColumns ) )
            EndIf

            uTemp := If( ::aDefault[ nCol ] != Nil, If( ValType( ::aDefault[ nCol ] ) == "B", ;
                         Eval( ::aDefault[ nCol ], Self ), ::aDefault[ nCol ] ), Eval( ::aColumns[ nCol ]:bData ) )
         Else
            uTemp := Eval( ::aColumns[ nCol ]:bData )
         EndIf

         If ::lCellBrw .and. ::aColumns[ nCol ]:lEdit            // JP v.1.1
            ::Edit( uTemp, nCol, nKey, nFlags )
         endif

      Case ::lCanSelect .and. !lEditable .and. nKey == VK_SPACE  // Added 27.09.2012
         ::Selection()
         ::GoDown()
      Case nKey == VK_UP
         ::GoUp()
      Case nKey == VK_DOWN
         ::GoDown()
      Case nKey == VK_LEFT
         ::GoLeft()
      Case nKey == VK_RIGHT
         ::GoRight()
      Case nKey == VK_PRIOR
         nKeyPressed := .T.
         ::PageUp()
      Case nKey == VK_NEXT
         nKeyPressed := .T.
         ::PageDown()
      Case nKey == VK_DELETE .and. ::lCanDelete
         ::DeleteRow()
      Case nKey == VK_CONTEXT .and. nFlags == 22872065
         If ::bContext != Nil
            Eval( ::bContext, ::nRowPos, ::nColPos, Self )
         EndIf
      Case !::lCellbrw .and. ( nKey == VK_RETURN .or. nKey == VK_SPACE ) .and. ::bLDblClick != Nil  // 14.07.2015
         Eval( ::bLDblClick, Nil, nKey, nFlags, Self )
      Otherwise
         ::SuperKeyDown( nKey, nFlags )
   EndCase

Return 0

* ============================================================================
* METHOD TSBrowse:Selection()  Version 9.0 Nov/30/2009
* ============================================================================

METHOD Selection() CLASS TSBrowse

   Local uTemp, uVal
#ifdef __EXT_SELECTION__
   Local lCan := .T.

   If HB_IsBlock( ::bPreSelect )
      lCan := Eval( ::bPreSelect, ::nAt )
      If !HB_IsLogical( lCan )
         lCan := .T.
      EndIf
   EndIf

   If lCan
#endif
   uVal := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

   If ( uTemp := AScan( ::aSelected, uVal ) ) > 0
      ARRDEL_( ::aSelected, uTemp )
      ::DrawSelect()

      If ::bSelected != Nil
         Eval( ::bSelected, Self, uVal, .F. )
      EndIf

   Else

      AAdd( ::aSelected, uVal )
      ::DrawSelect()

      If ::bSelected != Nil
         Eval( ::bSelected, Self, uVal, .T. )
      EndIf

   EndIf
#ifdef __EXT_SELECTION__
   EndIf
#endif

Return Self

* ============================================================================
* METHOD TSBrowse:KeyUp()  Version 9.0 Nov/30/2009
* ============================================================================

METHOD KeyUp( nKey, nFlags ) CLASS TSBrowse

   If lNoAppend != Nil
      ::lCanAppend := .T.
      lNoAppend := Nil
   EndIf

   If nKeyPressed != Nil

      ::Refresh( .F. )
      nKeyPressed := Nil

      If ::bChange != Nil
         Eval( ::bChange, Self, nKey )
      EndIf

   EndIf

Return ::Super:KeyUp( nKey, nFlags )

* ============================================================================
* METHOD TSBrowse:LButtonDown() Version 9.0 Nov/30/2009
* ============================================================================

METHOD LButtonDown( nRowPix, nColPix, nKeyFlags ) CLASS TSBrowse

   Local nClickRow, nSkipped, nI, lHeader, lFooter, nIcon, nAtCol, bLClicked, lMChange, lSpecHd, ;
         nColPixPos := 0, ;
         uPar1    := nRowPix, ;
         uPar2    := nColPix, ;
         nColInit := ::nColPos - 1, ;
         lDrawRow := .F., ;
         lDrawCol := .F., ;
         nLines   := ::nRowCount(), ;
         nCol     := 0, ;
         oCol, ix

   Default ::lDontChange := .F.

   ::lNoPaint := .F.

   If ::nFreeze > 0
      For nI := 1 To ::nFreeze
         nColPixPos += ::GetColSizes()[ nI ]
      Next
   EndIf

   nClickRow := ::GetTxtRow( nRowPix )
   nAtCol    := Max( ::nAtCol( nColPix ), 1 )   // JP 1.31
   lHeader   := nClickRow == 0 .and. ::lDrawHeaders
   lFooter   := nClickRow == -1 .and. If( ::lDrawFooters != Nil, ::lDrawFooters, .F. )
   lSpecHd   := nClickRow == -2 .and. if( ::lDrawSpecHd != Nil, ::lDrawSpecHd , .F. )
   ::oWnd:nLastKey := 0

   If ::aColumns[ nAtCol ]:lNoHilite .and. ! lHeader .and. ! lFooter

      If nAtCol <= ::nFreeze .and. ::lLockFreeze
         nAtCol := ::nFreeze + 1
      EndIf
   EndIf

   If ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
      If  nClickRow == -2 .and. ::nColSpecHd > 0
         oCol := ::oWnd:aColumns[ ::nColSpecHd ]
      else
         oCol := ::oWnd:aColumns[ ::oWnd:nCell ]
      endif
      If oCol:oEdit != Nil
// JP 1.40-64
         IF (nClickRow  == ::nRowPos .AND. nAtCol == ::oWnd:nCell) .or. ;
             (nClickRow == -2 .and. ::lDrawSpecHd .AND. nAtCol == ::nColSpecHd )

            DO CASE
            CASE "TSMULTI" $ Upper( oCol:oEdit:ClassName() )
               RETURN 0
            CASE "TCOMBOBOX" $ Upper( oCol:oEdit:ClassName() )
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )
               RETURN 0
            CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )  // JP 1.64
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )
               RETURN 0
            OTHERWISE
               ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
               If ix > 0
                  nCol := _HMG_aControlCol [ix]
               EndIf
               If nCol > nColPix
                   nCol := 0
               EndIf
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )
               RETURN 0
            ENDCASE
         ELSE
            DO CASE
            CASE "TSMULTI" $ Upper( oCol:oEdit:ClassName() )
               If oCol:oEdit:bLostFocus != Nil
                  Eval( oCol:oEdit:bLostFocus , VK_ESCAPE )
               EndIf
            CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )
               If oCol:oEdit:bLostFocus != Nil
                  Eval( oCol:oEdit:bLostFocus , VK_ESCAPE )
               Else
                  Eval( oCol:oEdit:bKeyDown , VK_ESCAPE, 0, .t. )
               EndIf
            OTHERWISE
               If oCol:oEdit:bLostFocus != Nil
                  Eval( oCol:oEdit:bLostFocus , VK_ESCAPE )
               EndIf
            ENDCASE
            SetFocus( ::hWnd )
            ::Refresh( .T. )
         ENDIF
//end
      EndIf
   EndIf

   If ::lIconView

      If ( nIcon := ::nAtIcon( nRowPix, nColPix ) ) != 0
         ::DrawIcon( nIcon )
      EndIf

      Return Nil

   EndIf

   SetFocus( ::hWnd )

   If ::nLen < 1 .or. ::lIsTxt
      If ! ::lCanAppend .or. ::lIsTxt
         Return 0
      ElseIf nClickRow > 0
         ::PostMsg( WM_KEYDOWN, VK_DOWN, nMakeLong( 0, 0 ) )
         Return 0
      EndIf
   EndIf

   If lHeader .and. Valtype( nKeyFlags ) == "N"
      lMChange   := ::lMChange
      ::lMChange := .F.

      If ::nHeightSuper == 0 .or. ( ::nHeightSuper > 0 .and. nRowPix >= ::nHeightSuper )
         ::DrawPressed( nAtCol )
      EndIf

      If ::aActions != Nil .and. nAtCol <= Len( ::aActions )

         If ::aActions[ nAtCol ] != Nil
            ::DrawHeaders()
            Eval( ::aActions[ nAtCol ], Self, uPar1, uPar2 )

            If ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
               CursorArrow()
               Return 0
            EndIf

            ::DrawHeaders()
         EndIf
      EndIf

      ::lMChange := lMChange

   ElseIf lFooter

      lMChange   := ::lMChange
      ::lMChange := .F.

      If ::aColumns[ nAtCol ]:bFLClicked != Nil

         Eval( ::aColumns[ nAtCol ]:bFLClicked, uPar1, uPar2, ::nAt, Self )

         If ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
            Return 0
         EndIf

      EndIf

      ::lMChange := lMChange
      ::DrawFooters()

   ElseIf lSpecHd .and. ::lEditableHd

      lMChange   := ::lMChange
      ::lMChange := .F.
      If ::aColumns[ nAtCol ]:bSLClicked != Nil

         Eval( ::aColumns[ nAtCol ]:bSLClicked, uPar1, uPar2, ::nAt, Self )

         If ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
            Return 0
         EndIf
      Else
         IF ::lEditingHd
            oCol := ::oWnd:aColumns[ ::oWnd:nCell ]
            If oCol:oEditSpec != Nil
               ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
               IF ix > 0
                  nCol := _HMG_aControlCol [ix]
               ENDIF
               IF nCol > nColPix
                   nCol := 0
               ENDIF
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )
               RETURN 0
            EndIf
         ENDIF
      EndIf

      ::lMChange := lMChange
      ::DrawHeaders()

   EndIf

   If ::lDontChange
      Return Nil
   EndIf

   If ::lMChange .and. nClickRow == 0 .and. ! ::lNoMoveCols

      If AScan( ::GetColSizes(), { | nColumn | nColPixPos += nColumn, nColInit ++, ;
                  nColPix >= nColPixPos - 2 .and. nColPix <= nColPixPos + 2 }, ::nColPos ) != 0

         ::lLineDrag := .T.
         ::VertLine( nColPixPos, nColInit, nColPixPos - nColPix )
      Else
         ::lColDrag := .T.
         ::nDragCol := ::nAtCol( nColPix )
      EndIf

      If ! ::lCaptured
         ::lCaptured := .T.
         ::Capture()
      EndIf

   EndIf

   If nClickRow > 0 .and. nClickRow != ::nRowPos .and. nClickRow < ( nLines + 1 )

      ::ResetSeek()
      ::DrawLine()

      nSkipped  := ::Skip( nClickRow - ::nRowPos )
      ::nRowPos += nSkipped

      If ::oVScroll != Nil
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      EndIf

      lDrawRow      := .T.
      ::lHitTop     := .F.
      ::lHitBottom  := .F.
      ::lAppendMode := .F.

      If ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      EndIf

   EndIf

   If nClickRow > 0 .or. ( ! ::lDrawHeaders .and. nClickRow >= 0 )

      bLClicked := If( ::aColumns[ nAtCol ]:bLClicked != Nil, ::aColumns[ nAtCol ]:bLClicked, ::bLClicked )

      If ! ( ::lLockFreeze .and. ::nAtCol( nColPix, .T. ) <= ::nFreeze )
         lDrawCol := ::HiliteCell( ::nCell, nColPix )
      EndIf

      If bLClicked != Nil
         Eval( bLClicked, uPar1, uPar2, nKeyFlags, Self )
      EndIf

      If ! ::lNoHScroll .and. ::oHScroll != Nil .and. lDrawCol
         ::oHScroll:SetPos( ::nCell )
      EndIf

   EndIf

   If lDrawRow .or. lDrawCol
      ::DrawSelect()
   EndIf

   If ::lCellBrw

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      ::nOldCell := ::nCell

   EndIf

   ::lGrasp := ! lHeader

   If ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus == ::hWnd
      ::lMouseDown := .T.
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:LButtonUp() Version 9.0 Nov/30/2009
* ============================================================================

METHOD LButtonUp( nRowPix, nColPix, nFlags ) CLASS TSBrowse

   Local nClickRow, nDestCol

   If nKeyPressed != Nil
      ::DrawPressed( nKeyPressed, .F. )
   EndIf

   If ::lCaptured
      ::lCaptured := .F.
      ReleaseCapture()

      If ::lLineDrag
         ::lLineDrag := .F.
         ::VertLine()
      Else
         ::lColDrag := .F.
         nClickRow := ::GetTxtRow( nRowPix )

         nDestCol := ::nAtCol( nColPix )

         // we gotta be on header row within listbox and not same colm
         If nClickRow == 0 .or. nClickRow == -2
            If  nColPix > ::nLeft .and. ::nDragCol != nDestCol

                If ::lMoveCols
                   ::MoveColumn( ::nDragCol, nDestCol )
                Else
                   ::Exchange( ::nDragCol, nDestCol )
                EndIf

                If ValType( ::bColDrag ) == "B" 
                   Eval( ::bColDrag, nDestCol, ::nDragCol, Self ) 
                EndIf
            ElseIf ::nDragCol = nDestCol

                If ::aColumns[ nDestCol ]:bHLClicked != Nil
                   ::DrawHeaders()
                   Eval( ::aColumns[ nDestCol ]:bHLClicked, nRowPix, nColPix, ::nAt, Self )
                   ::DrawHeaders()
               EndIf
            Endif
         EndIf
      EndIf
   EndIf

   ::lGrasp := .F.
   ::Super:LButtonUp( nRowPix, nColPix, nFlags )

Return 0

* ============================================================================
* METHOD TSBrowse:LDblClick() Version 9.0 Nov/30/2009
* ============================================================================

METHOD LDblClick( nRowPix, nColPix, nKeyFlags ) CLASS TSBrowse

   Local nClickRow := ::GetTxtRow( nRowPix ), ;
         nCol      := ::nAtCol( nColPix, ::lSelector ), ;
         uPar1     := nRowPix, ;
         uPar2     := nColPix

   ::oWnd:nLastKey := 0
   If ! ::lEnabled
      Return Self
   EndIf

   If ( nClickRow == ::nRowPos .and. nClickRow > 0 ) .or. ( nClickRow == ::nRowPos .and. ! ::lDrawHeaders )

      If ::lCellBrw .and. ::IsEditable( nCol )

         ::nColSpecHd := 0
         If ValType( Eval( ::aColumns[ nCol ]:bData ) ) == "L" .and. ;
            ::aColumns[ nCol ]:lCheckBox  // virtual checkbox
            ::PostMsg( WM_CHAR, VK_SPACE, 0 )
         Else
            ::PostMsg( WM_KEYDOWN, VK_RETURN, 0 )
         EndIf

         Return 0
#ifndef __EXT_SELECTION__
      ElseIf ::lCanSelect .and. ::bUserKeys == Nil  // Added 28.09.2012
         ::Selection()
#endif
      ElseIf ::bLDblClick != Nil
         Eval( ::bLDblClick, uPar1, uPar2, nKeyFlags, Self )
      EndIf

   ElseIf nClickRow == 0 .and. ::lDrawHeaders .and. ! ::lNoChangeOrd  // GF 1.71
      If ::bLDblClick != Nil .and. ::aActions == Nil
         Eval( ::bLDblClick, uPar1, uPar2, nKeyFlags, Self )
      Else
         ::SetOrder( ::nAtCol( nColPix, ! ::lSelector ) )
      EndIf
   ElseIf nClickRow == -2 .and. ::lDrawSpecHd .and. ::aColumns[ nCol ]:lEditSpec
      If ::lAutoSearch .or. ::lAutoFilter
         ::nColSpecHd := Min( If( nCol <= ::nFreeze, ::nFreeze + 1, ::nAtCol( nColPix ) ), Len( ::aColumns ) )
         ::PostMsg( WM_KEYDOWN, VK_RETURN, 0 )
         Return 0
      EndIf
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:LoadFields() Version 9.0 Nov/30/2009
* ============================================================================

METHOD LoadFields( lEditable ) CLASS TSBrowse

   Local n, nE, cHeading, nAlign, nSize, cData, cType, nDec, hFont, cPicture, ;
         cBlock, nCols, aNames, cKey, ;
         aColSizes := ::aColSizes, ;
         cOrder, nEle, ;
         cAlias := ::cAlias, ;
         aAlign := { "LEFT", "CENTER", "RIGHT", "VERT" }, ;
         aStru  := ( ::cAlias )->( DbStruct() )

   Default lEditable := ::lEditable, ;
           aColSizes := {}

   aNames    := ::aColSel
   nCols     := If( aNames == Nil, ( ::cAlias )->( FCount() ), Len( aNames ) )
   aColSizes := If( Len( ::aColumns ) == Len( aColSizes ), Nil, aColSizes )

   For n := 1 To nCols

      nE := If( aNames == Nil, n, ( ::cAlias )->( FieldPos( aNames[ n ] ) ) )

      If ValType( ::aHeaders ) == "A" .and. ! Empty( ::aHeaders ) .and. n <= Len( ::aHeaders )
         cHeading := ::aHeaders[ n ] 
      Else 
         cHeading := ::Proper( ( ::cAlias )->( Field( nE ) ) ) 
      EndIf 

      If ( nEle := AScan( ::aTags, {|e| Upper( cHeading ) $ Upper( e[ 2 ] ) } ) ) > 0
         cOrder := ::aTags[ nEle, 1 ]
         cKey   := ( ::cAlias )->( OrdKey() )

         If Upper( cHeading ) $ Upper( cKey )
            ::nColOrder := If( Empty( ::nColOrder ), Len( ::aColumns ) + 1, ::nColOrder )
         EndIf
      Else
         cOrder := ""
      EndIf

      nAlign := If( ::aJustify != Nil .and. Len( ::aJustify ) >= nE, ::aJustify[ nE ], ;
                    If( ( ::cAlias )->( ValType( FieldGet( nE ) ) ) == "N", 2, ;
                    If( ( ::cAlias )->( ValType( FieldGet( nE ) ) ) == "L", 1, 0 ) ) )

      nAlign := If( ValType( nAlign ) == "L", If( nAlign, 2, 0 ), ;
                If( ValType( nAlign ) == "C", AScan( aAlign, nAlign ) - 1, nAlign ) )

      nSize := If( ! aColSizes == Nil .and. Len( aColsizes ) >= nE, aColSizes[ nE ], Nil ) 

      cType := aStru[ nE, 2 ]
      If cType == "C"
         cPicture := "@K " + Replicate( 'X', aStru[ nE, 3 ] )
      ElseIf cType == "N"
         cPicture := Replicate( '9', aStru[ nE, 3 ] )
         IF aStru[ nE, 4 ] > 0
            cPicture := SubStr( cPicture, 1, aStru[ nE, 3 ]-aStru[ nE, 4 ] - 1 ) + '.' + Replicate( '9', aStru[ nE, 4 ] )
         endif
         cPicture := "@K " + cPicture
      EndIf

      If nSize == Nil
         cData := ( ::cAlias )->( FieldGet( nE ) )
         cType := aStru[ nE, 2 ]
         nSize := aStru[ nE, 3 ]
         nDec  := aStru[ nE, 4 ]
         hFont := If( ::hFont != Nil, ::hFont, 0 )

         If cType == "C"
            cData := PadR( Trim( cData ), nSize, "B" )
            nSize := GetTextWidth( 0, cData, hFont )
         ElseIf cType == "N"
            cData := StrZero( cData, nSize, nDec )
            nSize := GetTextWidth( 0, cData, hFont )
         ElseIf cType == "D"
            cData := cValToChar( If( Empty( cData ), Date(), cData ) )
            nSize := Int( GetTextWidth( 0, cData + "B", hFont ) ) + If( lEditable, 30, 0 )
         ElseIf cType == "M"
            nSize := If( ::nMemoWV == Nil, 200, ::nMemoWV )
         Else
            cData := cValToChar( cData )
            nSize := GetTextWidth( 0, cData, hFont )
         EndIf

         nSize := Max( GetTextWidth( 0, Replicate( "B", Len( cHeading ) ), hFont ), nSize )
         nSize += If( ! Empty( cOrder ), 14, 0 )

      ElseIf ValType( ::aColSizes ) == "A" .and. ! Empty( ::aColSizes ) .and. n <= Len( ::aColSizes )
         nSize := ::aColSizes[ n ] 
      EndIf

      If ValType( ::aFormatPic ) == "A" .and. ! Empty( ::aFormatPic ) .and. n <= Len( ::aFormatPic )
         cPicture := ::aFormatPic[ n ] 
      EndIf 
  
      cBlock := 'FieldWBlock("' + aStru[ nE, 1 ] + '",Select("' + ::cAlias + '"))'
      ::AddColumn( TSColumn():New( cHeading, FieldWBlock( aStru[ nE, 1 ], Select( ::cAlias ) ),cPicture, ;
                                   { ::nClrText, ::nClrPane }, { nAlign, DT_CENTER }, nSize,, lEditable,,, cOrder,,,, ;
                                   5,,,, Self, cBlock ) )

      ATail( ::aColumns ):cData := ::cAlias + "->" + FieldName( nE )
      ATail( ::aColumns ):cName := ( ::cAlias )->( FieldName( nE ) )  // 21.07.2015

      If cType == "L"
         ATail( ::aColumns ):lCheckBox := .T.
      EndIf

      If ! Empty( cOrder )
         ATail( ::aColumns ):lIndexCol := .T.
      EndIf

   Next

   If ::nLen == 0
      ::nLen := If( ::bLogicLen == Nil, Eval( ::bLogicLen := {||( cAlias )->( LastRec() ) } ), Eval( ::bLogicLen ) )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:nAtCol() Version 9.0 Nov/30/2009
* ============================================================================

METHOD nAtCol( nColPixel, lActual ) CLASS TSBrowse

   Local nColumn := ::nColPos - 1, ;
         aSizes  := ::GetColSizes(), ;
         nI      := 0, ;
         nPos    := 0

   Default lActual := .F.

   If ::nFreeze > 0

      If lActual
         nColumn := 0
      Else
         For nI := 1 To ::nFreeze
            nPos += aSizes[ nI ]
         Next
      EndIf
   EndIf

   While nPos < nColPixel .and. nColumn < ::nColCount()
      If ::aColumns[ nColumn + 1 ]:lVisible  // skip hidden columns
         nPos += aSizes[ nColumn + 1 ]
      EndIf
      nColumn++
   EndDo

Return nColumn

* ============================================================================
* METHOD TSBrowse:nAtColActual()
* ============================================================================

METHOD nAtColActual( nColPixel ) CLASS TSBrowse 
  
   Local nColumn := 0, ;
         aSizes  := ::GetColSizes(), ;
         nI      := 0, ;
         nColPix := 0

   For nI := 1 To ::nFreeze
      IF nColPixel > nColPix
         nColumn := nI
      ENDIF
      nColPix += aSizes[ nI ]
   Next

   For nI := 1 To ::nColCount()
      IF nI > ::nFreeze
         IF nColPixel > nColPix
            nColumn++
         ENDIF  
         nColPix += IF( ::IsColVis2( nI ), aSizes[ nI ], 0 )   
      ENDIF 
   Next 

Return nColumn 

* ============================================================================
* METHOD TSBrowse:nAtIcon() Version 9.0 Nov/30/2009
* ============================================================================

METHOD nAtIcon( nRow, nCol ) CLASS TSBrowse

   Local nIconsByRow := Int( ::nWidth() / 50 )

   nRow -= 9
   nCol -= 1

   If ( nCol % 50 ) >= 9 .and. ( nCol % 50 ) <= 41
      return Int( ( nIconsByRow * Int( nRow / 50 ) ) + Int( nCol / 50 ) ) + 1
   Else
      return 0
   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:nLogicPos() Version 9.0 Nov/30/2009
* ============================================================================

METHOD nLogicPos() CLASS TSBrowse

   Local cAlias, cOrderName, nLogicPos

   Default ::lIsDbf  := .F., ;
           ::lIsTxt  := .F.

   If ! ::lIsDbf

      If ::lIsTxt
         ::nAt := ::oTxtFile:RecNo()
      EndIf

      If ::cAlias == "ADO_"
         Return Eval( ::bKeyNo )
      EndIf

      Return ::nAt

   EndIf

   cAlias := ::cAlias

   cOrderName := If( ::bTagOrder != Nil, ( cAlias )->( Eval( ::bTagOrder ) ), Nil )
   nLogicPos  := ( cAlias )->( Eval( ::bKeyNo, Nil, Self ) )

   If ::lFilterMode
      nLogicPos := nLogicPos - ::nFirstKey
   EndIf

   nLogicPos := If( nLogicPos <= 0, ::nLen + 1, nLogicPos )

Return nLogicPos

* ============================================================================
* METHOD TSBrowse:HandleEvent() Version 9.0 Nov/30/2009
* ============================================================================

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TSBrowse

   Local nDelta, ix

   Default ::lNoPaint := .F., ;
           ::lDontChange := .F.

   If hb_IsBlock( ::bEvents ) 
      If ! Empty( EVal( ::bEvents, Self, nMsg, nWParam, nLParam ) )
         Return 1
      EndIf
   EndIf
   If nMsg == WM_SETFOCUS .and. ! ::lPainted
      Return 0
   #ifdef __HARBOUR__
   ElseIf nMsg == WM_KEYUP
      Return ::KeyUp( nWParam, nLParam )
   ElseIf nMsg == WM_VSCROLL
      If ::lDontchange
         Return Nil
      EndIf
      Return ::VScroll( Loword( nWParam ), HiWord( nWParam ) )
   #EndIf
   ElseIf nMsg == WM_GETDLGCODE
      return ::GetDlgCode( nWParam )
   ElseIf nMsg == WM_CHAR .and. ::lEditing
      Return 0
   ElseIf nMsg == WM_CHAR
      return ::KeyChar( nWParam, nLParam )
   ElseIf nMsg == WM_KEYDOWN .and. ::lDontChange
      Return 0
   ElseIf nMsg == WM_KEYDOWN
      return ::KeyDown( nWParam, nLParam )
   ElseIf nMsg == WM_KEYUP
      Return ::KeyUp( nWParam, nLParam )
   Elseif nMsg == WM_HSCROLL
      If ::lDontchange
         Return Nil
      EndIf
      Return ::HScroll( Loword( nWParam ), HiWord( nWParam ) )
   #ifdef __XHARBOUR__
   ElseIf nMsg == WM_VSCROLL
      if nLParam == 0
         Return ::VScroll( Loword( nWParam ), HiWord( nWParam ) )
      endif
   #EndIf
   ElseIf nMsg == WM_ERASEBKGND .and. ! ::lEditing
      ::lNoPaint := .F.
   ElseIf nMsg == WM_DESTROY .and. ! Empty( ::aColumns ) .and. ::aColumns[ ::nCell ]:oEdit != Nil
      ix := ::aColumns[ ::nCell ]:oEdit:Atx
      if ix > 0
         PostMessage( _HMG_aControlHandles [ix], WM_KEYDOWN, VK_ESCAPE, 0 )
      endif
#ifdef __EXT_SELECTION__
   ElseIf nMsg == WM_LBUTTONDBLCLK .and. _GetKeyState( VK_SHIFT )
      If ::lCanSelect .and. !::lEditable
         ::Selection()
      Endif
#endif
   ElseIf nMsg == WM_LBUTTONDBLCLK
      Return ::LDblClick( HiWord( nLParam ), LoWord( nLParam ), nWParam )
   ElseIf nMsg == WM_MOUSEWHEEL
      If ::hWnd != 0 .and. ! ::lDontChange
         nDelta := Bin2I( I2Bin( HiWord( nWParam ) ) ) / 120
         ::MouseWheel( nMsg, nDelta, LoWord( nLParam ), HiWord( nLParam ) )
      EndIf
      Return 0
   EndIf

Return ::Super:HandleEvent( nMsg, nWParam, nLParam )

* ============================================================================
* METHOD TSBrowse:HiliteCell() Version 9.0 Nov/30/2009
* ============================================================================

METHOD HiliteCell( nCol, nColPix ) CLASS TSBrowse

   Local nI, nAbsCell, nRelCell, nNowPos, nOldPos, nLeftPix, ;
         lDraw := .F.,;
         lMove := .T.

   Default nCol := 1

   If ! ::lCellBrw .and. nColPix == Nil            // if not browsing cell-style AND no nColPix, ignore call.
      Return lDraw                                 // nColPix NOT nil means called from ::LButtonDown()
   EndIf

   If nCol < 1
      nCol := 1
   ElseIf nCol > Len( ::aColumns )
      nCol := Len( ::aColumns )
   EndIf

   If Len( ::aColumns ) > 0

      If nColPix != Nil                            // used internally by ::LButtonDown() only
         nAbsCell := ::nAtCol( nColPix, .F. )
         nRelCell := ::nAtCol( nColPix, .T. )

         If nAbsCell >= ::nFreeze .and. nRelCell <= ::nFreeze
            nNowPos := nRelCell
         Else
            nNowPos := nAbsCell
         EndIf

         nOldPos := ::nCell

         If ::nFreeze > 0 .and. nOldPos < nNowPos .and. ::lLockFreeze  // frozen col and going right
            nNowPos := nAbsCell
            lMove := ( nOldPos > ::nFreeze )
         EndIf

         If nOldPos < nNowPos                      // going right
            nLeftPix := 0

            For nI := nOldPos To nNowPos - 1
               lDraw := .T.
               ::nCell ++
               nLeftPix += ::aColSizes[ nI ]       // we need to know pixels left of final cell...
            Next

            ::nCell := If( ::nCell > Len(::aColumns), Len(::aColumns), ::nCell )

            If ::nWidth() < ( nLeftPix + ::aColSizes[ ::nCell ] ) .and. ::nColPos < Len( ::aColumns ) .and. lMove
               ::nColPos ++
               ::Refresh( .F. )
            EndIf
         ElseIf nNowPos < nOldPos                  // going left

            For nI := nNowPos To nOldPos - 1
               lDraw := .T.
               ::nCell --
            Next

            ::nCell := If( ::nCell < 1, 1, ::nCell )
         EndIf

         nCol := ::nCell
      Else
         lDraw := ! ( ::nCell == nCol )

         ::nColPos := Max( ::nFreeze + 1, ::nColPos )

         If ::nFreeze > 0 .and. ::lLockFreeze
            ::nCell := Max( nCol, ::nFreeze + 1 )
         ElseIf ::nCell != nCol
            ::nCell := nCol
         EndIf

         If ! ::lNoHScroll .and. ::oHScroll != Nil .and. lDraw

            ::oHScroll:SetPos( nCol )

            If ::lPainted
               ::Refresh( .F. )
            EndIf

         EndIf
      EndIf

      If ::lCellBrw
         // unhilite all columns EXCEPT those with "double cursor" (permanent) efect
         AEval( ::aColumns, { |oColumn| oColumn:lNoLite := ! oColumn:lFixLite } ) // allways .T. if no double cursor
         ::aColumns[ nCol ]:lNoLite := .F.
      EndIf
   EndIf

Return lDraw

* ============================================================================
* METHOD TSBrowse:HScroll() Version 9.0 Nov/30/2009
* ============================================================================

METHOD HScroll( nWParam, nLParam ) CLASS TSBrowse

   Local nCol, nMsg, nPos

   nMsg := nWParam
   nPos := nLParam

   ::lNoPaint := .F.

   If GetFocus() != ::hWnd
      SetFocus( ::hWnd )
   EndIf

   Do Case
   Case nMsg == SB_LINEUP
      ::GoLeft()

   Case nMsg == SB_LINEDOWN
      ::GoRight()

   Case nMsg == SB_PAGEUP
      ::PanLeft()

   Case nMsg == SB_PAGEDOWN
        nCol := ::nColPos + 1

        While ::IsColVisible( nCol ) .and. nCol <= Len( ::aColumns )
           ++nCol
        EndDo

        If nCol < Len ( ::aColumns )
           ::nColPos := ::nCell := nCol
           ::Refresh( .F. )
           ::oHScroll:SetPos( nCol )
        Else

           nCol := Len( ::aColumns )
           While ! ::IsColVisible( nCol ) .and. ::nColPos < nCol
              ::nColPos++
           EndDo
           ::nCell := nCol
           ::oHScroll:GoBottom()
           ::Refresh( .F. )
        EndIf

        If ::lCellBrw
           ::HiLiteCell( ::nCell )
        EndIf

   Case nMsg == SB_TOP
      ::PanHome()

   Case nMsg == SB_BOTTOM
      ::PanEnd()

   Case nMsg == SB_THUMBPOSITION
      ::HThumbDrag( nPos )

   Case nMsg == SB_THUMBTRACK
      ::HThumbDrag( nPos )

   Endcase

Return 0

* ============================================================================
* METHOD TSBrowse:HThumbDrag() Version 9.0 Nov/30/2009
* ============================================================================

METHOD HThumbDrag( nPos ) CLASS TSBrowse

   Local nI, nLeftPix, nColPos,;
         nWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   If ::oHScroll != Nil .and. ! Empty( nPos )

      If nPos >= Len( ::aColumns )
         If ::IsColVisible( Len( ::aColumns ) )
            ::nCell := Len( ::aColumns )
            ::HiliteCell( ::nCell )
            ::Refresh( .F. )
         Else
            ::PanEnd()
         EndIf
         ::oHScroll:GoBottom()
         Return Self
      EndIf

      If ::lIsTxt
         ::oHScroll:SetPos( ::nAt := nPos )
      Else
         If ::lLockFreeze .and. nPos <= ::nFreeze   // watch out for frozen columns
            ::oHScroll:SetPos( ::nCell := ::nFreeze + 1 )
         Else
            ::oHScroll:SetPos( ::nCell := Min( nPos, Len( ::aColumns ) ) )
         EndIf

         nLeftPix := 0                              // check for frozen columns,

         For nI := 1 To ::nFreeze                   // if any
            nLeftPix += ::aColSizes[ nI ]
         Next

         nColPos := ::nCell

         For nI := ::nCell To 1 Step - 1            // avoid extra scrolling
            If nLeftPix + ::aColSizes[nI] < nWidth  // to the right of the
               nLeftPix += ::aColSizes[nI]          // last cell (column)
               nColPos := nI
            Else
               Exit
            EndIf
         Next

         ::nColPos := nColPos
         ::HiliteCell( ::nCell )
      EndIf

      ::Refresh( .F. )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:InsColumn() Version 9.0 Nov/30/2009
* ============================================================================

METHOD InsColumn( nPos, oColumn ) CLASS TSBrowse

   Local nI, ;
         nCell := ::nCell

   Default nPos := 1

   If oColumn == Nil                             // if no Column object supplied
      Return Nil                                 // return nil insted of reference to object
   EndIf

   If Valtype( nPos ) == "C"
      nPos := ::nColumn( nPos )
   EndIf

   If nPos < 1
      nPos := 1
   ElseIf nPos > Len( ::aColumns ) + 1
      nPos := Len( ::aColumns ) + 1
   EndIf

   ASize( ::aColumns, Len( ::aColumns ) + 1 )
   aIns( ::aColumns, nPos )
   ::aColumns[ nPos ] := oColumn

   ASize( ::aColSizes, Len( ::aColSizes ) + 1 )
   aIns( ::aColSizes, nPos )
   ::aColsizes[ nPos ] := IF(oColumn:lVisible, oColumn:nWidth, 0)

   If nPos == 1 .and. Len( ::aColumns ) > 1 .and. ::lSelector
      Return Nil
   EndIf

   If( nCell != nPos, ::nCell := If( ::lPainted, nPos, nCell ), Nil )

   If ! Empty( oColumn:cOrder )                       // if column has a TAG, we
      ::SetOrder( nPos )                              // set it as controling order
   ElseIf ::nColOrder != 0 .and. nPos <= ::nColOrder  // if left of current order
      ::nColOrder ++                                  // adjust position
   EndIf

   If ::lPainted
      ::HiliteCell( ::nCell )

      If ::oHScroll != Nil
         ::oHScroll:SetRange( 1, Len( ::aColumns ) )
         ::oHScroll:SetPos( ::nCell )
      EndIf

      If ! Empty( ::aSuperHead )

         For nI := 1 To Len( ::aSuperHead )

            If nPos >= ::aSuperHead[ nI, 1 ] .and. nPos <= ::aSuperHead[ nI, 2 ]
               ::aSuperHead[ nI, 2 ] ++
            ElseIf nPos < ::aSuperHead[ nI, 1 ]
               ::aSuperHead[ nI, 1 ] ++
               ::aSuperHead[ nI, 2 ] ++
            EndIf
         Next
      EndIf

      ::Refresh( .F. )
      ::SetFocus()
   EndIf

Return oColumn  // returns reference to Column object

* ============================================================================
* METHOD TSBrowse:IsColVisible() Version 9.0 Nov/30/2009
* ============================================================================

METHOD IsColVisible( nCol ) CLASS TSBrowse

   Local nCols, nFirstCol, nLastCol, nWidth, nBrwWidth, xVar, ;
         aColSizes := ::GetColSizes()

   nCols     := Len( aColSizes )
   nFirstCol := ::nColPos
   nLastCol  := nFirstCol
   nWidth    := 0
   nBrwWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   If nCol < ::nColPos .or. ::nColPos <= 0
      Return .F.
   EndIf

   xVar := 1

   While xVar <= ::nFreeze
      nWidth += aColSizes[ xVar++ ]
   EndDo

   While nWidth < nBrwWidth .and. nLastCol <= nCol .and. nLastCol <= nCols
      nWidth += aColSizes[ nLastCol ]
      nLastCol++
   EndDo

   If nCol <= --nLastCol
      Return ! nWidth > nBrwWidth
   EndIf

Return .F.

* ============================================================================
* METHOD TSBrowse:IsColVis2() Version 9.0 Nov/30/2009
* ============================================================================

METHOD IsColVis2( nCol ) CLASS TSBrowse

   Local nCols, nFirstCol, nLastCol, nBrwWidth, ;
         nWidth := 0, ;
         aColSizes := ::GetColSizes()

   nCols     := Len( aColSizes )
   nFirstCol := ::nColPos
   nLastCol  := nFirstCol

   // mt differs from iscolvisible here - allows for frozen column
   If ::nFreeze > 0
      AEval( aColSizes, {|nSize| nWidth += nSize }, 1, ::nFreeze )
   EndIf

   nBrwWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   If nCol < ::nColPos
      Return .F.
   EndIf

   Do While nWidth < nBrwWidth .and. nLastCol <= nCols
      nWidth += aColSizes[ nLastCol ]
      nLastCol++
   EndDo

   If nCol <= --nLastCol
      // mt differs from new iscolvisible here
      Return .T.
   EndIf

Return .F.

* ============================================================================
* METHOD TSBrowse:Insert() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Insert( cItem, nAt ) CLASS TSBrowse

   Local nMin, nMax, nPage

   Default nAt := ::nAt, ;
           cItem := AClone( ::aDefValue )

   If ! ::lIsArr
      Return Nil
   EndIf

   If ValType( cItem ) == "A" .and. cItem[ 1 ] == Nil
      ARRDEL_( cItem, 1  )
   EndIf

   ASize( ::aArray, Len( ::aArray ) + 1 )
   nAt := Max( 1, nAt )
   AIns( ::aArray, nAt )
   ::aArray[ nAt ] := If( Valtype( cItem ) == "A", cItem, {cItem} )

   ::nLen := Eval( ::bLogicLen )
   If ::lNoVScroll
      If ::nLen > ::nRowCount()
        ::lNoVScroll := .F.
      EndIf
   EndIf

   If ! ::lNoVScroll
      nMin  := Min( 1, ::nLen )
      nMax  := Min( ::nLen, MAX_POS )
      nPage := Min( ::nRowCount(), ::nLen )
      ::oVScroll := TSBScrlBar():WinNew( nMin, nMax, nPage, .T., Self )
   EndIf

   ::Refresh( .T. )

Return Self

* ============================================================================
* METHOD TSBrowse:AddItem() Version 7.0 Oct/10/2007
* ============================================================================

METHOD AddItem( cItem ) CLASS TSBrowse    // delete in V90

   Local nMin, nMax, nPage

   Default cItem := AClone( ::aDefValue )

   If ! ::lIsArr
      Return Nil
   EndIf

   If ValType( cItem ) == "A" .and. cItem[ 1 ] == Nil
      ARRDEL_( cItem, 1 )
   EndIf

   cItem := If( Valtype( cItem ) == "A", cItem, {cItem} )

   If ::lPhantArrRow .and. Len(::aArray) == 1
      ::SetArray( {cItem},.t. )
      ::lPhantArrRow := .F.
   ElseIf  Len(::aArray) == 0
      ::SetArray( {cItem},.t. )
   Else
      AAdd(::aArray,  cItem )
   EndIf

   ::nLen := Eval( ::bLogicLen )
   If ::lNoVScroll
      If ::nLen > ::nRowCount()
        ::lNoVScroll := .F.
      EndIf
   EndIf

   If ! ::lNoVScroll
      nMin  := Min( 1, ::nLen )
      nMax  := Min( ::nLen, MAX_POS )
      nPage := Min( ::nRowCount(), ::nLen )
      ::oVScroll := TSBScrlBar():WinNew( nMin, nMax, nPage, .T., Self )
   EndIf

   ::Refresh( .T. )

Return Self

* ============================================================================
* METHOD TSBrowse:lEditCol() Version 7.0 Jul/15/2004
* ============================================================================

METHOD lEditCol( uVar, nCol, cPicture, bValid, nClrFore, nClrBack ) CLASS TSBrowse

Return ::Edit( uVar, nCol,,, cPicture, bValid, nClrFore, nClrBack ) // just for compatibility

* ============================================================================
* METHOD TSBrowse:lIgnoreKey() Version 9.0 Nov/30/2009
* Checks if any of the predefined navigation keys has been remapped so as to
* ignore its default behavior and forward it to TWindow class in case a new
* behavior has been defined in ::bKeyDown. Uses the new nested array IVar
* ::aKeyRemap which has the following structure (data type in parens):
*
* { { VK_ to ignore(n), alone(l), ctrl(l), shift(l), alt(l), ctrl+shift(l), bBlock }, ... }
*
* Example:  AAdd( ::aKeyRemap, { VK_END, .T., .F., .T., .F., .F., { || Tone(600) } } )
*           will ignore End key alone and with shift+end combinations
*
* It's the programmer's (ie you!) responsibility to make sure each subarray
* has 6 elements of the specified data type or kaboom!
* This method is called by ::KeyDown() which provides nKey and nFlags.
* If called directly, you must specify the parameter nKey (nFlags is always ignored)
* ============================================================================

METHOD lIgnoreKey( nKey, nFlags ) CLASS TSBrowse

   Local lIgnore := .F., ;
         nAsync := 2, ;                // key by itself
         nIgnore := AScan( ::aKeyRemap, {|aRemap| aRemap[ 1 ] == nKey } )

   HB_SYMBOL_UNUSED( nFlags )

   If nIgnore > 0

      If _GetKeyState( VK_CONTROL ) .and. _GetKeyState( VK_SHIFT )
         nAsync := 6
      ElseIf _GetKeyState( VK_CONTROL )
         nAsync := 3
      ElseIf _GetKeyState( VK_SHIFT )
         nAsync := 4
      ElseIf _GetKeyState( VK_MENU )                    // alt key
         nAsync := 5
      EndIf

      lIgnore := ::aKeyRemap[ nIgnore, nAsync ]

      If lIgnore .and. ValType( ::aKeyRemap[ nIgnore, 7 ] ) == "B"
         Eval( ::aKeyRemap[ nIgnore, 7 ] )
      EndIf

   EndIf

Return lIgnore

* ============================================================================
* METHOD TSBrowse:LoadRecordSet() Version 9.0 Nov/30/2009
* ============================================================================

METHOD LoadRecordSet() CLASS TSBrowse

   Local n, nE, cHeading, nAlign, aColSizes, cData, cType, nDec, hFont, cBlock, nType, ;
         cOrder := Upper( ::oRSet:Sort ), ;
         aAlign := { "LEFT", "CENTER", "RIGHT", "VERT" }, ;
         nCols  := ::oRSet:Fields:Count(), ;
         nWidth := 0, ;
         aRName := {}, ;
         aNum   := {}, ;
         aNames := ::aColSel

   If ! Empty( aNames )
      For n := 1 To nCols
         AAdd( aRName, ::oRSet:Fields( n - 1 ):Name )
      Next

      nCols := Len( aNames )
   EndIf

   cOrder := AllTrim( StrTran( StrTran( cOrder, "ASC" ), "DESC" ) )
   aColSizes := If( Len( ::aColumns ) == Len( ::aColSizes ), Nil, ::aColSizes )

   For n := 1 To nCols

      nE := If( Empty( aNames ), n - 1, AScan( aRName, { |e| Upper( e ) == Upper( aNames[ n ] ) } ) - 1 )

      cHeading := If( ! Empty( ::aHeaders ) .and. Len( ::aHeaders ) >= n, ::aHeaders[ n ], ;
                      ::Proper( ::oRSet:Fields( nE ):Name ) )

      nAlign := If( ::aJustify != Nil .and. Len( ::aJustify ) >= n, ::aJustify[ n ], ;
                    If( ValType( ::oRSet:Fields( nE ):Value ) == "N", 2, ;
                    If( ValType( ::oRSet:Fields( nE ):Value ) == "L", 1, 0 ) ) )

      nAlign := If( ValType( nAlign ) == "L", If( nAlign, 2, 0 ), ;
                If( ValType( nAlign ) == "C", AScan( aAlign, nAlign ) - 1, nAlign ) )

      nWidth := If( ! aColSizes == Nil .and. Len( aColsizes ) >= n, aColSizes[ n ], Nil )

      If nWidth == Nil
         cData := ::oRSet:Fields( nE ):Value
         cType := ClipperFieldType( nType := ::oRSet:Fields( nE ):Type )
         If ValType( cType ) != "C"
            //msginfo(::oRSet:Fields( nE ):Name,cType)
            Loop
         EndIf

         nWidth := If( cType == "N", ::oRSet:Fields( nE ):Precision, ::oRSet:Fields( nE ):DefinedSize )
         nDec   := If( cType != "N", 0, If( nType == adCurrency, 2, ;
                   If( ASCan( { adDecimal, adNumeric, adVarNumeric }, nType ) > 0, ::oRSet:Fields( nE ):NumericScale, ;
                       0 ) ) )
         hFont := If( ::oFont != Nil, ::oFont:hFont, 0 )

         If cType == "C" .and. ValType( cData ) == "C"
            cData := PadR( Trim( cData ), nWidth, "B" )
            nWidth := GetTextWidth( 0, cData, hFont )
         ElseIf cType == "N"
            cData := StrZero( Val( Replicate( "4", nWidth ) ), nDec )
            nWidth := GetTextWidth( 0, cData, hFont )
         ElseIf cType == "D"
            cData := cValToChar( If( ! Empty( cData ), cData, Date() ) )
            nWidth := Int( GetTextWidth( 0, cData, hFont ) ) + 22
         ElseIf cType == "M"
            cData := cValToChar( cData )
            nWidth := If( ::nMemoWV == Nil, 200, ::nMemoWV )
         Else
            cData := cValToChar( cData )
            nWidth := GetTextWidth( 0, cData, hFont )
         EndIf
      EndIf

      nWidth := Max( nWidth, GetTextWidth( 0, cHeading, hFont ) )
      cBlock := 'AdoGenFldBlk( Self:oRS, ' + LTrim( Str( nE ) ) + ' )'
      ::AddColumn( TSColumn():New( cHeading, AdoGenFldBlk( ::oRSet, nE ),, { ::nClrText, ::nClrPane }, ;
                                   { nAlign, DT_CENTER }, nWidth,, ::lEditable,,, ::oRSet:Fields( nE ):Name,,,, ;
                                   5,,,, Self, cBlock ) )
      ATail( ::aColumns ):cDatatype := cType
      ATail( ::aColumns ):Cargo := ::oRSet:Fields( nE ):Name

      If cOrder == Upper( cHeading )
         ::nColOrder := Len( ::aColumns )
         Atail( ::aColumns ):cOrder := cOrder
      EndIf
   Next

Return Self

* ============================================================================
* METHOD TSBrowse:LoadRelated() Version 9.0 Nov/30/2009
* ============================================================================

METHOD LoadRelated( cAlias, lEditable, aNames, aHeaders ) CLASS TSBrowse

   Local n, nE, cHeading, nAlign, nSize, cData, cType, nDec, hFont, aStru, nArea, nFields, cBlock

   Default lEditable := .F.

   If Empty( cAlias )
      Return Self
   EndIf

   cAlias  := AllTrim( cAlias )
   nArea   := Select( cAlias )
   aStru   := ( cAlias )->( DbStruct() )
   nFields := If( aNames == Nil, ( cAlias )->( FCount() ), Len( aNames ) )

   For n := 1 To nFields

      nE := If( aNames == Nil, n, ( cAlias )->( FieldPos( aNames[ n ] ) ) )

      cHeading := If( aHeaders != Nil .and. Len( aHeaders ) >= n, ;
                      aHeaders[ n ], cAlias + "->" + ;
                      ::Proper( ( cAlias )->( Field( nE ) ) ) )

      nAlign := If( ( cAlias )->( ValType( FieldGet( nE ) ) ) == "N", 2, ;
                If( ( cAlias )->( ValType( FieldGet( nE ) ) ) == "L", 1, 0 ) )

      cData := ( cAlias )->( FieldGet( nE ) )
      cType := ValType( cData )
      nSize := aStru[ nE, 3 ]
      nDec  := aStru[ nE, 4 ]
      hFont := If( ::hFont != Nil, ::hFont, 0 )

      If cType == "C"
         cData := PadR( Trim( cData ), nSize, "B" )
         nSize := GetTextWidth( 0, cData, hFont )
      ElseIf cType == "N"
         cData := StrZero( cData, nSize, nDec )
         nSize := GetTextWidth( 0, cData, hFont )
      ElseIf cType == "D"
         cData := cValToChar( If( ! Empty( cData ), cData, Date() ) )
         nSize := Int( GetTextWidth( 0, cData, hFont ) * 1.15 )
      Else
         cData := cValToChar( cData )
         nSize := GetTextWidth( 0, cData, hFont )
      EndIf

      nSize := Max( GetTextWidth( 0, Replicate( "B", Len( cHeading ) ), ;
                                  hFont ), nSize )
      cBlock := 'FieldWBlock( "' + ( cAlias )->( Field( nE ) ) + '", Select( "' + ;
                cAlias + '" ) )'
      ::AddColumn( TSColumn():New( cHeading, FieldWBlock( ( cAlias )->( Field( nE ) ), nArea ),, ;
                                   { ::nClrText, ::nClrPane }, { nAlign, DT_CENTER }, nSize,, lEditable,,,,,,, ;
                                   5,,,, Self, cBlock ) )

      ATail( ::aColumns ):cAlias := cAlias
      ATail( ::aColumns ):cData  := cAlias + "->" + FieldName( nE )

   Next

Return Self

* ============================================================================
* METHOD TSBrowse:Look3D() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Look3D( lOnOff, nColumn, nLevel, lPhantom ) CLASS TSBrowse

   Default lOnOff   := .T., ;
           nColumn  :=  0 , ;
           lPhantom := .T., ;
           nLevel   :=  0

   ::l3DLook := lOnOff                              // used internally

   If nColumn > 0
      If nLevel = 1 .or. nLevel = 0
         ::aColumns[ nColumn ]:l3DLook := lOnOff
      EndIf

      If nLevel = 2 .or. nLevel = 0
         ::aColumns[ nColumn ]:l3DLookHead := lOnOff
      EndIf

      If nLevel = 3 .or. nLevel = 0
         ::aColumns[ nColumn ]:l3DLookFoot := lOnOff
      EndIf
   Else
      If nLevel > 0
         AEval( ::aColumns, { | oCol | If( nLevel = 1, oCol:l3DLook := lOnOff, If( nLevel = 2, ;
                              oCol:l3DLookHead := lOnOff, oCol:l3DLookFoot := lOnOff ) ) } )
      Else
         AEval( ::aColumns, { | oCol | oCol:l3DLook := lOnOff, oCol:l3DLookHead := lOnOff, ;
                              oCol:l3DLookFoot := lOnOff } )
      EndIf
   EndIf

   If lPhantom
      ::nPhantom := PHCOL_GRID
   Else
      ::nPhantom := PHCOL_NOGRID
   EndIf

   ::Refresh( .T. )

Return Self

* ============================================================================
* METHOD TSBrowse:LostFocus() Version 9.0 Nov/30/2009
* ============================================================================

METHOD LostFocus( hCtlFocus ) CLASS TSBrowse

   Local nRecNo, uTag

   Default ::aControls := {}

   If ::lEditing .and. Len( ::aControls ) > 0 .and. ;
      hCtlFocus == ::aControls[ 1 ]

      Return 0

   EndIf

   If ::lEditing

      If ::aColumns[ ::nCell ]:oEdit != Nil
         if IsControlDefined (::cChildControl, ::cParentWnd )
            ::aColumns[ ::nCell ]:oEdit:End()
            ::aColumns[ ::nCell ]:oEdit := Nil
         endif
      EndIf

      ::lEditing := ::lPostEdit := .F.

   EndIf

   ::lNoPaint := .F.

   ::lFocused := .F.

   If ! Empty( ::bLostFocus )
      Eval( ::bLostFocus, hCtlFocus )
   EndIf

   If ::nLen > 0 .and. ! EmptyAlias( ::cAlias ) .and. ! ::lIconView

      If ::lIsDbf .and. ( ::cAlias )->( RecNo() ) != ::nLastPos

         If ::bTagOrder != Nil .and. ::uLastTag != Nil
            uTag := ( ::cAlias )->( Eval( ::bTagOrder ) )
            ( ::cAlias )->( Eval( ::bTagOrder, ::uLastTag ) )
         EndIf

         nRecNo := ( ::cAlias )->( RecNo() )
         ( ::cAlias )->( DbGoTo( ::nLastPos ) )

      EndIf

      If ::lPainted
         ::DrawSelect()
      EndIf

      If nRecNo != Nil

         If uTag != Nil
            ( ::cAlias )->( Eval( ::bTagOrder, uTag ) )
         EndIf

         ( ::cAlias )->( DbGoTo( nRecNo ) )
      EndIf
   EndIf

   ::lHasFocus := .F.

Return 0

* ============================================================================
* METHOD TSBrowse:MButtonDown() Version 9.0 Nov/30/2009
* ============================================================================

METHOD MButtonDown( nRow, nCol, nKeyFlags ) CLASS TSBrowse

   If ::bMButtonDown != Nil
      Eval( ::bMButtonDown, nRow, nCol, nKeyFlags )
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:MouseMove() Version 9.0 Nov/30/2009
* ============================================================================

METHOD MouseMove( nRowPix, nColPix, nKeyFlags ) CLASS TSBrowse

   Local nI, nIcon, lHeader, lMChange, nFirst, nLast, nDestCol, ;
         cMsg       := ::cMsg, ;
         nColPixPos := 0, ;
         lFrozen    := .F., ;
         nColumn    := Max( 1, ::nAtColActual( nColPix ) ), ;
         nRowLine   := ::GetTxtRow( nRowPix ), cToolTip

   Default ::lMouseDown  := .F., ;
           ::lNoMoveCols := .F., ;
           ::lDontChange := .F.

   If ::lIconView

      If ( nIcon := ::nAtIcon( nRowPix, nColPix ) ) != 0

         If ::nIconPos != 0 .and. ::nIconPos != nIcon
            ::DrawIcon( ::nIconPos )
         EndIf

         ::nIconPos := nIcon
         ::DrawIcon( nIcon, .T. )
         CursorHand()
         Return 0
      EndIf
   EndIf

   If ::nFreeze > 0

      For nI := 1 To ::nFreeze
         nColPixPos += ::GetColSizes()[ nI ]
      Next

      If nColPix < nColPixPos
         lFrozen := .T.
      EndIf
   EndIf

   If nColumn <= ::nColCount()

      If ( lHeader := ( nRowLine == 0 .or. nRowLine == -2 ) ) .and. ! Empty( ::aColumns ) .and. ;
                                                                    ! Empty( ::aColumns[ nColumn ]:cToolTip )
         cToolTip := ::aColumns[ nColumn ]:cToolTip  // column's header tooltip
      Else
         cToolTip := ::cToolTip  // grid's tooltip
      EndIf

      If ( ::nToolTip != nColumn .or. nRowLine != ::nToolTipRow ) .and. IsWindowHandle( ::hWnd ) .and. IsWindowHandle( hToolTip )

         If Valtype( ctooltip ) == "B"
            cToolTip := Eval( cToolTip, Self, nColumn, nRowLine )
         EndIf

         SetToolTip( ::hWnd, cToolTip, hToolTip )
         SysRefresh()

         ::nToolTipRow := nRowLine
      EndIf

      ::nToolTip := nColumn
   EndIf

   If ! ::lGrasp .and. ( lFrozen .or. ! lHeader .or. ! ::lMChange )
       // don't allow MouseMove to drag/resize columns
       // unless in header row and not in frozen zone
      CursorArrow()

      If ::lCaptured
         If ::lLineDrag
            ::VertLine()
            ::lLineDrag := .F.
         EndIf

         ReleaseCapture()
         ::lColDrag := ::lCaptured := ::lMouseDown := .F.
      ElseIf ::lDontChange
         CursorStop()
         Return 0
      EndIf

      lMChange := ::lMChange  // save it for restore
      ::lMChange := .F.

      If ::lCellBrw .and. ! Empty( ::aColumns[ Max( 1, ::nAtCol( nColPix ) ) ]:cMsg )
         ::cMsg := ::aColumns[ Max( 1, ::nAtCol( nColPix ) ) ]:cMsg
      Else
         ::cMsg := cMsg
      EndIf

      ::cMsg := If( ValType( ::cMsg ) == "B", Eval( ::cMsg, Self, Max( 1, ::nAtCol( nColPix ) ) ), ::cMsg )
      ::Super:MouseMove( nRowPix, nColPix, nKeyFlags )
      ::lMChange := lMChange
      ::cMsg := cMsg
      Return 0
   EndIf

   If ::lMChange .and. ! ::lNoMoveCols .and. ! ::lDontChange
      If lHeader
         If ! Empty( ::aSuperHead )  .and. !::lLineDrag

            nFirst := 0
            nLast  := 0
            Aeval( ::aSuperHead, { | aSup, nCol | nFirst := If( ::nDragCol >= aSup[1] .and. ::nDragCol <= aSup[ 2 ],nCol,nFirst ), ;
                           nLast := max(nLast,aSup[ 2 ])} )

            nDestCol := ::nAtCol( nColPix )
            if nLast < nDestCol
               nLast := nFirst+1
            else
               Aeval( ::aSuperHead, { | aSup, nCol | nlast := If( nDestCol >= aSup[1] .and. nDestCol <= aSup[ 2 ],nCol,nlast )} )
            endif
            If nLast != nFirst
               ::lGrasp := .F.
               CursorHand()
               ::lColDrag := ::lCaptured := ::lMouseDown := .F.
            endif
         endif
         If ::lGrasp             // avoid dragging between header & rows
            ::lGrasp := .F.
            CursorArrow()        // restore default cursor
         EndIf

         If ::lColDrag
            CursorSize()
         Else
            If ::lLineDrag
               ::VertLine( nColPix )
               CursorWE()
            Else
               If AScan( ::GetColSizes(), { | nColumn | nColPixPos += nColumn, ;
                           nColPix >= nColPixPos - 2 .and. nColPix <= nColPixPos + 2 }, ::nColPos ) != 0
                  CursorWE()
               Else
                  CursorHand()
               EndIf
            EndIf
         EndIf
      ElseIf ::lGrasp
         ::lCaptured := ::lColDrag := .F.     // to avoid collision with header/column dragging
         ::lMouseDown := .T.                  // has to be down until dragging finishes
         ::Super:MouseMove( nRowPix, nColPix, nKeyFlags )
      Else
         CursorArrow()
      EndIf
   Else
      If ::lDontChange
         CursorStop()
      Else
         CursorArrow()
      EndIf
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:MouseWheel() Version 9.0 Nov/30/2009
* ============================================================================

METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos ) CLASS TSBrowse

   Local nWParam, oReg, ;
         aCoors := {0,0,0,0}

   HB_SYMBOL_UNUSED( nKeys )

   GetWindowRect( ::hWnd, aCoors )

   If ::nWheelLines == Nil
      oReg:= Treg32():New( HKEY_CURRENT_USER, "Control Panel\Desktop" )
      ::nWheelLines := Val( oReg:Get( "WheelScrollLines" ) )
      oReg:Close()
   EndIf

   If nYPos >= aCoors[ 2 ] .and. nXPos >= aCoors[ 1 ] .and. ;
         nYPos <= ( aCoors[ 4 ] )  .and.  nXPos <= ( aCoors[ 3 ]  )

      If ( nDelta ) > 0

         If ! Empty( ::nWheelLines )
            nWParam := SB_LINEUP
            nDelta  := ::nWheelLines * nDelta
         Else
            nWParam := SB_PAGEUP
         EndIf

      Else

         If ! Empty( ::nWheelLines )
            nWParam := SB_LINEDOWN
            nDelta  := ::nWheelLines * Abs( nDelta )
         Else
            nWParam := SB_PAGEDOWN
            nDelta := Abs( nDelta )
         EndIf

      EndIf

      While nDelta > 1
         ::VScroll( nWParam, 0 )
         nDelta--
      EndDo
   ENDIF

Return ::VScroll( nWParam, 0 )

* ============================================================================
* METHOD TSBrowse:MoveColumn() Version 9.0 Nov/30/2009
* ============================================================================

METHOD MoveColumn( nColPos, nNewPos ) CLASS TSBrowse

   Local oCol, cOrder, ;
         nMaxCol   := Len( ::aColumns ), ;
         nOrder    := ::nColOrder, ;
         lCurOrder := ( ::nColOrder == nColPos )

   Local lSetOrder := ;
      ( nOrder != nColPos .and. nOrder != nNewPos .and. ::nColOrder == nNewPos )

   If ! Empty( nColPos ) .and. ! Empty( nNewPos ) .and. ;
         nColPos > ::nFreeze .and. nNewPos > ::nFreeze .and. ;
         nColPos <= nMaxCol .and. nNewPos <= nMaxCol

      oCol   := ::aColumns[ nColPos ]
      cOrder := oCol:cOrder
      oCol:cOrder := Nil                         // avoid ::InsColumn() from seting order...

      ::DelColumn( nColPos )
      ::InsColumn( nNewPos, oCol )
      ::aColumns[ nNewPos ]:cOrder := cOrder     // ...restore ::cOrder (if any)

      If lSetOrder
         ::SetOrder( nNewPos - 1 )
      ElseIf lCurOrder
         ::SetOrder( nNewPos )
      ElseIf nOrder != 0
         // check if current order is in between moving columns
         If nOrder >= nColPos .and. nOrder <= nNewPos      // left to right movement
            nOrder --
         ElseIf nOrder <= nColPos .and. nOrder >= nNewPos  // right to left movement
            nOrder ++
         EndIf

         ::SetOrder( nOrder )

      EndIf

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:PageDown() Version 9.0 Nov/30/2009
* ============================================================================

METHOD PageDown( nLines ) CLASS TSBrowse

   Local nSkipped, nI, ;
         lPageMode := ::lPageMode, ;
         nTotLines := ::nRowCount()

   Default nLines := nTotLines

   ::lAppendMode := .F.
   ::ResetSeek()

   If ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   EndIf

   If ::nLen < 1
      Return Nil
   EndIf

   If ! ::lHitBottom

      ::nPrevRec := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

      If lPageMode .and. ::nRowPos < nLines
         nSkipped := ::Skip( nLines - ::nRowPos )
         lPageMode := .F.
      Else
         nSkipped = ::Skip( ( nLines * 2 ) - ::nRowPos )
      EndIf

      If nSkipped != 0
         ::lHitTop = .F.
      EndIf

      Do Case

         Case nSkipped == 0
            ::lHitBottom := .T.
            Return Nil
         Case nSkipped < nLines .and. ! lPageMode

            nI := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

            If ::lIsDbf
               ( ::cAlias )->( DbGoTo( ::nPrevRec ) )
            Else
               ::nAt := ::nPrevRec
            EndIf

            ::DrawLine()

            If ::lIsDbf
               ( ::cAlias )->( DbGoTo( nI ) )
            Else
               ::nAt := nI
            EndIf

            If nLines - ::nRowPos < nSkipped

               nKeyPressed := Nil
               ::Skip( -( nLines ) )

               For nI = 1 To ( nLines - 1 )
                  ::Skip( 1 )
                  ::DrawLine( nI )
               Next

               ::Skip( 1 )
            EndIf

            ::nRowPos = Min( ::nRowPos + nSkipped, nTotLines )

         Case nSkipped < nLines .and. lPageMode
            ::Refresh( .T. )
         Otherwise

            For nI = nLines To 1 Step -1
               ::Skip( -1 )
            Next

            ::Skip( ::nRowPos )
            ::lRepaint := .T.       // JP 1.31
      Endcase

      If nKeyPressed == Nil
         ::Refresh( ::nLen < nTotLines )
         If ::bChange != Nil
            Eval( ::bChange, Self, VK_NEXT )
         EndIf
      ElseIf nSkipped >= nLines
         ::DrawSelect()
      Else
         nKeyPressed := Nil
         ::DrawSelect()
      EndIf

      If ::oVScroll != Nil
         If ! ::lHitBottom
            ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
         Else
            ::oVScroll:GoBottom()
         EndIf
      EndIf

      If ::lRepaint .and. ::nRowPos == nTotLines
         If ::bChange != Nil
            Eval( ::bChange, Self, VK_NEXT )   // GF 15/01/2009
         EndIf
      EndIf

   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:PageUp() Version 9.0 Nov/30/2009
* ============================================================================

METHOD PageUp( nLines ) CLASS TSBrowse

   Local nSkipped, nRecNo

   Default nLines := ::nRowCount()

   ::lHitBottom := .F.
   ::lAppendMode := .F.
   ::ResetSeek()

   If ::lPageMode .and. ::nRowPos > 1

      ::DrawLine()
//      nSkipped := ::Skip( -( ::nRowPos - 1 ) )    //V90 active
      ::nRowPos := 1
      ::Refresh( .F. )

      If ::oVScroll != Nil
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      EndIf

      If ::bChange != Nil
         Eval( ::bChange, Self, VK_PRIOR )
      EndIf

      Return Self

   EndIf

   ::nPrevRec := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )
   nSkipped := ::Skip( -nLines )

   If ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), ;
                    Eval( ::bLogicLen ) )
   EndIf

   If ::nLen < 1
      Return Nil
   EndIf

   If ! ::lHitTop

      If nSkipped == 0
         ::lHitTop := .T.
      Else

         If -nSkipped < nLines .or. ::nAt == 1  // 14.07.2015

            nRecNo := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

            If ::lIsDbf
               ( ::cAlias )->( DbGoto( ::nPrevRec ) )
            Else
               ::nAt := ::nPrevRec
            EndIf

            ::DrawLine()
            ::nRowPos := 1
            ::Refresh( .F. )   // GF 14/01/2009

            If ::lIsDbf
               ( ::cAlias )->( DbGoto( nRecNo ) )
            Else
               ::nAt := nRecNo
            EndIf

            If ::oVScroll != Nil
               ::oVScroll:SetPos( 1 )
            EndIf

         Else

            If ::oVScroll != nil
               ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
            EndIf

         EndIf

         If nKeyPressed == Nil

            ::Refresh( .F. )

            If ::bChange != Nil
               Eval( ::bChange, Self, VK_PRIOR )
            EndIf

         Else

            ::DrawSelect()

            If -nSkipped < nLines
               nKeyPressed := Nil

               If ::bChange != Nil
                  Eval( ::bChange, Self, VK_PRIOR )   // GF 15/01/2009
               EndIf

            EndIf

         EndIf

      EndIf

   Else

      If ::oVScroll != Nil
         ::oVScroll:GoTop()
      EndIf

   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:Paint() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Paint() CLASS TSBrowse

   Local lAppendMode, nRecNo, uTag, oCol, ;
         nColPos := ::nColPos, ;
         nI      := 1, ;
         nLines  := Min( ( ::nLen + If( ::lAppendMode .and. ! ::lIsArr, 1, 0 ) ), ::nRowCount() ), ;
         nSkipped := 1

   Default ::lPostEdit   := .F., ;
           ::lFirstPaint := .T., ;
           ::lNoPaint    := .F., ;
           ::lInitGoTop  := .T., ;
           ::nFreeze     := 0

   If ! ::lRepaint
      Return 0
   EndIf

   If ::lEditing .and. ! ::lPostEdit .and. ::nLen > 0
      Return 0
   ElseIf ::lEditing .or. ::lNoPaint

      If ::lDrawHeaders
         ::DrawHeaders()
      EndIf

      ::DrawSelect()
      Return 0
   EndIf

   If ::lFirstPaint
      ::Default()
   EndIf

   ::nRowPos := If( ::lDrawHeaders, Max( 1, ::nRowPos ), ::nRowPos )

   If ::lIconView
      ::DrawIcons()
      Return 0
   EndIf

   If Empty( ::aColumns )
      Return Nil
   EndIf

   If ! ::lPainted
      SetHeights( Self )

      If ::lSelector
         Default ::nSelWidth := Max( nBmpWidth( ::hBmpCursor ), Min( ::nHeightHead, 25 ) )

         oCol           := ColClone( ::aColumns[ 1 ], Self )
         oCol:bData     := {||""}
         oCol:cHeading  := ""
         oCol:nWidth    := ::nSelWidth
         oCol:lNoHilite := .T.
         oCol:lFixLite  := Empty( ::hBmpCursor )
         oCol:nClrBack  := oCol:nClrHeadBack
         ::InsColumn( 1, oCol )
         ::nFreeze ++
         ::lLockFreeze := .T.
         ::HiliteCell( Max( ::nCell, ::nFreeze + 1 ) )

         If ! Empty( ::nColOrder )
            ::nColOrder ++
            ::SetOrder( ::nColOrder )
         EndIf
      EndIf

      nLines := Min( ( ::nLen + If( ::lAppendMode .and. ! ::lIsArr, 1, 0 ) ), ::nRowCount() )

      If ::nLen <= nLines .and. ::nAt > ::nRowPos
         ::nRowPos := ::nAt
      EndIf

      If ::lInitGoTop
         ::GoTop()
      EndIf

      If ! ::lNoHScroll .and. ::oHScroll != Nil
         ::oHScroll:SetRange( 1, Len( ::aColumns ) )
      EndIf

      If ::bInit != Nil
         Eval( ::bInit, Self )
      EndIf
   EndIf

   If ::lDrawHeaders .and. ::nHeightSuper > 0
      ::nColPos := ::nFreeze + 1
      ::DrawSuper()
      ::nColPos := nColPos
   EndIf

   If ::lDrawHeaders
      ::nRowPos := Max( 1, ::nRowPos )
      ::DrawHeaders()
   EndIf

   If ::lIsDbf .and. ::lPainted .and. ! ::lFocused .and. Select( ::cAlias ) > 0 .and. ;
      ( ::cAlias )->( RecNo() ) != ::nLastPos

      If ::bTagOrder != Nil .and. ::uLastTag != Nil
         uTag := ( ::cAlias )->( Eval( ::bTagOrder ) )
         ( ::cAlias )->( Eval( ::bTagOrder, ::uLastTag ) )
      EndIf

      nRecNo := ( ::cAlias )->( RecNo() )
      ( ::cAlias )->( DbGoTo( ::nLastPos ) )

   EndIf

   If ::lAppendMode .and. ::lFilterMode
      Eval( ::bGoBottom )
   EndIf

   ::Skip( 1 - ::nRowPos )

   If ::lIsArr
      lAppendMode   := ::lAppendMode
      ::lAppendMode := .F.
   EndIf

   ::nLastPainted := 0

   While nI <= nLines .and. nSkipped == 1

      If ::nRowPos == nI
         ::DrawSelect()
      Else
         ::DrawLine( nI )
      EndIf

      ::nLastPainted := nI
      nSkipped := ::Skip( 1 )

      If nSkipped == 1
         nI++
      EndIf
   EndDo
   ::nLenPos:=nI  //JP 1.31
   If ::lIsArr
      ::lAppendMode := lAppendMode
   EndIf

   If ::lAppendMode
      nI := Max( 1, --nI )
   EndIf

   ::Skip( ::nRowPos - nI )

   If ::nLen < ::nRowPos
      ::nRowPos := ::nLen
   EndIf

   If ::lAppendMode .and. ::nLen == ::nRowPos .and. ::nRowPos < nLines
      ::DrawLine( ++ ::nRowPos )
   EndIf

   If ! ::lPainted
      If ::bChange != Nil .and. ! ::lPhantArrRow
         Eval( ::bChange, Self, 0 )
      EndIf

      If ::lIsDbf .and. ! ::lNoResetPos

         If ::bTagOrder != Nil
            ::uLastTag := ( ::cAlias )->( Eval( ::btagOrder ) )
         EndIf

         ::nLastPos := ( ::cAlias )->( RecNo() )
      EndIf

      If ::lCanAppend .and. ::lHasFocus .and. ! ::lAppendMode .and. ::nLen == 0
         ::lHitBottom := .T.
         ::PostMsg( WM_KEYDOWN, VK_DOWN, 0 )
      Else
         ::lNoPaint := .T.
      EndIf
   EndIf

   ::lPainted := .T.

   If nRecNo != Nil

      If uTag != Nil
         ( ::cAlias )->( Eval( ::bTagOrder, uTag ) )
      EndIf

      ( ::cAlias )->( DbGoTo( nRecNo ) )
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:PanEnd() Version 9.0 Nov/30/2009
* ============================================================================

METHOD PanEnd() CLASS TSBrowse

   Local nI, nTxtWid, ;
         nWidth   := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ), ;
         nWide    := 0, ;
         nCols    := Len( ::aColumns )

   ::nOldCell := ::nCell

   If ::lIsTxt
      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != nil, ::hFont, 0 ) ) )
      ::nAt := ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
      ::Refresh( .F. )

      If ! ::lNoHScroll .and. ::oHScroll != Nil
         ::oHScroll:setPos( ::nAt )
      EndIf

      Return Self
   EndIf

   ::nColPos := nCols
   ::nCell := nCols
   nWide := ::aColSizes[nCols]

   For nI := nCols - 1 To 1 Step - 1
      If nWide + ::aColSizes[nI] <= nWidth
         nWide += ::aColSizes[nI]
         ::nColPos--
      Else
         Exit
      EndIf
   Next

   If ::lCellBrw

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      ::nOldCell := ::nCell

   EndIf

   ::Refresh( .F. )

   If ! ::lNoHScroll .and. ::oHScroll != Nil
      If ::oHScroll:nMax != nCols
         ::oHScroll:SetRange( 1, nCols )
      EndIf
      ::oHScroll:GoBottom()
   EndIf

   ::HiliteCell( nCols )

Return Self

* ============================================================================
* METHOD TSBrowse:PanHome() Version 9.0 Nov/30/2009
* ============================================================================

METHOD PanHome() CLASS TSBrowse

   Local nColChk, nEle

   ::nOldCell := ::nCell

   If ::lIsTxt

      ::nAt := 1
      ::Refresh( .F. )

      If ::oHScroll != Nil
         ::oHScroll:setPos( ::nAt )
      EndIf

      Return Self
   EndIf

   For nEle := 1 To Len( ::aColumns )
      If ! ::aColumns[ nEle ]:lNoHilite
         nColChk := nEle
         Exit
      EndIf
   Next

   ::nColPos := 1
   ::nCell := nColChk

   If ::lCellBrw

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      ::nOldCell := ::nCell

   EndIf

   If ! ::lEditing
      ::Refresh( .F. )
   Else
      ::Paint()
   EndIf

   If ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   EndIf

   ::HiliteCell( ::nCell )

Return Self

* ============================================================================
* METHOD TSBrowse:PanLeft() Version 9.0 Nov/30/2009
* ============================================================================

METHOD PanLeft() CLASS TSBrowse

   Local nI,;
         nWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ),;
         nWide := 0,;
         nCols := Len( ::aColumns ),;
         nPos := ::nColPos,;
         nFirst := If( ::lLockFreeze .and. ::nFreeze > 0, ::nFreeze + 1, 1 )

   ::nOldCell := ::nCell

   If ::lIsTxt

      If ::nAt > 11
         ::nAt := ::nAt - 10
      Else
         ::nAt := 1
      EndIf
      If ::oHScroll != Nil
         ::oHScroll:SetPos( ::nAt )
      EndIf
      ::Refresh( .F. )
      Return Self
   EndIf

   If ::nFreeze >= nCols
      Return Self
   EndIf

   AEval( ::aColSizes, { | nSize | nWide += nSize } )

   If  nWide <= nWidth                           // browse fits all inside
      ::nCell := nFirst                          // window or dialog
      ::nColPos := 1
   Else
      nWide := ::aColSizes[nPos]
      For nI := nPos - 1 To nFirst Step - 1
         If nWide <= nWidth
            nWide += ::aColSizes[ nI ]
            ::nCell := nI
         Else
            Exit
         EndIf
      Next
      ::nColPos := ::nCell                       // current column becomes first in offset
   EndIf

   If ! ::lCellBrw .and. ! ::lLockFreeze .and. ;  // for frozen columns
         ::nFreeze > 0 .and. ::nCell - 1 == 1
      ::nCell := ::nColPos := ::nFreeze
   EndIf

   If ::nCell != ::nOldCell
      ::Refresh( .F. )
   EndIf

   If ::lCellBrw

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      ::nOldCell := ::nCell

   EndIf

   If ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   EndIf

   If ::lCellBrw
      ::HiliteCell( ::nCell )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:PanRight() Version 9.0 Nov/30/2009
* ============================================================================

METHOD PanRight() CLASS TSBrowse

   Local nTxtWid, nI,;
         nWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ),;
         nWide := 0,;
         nCols := Len( ::aColumns ),;
         nPos := ::nColPos

   ::nOldCell := ::nCell

   If ::lIsTxt

      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != nil, ::hFont, 0 ) ) )

      If ::nAt < ::oTxtFile:nMaxLineLength - 21 - Int( nWidth / nTxtWid )
         ::nAt := ::nAt + 20
      Else
         ::nAt := ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
      EndIf

      If ::oHScroll != Nil
         ::oHScroll:SetPos( ::nAt )
      EndIf

      ::Refresh( .F. )
      Return Self
   EndIf

   If ::nFreeze >= nCols
      Return Self
   EndIf

   AEval( ::aColSizes, {|nSize| nWide += nSize }, nPos )

   If ::nFreeze > 0
      AEval( ::aColSizes, {|nSize| nWide += nSize }, 1, ::nFreeze )
   EndIf

   If nWide <= nWidth     // we're in last columns (including the current one),
      ::nCell := nCols    // so just ::nCell changes, not ::nColPos
   Else
      nWide := 0
      AEval( ::aColSizes, {|nSize| nWide += nSize }, nPos + 1 )

      If ::nFreeze > 0
         AEval( ::aColSizes, {|nSize| nWide += nSize }, 1, ::nFreeze )
      EndIf

      If nWide <= nWidth .and. nPos < nCols      // the remaining columns are added
         ::nCell := nPos + 1                     // the last in the browse
         nPos := nCols                           // so as to avoid For..Next
      EndIf

      nWide := ::aColSizes[nPos]

      For nI := nPos + 1 To nCols
         If ( nWide + ::aColSizes[nI] <= nWidth ) .or. ;
               ( nI - nPos < 2 .and. nWide + ::aColSizes[nI] > nWidth )  // two consecutive very wide columns
            nWide += ::aColSizes[nI]
            ::nCell := nI
         Else
            Exit
         EndIf
      Next
      ::nColPos := ::nCell                       // last column becomes first in offset
   EndIf

   If ! ::lCellBrw .and. ;                       // for frozen columns
      If( ::nFreeze > 0, ::IsColVis2( nCols ), ::IsColVisible( nCols ) )

      ::nCell := nCols

   EndIf

   If ::nCell != ::nOldCell
      ::Refresh( .F. )
   EndIf

   If ::lCellBrw

      If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      EndIf

      If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      EndIf

      ::nOldCell := ::nCell

   EndIf

   If ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   EndIf

   ::HiliteCell( ::nCell )

Return Self

* ============================================================================
* METHOD TSBrowse:Proper() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Proper( cString ) CLASS TSBrowse

   Local nPos, cChr, cTxt, cAnt, ;
         nLen := Len( cString )

   cString := Lower( Trim( cString ) ) + " "

   nPos := 1
   cAnt := "."
   cTxt := ""

   While nPos <= Len( cString )
      cChr := SubStr( cString, nPos, 1 )
      cTxt += If( cAnt $ '".,-/ (', Upper( cChr ), If( Asc( cChr ) == 209, Chr( 241 ), cChr ) )
      cAnt := cChr
      nPos++
   EndDo

   cTxt := StrTran( cTxt, ::aMsg[ 51 ], Lower( ::aMsg[ 51 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 52 ], Lower( ::aMsg[ 52 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 53 ], Lower( ::aMsg[ 53 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 54 ], Lower( ::aMsg[ 54 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 55 ], Lower( ::aMsg[ 55 ] ) )

Return PadR( cTxt, nLen )

* ============================================================================
* METHOD TSBrowse:PostEdit() Version 9.0 Nov/30/2009
* ============================================================================

METHOD PostEdit( uTemp, nCol, bValid ) CLASS TSBrowse

   Local aMoveCell, bRecLock, bAddRec, cAlias, uRet, ;
         nLastKey := ::oWnd:nLastKey, ;
         lAppend  := ::lAppendMode

   cAlias := If( ::lIsDbf .and. ::aColumns[ nCol ]:cAlias != Nil, ::aColumns[ nCol ]:cAlias, ::cAlias )

   aMoveCell := { {|| ::GoRight() }, {|| ::GoDown() }, {|| ::GoLeft() },  {|| ::GoUp() }, {|| ::GoNext() } }

   bRecLock := If( ! Empty( ::bRecLock ), ::bRecLock, {|| ( cAlias )->( RLock() ) } )

   bAddRec := If( ! Empty( ::bAddRec ), ::bAddRec, {|| ( cAlias )->( dbAppend() ), ! NetErr() } )

   If bValid != Nil

      uRet := Eval( bValid, uTemp, Self )

      If ValType( uRet ) == "B"
         uRet := Eval( uRet, uTemp, Self )
      EndIf

      If ! uRet

         Tone( 500, 1 )
         ::lEditing  := ::lPostEdit := ::lNoPaint := .F.

         If lAppend
            ::lAppendMode := .F.
            ::lHitBottom  := .F.
            ::GoBottom()
            ::HiliteCell( nCol )
            lNoAppend := .T.
            ::lCanAppend := .F.
         Else
            ::DrawSelect()
         EndIf

         Return Nil

      EndIf

   EndIf

   If ::lIsDbf

      If Eval( If( ! ::lAppendMode, bRecLock, bAddRec ), uTemp )

         Eval( ::aColumns[ nCol ]:bData, uTemp, Self )
         SysRefresh()

         If lAppend

            If ! Empty( ::aDefault )
               ASize( ::aDefault, Len( ::aColumns ) )
               AEval( ::aDefault, { | e, n | If( e != Nil .and. n != nCol, If( Valtype( e ) == "B", ;
                      Eval( ::aColumns[ n ]:bData, Eval( e, Self ) ), ;
                      Eval( ::aColumns[ n ]:bData, e ) ), Nil ) } )
               ::DrawLine()
            EndIf
#ifdef _TSBFILTER7_
            If ::lFilterMode .and. ::aColumns[ nCol ]:lIndexCol

               If &( ( cAlias )->( IndexKey() ) ) >= ::uValue1 .and. ;
                  &( ( cAlias )->( IndexKey() ) ) <= ::uValue2

                  ::nLen := ( cAlias )->( Eval( ::bLogicLen() ) )
                  ::nRowPos := ::nAt := Min( ::nRowCount, ::nLen )
               Else
                  ::lChanged := .F.
                  ( cAlias )->( DbGoTo( ::nPrevRec ) )
                  ::Refresh( .F. )
               EndIf

            Else
               ::nLen++
            EndIf
#else
            ::nLen++
#endif
            ::lAppendMode := .F.

            If ::nRowPos == 0 .and. ::lDrawHeaders
               ::nRowPos := ::nAt := 1
            EndIf

            If ::oVScroll != Nil
               ::oVScroll:SetRange( 1, Max( 1, ::nLen ) )
               ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
            EndIf

            ::DrawLine( ::nRowPos )
         EndIf

         If ::aColumns[ nCol ]:bPostEdit != Nil
            Eval( ::aColumns[ nCol ]:bPostEdit, uTemp, Self, lAppend )
         EndIf

         ::lEditing  := .F.
         ::lPostEdit := .F.
         ::lUpdated  := .T.
         if !("SQL" $ ::cDriver)
            ( cAlias )->( DbUnLock() )
         endif

         If lAppend
            If ::bChange != Nil
               Eval( ::bChange, Self, ::oWnd:nLastKey )
            EndIf

            lAppend := .F.
            AEval( ::aColumns, { |oC| lAppend := If( oC:lIndexCol, .T., lAppend ) } )
         EndIf

         If ( ::aColumns[ nCol ]:lIndexCol .and. ::lChanged ) .or. lAppend
            ::lNoPaint := .F.
#ifdef _TSBFILTER7_
            If ::lFilterMode

               If &( ( cAlias )->( IndexKey() ) ) >= ::uValue1 .and. ;
                  &( ( cAlias )->( IndexKey() ) ) <= ::uValue2

                  ::UpStable()

               Else
                  ::Reset()
               EndIf

            Else
               ::UpStable()
            EndIf
#else
            ::UpStable()
#endif
         EndIf

         ( cAlias )->( DbSkip( 0 ) )  // refresh relations just in case that a relation field changes

         ::SetFocus()

         If nLastKey == VK_UP
            ::GoUp()
         ElseIf nLastkey == VK_RIGHT
            ::GoRight()
         ElseIf nLastkey == VK_LEFT
            ::GoLeft()
         ElseIf nLastkey == VK_DOWN
            ::GoDown()
            ::Refresh( .F. )
         ElseIf ::aColumns[ nCol ]:nEditMove >= 1 .and. ::aColumns[ nCol ]:nEditMove <= 5  // excel-like behavior post-edit movement
            Eval( aMoveCell[ ::aColumns[ nCol ]:nEditMove ] )
            ::DrawSelect()
            If ! ::lAppendMode
               ::Refresh( .F. )
            EndIf
         ElseIf ::aColumns[ nCol ]:nEditMove == 0 .and. ! ::lAutoEdit
            ::DrawSelect()
         EndIf

         ::oWnd:nLastKey := Nil

         If ::lAutoEdit .and. ! lAppend
            SysRefresh()

            If ! ::aColumns[ ::nCell ]:lCheckBox
               ::PostMsg( WM_KEYDOWN, VK_RETURN, nMakeLong( 0, 0 ) )
            EndIf

            Return Nil
         EndIf

      Else
         If ! lAppend .and. Empty( ::bRecLock )
            MsgStop( ::aMsg[ 3 ], ::aMsg[ 4 ] )
         ElseIf lAppend .and. Empty( ::bAddRec )
            MsgStop( ::aMsg[ 5 ], ::aMsg[ 4 ] )
         EndIf
      EndIf
   Else
      If lAppend .and. ::lIsArr
         // when ::aDefValue[1] == Nil, it flags this element
         // as the equivalent of the "record no" for the array
         // this is why ::aDefValue will have one more element
         // than Len( ::aArray )
         ::lAppendMode := .F.
         AAdd( ::aArray, Array( Len( ::aDefValue ) - If( ::aDefValue[ 1 ] == Nil, 1, 0 ) ) )
         ::nAt := ::nLen := Len( ::aArray )

         If ::oVScroll != Nil
            ::oVScroll:SetRange( 1, Max( 1, ::nLen ) )
            ::oVScroll:GoBottom()
         EndIf

         AEval( ATail( ::aArray ), ;
                { | uVal, n | ::aArray[ ::nAt, n ] := ::aDefValue[ n + If( ::aDefValue[ 1 ] == Nil, 1, 0 ) ],HB_SYMBOL_UNUSED( uVal ) } )

      EndIf

      Eval( ::aColumns[ nCol ]:bData, uTemp )
      SysRefresh()

      If ::aColumns[ nCol ]:bPostEdit != Nil
         Eval( ::aColumns[ nCol ]:bPostEdit, uTemp, Self, lAppend )
      EndIf

      ::lEditing  := .F.
      ::lPostEdit := .F.

      If lAppend
         If ! Empty( ::aDefault )
            ASize( ::aDefault, Len( ::aColumns ) )
            AEval( ::aDefault, { | e, n | If( e != Nil .and. n != nCol, If( Valtype( e ) == "B", ;
                   Eval( ::aColumns[ n ]:bData, Eval( e, Self ) ), Eval( ::aColumns[ n ]:bData, e ) ), Nil ) } )
         EndIf
         ::DrawLine()
      EndIf

      If lAppend .and. ::nLen <= ::nRowCount()
         ::Refresh( .T. )
         ::nRowPos := Min( ::nRowCount(), ::nLen )
      EndIf

      If lAppend .and. ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      EndIf

      ::SetFocus()

      If nLastKey == VK_UP
         ::GoUp()
      ElseIf nLastkey == VK_RIGHT
         ::GoRight()
      ElseIf nLastkey == VK_LEFT
         ::GoLeft()
      ElseIf nLastkey == VK_DOWN
         ::GoDown()
         ::Refresh( .F. )
      ElseIf ::aColumns[ nCol ]:nEditMove >= 1 .and. ::aColumns[ nCol ]:nEditMove <= 5  // excel-like behaviour post-edit movement
         Eval( aMoveCell[ ::aColumns[ nCol ]:nEditMove ] )
      ElseIf ::aColumns[ nCol ]:nEditMove == 0
         ::DrawSelect()
      EndIf

      ::oWnd:nLastKey := Nil

      If ::lAutoEdit .and. ! lAppend
         SysRefresh()
         If ! ::aColumns[ ::nCell ]:lCheckBox
            ::PostMsg( WM_KEYDOWN, VK_RETURN, nMakeLong( 0, 0 ) )
         EndIf
      Endif

   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:RButtonDown() Version 9.0 Nov/30/2009
* ============================================================================

METHOD RButtonDown( nRowPix, nColPix, nFlags ) CLASS TSBrowse

   Local nRow, nCol, nSkipped, bRClicked, lNoEdit, lHeader, lFooter, lSpecHd, ;
         uPar1 := nRowPix, ;
         uPar2 := nColPix

   HB_SYMBOL_UNUSED( nFlags )

   Default ::lNoPopup    := .T., ;
           ::lNoMoveCols := .F.

   ::lNoPaint := .F.

   ::SetFocus()
   ::oWnd:nLastKey := 0

   If ::nLen < 1
      Return 0
   EndIf

   nRow    := ::GetTxtRow( nRowPix )
   nCol    := ::nAtCol( nColPix )
   lHeader := nRow == 0
   lFooter := nRow == -1
   lSpecHd := nRow == -2
   lNoEdit := ! ::aColumns[ nCol ]:lEdit

   If nRow > 0

      If ::lPopupActiv
         _ShowControlContextMenu( ::cControlName, ::cParentWnd, .f. )
      EndIf

      If ::lDontChange
         Return 0
      EndIf

      If nCol <= ::nFreeze .and. ::lLockFreeze
         Return 0
      EndIf

      If ::lNoMoveCols
         Return 0
      EndIf

      ::ResetSeek()
      ::DrawLine()

      nSkipped  := ::Skip( nRow - ::nRowPos )
      ::nRowPos += nSkipped
      ::nCell := nCol

      If ! ::lNoVScroll
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      EndIf

      If ! ::lNoHScroll
         ::oHScroll:SetPos( ::nCell )
      EndIf

      If nSkipped != 0 .and. ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      EndIf

      If ::lCellBrw

         If ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
            Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
         EndIf

         If ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
            Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
         EndIf

         ::nOldCell := ::nCell
         ::HiliteCell( ::nCell )

      EndIf

      ::DrawSelect()
      bRClicked := If( ::aColumns[ nCol ]:bRClicked != Nil, ;
                       ::aColumns[ nCol ]:bRClicked, ::bRClicked )

      If bRClicked != Nil
         Eval( bRClicked, uPar1, uPar2, ::nAt, Self )
      EndIf
      Return 0

   ElseIf lHeader
      If ::lPopupActiv
         if ::lPopupUser
            if  AScan( ::aPopupCol, nCol ) > 0 .or. ::aPopupCol[1] == 0
               if ::nPopupActiv == nCol
                  _ShowControlContextMenu( ::cControlName, ::cParentWnd, .t. )
               else
                  if ::bUserPopupItem != Nil
                     Eval( ::bUserPopupItem, nCol )
                     ::nPopupActiv := nCol
                  endif
               endif
            else
               _ShowControlContextMenu( ::cControlName, ::cParentWnd, .f. )
            endif
         else
            _ShowControlContextMenu( ::cControlName, ::cParentWnd, .t. )
         endif
      EndIf

      If ::aColumns[ nCol ]:bHRClicked != Nil
         Eval( ::aColumns[ nCol ]:bHRClicked, uPar1, uPar2, ::nAt, Self )
      EndIf
   ElseIf lSpecHd
      If ::aColumns[ nCol ]:bSRClicked != Nil
         Eval( ::aColumns[ nCol ]:bSRClicked, uPar1, uPar2, ::nAt, Self )
      EndIf
   ElseIf lFooter
      If ::aColumns[ nCol ]:bFRClicked != Nil
         Eval( ::aColumns[ nCol ]:bFRClicked, uPar1, uPar2, ::nAt, Self )
      EndIf
   EndIf

   If nCol <= ::nFreeze .or. ::lNoPopup
      Return 0
   EndIf

   if ::lPopupUser
      IF ::bUserPopupItem != Nil
         IF ! ::lPopupActiv
            If  AScan( ::aPopupCol, nCol ) > 0 .or. ::aPopupCol[1] == 0
               _DefineControlContextMenu( ::cControlName, ::cParentWnd )

               EVAL( ::bUserPopupItem, nCol )

               END MENU
               ::nPopupActiv := nCol
               ::lPopupActiv := .T.
            endif
         endif
      endif
   else
      IF ! ::lPopupActiv
         _DefineControlContextMenu( ::cControlName, ::cParentWnd )
         If ::lUnDo
            MENUITEM ::aMsg[ 6 ] + Space( 1 ) + ::aClipBoard[ 3 ] ;
            ACTION {|| ::InsColumn( ::aClipBoard[ 2 ], ;
                                  ::aClipBoard[ 1 ] ), ;
                                  ::nCell := ::aClipBoard[ 2 ], ::Refresh( .T. ), ;
                                  ::aClipBoard := Nil, ::lUnDo := .F. } NAME M_UNDO
         Else
            MENUITEM ::aMsg[ 6 ] ACTION Nil DISABLED NAME M_UNDO
         EndIf
         MENUITEM ::aMsg[ 7 ]  ;
            ACTION {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 12 ] } } NAME M_COPY

         MENUITEM ::aMsg[ 8 ]  ;
            ACTION {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 13 ] }, ;
                     ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. }  NAME M_CUT
         If ::aClipBoard != Nil .and. ::aClipBoard[ 3 ] != ::aMsg[ 12 ]
            MENUITEM ::aMsg[ 9 ] ;
               ACTION {|| ::InsColumn( nCol, ::aClipBoard[ 1 ] ), ::nCell := nCol, ::Refresh( .T. ), ;
                        ::aClipBoard := Nil, ::lUnDo := .F. } NAME M_PASTE
         Else
            MENUITEM ::aMsg[ 9 ] ACTION Nil DISABLED NAME M_PASTE
         EndIf
         SEPARATOR

         MENUITEM ::aMsg[ 10 ]  ;
         ACTION  {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 11 ] }, ;
                  ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. } NAME M_DEL

         END MENU
         ::lPopupActiv := .T.
      ELSE
         If ::lUnDo
           _ModifyMenuItem ( "M_UNDO" , ::cParentWnd ,::aMsg[ 6 ] + Space( 1 ) + ::aClipBoard[ 3 ] ,;
                           {|| ::InsColumn( ::aClipBoard[ 2 ], ;
                                  ::aClipBoard[ 1 ] ), ;
                                  ::nCell := ::aClipBoard[ 2 ], ::Refresh( .T. ), ;
                                  ::aClipBoard := Nil, ::lUnDo := .F. }, "M_UNDO", "" )
           _EnableMenuItem ( "M_UNDO" , ::cParentWnd )
         Else
           _ModifyMenuItem ( "M_UNDO" , ::cParentWnd ,::aMsg[ 6 ],Nil,"M_UNDO","" )
           _DisableMenuItem ( "M_UNDO" , ::cParentWnd )
         EndIf
         _ModifyMenuItem ( "M_COPY" , ::cParentWnd ,::aMsg[ 7 ],;
           {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 12 ] } },"M_COPY","" )
         _ModifyMenuItem ( "M_CUT" , ::cParentWnd ,::aMsg[ 8 ],;
           {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 13 ] }, ;
                     ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. },"M_CUT","" )
         If ::aClipBoard != Nil .and. ::aClipBoard[ 3 ] != ::aMsg[ 12 ]
           _ModifyMenuItem ( "M_PASTE" , ::cParentWnd ,::aMsg[ 9 ], ;
               {|| ::InsColumn( nCol, ::aClipBoard[ 1 ] ), ::nCell := nCol, ::Refresh( .T. ), ;
                        ::aClipBoard := Nil, ::lUnDo := .F. },"M_PASTE","" )
           _EnableMenuItem ( "M_PASTE" , ::cParentWnd )
         Else
           _ModifyMenuItem ( "M_PASTE" , ::cParentWnd ,::aMsg[ 9 ], Nil ,"M_PASTE","" )
           _DisableMenuItem ( "M_PASTE" , ::cParentWnd )
         EndIf
         _ModifyMenuItem ( "M_DEL" , ::cParentWnd ,::aMsg[ 10 ],;
           {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 11 ] }, ;
                  ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. },"M_DEL","" )
      ENDIF
   endif
Return 0

* ============================================================================
* METHOD TSBrowse:Refresh() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Refresh( lPaint, lRecount ) CLASS TSBrowse

   Default lPaint   := .T., ;
           lRecount := .F.

   If ::lFirstPaint == Nil .or. ::lFirstPaint
      Return 0
   EndIf

   If lRecount .or. Empty( ::nLen )
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   EndIf

   ::lNoPaint := .F.

Return ::Super:Refresh( lPaint )

* ============================================================================
* METHOD TSBrowse:RelPos() Version 9.0 Nov/30/2009
* Calculates the relative position of vertical scroll box in huge databases
* ============================================================================

METHOD RelPos( nLogicPos ) CLASS TSBrowse

   Local nRet

   If ::nLen > MAX_POS
      nRet := Int( nLogicPos * ( MAX_POS / ::nLen ) )
   Else
      nRet := nLogicPos
   EndIf

Return nRet

* ============================================================================
* METHOD TSBrowse:Report() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Report( cTitle, aCols, lPreview, lMultiple, lLandscape, lFromPos, aTotal ) CLASS TSBrowse

   Local nI, nRecNo, nSize, cAlias, ;
         aHeader1 := {}, ;
         aHeader2 := {}, ;
         aFields  := {}, ;
         aWidths  := {}, ;
         aFormats := {}, ;
         hFont    := ::hFont
#ifdef _TSBFILTER7_
   Local cFilterBlock
#endif

   Default cTitle     := ::oWnd:GetText(), ;
           lPreview   := .T., ;
           lMultiple  := .F., ;
           lLandscape := .F., ;
           lFromPos   := .F.

   ::lNoPaint := .F.

   If aCols == Nil

      aCols := {}

      For nI := 1 To Len( ::aColumns )
         AAdd( aCols, nI )
      Next

   EndIf

   If aTotal == Nil
      aTotal := AFill( Array( Len(aCols) ), .F. )
   Else
      If Len( aTotal ) <> Len( aCols )
         ASize( aTotal, Len(aCols) )
      EndIf
      For nI := 1 To Len( aCols )
         If aTotal[nI] == Nil
           aTotal[nI] := .F.
         EndIf
      Next
   EndIf

   If ::lIsDbf
      nRecNo := ( ::cAlias )->( RecNo() )
      cAlias := ::cAlias
   EndIf

   if lFromPos
      ::lNoResetPos := .F.
   else
      ::GoTop()
   endif
   Eval( ::bGoTop )

   For nI := If( ::lSelector, 2, 1 ) To Len( aCols )

      If ! ::aColumns[ aCols[ nI ] ]:lBitMap

         nSize := Max( 1, Round( ::aColSizes[ aCols[ nI ] ] / ;
                                 GetTextWidth( 0, "b", If( hFont != Nil, ;
                                                           hFont, ::hFont ) ), 0 ) )
         AAdd ( aWidths, nSize )
         AAdd ( aHeader1, "")
         AAdd ( aHeader2, ::aColumns[ aCols[ nI ] ]:cHeading )
         AAdd ( aFields , ::aColumns[ aCols[ nI ] ]:cData )
         AAdd ( aFormats, iif( ::aColumns[ aCols[ nI ] ]:cPicture != Nil, ::aColumns[ aCols[ nI ] ]:cPicture, '' ) ) // Nil or char.

      EndIf

   Next

#ifdef _TSBFILTER7_
   If ::lIsDbf .AND. ::lFilterMode

      cFilterBlock := BuildFiltr( ::cField, ::uValue1, ::uValue2, SELF )

      ( cAlias )->( DbSetFilter( &(cFilterBlock) , cFilterBlock ) )
      ( cAlias )->( DbGoTop() )

   EndIf
#endif

   If ::lIsDbf

      EasyReport ( cTitle +"|"+ ::aMsg[ 20 ] + Space( 1 ) + ;
         DToC( Date() ) + " - " + ::aMsg[ 22 ] + Space( 1 ) + Time() , ;
         aHeader1 , aHeader2 , ;
         aFields , aWidths , aTotal , ,.F. , lPreview ,,,,,, ;
         lMultiple ,,,     ;
         lLandscape ,,.t., ;
         cAlias ,,aFormats,;
         DMPAPER_A4 ,, .t. )

      ( ::cAlias )->( DbGoTo( nRecNo ) )
   EndIf

#ifdef _TSBFILTER7_
   If ::lIsDbf .AND. ::lFilterMode
      ( cAlias )->( DbClearFilter() )
   EndIf
#endif

   ::lHitTop := .F.
   ::SetFocus()

Return Self

* ============================================================================
* METHOD TSBrowse:Reset() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Reset( lBottom ) CLASS TSBrowse

   Local nMin, nMax, nPage

   Default lBottom := .F., ;
           ::lInitGoTop := .F.

   If ::lIsDbf
      ::nLen := ( ::cAlias )->( Eval( ::bLogicLen ) )
   Else
      ::nLen := Eval( ::bLogicLen )
   EndIf

   If ! ::lNoVScroll .and. ::oVScroll != Nil

      If ::nLen <= ::nRowCount()
         ::oVScroll:SetRange( 0, 0 )
      Else
         nMin  := Min( 1, ::nLen )
         nMax  := Min( ::nLen, MAX_POS )
         nPage := Min( ::nRowCount(), ::nLen )
         ::oVScroll:SetRange( nMin, nMax )
      EndIf

   EndIf

   ::lNoPaint := .F.
   ::lHitTop  := ::lHitBottom := .F.
   ::nColPos  := 1

   If lBottom
      ::GoBottom()
   ElseIf ::lInitGoTop
      ::GoTop()
   EndIf

   ::Refresh( .T., .T. )

   If ::bChange != Nil
      Eval( ::bChange, Self, 0 )
   EndIf

Return Self


* ============================================================================
* METHOD TSBrowse:ResetVScroll() Version 9.0 Nov/30/2009
* ============================================================================

METHOD ResetVScroll( lInit ) CLASS TSBrowse

   Local nMin, nMax, nPage, ;
         nLogicPos := ::nLogicPos()

   Default lInit := .F.

   If ::nLen <= ::nRowCount()
      nMin := nMax := 0
   Else
      nMin := Min( 1, ::nLen )
      nMax := Min( ::nLen, MAX_POS )
   EndIf

   If lInit .and. ! ::lNoVScroll

      If ::oVScroll == Nil
         nPage := Min( ::nRowCount(), ::nLen )
         ::oVScroll := TSBScrlBar ():WinNew( nMin, nMax, nPage, .T., Self )
      Else
         ::oVScroll:SetRange( nMin, nMax )
      EndIf

      ::oVScroll:SetPos( ::RelPos( nLogicPos ) )
   ElseIf ::oVScroll != Nil
      ::oVScroll:SetRange( nMin, nMax )
      ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:ResetSeek() Version 9.0 Nov/30/2009
* ============================================================================

METHOD ResetSeek() CLASS TSBrowse

   If ::nColOrder > 0
      If ::cOrderType == "D"
         ::cSeek := "  /  /    "
      Else
         ::cSeek := ""
      EndIf
   EndIf

   If ::bSeekChange != Nil
      Eval( ::bSeekChange )
   EndIf

   nNewEle := 0

Return ::cSeek

* ============================================================================
* METHOD TSBrowse:ReSize() Version 9.0 Nov/30/2009
* ============================================================================

METHOD ReSize( nSizeType, nWidth, nHeight ) CLASS TSBrowse

   Local nTotPix := 0

   If Empty( ::aColSizes )
      Return Nil
   EndIf

   AEval( ::aColumns, { | oCol | iif( oCol:lVisible, nTotPix += oCol:nWidth, Nil ) } )  // 14.07.2015

   If ::lEditing .and. ::aColumns[ ::nCell ]:oEdit != Nil .and. IsWindowHandle( ::aColumns[ ::nCell ]:oEdit:hWnd )
      SendMessage( ::aColumns[ ::nCell ]:oEdit:hWnd, WM_KEYDOWN, VK_ESCAPE, 0 )
   EndIf

   If ! Empty( ::nAdjColumn )
      ::nAdjColumn := Min( Len( ::aColumns ), ::nAdjColumn )
   EndIf

   ::nRowPos := Min( ::nRowPos, Max( ::nRowCount(), 1 ) )

   If ! Empty( ::nAdjColumn ) .and. nTotPix != nWidth
      ::aColumns[ ::nAdjColumn ]:nWidth := ;
      ::aColSizes[ ::nAdjColumn ] += ( nWidth - nTotPix )
   EndIf

Return ::Super:ReSize( nSizeType, nWidth, nHeight )

* ============================================================================
* METHOD TSBrowse:Seek() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Seek( nKey ) CLASS TSBrowse

    Local nIdxLen, cPrefix, ;
          nLines    := ::nRowCount(), ;
          lFound    := .T., ;
          lEoF      := .F., ;
          lTrySeek  := .T., ;
          nRecNo    := 0, ;
          cSeek     := ::cSeek, ;
          xSeek     := cSeek

   If ( Seconds() - ::nLapsus ) > 3 .or. ( Seconds() - ::nLapsus ) < 0
      ::cSeek := cSeek := ""
   EndIf

   ::nLapsus := Seconds()
   cPrefix := If( ::cPrefix == Nil, "", If( ValType( ::cPrefix ) == "B", Eval( ::cPrefix, Self ), ::cPrefix ) )

   If ::nColOrder > 0 .and. ::lIsDbf
      lTrySeek := .T.

      If ::cOrderType == "C"
         nIdxLen := ( ::cAlias )->( Len( Eval( &( "{||" + IndexKey() + "}" ) ) ) )
      EndIf

      If nKey == VK_BACK
         If ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         Else
            cSeek := Left( cSeek, Len( cSeek ) - 1 )
         EndIf
      Else
         If ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         ElseIf ::cOrderType == "N"
            /* only  0..9, minus and dot*/
            If ( nKey >= 48 .and. nKey <= 57 ) .or. ( nKey >= 45 .or. ;
                 nKey <= 46 )
                cSeek += Chr( nKey )
            Else
               Tone( 500, 1 )
               lTrySeek := .F.
            EndIf
         ElseIf ::cOrderType == "C"
            If Len( cSeek ) < nIdxLen
               cSeek += If( ::lUpperSeek, Upper( Chr( nKey ) ), Chr( nKey ) )
            Else
               Tone( 500, 1 )
               lTrySeek := .F.
            EndIf
         EndIf
      EndIf

      If ::cOrderType == "C"
         xSeek := cPrefix + cSeek
      ElseIf ::cOrderType == "N"
         xSeek := Val( cSeek )
      ElseIf ::cOrderType == "D"
         xSeek := cPrefix + DToS( CToD( cSeek ) )
      Else
         xSeek := cPrefix + cSeek
      EndIf

      If ! ( ::cOrderType == "D" .and. Len( RTrim( cSeek ) ) < Len( DToC( Date() ) ) ) .and. lTrySeek

         nRecNo := ( ::cAlias )->( RecNo() )
         lFound := ( ::cAlias )->( DbSeek( xSeek, .T. ) )
         lEoF   := ( ::cAlias )->( Eof() )

         If lEoF .or. ( ::cOrderType == "C" .and. ! lFound )
           ( ::cAlias )->( DbGoTo( nRecNo ) )
         EndIf

         If ( ::cOrderType == "C" .and. ! lFound ) .or. lEof
            Tone( 500, 1 )

            If ::cOrderType == "D"
               ::cSeek := DateSeek( cSeek, VK_BACK )
            Else
               ::cSeek := Left( cSeek, Len( cSeek ) - 1 )
            EndIf

            Return Self

         ElseIf ! lFound

            If ::cOrderType == "N"
               ( ::cAlias )->( DbSeek( Val( cSeek ) * 10, .T. ) )
               xSeek := ( ::cAlias )->( Eval( &( "{||" + IndexKey() + "}" ) ) )
               xSeek := Val( Right( LTrim( Str( xSeek ) ), Len( cSeek ) + 1 ) )

               If xSeek > ( ( Val( cSeek ) * 10 ) + 9 )
                  Tone( 500, 1 )
                  ( ::cAlias )->( DbGoTo( nRecNo ) )
                  ::cSeek := Left( cSeek, Len( cSeek ) - 1 )
                  Return Self
               EndIf

            EndIf

            ::cSeek := cSeek
            ( ::cAlias )->( DbGoto( nRecNo ) )
            Return Self
         Else
            ::lHitBottom := ::lHitTop := .F.

            If nRecNo != ( ::cAlias )->( RecNo() ) .and. ::nLen > nLines
               nRecNo := ( ::cAlias )->( RecNo() )
               ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

               If ( ::cAlias )->( EoF() )
                  Eval( ::bGoBottom )
                  ::nRowPos := nLines

                  While ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
                     ::Skip( -1 )
                     ::nRowPos --
                  EndDo
               Else
                  ( ::cAlias )->( DbGoTo( nRecNo ) )
                  ::Upstable()
               EndIf

               ::Refresh( .F. )
               ::ResetVScroll()
            ElseIf nRecNo != ( ::cAlias )->( RecNo() )
               nRecNo := ( ::cAlias )->( RecNo() )
               Eval( ::bGoTop )
               ::nAt := ::nRowPos := 1

               While nRecNo != ( ::cAlias )->( RecNo() )
                  ::Skip( 1 )
                  ::nRowPos++
               EndDo

               ::Refresh( .F. )
               ::ResetVScroll()
            EndIf

            If ::bChange != Nil
               Eval( ::bChange, Self, 0 )
            EndIf
         EndIf
      EndIf

      ::cSeek := cSeek

      If ::bSeekChange != Nil
         Eval( ::bSeekChange )
      EndIf

   ElseIf ::nColOrder > 0 .and. ::lIsArr
      lTrySeek := .T.
      nIdxLen := Len( cValToChar( ::aArray[ ::nAt, ::nColOrder ] ) )

      If nKey == VK_BACK

         If ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         Else
            cSeek := Left( cSeek, Len( cSeek ) - 1 )
         EndIf
      Else
         If ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         ElseIf ::cOrderType == "N"
            /* only  0..9, minus and dot*/
            If ( nKey >= 48 .and. nKey <= 57 ) .or. ( nKey >= 45 .or. ;
                 nKey <= 46 )
                cSeek += Chr( nKey )
            Else
               Tone( 500, 1 )
               lTrySeek := .F.
            EndIf
         ElseIf ::cOrderType == "C"
            If Len( cSeek ) < nIdxLen
               cSeek += If( ::lUpperSeek, Upper( Chr( nKey ) ), Chr( nKey ) )
            Else
               Tone( 500, 1 )
               lTrySeek := .F.
            EndIf
         EndIf
      EndIf

      If ::cOrderType == "C"
         xSeek := cPrefix + cSeek
      ElseIf ::cOrderType == "N"
         xSeek := Val( cSeek )
      ElseIf ::cOrderType == "D"
         xSeek := cPrefix + DToS( CToD( cSeek ) )
      Else
         xSeek := cPrefix + cSeek
      EndIf

      If ! ( ::cOrderType == "D" .and. Len( RTrim( cSeek ) ) < Len( DToC( Date() ) ) ) .and. lTrySeek
         nRecNo := ::nAt
         lFound := lASeek( xSeek,, Self )

         If ! lFound
            ::nAt   := nRecNo
         EndIf

         If ::cOrderType == "C" .and. ! lFound
            Tone( 500, 1 )
            ::cSeek := Left( cSeek, Len( cSeek ) - 1 )
            Return Self
         ElseIf ! lFound
            If ::cOrderType == "N"
               lASeek( Val( cSeek ) * 10, .T., Self )
               xSeek := ::aArray[ ::nAt, ::nColOrder ]
               xSeek := Val( Right( LTrim( Str( xSeek ) ), Len( cSeek ) + 1 ) )

               If xSeek > ( ( Val( cSeek ) * 10 ) + 9 )
                  Tone( 500, 1 )
                  ::cSeek := Left( cSeek, Len( cSeek ) - 1 )
                  ::nAt := nRecNo
                  Return Self
               EndIf
            EndIf

            ::cSeek := cSeek
            ::nAt   := nRecNo
            Return Self
         Else
            If nRecNo != ::nAt .and. ::nLen > nLines
               nRecNo := ::nAt
               ::nAt += ( nLines - ::nRowPos )

               If ::nAt > ::nLen
                  Eval( ::bGoBottom )
                  ::nRowPos := nLines

                  While ::nRowPos > 1 .and. ::nAt != nRecNo
                     ::Skip( -1 )
                     ::nRowPos --
                  EndDo
               Else
                  ::nAt := nRecNo
               EndIf

               ::Refresh( .F. )
               ::ResetVScroll()
            ElseIf nRecNo != ::nAt
               nRecNo := ::nAt
               Eval( ::bGoTop )
               ::nAt := ::nRowPos := 1

               While nRecNo != ::nAt
                  ::Skip( 1 )
                  ::nRowPos++
               EndDo

               ::Refresh( .F. )
               ::ResetVScroll()
            EndIf

            If ::bChange != Nil
               Eval( ::bChange, Self, 0 )
            EndIf
         EndIf
      EndIf

      ::cSeek := cSeek

      If ::bSeekChange != Nil
         Eval( ::bSeekChange )
      EndIf
   EndIf

   If ! lTrySeek
      ::ResetSeek()
   EndIf

   If ::lIsArr .and. ::bSetGet != Nil
      If ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ElseIf ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      Else
         Eval( ::bSetGet, "" )
      EndIf
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:Set3DText() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Set3DText( lOnOff, lRaised, nColumn, nLevel, nClrLight, ;
                  nClrShadow ) CLASS TSBrowse

   Local nEle

   Default lOnOff     := .T., ;
           lRaised    := .T., ;
           nClrLight  := GetSysColor( COLOR_BTNHIGHLIGHT ), ;
           nClrShadow := GetSysColor( COLOR_BTNSHADOW )

   If Empty( ::aColumns )
      Return Self
   EndIf

   If ! lOnOff
      If Empty( nColumn )
         If Empty( nLevel )
            For nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextCell := Nil
               ::aColumns[ nEle ]:l3DTextHead := Nil
               ::aColumns[ nEle ]:l3DTextFoot := Nil
            Next
         ElseIf nLevel == 1
            For nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextCell := Nil
            Next
         ElseIf nLevel == 2
            For nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextHead := Nil
            Next
         Else
            For nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextFoot := Nil
            Next
         EndIf

      ElseIf Empty( nLevel )
         ::aColumns[ nColumn ]:l3DTextCell := Nil
         ::aColumns[ nColumn ]:l3DTextHead := Nil
         ::aColumns[ nColumn ]:l3DTextFoot := Nil
      ElseIf nLevel == 1
         ::aColumns[ nColumn ]:l3DTextCell := Nil
      ElseIf nLevel == 2
         ::aColumns[ nColumn ]:l3DTextHead := Nil
      Else
         ::aColumns[ nColumn ]:l3DTextFoot := Nil
      EndIf

      Return Self

   EndIf

   If Empty( nColumn )
      If Empty( nLevel )
         For nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextCell  := lRaised
            ::aColumns[ nEle ]:l3DTextHead  := lRaised
            ::aColumns[ nEle ]:l3DTextFoot  := lRaised
            ::aColumns[ nEle ]:nClr3DLCell  := nClrLight
            ::aColumns[ nEle ]:nClr3DLHead  := nClrLight
            ::aColumns[ nEle ]:nClr3DLFoot  := nClrLight
            ::aColumns[ nEle ]:nClr3DSCell  := nClrShadow
            ::aColumns[ nEle ]:nClr3DSHead  := nClrShadow
            ::aColumns[ nEle ]:nClr3DSFoot  := nClrShadow
         Next
      ElseIf nLevel == 1
         For nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextCell  := lRaised
            ::aColumns[ nEle ]:nClr3DLCell  := nClrLight
            ::aColumns[ nEle ]:nClr3DSCell  := nClrShadow
         Next
      ElseIf nLevel == 2
         For nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextHead  := lRaised
            ::aColumns[ nEle ]:nClr3DLHead  := nClrLight
            ::aColumns[ nEle ]:nClr3DSHead  := nClrShadow
         Next

      Else
         For nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextFoot  := lRaised
            ::aColumns[ nEle ]:nClr3DLFoot  := nClrLight
            ::aColumns[ nEle ]:nClr3DSFoot  := nClrShadow
         Next
      EndIf
   Else
      If Empty( nLevel )
         ::aColumns[ nColumn ]:l3DTextCell  := lRaised
         ::aColumns[ nColumn ]:l3DTextHead  := lRaised
         ::aColumns[ nColumn ]:l3DTextFoot  := lRaised
         ::aColumns[ nColumn ]:nClr3DLCell  := nClrLight
         ::aColumns[ nColumn ]:nClr3DLHead  := nClrLight
         ::aColumns[ nColumn ]:nClr3DLFoot  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSCell  := nClrShadow
         ::aColumns[ nColumn ]:nClr3DSHead  := nClrShadow
         ::aColumns[ nColumn ]:nClr3DSFoot  := nClrShadow
      ElseIf nLevel == 1
         ::aColumns[ nColumn ]:l3DTextCell  := lRaised
         ::aColumns[ nColumn ]:nClr3DLCell  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSCell  := nClrShadow
      ElseIf nLevel == 2
         ::aColumns[ nColumn ]:l3DTextHead  := lRaised
         ::aColumns[ nColumn ]:nClr3DLHead  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSHead  := nClrShadow
      Else
         ::aColumns[ nColumn ]:l3DTextFoot  := lRaised
         ::aColumns[ nColumn ]:nClr3DLFoot  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSFoot  := nClrShadow
      EndIf
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetAlign() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetAlign( nColumn, nLevel, nAlign ) CLASS TSBrowse

   Default nColumn := 0, ;
            nLevel := 0, ;
            nAlign := DT_LEFT

   If nColumn > 0
      If nLevel > 0
         Do Case
            Case nLevel == 1
               ::aColumns[ nColumn ]:nAlign  := nAlign
            Case nLevel == 2
               ::aColumns[ nColumn ]:nHAlign := nAlign
            Otherwise
               ::aColumns[ nColumn ]:nFAlign := nAlign
         EndCase
      Else
         ::aColumns[ nColumn ]:nAlign := ::aColumns[ nColumn ]:nHAlign := ;
         ::aColumns[ nColumn ]:nFAlign := nAlign
      EndIf
   Else
      If nLevel > 0
         AEval( ::aColumns, { | oCol | If( nLevel = 1, oCol:nAlign := nAlign, If( nLevel = 2, oCol:nHAlign := nAlign, ;
                                           oCol:nFAlign := nAlign ) ) } )
      Else
         AEval( ::aColumns, { | oCol | oCol:nAlign := nAlign, oCol:nHAlign := nAlign, oCol:nFAlign := nAlign } )
      EndIf
   EndIf

   If ::lPainted
      ::Refresh( .T. )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetAppendMode() Version 9.0 Nov/30/2009
* Enables append mode in TSBrowse for DBF's and arrays.
* At least one column in TSBrowse must have oCol:lEdit set to TRUE in order
* to work and like direct cell editing.
* ============================================================================

METHOD SetAppendMode( lMode ) CLASS TSBrowse

   Local lPrevMode := ::lCanAppend

   Default lMode    := ! ::lCanAppend, ;
           ::lIsTxt := "TEXT_" $ ::cAlias

   If ! ::lIsTxt
      ::lCanAppend := lMode
   EndIf

Return lPrevMode

* ============================================================================
* METHOD TSBrowse:SetArray() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetArray( aArray, lAutoCols, aHead, aSizes ) CLASS TSBrowse

   Local nColumns, nI, cType, nMax, bData, cHead, ;
         lListBox := Len( aArray ) > 0 .and. ValType( aArray[ 1 ] ) != "A"

   Default aArray    := {}, ;
           lAutoCols := ::lAutoCol, ;
           aHead     := ::aHeaders, ;
           aSizes    := ::aColSizes

   If lListBox
      ::aArray := {}

      For nI := 1 To Len( aArray )
         AAdd( ::aArray, { aArray[ nI ] } )
      Next
   Else
      ::aArray := aArray
   EndIf

   //            default values for array elements used during append mode
   //            The user MUST AIns() as element no. 1 to ::aDefValue
   //            a nil value when using the actual elemnt no (::nAt)
   //            when browsing arrays like this:
   //            AIns( ASize( ::aDefValue, Len( ::aDefValue ) + 1 ), 1 )
   //            AFTER calling ::SetArray()

   nColumns    := If( ! Empty( aHead ), Len( aHead ), If( ! Empty( ::aArray ), Len( ::aArray[ 1 ] ), 0 ) )
   ::aDefValue := Array( Len( aArray[ 1 ] ) )

   For nI := 1 To nColumns
      cType := ValType( ::aArray[ 1, nI ] )

      If cType $ "CM"
         ::aDefValue[ nI ] := Space( Len( ::aArray[ 1, nI ] ) )
      ElseIf cType == "N"
         ::aDefValue[ nI ] := 0
      ElseIf cType == "D"
         ::aDefValue[ nI ] := CToD( "" )
      ElseIf cType == "T"
   #ifdef __XHARBOUR__
         ::aDefValue[ nI ] := CToT( "" )
   #else
         ::aDefValue[ nI ] := HB_CTOT("")
   #endif
      ElseIf cType == "L"
         ::aDefValue[ nI ] := .F.
      Else                                // arrays, objects and codeblocks not allowed
         ::aDefValue[ nI ] := "???"       // not user editable data type
      EndIf
   Next

   ::nAt       := 1
   ::bKeyNo    := { |n| If( n == Nil, ::nAt, ::nAt := n ) }
   ::cAlias    := "ARRAY"  // don't change name, used in method Default()
   ::lIsArr    := .T.
   ::lIsDbf    := .F.         //JP V90
   ::nLen      := Eval( ::bLogicLen := { || Len( ::aArray ) + If( ::lAppendMode, 1, 0 ) } )
   ::lIsArr    := .T.
   ::bGoTop    := { || ::nAt := 1 }
   ::bGoBottom := { || ::nAt := Eval( ::bLogicLen ) }
   ::bSkip     := { |nSkip, nOld| nOld := ::nAt, ::nAt += nSkip, ::nAt := Min( Max( ::nAt, 1 ), ::nLen ), ::nAt - nOld }
   ::bGoToPos  := { |n| Eval( ::bKeyNo, n ) }
   ::bBof      := { || ::nAt < 1 }
   ::bEof      := { || ::nAt > Len( ::aArray ) }

   ::lHitTop    := .F.
   ::lHitBottom := .F.
   ::nRowPos    := 1
   ::nColPos    := 1
   ::nCell      := 1

   ::HiliteCell( 1 )
   lAutocols := If( lAutocols == Nil, ( ! Empty( aHead ) .and. ! Empty( aSizes ) ), lAutocols )

   If lAutoCols .and. Empty( ::aColumns ) .and. lListBox
      nMax := ( ::nRight - ::nLeft + 1 ) * If( Empty( ::hWnd ), 2, 1 )
      ::lDrawHeaders := .F.
      ::nLineStyle   := LINES_NONE
      ::lNoHScroll   := .T.
      ::AddColumn( TSColumn():New( Nil, ArrayWBlock( Self, 1 ),,,, nMax,, ::lEditable,,,,,,,,,,, Self, ;
                                   "ArrayWBlock(::oBrw,1)" ) )

   ElseIf lAutoCols .and. Empty( ::aColumns ) .and. ValType( ::aArray[ 1 ] ) == "A"
      If Empty( aHead )
         aHead := AutoHeaders( Len( ::aArray[ 1 ] ) )
      EndIf

      If aSizes != Nil .and. ValType( aSizes ) != "A"
         aSizes := AFill( Array( Len( ::aArray[ 1 ] ) ), nValToNum( aSizes ) )
      ElseIf ValType( aSizes ) == "A" .and. ! Empty( aSizes  )
         If Len( aSizes ) < nColumns
            nI := Len( aSizes ) + 1
            ASize( aSizes, nColumns )
            AFill( aSizes, aSizes[ 1 ], nI )
         EndIf
      Else
         aSizes := Nil
      EndIf

      For nI := 1 To nColumns

         bData := ArrayWBlock( Self, nI )
         cHead := cValToChar( aHead[ nI ] )

         If Empty( aSizes )
            nMax := Max( GetTextWidth( 0, cValToChar( EVal( bData ) ) ), GetTextWidth( 0, cHead ) )
            nMax := Max( nMax, 60 )
         Else
            nMax := aSizes[ nI ]
         EndIf

         ::AddColumn( TSColumn():New( cHead, bData,,,, nMax,, ::lEditable,,,,,,,,,,, Self, ;
                                      "ArrayWBlock(::oBrw," + LTrim( Str( nI ) ) + ")" ) )
      Next

   EndIf

   ::lNoPaint := .F.
   ::ResetVScroll( .T. )

   If ::lPainted
      ::GoTop()
      ::Refresh()
   EndIf

Return Self

* ============================================================================

METHOD SetArrayTo( aArray, uFontHF, aHead, aSizes, uFooter, aPicture, aAlign, aName ) CLASS TSBrowse

   Local nColumns, nI, cType, nMax, bData, cHead 
   Local nN, cData, aDefMaxVal, aDefMaxLen, aDefType, aDefAlign, aDefFooter, oCol, ; 
         nAlign, aAligns, lFooter := .F., cFooter, nFooter, cTemp, cPict, ; 
         hFont := If( ::hFont != Nil, ::hFont, 0 ), ; 
         lFont := ( hFont != 0 ), hFontHead := hFont, hFontFoot := hFont 

   Default aHead     := AClone(::aHeaders), ;             
           aSizes    := AClone(::aColSizes), ;   
           aPicture  := AClone(::aFormatPic), ; 
           aAlign    := If( ISARRAY(::aJustify), AClone(::aJustify), {} ), ; 
           aName     := {} 

   If ValType(uFontHF) == 'N' .and. uFontHF != 0 
      hFontHead := uFontHF 
      hFontFoot := uFontHF 
   ElseIf ValType(uFontHF) == 'A' .and. Len(uFontHF) >= 2 
      If ValType(uFontHF[1]) == 'N' .and. uFontHF[1] != 0 
         hFontHead := uFontHF[1] 
      EndIf 
      If ValType(uFontHF[2]) == 'N' .and. uFontHF[2] != 0 
         hFontFoot := uFontHF[2] 
      EndIf 
   EndIf 

   ::aArray      := aArray 
   ::lPickerMode := .F. 

   nColumns := If( ! Empty( aHead ), Len( aHead ), If( ! Empty( ::aArray ), Len( ::aArray[ 1 ] ), 0 ) )

   ::aDefValue := Array( Len( aArray[ 1 ] ) )

   aDefMaxVal  := Array(nColumns) 
   aDefType    := Array(nColumns) 
   aDefAlign   := Array(nColumns) 
   aDefMaxLen  := Array(nColumns) 

   aFill(aDefMaxLen, 0) 

   If Len(aPicture) != nColumns 
      ASize(aPicture, nColumns) 
   EndIf 

   If Len(aAlign) != nColumns 
      ASize(aAlign, nColumns) 
   EndIf 

   If Len(aName) != nColumns 
      ASize(aName, nColumns) 
   EndIf 

   For nI := 1 To nColumns 
      cType := ValType( ::aArray[ 1, nI ] ) 
      aDefType[ nI ] := cType 

      If cType $ "CM" 
         ::aDefValue[ nI ] := Space( Len( ::aArray[ 1, nI ] ) ) 
         aDefMaxVal [ nI ] := Trim( ::aArray[ 1, nI ] ) 
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] ) 
         aDefAlign  [ nI ] := DT_LEFT 
      ElseIf cType == "N" 
         ::aDefValue[ nI ] := 0 
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] ) 
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] ) 
         aDefAlign  [ nI ] := DT_RIGHT 
      ElseIf cType == "D" 
         ::aDefValue[ nI ] := CToD( "" ) 
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] ) 
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] ) 
         aDefAlign  [ nI ] := DT_CENTER 
      ElseIf cType == "T" 
#ifdef __XHARBOUR__ 
         ::aDefValue[ nI ] := CToT( "" ) 
#else 
         ::aDefValue[ nI ] := HB_CTOT("") 
#endif 
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] ) 
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] ) 
         aDefAlign  [ nI ] := DT_LEFT 
      ElseIf cType == "L" 
         ::aDefValue[ nI ] := .F. 
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] ) 
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] ) 
         aDefAlign  [ nI ] := DT_CENTER 
      Else                                // arrays, objects and codeblocks not allowed 
         ::aDefValue[ nI ] := "???"       // not user editable data type 
         aDefMaxVal [ nI ] := "???" 
         aDefMaxLen [ nI ] := 0 
         aDefAlign  [ nI ] := DT_LEFT 
      EndIf 
   Next 

   ::nAt       := 1 
   ::bKeyNo    := { |n| If( n == Nil, ::nAt, ::nAt := n ) }
   ::cAlias    := "ARRAY"     // don't change name, used in method Default() 
   ::lIsArr    := .T. 
   ::lIsDbf    := .F.
   ::nLen      := Eval( ::bLogicLen := { || Len( ::aArray ) + If( ::lAppendMode, 1, 0 ) } ) 
   ::lIsArr    := .T. 
   ::bGoTop    := { || ::nAt := 1 } 
   ::bGoBottom := { || ::nAt := Eval( ::bLogicLen ) } 
   ::bSkip     := { |nSkip, nOld| nOld := ::nAt, ::nAt += nSkip, ::nAt := Min( Max( ::nAt, 1 ), ::nLen ), ::nAt - nOld }
   ::bGoToPos  := { |n| Eval( ::bKeyNo, n ) }
   ::bBof      := { || ::nAt < 1 }
   ::bEof      := { || ::nAt > Len( ::aArray ) }

   ::lHitTop    := .F. 
   ::lHitBottom := .F. 
   ::nRowPos    := 1 
   ::nColPos    := 1 
   ::nCell      := 1 

   ::HiliteCell( 1 ) 

   aDefFooter := Array(nColumns) 
   aFill(aDefFooter, "") 

   If ValType(uFooter) == "L" 
      lFooter := uFooter  
   ElseIf ValType(uFooter) == "A" 
      lFooter := .T. 
      For nI := 1 To Min( nColumns, Len(uFooter) ) 
          aDefFooter[ nI ] := cValToChar(uFooter[ nI ]) 
      Next 
   EndIf 

   If Empty( aHead ) 
      aHead := AutoHeaders( Len( ::aArray[ 1 ] ) ) 
   EndIf 

   If aSizes != Nil .and. ValType( aSizes ) != "A" 
      aSizes := AFill( Array( Len( ::aArray[ 1 ] ) ), nValToNum( aSizes ) ) 
   ElseIf ValType( aSizes ) == "A" .and. ! Empty( aSizes  ) 
      If Len( aSizes ) < nColumns 
         nI := Len( aSizes ) + 1 
         ASize( aSizes, nColumns ) 
         AFill( aSizes, aSizes[ 1 ], nI ) 
      EndIf 
   Else 
      aSizes := Nil 
   EndIf 

   For nI := 1 To Len(::aArray) 
       For nN := 1 To nColumns 
           cData := cValToChar( ::aArray[ nI, nN ] ) 
           If len(cData) > len(aDefMaxVal[ nN ]) 
              If aDefType[ nN ] == "C" 
                 aDefMaxVal[ nN ] := Trim(cData) 
                 aDefMaxLen[ nN ] := Max( aDefMaxLen[ nN ], Len(aDefMaxVal[ nN ]) ) 
              Else 
                 aDefMaxVal[ nN ] := cData 
                 aDefMaxLen[ nN ] := Max( aDefMaxLen[ nN ], Len(cData) ) 
              EndIf 
           EndIf 
       Next 
   Next 

   ::aHeaders   := Array(nColumns) 
   ::aColSizes  := Array(nColumns) 
   ::aFormatPic := Array(nColumns) 
   ::aJustify   := Array(nColumns) 

   For nI := 1 To nColumns 

      bData  := ArrayWBlock( Self, nI ) 
      cHead  := cValToChar( aHead[ nI ] ) 
      nAlign := aDefAlign[ nI ] 
      cPict  := Nil 

      If aDefType[ nI ] == "C" 
         If ValType(aPicture[ nI ]) == "C" .and. Len(aPicture[ nI ]) > 0 
            cTemp := If( Left(aPicture[ nI ], 2) == "@K", SubStr(aPicture[ nI ], 4), aPicture[ nI ]) 
         Else 
            cTemp := Replicate( "X", aDefMaxLen[ nI ] )
         EndIf 
         If Len(cTemp) > Len(::aDefValue[ nI ]) 
            ::aDefValue[ nI ] := Space( Len( cTemp ) ) 
         EndIf 
         cPict := Replicate( "X", Len( ::aDefValue[ nI ] ) )
      ElseIf aDefType[ nI ] == "N" 
         If ValType(aPicture[ nI ]) == "C" 
            cPict := aPicture[ nI ] 
         Else 
            cPict := Replicate( "9", aDefMaxLen[ nI ] )
            If ( nN := At(".", aDefMaxVal[ nI ]) ) > 0 
               cTemp := SubStr( aDefMaxVal[ nI ], nN )
               cPict := Left( cPict, Len( cPict ) - Len( cTemp ) ) + "." + Replicate( "9", Len( cTemp ) - 1 )
            EndIf 
         EndIf 
      EndIf 

      If ValType(aAlign[ nI ]) == "N" .and. ( aAlign[ nI ] == DT_LEFT   .or. ; 
                                              aAlign[ nI ] == DT_CENTER .or. ; 
                                              aAlign[ nI ] == DT_RIGHT ) 
         nAlign := aAlign[ nI ] 
      EndIf 

      If lFooter 
         aAligns := { nAlign, DT_CENTER, nAlign } 
         cFooter := aDefFooter[ nI ] 
         If CRLF $ cFooter 
            cTemp := "" 
            AEval(hb_aTokens(cFooter, CRLF), {|x| cTemp := If( Len(x) > Len(cTemp), x, cTemp )}) 
         Else 
            cTemp := cFooter 
         EndIf 
         nFooter := GetTextWidth( 0, cTemp, hFontFoot ) 
      Else 
         aAligns := { nAlign, DT_CENTER } 
         cFooter := Nil 
         nFooter := 0 
      EndIf 

      If CRLF $ cHead 
         cTemp := "" 
         AEval(hb_aTokens(cHead, CRLF), {|x| cTemp := If( Len(x) > Len(cTemp), x, cTemp )}) 
      Else 
         cTemp := cHead 
      EndIf 

      nMax := Max( GetTextWidth( 0, aDefMaxVal[ nI ]+'W', hFont ), GetTextWidth( 0, cTemp, hFontHead ) ) 
      nMax := Max( nMax + GetBorderWidth(), 32 ) 
      nMax := Max( nMax, nFooter ) 

      If ! Empty( aSizes ) 
         If Valtype(aSizes[ nI ]) == 'N' .and. aSizes[ nI ] > 0 
            nMax := aSizes[ nI ] 
         ElseIf valtype(aSizes[ nI ]) == 'C' 
            nMax := GetTextWidth( 0, aSizes[ nI ], hFont ) 
         EndIf 
      EndIf 

      ::aHeaders  [ nI ] := cHead 
      ::aColSizes [ nI ] := nMax 
      ::aFormatPic[ nI ] := cPict 
      ::aJustify  [ nI ] := aAligns 

      oCol := TSColumn():New( cHead, bData, cPict,, aAligns, nMax,, ::lEditable,,,,cFooter,,,,,,, ; 
                              Self, "ArrayWBlock(::oBrw," + LTrim( Str( nI ) ) + ")" ) 
      If lFont 
         oCol:hFontHead := hFontHead 
         If lFooter 
            oCol:hFontFoot := hFontFoot 
         EndIf 
      EndIf 

      If aDefType[ nI ] == "L"
         oCol:lCheckBox := .T.
         oCol:nEditMove := 0
      EndIf

      If ! Empty(aName[ nI ]) .and. ValType(aName[ nI ]) == "C" 
         oCol:cName := aName[ nI ] 
      EndIf 

      ::AddColumn( oCol ) 
   Next 

   ::lNoPaint := .F. 
   ::ResetVScroll( .T. )

   If ::lPainted 
      ::GoTop() 
      ::Refresh() 
   EndIf 

Return Self 

* ============================================================================
* METHOD TSBrowse:SetBtnGet() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetBtnGet( nColumn, cResName, bAction, nBmpWidth ) CLASS TSBrowse

   Default nBmpWidth := 16

   nColumn := If( ValType( nColumn ) == "C", ::nColumn( nColumn ), nColumn ) 

   If nColumn == Nil .or. nColumn > Len( ::aColumns ) .or. nColumn <= 0
      Return Self
   EndIf

   ::aColumns[ nColumn ]:cResName  := cResName
   ::aColumns[ nColumn ]:bAction   := bAction
   ::aColumns[ nColumn ]:nBmpWidth := nBmpWidth
   ::aColumns[ nColumn ]:lBtnGet   := .t.

Return Self

* ============================================================================
* METHOD TSBrowse:SetColMsg() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetColMsg( cMsg, cEditMsg, nCol ) CLASS TSBrowse

   If Empty( ::aColumns ) .or. ( cMsg == Nil .and. cEditMsg == Nil )
      Return Self
   EndIf

   If nCol == Nil
      AEval( ::aColumns, { |e| If( cMsg != Nil, e:cMsg := cMsg, Nil ), If( cEditMsg != Nil, e:cMsgEdit := cEditMsg, ;
                                   Nil ) } )
   Else
      If cMsg != Nil
         ::aColumns[ nCol ]:cMsg := cMsg
      EndIf

      If cEditMsg != Nil
         ::aColumns[ nCol ]:cMsgEdit := cEditMsg
      EndIf
  EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetColor() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetColor( xColor1, xColor2, nColumn ) CLASS TSBrowse

   Local nEle, nI, nColor

   Default xColor1 := {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}, ;
           nColumn := 0, ;
           ::lTransparent := .F.

   If ( Empty( ::aColumns ) .and. nColumn > 0 )
      Return nil
   End

   If Valtype( xColor1 ) == "A" .and.  Valtype( xColor2 ) == "A" .and. len ( xColor1 ) > len ( xColor2 )
      Return nil
   End

   If Valtype( xColor1 ) == "N" .and. Valtype( xColor2 ) == "N" .and. nColumn == 0
      Return ::SetColor( xColor1, xColor2 )  // FW SetColor Method only nClrText and nClrPane
   EndIf

   If Len( ::aColumns ) == 0 .and. ! ::lTransparent .and. ::hBrush == Nil
      nColor := If( ValType( xColor2[ 2 ] ) == "B", Eval( xColor2[ 2 ], 1, 1, Self ), xColor2[ 2 ] )
      ::hBrush := CreateSolidBrush( GetRed ( nColor ), GetGreen ( nColor ), GetBlue (nColor ) )
   EndIf

   If nColumn == 0 .and. ValType ( xColor2[ 1 ] ) == "N" .and. ValType( xColor1 ) == "A" .and. xColor1[ 1 ] == 1 .and. ;
      Len( xColor1 ) > 1 .and. ValType( xColor2 ) == "A" .and. ValType( xColor2[ 2 ] ) == "N" .and. xColor1[ 2 ] == 2

      nColor := If( ValType( xColor2[ 2 ] ) == "B", Eval( xColor2[ 2 ], 1, 1, Self ), xColor2[ 2 ] )
      ::Super:SetColor( xColor2[ 1 ], nColor )
   EndIf

   If Valtype( xColor1 ) == "N"
      xColor1 := { xColor1 }
      xColor2 := { xcolor2 }
   EndIf

   For nEle := 1 To Len( xColor1 )
      Do Case

         Case xColor1[ nEle ] == 1

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrFore := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrText := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 2

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrPane := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrBack := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 3

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrHeadFore := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrHeadFore := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrHeadFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 4

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrHeadBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrHeadBack := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrHeadBack := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 5

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrFocuFore := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrFocuFore := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrFocuFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 6

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrFocuBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrFocuBack := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrFocuBack := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 7

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrEditFore := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrEditFore := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrEditFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 8

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrEditBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrEditBack := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrEditBack := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 9

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrFootFore := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrFootFore := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrFootFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 10

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrFootBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrFootBack := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrFootBack := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 11

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrSeleFore := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrSeleFore := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrSeleFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 12

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrSeleBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrSeleBack := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrSeleBack := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 13

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrOrdeFore := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrOrdeFore := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrOrdeFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 14

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrOrdeBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrOrdeBack := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrOrdeBack := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 16

            If nColumn == 0
               For nI := 1 TO Len( ::aSuperHead )
                   ::aSuperHead[ nI , 5 ] := xColor2[ nEle ]
               Next

            Else
               ::aSuperHead[ nColumn , 5 ] := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 17
            If nColumn == 0

               For nI := 1 TO Len( ::aSuperHead )
                   ::aSuperHead[ nI , 4 ] := xColor2[ nEle ]
               Next

            Else
               ::aSuperHead[ nColumn , 4 ] := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 18

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrSpcHdFore := xColor2[ nEle ]
               Next
               If Empty( ::aColumns )
                  ::nClrSpcHdFore := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrSpcHdFore := xColor2[ nEle ]
            EndIf

         Case xColor1[ nEle ] == 19

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrSpcHdBack := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrSpcHdBack := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrSpcHdBack := xColor2[ nEle ]
            EndIf

       Case xColor1[ nEle ] == 20

            If nColumn == 0

               For nI := 1 TO Len( ::aColumns )
                   ::aColumns[ nI ]:nClrSpcHdActive := xColor2[ nEle ]
               Next

               If Empty( ::aColumns )
                  ::nClrSpcHdActive := xColor2[ nEle ]
               EndIf

            Else
               ::aColumns[ nColumn ]:nClrSpcHdActive := xColor2[ nEle ]
            EndIf

         Otherwise
            ::nClrLine := xColor2[ nEle ]
      EndCase

   Next

   If ::lPainted
      ::Refresh( .T. )
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:SetCols() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetColumns( aData, aHeaders, aColSizes ) CLASS TSBrowse

   Local aFields , nElements, n

   nElements   := Len( aData )

   ::aHeaders  := If( aHeaders  != Nil, aHeaders, ::aHeaders )
   ::aColSizes := If( aColSizes != Nil, aColSizes, {} )
   ::bLine     := {|| _aData( aData ) }
   ::aJustify  := AFill( Array( nElements ), .F. )

   If Len( ::GetColSizes() ) < nElements
      ::aColSizes := AFill( Array( nElements ), 0 )
      aFields := Eval( ::bLine )

      For n := 1 to nElements
          ::aColSizes[ n ] := If( ValType( aFields[ n ] ) != "C", 16,; // Bitmap handle
                                   GetTextWidth( 0, Replicate( "B", Max( Len( ::aHeaders[ n ] ), ;
                                        Len( aFields[ n ] ) ) + 1 ), ;
                                   If( ! Empty( ::hFont ), ::hFont, 0 ) ) )
      Next
   EndIf

   If ::oHScroll != nil
      ::oHScroll:nMax := ::GetColSizes()
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetColSize() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetColSize( nCol, nWidth ) CLASS TSBrowse

   Local nI, nSize

   If ValType( nCol ) == "A"
      For nI := 1 To Len( nCol )
          nSize := If( ValType( nWidth ) == "A", nWidth[ nI ], nWidth )
          ::aColumns[ nCol[ nI ] ]:nWidth := nSize
          ::aColSizes[ nCol[ nI ] ] := IF(::aColumns[ nCol[ nI ] ]:lVisible, ::aColumns[ nCol[ nI ] ]:nWidth, 0)
      Next
   Else
      If ValType( nCol ) == "C"  // 14.07.2015
         nCol := AScan( ::aColumns, { |oCol| Upper( oCol:cName ) == Upper(nCol) } )
      EndIf
      ::aColumns[ nCol ]:nWidth := nWidth
      ::aColSizes[ nCol ] := IF(::aColumns[ nCol ]:lVisible, ::aColumns[ nCol ]:nWidth, 0)
   EndIf

   If ::lPainted
      ::Refresh( .T. )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetData() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetData( nColumn, bData, aList ) CLASS TSBrowse

   If Valtype( nColumn ) == "C"
      nColumn := ::nColumn( nColumn )  // 21.07.2015
   EndIf

   If Valtype( nColumn ) != "N" .or. nColumn <= 0
      Return Nil
   EndIf

   If aList != Nil

      If ValType( aList[ 1 ] ) == "A"
         ::aColumns[ nColumn ]:aItems := aList[ 1 ]
         ::aColumns[ nColumn ]:aData := aList[ 2 ]
         ::aColumns[ nColumn ]:cDataType := ValType( aList[ 2, 1 ] )
      Else
         ::aColumns[ nColumn ]:aItems := aList
      EndIf

      ::aColumns[ nColumn ]:lComboBox := .T.

   EndIf

   If bData != Nil

      If Valtype( bData ) == "B"
         ::aColumns[ nColumn ]:bData := bData
      Else
         ::aColumns[ nColumn ]:bData := { || (bData) }
      EndIf

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetDbf() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetDbf( cAlias ) CLASS TSBrowse

   Local cAdsKeyNo, cAdsKeyCount, nTags, nEle

   Default ::cAlias := cAlias
   Default ::cAlias := Alias()

   If Empty( ::cAlias )
      Return Nil
   EndIf

   cAlias := ::cAlias
   ::cDriver := ( ::cAlias )->( RddName() )

   Default ::bGoTop    := {|| ( cAlias )->( DbGoTop() ) }, ;
           ::bGoBottom := {|| ( cAlias )->( DbGoBottom() ) }, ;
           ::bSkip     := {| n | If( n == Nil, n := 1, Nil ), ::DbSkipper( n ) }, ;
           ::bBof      := {|| ( cAlias )->( Bof() ) }, ;
           ::bEof      := {|| ( cAlias )->( Eof() ) }

   If "ADS" $ ::cDriver
      cAdsKeyNo := "{| n, oBrw | If( n == Nil, Round( " + cAlias + "->( ADSGetRelKeyPos() ) * oBrw:nLen, 0 ), " + ;
                         cAlias + "->( ADSSetRelKeyPos( n / oBrw:nLen ) ) ) }"

      cAdsKeyCount := "{|cTag| " + cAlias + "->( ADSKeyCount(cTag,, 1 ) ) }"

      Default ::bKeyNo    := &cAdsKeyNo , ;
              ::bKeyCount := &cAdsKeyCount, ;
              ::bLogicLen := &cAdsKeyCount, ;
              ::bTagOrder := {|uTag| ( cAlias )->( OrdSetFocus( uTag ) ) }, ;
              ::bGoToPos  := {|n| Eval( ::bKeyNo, n, Self ) }
   Else
      Default ::bKeyNo    := {| n | ( cAlias )->( If( n == Nil, If( IndexOrd() > 0, OrdKeyNo(), RecNo() ), ;
                              If( IndexOrd() > 0, OrdKeyGoto( n ), DbGoTo( n ) ) ) ) }, ;
              ::bKeyCount := {|| ( cAlias )->( If( IndexOrd() > 0, OrdKeyCount(), LastRec() ) ) }, ;
              ::bLogicLen := {|| ( cAlias )->( If(  IndexOrd() == 0, LastRec(), OrdKeyCount() ) ) }, ;
              ::bTagOrder := {|uTag| ( cAlias )->( OrdSetFocus( uTag ) ) }, ;
              ::bGoToPos  := {|n| Eval( ::bKeyNo, n ) }
   EndIf

   nTags := ( cAlias )->( OrdCount() )
   ::aTags := {}

   For nEle := 1 To nTags
      AAdd( ::aTags, { ( cAlias )->( OrdName( nEle ) ), ( cAlias )->( OrdKey( nEle ) ) } )
   Next
   if "SQL" $ ::cDriver
      Eval(::bGoToPos,100)
      ::bGoBottom := {|| CursorWait(), ( cAlias )->( DbGoBottom() ), CursorArrow() }
      ::bRecLock  := {|| .t. }
   endif

   ::nLen := Eval( ::bLogicLen )
   ::ResetVScroll( .T. )

Return Self

* ============================================================================
* METHOD TSBrowse:SetDeleteMode()  Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetDeleteMode( lOnOff, lConfirm, bDelete, bPostDel ) CLASS TSBrowse

   Default lOnOff   := .T., ;
           lConfirm := .T.

   ::lCanDelete := lOnOff
   ::lConfirm   := lConfirm
   ::bDelete    := bDelete
   ::bPostDel   := bPostDel

Return Self

* ============================================================================
* METHOD TSBrowse:SetFilter() Version 7.0 Jul/15/2004
* ============================================================================

METHOD SetFilter( cField, uVal1, uVal2 ) CLASS TSBrowse

   Local cIndexType, cAlias, ;
         lWasFiltered := ::lFilterMode

   Default uVal2 := uVal1

   If ValType( uVal2 ) == "A"
      ::bFilter := uVal2[ 2 ]
      uVal2 := uVal2[ 1 ]
   EndIf

   ::cField      := cField
   ::uValue1     := uVal1
   ::uValue2     := uVal2
   ::lFilterMode := ! Empty( cField )

   cAlias := ::cAlias

   If ::lFilterMode
      ::lDescend := ( ::uValue2 < ::uValue1 )

      cIndexType := ( cAlias )->( ValType( &( IndexKey() ) ) )

      If ( ::cAlias )->( ValType( &cField ) ) != cIndexType .or. ;
         ValType( uVal1 ) != cIndexType .or. ;
         ValType( uVal2 ) != cIndexType

         MsgInfo( ::aMsg[ 27 ], ::aMsg[ 28 ] )

         ::lFilterMode := .F.

      EndIf

   EndIf
#ifdef _TSBFILTER7_
   // Posibility of using FILTERs based on INDEXES!!!

   ::bGoTop := If( ::lFilterMode, {|| BrwGoTop( Self ) },;
                                      {|| ( cAlias )->( DbGoTop() ) } )

   ::bGoBottom := If( ::lFilterMode, {|| BrwGoBottom( uVal2, Self ) },;
                                      {|| ( cAlias )->( DbGoBottom() ) } )

   ::bSkip := If( ::lFilterMode, BuildSkip( ::cAlias, cField, uVal1, uVal2, Self ), ;
                                           {| n | ::dbSkipper( n ) } )
#else
   If ::lFilterMode
      ( ::cAlias )->( OrdScope( 0, ::uValue1 ) )
      ( ::cAlias )->( OrdScope( 1, ::uValue2 ) )
   Else
      ( ::cAlias )->( OrdScope( 0, Nil ) )
      ( ::cAlias )->( OrdScope( 1, Nil ) )
   EndIf
#endif
   If ::bLogicLen != Nil
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), ;
                    Eval( ::bLogicLen ) )
   EndIf

   ::ResetVScroll( .T. )
   ::lHitTop    := .F.
   ::lHitBottom := .F.

   If ::lFilterMode .or. lWasFiltered
      ::GoTop()
   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:SetFont() Version 7.0 Jul/15/2004
* ============================================================================

METHOD SetFont( hFont ) CLASS TSBrowse

   If hFont != Nil
      ::hFont := hFont
      SendMessage( ::hWnd, WM_SETFONT, hFont )
   EndIf

Return 0

* ============================================================================
* METHOD TSBrowse:SetHeaders() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetHeaders( nHeight, aCols, aTitles, aAlign , al3DLook, aFonts, aActions ) CLASS TSBrowse

   Local nI

   If nHeight != Nil
      ::nHeightHead := nHeight
   EndIf

   If aCols == Nil

      aCols := {}

      Do Case

         Case ValType( aTitles ) == "A"
            For nI := 1 TO Len( aTitles )
                AAdd( aCols, nI )
            Next

         Case ValType( aActions ) == "A"
            For nI := 1 TO Len( aActions )
                AAdd( aCols, nI )
            Next

         Case ValType( aAlign ) == "A"
            For nI := 1 TO Len( aAlign )
                AAdd( aCols, nI )
            Next

         Case ValType( al3DLook ) == "A"
            For nI := 1 TO Len( al3DLook )
                AAdd( aCols, nI )
            Next

         Case ValType( aFonts ) == "A"
            For nI := 1 TO Len( aFonts )
                AAdd( aCols, nI )
            Next

         Otherwise
            Return Nil
      EndCase

   EndIf

   For nI := 1 TO Len( aCols )

      If aTitles != Nil
         ::aColumns[ aCols[ nI ] ]:cHeading := aTitles[ nI ]
      EndIf

      If aAlign != Nil
         ::aColumns[ aCols[ nI ] ]:nHAlign := If( ValType( aAlign ) == "A", aAlign[ nI ], aAlign )
      EndIf

      If al3DLook != Nil
         ::aColumns[ aCols[ nI ] ]:l3DLookHead := If( ValType( al3DLook ) == "A", al3DLook[ nI ], al3DLook )
      EndIf

      If aFonts != Nil
         ::aColumns[ aCols[ nI ] ]:hFontHead := If( ValType( aFonts ) == "A", aFonts[ nI ], aFonts )
      EndIf

      If aActions != Nil
         ::aColumns[ aCols[ nI ] ]:bAction := aActions[ nI ]
      EndIf

   Next

   ::DrawHeaders()

Return Self

* ============================================================================
* METHOD TSBrowse:SetIndexCols() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetIndexCols( nCol1, nCol2, nCol3, nCol4, nCol5 ) CLASS TSBrowse

   Local aCol

   Default nCol2 := 0, ;
           nCol3 := 0, ;
           nCol4 := 0, ;
           nCol5 := 0

   If Valtype( nCol1 ) == "A"
      AEval( nCol1, { | nCol | ::aColumns[ nCol ]:lIndexCol := .T. } )
   Else
      aCol := { nCol1, nCol2, nCol3, nCol4, nCol5 }
      AEval( aCol, { | nCol | If( nCol > 0, ::aColumns[ nCol ]:lIndexCol := .T., Nil ) } )
   EndIf

Return Nil

* ============================================================================
* METHOD TSBrowse:SetOrder() VVersion 9.0 Nov/30/2009
* ============================================================================

METHOD SetOrder( nColumn, cPrefix, lDescend ) CLASS TSBrowse

   Local nDotPos, cAlias, nRecNo, ;
         lReturn := .F., ;
         oColumn := ::aColumns[ nColumn ], ;
         lAdo    := ::oRSet != Nil

   Default ::lIsArr := ( ::cAlias == "ARRAY" )

   If nColumn == Nil .or. nColumn > Len( ::aColumns )
      Return .F.
   EndIf

   ::lNoPaint := .F.

   If ::lIsDbf .and. ! Empty( oColumn:cOrder )

      If nColumn == ::nColOrder .or. oColumn:lDescend == Nil
         If lDescend == Nil
            lDescend := If( Empty( ::nColOrder ) .or. oColumn:lDescend == Nil, .F., ! oColumn:lDescend )
         EndIf
         If oColumn:lNoDescend   // SergKis addition
            lDescend := .F.
         Else
            ( ::cAlias )->( OrdDescend( ,, lDescend ) )
         EndIf
         oColumn:lDescend := lDescend
         ::nColOrder := nColumn
         ::lHitTop := ::lHitBottom := .F.
         ::nAt := ::nLastnAt := Eval( ::bKeyNo, Nil, Self )
      EndIf

      cAlias := ::cAlias

      If ::bKeyNo == Nil
         ::SetDbf()
      EndIf

      If ( nDotPos := At( ".", oColumn:cOrder ) ) > 0 // in case TAG has an extension (ie .NTX)
         oColumn:cOrder := SubStr( oColumn:cOrder, 1, nDotPos - 1 )
      EndIf

      ::uLastTag := oColumn:cOrder

      ( cAlias )->( Eval( ::bTagOrder, oColumn:cOrder ) )

      If Empty( ( cAlias )->( IndexKey() ) )
         ::cOrderType := ""
      Else
         ::cOrderType := ( cAlias )->( ValType( &( IndexKey() ) ) )
      EndIf

      ::UpStable()
      ::ResetVScroll()
      ::nColOrder := nColumn
      ::ResetSeek()
      ::nAt := ::nLastnAt := Eval( ::bKeyNo, Nil, Self )
      ::HiLiteCell( nColumn )

      If ::bSetOrder != Nil
         Eval( ::bSetOrder, Self, ( cAlias )->( Eval( ::bTagOrder ) ), nColumn )
      EndIf

      lReturn := .T.

      If cPrefix != Nil
         ::cPrefix := cPrefix
      EndIf

      ::aColumns[ nColumn ]:lSeek := ::lSeek  // GF 1.71

   ElseIf ::lIsArr

      If nColumn <= Len( ::aArray[ 1 ] ) .and. oColumn:lIndexCol
         ::cOrderType := ValType( ::aArray[ ::nAt, nColumn ] )

         If nColumn == ::nColOrder .or. Empty( oColumn:cOrder ) .or. oColumn:lDescend == Nil
            If lDescend == Nil
               lDescend := If( Empty( oColumn:cOrder ) .or. oColumn:lDescend == Nil, .F., ! oColumn:lDescend )
            EndIf
            If oColumn:lNoDescend   // SergKis addition
               lDescend := .F.
            EndIf
            oColumn:lDescend := lDescend
            ::nColOrder      := nColumn

            If ::bSetOrder != Nil
               Eval( ::bSetOrder, Self, nColumn )
            Else
               ::SortArray( nColumn, lDescend )
            EndIf

            If ::lPainted
               ::UpAStable()
               ::Refresh()
               ::HiliteCell( nColumn )
            EndIf

            ::ResetVScroll()
            oColumn:lSeek  := .T.
            oColumn:cOrder := "Order"
            Return .T.
         Else
            ::nColOrder := nColumn
         EndIf

      EndIf

      ::ResetSeek()
      lReturn := .T.

      If cPrefix != Nil
         ::cPrefix := cPrefix
      EndIf

      If ::bSetGet != Nil
         If ValType( Eval( ::bSetGet ) ) == "N"
            Eval( ::bSetGet, ::nAt )
         ElseIf ::nLen > 0
            Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
         Else
            Eval( ::bSetGet, "" )
         EndIf
      EndIf

   ElseIf ::oRSet != Nil .and. ! Empty( oColumn:cOrder )

      If nColumn == ::nColOrder .or. oColumn:lDescend == Nil
         If lDescend == Nil
            lDescend := If( Empty( ::nColOrder ) .or. oColumn:lDescend == Nil, .F., ! oColumn:lDescend )
         EndIf

         nRecNo := Eval( ::bRecNo )
         ::oRSet:Sort := Upper( oColumn:cOrder ) + If( lDescend, " DESC", " ASC" )

         oColumn:lDescend := lDescend
         ::UpRStable( nRecNo )
         ::ResetVScroll()
         ::nColOrder := nColumn
         ::ResetSeek()
         ::lHitTop := ::lHitBottom := .F.
         ::nAt := ::nLastnAt := Eval( ::bKeyNo )
         ::HiLiteCell( nColumn )
         ::Refresh()
         Return .T.
      EndIf

      ::uLastTag := oColumn:cOrder
      ::nColOrder := nColumn
      ::HiLiteCell( nColumn )
      ::nAt := ::nLastnAt := Eval( ::bKeyNo )
      lReturn := .T.

   EndIf

   ::lHitTop := ::lHitBottom := .F.

Return lReturn

* ============================================================================
* METHOD TSBrowse:SetSelectMode() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetSelectMode( lOnOff, bSelected, uBmpSel, nColSel, nAlign ) CLASS TSBrowse

   Default lOnOff  := .T., ;
           nColSel := 1, ;
           nAlign  := DT_RIGHT

   ::lCanSelect := lOnOff
   ::bSelected  := bSelected
   ::aSelected  := {}

   If ::lCanSelect .and. ;
      ( uBmpSel == Nil .or. Empty( nColSel ) .or. nColSel > Len( ::aColumns ) )
      Return Self
   EndIf

   If ::lCanSelect .and. uBmpSel != Nil

      If ValType( uBmpSel ) != "C"
         ::uBmpSel := uBmpSel
      Else
         ::uBmpSel := LoadImage ( uBmpSel )
         ::lDestroy := .T.
      EndIf

      ::nColSel  := nColSel
      ::nAligBmp := nAlign

   ElseIf ::uBmpSel != Nil

      If ::lDestroy
         DeleteObject ( ::uBmpSel )
      EndIf

      ::lDestroy := .F.
      ::uBmpSel  := Nil
      ::nCoSel   := 0
      ::nAligBmp := 0

   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SetSpinner() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetSpinner( nColumn, lOnOff, bUp, bDown, bMin, bMax ) CLASS TSBrowse

   Default lOnOff := .T., ;
           bUp := { | oGet | oGet++ }, ;
           bDown := { | oGet | oGet++ }

   If nColumn == Nil .or. nColumn > Len( ::aColumns ) .or. nColumn <= 0
      Return Self
   EndIf

   ::aColumns[ nColumn ]:lSpinner := lOnOff
   ::aColumns[ nColumn ]:bUp      := bUp
   ::aColumns[ nColumn ]:bDown    := bDown
   ::aColumns[ nColumn ]:bMin     := bMin
   ::aColumns[ nColumn ]:bMax     := bMax
   ::aColumns[ nColumn ]:lBtnGet  := .t.

Return Self

* ============================================================================
* METHOD TSBrowse:ShowSizes() Version 9.0 Nov/30/2009
* ============================================================================

#ifdef __DEBUG__
METHOD ShowSizes() CLASS TSBrowse

   Local cText  := "", ;
         nTotal := 0, ;
         aTemp  := ::GetColSizes()

   AEval( aTemp, { | e, n | nTotal += e, cText += ( If( ValType( ::aColumns[ n ]:cHeading ) == "C", ;
                   ::aColumns[ n ]:cHeading, ::aMsg[ 24 ] + Space( 1 ) + Ltrim( Str( n ) ) ) + ": " + ;
                     Str( e, 3 ) + " Pixels" + CRLF ) } )

   cText += CRLF + "Total " + Str( nTotal, 4 ) + " Pixels" + CRLF + ::aMsg[ 25 ] + Space( 1) + ;
            Str( ::nWidth(), 4 ) + " Pixels" + CRLF

   MsgInfo( cText, ::aMsg[ 26 ] )

Return Self
#endif

* ============================================================================
* METHOD TSBrowse:Skip() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Skip( n ) CLASS TSBrowse

   Local nSkipped

   Default n := 1

   If ::bSkip != Nil
      nSkipped := Eval( ::bSkip, n )
   Else
      nSkipped := ::DbSkipper( n )
   EndIf

   If ::lIsDbf
      ::nLastPos := ( ::cAlias )->( RecNo() )
   EndIf

   ::nLastnAt := ::nAt

   If ::lIsArr .and. ::bSetGet != Nil
      If ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ElseIf ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      Else
         Eval( ::bSetGet, "" )
      EndIf
   EndIf

Return nSkipped

* ============================================================================
* METHOD TSBrowse:SortArray() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SortArray( nCol, lDescend ) CLASS TSBrowse

   Local aLine := ::aArray[ ::nAt ]

   Default nCol := ::nColOrder

   If lDescend == Nil
      If ::aColumns[ nCol ]:lDescend == Nil
         lDescend := .F.
      Else
         lDescend := ::aColumns[ nCol ]:lDescend
      EndIf
   EndIf

   CursorWait()

   ::aColumns[ nCol ]:lDescend := lDescend

   if ::lSelector .and. nCol > 1
      nCol --
   endif

   If lDescend
      if  ValType(::aColumns[ nCol ]:bArraySortDes) == "B"
         ::aArray := ASort( ::aArray,,, ::aColumns[ nCol ]:bArraySortDes )
      else
         ::aArray := Asort( ::aArray,,, {|x,y| x[ nCol ] > y[ nCol ] } )
      endif
   Else
      if  ValType(::aColumns[ nCol ]:bArraySort) == "B"
         ::aArray := ASort( ::aArray,,, ::aColumns[ nCol ]:bArraySort )
      else
         ::aArray := Asort( ::aArray,,, {|x,y| x[ nCol ] < y[ nCol ] } )
      EndIf
   endif

   ::nAt := AScan( ::aArray, {|e| lAEqual( e, aLine ) } )
   CursorHand()

Return Self

* ============================================================================
* METHOD TSBrowse:SwitchCols() Version 9.0 Nov/30/2009
* This method is dedicated to John Stolte by the 'arry
* ============================================================================

METHOD SwitchCols( nCol1, nCol2 ) CLASS TSBrowse

   Local oHolder, nHolder, nMaxCol := Len(::aColumns)

   If nCol1 > ::nFreeze .and. nCol2 > ::nFreeze .and. ;
      nCol1 <= nMaxCol .and. nCol2 <= nMaxCol

      oHolder := ::aColumns[ nCol1 ]
      nHolder := ::aColSizes[ nCol1 ]

      ::aColumns[ nCol1 ]  := ::aColumns[ nCol2 ]
      ::aColSizes[ nCol1 ] := ::aColSizes[ nCol2 ]

      ::aColumns[ nCol2 ]  := oHolder
      ::aColSizes[ nCol2 ] := nHolder

      If ::nColOrder == nCol1
         ::nColOrder := nCol2
      EndIf

   EndIf

   If ::lPainted
      ::Refresh( .F. )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:SyncChild() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SyncChild( aoChildBrw, abAction ) CLASS TSBrowse

   If aoChildBrw != Nil
      If ValType( aoChildBrw ) == "O"
         aoChildBrw := { aoChildBrw }
      EndIf

      Default abAction := Array( Len( aoChildBrw ) )

      If ValType( abAction ) == "B"
         abAction := { abAction }
      EndIf

      ::bChange := {|| ;
                       AEval( aoChildBrw, {|oChild,nI| If( ! Empty( oChild:cAlias ),;
                       ( oChild:lHitTop := .F., oChild:goTop(),;
                       If( abAction[nI] != Nil, Eval( abAction[nI], Self, oChild ), Nil ),;
                       oChild:reset() ), Nil ) } ) }
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:UpStable() Version 9.0 Nov/30/2009
* ============================================================================

METHOD UpStable() CLASS TSBrowse

   Local nRow     := ::nRowPos, ;
         nRecNo   := ( ::cAlias )->( RecNo() ), ;
         nRows    := ::nRowCount(), ;
         n        := 1, ;
         lSkip    := .T., ;
         bChange  := ::bChange, ;
         nLastPos := ::nLastPos

   If ::nLen > nRows

      ( ::cAlias )->( DbSkip( nRows - nRow ) )

      If ( ::cAlias )->( EoF() )
         Eval( ::bGoBottom )
         ::nRowPos := nRows

         While ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
            ::Skip( -1 )
            ::nRowPos --
         EndDo

         ::Refresh( .F. )
         ::ResetVScroll()
         Return Self
      Else
         ( ::cAlias )->( DbGoto( nRecNo ) )
      EndIf

   EndIf

   ::bChange    := Nil
   ::lHitTop    := .F.
   ::lHitBottom := .F.
   ::GoTop()

   While ! ( ::cAlias )->( EoF() )

      If n > nRows
         ::nRowPos := nRow
         lSkip     := .F.
         Exit
      EndIf

      If nRecNo == ( ::cAlias )->( RecNo() )
         ::nRowPos := n
         Exit
      Else
         ::Skip( 1 )
      EndIf

      n++

   EndDo

   If lSkip
      ::Skip( -::nRowPos )
   EndIf

   ( ::cAlias )->( DbGoTo( nRecNo ) )                // restores Record position
   ::nLastPos := nLastPos
   ::nAt      := ::nLastnAt := ::nLogicPos()
   ::lHitTop  := ( ::nAt == 1 )

   If ::oVScroll != Nil .and. ! Empty( ::bKeyNo )     // restore scrollbar thumb
      ::oVScroll:SetPos( ::RelPos( ( ::cAlias )->( Eval( ::bKeyNo, Nil, Self ) ) ) )
   EndIf

   ::bChange := bChange

   If ::lPainted
      ::Refresh( If( ::nLen < nRows, .T., .F. ) )
   EndIf

Return Self

* ============================================================================
* METHOD TSBrowse:VertLine() Version 9.0 Nov/30/2009
* Thanks to Gianni Santamarina
* ============================================================================

METHOD VertLine( nColPixPos, nColInit, nGapp ) CLASS TSBrowse

   Local hDC      := GetDC( ::hWnd )
   Local aRect    := ::GetRect(), ;
         nRigHe   := 1, ;
         hRighe   := _GetTextHeight( ::hWnd, hDC )

   If nColInit != Nil
      nsCol   := nColInit
      nsWidth := nColPixPos
      nGap := If( ! Empty( nGapp ), nGapp, 0 )
      nsOldPixPos := 0
      _InvertRect( ::hDC, { 0, nsWidth - ::aColSizes[ nsCol ] - 2, aRect[4], nsWidth - ::aColSizes[ nsCol ] + 2 } )
   EndIf

   If nColPixPos == Nil .and. nColInit == Nil   // We have finish dragging
      ::aColSizes[ nsCol ] -= ( nsWidth - nsOldPixPos )
      ::aColumns[ nsCol ]:nWidth -= ( nsWidth - nsOldPixPos )
      ::Refresh()

      If ValType( ::bLineDrag ) == "B" 
         Eval( ::bLineDrag, nsCol, ( nsOldPixPos - nsWidth ), Self ) 
      EndIf
   EndIf

   aRect := ::GetRect()

   If nsOldPixPos != 0 .and. nColPixPos != Nil .and. nColPixPos != nsOldPixPos
      _InvertRect( hDC, { 0, nsOldPixPos - 2, aRect[4], nsOldPixPos + 2 } )
      nsOldPixPos := 0
   EndIf

   If nColPixPos != Nil .and. nColPixPos != nsOldPixPos
      nColPixPos := Max( nColPixPos, 10 )
      _InvertRect( hDC, { 0, nColPixPos - 2 + nGap, aRect[4], nColPixPos + 2 + nGap } )
      nsOldPixPos := nColPixPos + nGap
   EndIf

   ReleaseDC( ::hWnd, hDC )

Return Nil

* ============================================================================
* METHOD TSBrowse:VScroll() Version 9.0 Nov/30/2009
* ============================================================================

METHOD VScroll( nMsg, nPos ) CLASS TSBrowse

   Local oCol,;
         nLines := Min( ::nLen, ::nRowCount() )

   ::lNoPaint := .F.

   If ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
      oCol := ::oWnd:aColumns[ ::oWnd:nCell ]
      If oCol:oEdit != Nil .and. nPos == 0
        if "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )
           Eval( oCol:oEdit:bKeyDown , VK_ESCAPE, 0, .t. )
        endif
      EndIf
   EndIf
   If GetFocus() != ::hWnd
      SetFocus( ::hWnd )
   EndIf

   Do Case
      Case nMsg == SB_LINEUP
         ::GoUp()

      Case nMsg == SB_LINEDOWN
         If ! ::lHitBottom
            ::GoDown()
         EndIf

      Case nMsg == SB_PAGEUP
         ::PageUp()

      Case nMsg == SB_PAGEDOWN
         ::PageDown()

      Case nMsg == SB_TOP
         ::GoTop()

      Case nMsg == SB_BOTTOM
         ::GoBottom()

      Case nMsg == SB_THUMBPOSITION

         If ::nLen == 0
            ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
         EndIf

         If ::nLen < 1
            Return 0
         EndIf

         If nPos == 1
            ::lHitTop := .F.
            ::GoTop()
            Return 0
         ElseIf nPos >= ::oVScroll:GetRange()[ 2 ]
            ::lHitBottom := .F.
            ::GoBottom()
            Return 0
         Else
            ::lHitTop := .F.
            ::lHitBottom := .F.
         EndIf

         ::nAt := ::nLogicPos()
         ::oVScroll:SetPos( ::RelPos( ::nAt ) )

         If ( nPos - ::oVScroll:nMin ) < nLines
              ::nRowPos := 1
         EndIf

         If ( ::oVScroll:nMax - nPos ) < Min( nLines, ::nLen )
            ::nRowPos := Min( nLines, ::nLen ) - ( ::oVScroll:nMax - nPos )
         EndIf

         ::Refresh( .F. )

         If ::lIsDbf
            ::nLastPos := ( ::cAlias )->( RecNo() )
         EndIf

         If ::bChange != nil
            Eval( ::bChange, Self, 0 )
         EndIf

      Case nMsg == SB_THUMBTRACK

         If ::lIsDbf
            ::GoPos( ::GetRealPos( nPos ) )
            ::Skip( ( ::GetRealPos( nPos ) - ::GetRealPos( ::oVScroll:GetPos() ) ) )
         else
            If ::bGoToPos != Nil
               ( ::cAlias )->( Eval( ::bGoToPos, ::GetRealPos( nPos ) ) )
            Else
               ::Skip( ( ::GetRealPos( nPos ) - ::GetRealPos( ::oVScroll:GetPos() ) ) )
            EndIf

            If nPos == 1
               ::lHitTop := .F.
               ::GoTop()
               Return 0
            ElseIf nPos >= ::oVScroll:GetRange()[ 2 ]
               ::lHitBottom := .F.
               ::GoBottom()
               Return 0
            Else
               ::lHitTop := .F.
               ::lHitBottom := .F.
            EndIf

            if  ::nLen >= nLines
               if (::nLen - ::nAt) <= nLines
                  ::nRowPos := nLines - (::nLen - ::nAt )
               elseif ::nLen == ::nAt
                  ::nRowPos := nLines
               else
                  ::nRowPos := 1
               endif
            endif
            ::Refresh( .F. )
            SysRefresh()
         endif
      Otherwise
         Return Nil
   Endcase

Return 0

* ============================================================================
* METHOD TSBrowse:Enabled() Version 7.0 Adaptation Version
* ============================================================================

METHOD Enabled( lEnab )  CLASS TSBrowse

   Local nI

   Default lEnab := .T.

   IF ValType( lEnab ) == "L"
      IF !lEnab
         IF ::lEnabled
            For nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:SaveColor()
            Next
         ENDIF
         ::lEnabled := .F.
         ::SetColor( { 2 }, { CLR_HGRAY } )
         ::SetColor( { 3, 4 }, { CLR_GRAY, CLR_HGRAY } )
      ELSE
         IF ! ::lEnabled
            For nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:RestColor()
               SetColor( , ::aColumns[ nI ]:aColors, nI )
            Next
         ENDIF
         ::lEnabled := .T.
      ENDIF
   ENDIF

RETURN 0

* ============================================================================
* METHOD TSBrowse:HideColumns() Version 7.0 Adaptation Version
* ============================================================================

METHOD HideColumns( nColumn, lHide ) CLASS TSBrowse

   Local aColumn, nI, nJ, lPaint := .F.

   Default lHide := .T.

   If Valtype( nColumn ) == "C"
      nColumn := ::nColumn( nColumn )  // 21.07.2015
   EndIf

   If Empty( ::aColumns ) .and. nColumn > 0
      Return Nil
   EndIf

   aColumn := IF( ValType( nColumn ) == "N", { nColumn }, nColumn )

   FOR nI :=1 TO Len( aColumn )

      If ( nJ := aColumn[ nI ] ) <= Len( ::aColumns )

         lPaint := .T.
         If lHide
            ::aColSizes[ nJ ] := 0
         Else
            ::aColSizes[ nJ ] := ::aColumns[ nJ ]:nWidth
         EndIf
         ::aColumns[ nJ ]:lVisible := ! lHide

      EndIf

   NEXT

   ::Refresh( lPaint )

RETURN Nil

* ============================================================================
* METHOD TSBrowse:UserPopup() Version 9.0 Adaptation Version
* ============================================================================

METHOD UserPopup( bUserPopupItem, aColumn ) CLASS TSBrowse

   If Valtype( aColumn ) != "A"
      aColumn := IF( Valtype( aColumn ) == "N", { aColumn }, { 0 } )
   EndIf

   ::bUserPopupItem := IF( Valtype( bUserPopupItem ) == "B", bUserPopupItem, ;
      { || (bUserPopupItem) } )
   ::lNoPopup   := .F.
   ::lPopupUser := .T.
   ::aPopupCol  := aColumn

RETURN 0


* ============================================================================
*                    TSBrowse   Functions
* ============================================================================

* ============================================================================
* FUNCTION TSBrowse _aData() Version 9.0 Nov/30/2009
* Called from METHOD SetCols()
* ============================================================================

Static Function _aData( aFields )

  Local aFld, nFor, nLen

  nLen := Len( aFields )
  aFld := Array( nLen )

  For nFor := 1 To nLen
     aFld[ nFor ] := Eval( aFields[ nFor ] )
  Next

Return aFld

#ifdef __DEBUG__
* ============================================================================
* FUNCTION TSBrowse AClone() Version 9.0 Nov/30/2009
* ============================================================================

Static Function AClone( aSource )

   Local aTarget := {}

   AEval( aSource, { |e| AAdd( aTarget, e ) } )

Return aTarget
#endif

* ============================================================================
* FUNCTION TSBrowse:AutoHeaders() Version 9.0 Nov/30/2009
* Excel's style column's heading
* ============================================================================

Static Function AutoHeaders( nCols )

   Local nEle, aHead, nChg, ;
         cHead := "", ;
         aBCD  := {}

   For nEle := 65 To 90
      AAdd( aBCD, Chr( nEle ) )
   Next

   If nCols <= 26
      ASize( aBCD, nCols )
      Return aBCD
   EndIf

   aHead := AClone( aBCD )
   nCols -= 26
   cHead := "A"
   nChg  := 1

   While nCols > 0

      For nEle := 1 To Min( 26, nCols )
         AAdd( aHead, cHead + aBCD[ nEle ] )
      Next

      nCols -= 26

      If Asc( SubStr( cHead, nChg, 1 ) ) == 90
         If nChg > 1
            nChg --
         Else
            cHead := Replicate( Chr( 65 ), Len( cHead ) + 1 )
            nChg := Len( cHead )
         EndIf
      EndIf

      cHead := Stuff( cHead, nChg, 1, Chr( Asc( SubStr( cHead, nChg, 1 ) ) + 1 ) )

   EndDo

Return aHead

* ============================================================================
* FUNCTION TSBrowse lASeek() Version 9.0 Nov/30/2009
* Incremental searching in arrays
* ============================================================================

Static Function lASeek( uSeek, lSoft, oBrw )

   Local nEle, uData, ;
         lFound := .F., ;
         aArray := oBrw:aArray, ;
         nCol   := oBrw:nColOrder, ;
         nRecNo := oBrw:nAt

   Default lSoft := .F.

   For nEle := Max( 1, nNewEle ) To Len( aArray )

      uData := aArray[ nEle, nCol ]
      uData := If( oBrw:lUpperSeek, Upper( cValToChar( uData ) ), cValToChar( uData ) )

      If ! lSoft
         If uData = cValToChar( uSeek )
            lFound := .T.
            Exit
         EndIf
      Else
         If uData >= cValToChar( uSeek )
            lFound := .T.
            Exit
         EndIf
      EndIf

   Next

   If lFound .and. nEle <= oBrw:nLen
      oBrw:nAt := nEle
      nNewEle  := nEle
   Else
      oBrw:nAt := nRecNo
   EndIf

Return lFound

#ifdef _TSBFILTER7_
* ============================================================================
* FUNCTION TSBrowse BrwGoBottom() Version 9.0 Nov/30/2009
* Used by METHOD SetFilter() to set the bottom limit in an "Index Based"
* filtered database
* ============================================================================

Static Function BrwGoBottom( uExpr, oBrw )

   If ValType( uExpr ) == "C"
      ( oBrw:cAlias )->( DbSeek( SubStr( uExpr, 1, Len( uExpr ) - 1 ) + ;
              Chr( Asc( SubStr( uExpr, Len( uExpr ) ) ) + ;
              If( ! oBrw:lDescend, 1, - 1 ) ), .T. ) )
   Else
      ( oBrw:cAlias )->( DbSeek( uExpr + If( ! oBrw:lDescend, 1, -1 ), .T. ) )
   EndIf

   If ( oBrw:cAlias )->( EoF() )
      ( oBrw:cAlias )->( DbGoBottom() )
   Else
      ( oBrw:cAlias )->( DbSkip( -1 ) )
   EndIf

   While oBrw:bFilter != Nil .and. ! Eval( oBrw:bFilter ) .and. ! ( oBrw:cAlias )->( BoF() )
      ( oBrw:cAlias )->( DbSkip( -1 ) )
   EndDo

Return Nil

* ============================================================================
* FUNCTION TSBrowse BrwGoTop() Version 7.0 Jul/15/2004
* Used by METHOD SetFilter() to set the top limit in an "Index Based"
* filtered database
* ============================================================================

Static Function BrwGoTop( oBrw )

   ( oBrw:cAlias )->( DbSeek( oBrw:uValue1, .T. ) )

   While oBrw:bFilter != Nil .and. ! Eval( oBrw:bFilter ) .and. ! ( oBrw:cAlias )->( EoF() )
      ( oBrw:cAlias )->( DbSkip( 1 ) )
   EndDo

Return Nil

* ============================================================================
* FUNCTION TSBrowse BuildSkip() Version 7.0 Jul/15/2004
* Used by METHOD SetFilter(). Returns a block to be used on skipping records
* in an "Index Based" filtered database
* ============================================================================

Static Function BuildSkip( cAlias, cField, uValue1, uValue2, oTb )

   Local bSkipBlock, lDescend := oTb:lDescend, ;
         cType := ValType( uValue1 )

   Do Case
      Case cType == "C"
           If ! lDescend
              bSkipBlock := &( "{|| " + cField + ">= '" + uValue1 + "' .and. " + ;
              cField + "<= '" + uValue2 + "' }" )
           Else
              bSkipBlock := &( "{|| " + cField + "<= '" + uValue1 + "' .and. " + ;
              cField + ">= '" + uValue2 + "' }" )
           EndIf
      Case cType == "D"
           If ! lDescend
              bSkipBlock := &( "{|| " + cField + ">= CToD( '" + DToC( uValue1 ) + "') .and. " + ;
              cField + "<= CToD( '" + DToC( uValue2 ) + "') }" )
           Else
              bSkipBlock := &( "{|| " + cField + "<= CToD( '" + DToC( uValue1 ) + "') .and. " + ;
              cField + ">= CToD( '" + DToC( uValue2 ) + "') }" )
           EndIf

      Case cType == "N"
           If ! lDescend
              bSkipBlock := &( "{|| " + cField + ">= " + cValToChar( uValue1 ) + " .and. " + ;
              cField + "<= " + cValToChar( uValue2 ) + " }" )
           Else
              bSkipBlock := &( "{|| " + cField + "<= " + cValToChar( uValue1 ) + " .and. " + ;
              cField + ">= " + cValToChar( uValue2 ) + " }" )
           EndIf

      Case cType == "L"
           If ! lDescend
              bSkipBlock := &( "{|| " + cField + ">= " + cValToChar( uValue1 ) + " .and. " + ;
              cField + "<= " + cValToChar( uValue2 ) + " }" )
           Else
              bSkipBlock := &( "{|| " + cField + "<= " + cValToChar( uValue1 ) + " .and. " + ;
              cField + ">= " + cValToChar( uValue2 ) + " }" )
           EndIf
   Endcase

Return { | n | ( cAlias )->( BrwGoTo( n, bSkipBlock, oTb ) ) }

* ============================================================================
* FUNCTION TSBrowse BuildFiltr() Version 1.47 Adaption HMG
* Used in Report by Function dbSetFilter. Returns a string used for create bBlock of Filter
* ============================================================================

Static Function BuildFiltr( cField, uValue1, uValue2, oTb )

   Local cFiltrBlock, lDescend := oTb:lDescend, ;
         cType := ValType( uValue1 )

   Do Case
      Case cType == "C"
           If ! lDescend
              cFiltrBlock := "{||" + cField + ">= '" + uValue1 + "' .and." + ;
              cField + "<= '" + uValue2 + "' }"
           Else
              cFiltrBlock := "{||" + cField + "<= '" + uValue1 + "' .and." + ;
              cField + ">= '" + uValue2 + "' }"
           EndIf
      Case cType == "D"
           If ! lDescend
              cFiltrBlock := "{||" + cField + ">= CToD( '" + DToC( uValue1 ) + "') .and." + ;
              cField + "<= CToD( '" + DToC( uValue2 ) + "') }"
           Else
              cFiltrBlock := "{||" + cField + "<= CToD( '" + DToC( uValue1 ) + "') .and." + ;
              cField + ">= CToD( '" + DToC( uValue2 ) + "') }"
           EndIf

      Case cType == "N"
           If ! lDescend
              cFiltrBlock := "{||" + cField + ">= " + cValToChar( uValue1 ) + " .and." + ;
              cField + "<= " + cValToChar( uValue2 ) + " }"
           Else
              cFiltrBlock := "{||" + cField + "<= " + cValToChar( uValue1 ) + " .and." + ;
              cField + ">= " + cValToChar( uValue2 ) + " }"
           EndIf

      Case cType == "L"
           If ! lDescend
              cFiltrBlock := "{||" + cField + ">= " + cValToChar( uValue1 ) + " .and." + ;
              cField + "<= " + cValToChar( uValue2 ) + " }"
           Else
              cFiltrBlock := "{||" + cField + "<= " + cValToChar( uValue1 ) + " .and." + ;
              cField + ">= " + cValToChar( uValue2 ) + " }"
           EndIf
   Endcase

Return cFiltrBlock
#endif

* ============================================================================
* FUNCTION TSBrowse BuildAutoSeek() Version 1.47 Adaption HMG
* Used in AutoSeek by Functions SpecHeader. Returns a string used for create bBlock of Locate
* ============================================================================

Static Function BuildAutoSeek( oTb )

   Local nCol, nLen, cType, uValue, cField, cLocateBlock := "", cComp,cand
   IF oTb:lIsArr
      FOR nCol:=1 TO  Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cType := ValType( uValue )
         IF !Empty(uValue)
            IF Empty(cLocateBlock)
               DO CASE
               CASE cType == "C"
                  uValue := RTrim(uValue)
                  nLen   := Len(uValue)
                  cLocateBlock := "{|oTb|Ascan ( oTb:aArray, {|x,y| substr(x["+lTrim(Str(nCol))+"],1,"+;
                        lTrim(Str(nLen))+" ) == '"+uValue+"'"
               CASE cType == "N" .or. cType == "L"
                  cLocateBlock := "{|oTb|Ascan ( oTb:aArray, {|x,y| x["+lTrim(Str(nCol))+"] == "+;
                        cValToChar( uValue )
               CASE cType == "D"
                  cLocateBlock := "{|oTb|Ascan ( oTb:aArray, {|x,y| x["+lTrim(Str(nCol))+"] == "+;
                        "CToD( '" +DToC( uValue )+"' )"
               ENDCASE
            ELSE
               DO CASE
               CASE cType == "C"
                  uValue := RTrim(uValue)
                  nLen   := Len(uValue)
                  cLocateBlock += " .and. substr(x["+lTrim(Str(nCol))+"],1,"+;
                        lTrim(Str(nLen))+" ) == '"+uValue+"'"
               CASE cType == "N" .or. cType == "L"
                  cLocateBlock = " .and. x["+lTrim(Str(nCol))+"] == "+;
                        cValToChar( uValue )
               CASE cType == "D"
                  cLocateBlock += " .and. x["+lTrim(Str(nCol))+"] == "+;
                        "CToD( '" +DToC( uValue )+"' )"
               ENDCASE
            ENDIF
         ENDIF
      next
      cLocateBlock +=IF(!Empty(cLocateBlock), " },oTB:nAT+1) } ","")
   endif
   If oTb:lIsDbf
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cData
         cType := ValType( uValue )
         IF !Empty(uValue)
            cAnd := IF(Empty(cLocateBlock),"", " .AND. ")
            DO CASE
            CASE cType == "C"
               uValue := RTrim(uValue)
               nLen   := Len(uValue)
               cLocateBlock +=  cAnd + " substr("+cField +",1,"+;
                        lTrim(Str(nLen))+" ) == '" + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cLocateBlock += cAnd + cField + " == "+ cValToChar( uValue )
            CASE cType == "D"
               cLocateBlock += cAnd + cField + " == "+ "CToD( '" +DToC( uValue )+"' )"
            ENDCASE
         ENDIF
      next
   endif
   If ! oTb:lIsArr .and. ! oTb:lIsTxt  .and. oTb:cAlias == "ADO_"
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cOrder
         cType := ValType( uValue )
         IF !Empty(uValue)
            IF !Empty(cLocateBlock)   // Only a single-column name may be specified in cLocateBlock.
               Tone( 500, 1 )
               Return cLocateBlock
            endif
            DO CASE
            CASE cType == "C"
               cComp :=IF(At('*',uValue)!= 0, " LIKE '", " = '" )
               uValue := RTrim(uValue)
               cLocateBlock :=  cField + cComp + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cLocateBlock := cField + " = "+ cValToChar( uValue )
            CASE cType == "D"
               cLocateBlock := cField + " = #" +DToC( uValue )+"# "
            ENDCASE
         ENDIF
      next
   endif

Return cLocateBlock

* ============================================================================
* FUNCTION TSBrowse BuildAutoFiltr() Version 1.47 Adaption HMG
* Used in AutoFilter by Functions SpecHeader. Returns a string used for create bBlock of Filter
* ============================================================================

Static Function BuildAutoFilter( oTb )

   Local nCol, nLen, cType, uValue, cField, cFilterBlock := "", cAnd, cComp
//   IF oTb:lIsArr
//   endif
   If oTb:lIsDbf
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cData
         cType := ValType( uValue )
         IF !Empty(uValue)
            cAnd := IF(Empty(cFilterBlock), "", " .AND. ")
            DO CASE
            CASE cType == "C"
               uValue := RTrim(uValue)
               nLen   := Len(uValue)
               cFilterBlock += cAnd + " substr("+cField +",1,"+;
                        lTrim(Str(nLen))+" ) == '" + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cFilterBlock += cAnd + cField + " == "+ cValToChar( uValue )
            CASE cType == "D"
               cFilterBlock += cAnd + cField + " == "+ "CToD( '" +DToC( uValue )+"' )"
            ENDCASE
         ENDIF
      NEXT
   endif
   If ! oTb:lIsArr .and. ! oTb:lIsTxt .and. oTb:cAlias == "ADO_"
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cOrder
         cType := ValType( uValue )
         IF !Empty(uValue)
            cAnd := IF(Empty(cFilterBlock), "", " AND ")
            DO CASE
            CASE cType == "C"
               cComp :=IF(At('*',uValue)!= 0, " LIKE '", " = '" )
               uValue := RTrim(uValue)
               cFilterBlock += cAnd + cField + cComp + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cFilterBlock += cAnd + cField + " = "+ cValToChar( uValue )
            CASE cType == "D"
               cFilterBlock += cAnd +cField + " = #" +DToC( uValue )+"# "
            ENDCASE
         ENDIF
      NEXT
   endif

Return cFilterBlock

#ifdef _TSBFILTER7_
* ============================================================================
* FUNCTION TSBrowse BrwGoto() Version 7.0 Jul/15/2004
* Executes the action defined into the block created with FUNCTION BuildSkip()
* ============================================================================

Static Function BrwGoTo( n, bWhile, oTb )

   Local nSkipped := 0, ;
         nDirection := If( n > 0, 1, -1 )

   While nSkipped != n .and. Eval( bWhile ) .and. ! ( oTb:cAlias )->( EoF() ) .and. ! ( oTb:cAlias )->( BoF() )
      ( oTb:cAlias )->( DbSkip( nDirection ) )
      nSkipped += nDirection

      If oTb:bFilter != Nil
         While ! Eval( oTb:bFilter ) .and. ! ( oTb:cAlias )->( EoF() ) .and. ! ( oTb:cAlias )->( BoF() )
            ( oTb:cAlias )->( DbSkip( nDirection ) )
         EndDo
      EndIf

   EndDo

   Do Case
      Case ( oTb:cAlias )->( EoF() )
          ( oTb:cAlias )->( DbSkip( -1 ) )

         While oTb:bFilter != Nil .and. ! Eval( oTb:bFilter ) .and. ! ( oTb:cAlias )->( BoF() )
            ( oTb:cAlias )->( DbSkip( -1 ) )
         EndDo

         If ! oTb:lAppendMode
             nSkipped += -nDirection
            Else
                If oTb:nPrevRec == Nil
                    oTb:nPrevRec := ( oTb:cAlias )->( RecNo() )
            EndIf
                ( oTb:cAlias )->( DbGoTo( 0 ) )       // phantom record
         EndIf

      Case ( oTb:cAlias )->( BoF() )
         ( oTb:cAlias )->( DbGoTo( ( oTb:cAlias )->( RecNo() ) ) )

         While oTb:bFilter != Nil .and. ! Eval( oTb:bFilter ) .and. ! ( oTb:cAlias )->( EoF() )
            ( oTb:cAlias )->( DbSkip( 1 ) )
         EndDo

         nSkipped++

      Case ! Eval( bWhile )
         If nDirection == 1 .and. oTb:lAppendMode
             If oTb:nPrevRec == Nil
                ( oTb:cAlias )->( DbSkip( -1 ) )
                oTb:nPrevRec := ( oTb:cAlias )->( RecNo() )
             EndIf
             ( oTb:cAlias )->( DbGoTo( 0 ) )       // phantom record
         Else
             ( oTb:cAlias )->( DbSkip( -nDirection ) )
             While oTb:bFilter != Nil .and. ! Eval( oTb:bFilter ) .and. ;
                 ! ( oTb:cAlias )->( BoF() ) .and. ! ( oTb:cAlias )->( EoF() )
                ( oTb:cAlias )->( DbSkip( -nDirection ) )
             EndDo

             nSkipped += -nDirection
         EndIf
   Endcase

Return nSkipped
#endif

* ============================================================================
* FUNCTION TSBrowse:DateSeek() Version 9.0 Nov/30/2009
* ============================================================================

Static Function DateSeek( cSeek, nKey )

    Local cChar  := Chr( nKey ), ;
          nSpace := At( " ", cSeek ), ;
          cTemp  := ""

    /* only  0..9 */
    If nKey >= 48 .and. nKey <= 57
       If nSpace <> 0
          cTemp := Left( cSeek, nSpace - 1 )
          cTemp += cChar
          cTemp += SubStr( cSeek, nSpace + 1, Len( cSeek ) )
          cSeek := cTemp
       Else
          cSeek := cSeek
          Tone(500, 1)
       EndIf
    ElseIf nKey == VK_BACK
        If nSpace == 4 .or. nSpace == 7
           cTemp := Left( cSeek, nSpace - 3 )
           cTemp += " "
           cTemp += SubStr( cSeek, nSpace - 1, Len( cSeek ) )
        ElseIf nSpace == 0
           cTemp := Left( cSeek, Len( cSeek ) - 1 )
        ElseIf nSpace == 1
           cTemp := cSeek
        Else
            cTemp := Left( cSeek, nSpace - 2 )
            cTemp += " "
            cTemp += SubStr( cSeek, nSpace, Len( cSeek ) )
        EndIf
        cSeek := PadR( cTemp, 10 )
    Else
       Tone( 500, 1 )
    EndIf

Return cSeek

* ============================================================================
* FUNCTION TSBrowse EmptyAlias() Version 9.0 Nov/30/2009
* Returns .T. if cAlias is not a constant "ARRAY" (browsing an array),
* or a constant "TEXT_" (browsing a text file), or an active database alias.
* ============================================================================

Static Function EmptyAlias( cAlias )

   Local bErrorBlock, oErr, lEmpty := .T.

   If ! Empty( cAlias )

      If cAlias == "ARRAY" .or. "TEXT_" $ cAlias .or. "ADO_" $ cAlias .or. "SQL" $ cAlias
         lEmpty := .F.
      Else
         bErrorBlock := ErrorBlock( { | o | Break( o ) } )
         BEGIN SEQUENCE
            If (cAlias)->( Used() )
               lEmpty := .F.
            EndIf
         RECOVER USING oErr
            //?oErr:Description
         END SEQUENCE
         ErrorBlock( bErrorBlock )
      EndIf

    EndIf

Return lEmpty

* ============================================================================
* FUNCTION TSBrowse GetUniqueName( cName ) Version 9.0 Nov/30/2009
* ============================================================================

Static Function GetUniqueName( cName )

Return ( "TSB_" + cName + Ltrim( Str( _GetId() ) ) )

* ============================================================================
* FUNCTION TSBrowse IsChar() Version 9.0 Nov/30/2009
* Used by METHOD KeyChar() to filter keys according to the field type
* Clipper's function IsAlpha() doesn't fit the purpose in some cases
* ============================================================================

Static Function _IsChar( nKey )

Return ( nKey >= 32 .and. nKey <= 255 )

* ============================================================================
* FUNCTION TSBrowse IsNumeric() Version 9.0 Nov/30/2009
* Function used by METHOD KeyChar() to filter keys according to the field type
* Clipper's function IsDigit() doesn't fit the purpose in some cases
* ============================================================================

STATIC FUNCTION _IsNumeric( nKey )

Return ( Chr( nKey ) $ ".+-0123456789" )

* ============================================================================
* FUNCTION TSBrowse MakeBlock() Version 9.0 Nov/30/2009
* Called from METHOD Default() to assign data to columns
* ============================================================================

Static Function MakeBlock( Self, nI )

Return { || Eval( ::bLine )[ nI ] }

* ============================================================================
* FUNCTION TSBrowse nValToNum() Version 9.0 Nov/30/2009
* Converts any type variables value into numeric
* ============================================================================

Function nValToNum( uVar )

   Local nVar := If( ValType( uVar ) == "N", uVar, ;
                     If( ValType( uVar ) == "C", Val( StrTran( AllTrim( uVar ), "," ) ), ;
                         If( ValType( uVar ) == "L", If( uVar, 1, 0 ), ;
                             If( ValType( uVar ) == "D", Val( DtoS( uVar ) ), 0 ) ) ) )
Return nVar

* ============================================================================
* METHOD TSBrowse:SetRecordSet() Version 9.0 Nov/30/2009
* ============================================================================

METHOD SetRecordSet( oRSet ) CLASS TSBrowse

   Default ::oRSet := oRSet, ;
           ::bGoTop    := {|| ::oRSet:MoveFirst() }, ;
           ::bGoBottom := {|| ::oRSet:MoveLast() }, ;
           ::bKeyCount := {|| ::oRSet:RecordCount() }, ;
           ::bBof      := {|| ::oRSet:Bof() }, ;
           ::bEof      := {|| ::oRSet:Eof() }, ;
           ::bSkip     := {| n | RSetSkip( ::oRSet, If( n == nil, 1, n ), Self ) }, ;
           ::bKeyNo    := { | n | If( n == Nil, ::oRSet:AbsolutePosition, ::oRSet:AbsolutePosition := n ) }, ;
           ::bLogicLen := { || ::oRSet:RecordCount() }, ;
           ::bGoToPos  := { |n| Eval( ::bKeyNo, n ) }
           ::bRecNo    := {| n | If( n == nil, If( ::oRSet:RecordCount() > 0, ::oRSet:BookMark, 0 ), ;
                                 If( ::oRSet:RecordCount() > 0, ( ::oRSet:BookMark := n ), 0 ) ) }

   ::nLen := Eval( ::bLogicLen )
   ::ResetVScroll( .T. )

Return Self

* ============================================================================
* FUNCTION TSBrowse RSetSkip() Version 9.0 Nov/30/2009
* ============================================================================

STATIC FUNCTION RSetSkip( oRSet, n )

   Local nRecNo := oRSet:AbsolutePosition

   oRSet:Move( n )

   If oRSet:Eof()
      oRSet:MoveLast()
   ElseIf oRSet:Bof()
      oRSet:MoveFirst()
   EndIf

Return oRSet:AbsolutePosition - nRecNo

* ============================================================================
* FUNCTION TSBrowse RSetLocate() Version 9.0 Nov/30/2009
* ============================================================================

Static Function RSetLocate( oTb, cFindCriteria, lDescend, lContinue  )
   Local nRecNo
   LOCAL oRSet := oTb:oRSet
   DEFAULT lDescend := .f. , lContinue := .t.
   nRecNo := oRSet:AbsolutePosition
   IF !lContinue
      oRSet:MoveFirst()
   ENDIF
   IF lDescend
      oRSet:Find( cFindCriteria, 1,adSearchBackward )
   else
      oRSet:Find( cFindCriteria, 1,adSearchForward )
   endif
   If oRSet:Eof()
      Eval(oTb:bGoToPos, nRecNo )
      Tone( 500, 1 )
   ElseIf oRSet:Bof()
      Eval(oTb:bGoToPos, nRecNo )
      Tone( 500, 1 )
   EndIf

Return oRSet:AbsolutePosition - nRecNo

* ============================================================================
* FUNCTION TSBrowse RSetFilter() Version 9.0 Nov/30/2009
* ============================================================================

Static Function RSetFilter( oTb, cFilterCriteria )
   Local nRecNo
   LOCAL oRSet := oTb:oRSet
   nRecNo := oRSet:AbsolutePosition

   IF !Empty(  cFilterCriteria )
      oRSet:Filter := cFilterCriteria
      If oRSet:Eof()
         Tone( 500, 1 )
         oRSet:Filter := adFilterNone
      endif
   ELSE
      oRSet:Filter := adFilterNone
   endif
   nRecNo := oRSet:AbsolutePosition

Return nRecNo

* ============================================================================
* FUNCTION TSBrowse SetHeights() Version 7.0 Jul/15/2004
* ============================================================================

Static Function SetHeights( oBrw )

   Local nEle, nHeight, nHHeight, oColumn, nAt, cHeading, cRest, nOcurs, ;
         hFont, ;
         lDrawFooters := If( oBrw:lDrawFooters != Nil, oBrw:lDrawFooters, .F. )

   Default oBrw:nLineStyle := LINES_ALL

   If oBrw:lDrawHeaders

      nHHeight := oBrw:nHeightHead

      For nEle := 1 TO Len( oBrw:aColumns )

         oColumn := oBrw:aColumns[ nEle ]
         cHeading := If( Valtype( oColumn:cHeading ) == "B", Eval( oColumn:cHeading ), oColumn:cHeading )
         hFont := If( oColumn:hFontHead != Nil, oColumn:hFontHead, oBrw:hFont )
         hFont := If( ValType( hFont ) == "B", Eval( hFont, 0, nEle, oBrw ), hFont )
         hFont := If( hFont == Nil, 0, oBrw:hFont )

         If Valtype( cHeading ) == "C" .and. ;
            ( nAt := At( Chr( 13 ), cHeading ) ) > 0

            nOcurs := 1
            cRest := Substr( cHeading, nAt + 2 )

            While ( nAt := At( Chr( 13 ), cRest ) ) > 0
               nOcurs++
               cRest := Substr( cRest, nAt + 2 )
            EndDo

            nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
            nHeight *= ( nOcurs + 1 )

            If ( nHeight + 1 ) > nHHeight
               nHHeight := nHeight + 1
            EndIf

         ElseIf Valtype( cHeading ) == "C" .and. LoWord( oBrw:aColumns[ nEle ]:nHAlign ) == DT_VERT

            nHeight := GetTextWidth( oBrw:hDC, cHeading, hFont )

            If nHeight > nHHeight
               nHHeight := nHeight
            EndIf

         EndIf

      Next

      oBrw:nHeightHead := nHHeight
   Else
      oBrw:nHeightHead := 0
   EndIf

   If oBrw:lFooting .and. lDrawFooters

      nHHeight := oBrw:nHeightFoot

      For nEle := 1 TO Len( oBrw:aColumns )

         oColumn := oBrw:aColumns[ nEle ]
         cHeading := If( Valtype( oColumn:cFooting ) == "B", Eval( oColumn:cFooting ), oColumn:cFooting )
         hFont := If( oColumn:hFontFoot != Nil, oColumn:hFontFoot, If( oBrw:hFont != Nil, oBrw:hFont, 0 ) )

         hFont := If( ValType( hFont ) == "B", Eval( hFont, 0, nEle, oBrw ), hFont )
         hFont := If( hFont == Nil, 0, oBrw:hFont )

         If Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0

            nOcurs := 1
            cRest := Substr( cHeading, nAt + 2 )

            While ( nAt := At( Chr( 13 ), cRest ) ) > 0
               nOcurs++
               cRest := Substr( cRest, nAt + 2 )
            EndDo

            nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
            nHeight *= ( nOcurs + 1 )

            If ( nHeight + 1 ) > nHHeight
               nHHeight := nHeight + 1
            EndIf

         EndIf

      Next

      oBrw:nHeightFoot := nHHeight
   Else
      oBrw:nHeightFoot := 0
   EndIf

   // Now for cells

   nHHeight := oBrw:nHeightCell

   For nEle := 1 TO Len( oBrw:aColumns )
      oColumn := oBrw:aColumns[ nEle ]
      cHeading := Eval( oColumn:bData )
      hFont := If( oColumn:hFont != Nil, oColumn:hFont, oBrw:hFont )
      hFont := If( ValType( hFont ) == "B", Eval( hFont, 1, nEle, oBrw ), hFont )
      hFont := If( hFont == Nil, 0, oBrw:hFont )

      If ( Valtype( cHeading ) == "C"  .and. At( Chr( 13 ), cHeading ) > 0 ) .or. ;
         ValType( cHeading ) == "M" .or. ( oColumn:cDataType != Nil .and. oColumn:cDataType == "M" )

         Default oBrw:nMemoHV := 2
         nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
         nHeight *= oBrw:nMemoHV
         nHeight += If( oBrw:nLineStyle != 0 .and. oBrw:nLineStyle != 2, 1, 0 )
      Else
         nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
         nHeight += If( oBrw:nLineStyle != 0 .and. oBrw:nLineStyle != 2, 1, 0 )
      EndIf

      nHHeight := Max( nHeight, nHHeight )

   Next

   oBrw:nHeightCell := nHHeight

Return Nil

* ============================================================================
* FUNCTION TSBrowse FileRename() Version 9.0 Nov/30/2009
* ============================================================================

Static Function FileRename( oBrw, cOldName, cNewName, lErase )

   Local nRet, lNew := File( cNewName )

   Default lErase := .T.

   If ! File( cOldName )
      MsgStop( oBrw:aMsg[ 29 ] + CRLF + AllTrim( cOldName ) + oBrw:aMsg[ 30 ], oBrw:aMsg[ 28 ] )
      Return -1
   EndIf

   If lErase .and. lNew

      If FErase(  cNewName  ) < 0
         MsgStop( oBrw:aMsg[ 11 ] + Space( 1 ) + AllTrim( cNewName ), ;
                  oBrw:aMsg[ 28 ] + Space( 1 ) + LTrim( Str( FError() ) ) )
         Return -1
      EndIf

   ElseIf ! lErase .and. lNew
      Return -1
   EndIf

   nRet := MoveFile( cOldName, cNewName )

   If File( cOldName ) .and. File( cNewName )
      FErase( cOldName  )
   EndIf

Return nRet

//--------------------------------------------------------------------------------------------------------------------//

Static Function AdoGenFldBlk( oRS, nFld )

Return { |uVar| If( uVar == Nil, oRs:Fields( nFld ):Value, oRs:Fields( nFld ):Value := uVar ) }

//--------------------------------------------------------------------------------------------------------------------//

Static Function ClipperFieldType( nType )

   Local aNum := { adSmallInt, adInteger, adSingle, adDouble, adUnsignedTinyInt, adTinyInt, adUnsignedSmallInt, ;
                   adUnsignedInt, adBigInt, adUnsignedBigInt, adNumeric, adVarNumeric, adCurrency }, ;
         cType := "C"

   Do Case
      Case AScan( { adChar, adWChar, adVarChar, adVarWChar }, nType ) > 0
         cType := "C"
      Case AScan( aNum, nType ) > 0
         cType := "N"
      Case nType == 11
         cType := "L"
      Case AScan( { adDate, adDBDate }, nType ) > 0
         cType := "D"
      Case nType == adLongVarWChar
         cType := "M"
      Otherwise
         cType := nType
   End Case

Return cType

* ============================================================================
* FUNCTION TSBrowse IdentSuper() Version 7.0
* ============================================================================

Static Function IdentSuper( aHeaders, oBrw )

   Local nI := 1, cSuper, cOldSuper := '', nFromCol := 1, nToCol
   Local aSuperHeaders := {}, nSel := 0

   if oBrw:lSelector
      nSel := 1
   endif

   While nI <= Len( aHeaders )
      If Valtype( aHeaders[ nI ] ) == "C"  .and. At( '~', aHeaders[ nI ] ) > 0
         cSuper := SubStr(aHeaders[ nI ], At( '~', aHeaders[ nI ] )+1)
         aHeaders [nI] := SubStr( aHeaders[ nI ], 1, At( '~', aHeaders[ nI ] )-1 )
      Else
         cSuper := ''
      EndIf
      If !(cOldSuper == cSuper)
         nToCol := nI-1
         AAdd( aSuperHeaders, {cOldSuper, nFromCol+nSel, nToCol+nSel} )
         cOldSuper := cSuper
         nFromCol := nI
      ElseIf nI == Len( aHeaders )
         AAdd( aSuperHeaders, {cOldSuper, nFromCol+nSel, nI+nSel} )
      Endif
      nI++
   EndDo

Return aSuperHeaders

* ============================================================================
* METHOD TSBrowse:RefreshARow() Version 9.0 Nov/30/2009    JP Ver 1.90
* ============================================================================

METHOD RefreshARow( xRow ) CLASS TSBrowse

   Local nRow     := ::nRowPos, nSkip, ;
         nRows    := ::nRowCount(), ;
         nLine    := 1, ;
         nAt      := ::nAt

   Default xRow := nAt

   if xRow == nAt
      ::Refresh( .F. )
   elseif xRow >= nAt - nRow + 1 .and. xRow <= nAt + nRows - nRow
      nLine := xRow - (nAt -nRow )
      nSkip :=   nline - nRow
      ::Skip( nSkip )
      ::DrawLine( nLine )
      ::Skip( -nSkip )
   endif

RETURN nil

* ============================================================================
* METHOD TSBrowse:UpAStable() Version 9.0 Nov/30/2009
* ============================================================================

METHOD UpAStable() CLASS TSBrowse

   Local nRow     := ::nRowPos, ;
         nRows    := ::nRowCount(), ;
         n        := 1, ;
         lSkip    := .T., ;
         bChange  := ::bChange, ;
         nLastPos := ::nLastPos, ;
         nAt      := ::nAt , ;
         nRecNo

   ::nLen   := Len( ::aArray )
   ::nAt    := Min( ::nLen, ::nAt )
   nRecNo   := ::aArray[ ::nAt ]

   If ::nLen > nRows

      nAt += ( nRows - nRow )

      If nAt >= ::nLen
         Eval( ::bGoBottom )
         ::nRowPos := nRows

         While ::nRowPos > 1 .and. ! lAEqual( ::aArray[ ::nAt ], nRecNo )
            ::Skip( -1 )
            ::nRowPos --
         EndDo

         ::Refresh( .F. )
         ::ResetVScroll()
         Return Self
      EndIf
   EndIf

   ::bChange    := Nil
   ::lHitTop    := .F.
   ::lHitBottom := .F.
   Eval( ::bGoTop )

   While ! ::Eof()

      If n > nRows
         ::nRowPos := nRow
         lSkip     := .F.
         Exit
      EndIf

      If lAEqual( ::aArray[ ::nAt ], nRecNo )
         ::nRowPos := n
         Exit
      Else
         ::Skip( 1 )
      EndIf

      n++
   Enddo

   If lSkip
      ::Skip( -::nRowPos )
   EndIf

   ::nLastPos := nLastPos
   ::nAt := AScan( ::aArray, {|e| lAEqual( e, nRecNo ) } )
   ::lHitTop  := .F.

   If  ::oVScroll != Nil .and. nRow != ::nRowPos
      ::oVScroll:SetPos(  ::RelPos(  ::nLogicPos() ) )
   EndIf

   ::bChange := bChange

   If ::lPainted
      ::Refresh( If( ::nLen < nRows, .T., .F. ) )
   EndIf

Return Self

* =================================================================================
* METHOD TSBrowse:lSeek() Version 9.0 Nov/30/2009 dichotomic search with recordsets
* =================================================================================

METHOD lRSeek( uData, nFld, lSoft ) CLASS TSBrowse

   Local nCen, ;
         lFound := .F., ;
         nInf   := 1, ;
         nSup   := ::nLen, ;
         nRecNo := Eval( ::bKeyNo )

   Default lSoft := .F.

   While nInf <= nSup
      nCen := Int( ( nSup + nInf ) / 2 )
      Eval( ::bGoToPos, nCen )

      If ( lFound := If( lSoft, uData = ::oRSet:Fields( nFld ):Value, uData == ::oRSet:Fields( nFld ):Value ) )
         Exit
      ElseIf uData > ::oRSet:Fields( nFld ):Value
         nInf := nCen + 1
      Else
         nSup := nCen - 1
      EndIf
   EndDo

   If ! lFound
      Eval( ::bGoToPos, nRecNo )
   EndIf

Return lFound

* ================================================================================
* METHOD TSBrowse:UpRStable() Version 9.0 Nov/30/2009 recorset cursor repositioned
* ================================================================================

METHOD UpRStable( nRecNo ) CLASS TSBrowse

   Local nRow     := ::nRowPos, ;
         nRows    := ::nRowCount(), ;
         n        := 1, ;
         lSkip    := .T., ;
         bChange  := ::bChange, ;
         nLastPos := ::nLastPos, ;
         cField   := Substr( ::oRSet:Sort, 1, At( " ", ::oRSet:Sort ) - 1 ), ;
         lFilter  := !Empty(::oRSet:Filter )
   Eval( ::bRecNo, nRecNo )
   If ::nLen > nRows
      ::oRSet:Move( nRows - nRow )

      If Eval(::bBof)              //::EoF()
         Eval( ::bGoBottom )
         ::nRowPos := nRows
         While ::nRowPos > 1 .and. nRecNo != Eval( ::bRecNo )
            ::Skip( -1 )
            ::nRowPos --
         EndDo

         ::Refresh( .F. )
         ::ResetVScroll()
         Return Self
      Else
         Eval( ::bGoToPos, nRecNo )
      EndIf

   EndIf

   ::bChange    := Nil
   ::lHitTop    := .F.
   ::lHitBottom := .F.
   ::GoTop()

   While ! ::EoF()

      If n > nRows
         ::nRowPos := nRow
         lSkip     := .F.
         Exit
      EndIf

      If nRecNo == Eval( ::bRecNo )
         ::nRowPos := n
         Exit
      Else
         ::Skip( 1 )
      EndIf

      n++
   Enddo

   If lSkip
      ::Skip( -::nRowPos )
   EndIf

   Eval( ::bRecNo, nRecNo )  // restores Record position
   ::nLastPos := nLastPos
   ::nAt      := ::nLastnAt := ::nLogicPos()
   ::lHitTop  := .F.

   If ::oVScroll != Nil .and. ! Empty( ::bKeyNo )     // restore scrollbar thumb
      ::oVScroll:SetPos( ::RelPos( ( ::cAlias )->( Eval( ::bKeyNo ) ) ) )
   EndIf

   ::bChange := bChange

   If ::lPainted
      ::Refresh( If( ::nLen < nRows, .T., .F. ) )
   EndIf

Return Self

* ===================================================================================================
* METHOD TSBrowse:nField() Version 9.0 Nov/30/2009 returns field number from field name in recordsets
* ===================================================================================================

METHOD nField( cName ) CLASS TSBrowse

   Local nEle, ;
         nCount := ::oRSet:Fields:Count()

   For nEle := 1 To nCount
      If Upper( ::oRSet:Fields( nEle - 1 ):Name ) == Upper( cName )
         Exit
      EndIf
   Next

Return If( nEle <= nCount, nEle - 1, -1 )

//--------------------------------------------------------------------------------------------------------------------//

CLASS TSBcell 
  
  VAR nRow       AS NUMERIC  INIT 0 
  VAR nCol       AS NUMERIC  INIT 0 
  VAR nWidth     AS NUMERIC  INIT 0 
  VAR nHeight    AS NUMERIC  INIT 0 
   
  METHOD New()   INLINE ( Self ) 
  
ENDCLASS 
  
//--------------------------------------------------------------------------------------------------------------------//
  
* ===================================================================================================
* METHOD TSBrowse:GetCellInfo() returns the cell coordinates for auxiliary TSBcell class
* ===================================================================================================

METHOD GetCellInfo( nRowPos, nCell, lColSpecHd ) CLASS TSBrowse

   Local nI, ix, nStartX := 0, oCol, cBrw, cForm
   Local nRow, nCol, nWidth, nHeight
   Local oCell := TSBcell():New()

   Default nRowPos    := ::nRowPos, ;
           nCell      := ::nCell, ;
           lColSpecHd := .F.

   cForm := ::cParentWnd
   cBrw  := ::cControlName
   oCol  := ::aColumns[ nCell ]

   If ::nFreeze > 0
      For nI := 1 To Min( ::nFreeze , nCell - 1 )
         nStartX += ::GetColSizes()[ nI ]
      Next
   EndIf

   For nI := ::nColPos To nCell - 1
      nStartX += ::GetColSizes()[ nI ]
   Next

   if lColSpecHd
      nRow    := ::nHeightHead + ::nHeightSuper + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 1 )
      nHeight := ::nHeightSpecHd - If( oCol:l3DLook, 1, -1 )
   else
      nRow    := nRowPos - 1
      nRow    := ( nRow * ::nHeightCell ) + ::nHeightHead + ;
                 ::nHeightSuper + ::nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 0 )
      nHeight := ::nHeightCell - If( oCol:l3DLook, 1, -1 )
   endif

   ix := GetControlIndex ( cBrw, cForm )
   if _HMG_aControlContainerRow [ix] == -1
      nRow += ::nTop - 1
      nCol += ::nLeft
   else
      nRow += _HMG_aControlRow [ix] - 1
      nCol += _HMG_aControlCol [ix]
   endif

   nRow    += ::aEditCellAdjust[1]
   nCol    += ::aEditCellAdjust[2]
   nWidth  += ::aEditCellAdjust[3] + 2
   nHeight += ::aEditCellAdjust[4]

   oCell:nRow    := nRow
   oCell:nCol    := nCol
   oCell:nWidth  := nWidth
   oCell:nHeight := nHeight

Return oCell

* ============================================================================
* FUNCTION lAEqual() Version 9.0 Nov/30/2009 arrays comparison
* ============================================================================

Function lAEqual( aArr1, aArr2 )

   Local nEle

   If Empty( aArr1 ) .and. Empty( aArr2 )
      Return .T.
   ElseIf Empty( aArr1 ) .or. Empty( aArr2 )
      Return .F.
   ElseIf ValType( aArr1 ) != "A" .or. ValType( aArr2 ) != "A"
      Return .F.
   ElseIf Len( aArr1 ) != Len( aArr2 )
      Return .F.
   EndIf

   For nEle := 1 To Len( aArr1 )

      If ValType( aArr1[ nEle ] ) == "A" .and. ! lAEqual( aArr1[ nEle ], aArr2[ nEle ] )
         Return .F.
      ElseIf ValType( aArr1[ nEle ] ) != ValType( aArr2[ nEle ] )
         Return .F.
      ElseIf ! ( aArr1[ nEle ] == aArr2[ nEle ] )
         Return .F.
      EndIf
   Next

Return .T.

//--------------------------------------------------------------------------------------------------------------------//

Function StockBmp( uAnsi, oWnd, cPath, lNew )

   Local cBmp, nHandle, nWrite, hBmp, cBmpFile, cName, ;
         cTmp := AllTrim( GetEnv( "TMP" ) )

   Local aStock := { "42 4D F6 00 00 00 00 00 00 00 76 00 00 00 28 00" + ; // calendar
                     "00 00 10 00 00 00 10 00 00 00 01 00 04 00 00 00" + ;
                     "00 00 80 00 00 00 C4 0E 00 00 C4 0E 00 00 00 00" + ;
                     "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
                     "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
                     "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
                     "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
                     "00 00 FF FF FF 00 88 88 88 88 88 88 88 88 88 88" + ;
                     "88 88 88 88 88 88 88 77 77 77 77 77 77 78 80 00" + ;
                     "00 00 00 00 00 08 80 77 77 77 07 77 77 08 80 FF" + ;
                     "FF F7 FF FF FF 08 80 FF FF F7 FF FF FF 08 80 F0" + ;
                     "00 07 F0 00 0F 08 80 F9 99 F7 FF 99 9F 08 80 FF" + ;
                     "9F F7 FF 99 FF 08 80 FF 9F F7 FF F9 9F 08 80 F9" + ;
                     "9F 00 0F 99 9F 08 80 F9 9F F7 FF 99 9F 08 80 FF" + ;
                     "FF F7 FF FF FF 08 80 00 00 08 00 00 00 08 88 88" + ;
                     "88 88 88 88 88 88", ;
                     "42 4D F6 00 00 00 00 00 00 00 76 00 00 00 28 00" + ; // spinner
                     "00 00 10 00 00 00 10 00 00 00 01 00 04 00 00 00" + ;
                     "00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
                     "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
                     "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
                     "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
                     "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
                     "00 00 FF FF FF 00 FF FF FF FF FF FF FF FF FE EE" + ;
                     "EE EE EE EE EE FF EE EE EE E6 EE EE EE EF EE EE" + ;
                     "EE 66 6E EE EE EF EE EE E6 66 66 EE EE EF EE EE" + ;
                     "66 6E 66 6E EE EF EE EE EE EE EE EE EE EF 88 88" + ;
                     "88 88 88 88 88 8F EE EE EE EE EE EE EE EF EE EE" + ;
                     "66 6E 66 6E EE EF EE EE E6 66 66 EE EE EF EE EE" + ;
                     "EE 66 6E EE EE EF EE EE EE E6 EE EE EE EF EE EE" + ;
                     "EE EE EE EE EE EF FE EE EE EE EE EE EE FF FF FF" + ;
                     "FF FF FF FF FF FF", ;
                     "42 4D F6 00 00 00 00 00 00 00 76 00 00 00 28 00" + ; // selector
                     "00 00 10 00 00 00 10 00 00 00 01 00 04 00 00 00" + ;
                     "00 00 80 00 00 00 C4 0E 00 00 C4 0E 00 00 00 00" + ;
                     "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
                     "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
                     "00 00 C0 C0 C0 00 80 80 80 00 00 00 FF 00 00 FF" + ;
                     "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
                     "00 00 FF FF FF 00 77 77 77 77 77 77 77 77 77 77" + ;
                     "77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77" + ;
                     "77 70 77 77 77 77 77 77 77 70 07 77 77 77 77 77" + ;
                     "77 70 00 77 77 77 77 77 77 70 00 07 77 77 77 77" + ;
                     "77 70 00 00 77 77 77 77 77 70 00 00 07 77 77 77" + ;
                     "77 70 00 00 77 77 77 77 77 70 00 07 77 77 77 77" + ;
                     "77 70 00 77 77 77 77 77 77 70 07 77 77 77 77 77" + ;
                     "77 70 77 77 77 77 77 77 77 77 77 77 77 77 77 77" + ;
                     "77 77 77 77 77 77", ;
                     "42 4D DE 00 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // sort ascend
                     "00 00 0D 00 00 00 0D 00 00 00 01 00 04 00 00 00" + ;
                     "00 00 68 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
                     "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
                     "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
                     "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
                     "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
                     "00 00 FF FF FF 00 88 88 88 88 88 88 80 00 88 88" + ;
                     "88 88 88 88 80 00 88 88 88 88 88 88 80 00 88 87" + ;
                     "FF FF FF F8 80 00 88 87 78 88 8F F8 80 00 88 88" + ;
                     "78 88 8F 88 80 00 88 88 77 88 FF 88 80 00 88 88" + ;
                     "87 88 F8 88 80 00 88 88 87 7F F8 88 80 00 88 88" + ;
                     "88 7F 88 88 80 00 88 88 88 88 88 88 80 00 88 88" + ;
                     "88 88 88 88 80 00 88 88 88 88 88 88 80 00", ;
                     "42 4D DE 00 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // sort descend
                     "00 00 0D 00 00 00 0D 00 00 00 01 00 04 00 00 00" + ;
                     "00 00 68 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
                     "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
                     "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
                     "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
                     "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
                     "00 00 FF FF FF 00 88 88 88 88 88 88 80 00 88 88" + ;
                     "88 88 88 88 80 00 88 88 88 88 88 88 80 00 88 88" + ;
                     "88 7F 88 88 80 00 88 88 87 7F F8 88 80 00 88 88" + ;
                     "87 88 F8 88 80 00 88 88 77 88 FF 88 80 00 88 88" + ;
                     "78 88 8F 88 80 00 88 87 78 88 8F F8 80 00 88 87" + ;
                     "77 77 77 F8 80 00 88 88 88 88 88 88 80 00 88 88" + ;
                     "88 88 88 88 80 00 88 88 88 88 88 88 80 00", ;
                     "42 4D 4E 01 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // check box checked
                     "00 00 12 00 00 00 12 00 00 00 01 00 04 00 00 00" + ;
                     "00 00 D8 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
                     "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
                     "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
                     "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
                     "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
                     "00 00 FF FF FF 00 88 88 88 88 88 88 88 88 88 00" + ;
                     "00 00 8F FF FF FF FF FF FF FF F8 00 00 00 8F 00" + ;
                     "00 00 00 00 00 00 F8 00 00 00 8F 08 88 88 88 88" + ;
                     "88 80 F8 00 00 00 8F 08 88 8F 88 88 88 80 F8 00" + ;
                     "00 00 8F 08 88 F0 F8 88 88 80 F8 00 00 00 8F 08" + ;
                     "8F 00 0F 88 88 80 F8 00 00 00 8F 08 F0 08 00 F8" + ;
                     "88 80 F8 00 00 00 8F 08 00 88 80 0F 88 80 F8 00" + ;
                     "00 00 8F 08 88 88 88 00 F8 80 F8 00 00 00 8F 08" + ;
                     "88 88 88 80 0F 80 F8 00 00 00 8F 08 88 88 88 88" + ;
                     "00 F0 F8 00 00 00 8F 08 88 88 88 88 80 80 F8 00" + ;
                     "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
                     "88 88 88 88 88 80 F8 00 00 00 8F 00 00 00 00 00" + ;
                     "00 00 F8 00 00 00 8F FF FF FF FF FF FF FF F8 00" + ;
                     "00 00 88 88 88 88 88 88 88 88 88 00 00 00", ;
                     "42 4D 4E 01 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // check box unchecked
                     "00 00 12 00 00 00 12 00 00 00 01 00 04 00 00 00" + ;
                     "00 00 D8 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
                     "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
                     "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
                     "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
                     "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
                     "00 00 FF FF FF 00 88 88 88 88 88 88 88 88 88 00" + ;
                     "00 00 8F FF FF FF FF FF FF FF F8 00 00 00 8F 00" + ;
                     "00 00 00 00 00 00 F8 00 00 00 8F 08 88 88 88 88" + ;
                     "88 80 F8 00 00 00 8F 08 88 88 88 88 88 80 F8 00" + ;
                     "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
                     "88 88 88 88 88 80 F8 00 00 00 8F 08 88 88 88 88" + ;
                     "88 80 F8 00 00 00 8F 08 88 88 88 88 88 80 F8 00" + ;
                     "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
                     "88 88 88 88 88 80 F8 00 00 00 8F 08 88 88 88 88" + ;
                     "88 80 F8 00 00 00 8F 08 88 88 88 88 88 80 F8 00" + ;
                     "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
                     "88 88 88 88 88 80 F8 00 00 00 8F 00 00 00 00 00" + ;
                     "00 00 F8 00 00 00 8F FF FF FF FF FF FF FF F8 00" + ;
                     "00 00 88 88 88 88 88 88 88 88 88 00 00 00" }

   Local aStkName  := { "SCalen.bmp", "SSpinn.bmp", "SSelec.bmp", "SSAsc.bmp", "SSDesc.bmp", "SCheck.bmp", "SUncheck.bmp" }

   Default uAnsi := aStock[ 1 ], ;
           cPath := "", ;
           lNew  := .F.

   HB_SYMBOL_UNUSED( oWnd )

   If ValType( uAnsi ) == "N" .and. uAnsi <= Len( aStkName )
      cName := aStkName[ uAnsi ]
      uAnsi := StrTran( aStock[ uAnsi ], " " )
   ElseIf ValType( uAnsi ) == "N"
      uAnsi := StrTran( aStock[ 1 ], " " )  // calendar
      cName := aStkName[ 1 ]
   Else
      uAnsi := StrTran( uAnsi, " " )
      cName := If( ! Empty( cPath ) .and. ".BMP" $ Upper( cPath ), "", "STmp.bmp" )
   EndIf

   cBmp := cAnsi2Bmp( uAnsi )

   If Empty( cTmp )
      If Empty( cTmp := AllTrim( GetEnv( "TEMP" ) ) )
         cTmp := CurDir()
      EndIf
   EndIf

   cBmpFile := If( ! Empty( cPath ), cPath + If( Right( cPath ) != "\", "\", "" ), cTmp + "\" ) + cName
   cBmpFile := StrTran( cBmpFile, "\\", "\" )

   If ! File( cBmpFile )

      If ( nHandle := FCreate( cBmpFile ) ) < 0
         Return Nil
      EndIf

      nWrite := FWrite( nHandle, cBmp, Len( cBmp ) )

      If nWrite < Len( cBmp )
         FClose( nHandle )
         Return Nil
      EndIf

      FClose( nHandle )
   EndIf

   hBmp := LoadImage( cBmpFile )

   FErase( cBmpFile )

Return hBmp

* ============================================================================
* FUNCTION cAnsi2Bmp() Version 9.0 Nov/30/2009
* ============================================================================

Static Function cAnsi2Bmp( cAnsi )

   Local cLong, ;
         cBmp := ""

   While Len( cAnsi ) >= 8
      cLong := Left( cAnsi, 8 )
      cBmp += cHex2Bin( cAnsi2Hex( cLong ) )
      cAnsi := Stuff( cAnsi, 1, 8, "" )
   EndDo

   If ! Empty( cAnsi )
      cBmp += cHex2Bin( cAnsi2Hex( PadR( cAnsi, 4, "0" ) ) )
   EndIf

Return cBmp

* ============================================================================
* FUNCTION cAnsi2Hex() Version 9.0 Nov/30/2009
* ============================================================================

Static Function cAnsi2Hex( cAnsi )

   Local cDig, ;
         cHex := ""

   cAnsi := AllTrim( cAnsi )

   While Len( cAnsi ) >= 2
      cDig := Left( cAnsi, 2 )
      cHex := cDig + cHex
      cAnsi := Stuff( cAnsi, 1, 2, "" )
   EndDo

Return cHex

* ============================================================================
* FUNCTION cHex2Bin() Version 9.0 Nov/30/2009
* ============================================================================

Static Function cHex2Bin( cHex )

   Local nPos, nEle, ;
         nExp := 0, ;
         nDec := 0, ;
         aHex := { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" }

   cHex := AllTrim( cHex )

   For nPos := Len( cHex ) To 1 Step -1
      nEle := Max( 0, AScan( aHex, SubStr( cHex, nPos, 1 ) ) - 1 )
      nDec += ( nEle * ( 16 ** nExp ) )
      nExp ++
   Next

Return If( Len( cHex ) > 4, L2Bin( Int( nDec ) ), If( Len( cHex ) > 2, I2Bin( Int( nDec ) ), Chr( Int( nDec ) ) ) )

* ============================================================================
* FUNCTION nBmpWidth() Version 9.0 Nov/30/2009
* ============================================================================

Static Function nBmpWidth( hBmp )

Return GetBitmapSize( hBmp ) [1]

* ============================================================================
* FUNCTION _nColumn() Version 9.0 Nov/30/2009
* ============================================================================

Function _nColumn( oBrw, cName ) 

Return Max( AScan( oBrw:aColumns, { |oCol| Upper( oCol:cName ) == Upper( cName ) } ), 1 )

* ============================================================================
* FUNCTION SBrowse() Version 9.0 Nov/30/2009
* ============================================================================

Function SBrowse( uAlias, cTitle, bSetUp, aCols, nWidth, nHeight, lSql ) // idea from xBrowse

   Local cFormName, oBrw, nSaveSelect, cDbf, cAlias, lEdit, cTable

   DEFAULT  uAlias  := Alias(), ;
            cTitle  := If( ValType( uAlias ) == "C", uAlias, "SBrowse"  ), ;
            bSetUp  := { || .F. }, ;
            aCols   := {}, ;
            nWidth  := GetSysMetrics( 0 ) * .75, ;
            nHeight := GetSysMetrics( 1 ) / 2,;
            lSql    := .f.

   If ValType( uAlias ) == 'C' .and. Select( uAlias ) == 0
      nSaveSelect := Select()
      if lSql
         cTable := GetUniqueName( "SqlTable" )

         DBUSEAREA( .T.,, "SELECT * FROM "+uAlias, cTable ,,, "UTF8")
         Select &cTable

         cAlias := cTable
         uAlias := cAlias
      else

         cDbf   := uAlias
         cAlias := uAlias
         Try
            DbUseArea( .T., nil, cDbf, cAlias, .T. )
            uAlias := cAlias
         Catch
            uAlias := { { uAlias } }
         End
      endif
   ElseIf ValType( uAlias ) == 'N'

      If ! Empty( Alias( uAlias ) )
         uAlias := Alias( uAlias )
      Else
         uAlias := { { uAlias } }
      EndIf
   ElseIf ValType( uAlias ) $ 'BDLP'
      uAlias := { { uAlias } }
#ifdef __XHARBOUR__
   ElseIf ValType( uAlias ) == "H"
      uAlias := aHash2Array( uAlias )
#endif
   EndIf

   cFormName := GetUniqueName( "SBrowse" )

   DEFINE WINDOW &cFormName AT 0,0 WIDTH nWidth HEIGHT nHeight TITLE cTitle CHILD BACKCOLOR RGB( 191, 219, 255 )

      nWidth  -= 20
      nHeight -= 50
      DEFINE TBROWSE oBrw AT 10, 10 ALIAS (uAlias) WIDTH nWidth - 16 HEIGHT nHeight - 30 HEADER aCols ;
             AUTOCOLS SELECTOR 20

         lEdit := Eval( bSetUp, oBrw )
         lEdit := If( ValType( lEdit ) == "L", lEdit, .F. )

         With Object oBrw
            :nTop      := 10
            :nLeft     := 10
            :nBottom   := :nTop + nHeight - 30
            :nRight    := :nLeft + nWidth - 16
            :lEditable := lEdit
            :lCellBrw  := lEdit
            :nClrLine  := COLOR_GRID
            :nClrHeadBack := { CLR_WHITE, COLOR_GRID }
            :lUpdate   := .T.
            :bRClicked := {|| RecordBrowse( oBrw ) }
            If lEdit
               AEval( :aColumns, { |o| o:lEdit := .T. } )
            EndIf
         End With

      END TBROWSE

      @ nHeight-12-iif(_HMG_IsXPorLater,3,0), 10 BUTTON Btn_1 CAPTION oBrw:aMsg[ 44 ] WIDTH 70 HEIGHT 24 ;
         ACTION {|| oBrw:Report(cTitle,,,,.t.), oBrw:GoTop() }

      @ nHeight-12-iif(_HMG_IsXPorLater,3,0), 90 BUTTON Btn_2 CAPTION "Excel" WIDTH 70 HEIGHT 24 ;
         ACTION oBrw:ExcelOle()

      @ nHeight-12-iif(_HMG_IsXPorLater,3,0),nWidth-76 BUTTON Btn_3 CAPTION oBrw:aMsg[ 45 ] WIDTH 70 HEIGHT 24 ;
         ACTION ThisWindow.Release

      If ! lEdit
         ON KEY ESCAPE ACTION ThisWindow.Release
      EndIf

   END WINDOW
   CENTER WINDOW &cFormName
   ACTIVATE WINDOW &cFormName

   If ! Empty( cAlias )
      ( cAlias )->( DbCloseArea() )
   EndIf

   If ! Empty( nSaveSelect )
      Select( nSaveSelect )
   EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------//

Static Function RecordBrowse( oBrw )

   Local oCol, ;
         aArr := {}

   For Each oCol In oBrw:aColumns
      AAdd( aArr, { oCol:cHeading, Eval( oCol:bData ) } )
   Next

   SBrowse( aArr, "Record View", { || .T. }, { "Key", "Value" } )

Return Nil

#ifdef __XHARBOUR__
Static Function aHash2Array( uAlias ) // a fivetechsoft sample routine

   Local nEle, ;
         aArr := {}

   For nEle := 1 To Len( uAlias )
      AAdd( aArr, { HGetKeyAt( uAlias, nEle ), HGetValueAt( uAlias, nEle ) } )
   Next

Return aArr
#endif
