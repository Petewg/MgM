/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 http://www.geocities.com/harbour_minigui/

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
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - http://harbour-project.org

	"Harbour Project"
	Copyright 1999-2008, http://harbour-project.org/
---------------------------------------------------------------------------*/

/****************************************************************************
 Function MCHOICE()
 ****************************************************************************
 
  Short:
  ------
  MCHOICE() Does a boxed, achoice() style popup on an array
 
  Returns:
  --------
  <expN> Achoice selection
 
  Syntax:
  -------
  MCHOICE(aOptions,[nTop,nLeft],[nBottom,nRight],[cTitle],[lTrigger],;
                   [nStart],[@nRow],[aSelectable])
 
  Description:
  ------------
  Provides a box for selection from array <aOptions> of
  character elements.
 
  [nTop,nLeft] may be specifed to determine the
  starting top and left of the popup box.
 
  [nBottom,nRight] may be specified to complete the box
  dimensions.
 
  Default box dimensions are centered on the screen. If the dimensions
  passed are not wide enough to display the mouse hot areas on the
  bottom, the box is widened and centered on the screen.
 
  [cTitle] is a string to display at the top of the box.
 
  TRIGGER NOT IMPLEMENTED!!!!!
  [lTrigger] determines (yes or no) whether a return is
  to be executed on a first letter match.(default .f.)
  TRIGGER NOT IMPLEMENTED!!!!!

  [nStart] optional starting element (default 1)
  [@nRow] optional starting row. Pass by reference to retain value
  between calls.
 
  [aSelectable] is an array of logicals that determines which items
  are selectable. This array must be the same size as [aOptions], and
  all elements must be either True or False, not NIL. Where an element
  is False, the corresponding element in [aOptions] will be dimmed
  and will emit a BEEP when you attempt to select it.

  Examples:
  ---------
   aMeals   := {"Pizza","Chicken","Chinese"}
   nSelect  := mchoice(aMeals)
 
   // or box with title
   aMeals   := {"Pizza","Chicken","Chinese"}
   nSelect  := mchoice(aMeals,,,,"Meals")
 
   // or box with title, first letter match = return and top/left specified
   aMeals   := {"Pizza","Chicken","Chinese"}
   nSelect  := mchoice(aMeals,10,10,,,"Meals",.t.)
 
   //to retain element and position between calls
   nSelect := 1
   nRow    := 1
   aMeals   := {"Pizza","Chicken","Chinese"}
   while nSelect > 0
     nSelect  := mchoice(aMeals,,,,,"Meals",.t.,nSelect,@nRow)
     // code
   endif
 
 
  Notes:
  -------
  Bottom of window adjusts (shrinks) to adjust to array
  size if needed.

  This is a reduced MiniGui adaption of Mchoice from SuperLib 3.50 Public Domain

  Author Pierpaolo Martinello May 2008

  This Software Run only on Minigui Extended (Build 22) or later.

***************************************************************************/
// Browsing an array with TSBrowse
#include "MiniGui.ch"
#include "TSBrowse.ch"
#include "dbstruct.ch"

#DEFINE _BC ( "BORLAND" $ upper( HB_COMPILER() ) )

#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)
/*
*/
//Mchoice(aMajorKeys,10,10,20,60,"Select MAJOR group")
*-----------------------------------------------------------------------------------------------*
FUNCTION mchoice(aOptions,nTop,nLeft,nBottom,nRight,cTitle,lAlpha,nStart,nRow,aSelectable,Multi)
*-----------------------------------------------------------------------------------------------*
   Local oLbx, Ritorna :=0, nElement := 1 ,_H_Modal ,aBmp[1] ,dSel:= 0, aCloneSel:={}
   Local lnO, bcolor
   Default aOptions to {}
   Default nTop to 150, nLeft to 100
   Default nBottom to 550, nRight to  650
   Default cTitle to "" , nStart to 1
   Default nRow to 1 , Multi to .F.

   LnO := len(aOptions)
   aBmp[ 1 ] := LoadImage ("Bmps\check.bmp")
   _H_Modal := if(_BC, _HMG_IsModalActive ,_HMG_SYSDATA[271])

   if nBottom + nRight # 1200   // put in order to exclude the effect of the values of nBottom and nRigth
      nBottom := 550            // Therefore making Mchoice autocenter in the desktop admitted not to
      nRight  := 650            // have values of nTop and nLeft
   endif

   if aSelectable==nil
      aSelectable := ARRAY(lnO)
      AFILL(aSelectable,.t.)
   ElseIf len(aSelectable) # lnO
      aCloneSel := ARRAY(lnO)
      AFILL(aClonesel,.t.)
      aeval(aSelectable,{|x,n|aClonesel[n]:=x})
      aSelectable := aclone(aClonesel)
   endif

   if _H_Modal
      DEFINE WINDOW Mchoice;
             AT ntop,nLeft   ;
             WIDTH 500 HEIGHT 400 ;
             TITLE cTitle;
             MODAL NOSIZE NOSYSMENU
   Else
      DEFINE WINDOW Mchoice ;
             AT nTop, nLeft ;
             WIDTH 500 HEIGHT 400 ;
             TITLE cTitle;
             NOMINIMIZE ;
             NOMAXIMIZE;
             FONT "MS Sans Serif" SIZE 10 ;
             CHILD
   Endif

          ON KEY RETURN OF Mchoice  ACTION ;
          If( aSelectable[oLbx:nAt],(ritorna:=oLbx:nAt,Mchoice.release),MsgStop("Not Allowed!","Action Info"))

          ON KEY ESCAPE OF Mchoice  ACTION Mchoice.RELEASE

          DEFINE TBROWSE oLbx AT 10,15  ;
                 OF Mchoice WIDTH 470 HEIGHT 290 CELLED;
                 COLORS  {CLR_BLACK, CLR_NBLUE};
                 ON DBLCLICK If( aSelectable[oLbx:nAt],;
                             if(multi=.F.,(ritorna:=oLbx:nAt,Mchoice.release),ritorna := olbx:aSelected);
                            ,MsgStop("Not Allowed!","Action Info") )

          oLbx:SetArray( aOptions ) // this is necessary to work with arrays

          bColor := { || If( aSelectable[oLbx:nAt], rgb(255,255,190) , rgb(215,215,190) ) }

          ADD COLUMN TO TBROWSE oLbx DATA ARRAY ELEMENT 1;
              TITLE "" ;
              SIZE 435 ;                // this column is editable
              COLORS CLR_BLACK, bColor; // background color from a Code Block
              ALIGN DT_LEFT ;           // cells, title, footer
              FOOTER {||if (dsel > 0,"Selezionati: "+ltrim(str(dsel))+" ",'') }

              if Multi
                 ADD COLUMN TO TBROWSE oLbx DATA "" ;
                 TITLE "" ;
                 SIZE 15  ;                // this column is editable
                 COLORS CLR_BLACK, bColor; // background color from a Code Block
                 ALIGN DT_CENTER           // cells, title, footer

                 oLbx:SetSelectMode( multi , { | oBrw, nI, lSel | ;
                     ( Tone( If( lSel, 500, 100 ) );
                     ,dSel += if(lsel,1,-1),oLbx:DrawFooters() ) }, ;
                      aBmp[ 1 ], len(olbx: aColumns), DT_RIGHT )
              Endif

              oLbx:nHeightCell += 2
              oLbx:nWheelLines := 2

          END TBROWSE

          DEFINE BUTTONeX Button_1
                 ROW    318
                 COL    70
                 WIDTH  100
                 HEIGHT 35
                 CAPTION "&Ok"
                 ACTION (If( aSelectable[oLbx:nAt],( if(multi=.F.,ritorna:=oLbx:nAt,ritorna := olbx:aSelected),Mchoice.release);
                        ,MsgStop("Not Allowed!","Action Info") ) )
                 FONTNAME "Arial"
                 FONTSIZE 9
                 TOOLTIP ""
                 FONTBOLD .F.
                 FONTITALIC .F.
                 FONTUNDERLINE .F.
                 FONTSTRIKEOUT .F.
                 ONGOTFOCUS Nil
                 ONLOSTFOCUS Nil
                 HELPID Nil
                 FLAT .F.
                 TABSTOP .T.
                 VISIBLE .T.
                 TRANSPARENT .F.
                 Picture "Minigui_EDIT_OK"
          END BUTTONEX

          DEFINE BUTTONex Button_2
                 ROW    318
                 COL    310
                 WIDTH  100
                 HEIGHT 35
                 CAPTION "&Cancel"
                 ACTION (ritorna := 0, Mchoice.release)
                 FONTNAME "Arial"
                 FONTSIZE 9
                 TOOLTIP ""
                 FONTBOLD .F.
                 FONTITALIC .F.
                 FONTUNDERLINE .F.
                 FONTSTRIKEOUT .F.
                 ONGOTFOCUS Nil
                 ONLOSTFOCUS Nil
                 HELPID Nil
                 FLAT .F.
                 TABSTOP .T.
                 VISIBLE .T.
                 TRANSPARENT .F.
                 PICTURE "Minigui_EDIT_CANCEL"
          END BUTTONEX

   END WINDOW

   if ntop = 150 .and. nLeft = 100 .and. nBottom = 550
      Center window mchoice
   endif

   if nStart # nil .and. nStart <= len(aOptions)
      if nRow # nil
         oLbx:gopos(nRow,nStart)
      else
         oLbx:gopos(1,1)
      endif
   endif

   ACTIVATE WINDOW Mchoice

Return Ritorna
/*
*/
*------------------------------------------------------------------------------*
*  Short:
*  ------
*  TAGIT() Tag records in a dbf for later action
*
*  Returns:
*  --------
*  <aTagged> => An array of tagged record numbers
*
*  Syntax:
*  -------
*  TAGIT(aTagged,[aFields,aFieldDesc],[cTitle],nFreeze,<celled> ,HorWidth,VerWidth)
*
*  Description:
*  ------------
*  <aTagged> is an array. To start, it is an empty array. It is both
*  modified by reference and returned as a parameter. It
*  is filled with the record numbers of tagged records. If it is not
*  empty when passed in, it is presumed to be filled with already tagged
*  record numbers.
*
*  <aTagged> is always 'packed' on entry, so any empty()
*  or nil elements are removed, and the length adjusted.
*
*  [aFields,aFieldDesc] are optional arrays of field
*  names and field descriptions.
*
*  [cTitle] is an optional title for the tag popup.
*
*  nFreeze is a number of freeze column (optional)
*
*  <Celled> is an optional switc for drawing cells (default .F. as Linebar )
*
*  HorWidth is an optional horizontal dimension setting
*  Default 90% of your Desktop
*
*  VerWidth is an optional vertical dimension setting
*  Default 90% of your Desktop
*
*  Examples:
*  ---------
*   aTag := {}
*   tagit(aTag,nil,nil,"Tag records to copy")
*   copy to temp for (ascan(aTag,recno()) > 0)
*
*  Notes:
*  This is a reduced MiniGui adaption of Mchoice from SuperLib 3.50 Public Domain
*
*  Author Pierpaolo Martinello June 2008
*
*  This Software Run only on Minigui Extended (Build 22) or later.
/*
*/
*------------------------------------------------------------------------------*
FUNCTION TagIt(aTagged, aFields, aFieldNames, cTitle, nFreeze, cell,nHw,nVw)
*------------------------------------------------------------------------------*
   Local oTag, Ritorna :={}, _H_Modal ,aBmp[1], aFld := {}, cAlias := alias()
   Local nWinWidth  := if (getdesktopwidth() = 800,800*.9, getdesktopwidth() * 0.9 )+40
   Local nWinHeight := if (getdesktopheight() = 600,600*.85, getdesktopheight() * 0.9 )
   Local nBrwWidth  := 0 , nBrwHeight := 0
   if aFields == NIL
      aEval( ( cAlias )->( DbStruct() ),{|e,n| aAdd(aFld, e[DBS_NAME]) } )
   Endif
   Default  aTagged to {}, aFields to aFld , aFieldNames to {}
   Default cTitle to "" , nFreeze to 1 , cell to .F.
   default nHw to nWinWidth, nVw to nWinHeight

   nBrwWidth  := nHw - 15 ; nBrwHeight := nVw-160
   aBmp[ 1 ] := LoadImage ("check.bmp")
   _H_Modal  := if(_BC, _HMG_IsModalActive ,_HMG_SYSDATA[271])

   IF !IsWIndowDefined ( "TAGIT" )
      if _H_Modal
         DEFINE WINDOW Tagit;
                AT 100,100   ;
                WIDTH nHw HEIGHT nVw-50 ;
                TITLE cTitle;
                MODAL NOSIZE NOSYSMENU
      Else
         DEFINE WINDOW Tagit ;
                AT 100, 100 ;
                WIDTH nHw HEIGHT nVw-50 ;
                TITLE cTitle;
                NOMINIMIZE ;
                NOMAXIMIZE;
                FONT "MS Sans Serif" SIZE 10 ;
                CHILD
      Endif

      ON KEY RETURN OF Tagit ACTION (Ritorna := oTag:aSelected,Tagit.Release)
      ON KEY ESCAPE OF Tagit ACTION ( Ritorna:={},Tagit.RELEASE )

      DEFINE TBROWSE oTag AT 10,15  ;
             ALIAS cAlias WIDTH nBrwWidth-20 HEIGHT nBrwHeight ;
             COLORS {CLR_BLACK, CLR_NBLUE}

             ADD COLUMN TO TBROWSE oTag DATA " ";
                 TITLE "" ;
                 SIZE 18  ;
                 COLORS CLR_BLACK, rgb(255,255,190);
                 ALIGN DT_CENTER ;

                 oTag:LoadFields( .F., aFields )

                 aeval(aFld,{|x,y|if( len(aFieldNames) < y,aadd(aFieldNames,x),'' ) } ) // Insert Head decription Array)
                 aadd(aFieldNames,"") ; Ains(aFieldNames,1) ; aFieldNames[1] :=''       // Complete Head decription Array)
                 aeval(aFieldNames,{ |x,y|oTag:acolumns[y]:cHeading :=x } )             //Set Head description

                 oTag:SetSelectMode( .T., { | oTag, nI, lSel | ;
                               (Tone( If( lSel, 500, 100 ) ),  ;
                               Tagit.Button_1.caption := if(len(oTag:aSelected) > 0, "&"+_HMG_aLangLabel[1],"&+" ), ;
                               Tagit.Button_1.Picture := if(len(oTag:aSelected) > 0,"Minigui_EDIT_DEL","Minigui_EDIT_ADD" ) ) }, ;
                               aBmp[ 1 ], 1, DT_CENTER ) // New V.7.0 BitMap marker

                 // this is very important when working with the same database
                 oTag:lNoResetPos := .F.
                 oTag:aSelected   := aTagged
                 oTag:nFreeze     := nFreeze
                 oTag:lCellBrw    := cell
                 oTag:nHeightHead += 4
                 oTag:nHeightCell += 2
                 oTag:nWheelLines := 2

      END TBROWSE

      DEFINE BUTTONeX Button_1
             ROW    nBrwHeight+ 25
             COL    70
             WIDTH  100
             HEIGHT 35
             CAPTION "&+"
             ACTION  All_None(oTag)
             FONTNAME "Arial"
             FONTSIZE 9
             TOOLTIP ""
             FONTBOLD .F.
             FONTITALIC .F.
             FONTUNDERLINE .F.
             FONTSTRIKEOUT .F.
             ONGOTFOCUS Nil
             ONLOSTFOCUS Nil
             HELPID Nil
             FLAT .F.
             TABSTOP .T.
             VISIBLE .T.
             TRANSPARENT .F.
             Picture "Minigui_EDIT_ADD"
      END BUTTONEX

      DEFINE BUTTONeX Button_2
             ROW    nBrwHeight+ 25
             COL    (nHw/2)-50
             WIDTH  100
             HEIGHT 35
             CAPTION _HMG_aLangButton[8]
             ACTION  (Ritorna:=oTag:aSelected,Tagit.Release)
             FONTNAME "Arial"
             FONTSIZE 9
             TOOLTIP ""
             FLAT .F.
             TABSTOP .T.
             VISIBLE .T.
             TRANSPARENT .F.
             Picture "Minigui_EDIT_OK"
      END BUTTONEX

      DEFINE BUTTONex Button_3
             ROW    nBrwHeight+ 25
             COL    nBrwWidth-170
             WIDTH  100
             HEIGHT 35
             CAPTION "&"+_HMG_MESSAGE [7]
             ACTION ( Ritorna := {}, Tagit.release)
             FONTNAME "Arial"
             FONTSIZE 9
             TOOLTIP ""
             FLAT .F.
             TABSTOP .T.
             VISIBLE .T.
             TRANSPARENT .F.
             PICTURE "Minigui_EDIT_CANCEL"
      END BUTTONEX
      
      if len(atagged) > 0
         Tagit.Button_1.caption := "&"+_HMG_aLangLabel[1]
         Tagit.Button_1.Picture := "Minigui_EDIT_DEL"
      Endif

      END WINDOW

      Center window Tagit
      tagit.oTag.setfocus
      ACTIVATE WINDOW Tagit

   Endif
Return Ritorna
/*
*/
*------------------------------------------------------------------------------*
Static Function All_None(oTag)
*------------------------------------------------------------------------------*
   If len(oTag:aSelected) > 0
      oTag:aSelected := {}
      Tagit.Button_1.caption := "&+"
      Tagit.Button_1.Picture := "Minigui_EDIT_ADD"
   else
      DBEval( {|| aadd(oTag:aSelected,recno()) },,,,, .F. )
      Tagit.Button_1.caption := "&"+_HMG_aLangLabel[1]
      Tagit.Button_1.Picture := "Minigui_EDIT_DEL"
   Endif
   oTag:Refresh()
Return nil
/*
*/
