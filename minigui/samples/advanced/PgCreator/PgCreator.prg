/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Property Grid Creator Ver 1.1
 * (c) 2008-2010 Janusz Pora <januszpora@onet.eu>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_propgrid.ch"
#include "i_xml.ch"

//#define CLR_DEFAULT   0xff000000
#define MsgInfo( c )   MsgInfo( c, , , .f. )

#define CTG_MAIN     1000
#define CTG_HEADER   1010
#define CTG_ITEMPAR  1020
#define CTG_INITCAT  1030
#define CTG_ITEM     1100

#define ITM_HEADER      100
#define ITM_HDNAME      110
#define ITM_HDVALUE     120
#define ITM_PGPOS       130
#define ITM_PGSIZE      140
#define ITM_PGINDENT    150
#define ITM_PGDATAW     160
#define ITM_PGITEMH     170
#define ITM_PGFONTCLR   180
#define ITM_PGBACKCLR   190
#define ITM_PGFONT      200
#define ITM_PGINITCTG   210
#define ITM_PGINFO      220
#define ITM_PGSINEXP    230
#define ITM_PGEXP       240

#define ITM_CTG         500
#define ITM_TYPE        510
#define ITM_NAME        520
#define ITM_VALUE       530
#define ITM_DATA        540
#define ITM_DISAB       550
#define ITM_DISED       560
#define ITM_ID          570
#define ITM_INFO        580
#define ITM_VAR         590

MEMVAR clCategory, nDefId, FormTest, PG_test, Form1, PGrid1

*-----------------------------------------------------------------------------*
Function main()
*-----------------------------------------------------------------------------*
   PUBLIC clCategory := 'Init Category (ROOT)', nDefId := 100
   PUBLIC FormTest := "FormTest" , PG_test := "PG_Test"
   PUBLIC Form1 := "Form_1" , PGrid1 := "PropGrid_1"

   DECLARE WINDOW FormTest
   DECLARE WINDOW Form1

   DEFINE WINDOW Form_1 ;
      AT 100,50 ;
      WIDTH 750 ;
      HEIGHT 510 ;
      TITLE 'Property Grid Creator Ver 1.1' ;
      ICON "PgGen.ico" ;
      MAIN ;
      NOMAXIMIZE NOSIZE

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM 'Exit' ACTION ThisWindow.Release
         END POPUP
         POPUP '&Test'
            ITEM 'Get Value selected Item' ACTION DisplPGValue("PropGrid_1","Form_1",0)
            ITEM 'Get Property Info selected Item' ACTION DisplPGInfo("PropGrid_1","Form_1",0)
         END POPUP
          POPUP '&Info'
            ITEM 'About...' ACTION About()
         END POPUP

      END MENU

      @ 20,30 BUTTON btn_20;
         CAPTION "Create Property";
         ACTION CreateTestPG("Form_1" ,"PropGrid_1",FormTest, PG_Test) ;
         WIDTH 120 HEIGHT 24

      @ 20,200 BUTTON btn_21;
         CAPTION "Add Item";
         ACTION AddItemPG( "Form_1", "PropGrid_1", FormTest, PG_Test) ;
         WIDTH 120 HEIGHT 24

      DEFINE PROPGRID PropGrid_1   ;
         AT 55,10   WIDTH 350 HEIGHT 380 ;
         HEADER " Name","Value";
         FONTCOLOR {0,0,0} INDENT  10  DATAWIDTH 180;
         BACKCOLOR {240,240,240};
         ON CHANGEVALUE  ChdItem("PropGrid_1","Form_1");
         ITEMINFO SINGLEEXPAND

      DEFINE CATEGORY 'Main PG Property' ID CTG_MAIN //INFO "To create a Property Grid, fill Property Items with correct data and press button Create Property"
         DEFINE CATEGORY "Header" ID CTG_HEADER
            PROPERTYITEM CHECK  "Header"       VALUE "Excluded"  ITEMDATA "Excluded;Included" ID ITM_HEADER INFO "Check to include Header to Property Grid"
            PROPERTYITEM STRING "Header Name"  VALUE "Property Name" DISABLED ID ITM_HDNAME INFO "Insert Header Name"
            PROPERTYITEM STRING "Header Value" VALUE "Value"   DISABLED ID ITM_HDVALUE INFO "Insert Header Name for Value"
         END CATEGORY
         PROPERTYITEM SIZE   "Control Position" VALUE "(50,40)"  ITEMDATA "Row; Col"  ID ITM_PGPOS INFO "Insert Positon for Property Control"
         PROPERTYITEM SIZE   "Control Size"     VALUE "(300,400)"  ITEMDATA "Width; Height"  ID ITM_PGSIZE INFO "Insert Size for Property Control"
         DEFINE CATEGORY "Item" ID CTG_ITEMPAR
            PROPERTYITEM INTEGER "Indent"         VALUE 20  ID ITM_PGINDENT INFO "Insert value for Indent"
            PROPERTYITEM INTEGER "Width of Data"  VALUE 150  ID ITM_PGDATAW INFO "Insert column size for Value"
            PROPERTYITEM INTEGER "Height of Item" VALUE 20  ID ITM_PGITEMH INFO "Insert height of item"
            PROPERTYITEM CHECK  "Item Expand"     VALUE "Included"  ITEMDATA "Excluded;Included" ID ITM_PGEXP INFO "Check this option to expand a Category at start"
            PROPERTYITEM CHECK  "Single Expand"   VALUE "Excluded"  ITEMDATA "Excluded;Included" ID ITM_PGSINEXP INFO "Check this option to expand only one Category"
         END CATEGORY
         PROPERTYITEM FONT   "Font"      VALUE "Arial, 8, Italic"  ITEMDATA "Arial; 8; false; true; false; false"  ID ITM_PGFONT INFO "Basic font for application"
         PROPERTYITEM COLOR  "Fontcolor" VALUE  BLACK  ITEMDATA '0;0;0'  ID ITM_PGFONTCLR INFO "Color for Font, choose from palette of colours"
         PROPERTYITEM COLOR  "Backcolor" VALUE  {240,240,240}  ITEMDATA '208;205;188' ID ITM_PGBACKCLR INFO "Colour for background, choose from palette of colours"
         PROPERTYITEM CHECK  'Info'      VALUE 'Hide'  ITEMDATA 'Hide;Show' ID ITM_PGINFO INFO "Check this option to show window with Info"
      END CATEGORY
      DEFINE CATEGORY "INIT Category" ID CTG_INITCAT
         PROPERTYITEM STRING 'Init Category (ROOT)'      VALUE "Name of Init Category" ID ITM_PGINITCTG INFO "Insert name of Init Category to create Property Grid"
      END CATEGORY

      DEFINE CATEGORY "Item Property"  ID CTG_ITEM
         PROPERTYITEM LIST   "CATEGORY"  VALUE "Name of Init Category" ITEMDATA  clCategory ID ITM_CTG INFO "Insert a parent Category for Item"
         PROPERTYITEM ENUM   "Type"      VALUE "string"  ITEMDATA  "category;string;numeric;double;syscolor;color;logic;date;font;array;enum;flag;sysinfo;image;check;size;file;folder;list;userfun" INFO "Select type of Item" ID ITM_TYPE
         PROPERTYITEM STRING "Name"      VALUE ""        ID ITM_NAME  INFO "Insert a Name for Item"
         PROPERTYITEM USERFUN "Value"    VALUE ""        ITEMDATA "{|x| DefFunData(PGrid1,Form1,.f.,x)}" ID ITM_VALUE INFO "Insert a Value for Item, use appropriate function mit help of button."
         PROPERTYITEM USERFUN "Data"     VALUE ""        ITEMDATA "{|x| DefFunData(PGrid1,Form1,.t.,x)}" ID ITM_DATA  INFO "Insert adequate data to type of Item, use appropriate function mit help of button."
         PROPERTYITEM CHECK  "Disabled"  VALUE "Enabled" ITEMDATA "Enabled;Disabled" ID ITM_DISAB INFO "Check to disable this Item"
         PROPERTYITEM CHECK  "Disable Edit"  VALUE "Disabled" ITEMDATA "Enabled;Disabled" ID ITM_DISED INFO "Check to disable this Item"
         PROPERTYITEM INTEGER 'Id'       VALUE nDefId    ID ITM_ID  INFO "Automatically or manually invent new ID Numbers for new Item"
         PROPERTYITEM STRING 'Info'      VALUE  ""       ID ITM_INFO  INFO "Inser a Information for Item"
         PROPERTYITEM STRING 'Varable Name ' VALUE "" ID ITM_VAR INFO "Inser a Variable Name for Value to saved in file *.mem"
      END CATEGORY

   END PROPGRID

   ExpandCategPG("Form_1","PropGrid_1",'Main Property',1)

   END WINDOW

   Form_1.Btn_21.Enabled :=.f.

   ACTIVATE WINDOW Form_1

Return Nil

*------------------------------------------------------------------------------*
FUNCTION ChdItem(PGname,cForm)
*------------------------------------------------------------------------------*
   LOCAL aValue, nId, xValue, cValue, ItType

   GET INFO PROPERTYITEM &PGName OF  &cForm TO  aValue
   IF valtype(aValue)=='A'
      nId := aValue[PGI_ID]
      xValue := ValueTran(aValue[PGI_NAME], aValue[PGI_TYPE], aValue[PGI_VALUE])
      DO CASE
      CASE nId == ITM_HEADER
         IF xValue
            ENABLE PROPERTYITEM &PGName OF  &cForm ID ITM_HDNAME
            ENABLE PROPERTYITEM &PGName OF  &cForm ID ITM_HDVALUE
         ELSE
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_HDNAME
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_HDVALUE
         endif
      CASE nId == ITM_PGINITCTG
         xValue := aValue[PGI_VALUE ]
         IF !Empty(xValue)
            SET PROPERTYITEM &PGName OF &cForm   ;
               VALUE xValue ITEMDATA xValue ID ITM_CTG
            Form_1.Btn_20.Enabled :=.t.
         endif
      //Value for Item
      CASE nId == ITM_TYPE
         ItType := PgIdentType(xValue)

         ENABLE PROPERTYITEM &PGName OF  &cForm ID ITM_VALUE
         ENABLE PROPERTYITEM &PGName OF  &cForm ID ITM_DATA
         ENABLE PROPERTYITEM &PGName OF  &cForm ID ITM_DISAB
         ENABLE PROPERTYITEM &PGName OF  &cForm ID ITM_VAR
         SET PROPERTYITEM &PGName OF &cForm  VALUE "" ID ITM_NAME
         REDRAW PROPERTYITEM &PGName OF &cForm  ID ITM_NAME
         SET PROPERTYITEM &PGName OF &cForm  VALUE "" ID ITM_VALUE
         REDRAW PROPERTYITEM &PGName OF &cForm  ID ITM_VALUE
         SET PROPERTYITEM &PGName OF &cForm  VALUE "" ID ITM_DATA
         REDRAW PROPERTYITEM &PGName OF &cForm  ID ITM_DATA
         SET PROPERTYITEM &PGName OF &cForm  VALUE "" ID ITM_INFO
         REDRAW PROPERTYITEM &PGName OF &cForm  ID ITM_INFO
         SET PROPERTYITEM &PGName OF &cForm  VALUE "" ID ITM_VAR
         REDRAW PROPERTYITEM &PGName OF &cForm  ID ITM_VAR
         SET PROPERTYITEM &PGName OF &cForm  VALUE "Enabled" ID ITM_DISAB
         REDRAW PROPERTYITEM &PGName OF &cForm  ID ITM_DISAB

         DO CASE
         CASE ItType == PG_CATEG
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_VALUE
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_DATA
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_DISAB
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_VAR
         CASE ItType == PG_STRING .or. ItType == PG_INTEGER ;
            .or. ItType == PG_DOUBLE .or. ItType == PG_LOGIC .or. ItType == PG_DATE ;
            .or. ItType == PG_SYSCOLOR
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_DATA
         CASE ItType == PG_SIZE
            DISABLE PROPERTYITEM &PGName OF  &cForm ID ITM_VALUE
         ENDCASE
      CASE nId == ITM_NAME
         GET PROPERTYITEM &PGName OF  &cForm ID ITM_NAME TO  cValue
         IF !Empty(cValue)
            Form_1.Btn_21.Enabled :=.t.
         ENDIF
      ENDCASE
   endif
RETURN nil

*-----------------------------------------------------------------------------*
Function CreateTestPG(FormName,ControlName,FormTest, PG_Test)
*-----------------------------------------------------------------------------*
   LOCAL lHD, cHdName, cHdValue, xPos, yPos, xSize, ySize, aFontColor, aBackColor, nIndent, nDataWidth
   LOCAL cInitCateg, aFont, nItemHeight, lPgExp, lPgSinExp, lInfo

   GET PROPERTYITEM &ControlName OF &FormName ID ITM_HDNAME TO cHdName
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_HDVALUE TO cHdValue
   GET PROPERTYITEM &ControlName OF &FormName SUBITEM 1 ID ITM_PGPOS TO xPos
   GET PROPERTYITEM &ControlName OF &FormName SUBITEM 2 ID ITM_PGPOS TO yPos
   GET PROPERTYITEM &ControlName OF &FormName SUBITEM 1 ID ITM_PGSIZE TO xSize
   GET PROPERTYITEM &ControlName OF &FormName SUBITEM 2 ID ITM_PGSIZE TO ySize
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGINDENT TO nIndent
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGDATAW TO nDataWidth
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGITEMH TO nItemHeight
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGEXP TO lPgExp
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGSINEXP TO lPgSinExp
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGINFO TO lInfo


   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGFONTCLR TO aFontColor
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGBACKCLR TO aBackColor
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGFONT TO aFont

   GET PROPERTYITEM &ControlName OF &FormName ID ITM_PGINITCTG TO cInitCateg


   Form_1.Btn_20.Enabled :=.f.

   DEFINE WINDOW &FormTest ;
      AT 130,130 + xSize +xPos;
      WIDTH xSize +xPos +200;
      HEIGHT ySize +100 ;
      TITLE 'PropertyGrid Test' ;
      ON RELEASE ReleaseTest() ;
      CHILD

      _DefinePropGrid ( PG_Test, FormTest, yPos,xPos , xSize, ySize, , , .f., , ;
         aFont[1], aFont[2], , , ,.f., , , aFont[3], aFont[4], aFont[6], aFont[7],;
         lPgExp, aBackColor, aFontColor, nIndent, nItemHeight, nDataWidth, 0, .f.,;
         lInfo, , , {cHdName,cHdValue}, lPgExp )

      DEFINE CATEGORY cInitCateg ID nDefId

      END CATEGORY
      nDefId += 10

      SET PROPERTYITEM &ControlName OF &FormName  ;
               VALUE nDefId ID ITM_ID

   END PROPGRID

      @ 10,380 FRAME Frame_1 WIDTH 140 HEIGHT 120 CAPTION "Property from:"
      @ 30,400 BUTTON btn_1;
            CAPTION "File Txt";
            ACTION LoadPropertyFile(FormTest,PG_Test,"PgTest.txt",FormName, ControlName) ;
            WIDTH 100 HEIGHT 24

      @ 60,400 BUTTON btn_2;
            CAPTION "File Xml";
            ACTION LoadPropertyFile(FormTest,PG_Test,"PgTest.xml",FormName, ControlName) ;
            WIDTH 100 HEIGHT 24

      @ 90,400 BUTTON btn_3;
            CAPTION "File Ini";
            ACTION LoadPropertyFile(FormTest,PG_Test,"PgTest.ini",FormName, ControlName);
            WIDTH 100 HEIGHT 24

      @ 160,380 FRAME Frame_2 WIDTH 140 HEIGHT 130 CAPTION "Property save to:"

      @ 180,400 BUTTON btn_5;
            CAPTION "File Txt";
            ACTION SaveToFile(FormTest,PG_Test,"PgTest.txt",2) ;
            WIDTH 100 HEIGHT 24

      @ 215,400 BUTTON btn_6;
            CAPTION "File Xml";
            ACTION SaveToFile(FormTest,PG_Test,"PgTest.xml",1) ;
            WIDTH 100 HEIGHT 24

      @ 250,400 BUTTON btn_7;
            CAPTION "File Ini";
            ACTION SaveToFile(FormTest,PG_Test,"PgTest.ini",3) ;
            WIDTH 100 HEIGHT 24

   END WINDOW

   ACTIVATE WINDOW &FormTest

Return nil

*-----------------------------------------------------------------------------*
FUNCTION ReleaseTest()
*-----------------------------------------------------------------------------*

   Form_1.Btn_20.Enabled :=.t.
   Form_1.Btn_21.Enabled :=.f.

RETURN Nil

*-----------------------------------------------------------------------------*
Function AddItemPG( FormName, ControlName, FormTest, PG_Test)
*-----------------------------------------------------------------------------*
LOCAL cCateg, cType,cName, cValue, cData, lDisab, lDisEd,;
         nId, cInfo, cVarName, aValue,aData

   GET PROPERTYITEM &ControlName OF &FormName ID ITM_CTG TO cCateg
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_TYPE TO cType
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_NAME TO cName
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_VALUE TO cValue
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_DATA TO cData
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_DISAB TO lDisab
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_DISAB TO lDisEd
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_ID TO nId
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_INFO TO cInfo
   GET PROPERTYITEM &ControlName OF &FormName ID ITM_VAR TO cVarName

   IF cType == "category"

      ADD CATEGORY  &PG_Test OF &FormTest ;
         TO CATEGORY cCateg ;
         NAMECATEGORY cName ;
         ID nId ;
         INFO cInfo

      GET INFO PROPERTYITEM &PG_Test OF &FormTest ID nId TO  aValue

      IF ValType(aValue) =='A'
         IF aValue[PGI_NAME] == cName
            GET INFO PROPERTYITEM &ControlName OF &FormName ID ITM_CTG TO  aValue
            aData :=PgIdentData(aValue[PGI_VALUE])
            IF AScan(aData,cName)==0
               SET PROPERTYITEM &ControlName OF &FormName ;
                  VALUE cName ;
                  ITEMDATA aValue[PGI_VALUE]+';'+cName ;
                  ID ITM_CTG
            endif

            SET PROPERTYITEM &ControlName OF &FormName ;
               VALUE nId +10 ;
               ID ITM_ID
         endif
      endif

   else

      _AddPropertyItem  (PG_Test , FormTest, cCateg, cType, cName, cValue, cData, lDisab, lDisEd, nId ,cInfo, cVarName, , 1 )

      SET PROPERTYITEM &ControlName OF &FormName VALUE nId +10 ID ITM_ID

   endif

Return nil

*-----------------------------------------------------------------------------*
FUNCTION DefFunData( PGname, cForm, lData, cData )
*-----------------------------------------------------------------------------*
   LOCAL cType, ItType, cInputPrompt, cDataNew, xData
   DEFAULT cData := "Default Data"
   GET PROPERTYITEM &PGName OF &cForm ID ITM_TYPE TO  cType
   ItType := PgIdentType(cType)

   cInputPrompt := IF(lData, "Insert Data for Item", "Insert Value for Item" )
   IF ItType  == PG_CATEG
      cData := InputPgData ("Insert a new Category" , "Item Type: "+cType , cData, ItType )  // [, nTimeout][, lMultiLine ] )
   ELSE
      IF lData
         GET PROPERTYITEM &PGName OF  &cForm ID ITM_VALUE TO  xData
         IF Empty(cData)
            IF ItType == PG_IMAGE
               cData := '*.bmp'
            elseif ItType == PG_FILE
               cData := '*.txt, *.*'
            else
               cData := xData
            endif
         ENDIF
      else
          GET PROPERTYITEM &PGName OF  &cForm ID ITM_DATA TO  xData
         IF Empty(cData)
            IF ItType == PG_SIZE
               cData := "(  )"
            else
               cData := xData
            endif
         ENDIF
      endif

      IF ItType == PG_ARRAY  .or.( ItType == PG_ENUM .and. lData) .or. (ItType == PG_IMAGE .and. lData) .or. ;
         ( ItType == PG_FLAG .and. lData) .or. ( ItType == PG_LIST .and. lData ).or. ( ItType == PG_FILE .and. lData ) .or.;
         ( ItType == PG_SIZE .and. lData)
         IF lData
            cData := CHARREPL (';', cData, ',')
         endif
         cDataNew :=ArrayDlg( cData, cForm  )
         cData := IF(!Empty( cDataNew ),cdataNew, cData )
         IF lData
            cData := CHARREPL (',', cData, ';')
         endif
         IF ItType == PG_SIZE .and. !Empty(cData)
            ENABLE PROPERTYITEM &PGName OF  &cForm ID ITM_VALUE
         endif
      ELSE

         cData :=InputPgData ( cInputPrompt , "Item Type: "+cType , cData, xData, ItType,lData )
      endif
   endif

RETURN cData

*-----------------------------------------------------------------------------*
Function InputPgData ( cInputPrompt , cDialogCaption , cDefValue, cDefData, ItType,lData   )
*-----------------------------------------------------------------------------*
   LOCAL RetVal := '', bRetVal, aData, aFltr
   LOCAL n, BmpW, BmpH, aColorName, aSysColor, nPos

   DEFAULT cInputPrompt   TO ""
   DEFAULT cDialogCaption   TO ""
   DEFAULT cDefValue   TO ""


      DEFINE WINDOW _InputPG        ;
         AT 0,0                      ;
         WIDTH 250                   ;
         HEIGHT 115 +  GetTitleHeight() ;
         TITLE cDialogCaption        ;
         MODAL                       ;
         NOSIZE                      ;
         FONT 'Arial'                ;
         SIZE 10

         @ 07,10 LABEL _Label        ;
            VALUE cInputPrompt       ;
            WIDTH 280

         bRetVal := {|| _InputPG._DataBox.Value }
         ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T. , _InputPG.Release )

         DO CASE
         CASE ItType == PG_CATEG .or. ItType == PG_STRING .or. ItType == PG_DEFAULT .or. ;
            ItType == PG_INTEGER .or. ItType == PG_DOUBLE

            IF ItType == PG_INTEGER .or. ItType == PG_DOUBLE
               bRetVal := {|| AllTrim(Str(_InputPG._DataBox.Value ))}

               @ 30,10 TEXTBOX _DataBox VALUE cDefValue   ;
                  HEIGHT 26  WIDTH 220  NUMERIC    ;
                  ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal) , _InputPG.Release )

            else
               @ 30,10 TEXTBOX _DataBox  VALUE cDefValue   ;
                  HEIGHT 26  WIDTH 220    ;
                  ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal), _InputPG.Release )
            endif

         CASE ItType == PG_LOGIC

            bRetVal := {|| IF(_InputPG._DataBox.Value ==1,"true","false") }

            @ 30 ,10 RADIOGROUP _DataBox  OPTIONS {"true","false"};
               VALUE 1 HORIZONTAL ;
               ON CHANGE  (  RetVal := Eval(bRetVal) )

         CASE ItType == PG_FONT

            IF lData
               IF Empty(cDefValue)
                  cDefValue := "Arial;8;false;false;false"
               ELSE
                  cDefValue := CHARREPL (';', cDefValue, ',')
                  aData := PgIdentData(cDefValue,PG_FONT,,',')
                  cDefValue:= AttrTran(aData,'A')
               ENDIF
            else
               IF Empty(cDefValue)
                  cDefValue := "Arial,8"
               ELSE
                  aData := PgIdentData(cDefValue,PG_FONT,,',')
                  cDefValue := aFont2Str(aData)
               ENDIF
            ENDIF

            @ 30 ,10  BTNTEXTBOX _DataBox ;
               HEIGHT 26  WIDTH 220   ;
               VALUE cDefValue ;
               ACTION {|| _InputPG._DataBox.Value := InsertFont( cDefValue ,lData) }

         CASE ItType == PG_COLOR

            IF lData
               IF Empty(cDefValue)
                  cDefValue := "0;0;0"
               ELSE
                  cDefValue := CHARREPL (';', cDefValue, ',')
                  aData := PgIdentData(cDefValue,PG_COLOR,,',')
                  cDefValue:= AttrTran(aData,'A')
               ENDIF
            else
               IF Empty(cDefValue)
                  cDefValue := "{0,0,0)"
               ELSE
                  aData := PgIdentData(cDefValue,PG_COLOR,,',')
                  cDefValue := aCol2Str(aData)
               ENDIF
            ENDIF
            @ 30 ,10  BTNTEXTBOX _DataBox ;
               HEIGHT 26 WIDTH 220            ;
               VALUE cDefValue ;
               ACTION {|| _InputPG._DataBox.Value := InsertColor( cDefValue, lData) }

         CASE ItType == PG_SYSCOLOR

            BmpW := 28
            BmpH := 20
            aColorName := {}
            bRetVal := {|| nPos:= _InputPG._DataBox.Value, IF(nPos > 0, aColorName[nPos],cDefValue)  }
            aSysColor := PgIdentColor(1)
            AEval(aSysColor, {|x| AAdd(aColorName, x[2]) })
            nPos := IF(Empty(cDefValue),1,AScan(aColorName, cDefValue))

            DEFINE IMAGELIST Imagelst_1 ;
               BUTTONSIZE BmpW, BmpH ;
               IMAGE {}

            FOR n:=1 TO Len(aSysColor)
               HMG_SetSysColorBtm(aSysColor[n,1], BmpW, BmpH)
               HMG_SetSysColorBtm(aSysColor[n,1], BmpW, BmpH)
               HMG_SetSysColorBtm(aSysColor[n,1], BmpW, BmpH)
            NEXT


            @ 30 ,10  COMBOBOXEX  _DataBox ;
               HEIGHT 100 WIDTH 220 ;
               ITEMS aColorName ;
               VALUE nPos ;
               ON ENTER Eval( bRetVal) ;
               IMAGELIST "Imagelst_1"   ;

         CASE ItType == PG_ENUM .or. ItType == PG_LIST

            @ 30,10 TEXTBOX _DataBox  VALUE cDefValue   ;
               HEIGHT 26  WIDTH 220    ;
               ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal), _InputPG.Release )

         CASE ItType == PG_DATE

            bRetVal := {|| DToC( _InputPG._DataBox.Value)  }
            cDefValue := IF(Empty(cDefValue),CToD(""), CToD(cDefValue))

            @ 30,10 DATEPICKE _DataBox  VALUE cDefValue   ;
               WIDTH 220    ;
               ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal), _InputPG.Release )

         CASE ItType == PG_IMAGE

               aFltr := PgIdentData( cDefData,PG_IMAGE )
               @ 30 ,10  BTNTEXTBOX _DataBox ;
                  HEIGHT 26 WIDTH 220            ;
                  VALUE cDefValue ;
                  ACTION {|| _InputPG._DataBox.Value := GetFile ( aFltr , "Image File", cDefValue , .f. , .t.)  }

         CASE ItType == PG_SYSINFO

            IF lData
               aData:= {"SYSTEM","USERHOME","USERID", "USERNAME"}
               bRetVal := {|| nPos:= _InputPG._DataBox.Value, IF(nPos > 0, aData[nPos],cDefValue)  }
               nPos := IF(Empty(cDefValue),1,AScan(aData, cDefValue))

               @ 30 ,10  COMBOBOXEX  _DataBox ;
                  HEIGHT 100 WIDTH 220 ;
                  ITEMS aData ;
                  VALUE nPos ;
                  ON ENTER Eval( bRetVal)
            ELSE
               IF cDefData == "USERHOME"
                  cDefValue := IF(cDefValue == "USERHOME","",cDefValue )
                  @ 30 ,10  BTNTEXTBOX _DataBox ;
                     HEIGHT 26 WIDTH 220            ;
                     VALUE cDefValue ;
                     ACTION {|| _InputPG._DataBox.Value :=GetMyDocumentsFolder ( ) }
               ELSE
                  bRetVal := {|| ""  }
                  @ 25 ,10  Label _DataBox ;
                     HEIGHT 33 WIDTH 220  ;
                     VALUE "Value for Item Data of type"+cDefData+ " does not be required" ;
                     BOLD FONTCOLOR BLUE
               ENDIF
            ENDIF

         CASE ItType == PG_FLAG

            bRetVal := {|| '['+_InputPG._DataBox.Value+']' }
            @ 30,10 TEXTBOX _DataBox  VALUE cDefValue   ;
               HEIGHT 26  WIDTH 220    ;
               ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal), _InputPG.Release )

         CASE ItType == PG_CHECK

            IF lData
               IF Empty(cDefValue) .or. cDefValue == cDefData
                  cDefValue := "False;True"
               ELSE
                  cDefValue := CHARREPL (',', cDefValue, ';')
               ENDIF
            else
               IF Empty(cDefValue)
                  cDefValue := "False"
               ELSE
                  IF !Empty(cDefData)
                     aData := PgIdentData(cDefData)
                     IF ValType(aData) == 'A'
                        cDefValue := aData[1]
                     ELSE
                        cDefValue := cDefData
                     ENDIF
                  endif
               ENDIF
            ENDIF
            @ 30,10 TEXTBOX _DataBox  VALUE cDefValue   ;
               HEIGHT 26  WIDTH 220    ;
               ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal), _InputPG.Release )

         CASE ItType == PG_SIZE

            @ 30 ,10  BTNTEXTBOX _DataBox ;
               HEIGHT 26 WIDTH 220            ;
               VALUE cDefValue ;
               ACTION {|| _InputPG._DataBox.Value := InsertSize( cDefValue,cDefData )   }

         CASE ItType == PG_FILE

            aFltr := PgIdentData( cDefData,PG_FILE )
            @ 30 ,10  BTNTEXTBOX _DataBox ;
               HEIGHT 26 WIDTH 220            ;
               VALUE cDefValue ;
               ACTION {|| _InputPG._DataBox.Value := GetFile ( aFltr , "File", cDefValue , .f. , .t.)  }

         CASE ItType == PG_FOLDER

            IF lData
               @ 30,10 TEXTBOX _DataBox  VALUE cDefValue   ;
               HEIGHT 26  WIDTH 220    ;
               ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal), _InputPG.Release )

            else
               @ 30 ,10  BTNTEXTBOX _DataBox ;
                  HEIGHT 26 WIDTH 220            ;
                  VALUE cDefValue ;
                  ACTION {|| _InputPG._DataBox.Value := GetFolder( cDefData, cDefValue ) }
            endif

         CASE ItType == PG_USERFUN

            @ 30,10 TEXTBOX _DataBox  VALUE cDefValue   ;
               HEIGHT 26  WIDTH 220    ;
               ON ENTER ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal), _InputPG.Release )

         ENDCASE

         @ 67,20 BUTTON _Ok      ;
            CAPTION _HMG_MESSAGE [6] ;
            ACTION ( _HMG_DialogCancelled := .F. , RetVal := Eval(bRetVal) ,   _InputPG.Release )

         @ 67,130 BUTTON _Cancel  ;
            CAPTION _HMG_MESSAGE [7] ;
            ACTION   ( _HMG_DialogCancelled := .T. , _InputPG.Release )

      END WINDOW

      _InputPG._DataBox.SetFocus

      CENTER WINDOW _InputPG
      ACTIVATE WINDOW _InputPG

Return ( RetVal )

*------------------------------------------------------------------------------*
FUNCTION InsertFont( cValue ,lData)
*------------------------------------------------------------------------------*
   LOCAL adata, aDataNew,cData:=""

   IF lData
      aData := PgIdentData( cValue,PG_FONT)
      aDataNew := GetFont (aData[1,3], Val(aData[2,3]) ,aData[3,3]=="true" , aData[4,3]=="true" , , aData[5,3]=="true" , aData[6,3]=="true" )
   else
      aData := PgIdentData( cValue,PG_FONT,,',')
      aDataNew := GetFont (aData[1], Val(aData[2]) ,aData[3]=="true" , aData[4]=="true" , , aData[5]=="true" , aData[6]=="true" )
   endif
   IF !Empty(aDataNew[1])
      ADel(aDataNew,5)
      ASize(aDataNew,6)
      cData:= AttrTran(aDataNew,'A')
      aData :=PgIdentData(cData,PG_FONT)
      cValue  := aFont2Str(aData)
   ENDIF
RETURN IF(lData,cData,cValue)

*------------------------------------------------------------------------------*
FUNCTION InsertColor( cValue,lData )
*------------------------------------------------------------------------------*
   LOCAL adata, aDataNew,cData

   aData := PgIdentData( cValue,PG_COLOR,,',')
   aDataNew := GetColor (aData)
   IF aDataNew[1] != NIL
      cData:= AttrTran(aDataNew,'A')
      cValue  := aCol2Str(aDataNew)
   endif
RETURN IF(lData,cData,cValue)

*------------------------------------------------------------------------------*
FUNCTION InsertSize( cValue,cData )
*------------------------------------------------------------------------------*
   LOCAL adata, nValueNew, n, cInput

   aData := PgIdentData(cData,PG_SIZE,cValue)
   cValue := ''
   IF Len(aData) > 0
      FOR n := 1 to   Len(aData)
         cValue += IF(n==1,'(',',')
         cInput := "Size for Item: "+aData[n,1]
         nValueNew := InputBox (cInput, "Value for Item type SIZE" , aData[n,2])
         IF IsDigit(nValueNew)
            aData[n,2] := Val(nValueNew)
         ENDIF
         cValue += AllTrim(Str( aData[n,2]))
      NEXT
      cValue += ')'
   endif
RETURN cValue

*--------------------------------------
Function HMG_SetSysColorBtm(Color, BmpWidh, BmpHeight)
*--------------------------------------
LOCAL hImage, hImageLst, nColor
   hImageLst := GetControlHandle ( "imagelst_1" , _HMG_ActiveFormName )
   nColor := GetSysColor ( Color)
   hImage := CreateColorBMP( GetFormHandle (_HMG_ActiveFormName), nColor, BmpWidh, BmpHeight )
   IL_AddMaskedIndirect( hImageLst , hImage , , BmpWidh , BmpHeight , 1 )
RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION GetSystemColor(aColor)
*------------------------------------------------------------------------------*
   LOCAL nPos, cStr, nColorSys

   nPos := Form_1.ComboEx_2.Value
   nColorSys := GetSysColor ( aColor[nPos,1] )
   IF nPos > 0
      cStr := aColor[nPos,2]+ '  { '+ AllTrim( Str(GetRed(nColorSys)))+','+ AllTrim( Str(GetGreen(nColorSys))) +','+ AllTrim( Str(GetBlue(nColorSys))) +' }'
      MsgInfo(cStr, 'Selected color')
   endif
RETURN nil

*------------------------------------------------------------------------------*
FUNCTION LoadPropertyFile(ParentForm,ControlName,cFile,FormGen, ControlGen)
*------------------------------------------------------------------------------*
LOCAL aProp, k, cExt, aFlt, aCateg, cData, lXml

   cExt:= Lower(SubStr(cFile,RAt('.',cFile)+1))
   DO case
   CASE cExt == 'xml'
      aFlt := {{'File *.xml','*.xml'}}
   CASE cExt == 'txt'
      aFlt := {{'Text File ','*.txt'}}
   CASE cExt == 'ini'
      aFlt := {{'Ini File ','*.ini'}}
   ENDCASE
   cFile := GetFile ( aFlt , 'Store File Property Grid' ,cFile , .f. , .f. )
   if Empty(cFile)
        Return .f.
   endif
   IF File(cFile)
      IF Lower(SubStr(cFile,RAt('.',cFile)+1)) == 'xml'
         lXml := .t.
      ENDIF
      IF  !Empty(cFile) .and. File(cFile)
         k := GetControlIndex ( ControlName, ParentForm )
         IF !lXml
            aProp := _LoadProperty(cFile, k)
         endif
         _InitPgArray(aProp, cFile, lXml, k)
         _HMG_aControlCaption   [k] :=  cFile
         _HMG_aControlMiscData1 [k,5] := lXml
         _ChangeBtnState( _HMG_aControlHandles [k], .f., k )
      ENDIF

      aCateg := IdentCateg( ControlName, ParentForm )
      cData := aVal2Str(aCateg)
      SET PROPERTYITEM &ControlGen OF &FormGen VALUE "ROOT" ITEMDATA cData ID ITM_CTG
   ENDIF
RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION ReadTxt(ParentForm,ControlName,cFile)
*------------------------------------------------------------------------------*
   LOCAL aProp,k
   k := GetControlIndex ( ControlName, ParentForm )
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
   LOCAL aType := {"Name      - ",;
                   "Value     - ",;
                   "Data      - ",;
                   "Disabled  - ",;
                   "Changed   - ",;
                   "Item Type - ",;
                   "Item ID   - ",;
                   "Variable  - ",;
                   "Info      - ",;
                   "InitValue - "}
   IF nId==0
      cStr:= "The array info for selected item: "+CRLF+CRLF
   else
      cStr :="The array info for item of ID "+alltrim(Str(nId))+":"+CRLF
   endif
   GET INFO PROPERTYITEM &PGName OF &cForm ID nId TO aValue
   IF valtype(aValue)!='A'
      cStr += " ERROR by read Property Info! "
   ELSE
      FOR n:= 1 TO Len (aValue)
         cStr += aType[n]
         xValue := aValue[n]
         DO CASE
         CASE ValType(xValue) $  "CM";  cStr += xValue+CRLF
         CASE ValType(xValue) == "D" ;  cStr += DToC( xValue )+CRLF
         CASE ValType(xValue) == "N" .and. n==PGI_TYPE;  cStr += PgIdentType( xValue )+CRLF
         CASE ValType(xValue) == "N" .and. n==PGI_ID;  cStr += Str( xValue )+CRLF
         CASE ValType(xValue) == "L" ;  cStr += if(xValue == .t.,'TRUE','FALSE') +CRLF
         OTHERWISE;                     cStr += 'NIL' +CRLF
         ENDCASE
      NEXT
   Endif
   MsgInfo(cStr,"Info" )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION SaveToFile(ParentForm,ControlName,cFile,met)
*------------------------------------------------------------------------------*
LOCAL oXmlDoc, cExt, lSave := .t.
LOCAL aFlt, nH

   cExt:= Lower(SubStr(cFile,RAt('.',cFile)+1))
   DO case
   CASE cExt == 'xml'.or. met == 1
      aFlt := {{'File *.xml','*.xml'}}
   CASE cExt == 'txt' .or. met == 2
      aFlt := {{'Text File ','*.txt'}}
   CASE cExt == 'ini' .or. met == 3
      aFlt := {{'Ini File ','*.ini'}}
   ENDCASE
   cFile := PutFile ( aFlt , 'Store File Property Grid' , , .f. , cFile )
   if Empty(cFile)
        Return .f.
   endif
   IF File(cFile)
      IF !MsgYesNo ( "Overwrite File :"+cFile+" ?" , "Warning" )
         lSave := .f.
      ENDIF
   ENDIF
   IF lSave
      DO case
      CASE cExt == 'xml' .or. met == 1
         oXmlDoc := CreatePropXml(ParentForm,ControlName)
         oXmlDoc:Save( cFile )
         ReadXml(cFile)
      CASE cExt == 'txt' .or. met == 2
         lSave := CreatePropFile(ParentForm,ControlName,cFile)
         ReadTxt(ParentForm,ControlName,cFile)
      CASE cExt == 'ini' .or. met == 3
         lSave := CreateIniFile(ParentForm,ControlName,cFile)
         IF lSave
            IF ( nH := FOPEN(cFile) ) > 0
               MsgInfo(Freadstr(nH,32000))
            ENDIF
            FCLOSE(nH)
         endif
      ENDCASE
   ENDIF
RETURN lSave

*-----------------------------------------------------------------------------*
FUNCTION IdentCateg( ControlName, ParentForm )
*------------------------------------------------------------------------------*
LOCAL hItem, hWndPG, k, cValue,aCateg := {"ROOT"}
   k := GetControlIndex ( ControlName, ParentForm )
   IF k > 0
      hWndPG := _HMG_aControlHandles  [k]
      hItem := PG_GetRoot( hWndPG )
      WHILE hItem != 0
         IF PG_GetItem( hWndPG, hItem, PGI_TYPE) ==  PG_CATEG
            cValue := PG_GETITEM(hWndPG,hItem,PGI_NAME)
            AAdd(aCateg,cValue)
         ENDIF
         hItem := PG_GetNextItem( hWndPG, hItem )
      ENDDO
   ENDIF
RETURN aCateg

*-----------------------------------------------------------------------------*
FUNCTION IdentRootCateg( ControlName, ParentForm )
*------------------------------------------------------------------------------*
LOCAL hItem, hWndPG, k, cValue:=""
   k := GetControlIndex ( ControlName, ParentForm )
   IF k > 0
      hWndPG := _HMG_aControlHandles  [k]
      hItem := PG_GetRoot( hWndPG )
      if hItem != 0
         cValue := PG_GETITEM(hWndPG,hItem,PGI_NAME)
      ENDIF
   ENDIF
RETURN cValue

*-----------------------------------------------------------------------------*
Function About()
*-----------------------------------------------------------------------------*
   IF !IsWindowDefined ( Form_About )
      DEFINE WINDOW Form_About ;
         AT 0,0 ;
         WIDTH 250 HEIGHT 110 ;
         TITLE '';
         TOPMOST NOCAPTION ;

      @ 10 ,10 IMAGE Icon_1;
          PICTURE "PgGen.ico" ;
          WIDTH 50 HEIGHT 50

      @ 5 ,5 FRAME Frame_1;
          WIDTH 235  HEIGHT 90

      @ 10,70 LABEL Label_1 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE 'Property Grid Creator'  ;
         FONT 'Arial' SIZE 11 BOLD //CENTERALIGN

      @ 35,70 LABEL Label_2 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE '(c) 2008 Janusz Pora' ;
         FONT 'Arial' SIZE 9 FONTCOLOR BLUE //CENTERALIGN

      @ 60,70 LABEL Label_3 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE 'HMG Harbour MiniGui' ;
         FONT 'Arial' SIZE 9 //CENTERALIGN

      @ 65,15  BUTTON Btn_splash ;
         CAPTION 'OK' ;
         ACTION  {|| Form_About.Release };
         WIDTH 40 HEIGHT 20 ;
         FONT 'Arial' SIZE 9 Bold

      END WINDOW
      Form_About.Center
      ACTIVATE WINDOW Form_About
   ENDIF
Return Nil


#ifdef __XHARBOUR__
  #include <..\propgrid\fileread.prg>
#endif
