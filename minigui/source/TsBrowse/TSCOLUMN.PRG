*===========================================================================
* TSColumn.PRG Version 9.0 Nov/01/2009
*===========================================================================

#ifdef __XHARBOUR__
#define __SYSDATA__
#endif
#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

CLASS TSColumn

   CLASSDATA aProperties INIT { "cHeading", "cPicture", "nWidth" }
   CLASSDATA aEvents     INIT { "OnEdit" }

   DATA aColors                                  // Column's Color Kit
   DATA aColorsBack                              // Column's Color saved   JP 1.55
   DATA aItems                                   // shown data used by combobox on editing
   DATA aData                                    // update data used by combobox on editing
   DATA aFill                                    // array to autofill text on editing
   DATA aBitMaps                                 // array with bitmaps handles
   DATA aCheck                                   // array to store the checkbox images
   DATA bAction                                  // TBtnGet action
   DATA bChange                                  // Editing changed block
   DATA bCustomEdit                              // Block for custmized data edition
   DATA bData                                    // Mandatory code block to return column data
   DATA bDown                                    // Editing optional spinner bDown movement
   DATA bEditing                                 // Block to be evaluated when editing starts
   DATA bEditEnd                                 // Block to be evaluated when editing success
   DATA bExtEdit                                 // Block for external data edition
   DATA bGotFocus                                // Evaluated when column gains focus
   DATA bFLClicked                               // Block to be evaluated on footer left clicked
   DATA bFRClicked                               // Block to be evaluated on footer right clicked
   DATA bHLClicked                               // Block to be evaluated on header left clicked
   DATA bHRClicked                               // Block to be evaluated on header right clicked
   DATA bSLClicked                               // Block to be evaluated on Special header left clicked
   DATA bSRClicked                               // Block to be evaluated on Special header right clicked
   DATA bLClicked                                // Block to be evaluated on cell left clicked
   DATA bLostFocus                               // Evaluated when column loses focus
   DATA bMax                                     // Editing optional spinner bMax value
   DATA bMin                                     // Editing optional spinner bMin value
   DATA bPassWord                                // evaluated (if present) to permit data edition
   DATA bPrevEdit                                // Action to be performed before editing cell
   DATA bPostEdit                                // Action to be performed after editing cell
   DATA bRClicked                                // Block to be evaluated on cell right clicked
   DATA bUp                                      // Editing optional spinner bUp movement
   DATA bValid                                   // Editing valid block
   DATA bWhen                                    // Editing when block
   DATA bArraySort                               // Block to be evaluated on header dblclicked
   DATA bArraySortDes                            // Block to be evaluated on header dblclicked and
                                                 // descending order flag is true
   DATA Cargo                                    // programmer data
   DATA cAlias                                   // An optional alias for every column
   DATA cData                                    // bData as string
   DATA cDefData                                 // Default bData as string
   DATA cDataType                                // ValType of evaluated bdata
   DATA cError                                   // Bad valid error message
   DATA cFooting                                 // Optional Footing text
   DATA cHeading                                 // Optional Header text
   DATA cSpcHeading                              // Optional Special Header text
   DATA cMsg                                     // Browse message specific to the column
   DATA cMsgEdit                                 // Editing message
   DATA cOrder                                   // index tag name
   DATA cPicture                                 // Optional picture clause
   DATA cPrevEdit                                // bPrevEdit as string
   DATA cPostEdit                                // bPostEdit as string
   DATA cResName                                 // TBtnGet bitmap resource name
   DATA cName                  INIT ""           // An optional column name
   DATA cType                                    // column data type
   DATA cToolTip                                 // tooltip when mouse is over column header //V90
   DATA cValid                                   // bValid as string
   DATA cWhen                                    // bWhen as string
   DATA l3DLook     AS LOGICAL                   // 3D Look for cells
   DATA l3DLookHead AS LOGICAL                   // 3D Look for header
   DATA l3DLookFoot AS LOGICAL                   // 3D Look for footer
   DATA l3DTextCell, l3DTextHead, l3DTextFoot, l3DTextSpcHd    // 3d Text
   DATA lBitMap                                  // Optional bmp flag
   DATA lAdjBmp     AS LOGICAL INIT .F.          // Stretch optional bitmap
   DATA lAdjBmpHead AS LOGICAL INIT .F.          // Stretch optional header bitmap
   DATA lAdjBmpFoot AS LOGICAL INIT .F.          // Stretch optional header bitmap
   DATA lAdjBmpSpcHd AS LOGICAL INIT .F.         // Stretch optional special header bitmap
   DATA lCheckBox   AS LOGICAL                   // Edit with TSBrowse virtual checkbox
   DATA lComboBox   AS LOGICAL                   // Edit with combobox
   DATA lDescend                                 // descending order flag        //V90
   DATA lEdit       AS LOGICAL                   // True if editing is allowable
   DATA lEditSpec   AS LOGICAL INIT .T.          // True if editing special header is allowable
   DATA lEmptyValToChar AS LOGICAL INIT .F.      // True if show of empty string for empty values of D,N,T,L types
   DATA lFixLite    AS LOGICAL                   // Fixed cursor
   DATA lIndexCol   AS LOGICAL                   // index flag for sort of a column via the header's double click
   DATA lMemoRO     AS LOGICAL                   // lets edit memo fields with ReadOnly attribute
   DATA lNoLite     AS LOGICAL                   // True to skip cell during SelectlLine()
   DATA lNoHiLite   AS LOGICAL                   // True to skip cell during SelectlLine()
   DATA lNoMinus    AS LOGICAL INIT .F.   
   DATA lSeek       AS LOGICAL                   // incremental search is available for this column
   DATA lSpinner    AS LOGICAL                   // Editing optional spinner (only Numerics and Dates - others will be ignored)
   DATA lVisible    AS LOGICAL INIT .T.          // flag to display column
   DATA lBtnGet     AS LOGICAL INIT .F.          // flag to display button in column
   DATA lTotal      AS LOGICAL                   // true to automatically totalize the column and show the total at footer   //V90
   DATA lOnGotFocusSelect  AS LOGICAL INIT .F.   // true to send EM_SETSEL message on got focus at cell editing
   DATA lNoDescend  AS LOGICAL INIT .F.          // No descending order flag (only dbf)
   DATA nAlign                                   // Optional Alignement for cell's text
   DATA nBmpWidth   AS NUMERIC                   // TBtnGet bitmap width
   DATA nBParam     AS NUMERIC                   // flag to select parameters in bLClick, bLDblClick
   DATA nClrFore, nClrBack                       // cell colors
   DATA nClrHeadBack, nClrHeadFore               // headers colors
   DATA nClrSpcHdBack, nClrSpcHdFore,nClrSpcHdActive   // special headers colors
   DATA nClrFocuBack, nClrFocuFore               // focused cell colors
   DATA nClrEditBack, nClrEditFore               // editing cell colors
   DATA nClrFootBack, nClrFootFore               // footers colors
   DATA nClrSeleBack, nClrSeleFore               // Focused inactive colors
   DATA nClrOrdeBack, nClrOrdeFore               // order control column colors
   DATA nClr3DLCell, nClr3DLHead, nClr3DLFoot, nClr3DLSpcHd    // light color for 3d text
   DATA nClr3DSCell, nClr3DSHead, nClr3DSFoot, nClr3DSSpcHd    // shadow color for 3d text
   DATA nEditMove   AS NUMERIC                   // post editing cursor movement
   DATA nFAlign                                  // Optional Alignement for footer's text
   DATA nHAlign                                  // Optional Alignement for header's text
   DATA nSAlign                                  // Optional Alignement for Special header's text
   DATA nOpaque     AS NUMERIC                   // nOr( 1=CellBmp, 2=HeadBmp, 4=FootBmp )
   DATA nWidth      AS NUMERIC                   // Optional Width
   DATA uBmpCell                                 // bitmap in cell (oBmp, hBmp or bBlock)
   DATA uBmpFoot                                 // bitmap in footer (oBmp, hBmp or bBlock)
   DATA uBmpHead                                 // bitmap in header (oBmp, hBmp or bBlock)
   DATA uBmpSpcHd                                // bitmap in special header (oBmp, hBmp or bBlock)
   DATA uDefFirstVal                             // default first value for combobox     //V90
   DATA oEdit                                    // Edition object (get, multiget, combobox)
   DATA oEditSpec                                // Edition object of SpecHd
   DATA hFont                                    // cells font
   DATA hFontEdit                                // edition font
   DATA hFontHead                                // header font
   DATA hFontFoot                                // footer font
   DATA hFontSpcHd                               // special header font

   METHOD New( cHeading, bData, cPicture, aColors, aAlign, nWidth, ;
            lBitMap, lEdit, bValid, lNoLite, cOrder, cFooting, ;
            bPrevEdit, bPostEdit, nEditMove, lFixLite, a3DLook, ;
            bWhen, oBrw, cData, cWhen, cValid, cPrevEdit, cPostEdit, cMsg, cToolTip, lTotal, ;
            lSpinner, bUp, bDown, bMin, bMax, cError, cSpcHeading, ;
            cDefData, cName ) CONSTRUCTOR

    METHOD End() VIRTUAL                          // Visual FiveWin 2.0

    METHOD Load( cInfo )
    METHOD Save()                                 // Visual FiveWin 2.0
    METHOD SaveColor()                            //  JP 1.55
    METHOD RestColor()                            //  JP 1.55

ENDCLASS

*=============================================================================
* METHOD TSColumn:New() Version 9.0 Nov/01/2009
*=============================================================================

METHOD New( cHeading, bData, cPicture, aColors, aAlign, nWidth, ;
            lBitMap, lEdit, bValid, lNoLite, cOrder, cFooting, ;
            bPrevEdit, bPostEdit, nEditMove, lFixLite, a3DLook, ;
            bWhen, oBrw, cData, cWhen, cValid, cPrevEdit, cPostEdit, cMsg, cToolTip, lTotal, ;
            lSpinner, bUp, bDown, bMin, bMax, cError, cSpcHeading,;
            cDefData, cName ) CLASS TSColumn

   Local nEle, uAlign, xVar, aList, ;
         aTmpColor := Array( 20 ) , ;
         aTmp3D    := Array( 3 ), ;
         aTmpAlign := Array( 4 ), ;
         lCombo    := .F., ;
         lCheck    := .F.

   If aColors != Nil
      ASize( aColors, 20 )
      Aeval( aColors, { |bColor,n| aTmpColor[ n ] := bColor } )
   Endif

   If a3DLook != Nil
      Aeval( a3DLook, { |l3D,n| aTmp3D[ n ] := l3D } )
   Endif

   If aAlign != Nil
      Aeval( aAlign, { |nAli,n| ;
                       aTmpAlign[ n ] := If( ValType( nAli ) == "N" .or. ;
                       ValType( nAli ) == "B", nAli, ;
                       If( ( xVar := AScan( { "LEFT", "CENTER", "RIGHT", "VERT" }, ;
                           Upper( nAli ) ) ) > 0, xVar - 1, xVar ) ) } )
   Endif

   Default cHeading  := ""            , ;
           bData     := {|| Nil }     , ;
           cData     := "{|| Nil }"   , ;
           cPicture  := Nil           , ;
           lBitMap   := .F.           , ;
           lEdit     := .F.           , ;
           lNoLite   := .F.           , ;
           cOrder    := ""            , ;
           cWhen     := ""            , ;
           bValid    := {|| .T. }     , ;
           cValid    := "{|| .T. }"   , ;
           nEditMove := DT_MOVE_RIGHT , ;        // cursor movement after editing
           lFixLite  := .F.           , ;        // for "double cursor" (permanent) efect (only when lCellBrw == .T.)
           lSpinner     := .F.           , ;
           cPrevEdit    := ""            , ;
           cPostEdit    := ""            , ;
           cSpcHeading  := ""            , ;
           cDefData     := ""            , ;
           lTotal       := .F.           , ;     //V90
           cName        := ""

   If ValType( cHeading ) == "O"
      ::uBmpHead := cHeading
      cHeading := ""
   ElseIf ValType( cHeading ) == "N"
      ::uBmpHead := cHeading
      cHeading := ""
   EndIf

   If ValType( cSpcHeading ) == "O"
      ::uBmpSpcHd := cSpcHeading
      cSpcHeading := ""
   ElseIf ValType( cSpcHeading ) == "N"
      ::uBmpSpcHd := cSpcHeading
      cSpcHeading := ""
   EndIf

   If ValType( lBitMap ) == "C"

      If lBitMap == "BITMAP"
         lBitMap := .T.
      ElseIf "CHECK" $ lBitMap
         lCheck  := .T.
         lBitMap := .F.
      ElseIf "COMBO" $ lBitMap
         lBitMap := .F.
         lCombo  := .T.
      Else
         lBitMap := .F.
      EndIf

   EndIf

   If oBrw == Nil

      Default aTmpColor[ 1 ]  := GetSysColor( COLOR_WINDOWTEXT ), ; // nClrText
              aTmpColor[ 2 ]  := GetSysColor( COLOR_WINDOW )    , ; // nClrPane
              aTmpColor[ 3 ]  := GetSysColor( COLOR_BTNTEXT )   , ; // nClrHeadFore
              aTmpColor[ 4 ]  := GetSysColor( COLOR_BTNFACE )   , ; // nClrHeadBack
              aTmpColor[ 5 ]  := GetSysColor( COLOR_HIGHLIGHTTEXT ), ; // nClrFocuFore
              aTmpColor[ 6 ]  := GetSysColor( COLOR_HIGHLIGHT )     // nClrFocuBack

      Default aTmpColor[ 7 ]  := GetSysColor( COLOR_WINDOWTEXT ), ; // nClrEditFore
              aTmpColor[ 8 ]  := GetSysColor( COLOR_WINDOW )    , ; // nClrEditBack
              aTmpColor[ 9 ]  := GetSysColor( COLOR_BTNTEXT )   , ; // nClrFootFore
              aTmpColor[ 10 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrFootBack
              aTmpColor[ 11 ] := CLR_HGRAY                      , ; // nClrSeleFore  NO focused
              aTmpColor[ 12 ] := CLR_GRAY                       , ; // nClrSeleBack  NO focused
              aTmpColor[ 13 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrOrdeFore
              aTmpColor[ 14 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrLine
              aTmpColor[ 15 ] := CLR_BLACK ,;
              aTmpColor[ 16 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrSupHeadFore
              aTmpColor[ 17 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrSupHeadBack
              aTmpColor[ 18 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrSpecHeadFore
              aTmpColor[ 19 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrSpecHeadBack
              aTmpColor[ 20 ] := CLR_HRED                           // nClrSpecHeadActive

   Else

      Default aTmpColor[ 1 ]  := oBrw:nClrText, ;
              aTmpColor[ 2 ]  := oBrw:nClrPane, ;
              aTmpColor[ 3 ]  := oBrw:nClrHeadFore, ;
              aTmpColor[ 4 ]  := oBrw:nClrHeadBack, ;
              aTmpColor[ 5 ]  := oBrw:nClrFocuFore, ;
              aTmpColor[ 6 ]  := oBrw:nClrFocuBack

      Default aTmpColor[ 7 ]  := oBrw:nClrEditFore, ;
              aTmpColor[ 8 ]  := oBrw:nClrEditBack, ;
              aTmpColor[ 9 ]  := oBrw:nClrFootFore, ;
              aTmpColor[ 10 ] := oBrw:nClrFootBack, ;
              aTmpColor[ 11 ] := oBrw:nClrSeleFore, ;
              aTmpColor[ 12 ] := oBrw:nClrSeleBack, ;
              aTmpColor[ 13 ] := oBrw:nClrOrdeFore, ;
              aTmpColor[ 14 ] := oBrw:nClrOrdeBack, ;
              aTmpColor[ 15 ] := oBrw:nClrLine    , ;
              aTmpColor[ 16 ] := oBrw:nClrHeadFore, ;
              aTmpColor[ 17 ] := oBrw:nClrHeadBack, ;
              aTmpColor[ 20 ] := oBrw:nClrSpcHdActive

      IF oBrw:lEnum
         DEFAULT  aTmpColor[ 18 ] := oBrw:nClrHeadFore, ;
                  aTmpColor[ 19 ] := oBrw:nClrHeadBack
      ELSE
         Default aTmpColor[ 18 ]  := oBrw:nClrEditFore, ;
                 aTmpColor[ 19 ]  := oBrw:nClrEditBack
      endif

      ::hFont      := oBrw:hFont
      ::hFontHead  := If( Empty( oBrw:hFontHead  ), oBrw:hFont, oBrw:hFontHead  ) 
      ::hFontFoot  := If( Empty( oBrw:hFontFoot  ), oBrw:hFont, oBrw:hFontFoot  ) 
      ::hFontEdit  := If( Empty( oBrw:hFontEdit  ), oBrw:hFont, oBrw:hFontEdit  ) 
      ::hFontSpcHd := If( Empty( oBrw:hFontSpcHd ), oBrw:hFont, oBrw:hFontSpcHd ) 

   EndIf

   Default aTmp3D[ 1 ]    := If( oBrw == Nil, .F., oBrw:l3DLook )

   Default aTmp3D[ 2 ]    := aTmp3D[ 1 ], ;
           aTmp3D[ 3 ]    := aTmp3D[ 1 ]

   Default aTmpAlign[ 1 ] := DT_LEFT, ;
           aTmpAlign[ 2 ] := DT_CENTER, ;
           aTmpAlign[ 3 ] := DT_RIGHT,;
           aTmpAlign[ 4 ] := DT_CENTER

   For nEle := 1 TO 4

      If ValType( aTmpAlign[ nEle ] ) == "C"
         uAlign := AScan( { "LEFT", "CENTER", "RIGHT" }, ;
                          {| c |  Upper( aTmpAlign[ nEle ] ) $ c } ) - 1

         uAlign := If( uAlign < 0, DT_LEFT, uAlign )
         aTmpAlign[ nEle ] := uAlign
      Endif

   Next

   For nEle := 1 TO 3

      If ValType( aTmp3D[ nEle ] ) == "C"
         uAlign := AScan( {"T",".T.","SI","YES"}, ;
                          {| c |  Upper( aTmp3D[ nEle ] ) == c } )
         aTmp3D[ nEle ] := If( uAlign > 0, .T., .F. )
      Endif

   Next

   If ValType( Eval( bData ) ) == "O"
      ::uBmpCell := bData
      bData := {||Nil}
      cData := '{||Nil}'
   ElseIf ValType( Eval( bData ) ) == "N" .and. lBitMap
      ::uBmpCell := bData
      bData := {||Nil}
      cData := '{||Nil}'
   EndIf

   If ValType( Eval( bdata ) ) == "A"
      ::bData := Eval( bData )[ 1 ]
      aList := Eval( bData )[ 2 ]
   Else
      ::bData := bData
   Endif

   If aList != Nil

      If ValType( aList[ 1 ] ) == "A"
         ::aItems := aList[ 1 ]
         ::aData  := aList[ 2 ]
      Else
         ::aItems := aList
      EndIf

   EndIf

   If nWidth == Nil

      If oBrw != Nil
         nWidth := SBGetHeight( oBrw:hWnd, If( ::hFont != Nil, ;
                                               ::hFont, 0 ), 1 )
         nEle   := Max( If( LoWord( aTmpAlign[ 2 ] ) == 3, 2, Len( cHeading ) ), ;
                   Len( If( Empty( cPicture ), cValToChar( Eval( ::bData ) ), ;
                   Transform( cValToChar( Eval( ::bData ) ), cPicture ) ) ) )
         nWidth := Round( nWidth * ( nEle + 1 ) * 1.3, 0 )         //V90
      Else
         nWidth := Int( If( ! lBitMap .and. ! lCheck, 0.67 * ;
                   GetTextWidth( 0, Replicate( "B", ;
                   Max( Len( cHeading ), Len( If( Empty( cPicture ), ;
                   cValToChar( Eval( bData ) ), ;
                   Transform( cValToChar( Eval( bData ) ), cPicture ) ) ) ) + ;
                   1 ), 0 ), 16 ) )
      EndIf

    Endif

   ::cOrder       = cOrder
   ::lSeek        = ! Empty( cOrder ) .and. ! lEdit     //V90
   ::cHeading     = cHeading
   ::cFooting     = cFooting
   ::cSpcHeading  = cSpcHeading
   ::cPicture     = cPicture
   ::nAlign       = aTmpAlign[ 1 ]
   ::nHAlign      = aTmpAlign[ 2 ]
   ::nFAlign      = aTmpAlign[ 3 ]
   ::nSAlign      = aTmpAlign[ 4 ]
   ::nWidth       = nWidth
   ::lBitMap      = lBitMap
   ::lEdit        = lEdit
   ::lNoLite      = lNoLite
   ::lNoHilite    = lNoLite
   ::cMsg         = cMsg
   ::cToolTip     = cToolTip       //V90
   ::cMsgEdit     = cMsg
   ::bValid       = bValid
   ::cError       = cError
   ::bPrevEdit    = bPrevEdit
   ::bPostEdit    = bPostEdit
   ::nEditMove    = nEditMove
   ::lFixLite     = lFixLite
   ::l3DLook      = aTmp3D[ 1 ]
   ::l3DLookHead  = aTmp3D[ 2 ]
   ::l3DLookFoot  = aTmp3D[ 3 ]
   ::bWhen        = bWhen
   ::lSpinner     = lSpinner
   ::bUp          = bUp
   ::bDown        = bDown
   ::bMin         = bMin
   ::bMax         = bMax
   ::nClrFore     = aTmpColor[ 1 ]
   ::nClrBack     = aTmpColor[ 2 ]
   ::nClrHeadFore = aTmpColor[ 3 ]
   ::nClrHeadBack = aTmpColor[ 4 ]
   ::nClrFocuFore = aTmpColor[ 5 ]
   ::nClrFocuBack = aTmpColor[ 6 ]
   ::nClrEditFore = aTmpColor[ 7 ]
   ::nClrEditBack = aTmpColor[ 8 ]
   ::nClrFootFore = aTmpColor[ 9 ]
   ::nClrFootBack = aTmpColor[ 10 ]
   ::nClrSeleFore = aTmpColor[ 11 ]
   ::nClrSeleBack = aTmpColor[ 12 ]
   ::nClrOrdeFore = aTmpColor[ 13 ]
   ::nClrOrdeBack = aTmpColor[ 14 ]
   ::nClrSpcHdFore = aTmpColor[ 18 ]
   ::nClrSpcHdBack = aTmpColor[ 19 ]
   ::nClrSpcHdActive = aTmpColor[ 20 ]
   ::nClr3DLCell  = GetSysColor( COLOR_BTNHIGHLIGHT )
   ::nClr3DLHead  = GetSysColor( COLOR_BTNHIGHLIGHT )
   ::nClr3DLFoot  = GetSysColor( COLOR_BTNHIGHLIGHT )
   ::nClr3DSCell  = GetSysColor( COLOR_BTNSHADOW )
   ::nClr3DSHead  = GetSysColor( COLOR_BTNSHADOW )
   ::nClr3DSFoot  = GetSysColor( COLOR_BTNSHADOW )
   ::aColors      = aTmpColor
   ::aColorsBack  = aTmpColor
   ::lIndexCol    = .F.
   ::lAdjBmp      = .F.
   ::lAdjBmpHead  = .F.
   ::lAdjBmpFoot  = .F.
   ::cData        = cData
   ::cDefData     = cDefData
   ::cWhen        = cWhen
   ::cValid       = cValid
   ::cPrevEdit    = cPrevEdit
   ::cPostEdit    = cPostEdit
   ::lComboBox    = lCombo
   ::lCheckBox    = lCheck
   ::cDataType    = ValType( Eval( ::bData ) )
   ::lTotal      := lTotal         //V90
   ::cName       := cName 

   If ! Empty( oBrw ) .and. oBrw:lIsArr
      ::lIndexCol := .T. 
   EndIf 

Return Self

*=============================================================================
* METHOD TSColumn:Load() Version 7.0 15/Jul/2004
*=============================================================================

METHOD Load( cInfo ) CLASS TSColumn

   local nPos := 1, nProps, n, nLen
   local cType

   nProps := Bin2I( SubStr( cInfo, nPos, 2 ) )
   nPos += 2

   for n := 1 to nProps
      nLen  := Bin2I( SubStr( cInfo, nPos, 2 ) )
      nPos += 2
//      cData := SubStr( cInfo, nPos, nLen )
      nPos += nLen
      cType := SubStr( cInfo, nPos++, 1 )
      nLen  := Bin2I( SubStr( cInfo, nPos, 2 ) )
      nPos += 2
//      cBuffer := SubStr( cInfo, nPos, nLen )
      nPos += nLen
      do case
         case cType == "A"
 //JP             OSend( Self, "_" + cData, ARead( cBuffer ) )

         case cType == "O"
//JP              OSend( Self, "_" + cData, ORead( cBuffer ) )

         case cType == "C"
//JP               OSend( Self, "_" + cData, cBuffer )

         case cType == "L"
//JP               OSend( Self, "_" + cData, cBuffer == ".T." )

         case cType == "N"
//JP               OSend( Self, "_" + cData, Val( cBuffer ) )
      endcase
   next

Return Nil

*=============================================================================
* METHOD TSColumn:Save() Version 7.0 15/Jul/2004
*=============================================================================

METHOD Save() CLASS TSColumn

   Local cInfo := "", ;
         oWnd  := &( ::ClassName() + "()" ), ;
         nProps := 0

   oWnd:New()
   oWnd:End()

Return "O" + I2Bin( 2 + Len( ::ClassName() ) + 2 + Len( cInfo ) ) + ;
       I2Bin( Len( ::ClassName() ) ) + ::ClassName() + I2Bin( nProps ) + cInfo

*=============================================================================
* METHOD TSColumn:SaveColor() Version 7.0 Adaption
*=============================================================================

METHOD SaveColor() CLASS TSColumn

   If ::aColorsBack != Nil .AND. ValType(::aColorsBack) == 'A'
      ::aColorsBack[ 1 ] := ::nClrFore
      ::aColorsBack[ 2 ] := ::nClrBack
      ::aColorsBack[ 3 ] := ::nClrHeadFore
      ::aColorsBack[ 4 ] := ::nClrHeadBack
      ::aColorsBack[ 5 ] := ::nClrFocuFore
      ::aColorsBack[ 6 ] := ::nClrFocuBack
      ::aColorsBack[ 7 ] := ::nClrEditFore
      ::aColorsBack[ 8 ] := ::nClrEditBack
      ::aColorsBack[ 9 ] := ::nClrFootFore
      ::aColorsBack[ 10 ] := ::nClrFootBack
      ::aColorsBack[ 11 ] := ::nClrSeleFore
      ::aColorsBack[ 12 ] := ::nClrSeleBack
      ::aColorsBack[ 13 ] := ::nClrOrdeFore
      ::aColorsBack[ 14 ] := ::nClrOrdeBack
      ::aColorsBack[ 18 ] := ::nClrSpcHdFore
      ::aColorsBack[ 19 ] := ::nClrSpcHdBack
      ::aColorsBack[ 20 ] := ::nClrSpcHdActive
   EndIf

RETURN Nil

*=============================================================================
* METHOD TSColumn:RestColor() Version 7.0 Adaption
*=============================================================================

METHOD RestColor() CLASS TSColumn

   If ::aColorsBack != Nil .AND. ValType(::aColorsBack) == 'A'
      ::nClrFore        := ::aColorsBack[ 1 ]
      ::nClrBack        := ::aColorsBack[ 2 ]
      ::nClrHeadFore    := ::aColorsBack[ 3 ]
      ::nClrHeadBack    := ::aColorsBack[ 4 ]
      ::nClrFocuFore    := ::aColorsBack[ 5 ]
      ::nClrFocuBack    := ::aColorsBack[ 6 ]
      ::nClrEditFore    := ::aColorsBack[ 7 ]
      ::nClrEditBack    := ::aColorsBack[ 8 ]
      ::nClrFootFore    := ::aColorsBack[ 9 ]
      ::nClrFootBack    := ::aColorsBack[ 10 ]
      ::nClrSeleFore    := ::aColorsBack[ 11 ]
      ::nClrSeleBack    := ::aColorsBack[ 12 ]
      ::nClrOrdeFore    := ::aColorsBack[ 13 ]
      ::nClrOrdeBack    := ::aColorsBack[ 14 ]
      ::nClrSpcHdFore   := ::aColorsBack[ 18 ]
      ::nClrSpcHdBack   := ::aColorsBack[ 19 ]
      ::nClrSpcHdActive := ::aColorsBack[ 20 ]
   EndIf

RETURN Nil

* ============================================================================
* FUNCTION ColClone() Version 9.0 Adaption
*=============================================================================

Function ColClone(oColS, oBrw)

   Local oCol,  aTmpAlign, ;
        aTmpColor := Array( 20 ) , ;
        aTmp3D    := Array( 3 )

   aTmpAlign := { oColS:nAlign , oColS:nHAlign, oColS:nFAlign, oColS:nSAlign }
   aTmp3D    := { oColS:l3DLook , oColS:l3DLookHead, oColS:l3DLookFoot }

   oCol := TSColumn():New( oColS:cHeading, oColS:bData, oColS:cPicture, oColS:aColors, aTmpAlign, oColS:nWidth, ;
            oColS:lBitMap, oColS:lEdit, oColS:bValid, oColS:lNoLite, oColS:cOrder, oColS:cFooting, ;
            oColS:bPrevEdit, oColS:bPostEdit, oColS:nEditMove, oColS:lFixLite, aTmp3D, ;
            oColS:bWhen, oBrw, oColS:cData, oColS:cWhen, oColS:cValid, oColS:cPrevEdit, oColS:cPostEdit, ;
            oColS:cMsg, oColS:cToolTip, oColS:lTotal, ;
            oColS:lSpinner, oColS:bUp, oColS:bDown, oColS:bMin, oColS:bMax, oColS:cError, ;
            oColS:cSpcHeading, oColS:cDefData, oColS:cName )

Return oCol

* ============================================================================
* FUNCTION BiffRec() Version 9.0 Nov/01/2009
* Excel BIFF record wrappers (Biff2)
* ============================================================================

Function BiffRec( nOpCode, uData, nRow, nCol, lBorder, nAlign, nPic, nFont )

   Local cHead, cBody, aAttr[ 3 ]

   Default lBorder := .F., ;
           nAlign  := 1, ;
           nPic    := 0, ;
           nFont   := 0

   aAttr[ 1 ] := Chr( 64 )
   aAttr[ 2 ] := Chr( ( ( 2 ** 6 ) * nFont ) + nPic )
   aAttr[ 3 ] := Chr( If( lBorder, 120, 0 ) + nAlign )

   Do Case  // in order of apearence

      Case nOpCode == 9 // BOF record
         cHead := I2Bin( 9 ) + ; // opCode
                  I2Bin( 4 )     // body length
         cBody := I2Bin( 2 ) + ; // excel version
                  I2Bin( 16 )    // file type (10h = worksheet)

      Case nOpCode == 12 // 0Ch CALCCOUNT record
         cHead := I2Bin( 12 ) + ; // opCode
                  I2Bin( 2 )      // body length
         cBody := I2Bin( uData )  // iteration count

      Case nOpCode == 13 // 0Dh CALCMODE record
         cHead := I2Bin( 13 ) + ; // opCode
                  I2Bin( 2 )      // body length
         cBody := I2Bin( uData )  // calculation mode

      Case nOpCode == 66 // 42h CODEPAGE record
         cHead := I2Bin( 66 ) + ; // opCode
                  I2Bin( 2 )      // body length
         cBody := I2Bin( uData )  // codepage identifier

      Case nOpCode == 49 // 31h FONT record
         cHead := I2Bin( 49 ) + ; // opCode
                  I2Bin( 5 + Len( uData[ 1 ] ) ) // body length
         cBody := I2Bin( uData[ 2 ] * 20 ) + ;   // font height in 1/20ths of a point
                  I2Bin( nOr( If( uData[ 3 ], 1, 0 ), ; // lBold    //JP nOr
                            If( uData[ 4 ], 2, 0 ), ;   // lItalic
                            If( uData[ 5 ], 4, 0 ), ;   // lUnderline
                            If( uData[ 6 ], 8, 0 ) ) ) + ;  // lStrikeout
                  Chr( Len( uData[ 1 ] ) ) + ;          // length of cFaceName
                  uData[ 1 ]                            // cFaceName

      Case nOpCode == 20 // 14h HEADER record
         cHead := I2Bin( 20 ) + ; // opCode
                  I2Bin( 1 + Len( uData ) ) // body length
         cBody := Chr( Len( uData ) ) + ;
                  uData

      Case nOpCode == 21 // 15h FOOTER record
         cHead := I2Bin( 21 ) + ; // opCode
                  I2Bin( 1 + Len( uData ) ) // body length
         cBody := Chr( Len( uData ) ) + ;
                  uData

      Case nOpCode == 36 // 24h COLWIDTH record
         Default nCol := nRow
         cHead := I2Bin( 36 ) + ;       // opCode
                  I2Bin( 4 )            // body length
         cBody := Chr( nRow ) + ;       // first column
                  Chr( nCol ) + ;       // last column
                  I2BIN( uData * 256 )  // column width in 1/256ths of a character

      Case nOpCode == 31 // 1Fh FORMATCOUNT record
         cHead := I2Bin( 31 ) + ; // opCode
                  I2Bin( 2 )      // body length
         cBody := I2BIN( uData )  // number of standard format records in file

      Case nOpCode == 30 // 1Eh FORMAT record
         cHead := I2Bin( 30 ) + ; // opCode
                  I2Bin( 1 + Len( uData ) ) // body length
         cBody := Chr( Len( uData ) ) + ;   // length of format string
                  uData                     // format string

      Case nOpCode == 4 // 04h LABEL record
         uData := SubStr( uData, 1, Min( 255, Len( uData ) ) )
         cHead := I2Bin( 4 ) + ; // opCode
                  I2Bin( 8 + Len( uData ) ) // body length
         cBody := I2Bin( nRow ) + ; // row number 0 based
                  I2Bin( nCol ) + ; // col number 0 based
                  aAttr[ 1 ]    + ;
                  aAttr[ 2 ]    + ;
                  aAttr[ 3 ]    + ;
                  Chr( Len( uData ) ) + ;
                  uData

      Case nOpCode == 2 // 02h INTEGER record
         cHead := I2Bin( 2 ) + ; // opCode
                  I2Bin( 9 )     // body length
         cBody := I2Bin( nRow ) + ;
                  I2Bin( nCol ) + ;
                  aAttr[ 1 ]    + ;
                  aAttr[ 2 ]    + ;
                  aAttr[ 3 ]    + ;
                  I2Bin( Int( uData ) )

      Case nOpCode == 3 // NUMBER record
         cHead := I2Bin( 3 ) + ; // opCode
                  I2Bin( 15 )    // body length
         cBody := I2Bin( nRow ) + ;
                  I2Bin( nCol ) + ;
                  aAttr[ 1 ]    + ;
                  aAttr[ 2 ]    + ;
                  aAttr[ 3 ]    + ;
                  FTOC( uData )             //D2Bin( uData )

      Case nOpCode == 10 // 0Ah EOF record
         cHead := I2Bin( 10 ) + ; // opcode
                  I2Bin( 0 )      // body length
         cBody := ""

   End Case

Return cHead + cBody

* ============================================================================
* FUNCTION StrCharCount() Version 9.0 Nov/01/2009
* This function does not exist in all versions of FW, so let's define it here
* ============================================================================

Function StrCharCount( cStr, cChr )

   Local nAt, ;
         nCount := 0

   While ! Empty( cStr ) .and. ( nAt := At( cChr, cStr ) ) > 0
      nCount ++
      cStr := SubStr( cStr, nAt + 1 )
   EndDo

Return nCount

* ============================================================================
* FUNCTION StrWBlock() Version 9.0 Nov/01/2009
* Creates a View/Edit code block for a numeric field with a character display
* ============================================================================

Function StrWBlock( cField, nLen, nDec )

   Local bBlock := &( "{|x|If(Pcount()>0," + cField + ":=x,Str(" + cField + ;
                      "," + LTrim( Str( nLen ) ) + If( nDec == Nil, "", ;
                      "," + Ltrim( Str( nDec ) ) ) + "))}" )

Return bBlock


* ============================================================================
* FUNCTION lIsFile() Version 9.0 Nov/01/2009
* Like Clipper's File() function for long file names
* ============================================================================

Function lIsFile( cFile )

   Local nHandle := FOpen( AllTrim( cFile ), 64 )

   If nHandle >= 0
      FClose( nHandle )
      Return .T.
   EndIf

Return .F.

* ============================================================================
* FUNCTION ArrayWBlock() Version 9.0 Nov/01/2009
* Creates a View/Edit code block for array
* ============================================================================

Function ArrayWBlock( oBrw, nEle )

Return {|x| If(PCount() > 0, oBrw:aArray[ oBrw:nAt, nEle ] := x, ;
            oBrw:aArray[ oBrw:nAt, nEle ] ) }

* ============================================================================
* FUNCTION ComboWBlock() Version 9.0 Nov/01/2009
* Creates a View/Edit code block for column combobox
* ============================================================================

Function ComboWBlock( oBrw, uField, nCol, aList )

   Local aItems, aData, bBlock

   If Empty( oBrw ) .or. Empty( uField ) .or. Empty( nCol ) .or. Empty( aList )
      Return Nil
   EndIf

   If Valtype( nCol ) == "C"
      nCol := oBrw:nColumn( nCol )  // 21.07.2015
   EndIf

   If nCol <= Len( oBrw:aColumns )

      If ValType( aList[ 1 ] ) == "A"
         oBrw:aColumns[ nCol ]:aItems := aList[ 1 ]
         oBrw:aColumns[ nCol ]:aData := aList[ 2 ]
         oBrw:aColumns[ nCol ]:cDataType := ValType( aList[ 2, 1 ] )
      Else
         oBrw:aColumns[ nCol ]:aItems := aList
      EndIf

      oBrw:aColumns[ nCol ]:lComboBox := .T.

   Else
      oBrw:aPostList := aList    // block is created before creating the column
   EndIf

   If ValType( aList[ 1 ] ) == "A"
      aItems := aList[ 1 ]
      aData  := aList[ 2 ]
   Else
      aItems := aList
   EndIf

   If oBrw:lIsDbf

      If ValType( uField ) == "C"

         uField := ( oBrw:cAlias )->( FieldPos( uField ) )

         If uField == 0
            Return Nil
         EndIf

      EndIf

      If aData == Nil

         bBlock := {|x| If( PCount() > 0, ( oBrw:cAlias )->( FieldPut( uField, x ) ), ;
                    aItems[ Max( 1, AScan( aItems, ( oBrw:cAlias )->( FieldGet( uField ) ) ) ) ] ) }
      Else

         bBlock := {|x| If( PCount() > 0, ( oBrw:cAlias )->( FieldPut( uField, x ) ), ;
                    If( nCol <= Len( oBrw:aColumns ) .and. ! Empty( oBrw:aColumns[ nCol ]:aItems ), ;
                    oBrw:aColumns[ nCol ]:aItems[ Max( 1, AScan( oBrw:aColumns[ nCol ]:aData, ;
                    ( oBrw:cAlias )->( FieldGet( uField ) ) ) ) ], Nil ) ) }
      EndIf

   Else  // editing an array uField is the array element number

      If ValType( uField ) == "C"
         uField := oBrw:nColumn( uField )  // 21.07.2015
      EndIf

      If aData == Nil

         bBlock := {|x| If( PCount() > 0, ;
                    oBrw:aArray[ oBrw:nAt, uField ] := x, ;
                    aItems[ Max( 1, AScan( aItems, oBrw:aArray[ oBrw:nAt, uField ] ) ) ] ) }
      Else

         bBlock := {|x| If( PCount() > 0, ;
                    oBrw:aArray[ oBrw:nAt, uField ] := x, ;
                    aItems[ Max( 1, AScan( aData, oBrw:aArray[ oBrw:nAt, uField ] ) ) ] ) }
      EndIf

   EndIf

Return bBlock
