ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_propgrid.ch"

#define MsgInfo( c )   MsgInfo( c, , , .f. )

MEMVAR mPg_SysCol, mPg_Color, mPg_Font, mPg_Label, mPg_Image, mPg_Enum
MEMVAR mPg_Check1, mPg_Check2, mPg_Check3, mPg_Date, mPg_Flag, mPg_Float
MEMVAR mPg_Int, mPg_Float2, mPg_LabelM


Function main()

   Public mPg_SysCol :='ButtonHighlight'
   Public mPg_Color := '(208,205,188)'
   Public mPg_Font := 'Arial, 8, Italic'
   Public mPg_Label := "CustomProperty"
   Public mPg_LabelM := "Masked text"
   Public mPg_Image :='Image.bmp'
   Public mPg_Enum := 'Windows 98'
   Public mPg_Check1 := 'Option 1'
   Public mPg_Check2 := 'False'
   Public mPg_Check3 := 'Excluded'
   Public mPg_Date := DToC(Date())
   Public mPg_Flag := '[Windows 98]'
   Public mPg_Float := '234.98'
   Public mPg_Float2 := '7125.13'
   Public mPg_Int := '17'

   if file("PG_Var.mem")
      rest from pg_var additive
   else
      save all like mPg_* to pg_var
   endif


   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 670 ;
      HEIGHT 500 ;
      TITLE 'PropertyGrid for Variable Sample' ;
      MAIN ;
      NOMAXIMIZE

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM 'Load Property from TXT file' ACTION  LoadDemoFile("PropGrid.txt")
            ITEM 'Load Property from XML file' ACTION  LoadDemoFile("PropGrid.xml",.t.)
            ITEM 'Load Property from INI file' ACTION  LoadDemoFile("PropGrid.ini")
            SEPARATOR
            ITEM 'Read from XML file' ACTION ReadXml("PropGrid.xml")
            ITEM 'Read from TXT file' ACTION ReadTxt("PropGrid.txt")
         END POPUP
         POPUP '&Test'
            ITEM 'HIDE Item' ACTION Form_1.PropertyGrid_1.hide
            ITEM 'SHOW Item' ACTION Form_1.PropertyGrid_1.show
            SEPARATOR
            ITEM 'Get Value selected Item' ACTION DisplPGValue("PropertyGrid_1","Form_1",0)
            ITEM 'Get Property Info selected Item' ACTION DisplPGInfo("PropertyGrid_1","Form_1",0)
            SEPARATOR
            ITEM 'Disabled selected Item' ACTION EnablePropGridItem("Form_1","PropertyGrid_1",107,.f.)
            ITEM 'Enabled selected Item' ACTION EnablePropGridItem("Form_1","PropertyGrid_1",107,.t.)
         END POPUP
         POPUP '&Help'
            ITEM '&About'    ACTION MsgInfo ("MiniGUI PropertyGrid demo"+CRLF+"Version 2.0"+CRLF+"by Janusz Pora")
         END POPUP

      END MENU

   DEFINE PROPGRID PropertyGrid_1   ;
     AT 15,10   WIDTH 430 HEIGHT 390 ;
     HEADER "Property Name","Value";
     FONTCOLOR {0,0,0} INDENT  10  DATAWIDTH 280;
     BACKCOLOR {240,240,240};
     ON CHANGEVALUE  RejChd();
     OKBTN  APPLYBTN;
     CANCELBTN;
     HELPBTN  MsgInfo( "Help Button User");
     ITEMINFO

      DEFINE CATEGORY 'Appearance'
         PROPERTYITEM SYSCOLOR 'Collour' VALUE mPg_SysCol INFO "Colour of background of cell"
         PROPERTYITEM COLOR 'Line Colour' VALUE  mPg_Color  ITEMDATA '208;205;188' DISABLEEDIT INFO "Colour for line, choose from palette of colours"
         PROPERTYITEM FONT 'Font' VALUE mPg_Font  ITEMDATA 'Arial; 8; false; true; false; false' DISABLEEDIT INFO "Basic font for application"
      END CATEGORY
      DEFINE CATEGORY 'Custom User Property'
         PROPERTYITEM STRING "Label" VALUE mPg_Label INFO "Example - text for test"
//         PROPERTYITEM STRING "Masked Label" VALUE mPg_LabelM ITEMDATA '!NN.!N' INFO "Example - Masked text for test"
         PROPERTYITEM IMAGE 'Image' VALUE mPg_Image ITEMDATA  '*.bmp;*.ico' DISABLEEDIT
         PROPERTYITEM ENUM 'Enum Item' VALUE mPg_Enum  ITEMDATA  'Windows 98;Windows 2000;Windows XP;Windows Vista' INFO "Application be tested under system"
         PROPERTYITEM CHECK 'Check Item 1' VALUE mPg_Check1  ITEMDATA 'true' INFO "Example 1 - Check with default option"
         PROPERTYITEM CHECK 'Check Item 2' VALUE mPg_Check2  ITEMDATA 'False;True' INFO "Example 2 - Check with option : True and False"
         PROPERTYITEM CHECK 'Check Item 3' VALUE mPg_Check3  ITEMDATA 'Excluded;Included' INFO "Example 3 - Check with option : Included and Excluded"
         PROPERTYITEM DATE 'Date' VALUE  mPg_Date
         PROPERTYITEM FLAG 'Flag Item' VALUE mPg_Flag ITEMDATA  'All Windows;Windows 98;Windows 2000;Windows XP;Windows Vista' INFO "It application works for chosen systems"
         PROPERTYITEM LIST 'Edit List Item'  VALUE 'Windows 98' ITEMDATA  'Windows 98;Windows 2000;Windows XP;Windows Vista' INFO "Add new System to list"
         PROPERTYITEM USERFUN 'User Function Item'  ITEMDATA  'GetFolder()' INFO "Activity User Function to get new value"
         PROPERTYITEM PASSWORD 'Edit Password Item'  ITEMDATA  'PgKey' INFO "Example - Password entry"
      END CATEGORY
      DEFINE CATEGORY 'Numeric Entry Property'
         PROPERTYITEM DOUBLE 'Float  Item'  VALUE mPg_Float  INFO "Example - Float (double) entry"
         PROPERTYITEM DOUBLE 'Float (masked) Item'  VALUE mPg_Float2 ITEMDATA  '999 999.99' INFO "Example - Masked Float (double) entry"+CRLF+"for example '999 999.99'"
         PROPERTYITEM NUMERIC 'Integer Item'  VALUE mPg_Int  INFO "Example - Integer (Numeric) entry"
      END CATEGORY
      DEFINE CATEGORY 'Environment'
         PROPERTYITEM SYSINFO "Operating System" ITEMDATA 'SYSTEM' DISABLED
         PROPERTYITEM SYSINFO 'User Home'  ITEMDATA 'USERHOME'
         PROPERTYITEM SYSINFO "User Id"  ITEMDATA 'USERID' DISABLED
         PROPERTYITEM SYSINFO "User Name" ITEMDATA 'USERNAME' DISABLED
      END CATEGORY

   END PROPGRID

      DISABLE PROPERTYITEM PropertyGrid_1 ID 107

      @ 10,480 FRAME Frame_1 WIDTH 140 HEIGHT 120 CAPTION "Property from:"
      @ 30,500 BUTTON btn_1;
            CAPTION "File Txt";
            ACTION  LoadDemoFile("PropGrid.txt");
            WIDTH 100 HEIGHT 24


      @ 60,500 BUTTON btn_2;
            CAPTION "File Xml";
            ACTION   LoadDemoFile("PropGrid.xml",.t.) ;
            WIDTH 100 HEIGHT 24

      @ 90,500 BUTTON btn_3;
            CAPTION "File Ini";
            ACTION  LoadDemoFile("PropGrid.ini");
            WIDTH 100 HEIGHT 24

      @ 160,480 FRAME Frame_2 WIDTH 140 HEIGHT 110 CAPTION "Saving a copy to:"

      @ 180,500 BUTTON btn_5;
            CAPTION "File Txt";
            ACTION PgSaveFile("Form_1","PropertyGrid_1","PropGrid1.txt") ;
            WIDTH 100 HEIGHT 24


      @ 210,500 BUTTON btn_6;
            CAPTION "File Xml";
            ACTION PgSaveFile("Form_1","PropertyGrid_1","PropGrid1.xml") ;
            WIDTH 100 HEIGHT 24

      @ 240,500 BUTTON btn_7;
            CAPTION "File Ini";
            ACTION PgSaveFile("Form_1","PropertyGrid_1","PropGrid1.ini") ;
            WIDTH 100 HEIGHT 24

      @ 290,490 BUTTON btn_10;
            CAPTION "Collapse/Expand";
            ACTION ToggleExpandPG("Form_1","PropertyGrid_1") ;
            WIDTH 120 HEIGHT 24

      @ 330,490 BUTTON btn_11;
            CAPTION "Save Variables";
            ACTION SaveChdPar("PropertyGrid_1","Form_1") ;
            WIDTH 120 HEIGHT 24

      @ 370,490 BUTTON btn_12;
            CAPTION "Info Hide/Show";
            ACTION _ShowInfoItem  ("Form_1","PropertyGrid_1") ;
            WIDTH 120 HEIGHT 24

   END WINDOW

   Form_1.Btn_11.Enabled :=.f.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

*------------------------------------------------------------------------------*
FUNCTION ToggleExpandPG(ParentForm,ControlName)
*------------------------------------------------------------------------------*
   LOCAL k
   k := GetControlIndex ( ControlName, ParentForm )
   IF k > 0
      ExpandPG( _HMG_aControlHandles  [k,1], 0)
   ENDIF
RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION LoadDemoFile(cFile,lXml)
*------------------------------------------------------------------------------*
DEFAULT lXml := .f.
   PgLoadFile("Form_1","PropertyGrid_1", cFile, lXml)
RETURN nil

*------------------------------------------------------------------------------*
FUNCTION ReadTxt(cFile)
*------------------------------------------------------------------------------*
   LOCAL aProp,k
   k := GetControlIndex ( "PropertyGrid_1", "Form_1" )
   aProp := _LoadProperty(cFile, k)
   DispArray(aProp)
RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION DispArray(aProp)
*------------------------------------------------------------------------------*
   LOCAL n,i, cStr:="",cItem
   FOR n:=1 TO Len(aProp)
      cItem:=aProp[n]
      IF ValType(cItem) == 'A'
         FOR i:=1 TO Len(cItem)
            IF ValType(cItem[i]) == 'C'
               cStr += cItem[i]+','
            ELSE
               if  ValType(cItem[i])=='L'
                  cStr += IF(cItem[i],'.T.','.F.')+','
               else
                  cStr += ValType(cItem[i])+','
               endif
            ENDIF
         NEXT
         cStr += CRLF
      ENDIF
   NEXT
   MsgInfo(cStr)
RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION ReadXml(cFile)
*------------------------------------------------------------------------------*
   LOCAL oXmlDoc := HXMLDoc():Read( cFile )
   MsgInfo(oXmlDoc:Save2String())
RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION DisplPGValue(PGname,cForm,nId)
*------------------------------------------------------------------------------*
   LOCAL xValue,cType
   LOCAL cStr
   IF nId==0
      cStr:= "The variable for selected item "
   else
      cStr :="The variable for item of ID "+alltrim(Str(nId))+" is type: "
   endif
   GET PROPERTYITEM &PGName OF  &cForm ID nId TO  xValue
   IF valtype(xValue)!='U'
      cStr += " is type: "
      cType := valtype(xValue)
   ELSE
      cStr += " is not available"
      cType := ""
   endif
   DO CASE
      CASE cType $  "CM";  MsgInfo(cStr+cType+CRLF+xValue)
      CASE cType == "D" ;  MsgInfo(cStr+cType+CRLF+DToC( xValue ))
      CASE cType == "N" ;  MsgInfo(cStr+cType+CRLF+Str( xValue ))
      CASE cType == "L" ;  MsgInfo(cStr+cType+CRLF+if(xValue == .t.,'TRUE','FALSE') )
      CASE cType == "A" ;  MsgInfo(cStr+cType+CRLF+ AToC( xValue ))
      OTHERWISE;           MsgInfo(cStr+cType+CRLF+'NIL' )
   ENDCASE
RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION DisplPGInfo(PGname,cForm,nId)
*------------------------------------------------------------------------------*
   LOCAL xValue,aValue,n
   LOCAL cStr
   LOCAL aType := {"Name        - ",;
                   "Value       - ",;
                   "Data        - ",;
                   "Disabled    - ",;
                   "Changed     - ",;
                   "DisableEdit - ",;
                   "Item Type   - ",;
                   "Item ID     - ",;
                   "Info        - ",;
                   "Variable    - "}
   IF nId==0
      cStr:= "The array info for selected item: "+CRLF+CRLF
   else
      cStr :="The array info for item of ID "+alltrim(Str(nId))+":"+CRLF
   endif
   GET INFO PROPERTYITEM &PGName OF  &cForm ID nId TO  aValue
   IF valtype(aValue)!='A'
      cStr += " ERROR by read Property Info! "
   ELSE
      FOR n:= 1 TO Len (aValue)
         cStr += aType[n]
         xValue := aValue[n]
         DO CASE
         CASE ValType(xValue) $  "CM";  cStr += xValue+CRLF
         CASE ValType(xValue) == "D" ;  cStr += DToC( xValue )+CRLF
         CASE ValType(xValue) == "N" .and. n==7;  cStr += PgIdentType( xValue )+CRLF
         CASE ValType(xValue) == "N" .and. n==8;  cStr += Str( xValue )+CRLF
         CASE ValType(xValue) == "L" ;  cStr += if(xValue == .t.,'TRUE','FALSE') +CRLF
         OTHERWISE;                     cStr += 'NIL' +CRLF
         ENDCASE
      NEXT
   Endif
   MsgInfo(cStr,"Info" )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION RejChd()
*------------------------------------------------------------------------------*

   Form_1.Btn_11.Enabled :=.t.

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION SaveChdPar(PGname,cForm)
*------------------------------------------------------------------------------*
LOCAL aValue,n, cVar

   // SaveMemVarible(cForm,PGName)
   SAVE MEMVALUE PROPERTY &PGName OF  &cForm

   Form_1.Btn_11.Enabled :=.f.
   SAVE ALL LIKE mPg_* TO pg_var

RETURN Nil


#ifdef __XHARBOUR__
  #include <fileread.prg>
#endif
