/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Extend COMBOBOX demo & tests by Jacek Kubica
 * (C)2005 Jacek Kubica <kubica@wssk.wroc.pl>
 *  HMG 1.0 Experimental Build 8
*/

#include "minigui.ch"

#define DRIVE_NO_ROOT  1
#define DRIVE_REMOVABLE 2
#define DRIVE_FIXED  3
#define DRIVE_REMOTE 4
#define DRIVE_CDROM  5

*------------------------------------------------
Function Main()
*------------------------------------------------

Local cDrives := HMG_GetDriveStrings()
Local aMyDriveTypes := _SPLIT( cDrives, chr(0) ),i
Local aDriveTypes:={},aDriveImage:={},cDriveType:=""

for i = 1 to len(aMyDriveTypes)-2

   if GETDRIVETYPE(  alltrim(lower(aMyDriveTypes[i]))  )     == DRIVE_REMOVABLE
      AADD(aDriveImage,"FLOPPY")
   elseif GETDRIVETYPE(  alltrim(lower(aMyDriveTypes[i]))  ) == DRIVE_FIXED
      AADD(aDriveImage,"HD")
   elseif GETDRIVETYPE(  alltrim(lower(aMyDriveTypes[i]))  ) == DRIVE_REMOTE
      AADD(aDriveImage,"NET")
   elseif GETDRIVETYPE(  alltrim(lower(aMyDriveTypes[i]))  ) == DRIVE_CDROM
      AADD(aDriveImage,"CDROM")
   else
      AADD(aDriveImage,"HD")
   endif
   AADD(aDriveTypes,left(aMyDriveTypes[i],2)+PADR(" ["+GETVOLINFO(alltrim(lower(aMyDriveTypes[i])))+"]",100) )
next i

   SET MULTIPLE OFF WARNING

   SET PROGRAMMATICCHANGE OFF

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 610 HEIGHT 310 ;
      TITLE 'Harbour MiniGUI Combo Extend Demo -  by Jacek Kubica <kubica@wssk.wroc.pl>' ;
      MAIN ;
      ON INIT OpenTables() ;
      ON RELEASE CloseTables()

     DEFINE MAIN MENU

         DEFINE POPUP 'Values'

         // Get Value of particular combo

            MENUITEM 'Get Value ComboEx_1'  ACTION MsgInfo(Str(Form_1.ComboEx_1.Value),"ComboEx_1")
            MENUITEM 'Get Value ComboEx_2'  ACTION MsgInfo(Str(Form_1.ComboEx_2.Value),"ComboEx_2")
            MENUITEM 'Get Value ComboEx_3'  ACTION MsgInfo(Str(Form_1.ComboEx_3.Value),"ComboEx_3")

            MENUITEM 'Get Value Combo_1std' ACTION MsgInfo(Str(Form_1.Combo_1std.Value),"Combo_1std")
            MENUITEM 'Get Value Combo_2std' ACTION MsgInfo(Str(Form_1.Combo_2std.Value),"Combo_2std")
            MENUITEM 'Get Value Combo_3std' ACTION MsgInfo(Str(Form_1.Combo_3std.Value),"Combo_3std")

            SEPARATOR

            MENUITEM 'Get Value URL ComboEx_4'  ACTION MsgInfo(_GetComboItemValue( "ComboEx_4", "Form_1", 2) )

            SEPARATOR

            MENUITEM 'Set ComboEx_1 Value to 0' ACTION Form_1.ComboEx_1.Value := 0
            MENUITEM 'Set ComboEx_1 Value to 3' ACTION Form_1.ComboEx_1.Value := 3
            MENUITEM 'Set Data ComboEx_2 Value to 3' ACTION Form_1.ComboEx_2.Value := 3

            SEPARATOR

         // Get DisplayValue of particular combo

            MENUITEM 'Get DisplayValue ComboEx_1'       ACTION  MsgInfo(Form_1.ComboEx_1.DisplayValue,"ComboEx_1")
            MENUITEM 'Get DisplayValue ComboEx_1wi'     ACTION  MsgInfo(Form_1.ComboEx_1wi.DisplayValue,"ComboEx_1wi")
            MENUITEM 'Get DisplayValue Data ComboEx_2'  ACTION  MsgInfo(Form_1.ComboEx_2.DisplayValue,"ComboEx_2")
            MENUITEM 'Get DisplayValue Combo_1std' ACTION  MsgInfo(Form_1.Combo_1std.DisplayValue,"Combo_1std")
            MENUITEM 'Get DisplayValue Data Combo_2std' ACTION  MsgInfo(Form_1.Combo_2std.DisplayValue,"Combo_2std")
            MENUITEM 'Get DisplayValue Combo_3std' ACTION  MsgInfo(Form_1.Combo_3std.DisplayValue,"Combo_3std")
            MENUITEM 'Get DisplayValue URL ComboEx_4'  ACTION  MsgInfo(Form_1.ComboEx_4.DisplayValue,"ComboEx_2")
         END POPUP

          DEFINE POPUP 'Tooltips'

          // set new tooltip for combo

            MENUITEM 'Set new tooltip for ComboEx_1' ACTION {|| (Form_1.ComboEx_1.Tooltip:='New tooltip exCombo1')}
            MENUITEM 'Set new tooltip for Data ComboEx_2' ACTION {|| (Form_1.ComboEx_2.Tooltip:='New tooltip Data exCombo2')}
            MENUITEM 'Set new tooltip for ComboEx_3' ACTION {|| (Form_1.ComboEx_3.Tooltip:='New tooltip exCombo2')}

          END POPUP

          DEFINE POPUP 'Items'

          // get items count from particular control

            MENUITEM 'Get Items Count ComboEx_1' ACTION MsgInfo (str(Form_1.ComboEx_1.ItemCount ) )
            MENUITEM 'Get Items Count Combo_1std' ACTION  MsgInfo (str(Form_1.Combo_1std.ItemCount ) )

            SEPARATOR
        
          // adding new items to combo list
        
            MENUITEM 'Add new Item to ComboEx_1 with picture 1'  ACTION Form_1.ComboEx_1.AddItem ( "New Item", 1 )
            MENUITEM 'Add new Item to ComboEx_1 with picture 2'  ACTION Form_1.ComboEx_1.AddItem ( "New Item", 2 )

            MENUITEM 'Add new Item to Data ComboEx_2 with picture 1'  ACTION Form_1.ComboEx_2.AddItem ( "New Item", 1 )
            MENUITEM 'Add new Item to Data ComboEx_2 with picture 2'  ACTION Form_1.ComboEx_2.AddItem ( "New Item", 2 )

            MENUITEM 'Add new Item to Combo_1std '  ACTION Form_1.Combo_1std.AddItem ( "New Item" )
            MENUITEM 'Add new Item to Data Combo_2std '  ACTION Form_1.Combo_2std.AddItem ( "New Item" )

            SEPARATOR
 
          // deleting items form combo

            MENUITEM 'Delete Item 3 from ComboEx_1'       ACTION Form_1.ComboEx_1.DeleteItem ( 3 )
            MENUITEM 'Delete Current Item from ComboEx_1' ACTION Form_1.ComboEx_1.DeleteItem ( Form_1.ComboEx_1.Value )
            MENUITEM 'Delete AllItems from ComboEx_1'     ACTION Form_1.ComboEx_1.DeleteAllItems

          END POPUP

          DEFINE POPUP 'Misc'

             MENUITEM 'ComboEx_1 Enable ' ACTION {|| (Form_1.ComboEx_1.Enabled:=.t.)}
             MENUITEM 'ComboEx_1 Disable' ACTION {|| (Form_1.ComboEx_1.Enabled:=.f.)}

             MENUITEM 'ComboEx_2 Enable ' ACTION {|| (Form_1.ComboEx_2.Enabled:=.t.)}
             MENUITEM 'ComboEx_2 Disable' ACTION {|| (Form_1.ComboEx_2.Enabled:=.f.)}

             MENUITEM 'ComboEx_3 Enable ' ACTION {|| (Form_1.ComboEx_3.Enabled:=.t.)}
             MENUITEM 'ComboEx_3 Disable' ACTION {|| (Form_1.ComboEx_3.Enabled:=.f.)}

             MENUITEM 'URL ComboEx_4 Enable ' ACTION {|| (Form_1.ComboEx_4.Enabled:=.t.)}
             MENUITEM 'URL ComboEx_4 Disable' ACTION {|| (Form_1.ComboEx_4.Enabled:=.f.)}
             
             SEPARATOR

             MENUITEM "IsComboExtend ComboEx_1 ? " ACTION MsgInfo("This COMBO is" +  IIF(_IsComboExtend("ComboEx_1","Form_1")," "," not ") +"an extend Combo Control", "COMBO ComboEx_1")
             MENUITEM "IsComboExtend Combo_1Std ? " ACTION MsgInfo("This COMBO is" + IIF(_IsComboExtend("Combo_1Std","Form_1")," "," not ") +"an extend Combo Control", "COMBO Combo_1Std")
             
          END POPUP

          DEFINE POPUP 'ListWidth'
       
          // Get property Combo.ListWidth 
       
             MENUITEM "Get DropDown Width ComboEx_1 "ACTION  MsgBox( str(Form_1.ComboEx_1.ListWidth ) )
             MENUITEM "Get DropDown Width ComboEx_2 "ACTION  MsgBox( str(Form_1.ComboEx_2.ListWidth ) )
             MENUITEM "Get DropDown Width Combo_1Std "ACTION MsgBox( str(Form_1.Combo_1Std.ListWidth ) )
             MENUITEM "Get DropDown Width Combo_2Std "ACTION MsgBox( str(Form_1.Combo_2Std.ListWidth ) )
        
             SEPARATOR

          // set new value for Combo.ListWidth property

             MENUITEM "Set DropDown Width ComboEx_1  to 200 " ACTION  {|| ( Form_1.ComboEx_1.ListWidth  := 200 )}
             MENUITEM "Set DropDown Width ComboEx_2  to 200 " ACTION  {|| ( Form_1.ComboEx_2.ListWidth  := 200 )} 
             MENUITEM "Set DropDown Width Combo_1Std to 200 " ACTION  {|| ( Form_1.Combo_1Std.ListWidth := 200 )} 
             MENUITEM "Set DropDown Width Combo_2Std to 200 " ACTION  {|| ( Form_1.Combo_2Std.ListWidth := 200 )}
        
             SEPARATOR

          // reset Combos Listview width to control width
        
             MENUITEM "ReSet DropDown Width ComboEx_1  " ACTION  {|| ( Form_1.ComboEx_1.ListWidth  := 0 )}
             MENUITEM "ReSet DropDown Width ComboEx_2  " ACTION  {|| ( Form_1.ComboEx_2.ListWidth  := 0 )} 
             MENUITEM "ReSet DropDown Width Combo_1Std " ACTION  {|| ( Form_1.Combo_1Std.ListWidth := 0 )} 
             MENUITEM "ReSet DropDown Width Combo_2Std " ACTION  {|| ( Form_1.Combo_2Std.ListWidth := 0 )}

          END POPUP

      END MENU

      // first extend combo

         @ 10,10 COMBOBOXEX ComboEx_1 ;
           WIDTH 150 ;
           ITEMS aDriveTypes ;
           VALUE 1 ;
           ON ENTER TONE(800) ;
           FONT 'MS Sans serif' SIZE 9 ;
           IMAGE aDriveImage   ;
           TOOLTIP "Extend Combo ComboEx_1 - Edit disabled"

         @ 33,10 Label Label_1ex Value "Extend ComboEx_1"


      // 2nd extend combo - ITEMSOURCE (Data combo )

         @ 60,10 COMBOBOXEX ComboEx_2 ;
                 WIDTH 150 ;
                 ITEMSOURCE CITIES->NAME;
                 VALUE 1 ;
                 FONT 'MS Sans serif' SIZE 9 ;
                 ON CHANGE MsgBox("RecNo. "+alltrim(str(This.Value))+" "+This.DisplayValue+" selected");
                 IMAGE {{"br0","br2"},"br2"} ;
                 Tooltip "Extend Data ComboEx_2 - Edit disabled"

         @ 83,10 Label Label_2ex Value "Extend Data ComboEx_2" AUTOSIZE

      // 3rd extend COMBO

         @ 110,10 COMBOBOXEX ComboEx_3 ;
           WIDTH 150 ;
           ITEMS {"one            ","two            ","tree           "} ;
           VALUE 1 ;
           DISPLAYEDIT;
           ON ENTER MsgBox(This.DisplayValue,Str(this.Value)) ;
           FONT 'MS Sans serif' SIZE 9 ;
           TOOLTIP "Extend ComboEx_3 - Edit enabled" ;
           IMAGE {"br0","br2","br1"}

         @ 133,10 Label Label_3ex Value "Extend ComboEx_3 - Edit" AUTOSIZE


           @ 160,10 COMBOBOXEX ComboEx_4 ;
              WIDTH 530 ;
              ITEMS {"http://hmgextended.com","http://harbourminigui.blogspot.com","http://harbour-project.org","http://groups.yahoo.com/group/harbourminigui"} ;
              VALUE 1 ;
              DISPLAYEDIT;
              ON ENTER RunMSIE(This.DisplayValue) ;
              FONT 'MS Sans serif' SIZE 10 ;
              Tooltip "Select or modify URL and press RETURN Key to open Browser" ;
              IMAGE {"mse","mse","mse","mse"}

              @ 185,10 Label Label_4ex Value "URL Extend ComboEx_4 - Edit enabled" AUTOSIZE

              @ 160,545 BUTTON Button_URL CAPTION "Go!" WIDTH 30 HEIGHT 25 FONT 'MS Sans serif' SIZE 9 BOLD ;
                        ACTION RunMSIE(Form_1.ComboEx_4.DisplayValue)

      // 1st standard COMBO

      @ 10,200 COMBOBOX Combo_1std ;
         WIDTH 50 ;
         LISTWIDTH 150;
         ITEMS aDriveTypes ;
         VALUE 1 ;
         ON ENTER TONE(800) ;
         FONT 'MS Sans serif' SIZE 9    ;
         TOOLTIP "Standard Combo_1std - Edit disabled"

         @ 33,200 Label Label_1std Value "Standard Combo_1std" AUTOSIZE

       // 2nd standard COMBO with ITEMSOURCE set

         @ 60,200 COMBOBOX Combo_2std ;
           WIDTH 150 ;
           ITEMSOURCE CITIES->NAME;
           VALUE 5 ;
           ON ENTER msgbox("Here I am") ;
           FONT 'MS Sans serif' SIZE 9 ;
           ON CHANGE MsgBox("RecNo. "+alltrim(str(This.Value))+" "+This.DisplayValue+" selected");
           TOOLTIP "Standard Data Combo_2std";

         @ 83,200 Label Label_2std Value "Standard Data Combo_2std" AUTOSIZE

         // 3rd standard COMBO with with DISPLAYEDIT clause set

         @ 110,200 COMBOBOX Combo_3std ;
            WIDTH 150 ;
            ITEMS  {"one","two","three","four","five","six"} ;
            VALUE 1 ;
            DISPLAYEDIT ;
            FONT 'MS Sans serif' SIZE 9 ;
            TOOLTIP "Standard Combo_3std - Edit enabled"

         @ 133,200 Label Label_3std Value "Standard Combo_3std - Edit"  AUTOSIZE


        // 1st extend COMBO without image list set

           @ 10,390 COMBOBOXEX ComboEx_1wi ;
              WIDTH 150 ;
              ITEMS aDriveTypes ;
              VALUE 1 ;
              ON GOTFOCUS  {|| (This.FontBold := .T.) };
              ON LOSTFOCUS {|| (This.FontBold := .F.)};
              ON ENTER MsgBox ( Str(This.value),"This.Value" ) ;
              FONT 'MS Sans serif' SIZE 9;
              TOOLTIP "Extend ComboEx_1wi without images - Edit disabled"

           @ 33,390 Label Label_1wi Value "Extend ComboEx_1wi w/o img." AUTOSIZE

          // 2nd extend COMBO without image list set

          @ 60,390 COMBOBOXEX ComboEx_2wi ;
               WIDTH 150 ;
               ITEMSOURCE CITIES->NAME;
               VALUE 2 ;
               FONT 'MS Sans serif' SIZE 9 ;
               ON CHANGE MsgBox("RecNo. "+alltrim(str(This.Value))+" "+This.DisplayValue+" selected");
               TOOLTIP "Extend Data ComboEx_2wi without images - Edit disabled"

          @ 83,390 Label Label_2wi Value "Extend ComboEx_2wi w/o img." AUTOSIZE

          // 3rd extend COMBO without image list set

          @ 110,390 COMBOBOXEX ComboEx_3wi ;
            WIDTH 150 ;
            ITEMS  {"one","two","three","four","five","six"} ;
            VALUE 1 ;
            DISPLAYEDIT ;
            FONT 'MS Sans serif' SIZE 9 ;
            ON DISPLAYCHANGE {|| TONE(100)} ;
            TOOLTIP "Extend ComboEx_3wi without images - Edit enabled"

            @ 133,390 Label Label_3wi Value "Extend ComboEx_3wi - Edit w/o img." AUTOSIZE

            // AltSyntax test

            DEFINE COMBOBOXEX ComboEx_1alt
              ROW   210
              COL   10
              WIDTH 150
              FONTNAME  'MS Sans serif'
              FONTSIZE  9
              LISTWIDTH 150
              ITEMS {'One','Two','Three'}
              IMAGE {"br0","br2","br1"}
              VALUE 3
              TOOLTIP 'ComboEx_1alt AltSyntax'
            END COMBOBOXEX

            @ 235,10 Label Label_ComboEx_1alt Value "Ext. ComboEx_1alt - AltSynt." AUTOSIZE

             DEFINE COMBOBOXEX ComboEx_2alt
              ROW   210
              COL   200
              WIDTH 50
              FONTNAME  'MS Sans serif'
              FONTSIZE  9
              ITEMSOURCE CITIES->NAME
              LISTWIDTH 150
              IMAGE {{"br0","br2"}}
              VALUE 2
              TOOLTIP 'ComboEx_2alt AltSyntax - Data'
            END COMBOBOXEX

            @ 235,200 Label Label_ComboEx_2alt Value "Ext. ComboEx_2alt - AltSynt." AUTOSIZE

              DEFINE COMBOBOXEX ComboEx_3alt
              ROW   210
              COL   390
              WIDTH 150
              DISPLAYEDIT .t.
              FONTNAME  'MS Sans serif'
              FONTSIZE  9
              ITEMS  {"one","two","three","four","five","six"}
              VALUE 2
              TOOLTIP 'ComboEx_3alt AltSyntax - Edit enabled'
            END COMBOBOXEX

            @ 235,390 Label Label_ComboEx_3alt Value "Ext. ComboEx_3alt - AltSynt." AUTOSIZE

   END WINDOW

   if IsVistaOrLater()
      Form_1.ComboEx_4.SetFocus
   endif

   Form_1.Center
   Form_1.Activate

Return Nil

*-------------------------------
Function RunMSIE(cURL)
*-------------------------------
Local cItemValue:="", nSeleValue:=0, iTotal:=Form_1.ComboEx_4.ItemCount ,i

// check for existing URL

for i:=1 to iTotal
   cItemValue:=_GetComboItemValue( "ComboEx_4", "Form_1", i)
   if alltrim(upper( cItemValue)) == alltrim(upper(cURL))
      nSeleValue:=i
   endif
next i

// adde new item if not present

If nSeleValue==0
   Form_1.ComboEx_4.AddItem(cUrl,1)
   Form_1.ComboEx_4.Value:= iTotal+1
   else
   Form_1.ComboEx_4.Value:=nSeleValue
endif

// run browser

ShellExecute(0, "open", "rundll32.exe", "url.dll,FileProtocolHandler " + cUrl, ,1)

Return NIL

*-------------------------------
Function HMG_GetDriveStrings()
*-------------------------------
Local cBuffer:=space(300)

GETLOGICALDRIVESTRINGS(len(cBuffer),@cBuffer)

Return alltrim(cBuffer)

*-------------------------------
Function HMG_GetDriveTypeString(cDrive)
*-------------------------------
Local i:=0, cRet:=""

i:=GETDRIVETYPE(cDrive)

if i==0
  cRet:="[unknow]"
elseif i==DRIVE_NO_ROOT
  cRet:="[uroot]"
elseif i==DRIVE_REMOVABLE
  cRet:="[remov]"
elseif i==DRIVE_FIXED
  cRet:="[hdd]"
elseif i==DRIVE_REMOTE
  cRet:="[net]"
elseif i==DRIVE_CDROM
  cRet:="[cd-rom]"
endif

Return cRet

*--------------------------------------
Static Function _SPLIT( elstr, _separator )
*--------------------------------------
Local aElems := {}, Elem, _sep := IIF( ! EMPTY( _separator ), _separator, " " )
Local nSepPos:=0

If !EMPTY(elstr)
   elstr := alltrim( elstr )
   do while AT( _sep, elstr ) > 0
      nSepPos := AT( _sep, elstr )
      if nSepPos > 0
         Elem  := LEFT( elstr, nSepPos - 1 )
         elstr := SUBSTR( elstr, LEN( Elem ) + 2 )
         AADD( aElems, Elem )
      endif
   enddo
   AADD( aElems, elstr )
endif

Return ( aElems )

Procedure Opentables()
   Use CITIES New
Return

Procedure CloseTables()
   Use
Return

*--------------------------------------
Function HMG_GetVolumeName(cPath)
*--------------------------------------
Local cVolName:=space(256),cFatName:=space(30),nFlag
      GetVolumeInformation(cPath,cVolName,NIL,len(cVolName),56,nFlag,cFATName )
Return alltrim(cVolName)

*--------------------------------------
Static Function IsVistaOrLater()
*--------------------------------------
   Local cOSName := WindowsVersion() [1]

Return ( 'Vista' $ cOSName .Or. '7' $ cOSName .Or. ' 8' $ cOSName )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#define ISBYREF( n )        HB_ISBYREF( n )
#define ISNIL( n )          HB_ISNIL( n )
#endif

HB_FUNC ( GETDRIVES )
{
   DWORD dwDrives=GetLogicalDrives();
   DWORD dwMask=1;
   DWORD dwCount=0, i;
   char szPath[4]="A:\\";

   for(i=0;i<27;i++)
   {
      if (dwDrives&dwMask) dwCount++;
      dwMask<<=1;
   }

   hb_reta(dwCount);

   dwCount=0;
   dwMask=1;
   szPath[3]=0;

   for(i=0;i<27;i++)
   {
      if (dwDrives&dwMask)
      {
         szPath[0]='A'+i;
         HB_STORC(szPath,-1,++dwCount);
      }
      dwMask<<=1;
   }
}

//--------------------------------------
HB_FUNC( GETLOGICALDRIVESTRINGS )
//--------------------------------------
{
   hb_retnl( (LONG) GetLogicalDriveStrings( (DWORD) hb_parnl( 1 ),
                                             (LPSTR) hb_parc( 2 )
                                             ) ) ;
}

//--------------------------------------
HB_FUNC( GETDRIVETYPE )
//--------------------------------------
{
   hb_retni( GetDriveType( (LPCSTR) hb_parc( 1 ) ) ) ;
}

//--------------------------------------
HB_FUNC( GETVOLINFO )
//--------------------------------------
{
    int iretval;
    const char * sDrive = hb_parc(1);
    char sVolName[255];

    if ( sDrive[0] == 0 )
    {
       sDrive = NULL;
    }
    iretval = GetVolumeInformation( sDrive,
                                    sVolName,
                                    256,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    0 );

    if ( iretval!=0 )
       hb_retc( sVolName );
    else
       hb_retc("");
}

HB_FUNC( GETVOLUMEINFORMATION )
{
  char *VolumeNameBuffer     = (char *) hb_xgrab( MAX_PATH ) ;
  DWORD VolumeSerialNumber                              ;
  DWORD MaximumComponentLength                          ;
  DWORD FileSystemFlags                                 ;
  char *FileSystemNameBuffer = (char *) hb_xgrab( MAX_PATH )  ;
  BOOL bRet;

  bRet = GetVolumeInformation( ISNIL(1) ? NULL : (LPCTSTR) hb_parc(1) ,
                                  (LPTSTR) VolumeNameBuffer              ,
                                  MAX_PATH                               ,
                                  &VolumeSerialNumber                    ,
                                  &MaximumComponentLength                ,
                                  &FileSystemFlags                       ,
                                  (LPTSTR)FileSystemNameBuffer           ,
                                  MAX_PATH ) ;
  if ( bRet  )
  {
     if ( ISBYREF( 2 ) )  hb_storc ((char *) VolumeNameBuffer, 2 ) ;
     if ( ISBYREF( 3 ) )  hb_stornl( (LONG)  VolumeSerialNumber, 3 ) ;
     if ( ISBYREF( 4 ) )  hb_stornl( (LONG)  MaximumComponentLength, 4 ) ;
     if ( ISBYREF( 5 ) )  hb_stornl( (LONG)  FileSystemFlags, 5 );
     if ( ISBYREF( 6 ) )  hb_storc ((char *) FileSystemNameBuffer, 6 );
  }

  hb_retl(bRet);
  hb_xfree( VolumeNameBuffer );
  hb_xfree( FileSystemNameBuffer );
}

#pragma ENDDUMP
