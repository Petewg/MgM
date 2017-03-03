/*
MINIGUI - Harbour Win32 GUI library Demo

Copyright 2007 Pierpaolo Martinello <pier at bmm.it>

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
   (or visit the web site http://www.gnu.org/).

   Parts of this project are based upon:

   FileStr, StrFile Borrowed from xHarbour

   MINIGUI
   Harbour MiniGUI: Free xBase Win32/GUI Development System
   (c) 2002-2007 Roberto Lopez
   Mail: harbourminigui@gmail.com
   Web: http://harbourminigui.googlepages.com

   (c) 2007 Pierpaolo Martinello <pier at bmm.it>
   Data2Pdf.Prg donated to public domain
*/

#include "TSBrowse.ch"
#include "MiniGui.ch"
#include "fileio.ch"

// MEMVAR _HMG_BeginTBrowseActive
// MEMVAR _HMG_ActiveTBrowseName
// MEMVAR _HMG_ActiveTBrowseHandle

*-----------------------------------------------------------------------------*
PROCEDURE main(Template, Datasource, RootName)
*-----------------------------------------------------------------------------*
Local aarq:={}
default  template to 'Template.pdf', datasource to 'Test.dbf', Rootname to 'Output.pdf'

        If ! File(datasource)

             Aadd( aarq ,  {'Firstname','C',15,0} )
             Aadd( aarq ,  {'Surname','C',15,0} )
             Aadd( aarq ,  {'City','C',45,0} )
             DbCreate((datasource), aarq, "DBFNTX")
             use (datasource) ALIAS D2P Exclusive New
             append blank
             replace Field->Firstname with "Pierpaolo", ;
                     Field->Surname with "Martinello", ;
                     Field->City with "Biella"
             use
        EndIf

        DEFINE WINDOW F1 ;
                AT 10,10 ;
                WIDTH 550 HEIGHT 300 ;
                TITLE 'DataToPdFmixer Demo' ;
                ICON 'ACROBAT.ICO' ;
                MAIN NOSIZE NOMAXIMIZE ;
                FONT 'Arial' SIZE 10;
                ON INIT OpenData();
                On Release Exit()

                ON KEY ESCAPE OF F1 ACTION F1.RELEASE

                DEFINE STATUSBAR
                       STATUSITEM '[x] Harbour Power Ready!'
                END STATUSBAR

                @ 29,20   LABEL Label_1 VALUE "Pdf Template:" HEIGHT 19 FONT "Arial" SIZE 9 AUTOSIZE

                @ 146,110  BUTTON Button_1 CAPTION "&Define" WIDTH 100 HEIGHT 24 ;
                                ACTION {||print(1),f1.button_1.setfocus} DEFAULT

                @ 28,110  TEXTBOX TextBox_1 WIDTH 298 HEIGHT 21 value template
                @ 26,414  BUTTON Button_10 CAPTION "..." WIDTH 39 HEIGHT 23 ;
                ACTION  {|| (F1.TextBox_1.Value := MyGetFileName( Getfile ( { {'Pdf files ','*.Pdf'} } , 'Select a Template file for merging' )) ) }

                @ 62,20   LABEL Label_2 VALUE "Data Source:" WIDTH 86 HEIGHT 18

                @ 61,110  TEXTBOX TextBox_2 WIDTH 298 HEIGHT 21 value datasource
                @ 59,414  BUTTON Button_2 CAPTION "..." WIDTH 39 HEIGHT 23 ACTION {|| Seledata()}

                @ 93,20   LABEL Label_3 VALUE 'Output "Root"' WIDTH 86 HEIGHT 18

                @ 94,110  TEXTBOX TextBox_3 WIDTH 298 HEIGHT 21 value RootName

                @ 92,414  BUTTON Button_11 CAPTION "..." WIDTH 39 HEIGHT 23 ;
                ACTION  {|| (F1.TextBox_3.Value := MyGetFileName( Getfile ( { {'Pdf files ','*.Pdf'} } , 'Select for Output "Root" Name' )) )}

                @ 146,230  BUTTON Button_3 CAPTION "&Execute" WIDTH 100 HEIGHT 24 action Print(2)

                @ 146,353 BUTTON Button_4 CAPTION "E&xit" WIDTH 100 HEIGHT 24 ACTION ThisWindow.Release

        END WINDOW

        CENTER WINDOW F1

        ACTIVATE WINDOW F1

Return
/*
*/
*-----------------------------------------------------------------------------*
Static Procedure print(arg1,Template, Datasource ,Rootname)
*-----------------------------------------------------------------------------*
Local Cg:=1, afld:={}, Tf:='',mFld:={},CNT := 0
local dbW
default datasource to F1.TextBox_2.value
default template to F1.TextBox_1.value
default Rootname to F1.TextBox_3.value
dbw := Datasource
if empty(dbw)
   MsgStop("Please select a Data Source FIRST!")
   F1.Button_2.setfocus
   return
endif
if arg1=2
   sele 1
   use &(dbw) shared alias dbd
   if empty(Template)
      MsgStop("Please select a PDF TEMPLATE FIRST!")
      F1.Button_10.setfocus
      return
   endif
   PdfWork(Template,RootName, dbw)
else
   Sele 1
   use &(dbw) shared alias dbd
   for cg = 1 to fcount()
       tf:= VALTYPE(&(FIELDNAME(cg)))
       if TF =="N" .or. TF =="C" .or. TF =="D"
          CNT ++
          aadd(Mfld,zaps(CNT)+','+fieldName(cg)+',10,'+'65280,'+'0.0'+','+Tf+','+zaps(fielddeci(cg))+'|'+Zaps( FIELDSIZE( cg )  ) )
          aadd(afld,{0,fieldName(cg),10,"{0,0,0}",0.00,.f.,Tf,"  ",IF(TF $ "ND",.T.,.F.)})
       endif
   next
   SELE 1
   //mchoice(mfld)
   Ed_fld(afld)
endif
return
/*
*/
*-----------------------------------------------------------------------------*
Proc OpenData()
*-----------------------------------------------------------------------------*
Local aarq:={}, Archivio:= 'Def2Pdf.dbf'

         If ! File(Archivio)

             Aadd( aarq ,  {'Token','N',2,0} )
             Aadd( aarq ,  {'EField','C',15,0} )
             Aadd( aarq ,  {'TField','C',1,0} )
             Aadd( aarq ,  {'Separator','L',1,0} )
             Aadd( aarq ,  {'Size','N',2,0} )
             Aadd( aarq ,  {'Color','C',13,0} )
             Aadd( aarq ,  {'CharSpace','N',5,2} )
             Aadd( aarq ,  {'Replawith','C',100,0} )
             DbCreate((Archivio), aarq, "DBFNTX")
             asize ( aarq, 0 )
          EndIf
          sele 2
          use Def2Pdf ALIAS D2P Exclusive
          index on Field->Token to Token
          set index to token
return
/*
*/
*-----------------------------------------------------------------------------*
Proc exit()
*-----------------------------------------------------------------------------*
     DBcloseall()
     Ferase("UseIt.dbf")
     Ferase("Token.NTX")
return
/*
*/
*-----------------------------------------------------------------------------*
Proc Ed_Fld (udb)
*-----------------------------------------------------------------------------*

#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)
#define CLR_ORANGE  RGB( 255, 214, 136)
#define CLR_DARKGRAY  RGB( 192,192,192)

   Local oDlg, oBrwS, bcolor, sColor

   /* Public _HMG_ActiveTBrowseName := ""
   Public _HMG_ActiveTBrowseHandle := 0
   Public _HMG_BeginTBrowseActive := .F.
   */
   
   DEFINE WINDOW Form_3 ;
   AT 100, 50 ;
   WIDTH 500 HEIGHT 440 ;
   TITLE "Field Propertyes" ;
   ICON 'ACROBAT.ICO' ;
   MODAL NOSIZE ;
   FONT "MS Sans Serif" SIZE 8

//   ON KEY ESCAPE OF FORM_3 ACTION FORM_3.RELEASE

   DEFINE TBROWSE oBrwS AT 20,20 OF FORM_3 CELLED ;
          WIDTH 450 HEIGHT 300  ;
          ITEMS UDB ;
          COLORS {CLR_BLACK, CLR_NBLUE} on HEADclick {{||SrtBy(udb,6),oBrwS:refresh(.t.)},{||SrtBy(udb,1),oBrwS:refresh(.t.)},{|| SrtBy(udb,2),oBrwS:refresh(.t.)},NIL,NIL,NIL}

          oBrwS:SetArray( udb) //,,.f. )
          // let's define the block for background color
          bColor := { || If( oBrwS:nAt % 2 == 0, CLR_ORANGE, CLR_DARKGRAY ) }
          sColor := { || myRgb(udb[oBrwS:nAt,4]) } // For Visual color

             // The checkbox for select the field
         ADD COLUMN TO oBrwS DATA Array ELEMENT 6;
             Title "Use" ;
             SIZE 25 PIXELS EDITABLE ;
             ;//;COLORS CLR_BLACK,CLR_NBLUE ;
             3DLOOK TRUE CHECKBOX ;         // Editing with Check Box
             ALIGN DT_CENTER, DT_CENTER ;  // Cells centered, Header Vertical
             POSTEDIT {|uVar| if (!uvar,udb[oBrwS:nAt,1]:= 0,udb[oBrwS:nAt,1]:=NxtNr(udb) ),SetBtn(udb) }

             // The Number of  Related Token to use
         ADD COLUMN TO TBROWSE oBrwS DATA ARRAY ELEMENT 1;
             TITLE "Token N°" ;
             SIZE 55 EDITABLE;          // this column is editable
             COLORS CLR_BLACK, bColor;   // background color from a Code Block
             3DLOOK TRUE, TRUE, TRUE;    // cells, titles, footers
             MOVE DT_MOVE_NEXT;          // cursor goes to next editable column
             VALID { | uVar | if (uVar > 0 ,if (uVar <= len(udb),.t.,(msgStop("Token Not Available (Too big)","Error"),.F.)),(msgStop("Must Be > 0","Error"),.F.)) }; // don't want empty rows
             ALIGN DT_CENTER, DT_CENTER, DT_RIGHT ; // cells, title, footer
             POSTEDIT {|uVar| if (uvar > 0,udb[oBrwS:nAt,6]:=.t.,NIL),SetBtn(udb) }

             // The name of field
         ADD COLUMN TO TBROWSE oBrwS ;
             DATA ARRAY ELEMENT 2;
             TITLE "Field" SIZE 90

             // Te type of field
         ADD COLUMN TO TBROWSE oBrwS ;
             DATA ARRAY ELEMENT 7;
             TITLE "Type" SIZE 25;
             ALIGN DT_CENTER

             // Flag for use separator or not
         ADD COLUMN TO oBrwS DATA Array ELEMENT 9;
             Title "Sep" ;
             SIZE 25 PIXELS EDITABLE ;
             ;//;COLORS CLR_BLACK,CLR_NBLUE ;
             3DLOOK TRUE CHECKBOX ;   // Editing with Check Box
             ALIGN DT_CENTER, DT_CENTER ;   // Cells centered, Header Vertical
             Postedit {|uVar,oBrw| udb[obrw:nAt,9]:= Myedr( uvar,oBrw,udb)} ;

             //The size of Font
         ADD COLUMN TO TBROWSE oBrwS ;
             DATA ARRAY ELEMENT 3;
             ALIGN DT_CENTER, DT_CENTER, DT_RIGHT; // cells, title, footer
             TITLE "FontSize" SIZE 50 EDITABLE;
             COLORS CLR_BLACK, bColor;   // background color from a Code Block
             VALID { | uVar | if (uVar > 1 ,.T.,(msgStop("Must Be a positive number or 10.","Error"),.F.)) } // don't want empt

             //The Color of Font
         ADD COLUMN TO TBROWSE oBrwS ;
             DATA ARRAY ELEMENT 4;
             ALIGN DT_CENTER, DT_CENTER, DT_RIGHT; // cells, title, footer
             TITLE "Color" SIZE 70 EDITABLE ;
             MOVE DT_MOVE_NEXT

             oBrwS:aColumns[ 7 ]:bExtEdit := { |Color,oBrw| edColor( Color, oBrw ) }

             // A visual of color
         ADD COLUMN TO TBROWSE oBrwS ;
             DATA ARRAY ELEMENT 8;
             ALIGN DT_CENTER, DT_CENTER, DT_RIGHT; // cells, title, footer
             PICTURE "!" ;
             TITLE " " SIZE 20 ;
             COLORS sColor,sColor  //bColor   // background color from a Code Block

             // The charspace , must be  positive (expand) or negative (compress) number
         ADD COLUMN TO TBROWSE oBrwS ;
             DATA ARRAY ELEMENT 5;
             ALIGN DT_CENTER, DT_CENTER, DT_RIGHT; // cells, title, footer
             PICTURE "99.99" ;
             TITLE "CharSpace" SIZE 70 EDITABLE;
             COLORS CLR_BLACK, bColor;   // background color from a Code Block
             MOVE DT_MOVE_NEXT          // cursor goes to next editable column

         oBrwS:nHeightCell += 1
         oBrwS:SetAppendMode( .F. )
         oBrwS:SetDeleteMode( .F., .T.)

   END TBROWSE

   @ 350,66  BUTTON Button_1 CAPTION "&Restore" WIDTH 80 HEIGHT 24 ;
             ACTION (LoadFrom(udb),oBrwS:refresh(.t.) ,setBtn(udb))

   @ 350,156 BUTTON Button_2 CAPTION "&Save" WIDTH 80 HEIGHT 24 ACTION Savedefs(udb)

   @ 350,246 BUTTON Button_3 CAPTION "&Clear" WIDTH 80 HEIGHT 24 ACTION (ClearForm(udb),oBrwS:refresh(.t.),setBtn(udb))

   @ 350,336 BUTTON Button_4 CAPTION "E&xit" WIDTH 80 HEIGHT 24 ACTION ThisWindow.Release
   
   END WINDOW
   SetBtn()
   Form_3.center
   Form_3.activate
Return
/*
*/
*-----------------------------------------------------------------------------*
Static Function Myedr( aRg1,oBrw,udb)
*-----------------------------------------------------------------------------*
   Local adataNew:={}, cVal := .f.
   If udb[obrw:nAt,7] $ "DN"
      cVal:= aRg1
   Else
       MsgStop(padc("Feature not available for this Field!",40) )
   Endif
Return cVal
/*
*/
*-----------------------------------------------------------------------------*
Static Function edColor( aRg1,oBrw)
*-----------------------------------------------------------------------------*
   Local adataNew:={}, cvAlue:=''

   aDataNew := GetColor (&arg1)
   IF aDataNew[1] != NIL
      aeval(adatanew,{|x,y|cValue += if(y =1,"{"+ltrim(str(x,3,0) )+',',if(y=len(adatanew),ltrim(str(x,3,0))+"}",ltrim(str(x,3,0)+"," ) ) ) } )
   else
      cValue := aRg1
   Endif
Return cValue
/*
*/
*-----------------------------------------------------------------------------*
Static Function MyRgb(arg1)
*-----------------------------------------------------------------------------*
local r1 := &arg1 , rt := 0
   rt:= r1[1]+(r1[2]*256)+(r1[3]* 65536 )
return rt
/*
*/
*-----------------------------------------------------------------------------*
Static Proc SetBtn(udb)
*-----------------------------------------------------------------------------*
   Form_3.Button_1.enabled := 2->(recc()) > 0
   Form_3.Button_2.enabled := ascan(udb,{|x| x[6]=.t.}) > 0
return
/*
*/
*-----------------------------------------------------------------------------*
Static Function SrcBy(afld,src,Colum)
*-----------------------------------------------------------------------------*
Local nret := 0
   default colum to 1
   nret := ascan(afld,{|aVal|zaps(aVal[colum])= zaps(src)})
return  nret
/*
*/
*-----------------------------------------------------------------------------*
Static Function NxtNr(afld)
*-----------------------------------------------------------------------------*
local vln:=0
   aeval(afld,{|x,y| vln:=max(vln,x[1])} )
return vln + 1
/*
*/
*-----------------------------------------------------------------------------*
Static Function SrtBy(afld,Colum)
*-----------------------------------------------------------------------------*
Local mFld:={}
default colum to 1
asort(afld,,,{|x, y| x[colum] < y[colum] } )
return nil 
/*
*/
*-----------------------------------------------------------------------------*
Static Proc LoadFrom(afld)
*-----------------------------------------------------------------------------*
Local cln , cntg := 0
   ClearForm(afld)
   sele 2
   go top
   while !eof()
         cln := SrcBy(afld,D2P->EFIELD,2)
         if Cln > 0
           cntg ++
           afld[cln,6]:= .T.
           afld[cln,1]:= D2P->TOKEN
           afld[cln,3]:= D2P->SIZE
           afld[cln,4]:= D2P->COLOR
           afld[cln,5]:= D2P->CHARSPACE
           afld[cln,9]:= D2P->SEPARATOR
         endif
         dbskip()
   enddo
   if cntg # lastrec()
      msgExclamation("This definition doesn't seem to match the origin database.";
               +CRLF+padc("But restored where possible.",60) )
   Endif
   Form_3.oBrwS.setfocus
return
/*
*/
*-----------------------------------------------------------------------------*
Static Procedure ClearForm(afld)
*-----------------------------------------------------------------------------*
Local cln  := 0
      for cln := 1 to len(afld)
          afld[cln,6]:= .T.
          afld[cln,1]:= 0
          afld[cln,3]:= 10
          afld[cln,4]:= "{0,0,0}"
          afld[cln,5]:= 0.00
          afld[cln,6]:= .F.
          afld[cln,9]:= IF(afld[cln,7] $ "ND",.T.,.F.)
      next
      Form_3.oBrwS.setfocus
return
/*
*/
*-----------------------------------------------------------------------------*
Static Procedure SaveDefs(afld)
*-----------------------------------------------------------------------------*
Local Cg:=1, Tf:='',mFld:={}
asort(afld,,,{|x, y| x[1] < y[1] } )
//aeval(afld,{|x|aadd(Mfld,zaps(x[1])+','+x[2]+','+zaps(x[3])+','+x[4]+','+zaps(x[5])+','+if(x[6],'.t.','.f.' ) ) } )
//mchoice(mfld)
    sele 2
    if len(afld) > 0
       ZAP
       for cg =1 to len(afld)
           if AFLD[cg,6] = .t.
              SELE 2
              APPEND BLANK
              D2P->TOKEN     := AFLD[cg,1]
              D2P->EFIELD    := AFLD[cg,2]
              D2P->TFIELD    := AFLD[cg,7]
              D2P->SEPARATOR := AFLD[cg,9]
              D2P->SIZE      := AFLD[cg,3]
              D2P->COLOR     := aFld[cg,4]
              D2P->CHARSPACE := AFLD[cg,5]
              D2P->REPLAWITH := '"/FontSize '+ZAPS( AFLD[cg,3] )+' /Text ("+Zaps('+'3->'+afld[cg,2];
                               +if( AFLD[cg,9],',.T.',',.F.')+',.T.)+")/CharColor '+zaps( MyRgb(aFld[cg,4]) );
                               +" /CharSpace "+ltrim( str( afld[cg,5],4,2 ) )+' /"'
              DBCOMMIT()
           Endif
       next
   endif
   go top
   SetBtn()
return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Zaps(arg_in,sep,euro,money)
*-----------------------------------------------------------------------------*
local arg1, arg2
DEFAULT SEP TO .F.
DEFAULT EURO TO .T.
DEFAULT MONEY TO .F.

if Valtype(arg_in)== "C"
   *- make sure it fits on the screen
   arg1 = "@KS" + LTRIM(STR(MIN(LEN((alltrim(arg_in))), 78)))
elseif VALTYPE(arg_in) == "N"
   *- convert to a string
   arg2 := ltrim( STR (arg_in) )
   *- look for a decimal point
   IF ("." $ arg2)
      *- return a picture reflecting a decimal point
      arg1 := REPLICATE("9", AT(".", arg2) - 1)+[.]
      arg1 := eu_point(arg1,sep,euro)+[.]+ REPLICATE("9", LEN(arg2) - LEN(arg1))
   ELSE
      *- return a string of 9's a the picture
      arg1 := REPLICATE("9", LEN(arg2))
      arg1 := eu_point(arg1,sep,euro)+if( money,".00","")
   ENDIF
elseif VALTYPE(arg_in) == "D"
   arg_in := dtoc(arg_in)
   if !sep
      arg_in := strtran(arg_in,"/","")
      arg_in := strtran(arg_in,"-","")
   endif
   arg1:="@KS"+ LTRIM(STR(MIN(LEN((alltrim(arg_in))), 78)))
else
   *- well I just don't know.
   arg1 := ""
Endif

RETURN trans(arg_in,arg1)
/*
*/
*-----------------------------------------------------------------------------*
Function eu_point(valore,sep,euro)
*-----------------------------------------------------------------------------*
local TAPPO :='',sep_conto:=0,n
default sep to .t.
default euro to .t.
for n= len(valore) to 1 step -1
   IF substr( valore,n,1 )== [9]
      if sep_conto = 3
         if sep
            TAPPO := ","+TAPPO
         endif
         sep_conto := 0
      endif
      tappo := substr(valore,n,1)+TAPPO
      sep_conto ++
   ENDIF
next
if euro
   TAPPO := "@E "+TAPPO
endif

RETURN TAPPO
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION MyGetFileName(rsFileName)
*-----------------------------------------------------------------------------*
   LOCAL i := 0
   FOR i = Len(rsFileName) TO 1 STEP -1
      IF SUBSTR(rsFileName, i, 1) $ "\/"
         EXIT
      END IF
   NEXT
RETURN SUBSTR(rsFileName, i + 1)
/*
*/
*-----------------------------------------------------------------------------*
Proc SeleData()
*-----------------------------------------------------------------------------*
Local OpenDb
OpenDB := Getfile ( { {'Dbf files ','*.DBF'} } , 'Select a DataSource for merging' )
if len(OpenDb) > 0
   openDb:=MyGetFileName(OpenDb)
   if upper(OpenDb) # "DEF2PDF.DBF" .and. upper(OpenDb) # "USEIT.DBF"
      F1.TextBox_2.Value:= Proper(Opendb)
   else
      msgstop( "This File is used by this application!"+CRLF+"Please select an other DBF!" )
   endiF
endif
return

/*
*/
#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define HB_OS_WIN_32_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbapifs.h"
#include "hbapigt.h"


static int s_iFileAttr = HB_FA_NORMAL;
static BOOL s_bSafety = 0;

void ct_setfcreate (int iFileAttr)
{
   HB_TRACE(HB_TR_DEBUG, ("ct_setfcreate(%i)", iFileAttr));
   s_iFileAttr = iFileAttr;
}

int ct_getfcreate (void)
{
   HB_TRACE(HB_TR_DEBUG, ("ct_getfcreate()"));
   return (s_iFileAttr);
}

HB_FUNC (SETFCREATE)
{

   hb_retni (ct_getfcreate());

   if (HB_ISNUM (1))
   {
      ct_setfcreate(hb_parni (1));
   }

   return;

}

void ct_setsafety (BOOL bSafety)
{
   HB_TRACE(HB_TR_DEBUG, ("ct_setsafety(%i)", bSafety));
   s_bSafety = bSafety;
}

BOOL ct_getsafety (void)
{
   HB_TRACE(HB_TR_DEBUG, ("ct_getsafety()"));
   return (s_bSafety);
}

HB_FUNC (CSETSAFETY)
{

   hb_retni (ct_getsafety());

   if (HB_ISLOG (1))
   {
      ct_setsafety(hb_parnl (1));
   }

   return;

}

LONG ct_StrFile( BYTE *pFileName, BYTE *pcStr, ULONG ulLen, BOOL bOverwrite, LONG lOffset, BOOL bTrunc)
{
   HB_FHANDLE hFile;
   BOOL bOpen = FALSE;
   BOOL bFile = hb_fsFile(pFileName);
   ULONG ulWrite = 0;

   if( bFile && bOverwrite)
   {
      hFile = hb_fsOpen(pFileName, FO_READWRITE);
      bOpen = TRUE;
   }
   else if ( ! bFile || ! ct_getsafety() )
   {
      hFile = hb_fsCreate(pFileName, ct_getfcreate() );
   }
   else
   {
      hFile = FS_ERROR;
   }

   if( hFile != FS_ERROR )
   {
      if ( lOffset )
      {
         hb_fsSeek(hFile, lOffset, FS_SET);
      }
      else if (bOpen)
      {
         hb_fsSeek(hFile, 0, FS_END);
      }

      ulWrite = hb_fsWriteLarge(hFile, pcStr, ulLen);
      if( (ulWrite == ulLen) && bOpen && bTrunc)
      {
         hb_fsWrite(hFile, NULL, 0);
      }

      hb_fsClose( hFile );
   }
   return( ulWrite );
}

HB_FUNC (STRFILE)
{

   if ( HB_ISCHAR(1) && HB_ISCHAR(2) )
   {
      hb_retnl( ct_StrFile((BYTE *) hb_parc(2), (BYTE *) hb_parc (1), hb_parclen (1), (HB_ISLOG(3) ? hb_parl(3) : 0 ),
         (HB_ISNUM(4) ? hb_parnl(4) : 0), (HB_ISLOG(5) ? hb_parl(5) : 0 ) ) );
   }
   else
   {
      hb_retnl(0);
   }

}

HB_FUNC (FILESTR)
{

   if ( HB_ISCHAR(1) )
   {
      HB_FHANDLE hFile = hb_fsOpen((BYTE *) hb_parc(1), FO_READ);

      if( hFile != FS_ERROR )
      {
         LONG lFileSize = hb_fsSeek(hFile, 0, FS_END);
         LONG lPos = hb_fsSeek(hFile, (HB_ISNUM(3) ? hb_parnl(3) : 0), FS_SET);
         LONG lLength = HB_ISNUM(2) ? HB_MIN(hb_parnl(2), lFileSize - lPos) : lFileSize - lPos;
         char * pcResult = (char *) hb_xgrab(lLength + 1);
         BOOL bCtrlZ = (HB_ISLOG(4) ? hb_parl(4) : 0 );
         char * pCtrlZ;

         if( lLength > 0)
         {
            lLength = hb_fsReadLarge(hFile, (BYTE *) pcResult, (ULONG) lLength);
         }

         if( bCtrlZ )
         {
            pCtrlZ = (char *) memchr(pcResult, 26, lLength);
            if( pCtrlZ )
            {
               lLength = pCtrlZ - pcResult;
            }
         }

         hb_fsClose( hFile );
         hb_retclen(pcResult, lLength);
         hb_xfree(pcResult);
      }
      else
      {
         hb_retc("");
      }
   }
   else
   {
      hb_retc("");
   }

}

#pragma ENDDUMP

#include 'PdfWork.prg'
