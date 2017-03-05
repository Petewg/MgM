/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Author: Christian T. Kurowski <xharbour@wp.pl>
 *
 * (PL)
 *
 * Translators:
 *   Adam Trub³ajewicz (EN)
 *   Alexey L. Gustow  (RU)
 *   Arcangelo Molinaro (IT)
 *   Aleksandra Brzozowska, David Chmara (DE)
 *   Lucyna Iwaniec, Lourdes Guijarro (ES)
 *   Lucyna Iwaniec, Ing. Vladimir Precak (CZ)
 *   Lucyna Iwaniec, Ing. Vladimir Precak (SK)
 *   Danail Dikov (BG)
 *
 *
 * see: http://pl.wikipedia.org/wiki/Biorytmy
 *      http://en.wikipedia.org/wiki/Biorhythm
 *      http://ru.wikipedia.org/wiki/%D0%91%D0%B8%D0%BE%D1%80%D0%B8%D1%82%D0%BC
 *      http://de.wikipedia.org/wiki/Biorhythmus
 *      http://es.wikipedia.org/wiki/Biorritmo
 *
*/

#include "minigui.ch"
#include "fileio.ch"


#DEFINE PROGRAM 'MiniGUI Biorhythms'
#DEFINE VERSION '1.00.003'


#DEFINE  N_PHYS   23
#DEFINE  N_EMOT   28
#DEFINE  N_INTE   33
#DEFINE  N_INTU   38

// first day of Gregorian Calendar
#DEFINE  cFDGCd   15
#DEFINE  cFDGCm   10
#DEFINE  cFDGCy   '1582'
#DEFINE  cFDGC    "'"+STR(cFDGCd,2.0)+"."+STR(cFDGCm,2.0)+"."+cFDGCy+"'"

MEMVAR lgLanguage
MEMVAR lgLang
MEMVAR lgBiorhythms
MEMVAR lgAbout
MEMVAR lgVersion
MEMVAR lgTranslators
MEMVAR lgDateOfBirth
MEMVAR lgDateOfCalc
MEMVAR lgCycles
MEMVAR lgShowAll
MEMVAR lgClassicalCycles
MEMVAR lgAdditionalCycle
MEMVAR lgPhysicalCycle
MEMVAR lgEmotionalCycle
MEMVAR lgIntellectualCycle
MEMVAR lgButton_Phys
MEMVAR lgButton_Emot
MEMVAR lgButton_Inte
MEMVAR lgButton_Intu
MEMVAR lgButton_Today
MEMVAR lgButton_Calculate
MEMVAR lgButton_Summary

MEMVAR lgJanuary
MEMVAR lgFebruary
MEMVAR lgMarch
MEMVAR lgApril
MEMVAR lgMay
MEMVAR lgJune
MEMVAR lgJuly
MEMVAR lgAugust
MEMVAR lgSeptember
MEMVAR lgOctober
MEMVAR lgNovember
MEMVAR lgDecember
MEMVAR aMonth

MEMVAR xcDOB_day
MEMVAR xcDOB_month
MEMVAR xcDOB_year

MEMVAR dBegin
MEMVAR dCurrent
MEMVAR nFirstOff

MEMVAR IsFirstRun
MEMVAR IsPlusMinus



PROCEDURE Main()

  SET DATE TO GERMAN
  SET LANGUAGE TO ENGLISH
  SET CODEPAGE TO ENGLISH

  PRIVATE IsFirstRun          :=.T.
  PRIVATE IsPlusMinus         :=.F.

  PRIVATE lgLanguage          :='English'
  PRIVATE lgLang              :='Language'
  PRIVATE lgBiorhythms        :='Biorythms'
  PRIVATE lgAbout             :='About...'
  PRIVATE lgVersion           :='version'
  PRIVATE lgTranslators       :='Translators'
  
  PRIVATE lgDateOfBirth       :='Date of birth'
  PRIVATE lgDateOfCalc        :='Date of calculations'
  PRIVATE lgCycles            :='Cycles'
  PRIVATE lgShowAll           :='show another cycles even if the summary cycle is showed'
  PRIVATE lgClassicalCycles   :='Classical cycles'
  PRIVATE lgAdditionalCycle   :='Additional cycle'
  PRIVATE lgPhysicalCycle     :='Physical cycle'
  PRIVATE lgEmotionalCycle    :='Emotional cycle'
  PRIVATE lgIntellectualCycle :='Intellectual cycle'
  PRIVATE lgButton_Phys       :='Physical'
  PRIVATE lgButton_Emot       :='Emotional'
  PRIVATE lgButton_Inte       :='Intellectual'
  PRIVATE lgButton_Intu       :='Intuitive'
  PRIVATE lgButton_Today      :='Today'
  PRIVATE lgButton_Calculate  :='Calculate'
  PRIVATE lgButton_Summary    :='Summary'

  PRIVATE lgJanuary     :='January'
  PRIVATE lgFebruary    :='February'
  PRIVATE lgMarch       :='March'
  PRIVATE lgApril       :='April'
  PRIVATE lgMay         :='May'
  PRIVATE lgJune        :='June'
  PRIVATE lgJuly        :='July'
  PRIVATE lgAugust      :='August'
  PRIVATE lgSeptember   :='September'
  PRIVATE lgOctober     :='October'
  PRIVATE lgNovember    :='November'
  PRIVATE lgDecember    :='December'
  PRIVATE aMonth  :=  { lgJanuary, lgFebruary, lgMarch, lgApril,;
                        lgMay, lgJune, lgJuly, lgAugust,;
                        lgSeptember, lgOctober, lgNovember, lgDecember }

  PRIVATE xcDOB_day   :='1'
  PRIVATE xcDOB_month :='1'
  PRIVATE xcDOB_year  :='1970'

  PRIVATE dBegin
  PRIVATE dCurrent
  
  PRIVATE nFirstOff
  

  SelectLanguage()
     
  LOAD WINDOW Biorhythm AS oBiorhythm
  
  ON KEY ESCAPE OF oBiorhythm ACTION { || oBiorhythm.Release} 
  ON KEY F1 OF oBiorhythm ACTION DISPLAY HELP MAIN 
  ON KEY F2 OF oBiorhythm ACTION { || oBiorhythm.Center }

  Begin()
  ShowCycles()

  CENTER WINDOW oBiorhythm
  
  ACTIVATE WINDOW oBiorhythm

RETURN



PROCEDURE SelectLanguage(xPath)
  LOCAL cSet

  DEFAULT xPath:=0

  IF FILE('Biorhythm.ini')
    BEGIN INI FILE 'Biorhythm.ini'

      IF xPath=1
        lgLanguage:=ALLTRIM(oBiorhythm.Combo_Language.DisplayValue)
      ELSE
        GET lgLanguage SECTION "Biorhythm" ENTRY "language" DEFAULT lgLanguage
      ENDIF

      GET xcDOB_day   SECTION [Date of birth] ENTRY "cDOB_day"    DEFAULT xcDOB_day
      GET xcDOB_month SECTION [Date of birth] ENTRY "cDOB_month"  DEFAULT xcDOB_month
      GET xcDOB_year  SECTION [Date of birth] ENTRY "cDOB_year"   DEFAULT xcDOB_year

      GET lgBiorhythms        SECTION [cBiorhythms]        ENTRY lgLanguage  DEFAULT lgBiorhythms
      GET lgAbout             SECTION [cAbout]             ENTRY lgLanguage  DEFAULT lgAbout
      GET lgVersion           SECTION [cVersion]           ENTRY lgLanguage  DEFAULT lgVersion
      GET lgTranslators       SECTION [cTranslators]       ENTRY lgLanguage  DEFAULT lgTranslators
      GET lgDateOfBirth       SECTION [cDateOfBirth]       ENTRY lgLanguage  DEFAULT lgDateOfBirth
      GET lgDateOfCalc        SECTION [cDateOfCalc]        ENTRY lgLanguage  DEFAULT lgDateOfCalc
      GET lgCycles            SECTION [cCycles]            ENTRY lgLanguage  DEFAULT lgCycles
      GET lgShowAll           SECTION [cShowAll]           ENTRY lgLanguage  DEFAULT lgShowAll
      GET lgClassicalCycles   SECTION [cClassicalCycles]   ENTRY lgLanguage  DEFAULT lgClassicalCycles
      GET lgAdditionalCycle   SECTION [cAdditionalCycle]   ENTRY lgLanguage  DEFAULT lgAdditionalCycle
      GET lgPhysicalCycle     SECTION [cPhysicalCycle]     ENTRY lgLanguage  DEFAULT lgPhysicalCycle
      GET lgEmotionalCycle    SECTION [cEmotionalCycle]    ENTRY lgLanguage  DEFAULT lgEmotionalCycle
      GET lgIntellectualCycle SECTION [cIntellectualCycle] ENTRY lgLanguage  DEFAULT lgIntellectualCycle
      GET lgButton_Phys       SECTION [cButton_Phys]       ENTRY lgLanguage  DEFAULT lgButton_Phys
      GET lgButton_Emot       SECTION [cButton_Emot]       ENTRY lgLanguage  DEFAULT lgButton_Emot
      GET lgButton_Inte       SECTION [cButton_Inte]       ENTRY lgLanguage  DEFAULT lgButton_Inte
      GET lgButton_Intu       SECTION [cButton_Intu]       ENTRY lgLanguage  DEFAULT lgButton_Intu
      GET lgButton_Calculate  SECTION [cButton_Calculate]  ENTRY lgLanguage  DEFAULT lgButton_Calculate
      GET lgButton_Today      SECTION [cButton_Today]      ENTRY lgLanguage  DEFAULT lgButton_Today
      GET lgButton_Summary    SECTION [cButton_Summary]    ENTRY lgLanguage  DEFAULT lgButton_Summary
      GET lgLang              SECTION [cLanguage]          ENTRY lgLanguage  DEFAULT lgLang

      GET lgJanuary    SECTION [cJanuary]    ENTRY lgLanguage  DEFAULT lgJanuary
      GET lgFebruary   SECTION [cFebruary]   ENTRY lgLanguage  DEFAULT lgFebruary
      GET lgMarch      SECTION [cMarch]      ENTRY lgLanguage  DEFAULT lgMarch
      GET lgApril      SECTION [cApril]      ENTRY lgLanguage  DEFAULT lgApril
      GET lgMay        SECTION [cMay]        ENTRY lgLanguage  DEFAULT lgMay
      GET lgJune       SECTION [cJune]       ENTRY lgLanguage  DEFAULT lgJune
      GET lgJuly       SECTION [cJuly]       ENTRY lgLanguage  DEFAULT lgJuly
      GET lgAugust     SECTION [cAugust]     ENTRY lgLanguage  DEFAULT lgAugust
      GET lgSeptember  SECTION [cSeptember]  ENTRY lgLanguage  DEFAULT lgSeptember
      GET lgOctober    SECTION [cOctober]    ENTRY lgLanguage  DEFAULT lgOctober
      GET lgNovember   SECTION [cNovember]   ENTRY lgLanguage  DEFAULT lgNovember
      GET lgDecember   SECTION [cDecember]   ENTRY lgLanguage  DEFAULT lgDecember
    END INI

    aMonth:={}
    aMonth:={ lgJanuary, lgFebruary, lgMarch, lgApril,;
              lgMay, lgJune, lgJuly, lgAugust,;
              lgSeptember, lgOctober, lgNovember, lgDecember }

    cSet:=UPPER(lgLanguage)

    DO CASE
/**********************************************    
      CASE cSet == '<YourLanguage>'
        SET LANGUAGE TO <YourLanguage>
        SET CODEPAGE TO <YourCodePage>
        IF FILE('Biorhythm_<YL>.chm')
          SET HELPFILE TO 'Biorhythm_<YL>.chm'
        ELSE
          IF FILE('Biorhythm_<YL>.hlp')
            SET HELPFILE TO 'Biorhythm_<YL>.hlp'
          ENDIF
        ENDIF
***********************************************/        
      CASE cSet == 'RUSSIAN'
        SET LANGUAGE TO RUSSIAN
        SET CODEPAGE TO RUSSIAN
        IF FILE('Biorhythm_RU.chm')
          SET HELPFILE TO 'Biorhythm_RU.chm'
        ELSE
          IF FILE('Biorhythm_RU.hlp')
            SET HELPFILE TO 'Biorhythm_RU.hlp'
          ENDIF
        ENDIF
        
      CASE cSet == 'POLSKI'
        SET LANGUAGE TO POLISH
        SET CODEPAGE TO POLISH
        IF FILE('Biorhythm_PL.chm')
          SET HELPFILE TO 'Biorhythm_PL.chm'
        ELSE
          IF FILE('Biorhythm_PL.hlp')
            SET HELPFILE TO 'Biorhythm_PL.hlp'
          ENDIF
        ENDIF
      OTHERWISE
        SET LANGUAGE TO ENGLISH
        SET CODEPAGE TO ENGLISH
        IF FILE('Biorhythm_EN.chm')
          SET HELPFILE TO 'Biorhythm_EN.chm'
        ELSE
          IF FILE('Biorhythm_EN.hlp')
            SET HELPFILE TO 'Biorhythm_EN.hlp'
          ENDIF
        ENDIF
    ENDCASE

  ELSE
    CreateINI()
  ENDIF

RETURN



PROCEDURE Begin(xPath)

  LOCAL i
  LOCAL n:=1
  LOCAL nBorn
  LOCAL cLang
  LOCAL aItems:={}
  LOCAL xxDOB_day
  LOCAL xxDOB_month
  LOCAL xxDOB_year

  DEFAULT xPath:=0

  oBiorhythm.frBiorhythms.Caption:=lgBiorhythms
  oBiorhythm.frDateOfBirth.Caption:=lgDateOfBirth
  oBiorhythm.frDateOfCalc.Caption:=lgDateOfCalc
  oBiorhythm.frCycles.Caption:=lgCycles
  oBiorhythm.ShowAll.Caption:=lgShowAll
  oBiorhythm.frClassicalCycles.Caption:=lgClassicalCycles
  oBiorhythm.frAdditionalCycle.Caption:=lgAdditionalCycle
  oBiorhythm.frPhysicalCycle.Caption:=lgPhysicalCycle
  oBiorhythm.frEmotionalCycle.Caption:=lgEmotionalCycle
  oBiorhythm.frIntellectualCycle.Caption:=lgIntellectualCycle
  oBiorhythm.Button_Phys.Caption:=lgButton_Phys
  oBiorhythm.Button_Emot.Caption:=lgButton_Emot
  oBiorhythm.Button_Inte.Caption:=lgButton_Inte
  oBiorhythm.Button_Intu.Caption:=lgButton_Intu
  oBiorhythm.Button_Today.Caption:=lgButton_Today
  oBiorhythm.Button_Calculate.Caption:=lgButton_Calculate
  oBiorhythm.Button_Summary.Caption:=lgButton_Summary
  
  oBiorhythm.frLanguage.Caption:=lgLang

  IF xPath=0

    IsFirstRun:=.F.

    xxDOB_day:=VAL(xcDOB_day)
    xxDOB_month:=VAL(xcDOB_month)
    xxDOB_year:=ALLTRIM(xcDOB_year)

    oBiorhythm.SpinnerBorn.Value    :=xxDOB_day
    oBiorhythm.ComboBorn.Value      :=xxDOB_month
    oBiorhythm.TextBorn.Value       :=xxDOB_year

    oBiorhythm.SpinnerCurrent.Value := DAY(DATE())
    oBiorhythm.ComboCurrent.Value   := MONTH(DATE())
    oBiorhythm.TextCurrent.Value    := STR(YEAR(DATE()),4)

    oBiorhythm.Combo_Language.DeleteAllItems
    WHILE .T.
      cLang := GetLangName(n)
      IF cLang == ""
        EXIT
      ENDIF
      AADD( aItems, cLang )
      n ++
    END WHILE

    ASORT(aItems,,, { | x, y | OEMTOLATIN(x) < OEMTOLATIN(y) })
    
    FOR i=1 TO LEN(aItems)
      oBiorhythm.Combo_Language.AddItem( aItems[i] )
    NEXT I

    oBiorhythm.Combo_Language.Value := ASCAN( aItems,  {|e| e = lgLanguage })
    
  ENDIF

  nBorn:=oBiorhythm.ComboBorn.Value
  oBiorhythm.ComboBorn.DeleteAllItems
  FOR I:=1 TO LEN(aMonth)
    oBiorhythm.ComboBorn.AddItem( aMonth[I] )
  NEXT I
  oBiorhythm.ComboBorn.Value := nBorn


  nBorn:=oBiorhythm.ComboCurrent.Value
  oBiorhythm.ComboCurrent.DeleteAllItems
  FOR I:=1 TO LEN(aMonth)
    oBiorhythm.ComboCurrent.AddItem( aMonth[I] )
  NEXT I
  oBiorhythm.ComboCurrent.Value := nBorn

RETURN




FUNCTION OEMTOLATIN(xText)

xText:=STRTRAN(xText,CHR(200),CHR(67))

RETURN xText   





PROCEDURE ValidDate()

  LOCAL aDays:={31,28,31,30,31,30,31,31,30,31,30,31}
  LOCAL dCurrentMinus
  LOCAL dCurrentPlus  

  IF ISLEAP(CTOD('01.01.'+oBiorhythm.TextBorn.Value ))
    aDays[2]:=29
  ENDIF

  IF oBiorhythm.SpinnerBorn.Value>=aDays[oBiorhythm.ComboBorn.Value]
    oBiorhythm.SpinnerBorn.Value:=aDays[oBiorhythm.ComboBorn.Value]
    oBiorhythm.SpinnerBorn.Refresh
  ENDIF

  IF VAL(oBiorhythm.TextCurrent.Value)<VAL(cFDGCy)
    oBiorhythm.TextCurrent.Value:=cFDGCy
  ENDIF


  IF ISLEAP(CTOD('01.01.'+oBiorhythm.TextCurrent.Value ))
    aDays[2]:=29
  ENDIF
  
  IF oBiorhythm.SpinnerCurrent.Value>=aDays[oBiorhythm.ComboCurrent.Value]
    oBiorhythm.SpinnerCurrent.Value:=aDays[oBiorhythm.ComboCurrent.Value]
    oBiorhythm.SpinnerCurrent.Refresh
  ENDIF


  dBegin:=CTOD("'"+STR(oBiorhythm.SpinnerBorn.Value,0) ;
    +"."+STR(oBiorhythm.ComboBorn.Value,0) ;
    +"."+oBiorhythm.TextBorn.Value+"'" )


  dCurrent:=CTOD("'"+STR(oBiorhythm.SpinnerCurrent.Value,0) ;
    +"."+STR(oBiorhythm.ComboCurrent.Value,0) ;
    +"."+oBiorhythm.TextCurrent.Value+"'" )


  nFirstOff:=0
  IF dBegin<CTOD(cFDGC)
    dBegin:=CTOD(cFDGC)
    oBiorhythm.SpinnerBorn.Value:=cFDGCd
    oBiorhythm.ComboBorn.Value:=cFDGCm
    oBiorhythm.TextBorn.Value:=cFDGCy
  ENDIF

  IF dBegin>dCurrent
    dCurrent:=dBegin
    oBiorhythm.SpinnerCurrent.Value :=  oBiorhythm.SpinnerBorn.Value
    oBiorhythm.ComboCurrent.Value   :=  oBiorhythm.ComboBorn.Value
    oBiorhythm.TextCurrent.Value    :=  oBiorhythm.TextBorn.Value
  ENDIF

  IF dCurrent>=CTOD(cFDGC)
     IF dCurrent-CTOD(cFDGC)<20
       nFirstOff:=20-(dCurrent-CTOD(cFDGC))
     ENDIF
  ENDIF

  oBiorhythm.LabelCurrent.Value:=;
    (  ALLTRIM(STR(oBiorhythm.SpinnerCurrent.Value,0)) ;
    +" "+ALLTRIM(oBiorhythm.ComboCurrent.DisplayValue) ;
    +" "+oBiorhythm.TextCurrent.Value )
    
  IF nFirstOff<10+1 
    dCurrentMinus:=CTOD("'"+STR(oBiorhythm.SpinnerCurrent.Value,0) ;
      +"."+STR(oBiorhythm.ComboCurrent.Value,0) ;
      +"."+oBiorhythm.TextCurrent.Value+"'" )-10

    oBiorhythm.LabelMinus.Value:=;
      STR(DAY(dCurrentMinus));
      +" "+aMonth[MONTH(dCurrentMinus)];
      +STR(YEAR(dCurrentMinus))
  ELSE
    oBiorhythm.LabelMinus.Value:=''
  ENDIF

  dCurrentPlus:=CTOD("'"+STR(oBiorhythm.SpinnerCurrent.Value,0) ;
    +"."+STR(oBiorhythm.ComboCurrent.Value,0) ;
    +"."+oBiorhythm.TextCurrent.Value+"'" )+10

  oBiorhythm.LabelPlus.Value:=;
    STR(DAY(dCurrentPlus));
    +" "+aMonth[MONTH(dCurrentPlus)];
    +STR(YEAR(dCurrentPlus))

RETURN



PROCEDURE ChangeCurrentDate(xnOffset)
  
  LOCAL dCCD

  IF xnOffset<>0
    dCCD:=CTOD("'"+STR(oBiorhythm.SpinnerCurrent.Value,0) ;
      +"."+STR(oBiorhythm.ComboCurrent.Value,0) ;
      +"."+oBiorhythm.TextCurrent.Value+"'" )+xnOffset
  ELSE
    dCCD:=DATE()
    oBiorhythm.Button_Calculate.Enabled:=.F.
  ENDIF

  oBiorhythm.SpinnerCurrent.Value := DAY(dCCD)
  oBiorhythm.ComboCurrent.Value   := MONTH(dCCD)
  oBiorhythm.TextCurrent.Value    := STR(YEAR(dCCD),4)

RETURN



PROCEDURE ShowAll_Change(xnCase)

  IF !(oBiorhythm.ShowAll.Value)
    DO CASE
      CASE xnCase=1
        oBiorhythm.Button_Summary.Value := .F.
      CASE xnCase=2
        IF oBiorhythm.Button_Summary.Value==.T.
          oBiorhythm.Button_Phys.Value:=.F.
          oBiorhythm.Button_Emot.Value:=.F.
          oBiorhythm.Button_Inte.Value:=.F.
          oBiorhythm.Button_Intu.Value:=.F.
        ELSE
          oBiorhythm.Button_Phys.Value:=.T.
          oBiorhythm.Button_Emot.Value:=.T.
          oBiorhythm.Button_Inte.Value:=.T.
        ENDIF
      CASE xnCase=3        
        IF oBiorhythm.Button_Summary.Value==.T.
          oBiorhythm.Button_Phys.Value:=.F.
          oBiorhythm.Button_Emot.Value:=.F.
          oBiorhythm.Button_Inte.Value:=.F.
          oBiorhythm.Button_Intu.Value:=.F.
        ENDIF      
    END CASE
  ENDIF

RETURN



PROCEDURE ShowCycles(xPath)

  DEFAULT xPath:=0

  oBiorhythm.Button_Calculate.Enabled:=.F.

  oBiorhythm.Button_Summary.ENABLED:=.T.
  oBiorhythm.Button_Phys.ENABLED:=.T.
  oBiorhythm.Button_Emot.ENABLED:=.T.
  oBiorhythm.Button_Inte.ENABLED:=.T.
  oBiorhythm.Button_Intu.ENABLED:=.T.

  IF xPath==0
    oBiorhythm.Button_Summary.Value:=.F.
    oBiorhythm.Button_Phys.Value:=.T.
    oBiorhythm.Button_Emot.Value:=.T.
    oBiorhythm.Button_Inte.Value:=.T.
    oBiorhythm.Button_Intu.Value:=.F.
  ENDIF

RETURN



PROCEDURE DateChanged()

  IF IsFirstRun==.T.
    ERASE WINDOW oBiorhythm

    oBiorhythm.LabelCurrent.Value:=""
    oBiorhythm.LabelMinus.Value:=""
    oBiorhythm.LabelPlus.Value:=""
    oBiorhythm.Button_Calculate.Enabled:=.T.

    xcDOB_day:=ALLTRIM(STR(oBiorhythm.SpinnerBorn.Value))
    xcDOB_month:=ALLTRIM(STR(oBiorhythm.ComboBorn.Value))
    xcDOB_year:=ALLTRIM(oBiorhythm.TextBorn.Value)

    oBiorhythm.Button_Minus.Visible:=.F.
    oBiorhythm.Button_MinusONE.Visible:=.F.
    oBiorhythm.Button_Plus.Visible:=.F.
    oBiorhythm.Button_PlusONE.Visible:=.F.

    oBiorhythm.Button_Summary.ENABLED:=.F.
    oBiorhythm.Button_Phys.ENABLED:=.F.
    oBiorhythm.Button_Emot.ENABLED:=.F.
    oBiorhythm.Button_Inte.ENABLED:=.F.
    oBiorhythm.Button_Intu.ENABLED:=.F.
  ENDIF

  IF (oBiorhythm.FocusedControl != 'SpinnerBorn');
     .AND.;
     (oBiorhythm.FocusedControl != 'SpinnerCurrent');
     .AND.;
     (oBiorhythm.FocusedControl != 'TextBorn');
     .AND.;
     (oBiorhythm.FocusedControl != 'TextCurrent');
     .OR.;
     (oBiorhythm.SpinnerCurrent.Value>10;
     .AND.;
     oBiorhythm.SpinnerBorn.Value>10);
     .AND.;
     (LEN(oBiorhythm.TextCurrent.Value)==4;
     .AND.;
     LEN(oBiorhythm.TextBorn.Value)==4)
     
    oBiorhythm.Button_Calculate.SetFocus
  ENDIF

RETURN



PROCEDURE ShowBiorhythm()
  oBiorhythm.Button_Minus.Visible:=.T.
  oBiorhythm.Button_MinusONE.Visible:=.T.
  oBiorhythm.Button_Plus.Visible:=.T.
  oBiorhythm.Button_PlusONE.Visible:=.T.

  oBiorhythm.Button_Summary.ENABLED:=.T.
  oBiorhythm.Button_Phys.ENABLED:=.T.
  oBiorhythm.Button_Emot.ENABLED:=.T.
  oBiorhythm.Button_Inte.ENABLED:=.T.
  oBiorhythm.Button_Intu.ENABLED:=.T.
  
  oBiorhythm.Button_Minus.Visible    :=.T.
  oBiorhythm.Button_MinusONE.Visible :=.T.
  oBiorhythm.Button_Plus.Visible     :=.T.
  oBiorhythm.Button_PlusONE.Visible  :=.T.
    
RETURN



PROCEDURE DrawBiorhythm()

  LOCAL nDays
  LOCAL I, x0, y0, Step_fi := 0.10
  LOCAL rr:=130
  LOCAL nPixels:=16
  LOCAL nDaysPrev:=20
  LOCAL nOffsetX:=80
  LOCAL nOffsetY:=((800-(nPixels*(nDaysPrev)*2))/2)
  LOCAL nPercent
  LOCAL aValue:={ "+100","+080","+060","+040","+020",;
                  "+000",;
                  "-020","-040","-060","-080","-100";
                }

  ERASE WINDOW oBiorhythm

  ValidDate()
  ShowBiorhythm()

  nDays:= dCurrent-dBegin

  nPercent:=0
  FOR I:=rr-120 TO rr+120 STEP (120*2)/10
    nPercent++
    draw text in window oBiorhythm;
      at (nOffsetX+i)-5,37;
      value aValue[nPercent] transparent;
      Font "arial" size 7
    draw text in window oBiorhythm;
      at (nOffsetX+i)-5,743;
      value aValue[nPercent] transparent;
      Font "arial" size 7

  NEXT I

  y0:=0

  FOR I:=rr-120 TO rr+120 STEP (120*2)/10
    x0:=I
    drawline("oBiorhythm",;
            (nOffsetX+x0), (nOffsetY+y0),;
            (nOffsetX+x0), (nOffsetY+nDaysPrev*nPixels*2),;
            IIF(I==rr-120.OR.I==rr.OR.I==rr+120,;
              {0,0,0},;
              {128,128,128});
            ,.5 )
  NEXT I
   

  FOR I := 0 TO (nDaysPrev*2) STEP 1
    x0:=rr-120
    y0:=i*nPixels
    drawline(;
            "oBiorhythm",;
            IIF(i<>nDaysPrev,(nOffsetX+x0),(nOffsetX+x0)-20),;
            (nOffsetY+y0),;
            IIF(i<>nDaysPrev,(nOffsetX+x0+240),(nOffsetX+x0+240)+10),;
            (nOffsetY+y0),;
              IIF(i<>nDaysPrev,;
                  IIF(I=0.OR.I=(nDaysPrev*2),;
                    {0,0,0},;
                    {128,128,128});
              ,{255,0,15});
            ,.5;
            )
  NEXT I

  FOR I := 0 TO (nDaysPrev*2) STEP 1
    x0:=rr-120
    y0:=i*nPixels
    
    IF nFirstOff<(nDaysPrev/2)+1   
      IF I==nDaysPrev-(nDaysPrev/2)
        drawline("oBiorhythm",;
                (nOffsetX+x0-10),;
                (nOffsetY+y0),;
                (nOffsetX+x0+240+30),;
                (nOffsetY+y0),;
                BLUE ,.5 )
      ENDIF
    ENDIF    
  
    IF I==nDaysPrev+(nDaysPrev/2)
      drawline("oBiorhythm",;
              (nOffsetX+x0-10),;
              (nOffsetY+y0),;
              (nOffsetX+x0+240+30),;
              (nOffsetY+y0),;
              BLUE ,.5 )
    ENDIF
  NEXT I


  IF nFirstOff<20.AND.nFirstOff>0
    x0:=rr-120
    y0:=nFirstOff*nPixels

      drawline("oBiorhythm",;
              (nOffsetX+x0),;
              (nOffsetY+y0),;
              (nOffsetX+x0+240),;
              (nOffsetY+y0),;
              YELLOW ,.5 )
    
  ENDIF
   

  draw polygon in window oBiorhythm ;
    points  {{nOffsetX+rr+130,  (nDaysPrev*nPixels)+nOffsetY},;
            {nOffsetX+rr+130-7,(nDaysPrev*nPixels)+nOffsetY-3},;
            {nOffsetX+rr+130-7,(nDaysPrev*nPixels)+nOffsetY+3};
           };
    pencolor {255,0,15};
    penwidth 1;
    fillcolor {255,0,15}


  FOR i := 0+nFirstOff TO nDaysPrev*2 STEP Step_fi

    y0 := i

    IF oBiorhythm.Button_Summary.Value
      x0:=( -(sin( pi()*( mod(i-nDaysPrev+nDays,N_EMOT) )*(2/N_EMOT)));
          + -(sin( pi()*( mod(i-nDaysPrev+nDays,N_INTE) )*(2/N_INTE)));
          + -(sin( pi()*( mod(i-nDaysPrev+nDays,N_PHYS) )*(2/N_PHYS))) )/3
      drawline("oBiorhythm", (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels),;
              (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels), BLACK ,3 )

      draw rectangle in window oBiorhythm at 530,45 ;
        to 540,545;
        pencolor BLACK;
        penwidth 1;
        fillcolor BLACK
    ELSE
      draw rectangle in window oBiorhythm at 530,45 ;
        to 540,545;
        pencolor BLACK;
        penwidth 2
    ENDIF

    IF oBiorhythm.Button_Phys.Value
      x0:=-(sin( pi()*( mod(i-nDaysPrev+nDays,N_PHYS) )*(2/N_PHYS)))
      drawline("oBiorhythm", (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels),;
              (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels), {255,0,0} , 3 )

      draw rectangle in window oBiorhythm at 465,45 ;
        to 485,185;
        pencolor {255,0,0};
        penwidth 1;
        fillcolor {255,0,0}
    ELSE
      draw rectangle in window oBiorhythm at 465,45 ;
        to 485,185;
        pencolor {255,0,0};
        penwidth 2
    ENDIF

    IF oBiorhythm.Button_Emot.Value
      x0:=-(sin( pi()*( mod(i-nDaysPrev+nDays,N_EMOT) )*(2/N_EMOT)))
      drawline("oBiorhythm", (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels),;
              (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels), {0,0,255} ,3 )

      draw rectangle in window oBiorhythm at 465,225 ;
        to 485,365;
        pencolor {0,0,255};
        penwidth 1;
        fillcolor {0,0,255}
    ELSE
      draw rectangle in window oBiorhythm at 465,225 ;
        to 485,365;
        pencolor {0,0,255};
        penwidth 2
    ENDIF

    IF oBiorhythm.Button_Inte.Value
      x0:=-(sin( pi()*( mod(i-nDaysPrev+nDays,N_INTE) )*(2/N_INTE)))
      drawline("oBiorhythm", (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels),;
              (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels), {0,255,0} , 3 )

      draw rectangle in window oBiorhythm at 465,405 ;
        to 485,545;
        pencolor {0,255,0};
        penwidth 1;
        fillcolor {0,255,0}
    ELSE
      draw rectangle in window oBiorhythm at 465,405 ;
        to 485,545;
        pencolor {0,255,0};
        penwidth 2
    ENDIF

    IF oBiorhythm.Button_Intu.Value
      x0:=-(sin( pi()*( mod(i-nDaysPrev+nDays,N_INTU) )*(2/N_INTU)))
      drawline("oBiorhythm", (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels),;
              (nOffsetX+rr+x0*120), (nOffsetY+y0*nPixels), {255,255,0} , 3 )

      draw rectangle in window oBiorhythm at 465,615 ;
        to 485,755;
        pencolor {255,255,0};
        penwidth 1;
        fillcolor {255,255,0}
    ELSE
      draw rectangle in window oBiorhythm at 465,615 ;
        to 485,755;
        pencolor {255,255,0};
        penwidth 2
    ENDIF

  NEXT I

RETURN



*********************************************************************************
**borrowed from [MiniGUI]\samples\basic\MultiLingual\demo.prg
*********************************************************************************

FUNCTION GetLangName(iLangNumber)
  LOCAL cFileName := GetStartupFolder() + "\Biorhythm.ini"
  LOCAL sReadStr
  LOCAL i
  LOCAL LangName := ""
  LOCAL oFile

  IF FILE( cFileName )
    oFile := TFileRead():New( cFileName )
    oFile:Open()
    IF oFile:Error()
      MsgStop( oFile:ErrorMsg( "FileRead: " ), "Error" )
    ELSE
      sReadStr := oFile:ReadLine()
      oFile:Close()
      For i = 1 To NumToken(sReadStr, ",")
        IF i == iLangNumber
          LangName := Token(sReadStr, ",", i)
          EXIT
        ENDIF
      NEXT i
    ENDIF
  ENDIF

RETURN ( LangName )



PROCEDURE ReleaseBiorhytms()
  IF FILE('Biorhythm.ini')
      BEGIN INI FILE 'Biorhythm.ini'

        SET SECTION [Date of birth];
            ENTRY "cDOB_day";
            TO xcDOB_day
            
        SET SECTION [Date of birth];
            ENTRY "cDOB_month";
            TO xcDOB_month
            
        SET SECTION [Date of birth];
            ENTRY "cDOB_year";
            TO xcDOB_year
            
        SET SECTION [Biorhythm];
            ENTRY "language";
            TO ALLTRIM(oBiorhythm.Combo_Language.DisplayValue)

      END INI
  ENDIF

RETURN



PROCEDURE AboutBox()

  LOCAL n:=1
  LOCAL cLang
  LOCAL cTranslator
  LOCAL aItems:={}

    WHILE .T.
      cLang := GetLangName(n)
      If cLang == ""
        EXIT
      ELSE
        cTranslator := GetTranslatorName(cLang)       
      EndIf
      aadd( aItems, {cLang,cTranslator} )
      n ++
    END WHILE

  LOAD WINDOW AboutBox AS oAboutBox

  CENTER WINDOW oAboutBox
    
  ACTIVATE WINDOW oAboutBox

RETURN



PROCEDURE AboutBox_Init()
   
  oAboutBox.Title                 := lgAbout
  oAboutBox.LabelVersion.Caption  := lgVersion+ " "+ VERSION
  oAboutBox.frAbout.Caption       := lgAbout
  oAboutBox.frTranslators.Caption := lgTranslators
  oAboutBox.Tab_1.Caption(1)      := lgAbout
  oAboutBox.Tab_1.Caption(2)      := lgTranslators
  oAboutBox.Grid_1.Header(1)      := lgLang
  oAboutBox.Grid_1.Header(2)      := lgTranslators

// Tab.Refresh   
  oAboutBox.Tab_1.Hide
  oAboutBox.Tab_1.Show

RETURN



FUNCTION GetTranslatorName(xcLang)

  IF FILE('Biorhythm.ini')
    BEGIN INI FILE 'Biorhythm.ini'
       
      GET xcLang SECTION [cTranslator] ENTRY xcLang  DEFAULT ""
      
    END INI
  ENDIF
  
RETURN xcLang


#ifdef __XHARBOUR__
  #include <fileread.prg>
#endif

// End of file