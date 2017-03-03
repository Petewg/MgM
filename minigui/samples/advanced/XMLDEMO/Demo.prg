/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
 *
 * This sample demonstrates reading/writing XML file and handling menu items
 * while run-time.
*/

#include "minigui.ch"
#include "i_xml.ch"

Memvar cFileIni
Memvar oXmlDoc, lIniChanged, cId, cIdXML
Memvar mVar

*-----------------------------------------------------------------------------*
Function Main
*-----------------------------------------------------------------------------*
	Local oXmlNode, i, fname := "", action

	Public cFileIni := "demo.xml"

	cFileIni := CurDrive()+':\'+Curdir()+'\'+cFileIni

	Private oXmlDoc, lIniChanged := .F., cId := 'XML_', cIdXML

	oXmlDoc := HXMLDoc():Read( cFileIni )

	DEFINE FONT font_0 FONTNAME 'Tahoma' SIZE 9 DEFAULT

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI XML Demo' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		ON RELEASE SaveOptions()

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour Power Ready!' 
		END STATUSBAR

		DEFINE MAIN MENU 
			POPUP '&File'
				MENUITEM "New item" ACTION NewItem(0)
		        	SEPARATOR 
				IF !Empty( oXmlDoc:aItems )
					FOR i := 1 TO Len( oXmlDoc:aItems[1]:aItems )
						oXmlNode := oXmlDoc:aItems[1]:aItems[i]
						fname := oXmlNode:GetAttribute("name")
						action := &( "{||NewItem("+LTrim(Str( i, 2 ))+")}" )
						IF i == 1
							cIdXML := cId+LTrim(Str( i ))
							ITEM '' ACTION {|| Nil } NAME &cIdXML
							_ModifyMenuItem ( cIdXML , 'Form_1' , fname , action )
						ELSE
							_InsertMenuItem ( cIdXML , 'Form_1' , fname , action, cId+LTrim(Str( i )) )
						ENDIF
					NEXT
					SEPARATOR
				ENDIF
				ITEM 'E&xit'	ACTION Thiswindow.release
			END POPUP
			POPUP '&Info'
				ITEM 'About'	ACTION  MsgInfo ( MiniGUIVersion(), "MiniGUI XML Demo" )
			END POPUP
		END MENU

	END WINDOW

	Form_1.Center

	ACTIVATE WINDOW Form_1

Return Nil

*-----------------------------------------------------------------------------*
Function NewItem( nItem )
*-----------------------------------------------------------------------------*
Local oDlg, aItemFont, aFontNew := { "" }
Local oXmlNode, fname, i, action, nId
Local cName, cInfo, lResult := .F.

   IF nItem > 0
      oXmlNode := oXmlDoc:aItems[1]:aItems[nItem]
      cName := oXmlNode:GetAttribute( "name" )
      FOR i := 1 TO Len( oXmlNode:aItems )
         IF Valtype( oXmlNode:aItems[i] ) == "C"
            cInfo := oXmlNode:aItems[i]
         ELSEIF oXmlNode:aItems[i]:title == "font"
            aItemFont := FontFromXML( oXmlNode:aItems[i] )
         ENDIF
      NEXT
   ELSE
      cName := ""
      cInfo := ""
      aItemFont := { 'Times New Roman' , 12 , .f. , .f. , {0,0,0} , .f. , .f. , 0 }
   ENDIF

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 308 HEIGHT 178 ;
		TITLE IIF( nItem == 0, "New item", "Change item" )  ;
		MODAL NOSIZE ;
		FONT 'Times New Roman' SIZE 12

		@ 24,20 LABEL Label_1 VALUE 'Name:' AUTOSIZE

		@ 20,80 TEXTBOX Text_1 ;
			VALUE cName ;
			WIDTH 150 ;
			HEIGHT 26 ;
			ON CHANGE cName := Form_2.Text_1.Value

		@ 20,240 BUTTON Button_0 ;
			CAPTION "Font" ;
			ACTION aFontNew := GetFont( aItemFont[1], aItemFont[2], aItemFont[3], ;
			aItemFont[4], aItemFont[5], aItemFont[6], aItemFont[7], aItemFont[8] ) ;
			WIDTH 44 ;
			HEIGHT 26

		@ 54,20 LABEL Label_2 VALUE 'Info:' AUTOSIZE

		@ 50,80 TEXTBOX Text_2 ;
			VALUE cInfo ;
			WIDTH 150 ;
			HEIGHT 26 ;
			ON CHANGE cInfo := Form_2.Text_2.Value

		@ 110,20 BUTTON Button_1 ;
			CAPTION "Ok" ;
			ACTION ( lResult:=.T., ThisWindow.Release ) ;
			WIDTH 100 ;
			HEIGHT 30

		@ 110,184 BUTTON Button_2 ;
			CAPTION "Cancel" ;
			ACTION ThisWindow.Release ;
			WIDTH 100 ;
			HEIGHT 30

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	Form_2.Center

	Form_2.Activate

   IF lResult == .T. .AND. !Empty(cName) .AND. !Empty(cInfo)
      IF nItem == 0
         oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "item" ) )
         oXmlNode:SetAttribute( "name", Trim(cName) )
         oXmlNode:Add( Trim(cInfo) )
         oXMLNode:Add( Font2XML( IIF( Empty(aFontNew[1]), aItemFont, aFontNew ) ) )
         lIniChanged := .T.

         nId := Len( oXmlNode:aItems ) + 1
         action := &( "{||NewItem("+LTrim(Str( nId, 2 ))+")}" )
         _InsertMenuItem ( cIdXML , 'Form_1' , cName , action, cId+LTrim(Str( nId ))  )
      ELSE
         IF oXmlNode:GetAttribute( "name" ) != cName
            oXmlNode:SetAttribute( "name", cName )
            lIniChanged := .T.

            action := &( "{||NewItem("+LTrim(Str( nItem, 2 ))+")}" )
            _ModifyMenuItem ( cId+LTrim(Str( nItem )) , 'Form_1' , cName , action )
         ENDIF
         FOR i := 1 TO Len( oXmlNode:aItems )
            IF Valtype( oXmlNode:aItems[i] ) == "C"
               IF cInfo != oXmlNode:aItems[i]
                  oXmlNode:aItems[i] := cInfo
                  lIniChanged := .T.
               ENDIF
            ELSEIF oXmlNode:aItems[i]:title == "font"
               IF !Empty(aFontNew[1])
                  oXMLNode:aItems[i] := Font2XML( aFontNew )
                  lIniChanged := .T.
               ENDIF
            ENDIF
         NEXT
      ENDIF
   ENDIF

Return Nil

*-----------------------------------------------------------------------------*
Function FontFromXML( oXmlNode )
*-----------------------------------------------------------------------------*
Local height  := oXmlNode:GetAttribute( "height" )
Local bold := oXmlNode:GetAttribute( "bold" )
Local italic := oXmlNode:GetAttribute( "italic" )
Local under := oXmlNode:GetAttribute( "underline" )
Local strike := oXmlNode:GetAttribute( "strikeout" )
Local charset := oXmlNode:GetAttribute( "charset" )

  IF height != Nil
     height := Val( height )
  ENDIF

  IF bold != Nil
     bold := ( bold == "1" )
  ENDIF
  IF italic != Nil
     italic := ( italic == "1" )
  ENDIF
  IF under != Nil
     under := ( under == "1" )
  ENDIF
  IF strike != Nil
     strike := ( strike == "1" )
  ENDIF

  default bold := .f., italic := .f., under := .f., strike := .f.

  IF charset != Nil
     charset := Val( charset )
  ENDIF

Return { oXmlNode:GetAttribute( "name" ) , height , bold , italic , {0,0,0} , under , strike , charset }

*-----------------------------------------------------------------------------*
Function Font2XML( aFont )
*-----------------------------------------------------------------------------*
Local aAttr := {}

   Aadd( aAttr, { "name", aFont[1] } )
   Aadd( aAttr, { "height", Ltrim(Str(aFont[2])) } )

   IF aFont[3] == .t.
      Aadd( aAttr, { "bold", Ltrim(Str(1)) } )
   ENDIF
   IF aFont[4] == .t.
      Aadd( aAttr, { "italic", Ltrim(Str(1)) } )
   ENDIF
   IF aFont[6] == .t.
      Aadd( aAttr, { "underline", Ltrim(Str(1)) } )
   ENDIF
   IF aFont[7] == .t.
      Aadd( aAttr, { "strikeout", Ltrim(Str(1)) } )
   ENDIF
   IF aFont[8] != 0
      Aadd( aAttr, { "charset", Ltrim(Str(aFont[8])) } )
   ENDIF

Return HXMLNode():New( "font", HBXML_TYPE_SINGLE, aAttr )

*-----------------------------------------------------------------------------*
Function SaveOptions()
*-----------------------------------------------------------------------------*
    IF lIniChanged
	oXmlDoc:Save( cFileIni )
    ENDIF
    CLOSE ALL
Return Nil

