ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_propgrid.ch"
#include "i_xml.ch"

#define CLR_DEFAULT   0xff000000
#define MsgInfo( c )   MsgInfo( c, , , .f. )

Function main()
   LOCAL aProperty

      aProperty :=  {{'category','Category 1','','',.t.,.f.,.F.,100,''},;
                       {'string','Property 1','Value for Property 1','',.f.,.f.,.F.,101,'Info for Property 1'},;
                       {'string','Property 2','Value for Property 2 (Disabled)','',.t.,.f.,.F.,102,'Info for Property 2'},;
                       {'string','Property 3','Value for Property 3 (Disable Edit)','',.f.,.f.,.T.,103,'Info for Property 3'},;
                     {'category','end'},;
                     {'category','Category 2','','',.t.,.f.,.F.,200,''},;
                       {'string','Property 1','Value for Property 1','',.f.,.f.,.F.,201,'Info for Property 1'},;
                       {'string','Property 2','Value for Property 2 (Disabled )','',.t.,.f.,.F.,202,'Info for Property 2'},;
                       {'category','Category 3','','',.t.,.f.,.F.,203,''},;
                           {'string','Property 2.1','Value for Property 2.1','',.f.,.f.,.F.,2031,'Info for Property 2.1'},;
                           {'string','Property 2.2','Value for Property 2.2','',.f.,.f.,.F.,2032,'Info for Property 2.2'},;
                           {'string','Property 2.3','Value for Property 2.3 (Disabled)','',.t.,.f.,.F.,2033,'Info for Property 2.3'},;
                           {'string','Property 2.4','Value for Property 2.4 (Changed)','',.f.,.t.,.T.,2034,'Info for Property 2.4'},;
                           {'string','Property 2.5','Value for Property 2.5','',.f.,.f.,.F.,2035,'Info for Property 2.5'},;
                           {'string','Property 2.6','Value for Property 2.6 (Changed)','',.f.,.t.,.f.,2036,'Info for Property 2.6'},;
                           {'string','Property 2.7','Value for Property 2.7 (Disable Edit)','',.f.,.f.,.T.,2037,'Info for Property 2.7'},;
                           {'string','Property 2.8','Value for Property 2.8','',.f.,.f.,.F.,2038,'Info for Property 2.8'},;
                       {'category','end'},;
                       {'string','Property 3','Value for Property 3','',.t.,.f.,.T.,204,'Info for Property 3'},;
                     {'category','end'},;
                     {'category','Category 3','','',.t.,.f.,300,''},;
                         {'string','Property 1','Value for Property 1','',.f.,.f.,.F.,301,'Info for Property 1'},;
                         {'string','Property 2','Value for Property 2','',.f.,.f.,.F.,302,'Info for Property 2'},;
                         {'string','Property 3','Value for Property 3','',.f.,.f.,.F.,303,'Info for Property 3'},;
                         {'category','Category 3','','',.t.,.f.,3030,''},;
                            {'string','Property 3.1','Value for Property 3.1','',.f.,.f.,.F.,3031,'Info for Property 3.1'},;
                            {'string','Property 3.2','Value for Property 3.2','',.f.,.f.,.F.,3032,'Info for Property 3.2'},;
                         {'category','end'},;
                     {'category','end'},;
                     {'category','Category 4','','',.t.,.f.,.T.,400,''},;
                     {'category','end'}}

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 670 ;
      HEIGHT 500 ;
      TITLE 'PropertyGridView Sample' ;
      MAIN ;
      NOMAXIMIZE NOSIZE

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM 'Load Property from Array' ACTION LoadPropertyArray("Form_1","PropertyGrid_1",aProperty)
            ITEM 'Load Property from TXT file' ACTION LoadDemoFile("PropGrid.txt")
            ITEM 'Load Property from XML file' ACTION LoadDemoFile("PropGrid.xml",.t.)
            ITEM 'Load Property from INI file' ACTION LoadDemoFile("PropGrid.ini")
            SEPARATOR
            ITEM 'Create XML ' ACTION CreateXml()
            SEPARATOR
            ITEM 'Read from XML file' ACTION ReadXml("PropGrid.xml")
            ITEM 'Read from TXT file' ACTION ReadTxt("PropGrid.txt")
         END POPUP
         POPUP '&Test'
            ITEM 'HIDE Item' ACTION Form_1.PropertyGrid_1.hide
            ITEM 'SHOW Item' ACTION Form_1.PropertyGrid_1.show
            SEPARATOR
            ITEM 'Get Value for ID 102' ACTION DisplPGValue("PropertyGrid_1","Form_1",102)
            ITEM 'Get Property Info for ID 102' ACTION DisplPGInfo("PropertyGrid_1","Form_1",102)
            ITEM 'Set Value "TEST" for ID 103' ACTION SetPGValue("PropertyGrid_1","Form_1",103)
            ITEM 'Add Item to Category 2' ACTION AddItemPG("PropertyGrid_1","Form_1",.t.)
            SEPARATOR
            ITEM 'Get Value selected Item' ACTION DisplPGValue("PropertyGrid_1","Form_1",0)
            ITEM 'Get Property Info selected Item' ACTION DisplPGInfo("PropertyGrid_1","Form_1",0)
            ITEM 'Set Value "TEST" to selected Item' ACTION SetPGValue("PropertyGrid_1","Form_1",0)
            ITEM 'Add Item to selected Category' ACTION AddItemPG("PropertyGrid_1","Form_1",.f.)
         END POPUP

      END MENU

      DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
         STATUSITEM StatMem(1)  ACTION Form_1.StatusBar.Item(1) := StatMem(1)
         STATUSITEM StatMem(2) WIDTH 130  ACTION Form_1.StatusBar.Item(2) :=StatMem(2)
         STATUSITEM StatMem(3) WIDTH 140  ACTION Form_1.StatusBar.Item(3) :=StatMem(3)
         STATUSITEM StatMem(4) WIDTH 140  ACTION Form_1.StatusBar.Item(4) :=StatMem(4)
         STATUSITEM StatMem(6) WIDTH 160  ACTION Form_1.StatusBar.Item(5) :=StatMem(6)
      END STATUSBAR

/*
      @ 35,10 PROPGRID PropertyGrid_1 WIDTH 430 HEIGHT 380 FROMFILE "PropGrid.xml" XML;
                        FONTCOLOR {0,0,0} INDENT  10  DATAWIDTH 280;
                        BACKCOLOR {240,240,240}
*/

      @ 35,10 PROPGRID PropertyGrid_1 WIDTH 430 HEIGHT 380 ARRAYITEM aProperty;
                        FONTCOLOR {0,0,0} INDENT  10  DATAWIDTH 280;
                        BACKCOLOR {240,240,240} ;
                        ON CHANGEVALUE  msgInfo('Item Value Changed') ;
                        ITEMINFO

      @ 10,480 FRAME Frame_1 WIDTH 140 HEIGHT 140 CAPTION "Property from:"
      @ 30,500 BUTTON btn_1;
            CAPTION "File Txt";
            ACTION  LoadDemoFile("PropGrid.txt");
            WIDTH 100 HEIGHT 24

      @ 60,500 BUTTON btn_2;
            CAPTION "File Xml";
            ACTION LoadDemoFile("PropGrid.xml",.t.);
            WIDTH 100 HEIGHT 24

      @ 90,500 BUTTON btn_3;
            CAPTION "File Ini";
            ACTION LoadDemoFile("PropGrid.ini");
            WIDTH 100 HEIGHT 24

      @ 120,500 BUTTON btn_4;
            CAPTION "Array";
            ACTION LoadPropertyArray("Form_1","PropertyGrid_1",aProperty);
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
            CAPTION "Test Property 2";
            ACTION TestPG2() ;
            WIDTH 120 HEIGHT 24

      @ 370,490 BUTTON btn_12;
            CAPTION "Info Hide/Show";
            ACTION _ShowInfoItem  ("Form_1","PropertyGrid_1") ;
            WIDTH 120 HEIGHT 24


   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

*------------------------------------------------------------------------------*
FUNCTION StatMem(ver)
*------------------------------------------------------------------------------*
   LOCAL aName:= { "Total memory","Available memory","Total page memory",;
                   "Total page memory","Total Virtual Memory","Available virtual memory" }
   IF ver>0
      RETURN aName[ver]+': '+AllTrim(Str(MemoryStatus(ver)))
   endif
RETURN "None"

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
FUNCTION LoadPropertyArray(ParentForm,ControlName,aProp)
*------------------------------------------------------------------------------*
   LOCAL k
   k := GetControlIndex ( ControlName, ParentForm )
   _InitPgArray(aProp, "", .f., k)

RETURN Nil

*------------------------------------------------------------------------------*
Function TestPG2()
*------------------------------------------------------------------------------*

   DEFINE WINDOW Form_2 ;
      AT 30,30 ;
      WIDTH 670 ;
      HEIGHT 500 ;
      TITLE 'PropertyGrid Sample 2' ;
      CHILD ;
      NOMAXIMIZE NOMINIMIZE NOSIZE


   DEFINE PROPGRID PropertyGrid_2   ;
     AT 35,10   WIDTH 430 HEIGHT 380 ;
     FONTCOLOR {0,0,0} INDENT  10  DATAWIDTH 280;
     BACKCOLOR {240,240,240};
//     ITEMINFO

      DEFINE CATEGORY 'Category 1'
         PROPERTYITEM 'Property 1' ITEMTYPE 'string'  VALUE 'Value for Property 1' INFO 'Test Item Info for Property 1'
         PROPERTYITEM 'Property 2' ITEMTYPE 'string'  VALUE 'Value for Property 2(Disabled)' DISABLED INFO 'Test Item Info for Property 2'
         DEFINE CATEGORY 'Category 2'
            PROPERTYITEM 'Property 1' ITEMTYPE 'string'  VALUE 'Value for Property 1'
            PROPERTYITEM 'Property 2' ITEMTYPE 'string'  VALUE 'Value for Property 2(Disabled)' DISABLED
            PROPERTYITEM 'Property 1' ITEMTYPE 'string'  VALUE 'Value for Property 1'
         END CATEGORY
      END CATEGORY

      DEFINE CATEGORY 'Appearance'
         PROPERTYITEM SYSCOLOR 'Collour' VALUE 'ButtonHighlight'
         PROPERTYITEM COLOR 'Line Colour' VALUE  '(208,205,188)' ITEMDATA '208;205;188'
         PROPERTYITEM FONT 'Font' VALUE 'Arial, 8, Italic' ITEMDATA 'Arial; 8; false; true; false; false'
      END CATEGORY
      DEFINE CATEGORY 'Custom User Property'
         PROPERTYITEM STRING "Label" VALUE "CustomProperty"
         PROPERTYITEM IMAGE 'Image' VALUE 'Image.bmp' ITEMDATA  '*.bmp;*.ico'
         PROPERTYITEM ENUM 'Enum Item' VALUE 'Windows 98' ITEMDATA  'Windows 98;Windows 2000;Windows XP;Windows Vista'
         PROPERTYITEM CHECK 'Check Item 1' VALUE 'Option 1' ITEMDATA 'true'
         PROPERTYITEM CHECK 'Check Item 2' VALUE 'False' ITEMDATA 'False;True'
         PROPERTYITEM CHECK 'Check Item 3' VALUE 'Option 3' ITEMDATA 'false' DISABLED
         PROPERTYITEM DATE 'Date' VALUE  DToC(Date()) //"02/13/2007"
         PROPERTYITEM FLAG 'Flag Item' VALUE '[Windows 98]' ITEMDATA  'All Windows;Windows 98;Windows 2000;Windows XP;Windows Vista'
      END CATEGORY
      DEFINE CATEGORY 'Environment'
         PROPERTYITEM SYSINFO "Operating System" VALUE '' ITEMDATA 'SYSTEM' DISABLED
         PROPERTYITEM SYSINFO 'User Home' VALUE '' ITEMDATA 'USERHOME'
         PROPERTYITEM SYSINFO "User Id" VALUE '' ITEMDATA 'USERID' DISABLED
         PROPERTYITEM SYSINFO "User Name" VALUE '' ITEMDATA 'USERNAME' DISABLED
      END CATEGORY

   END PROPGRID

      @ 160,480 FRAME Frame_2 WIDTH 140 HEIGHT 100 CAPTION "Property save to:"

      @ 180,500 BUTTON btn_1;
            CAPTION "File txt";
            ACTION PgSaveFile("Form_2","PropertyGrid_2","PropGrid2.txt") ;
            WIDTH 100 HEIGHT 24

      @ 215,500 BUTTON btn_2;
            CAPTION "File Xml";
            ACTION PgSaveFile("Form_2","PropertyGrid_2","PropGrid2.xml") ;
            WIDTH 100 HEIGHT 24

      @ 290,490 BUTTON btn_3;
            CAPTION "Collapse/Expand";
            ACTION ToggleExpandPG("Form_2","PropertyGrid_2") ;
            WIDTH 120 HEIGHT 24

      @ 330,490 BUTTON btn_4;
            CAPTION "Close Window";
            ACTION Form_2.Release ;
            WIDTH 120 HEIGHT 24


   END WINDOW

   ACTIVATE WINDOW Form_2

Return Nil

*------------------------------------------------------------------------------*
FUNCTION CreateXml()
*------------------------------------------------------------------------------*
      LOCAL oXmlDoc := HXMLDoc():new( )
      LOCAL oXmlNode, oXmlSubNode1, oXmlSubNode2, aAttr

      oXmlNode := HXMLNode():New( "ROOT" )
      oXmlNode:SetAttribute( "Title","PropertyGrid" )
      oXmlDoc:add( oXmlNode )

      oXmlSubNode1 := HXMLNode():New( "category" )
      oXmlSubNode1:SetAttribute( "Name","Category 1" )
      oXmlSubNode1:SetAttribute( "Value","" )
      oXmlNode:add( oXmlSubNode1  )

      aAttr := { {"Name",'Property 1'},{"Value",'Value for Property 1 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2'},{"Value",'Value for Property 2 (Disabled)'},{"cData",""},{"disabled", "true"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 3'},{"Value",'Value for Property 3 (Changed)'},{"cData",""},{"disabled", "false"},{"changed", "true"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )

      oXmlSubNode1  := HXMLNode():New( "category" )
      oXmlSubNode1:SetAttribute( "Name","Category 2" )
      oXmlSubNode1:SetAttribute( "Value","" )
      oXmlNode:add( oXmlSubNode1 )

      aAttr := { {"Name",'Property 1'},{"Value",'Value for Property 1 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2'},{"Value",'Value for Property 2 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )

      oXmlSubNode2 := HXMLNode():New( "category" )
      oXmlSubNode2:SetAttribute( "Name","Category 2.1" )
      oXmlSubNode2:SetAttribute( "Value","" )
      oXmlSubNode1:add( oXmlSubNode2 )

      aAttr := { {"Name",'Property 2.1'},{"Value",'Value for Property 2.1 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2.2'},{"Value",'Value for Property 2.2 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2.3'},{"Value",'Value for Property 2.3 (Disabled)'},{"cData",""},{"disabled", "true"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2.4'},{"Value",'Value for Property 2.4 (Changed)'},{"cData",""},{"disabled", "false"},{"changed", "true"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2.5'},{"Value",'Value for Property 2.5 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2.6'},{"Value",'Value for Property 2.6 (Changed)'},{"cData",""},{"disabled", "false"},{"changed", "true"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2.7'},{"Value",'Value for Property 2.7 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2.8'},{"Value",'Value for Property 2.8 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )

      aAttr := { {"Name",'Property 3'},{"Value",'Value for Property 3 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )

      oXmlSubNode1 := HXMLNode():New( "category" )
      oXmlSubNode1:SetAttribute("Name", "Category 3" )
      oXmlSubNode1:SetAttribute( "Value","" )
      oXmlNode:add( oXmlSubNode1 )

      aAttr := { {"Name",'Property 1'},{"Value",'Value for Property 1 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 2'},{"Value",'Value for Property 2 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 3'},{"Value",'Value for Property 3 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode1:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )

      oXmlSubNode2 := HXMLNode():New( "category" )
      oXmlSubNode2:SetAttribute("Name", "Category 3.1" )
      oXmlSubNode2:SetAttribute( "Value","" )
      oXmlSubNode1:add( oXmlSubNode2 )

      aAttr := { {"Name",'Property 3.1'},{"Value",'Value for Property 3.1 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )
      aAttr := { {"Name",'Property 3.2'},{"Value",'Value for Property 3.2 '},{"cData",""},{"disabled", "false"},{"changed", "false"}}
      oXmlSubNode2:add( HXMLNode():New( "string", HBXML_TYPE_SINGLE, aAttr ) )

      oXmlSubNode1 := HXMLNode():New( "category" )
      oXmlSubNode1:SetAttribute( "Name","Category 4" )
      oXmlSubNode1:SetAttribute( "Value","" )
      oXmlNode:add( oXmlSubNode1 )

      oXmlDoc:Save( "PropGrid.xml")

RETURN Nil

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
FUNCTION SetPGValue(PGname,cForm,nId)
*------------------------------------------------------------------------------*
LOCAL cValue :='TEST'

   SET PROPERTYITEM &PGName OF  &cForm VALUE cValue ID nId

RETURN nil

*------------------------------------------------------------------------------*
FUNCTION AddItemPG(PGname,cForm,lCat)
*------------------------------------------------------------------------------*
LOCAL nId :=333

IF lCat
   ADD PROPERTYITEM &PGname OF &cForm ;
            CATEGORY "Category 2" ;
            ITEMTYPE "string" ;
            NAMEITEM "New Item";
            VALUE "New Value" ;
            ID nId
else
   ADD PROPERTYITEM &PGname OF &cForm ;
            ITEMTYPE "string" ;
            NAMEITEM "New Item";
            VALUE "New Value" ;
            ID nId
endif

RETURN Nil



#ifdef __XHARBOUR__
  #include <fileread.prg>
#endif
