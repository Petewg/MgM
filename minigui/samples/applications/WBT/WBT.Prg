******************************
** WBT - Web Button Tool
** A program to make a simple web buttons
** (r) Roberto Sanchez <jrsancheze@gmail.com>
** Honduras, Central America
******************************
#include <minigui.ch>

#Define True                         .T.
#Define False                        .F.

#Define nInitColumn                  5
#Define nInitRow                     5
#Define nInitWidth                   110
#Define nInitHeight                  35
#Define cInitCaption1                "Sample"
#Define cInitCaption2                ""
#Define cInitCaption3                ""
#Define cInitCaption4                ""
#Define cInitFontName                "MS Sans serif"
#Define nInitFontSize                9
#Define lInitBold                    .F.
#Define lInitItalic                  .F.
#Define lInitUnderline               .F.
#Define lInitStrikeOut               .F.
#Define aInitColor                   {0,0,0}
#Define lInitVertical                .F.
#Define lInitLeftText                .F.
#Define lInitUpperText               .F.
#Define lInitAdjust                  .F.
#Define cInitIcon                    Nil
#Define aInitBackColor               {255,255,255}
#Define lInitFlat                    .F.
#Define lInitNoTransparent           .F.
#Define lInitNoHotLight              .F.
#Define lInitNoXPStyle               .F.

#Define SampleColumnPosition         1
#Define SampleRowPosition            2
#Define SampleWidthPosition          3
#Define SampleHeightPosition         4
#Define SampleCaptionPosition1       5
#Define SampleCaptionPosition2       6
#Define SampleCaptionPosition3       7
#Define SampleCaptionPosition4       8
#Define SampleFontNamePosition       9
#Define SampleFontSizePosition       10
#Define SampleBoldPosition           11
#Define SampleItalicPosition         12
#Define SampleUnderlinePosition      13
#Define SampleStrikeOutPosition      14
#Define SampleColorPosition          15
#Define SampleVerticalPosition       16
#Define SampleLeftTextPosition       17
#Define SampleUpperTextPosition      18
#Define SampleAdjustPosition         19
#Define SampleIconPosition           20
#Define SampleBackColorPosition      21
#Define SampleFlatPosition           22
#Define SampleNoTransparentPosition  23
#Define SampleNoHotLightPosition     24
#Define SampleNoXPStylePosition      25

#Define nInitCharSet                 0

#Define FontNamePosition             1
#Define FontSizePosition             2
#Define FontBoldPosition             3
#Define FontItalicPosition           4
#Define FontColorPosition            5
#Define FontUnderlinePosition        6
#Define FontStrikeOutPosition        7
#Define FontCharsetPosition          8

#Define IconFolderPosition           1
#Define SaveFolderPosition           2

Memvar aBackColor
Memvar cImageType
Memvar aFont
Memvar aSampleButton
Memvar aFolders

******************************
** Main Function
******************************
Procedure Main()
  Public aBackColor    := aInitBackColor
  Public cImageType    := "ICO"
  Public aFont         := Array(8)
  Public aSampleButton := Array(25)
  Public aFolders      := {"C:\",GetMyDocumentsFolder()}

  fInitPublicArrays()
  Set Navigation Extended
  Set Language To English
  Set Multiple Off

  Load Window Form_Wbt
  Load Window Form_SampleButton
  fChildLocation()
  fCreateSampleButton()
  Activate Window Form_SampleButton, Form_Wbt

Return

******************************
** Function to Init public arrays
******************************
Procedure fInitPublicArrays()
  aFont[FontNamePosition]                   := cInitFontName
  aFont[FontSizePosition]                   := nInitFontSize
  aFont[FontBoldPosition]                   := lInitBold
  aFont[FontItalicPosition]                 := lInitItalic
  aFont[FontColorPosition]                  := aInitColor
  aFont[FontUnderlinePosition]              := lInitUnderline
  aFont[FontStrikeOutPosition]              := lInitStrikeOut
  aFont[FontCharsetPosition]                := nInitCharSet

  aSampleButton[SampleColumnPosition]       := nInitColumn
  aSampleButton[SampleRowPosition]          := nInitRow
  aSampleButton[SampleWidthPosition]        := nInitWidth
  aSampleButton[SampleHeightPosition]       := nInitHeight
  aSampleButton[SampleCaptionPosition1]     := cInitCaption1
  aSampleButton[SampleCaptionPosition2]     := cInitCaption2
  aSampleButton[SampleCaptionPosition3]     := cInitCaption3
  aSampleButton[SampleCaptionPosition4]     := cInitCaption4
  aSampleButton[SampleFontNamePosition]     := cInitFontName
  aSampleButton[SampleFontSizePosition]     := nInitFontSize
  aSampleButton[SampleBoldPosition]         := lInitBold
  aSampleButton[SampleItalicPosition]       := lInitItalic
  aSampleButton[SampleUnderlinePosition]    := lInitUnderline
  aSampleButton[SampleStrikeOutPosition]    := lInitStrikeOut
  aSampleButton[SampleColorPosition]        := aInitColor
  aSampleButton[SampleVerticalPosition]     := lInitVertical
  aSampleButton[SampleLeftTextPosition]     := lInitLeftText
  aSampleButton[SampleUpperTextPosition]    := lInitUpperText
  aSampleButton[SampleAdjustPosition]       := lInitAdjust
  aSampleButton[SampleIconPosition]         := cInitIcon
  aSampleButton[SampleBackColorPosition]    := aInitBackColor
  aSampleButton[SampleFlatPosition]         := lInitFlat
  aSampleButton[SampleNoTransparentPosition]:= lInitNoTransparent
  aSampleButton[SampleNoHotLightPosition]   := lInitNoHotLight
  aSampleButton[SampleNoXPStylePosition]    := lInitNoXPStyle
Return

******************************
** Function to update public arrays
******************************
Procedure fUpdateSampleArrays()

  ** Sample Button Array
  aSampleButton[SampleColumnPosition]       := nInitColumn
  aSampleButton[SampleRowPosition]          := nInitRow
  aSampleButton[SampleWidthPosition]        := Form_Wbt.Spinner_Width.Value
  aSampleButton[SampleHeightPosition]       := Form_Wbt.Spinner_Height.Value
  aSampleButton[SampleCaptionPosition1]     := Form_Wbt.TXB_Caption1.Value
  aSampleButton[SampleCaptionPosition2]     := Form_Wbt.TXB_Caption2.Value
  aSampleButton[SampleCaptionPosition3]     := Form_Wbt.TXB_Caption3.Value
  aSampleButton[SampleCaptionPosition4]     := Form_Wbt.TXB_Caption4.Value
  aSampleButton[SampleFontNamePosition]     := aFont[FontNamePosition]
  aSampleButton[SampleFontSizePosition]     := aFont[FontSizePosition]
  aSampleButton[SampleBoldPosition]         := aFont[FontBoldPosition]
  aSampleButton[SampleItalicPosition]       := aFont[FontItalicPosition]
  aSampleButton[SampleUnderlinePosition]    := aFont[FontUnderlinePosition]
  aSampleButton[SampleStrikeOutPosition]    := aFont[FontStrikeOutPosition]
  aSampleButton[SampleColorPosition]        := aFont[FontColorPosition]
  aSampleButton[SampleVerticalPosition]     := Form_Wbt.Check_Vertical.Value
  aSampleButton[SampleLeftTextPosition]     := Form_Wbt.Check_LeftText.Value
  aSampleButton[SampleUpperTextPosition]    := Form_Wbt.Check_UpperText.Value
  aSampleButton[SampleAdjustPosition]       := Form_Wbt.Check_Adjust.Value
  aSampleButton[SampleIconPosition]         := Form_Wbt.TXB_IconFile.Value
  aSampleButton[SampleBackColorPosition]    := aBackColor
  aSampleButton[SampleFlatPosition]         := Form_Wbt.Check_Flat.Value
  aSampleButton[SampleNoTransparentPosition]:= Form_Wbt.Check_Transparent.Value
  aSampleButton[SampleNoHotLightPosition]   := Form_Wbt.Check_HotLight.Value
  aSampleButton[SampleNoXPStylePosition]    := Form_Wbt.Check_XPStyle.Value
Return

******************************
** Function to update Form fields
******************************
Procedure fUpdateFormFields()
  Form_Wbt.Setfocus
  Form_Wbt.Spinner_Width.Value      := aSampleButton[SampleWidthPosition]
  Form_Wbt.Spinner_Height.Value     := aSampleButton[SampleHeightPosition]
  Form_Wbt.TXB_IconFile.Value       := aSampleButton[SampleIconPosition]
  Form_Wbt.Check_Flat.Value         := aSampleButton[SampleFlatPosition]
  Form_Wbt.Check_Transparent.Value  := aSampleButton[SampleNoTransparentPosition]
  Form_Wbt.Check_HotLight.Value     := aSampleButton[SampleNoHotLightPosition]
  Form_Wbt.Check_XPStyle.Value      := aSampleButton[SampleNoXPStylePosition]
  Form_Wbt.Check_Adjust.Value       := aSampleButton[SampleAdjustPosition]

  Form_Wbt.TXB_Caption1.Value       := aSampleButton[SampleCaptionPosition1]
  Form_Wbt.TXB_Caption2.Value       := aSampleButton[SampleCaptionPosition2]
  Form_Wbt.TXB_Caption3.Value       := aSampleButton[SampleCaptionPosition3]
  Form_Wbt.TXB_Caption4.Value       := aSampleButton[SampleCaptionPosition4]
  Form_Wbt.TXB_FontValues.Value     := aFont[FontNamePosition]
  Form_Wbt.Check_Vertical.Value     := aSampleButton[SampleVerticalPosition]
  Form_Wbt.Check_LeftText.Value     := aSampleButton[SampleLeftTextPosition]
  Form_Wbt.Check_UpperText.Value    := aSampleButton[SampleUpperTextPosition]
Return

******************************
** Function to exit application
******************************
Procedure fExit()
  Release Window All
Return

******************************
** Function to create Sample Button
******************************
Procedure fCreateSampleButton()
  Form_SampleButton.Setfocus
  If IsControlDefined(Button_Sample,Form_SampleButton)
    Form_SampleButton.Button_Sample.Release
  Endif

  fInitPublicArrays()

  DEFINE BUTTONEX Button_Sample
    PARENT        Form_SampleButton
    COL           aSampleButton[SampleColumnPosition]
    ROW           aSampleButton[SampleRowPosition]
    WIDTH         aSampleButton[SampleWidthPosition]
    HEIGHT        aSampleButton[SampleHeightPosition]
    CAPTION       aSampleButton[SampleCaptionPosition1]
    FONTNAME      aSampleButton[SampleFontNamePosition]
    FONTSIZE      aSampleButton[SampleFontSizePosition]
    FONTBOLD      aSampleButton[SampleBoldPosition]
    FONTITALIC    aSampleButton[SampleItalicPosition]
    FONTUNDERLINE aSampleButton[SampleUnderlinePosition]
    FONTSTRIKEOUT aSampleButton[SampleStrikeOutPosition]
    FONTCOLOR     aSampleButton[SampleColorPosition]
    VERTICAL      aSampleButton[SampleVerticalPosition]
    LEFTTEXT      aSampleButton[SampleLeftTextPosition]
    UPPERTEXT     aSampleButton[SampleUpperTextPosition]
    ADJUST        aSampleButton[SampleAdjustPosition]
    ICON          aSampleButton[SampleIconPosition]
    BACKCOLOR     aSampleButton[SampleBackColorPosition]
    FLAT          aSampleButton[SampleFlatPosition]
    NOTRANSPARENT aSampleButton[SampleNoTransparentPosition]
    NOHOTLIGHT    aSampleButton[SampleNoHotLightPosition]
    NOXPSTYLE     aSampleButton[SampleNoXPStylePosition]
  END BUTTONEX
  Form_Wbt.Setfocus
  fUpdateFormFields()
Return

******************************
** Function to refresh screen
******************************
Procedure fRefresh()
  Local cSTRCaption:=""

  If IsControlDefined(Button_Sample,Form_SampleButton)
    Form_SampleButton.Button_Sample.Release
  Endif

  fUpdateSampleArrays()
  Form_SampleButton.StatusBar.Visible:=False
  Form_SampleButton.Backcolor:={128,128,128}
  
  If len(aSampleButton[SampleCaptionPosition1])>0
    cSTRCaption:=aSampleButton[SampleCaptionPosition1]
  Endif
  If len(aSampleButton[SampleCaptionPosition2])>0
    cSTRCaption:=cSTRCaption+CRLF+aSampleButton[SampleCaptionPosition2]
  Endif
  If len(aSampleButton[SampleCaptionPosition3])>0
    cSTRCaption:=cSTRCaption+CRLF+aSampleButton[SampleCaptionPosition3]
  Endif
  If len(aSampleButton[SampleCaptionPosition4])>0
    cSTRCaption:=cSTRCaption+CRLF+aSampleButton[SampleCaptionPosition4]
  Endif

  If cImageType="ICO"
   DEFINE BUTTONEX Button_Sample
     PARENT        Form_SampleButton
     COL           aSampleButton[SampleColumnPosition]
     ROW           aSampleButton[SampleRowPosition]
     WIDTH         aSampleButton[SampleWidthPosition]
     HEIGHT        aSampleButton[SampleHeightPosition]
     CAPTION       cSTRCaption
     FONTNAME      aSampleButton[SampleFontNamePosition]
     FONTSIZE      aSampleButton[SampleFontSizePosition]
     FONTBOLD      aSampleButton[SampleBoldPosition]
     FONTITALIC    aSampleButton[SampleItalicPosition]
     FONTUNDERLINE aSampleButton[SampleUnderlinePosition]
     FONTSTRIKEOUT aSampleButton[SampleStrikeOutPosition]
     FONTCOLOR     aSampleButton[SampleColorPosition]
     VERTICAL      aSampleButton[SampleVerticalPosition]
     LEFTTEXT      aSampleButton[SampleLeftTextPosition]
     UPPERTEXT     aSampleButton[SampleUpperTextPosition]
     ADJUST        aSampleButton[SampleAdjustPosition]
     ICON          aSampleButton[SampleIconPosition]
     BACKCOLOR     aSampleButton[SampleBackColorPosition]
     FLAT          aSampleButton[SampleFlatPosition]
     NOTRANSPARENT aSampleButton[SampleNoTransparentPosition]
     NOHOTLIGHT    aSampleButton[SampleNoHotLightPosition]
     NOXPSTYLE     aSampleButton[SampleNoXPStylePosition]
   END BUTTONEX
  Else
   DEFINE BUTTONEX Button_Sample
     PARENT        Form_SampleButton
     COL           aSampleButton[SampleColumnPosition]
     ROW           aSampleButton[SampleRowPosition]
     WIDTH         aSampleButton[SampleWidthPosition]
     HEIGHT        aSampleButton[SampleHeightPosition]
     CAPTION       cSTRCaption
     FONTNAME      aSampleButton[SampleFontNamePosition]
     FONTSIZE      aSampleButton[SampleFontSizePosition]
     FONTBOLD      aSampleButton[SampleBoldPosition]
     FONTITALIC    aSampleButton[SampleItalicPosition]
     FONTUNDERLINE aSampleButton[SampleUnderlinePosition]
     FONTSTRIKEOUT aSampleButton[SampleStrikeOutPosition]
     FONTCOLOR     aSampleButton[SampleColorPosition]
     VERTICAL      aSampleButton[SampleVerticalPosition]
     LEFTTEXT      aSampleButton[SampleLeftTextPosition]
     UPPERTEXT     aSampleButton[SampleUpperTextPosition]
     ADJUST        aSampleButton[SampleAdjustPosition]
     PICTURE       aSampleButton[SampleIconPosition]
     BACKCOLOR     aSampleButton[SampleBackColorPosition]
     FLAT          aSampleButton[SampleFlatPosition]
     NOTRANSPARENT aSampleButton[SampleNoTransparentPosition]
     NOHOTLIGHT    aSampleButton[SampleNoHotLightPosition]
     NOXPSTYLE     aSampleButton[SampleNoXPStylePosition]
   END BUTTONEX
  Endif

  Form_SampleButton.StatusBar.Visible:=True
  Form_Wbt.Spinner_Width.SetFocus
Return

******************************
** Function to save Button
******************************
Procedure fSave()
  Local cFileName
  Local acFilter      := {{"Bitmap","*.bmp"}}
  Local cTitle        := "Save Button"
  Local cIniFolder    := aFolders[SaveFolderPosition]
  Local lNoChangeDir  := False
  Local lSave         := True

  cFileName:=Upper(PutFile(acFilter, cTitle, cIniFolder, lNoChangeDir, "Button.BMP"))

  If Empty(cFileName)
    MsgStop("Button image was not saved","Not saved")
  Else
    If At(".",cFileName)=0
      cFileName:=cFileName+".BMP"
    Endif
    If File(cFileName)
      PlayExclamation()
      If MsgYesNo("File already exists. Do you want to replace with a new file?","File Exist")
        lSave:=True
      Else
        MsgStop("Button image was not saved","Not saved")
        lSave:=False
      Endif
    Endif
    If lSave
      Form_SampleButton.Setfocus
      Form_SampleButton.Button_Sample.SaveAs(cFileName)
      MsgInfo("File was saved","Saved")
    Endif
    aFolders[SaveFolderPosition]:=GetCurrentFolder()
  Endif
Return

******************************
** Function to select button icon
******************************
Procedure fSelectIcon()
  Local acFilter:={{"Windows icons (*.ico)","*.ico"},{"Windows bitmaps (*.bmp)","*.bmp"},{"All Pictures (*.ico;*.bmp)","*.ico;*.bmp"}}
  Local cTitle:="Icon/Bitmap files"
  Local cDefaultPath:=aFolders[IconFolderPosition]
  Local lMultiSelect:=False
  Local lNoChangeDir:=False

  aSampleButton[SampleIconPosition]:=GetFile(acFilter, cTitle, cDefaultPath, lMultiSelect, lNoChangeDir)
  Form_Wbt.TXB_IconFile.Value:=aSampleButton[SampleIconPosition]
  cImageType:=Upper(right(aSampleButton[SampleIconPosition],3))
  If !Empty(aSampleButton[SampleIconPosition])
    aFolders[IconFolderPosition]:=GetCurrentFolder()
  Endif
  fRefresh()
Return

******************************
** Function to select button back color
******************************
Procedure fBackColor()
  Local aBackColor_Old:=aBackColor
  
  aBackColor:=GetColor(aBackColor)

  If Empty(aBackColor[1])
    aBackColor:= aBackColor_Old
  ElseIf IsThemed()
    Form_Wbt.Check_XPStyle.Value:=True
  Endif
  fRefresh()
Return

******************************
** Function to select font name
******************************
Procedure fFontName()
  Local aFont_Old          := Aclone(aFont)
  Local cFontName_Old      := aFont[FontNamePosition]
  Local nFontSize_Old      := aFont[FontSizePosition]
  Local lFontBold_Old      := aFont[FontBoldPosition]
  Local lFontItalic_Old    := aFont[FontItalicPosition]
  Local aFontColor_Old     := aFont[FontColorPosition]
  Local lFontUnderline_Old := aFont[FontUnderlinePosition]
  Local lFontStrikeOut_Old := aFont[FontStrikeOutPosition]
  Local nCharSet_Old       := aFont[FontCharsetPosition]

  aFont:= GetFont(cFontName_Old,nFontSize_Old,lFontBold_Old,lFontItalic_Old,aFontColor_Old,lFontUnderline_Old,lFontStrikeOut_Old,nCharSet_Old)

  If !Empty(aFont[FontNamePosition])
    Form_Wbt.TXB_FontValues.Value   := aFont[FontNamePosition]
    fUpdateSampleArrays()
  Else
    Form_Wbt.TXB_FontValues.Value   := aFont_Old[FontNamePosition]
    Acopy(aFont_Old,aFont)
  Endif
  fRefresh()
Return

******************************
** Function to put the location for the child form
******************************
Procedure fChildLocation()
  Local nColumn := Form_Wbt.Col
  Local nRow    := Form_Wbt.Row
  Local nHeight := Form_Wbt.Height
   
  Form_SampleButton.Col := nColumn
  Form_SampleButton.Row := nRow + nHeight + 1
Return

******************************
** Function about
******************************
Procedure fAbout()
  Load     Window Form_About
  Center   Window Form_About
  Form_About.Label_HBVersion.Value:=Version()
  Form_About.Label_MGVersion.Value:=MiniGuiVersion()
  Activate Window Form_About
Return
