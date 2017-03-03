/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Example to view DBF files using standard Browse control
 * Copyright 2009 MigSoft <mig2soft/at/yahoo.com>
 *
 * Enhanced by Grigory Filatov <gfilatov@inbox.ru>
 * Last Revised 18/09/2014
 */

#include "minigui.ch"

STATIC cExpress := ''

Function Main()

   Local cBaseFolder, aTypes, aNewFiles
   Local nCamp, aEst, aNomb, aJust, aLong, aFtype, i

   // Set default language to English
   HB_LANGSELECT( "EN" )

   // Set default language to Portuguese
   //SET LANGUAGE TO PORTUGUESE

   SET CENTURY ON
   SET EPOCH TO YEAR(DATE())-20
   SET DATE TO BRITISH

   cBaseFolder := GetStartupFolder()

   aTypes    := { {'Database files (*.dbf)', '*.dbf'} }
   aNewFiles := GetFile( aTypes, 'Select database files', cBaseFolder, TRUE )

   IF !Empty(aNewFiles)

      Use (aNewFiles[1]) Shared New

      nCamp := Fcount()
      aEst  := DBstruct()

      aNomb := {'iif(deleted(),0,1)'} ; aJust := {0} ; aLong := {0} ; aFtype := {}

      For i := 1 to nCamp
          aadd(aNomb,aEst[i,1])
          aadd(aFtype, aEst[i,2])
          aadd(aJust,LtoN(aEst[i,2]=='N'))
          aadd(aLong,Max(100,Min(160,aEst[i,3]*14)))
      Next

      CreaBrowse( Alias(), aNomb, aLong, aJust, aFtype )

   Endif

Return Nil

//----------------------------------------------------------------------------// 

Function CreaBrowse( cBase, aNomb, aLong, aJust, aFtype )

    Local nAltoPantalla  := GetDesktopHeight() + GetTitleHeight() + GetBorderHeight()
    Local nAnchoPantalla := GetDesktopWidth()
    Local nRow           := nAltoPantalla  * 0.10
    Local nCol           := nAnchoPantalla * 0.10
    Local nWidth         := nAnchoPantalla * 0.95
    Local nHeight        := nAltoPantalla  * 0.85
    Local aHdr           := aClone(aNomb)
    Local aCabImg        := aClone(VerHeadIcon(aFtype))

    aHdr[1] := Nil

    SET DEFAULT ICON TO "MAIN"

    DEFINE WINDOW oWndBase AT nRow , nCol ;
      WIDTH nWidth HEIGHT nHeight ;
      TITLE "(c)2009 MigSoft - View DBF files" ;
      MAIN ICON "MGM" ;
      ON SIZE Adjust() ON MAXIMIZE Adjust()

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 90,32 FONT "Arial" SIZE 9 FLAT RIGHTTEXT
        BUTTON Cerrar    CAPTION _HMG_aABMLangButton[1]  PICTURE "MINIGUI_EDIT_CLOSE"  ACTION oWndBase.Release               AUTOSIZE
        BUTTON Nuevo     CAPTION _HMG_aABMLangButton[2]  PICTURE "MINIGUI_EDIT_NEW"    ACTION Append()                       AUTOSIZE
        BUTTON Modificar CAPTION _HMG_aABMLangButton[3]  PICTURE "MINIGUI_EDIT_EDIT"   ACTION Edit()                         AUTOSIZE
        BUTTON Eliminar  CAPTION _HMG_aABMLangButton[4]  PICTURE "MINIGUI_EDIT_DELETE" ACTION DeleteOrRecall()               AUTOSIZE
        BUTTON Buscar    CAPTION _HMG_aABMLangButton[5]  PICTURE "MINIGUI_EDIT_FIND"   ACTION MyFind()                       AUTOSIZE
        BUTTON Imprimir  CAPTION _HMG_aABMLangButton[16] PICTURE "MINIGUI_EDIT_PRINT"  ACTION printlist(cBase, aNomb, aLong) AUTOSIZE
      END TOOLBAR

      DEFINE BROWSE Browse_1
        ROW    45
        COL    20
        WIDTH  oWndBase.width  - 40
        HEIGHT oWndBase.height - 95
        VALUE 0
        WIDTHS aLong
        HEADERS aHdr
        HEADERIMAGE aCabImg
        WORKAREA &cBase
        FIELDS aNomb
        JUSTIFY aJust
        IMAGE { "br_no", "br_ok" }
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE Nil
        LOCK .T.
        ALLOWEDIT .T.
        INPLACEEDIT .T.
        ALLOWDELETE .T.
        ALLOWAPPEND .T.
        ONHEADCLICK Nil
      END BROWSE

    END WINDOW

    Aeval( aHdr, {|x,i| oWndBase.Browse_1.HeaderImage(i) := {i,(aJust[i]==1)}} )

    oWndBase.Browse_1.ColumnWidth(1) := 21

    oWndBase.Center
    oWndBase.Activate

Return Nil

//----------------------------------------------------------------------------//

Function VerHeadIcon( aType )

   Local aFtype, cType, n
   Local aHeadIcon := {"hdel"}
   aFtype := aClone( aType )

   For n := 1 to FCount()
       cType := aFtype[n]
       Switch cType
          Case 'L'
               aadd(aHeadIcon,"hlogic")
               exit
          Case 'D'
               aadd(aHeadIcon,"hfech")
               exit
          Case 'N'
               aadd(aHeadIcon,"hnum")
               exit
          Case 'C'
               aadd(aHeadIcon,"hchar")
               exit
          Case 'M'
               aadd(aHeadIcon,"hmemo")
       End
   Next

Return(aHeadIcon)

//----------------------------------------------------------------------------//

Procedure Adjust()
   oWndBase.Browse_1.Width  := oWndBase.width  - 40
   oWndBase.Browse_1.Height := oWndBase.height - 95
Return

//----------------------------------------------------------------------------//

Procedure Append()
   Local i := GetControlIndex ( "Browse_1", "oWndBase" )

   ( Alias() )->( DbAppend() )

   if !NetErr()

      oWndBase.Browse_1.Value := ( Alias() )->( RecNo() )

      ProcessInPlaceKbdEdit( i )

   EndIf

   oWndBase.Browse_1.SetFocus

Return

//----------------------------------------------------------------------------//

Procedure Edit()
   Local i := GetControlIndex ( "Browse_1", "oWndBase" )

   ( Alias() )->( DbGoto(oWndBase.Browse_1.Value) )

   ProcessInPlaceKbdEdit( i )

   oWndBase.Browse_1.SetFocus

Return

//----------------------------------------------------------------------------//

Procedure DeleteOrRecall()

   ( Alias() )->( DbGoto(oWndBase.Browse_1.Value) )

   if ( Alias() )->( Rlock() )
      iif( ( Alias() )->( Deleted() ), ( Alias() )->( DbRecall() ), ( Alias() )->( DbDelete() ) )
   endif
   ( Alias() )->( dbUnlock() )

   oWndBase.Browse_1.Refresh
   oWndBase.Browse_1.SetFocus

Return

//----------------------------------------------------------------------------//

Procedure printlist(cBase, aNomb, aLong)
    Local aHdr := aClone(aNomb)
    Local aLen := aClone(aLong)
    Local aHdr1
    Local aTot
    Local aFmt

	aeval(aLen, {|e,i| aLen[i] := e/9})
	adel(aLen, 1)
	asize(aLen, len(aLen)-1)
	adel(aHdr, 1)
	asize(aHdr, len(aHdr)-1)
	adel(aHdr, len(aHdr))
	asize(aHdr, len(aHdr)-1)
	aHdr1 := array(len(aHdr))
	aTot := array(len(aHdr))
	aFmt := array(len(aHdr))
	afill(aHdr1, '')
	afill(aTot, .f.)
	afill(aFmt, '')
//	aFmt[9]  := '999'
//	aFmt[10] := '@E 999,999'

	set deleted on

	( cBase )->( dbgotop() )

	DO REPORT ;
		TITLE  cBase + ' Database List'						;
		HEADERS  aHdr1, aHdr							;
		FIELDS   aHdr								;
		WIDTHS   aLen								;
		TOTALS   aTot								;
		NFORMATS aFmt				                     		;
		WORKAREA &cBase								;
		LMARGIN  3								;
		TMARGIN  3								;
		PAPERSIZE DMPAPER_A4 							;
		PREVIEW

	set deleted off

Return

//----------------------------------------------------------------------------//

Procedure MyFind()
   Local cExpErr, nCurRec

   cExpress := InputBox( "Enter a Search Expression :", "Find", cExpress )

   IF ! Empty( cExpress )

      cExpErr := Exp1Chek( cExpress )
   
      IF Empty( cExpErr ) .AND. .NOT. "U" $ TYPE( cExpress )

         ( Alias() )->( DbGoto( oWndBase.Browse_1.Value ) )
         nCurRec := ( Alias() )->( RecNo() )

         LOCATE FOR &cExpress REST

         IF ( Alias() )->( Eof() )
            ( Alias() )->( DbGoto( nCurRec ) )
         ENDIF   

         oWndBase.Browse_1.Value := ( Alias() )->( RecNo() )
         oWndBase.Browse_1.Refresh

      ELSE

         MsgStop( "Invalid expression : " + cExpErr, "Warning" ) 

      ENDIF   

   ENDIF

   oWndBase.Browse_1.SetFocus

Return

//----------------------------------------------------------------------------//

/*
   f.Exp1Chek( <cSingleExpression> ) => <cResult> 

   Copyright 2008-2010 © Bicahi Esgici <esgici@gmail.com>
*/
FUNCTION Exp1Chek( ;                // Syntax Checking on a single expression  
                 c1Exprsn )
                 
   LOCAL cRVal   := '',;
         c1Char  := '',;
         c1Atom  := '',;
         cDelmt  := ',',;
         nPnter  := 0,;
         cBPrnts := "([{'" + '"',;  // Parenthesis Begin
         cEPrnts := ")]}'" + '"',;  // Parenthesis End
         cOprtrs := "+-/*,@$&!<>=#",;
         cVoidEs := '"(' + "'",;
         c1stChr := '',;
         aLogics := { "AND", "OR", "NOT"  },;
         aBrackts := { 0, 0, 0, 0, 0 },;
         nBracket := 0

   LOCAL cTermtors := cBPrnts + cEPrnts + cOprtrs + ". ",;
         nAInd := 0,;
         c1ExpSav := c1Exprsn

   c1Exprsn := STRTRAN( c1Exprsn,' ', '' )  // Is this NoP ?
   
   WHILE nPnter < LEN( c1Exprsn )
   
      c1Char := SUBS( c1Exprsn, ++nPnter, 1 )
      
      IF ISALPHA( c1Char ) .OR. ( !EMPTY( c1Atom ) .AND. c1Char == "_" )
         IF EMPTY( c1Atom ) .AND. nPnter > 1 
            c1stChr := SUBS( c1Exprsn, nPnter -1, 1 )
         ENDIF
         c1Atom += c1Char
      ELSE
         IF ISDIGIT( c1Char )
            c1Atom += IF( EMPTY( c1Atom ), '', c1Char )
         ELSE   
            IF c1Char $ cTermtors 
               IF c1Char == "." .AND. c1stChr == "."
                  IF ( ASCAN( aLogics, UPPE( SubStrng2( c1Exprsn, nPnter-3, nPnter-1 ))) > 0 .OR. ; 
                       ASCAN( aLogics, UPPE( SubStrng2( c1Exprsn, nPnter-2, nPnter-1 ))) > 0 )
                     c1Atom := ''
                     c1stChr := ''
                  ENDIF ASCAN( ...                     
               ENDIF c1Char == "."
               IF !EMPTY( c1Atom ) .AND. !c1Char $ cVoidEs
                  IF "U" $ TYPE( c1Atom  ) 
                     cRVal := c1Atom 
                     EXIT 
                  ENDIF   
               ENDIF   
               c1Atom  := ''
               c1stChr := ''
               IF c1Char $ cBPrnts .OR. c1Char $ cEPrnts
                  IF c1Char $ cBPrnts 
                     nBracket := AT( c1Char, cBPrnts )
                     IF nBracket > 3
                        IF aBrackts[ nBracket ] > 0
                           --aBrackts[ nBracket ]
                        ELSE
                           ++aBrackts[ nBracket ]
                        ENDIF
                     ELSE      
                        ++aBrackts[ nBracket ]
                     ENDIF nBracket > 3
                  ELSE // c1Char $ cEPrnts
                     nBracket := AT( c1Char, cEPrnts )
                     IF nBracket > 3
                        IF aBrackts[ nBracket ] > 0
                           --aBrackts[ nBracket ]
                        ELSE
                           ++aBrackts[ nBracket ]
                        ENDIF
                     ELSE      
                        --aBrackts[ nBracket ]
                     ENDIF nBracket > 3
                  ENDIF c1Char $ cBPrnts
               ENDIF c1Char $ cBPrnts .OR. c1Char $ cEPrnts
            ENDIF c1Char $ cTermtors   
         ENDIF ISDIGIT( c1Char )
      ENDIF ISALPHA( c1Char )
   ENDDO  nPnter < LEN( c1Exprsn )
   
   IF ASCAN( aBrackts, { | n1 | n1 # 0 } ) > 0 
      cRVal := c1ExpSav
   ENDIF   
   
   IF !EMPTY( c1Atom ) .AND. EMPTY( cRVal )  
      IF "U" $ TYPE( c1Atom )
         cRVal := c1Atom 
      ENDIF   
   ENDIF   
   
RETURN cRVal // Exp1Chek()

//----------------------------------------------------------------------------//

FUNCTION SubStrng2( ;             // Sub String defined two position
                cString,;
                nBegPos,;
                nEndPos ) 

   LOCAL cRVal

   cRVal := SUBSTR( cString,  nBegPos, nEndPos - nBegPos + 1 )

RETURN cRVal // SubStrng2()
