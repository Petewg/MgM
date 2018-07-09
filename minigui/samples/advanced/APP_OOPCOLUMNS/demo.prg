/* 
 * MINIGUI - Harbour Win32 GUI library Demo 
 * 
 */ 
  
#include "minigui.ch" 
#include "tsbrowse.ch" 

REQUEST DBFCDX 

FIELD KOD, NAME
FIELD ID, FIRST, LAST, STREET, CITY, STATE, ZIP
FIELD DTDOK, NRDOK, SMDOK, TXDOK, SMTAX, SMITG, ID_E

MEMVAR o_Cols, oKOD, oNAME, oH_A, oS_C_Z, oF_L, oD_N, oK_N, oT_S, oS_T, oS_S
MEMVAR oID, oFIRST, oLAST, oSTREET, oCITY, oSTATE, oZIP, oHIREDATE, oAGE
MEMVAR oDTDOK, oNRDOK, oSMDOK, oTXDOK, oSMTAX, oSMITG, oID_E

*-----------------------------------------------------------------------------*
FUNCTION Main()
*-----------------------------------------------------------------------------*
   LOCAL nY, nX, nW, nH, hSpl, oDoks, oCol
   LOCAL cWnd := 'wMain', aCols := {}
   LOCAL cAlsDoks, cAlsEmpl, cAlsStat
   LOCAL cBrw := 'oDoks'

   SetsEnv()
   IndexDbf()
   BaseCols()

   AAdd(aCols,    oDTDOK:Clone() )
   AAdd(aCols,    oNRDOK:Clone() )
   AAdd(aCols,    oSMDOK:Clone() )
   AAdd(aCols,    oTXDOK:Clone() )
   AAdd(aCols,    oSMTAX:Clone() )
   AAdd(aCols,    oSMITG:Clone() )
   AAdd(aCols,     oID_E:Clone() )
   AAdd(aCols,    oFIRST:Clone() )
   AAdd(aCols,     oLAST:Clone() )
   AAdd(aCols,   oSTREET:Clone() )
   AAdd(aCols,     oCITY:Clone() )
   AAdd(aCols,    oSTATE:Clone() )
   AAdd(aCols,     oNAME:Clone() )
   AAdd(aCols,      oZIP:Clone() )
   AAdd(aCols, oHIREDATE:Clone() )
   AAdd(aCols,      oAGE:Clone() )
   
   MyUse( 'States'  , 'STAT' )
   cAlsStat := Alias()

   MyUse( 'Employee', 'EMPL' )
   SET RELATION TO STATE INTO &cAlsStat
   GO TOP
   cAlsEmpl := Alias()

   MyUse( 'Employ'  , 'DOKS' )
   SET RELATION TO ID_E  INTO &cAlsEmpl
   GO TOP
   cAlsDoks := Alias()    
   
   FOR EACH oCol IN aCols
       WITH OBJECT oCol
       // real alias
       If :cAlias $ cAlsStat; :cAlias := cAlsStat
       EndIf
       If :cAlias $ cAlsEmpl; :cAlias := cAlsEmpl
       EndIf
       If :cAlias $ cAlsDoks; :cAlias := cAlsDoks
       EndIf
       END WITN
   NEXT

   oCol        := o_Cols:Get('OrdKeyNo'):Clone()
   oCol:cAlias := cAlsDoks
   hb_AIns( aCols, 1, oCol, .T. )
   
	DEFINE WINDOW &cWnd AT 0,0 WIDTH 1250 HEIGHT 650  ;
		TITLE 'MiniGUI Demo for TBrowse columns base' ;
		MAIN   NOMAXIMIZE   NOSIZE ; 
		ON RELEASE  dbCloseAll() ;
		ON INTERACTIVECLOSE (This.Object):Action
		
  		DEFINE STATUSBAR BOLD
			STATUSITEM ''           ACTION Nil
			STATUSITEM '' WIDTH  80 ACTION Nil
			STATUSITEM '' WIDTH 400 ACTION Nil
		END STATUSBAR

      DEFINE SPLITBOX HANDLE hSpl
		DEFINE TOOLBAR ToolBar_1 CAPTION  "REPORT" BUTTONSIZE 72,32 FLAT
         BUTTON E0  CAPTION ' '          PICTURE 'cabinet' ACTION Nil ;
                                         SEPARATOR 
			BUTTON 01  CAPTION 'Employee'   PICTURE 'n1'      ACTION wPost(11) ;
                                         SEPARATOR         DROPDOWN
                    DEFINE DROPDOWN MENU BUTTON 01
                       ITEM "Employee"   IMAGE 'n1'        ACTION wPost(11)            
                       ITEM "States"     IMAGE 'n2'        ACTION wPost(12)            
                    END MENU
                                        
			BUTTON 02  CAPTION 'Report 2'   PICTURE 'n2'      ACTION wPost() ;
                                         SEPARATOR 
		END TOOLBAR
		
		DEFINE TOOLBAR ToolBar_2 CAPTION "" BUTTONSIZE 42,32 FLAT
			BUTTON 99  CAPTION 'Exit'   PICTURE 'exit'  ACTION wPost() 
		END TOOLBAR
		END SPLITBOX

      WITH OBJECT This.Object            // ---- Window events
      // ToolBar 1
      :Event( 11, {|ow| Employee(ow)   } )
      :Event( 12, {|ow| States  (ow)   } )
      :Event( 02, {|ow| Report_2(ow)   } )
      // ToolBar 2
      :Event( 99, {|ow| ow:Release()   } )
      END WITH                           // ---- Window events

      nY := GetWindowHeight(hSpl)
      nX := 1
      nW := This.ClientWidth  - nX * 2
      nH := This.ClientHeight - This.StatusBar.Height - nY

      dbSelectArea(cAlsDoks)

      oDoks := Tsb_Create( cBrw, nY, nX, nW, nH, aCols )

      oDoks:SetNoHoles()
      oDoks:SetFocus()
      
	END WINDOW

	CENTER   WINDOW &cWnd
	ACTIVATE WINDOW &cWnd

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION Employee( oWnd )
*-----------------------------------------------------------------------------*
   LOCAL nY, nX, nW, nH, hSpl, oBrw, oCol
   LOCAL cWnd := 'wEmployee', aCols := {}
   LOCAL nAreaOld := Select()
   LOCAL cBrw := 'oBrw'
   LOCAL cAlsEmpl

   If _IsWindowDefined( cWnd )
      _WindowObj(cWnd):SetFocus(cBrw)
      RETURN Nil
   EndIf

   AAdd(aCols,       oID:Clone() )
   AAdd(aCols,    oFIRST:Clone() )
   AAdd(aCols,     oLAST:Clone() )
   AAdd(aCols,   oSTREET:Clone() )
   AAdd(aCols,     oCITY:Clone() )
   AAdd(aCols,      oZIP:Clone() )
   AAdd(aCols, oHIREDATE:Clone() )
   AAdd(aCols,      oAGE:Clone() )

   MyUse( 'Employee', 'EMPL' )
   GO TOP
   cAlsEmpl := Alias()

   FOR EACH oCol IN aCols
       WITH OBJECT oCol
       :cAlias          := Nil
       :cData           := 'FieldWBlock("'+:cField+'", Select(['+cAlsEmpl+']))'
       :bData           :=  FieldWBlock(   :cField   , Select(   cAlsEmpl   ) )
       :lEdit           := :cField != 'ID'
       END WITN
   NEXT
   
	DEFINE WINDOW &cWnd AT 0,0 WIDTH 1250 HEIGHT 650  ;
		TITLE 'MiniGUI Demo for TBrowse columns base.' ;
		MODAL  NOSIZE ; 
		ON RELEASE ( ( cAlsEmpl )->( dbCloseArea() ),  ;
                 dbSelectArea(nAreaOld), wPost(98) ) ; 
		ON INTERACTIVECLOSE (This.Object):Action
		
  		DEFINE STATUSBAR BOLD
			STATUSITEM ''           ACTION Nil
			STATUSITEM '' WIDTH  80 ACTION Nil
			STATUSITEM '' WIDTH 400 ACTION Nil
		END STATUSBAR

      DEFINE SPLITBOX HANDLE hSpl
		DEFINE TOOLBAR ToolBar_1 CAPTION "EMPLOYEE"         BUTTONSIZE 72,32 FLAT
         BUTTON E0  CAPTION ' '         PICTURE 'cabinet' ACTION Nil ;
                                        SEPARATOR 
		END TOOLBAR
		
		DEFINE TOOLBAR ToolBar_2 CAPTION ""                 BUTTONSIZE 42,32 FLAT
			BUTTON 99  CAPTION 'Exit'       PICTURE 'exit'   ACTION wPost() 
		END TOOLBAR
		END SPLITBOX

      WITH OBJECT This.Object            // ---- Window events
      // ToolBar 1
      // Events
      :Event( 98, {|  | oWnd:SetFocus('oDoks') })
      // ToolBar 2
      :Event( 99, {|ow| ow:Release()   } )
      END WITH                           // ---- Window events

      nY := GetWindowHeight(hSpl)
      nX := 1
      nW := This.ClientWidth  - nX * 2
      nH := This.ClientHeight - This.StatusBar.Height - nY

      oBrw := Tsb_Create( cBrw, nY, nX, nW, nH, aCols )

      oBrw:SetNoHoles()
      oBrw:SetFocus()
      
	END WINDOW

	CENTER   WINDOW &cWnd
	ACTIVATE WINDOW &cWnd

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION States( oWnd )
*-----------------------------------------------------------------------------*
   LOCAL nY, nX, nW, nH, hSpl, oBrw, oCol
   LOCAL cWnd := 'wStates', aCols := {}
   LOCAL nAreaOld := Select()
   LOCAL cBrw := 'oBrw'
   LOCAL cAlsStat

   If _IsWindowDefined( cWnd )
      _WindowObj(cWnd):SetFocus(cBrw)
      RETURN Nil
   EndIf

   AAdd(aCols, o_Cols:Get('oKOD'):Clone() )
   AAdd(aCols, o_Cols:Get('oNAME'):Clone() )

   MyUse( 'States', 'STAT' )
   GO TOP
   cAlsStat := Alias()
   nW       := GetVSCrollBarWidth() + 50

   FOR EACH oCol IN aCols
       WITH OBJECT oCol
       :cAlias := Nil
       :cData  := 'FieldWBlock("'+:cField+'", Select(['+cAlsStat+']))'
       :bData  :=  FieldWBlock(   :cField   , Select(   cAlsStat   ) )
       :lEdit  := :cField != 'KOD'
       nW      += :nWidth
       END WITN
   NEXT

	DEFINE WINDOW &cWnd AT 0,0 WIDTH nW   HEIGHT 650  ;
		TITLE 'MiniGUI Demo for TBrowse columns base.' ;
		MODAL  NOSIZE ; 
		ON RELEASE ( ( cAlsStat )->( dbCloseArea() ),  ;
                 dbSelectArea(nAreaOld), wPost(98) ) ; 
		ON INTERACTIVECLOSE (This.Object):Action
		
  		DEFINE STATUSBAR BOLD
			STATUSITEM ''           ACTION Nil
			STATUSITEM '' WIDTH  80 ACTION Nil
			STATUSITEM '' WIDTH 400 ACTION Nil
		END STATUSBAR

      DEFINE SPLITBOX HANDLE hSpl
		DEFINE TOOLBAR ToolBar_1 CAPTION "STATES"           BUTTONSIZE 72,32 FLAT
         BUTTON E0  CAPTION ' '         PICTURE 'cabinet' ACTION Nil ;
                                        SEPARATOR 
		END TOOLBAR
		
		DEFINE TOOLBAR ToolBar_2 CAPTION ""                 BUTTONSIZE 42,32 FLAT
			BUTTON 99  CAPTION 'Exit'      PICTURE 'exit'    ACTION wPost() 
		END TOOLBAR
		END SPLITBOX

      WITH OBJECT This.Object            // ---- Window events
      // ToolBar 1
      // Events
      :Event( 98, {|  | oWnd:SetFocus('oDoks') })
      // ToolBar 2
      :Event( 99, {|ow| ow:Release()   } )
      END WITH                           // ---- Window events

      nY := GetWindowHeight(hSpl)
      nX := 1
      nW := This.ClientWidth  - nX * 2
      nH := This.ClientHeight - This.StatusBar.Height - nY

      oBrw := Tsb_Create( cBrw, nY, nX, nW, nH, aCols )

      oBrw:SetNoHoles()
      oBrw:SetFocus()
      
	END WINDOW

	CENTER   WINDOW &cWnd
	ACTIVATE WINDOW &cWnd

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION Report_2( oWnd )
*-----------------------------------------------------------------------------*
   LOCAL nY, nX, nW, nH, hSpl, oDoks, oCol
   LOCAL cWnd := 'wRpt2', aCols := {}
   LOCAL nAreaOld := Select()
   LOCAL cAlsDoks, cAlsEmpl, cAlsStat
   LOCAL cBrw := 'oDoks'

   If _IsWindowDefined( cWnd )
      _WindowObj(cWnd):SetFocus(cBrw)
      RETURN Nil
   EndIf
   
   AAdd(aCols,      oD_N:Clone() )
   AAdd(aCols,      oS_S:Clone() )
   AAdd(aCols,      oT_S:Clone() )
   AAdd(aCols,     oID_E:Clone() )
   AAdd(aCols,      oF_L:Clone() )
   AAdd(aCols,    oS_C_Z:Clone() )
   AAdd(aCols,    oSTATE:Clone() )
   AAdd(aCols,      oK_N:Clone() )
   AAdd(aCols,      oH_A:Clone() )
   
   MyUse( 'States'  , 'STAT' )
   cAlsStat := Alias()

   MyUse( 'Employee', 'EMPL' )
   SET RELATION TO STATE INTO &cAlsStat
   GO TOP
   cAlsEmpl := Alias()

   MyUse( 'Employ'  , 'DOKS' )
   SET RELATION TO ID_E  INTO &cAlsEmpl
   GO TOP
   cAlsDoks := Alias()    
   
   FOR EACH oCol IN aCols
       WITH OBJECT oCol
       // real alias
       If :cAlias $ cAlsStat; :cAlias := cAlsStat
       EndIf
       If :cAlias $ cAlsEmpl; :cAlias := cAlsEmpl
       EndIf
       If :cAlias $ cAlsDoks; :cAlias := cAlsDoks
       EndIf
       END WITN
   NEXT

   oCol        := o_Cols:Get('OrdKeyNo'):Clone()
   oCol:cAlias := cAlsDoks
   hb_AIns( aCols, 1, oCol, .T. )
   
	DEFINE WINDOW &cWnd AT 0,0 WIDTH 1250 HEIGHT 650  ;
		TITLE 'MiniGUI Demo for TBrowse columns base.' ;
		CHILD  NOMAXIMIZE   NOSIZE ; 
		ON RELEASE ( ( cAlsStat )->( dbCloseArea() ),  ;
                   ( cAlsEmpl )->( dbCloseArea() ),  ;
                   ( cAlsDoks )->( dbCloseArea() ),  ;
                 dbSelectArea(nAreaOld), wPost(98) ) ; 
		ON INTERACTIVECLOSE (This.Object):Action
		
  		DEFINE STATUSBAR BOLD
			STATUSITEM ''           ACTION Nil
			STATUSITEM '' WIDTH  80 ACTION Nil
			STATUSITEM '' WIDTH 400 ACTION Nil
		END STATUSBAR

      DEFINE SPLITBOX HANDLE hSpl
		DEFINE TOOLBAR ToolBar_1 CAPTION "REPORT 2"         BUTTONSIZE 72,32 FLAT
         BUTTON E0  CAPTION ' '         PICTURE 'cabinet' ACTION Nil ;
                                        SEPARATOR 
		END TOOLBAR
		
		DEFINE TOOLBAR ToolBar_2 CAPTION ""                 BUTTONSIZE 42,32 FLAT
			BUTTON 99  CAPTION 'Exit'       PICTURE 'exit'   ACTION wPost() 
		END TOOLBAR
		END SPLITBOX

      WITH OBJECT This.Object            // ---- Window events
      // ToolBar 1
      // Events
      :Event( 98, {|  | oWnd:SetFocus('oDoks') })
      // ToolBar 2
      :Event( 99, {|ow| ow:Release()   } )
      END WITH                           // ---- Window events

      nY := GetWindowHeight(hSpl)
      nX := 1
      nW := This.ClientWidth  - nX * 2
      nH := This.ClientHeight - This.StatusBar.Height - nY

      dbSelectArea(cAlsDoks)

      oDoks := Tsb_Create( cBrw, nY, nX, nW, nH, aCols )

      oDoks:SetNoHoles()
      oDoks:SetFocus()
      
	END WINDOW

	CENTER   WINDOW &cWnd
	ACTIVATE WINDOW &cWnd

RETURN Nil

*----------------------------------------------------------------------------*
FUNC Tsb_Create( cName, nY, nX, nW, nH, aCols, aColors )
*----------------------------------------------------------------------------*
   LOCAL oBrw
   
   If Empty(aColors) .or. ! HB_ISARRAY(aColors)
      aColors := {}
      AAdd(aColors, { CLR_FOCUSB, { |a,b,c| If( c:nCell == b, ;
                    {RGB( 66, 255, 236), RGB(209, 227, 248)}, ;
                    {RGB(220, 220, 220), RGB(220, 220, 220)} ) } } )
   EndIf

   DEFINE TBROWSE &cName OBJ oBrw AT nY, nX ALIAS ALIAS() WIDTH nW HEIGHT nH CELL ;
          COLORS   aColors

   :hFontHead    := GetFontHandle( "FontBold" )
   :hFontFoot    := GetFontHandle( "FontBold" )

   AEval(aCols, {|oc| :AddColumn(oc) })

   :lNoGrayBar   := .T.
   :lNoLiteBar   := .F.
   :nWheelLines  := 1
   :nClrLine     := COLOR_GRID
   :nHeightCell  += 5
   :nHeightHead  := :nHeightCell + 2
   :nHeightFoot  := :nHeightCell + 2
   :lDrawFooters := .T.
   :lFooting     := .T.
   :lNoVScroll   := .F.
   :lNoHScroll   := GetWindowWidth( :hWnd ) > ( :GetAllColsWidth() + GetVSCrollBarWidth() )
   :lNoKeyChar   := .T.
//   :lNoMoveCols := .T.
   :lNoResetPos := .F.
   :lPickerMode := .F.              // usual date format
   :nLineStyle  := LINES_ALL        // LINES_NONE LINES_ALL LINES_VERT LINES_HORZ LINES_3D LINES_DOTTED

   :AdjColumns()
   :ResetVScroll( .T. )
   :oHScroll:SetRange( 0, 0 )

   END TBROWSE

RETURN oBrw

*----------------------------------------------------------------------------*
FUNC SetsEnv()
*----------------------------------------------------------------------------*

   RddSetDefault("DBFCDX") 
  
   SET CENTURY      ON 
   SET DATE         GERMAN 
   SET DELETED      ON 
   SET EXCLUSIVE    ON 
   SET EPOCH TO     2000 
   SET AUTOPEN      ON 
   SET EXACT        ON 
   SET SOFTSEEK     ON 
  
   SET NAVIGATION   EXTENDED 
   SET FONT         TO "Arial", 11 
   SET DEFAULT ICON TO "hmg_ico"

   *--------------------------------
   SET OOP ON
   *--------------------------------

RETURN Nil

*----------------------------------------------------------------------------*
FUNC IndexDbf()
*----------------------------------------------------------------------------*

   If ! hb_FileExists('States'+'.cdx')
      USE States  ALIAS STAT  NEW
      INDEX ON KOD TAG KOD
      USE
   EndIf

   If ! hb_FileExists('Employee'+'.cdx')
      USE Employee  ALIAS BASE  NEW
      INDEX ON ID TAG IDE
      USE
   EndIf
   
   If ! hb_FileExists('Employ'+'.cdx')
      USE Employ  ALIAS DOKS  NEW
      INDEX ON DTOS(DTDOK)+TR0(NRDOK) TAG DOK
      USE
   EndIf

RETURN Nil

*----------------------------------------------------------------------------*
FUNC TR0( c ) 
*----------------------------------------------------------------------------*
RETURN PADL(AllTrim(c), Len(c)) 

*----------------------------------------------------------------------------*
FUNC TxtWidth( cText, nFontSize, cFontName, cChr ) // get the width of the text
*----------------------------------------------------------------------------*
   LOCAL hFont, nWidth
   DEFAULT cChr := 'A'

   IF VALTYPE( cText ) == 'N'
      cText := REPLICATE( cChr, cText )
   ENDIF

   DEFAULT cText := REPLICATE( cChr, 2 ), ;
       cFontName := _HMG_DefaultFontName, ;
       nFontSize := _HMG_DefaultFontSize

   hFont  := InitFont( cFontName, nFontSize )
   nWidth := GetTextWidth( 0, cText + cChr, hFont )

   DeleteObject( hFont )

RETURN nWidth

FUNC MyUse( cDbf, cAls, lShared, cRdd )
   LOCAL lRet := .F.
   DEFAULT lShared := .T.

   SELECT 0
   If     empty (cAls)    ; cAls := '_XYZ_'+hb_ntos(select())
   ElseIf select(cAls) > 0; cAls += '_'    +hb_ntos(select())
   EndIf

   BEGIN SEQUENCE WITH { |e|break(e) }
      DbUseArea( .F., cRdd, cDbf, cAls, lShared )
      lRet := Used()
   END SEQUENCE

   IF lRet
      If OrdCount() > 0
         OrdSetFocus(1)
      EndIf
      dbGoTop()
   ENDIF
 
RETURN lRet

*-----------------------------------------------------------------------------*
FUNC wPost( nEvent, nIndex, xParam )
*-----------------------------------------------------------------------------*
   LOCAL oWnd
   
   If HB_ISOBJECT(nIndex)

      If nIndex:ClassName == 'TSBROWSE'
         oWnd := _WindowObj( nIndex:cParentWnd )
      Else
         oWnd := nIndex
      EndIf

      oWnd:SetProp( nEvent, xParam )
      oWnd:PostMsg( nEvent )

   Else

      DEFAULT nEvent := val( This.Name )
      
      If nEvent > 0
         oWnd := ThisWindow.Object
         oWnd:SetProp( nEvent, xParam )
         oWnd:PostMsg( nEvent, nIndex )
      EndIf

   EndIf
   
RETURN Nil

*-----------------------------------------------------------------------------*
FUNC wSend( nEvent, nIndex, xParam )
*-----------------------------------------------------------------------------*
   LOCAL oWnd
   
   If HB_ISOBJECT(nIndex)

      If nIndex:ClassName == 'TSBROWSE'
         oWnd := _WindowObj( nIndex:cParentWnd )
      Else
         oWnd := nIndex
      EndIf

      oWnd:SetProp( nEvent, xParam )
      oWnd:SendMsg( nEvent )

   Else

      DEFAULT nEvent := val( This.Name )
      
      If nEvent > 0
         oWnd := ThisWindow.Object
         oWnd:SetProp( nEvent, xParam )
         oWnd:SendMsg( nEvent, nIndex )
      EndIf

   EndIf
   
RETURN Nil

*----------------------------------------------------------------------------*
FUNC BaseCols()
*----------------------------------------------------------------------------*
   LOCAL oCol

   DEFINE FONT FontNorm FONTNAME _HMG_DefaultFontName SIZE _HMG_DefaultFontSize 
   DEFINE FONT FontBold FONTNAME _HMG_DefaultFontName SIZE _HMG_DefaultFontSize BOLD

   PUBLIC oKOD, oNAME, oH_A, oS_C_Z, oF_L, oD_N, oK_N, oT_S, oS_S
   PUBLIC oID, oFIRST, oLAST, oSTREET, oCITY, oSTATE, oZIP, oHIREDATE, oAGE
   PUBLIC oDTDOK, oNRDOK, oSMDOK, oTXDOK, oSMTAX, oSMITG, oID_E
   PUBLIC o_Cols := oKeyData()

   DEFINE COLUMN oCol      DATA      'ORDKEYNO()'                      ;
                           HEADER    '#'                               ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth(6)                       ;
                           PICTURE   '999999'                          ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'ORDKEYNO'        ALIAS ____          
      oCol:cFooting := { |nc,ob| nc := ob:nLen, iif( Empty(nc), '', hb_ntos(nc) ) } 
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )
      o_Cols:Set('OrdKeyNo', oCol)

   // States.dbf
   DEFINE COLUMN oCol      DATA      'KOD'                             ;
                           HEADER    'Code'                            ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth(10)                      ;
                           PICTURE   '!!'                              ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'STAT_KOD'        ALIAS STAT
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )
      o_Cols:Set('oKOD'    , oCol)

   DEFINE COLUMN oCol      DATA      'NAME'                            ;
                           HEADER    'Name'                            ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 25 )                    ;
                           PICTURE   Repl('X', 25 )                    ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'STAT_NAME'       ALIAS STAT
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )
      o_Cols:Set('oNAME'   , oCol)

   DEFINE COLUMN oNAME     DATA      'NAME'                            ;
                           HEADER    'Name'                            ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 25 )                    ;
                           PICTURE   Repl('X', 25 )                    ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'STAT_NAME'       ALIAS STAT
      oCol                 := oNAME
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oK_N      DATA      'KOD+chr(13)+chr(10)+Trim(NAME)'  ;
                           HEADER    'Code'+CRLF+'State name'          ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth(15)                      ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'STAT_K_N'        ALIAS STAT
      oCol                 := oK_N
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   // Employee.dbf
   DEFINE COLUMN oID       DATA      'ID'                              ;
                           HEADER    'ID'                              ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth(7)                       ;
                           PICTURE   '999999'                          ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_ID'         ALIAS EMPL
      oCol                 := oID
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oFIRST    DATA      'FIRST'                           ;
                           HEADER    'First'                           ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 15 )                    ;
                           PICTURE   Repl('X', 15)                     ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_FIRST'      ALIAS EMPL
      oCol                 := oFIRST
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oLAST     DATA      'LAST'                            ;
                           HEADER    'Last'                            ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 15 )                    ;
                           PICTURE   Repl('X', 15)                     ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_LAST'       ALIAS EMPL 
      oCol                 := oLAST
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oF_L      DATA      'Trim(FIRST)+chr(13)+chr(10)+Trim(LAST)'     ;
                           HEADER    'First'+CRLF+'Last'               ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 15 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_F_L'        ALIAS EMPL
      oCol                 := oF_L
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oSTREET   DATA      'STREET'                          ;
                           HEADER    'Street'                          ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 30 )                    ;
                           PICTURE   Repl('X', 30)                     ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_STREET'     ALIAS EMPL 
      oCol                 := oSTREET
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oCITY     DATA      'CITY'                            ;
                           HEADER    'City'                            ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 20 )                    ;
                           PICTURE   Repl('X', 20)                     ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_CITY'       ALIAS EMPL 
      oCol                 := oCITY
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oS_C_Z    DATA      'Trim(STREET)+chr(13)+chr(10)+Trim(CITY)+[, ]+Trim(ZIP)' ;
                           HEADER    'Street'+CRLF+'City'+', '+'Zip'   ;
                           FOOTER    ' '                               ;
                           ALIGN     0, 1, 1                           ;
                           WIDTH     TxtWidth( 27 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_S_C_Z'      ALIAS EMPL 
      oCol                 := oS_C_Z
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oSTATE    DATA      'STATE'                           ;
                           HEADER    'State'                           ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 4 )                     ;
                           PICTURE   '!!'                              ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_STATE'      ALIAS EMPL 
      oCol                 := oSTATE
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oZIP      DATA      'ZIP'                             ;
                           HEADER    'Zip'+CRLF+'code'                 ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Repl('X', 10)                     ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_ZIP'        ALIAS EMPL
      oCol                 := oZIP
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oHIREDATE DATA      'HIREDATE'                        ;
                           HEADER    'Hiredate'                        ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_HIREDATE'   ALIAS EMPL
      oCol                 := oHIREDATE
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oAGE      DATA      'AGE'                             ;
                           HEADER    'Age'                             ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 3 )                     ;
                           PICTURE   '999'                             ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_AGE'        ALIAS EMPL
      oCol                 := oAGE
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oH_A      DATA      'DTOC(HIREDATE)+chr(13)+chr(10)+hb_ntos(AGE)' ;
                           HEADER    'Hiredate'+CRLF+'Age'             ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'EMPL_H_A'        ALIAS EMPL
      oCol                 := oH_A
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )
                                                   
   // Employ.dbf
   DEFINE COLUMN oDTDOK    DATA      'DTDOK'                           ;
                           HEADER    'Document'+CRLF+'date'            ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_DTDOK'      ALIAS DOKS
      oCol                 := oDTDOK
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oNRDOK    DATA      'NRDOK'                           ;
                           HEADER    'Document'+CRLF+'number'          ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Repl('X', 10 )                    ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_NRDOK'      ALIAS DOKS
      oCol                 := oNRDOK
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oD_N      DATA      'DTOC(DTDOK)+chr(13)+chr(10)+AllTrim(NRDOK)'                           ;
                           HEADER    'Date'+CRLF+'Numurs'              ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_D_N'        ALIAS DOKS
      oCol                 := oD_N
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oSMDOK    DATA      'SMDOK'                           ;
                           HEADER    'Amount'                          ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 11 )                    ;
                           PICTURE   '999999999.99'                    ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_SMDOK'      ALIAS DOKS 
      oCol                 := oSMDOK
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oS_S      DATA      'hb_ntos(SMDOK)+chr(13)+chr(10)+hb_ntos(SMITG)'                           ;
                           HEADER    'Amount'+CRLF+'Sum total'         ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_SMDOK'      ALIAS DOKS 
      oCol                 := oS_S
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oTXDOK    DATA      'TXDOK'                           ;
                           HEADER    'Tax'+CRLF+'%'                    ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 4 )                     ;
                           PICTURE   '99'                              ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_TXDOK'      ALIAS DOKS 
      oCol                 := oTXDOK
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oSMTAX    DATA      'SMTAX'                           ;
                           HEADER    'Tax'+CRLF+'amount'               ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 11 )                    ;
                           PICTURE   '999999999.99'                    ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_SMTAX'      ALIAS DOKS 
      oCol                 := oSMTAX
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oT_S      DATA      'str(TXDOK,2)+[ %]+chr(13)+chr(10)+hb_ntos(SMTAX)'                           ;
                           HEADER    'Tax %'+CRLF+'Tax amount'         ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 10 )                    ;
                           PICTURE   Nil                               ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_TXDOK'      ALIAS DOKS 
      oCol                 := oT_S
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oSMITG    DATA      'SMITG'                           ;
                           HEADER    'Sum'+CRLF+'total'                ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth( 11 )                    ;
                           PICTURE   '999999999.99'                    ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_SMITG'      ALIAS DOKS 
      oCol                 := oSMITG
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )

   DEFINE COLUMN oID_E     DATA      'ID_E'                            ;
                           HEADER    'ID'+CRLF+'Employee'              ;
                           FOOTER    ' '                               ;
                           ALIGN     1, 1, 1                           ;
                           WIDTH     TxtWidth(7)                       ;
                           PICTURE   '999999'                          ;
                           MOVE      0                                 ;
                           DBLCURSOR                                   ;
                           NAME      'DOKS_ID_E'       ALIAS DOKS
      oCol                 := oID_E
      oCol:lEmptyValToChar := .T.
      oCol:cData           := 'hb_macroblock("'+oCol:cField+'")'
      oCol:bData           :=  hb_macroblock(   oCol:cField )
   
RETURN Nil

