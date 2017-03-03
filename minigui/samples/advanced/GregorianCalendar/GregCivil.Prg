/***************************************************************************************************
* Program Name: GregCivil.Prg
*       Calls : Easter from EasterCalc.Prg
*
* Purpose : To Generate Gregorian Calendar with all the Holidays in the Philippines (that I
*           remembered as of the moment) and the Church Feast Days. You can customized Holidays
*           according to your locality.
*
*
* Copyright © 2008 Danny A. del Pilar <dhaine_adp@yahoo.com> , All Rights Reserved.
* Manila, Philippines
* 
* 
* 
*  This program is free software; you can redistribute it and/or modify it under 
*  the terms of the GNU General Public License as published by the Free Software 
*  Foundation; either version 2 of the License, or (at your option) any later    
*  version.                                                                      
*                                                                                
*  This program is distributed in the hope that it will be useful, but WITHOUT   
*  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
*  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*                                                                                
*  You should have received a copy of the GNU General Public License along with  
*  this software; see the file COPYING. If not, write to the Free Software       
*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or   
*  visit the web site http://www.gnu.org/).                                      
*
*-------------------------------------------------------------------------------------------
* DISCLAIMER:
* ===========
* XL.ch -- This is not my definitions, I downloaded it somewhere from the internet in 2006.
* ======== The source comments was strip-off during my early experimentation with HMG.
*          If you have any information, please correct me. Anyway, whoever you are
*          who wrote this XL.ch THANK YOU VERY MUCH!
*
*          On the otherhand, it was Mr. Roberto Lopez who told me to record macro and
*          edit the macro after stopping it to see what is the corresponding value of
*          the task I recorded. If I remember it correctly it was sometime in December 2006,
*          a few day(s) before New Year.
*          
*------------------------------------------------------------------------------------------
*
* Revisions History:
* June 3, 2006 - Initial Release, created from scratch using TOLEAuto()
* August 13, 2007 - Source code is revised due to changes in HB OLE.
*
* NOTE: This is a part of my working application that I took-off and made as stand-alone to
*       served as an example for those who are learning HMG like myself.
*
* 
* MY MOTIVATION IN WRITING THIS PROGRAM
* -------------------------------------
*
*    Well it is easy creating calendar using Microsoft Excel, the trouble comes in when I
* am trying to mark the Holidays for a particular year. Since at present I am working in
* Saudi Arabia, all the calendars that I could see is that of Islamic Calendar (Hijri
* Calendar which is based on the lunar cycle). That the new day begins at sunset which is
* different from Gregorian Calendar because a new day begins at midnight.
*
*    Being a Christian in Islamic Country most especially in Saudi Arabia (the most
* conservative Muslim in all the Islamic States) I find it difficult to know the Easter
* Sunday without resorting to overseas call to Philippines to ask my wife regarding the
* Easter Date. If I wanted to recite the Holy Rosary, it is also a problem to find the
* appropriate Mysteries. It's not appropriate to recite Joyful Mysteries during Lent
* (40 days from Ash Wednesday to Holy Saturday) or reciting Sorrowful Mysteries in the
* period of Advent.
*
*
*    We used Gregorian Calendar here but without those Feast Days related to Church.
*
*    And so that was my Main Goal to find Easter Sunday. After coding the calculation of
* Easter Sunday, I realized that I can generate a calendar for any given year and still
* able to calculate the movable Holidays of the Gregorian Calendar (Easter Sunday and
* Good Friday. In the Philippines Thursday before Good Friday is also a Holiday) So with
* the help of HB OLE and MiniGUI (by Roberto Lopez) I'd be able to create a Calendar
* with all the Holidays and Church Feast Days.
*
*    One thing more, eversince I learned to read and write, it's been a childhood question
* until 2006 that kept me wondering why EVERY YEAR, THE CALENDARS DATE AND DAYS IS DIFFERENT
* AND WHEN I WOULD SEE THEM THE SAME AGAIN IN DIFFERENT YEAR.
*
*    After I created this calendar GregCivil.Prg, I spent time playing with it like adding and
* subtracting 10, 20, 30, 40...100, 200, 300, 400 from 2008. I kept the Year 2008 Excel Window opened
* until I hit that 2408 when I saw that the days and date of the month is the same. At first I
* thought I made a mistake, then subtracted 400 and goes to 1608, still they are the same. I go
* to year 2808 and yet they are the same. I can't believed it so I went on-line do some more
* research and finaly I confirmed that the metonic cycle for Gregorian Calendar is every 400 years
* and for Julian Calendar is 19 Years. The leap year concept of Pope Gregory XIII makes a big
* difference.
*
*   Though I am not the first but it has been a great pleasure for me to find the answer in my
* childhood question considering that I never intended to find the answer and this is not my goal. 
* Really, God is good, God is great! No wonder I am still a Christian in spite of 12 years of
* working here.
*
*   I was born in 1970, learned to read and write when I was 6 and found this 400 years cycle of the
* Gregorian Calendar when I was 36. I'll be long gone beneath the ground but would never see 
* that the days and date of Calendar to be same again in different year. But with the help of 
* Harbour, HB OLE and MiniGUI I saw it virtually somehow in my time.
*
* To: All the developers of Harbour - THANK YOU VERY MUCH!
* To: Mr. Roberto Lopez, the creator of Harbour MiniGUI - THANK YOU VERY MUCH!
* To: Mr. Rathinagiri, THANK YOU VERY MUCH FOR THIS HMG FORUM!
* To: All of US here, MORE POWER!
*
*
* About the Program:
* ------------------
*   After compilation, during runtime, if you removed the thick mark (check mark) on Civil Calendar
* (includes Regular Holidays) the program will prompt you to put a check mark. It's a minor bug
* that I never get fixed out of pure laziness, sorry. However as an example for HB OLE for those 
* who are learning HMG like me, it's fine if you want to agree with me otherwise not. LOL
*
*   The Holidays contained in here are those of Regular Philippine Holidays. You can adjust it to
* suit your own local holidays.
*
*   Technically, you have the source code so, enjoy!
*
* Test Platform:
* --------------
*
* OS: Windows XP Professional Version 2002 SP2 with the latest security updates
*     Microsoft Office Professional version 2003
*
*     Windows Vista Ultimate (dual boot)
*     Microsoft Office 2007
* 
* Hardware: Dell Inspiron 510m
*
* Test Result: The program works fine for both of OSs' on my testing.
*              Not tested with Windows Vista Enterprise. I believed it has nothing to do with
*              the OS, please, correct me if I am mistaken.
*
* WARNING: I have renamed function Main() to Main1() in the EasterCalc.Prg
*
* TIP: If you are calculating days beyond 1582 to prehistoric times, it is better
*      to calculate in Julian Days Number rather than Gregorian Calendar. The same is true
*      if you are calculating beyond year 3000 AD or CE. Well that is if you are interested
*      in triangulating/calculating the position of celestial bodies.
*
*
* Regards,
* 
* Danny A. del Pilar <dhaine_adp@yahoo.com>
* Manila, Philippines
*
*
****************************************************************************************************
*/



#include "minigui.ch"
#include "XL.ch"


MEMVAR aHolidays_
*********************************
function Main()

   IF ISWINDOWDEFINED(frmGregCivil)
      DOMETHOD("frmGregCivil","SetFocus")
      RETURN NIL
   ENDIF

   DEFINE WINDOW frmGregCivil;
      AT 0,0;
      WIDTH 360 HEIGHT 228;
      TITLE "Gregorian Calendar";
      MAIN ICON "main.ico";
      NOMAXIMIZE NOMINIMIZE;
      FONT "Arial" SIZE 9
         
      ON KEY RETURN ACTION ButtonOk()
         
      @  70, 10 FRAME Frame_1 OF frmGregCivil CAPTION "Please select calendar settings"; 
         WIDTH  330 HEIGHT 80 FONT "Arial" SIZE 9 BACKCOLOR NIL FONTCOLOR NIL OPAQUE
         
      @  10, 10 FRAME Frame_2 OF frmGregCivil CAPTION "Year to be entered must be after 1582"; 
         WIDTH  330 HEIGHT 50 FONT "Arial" SIZE 9 BACKCOLOR NIL FONTCOLOR NIL OPAQUE
         
      @  30, 20 LABEL lblYear OF frmGregCivil VALUE "Please enter year in full century format :"; 
         ACTION Nil WIDTH  215 HEIGHT 20 FONT "Arial" SIZE 9
         
      @  26,240 TEXTBOX txbYear OF frmGregCivil HEIGHT 24; 
         VALUE Year(Date()) WIDTH  92 NUMERIC INPUTMASK "9999" 
         
      @  90, 20 CHECKBOX chkCivilNormal OF frmGregCivil ;
         CAPTION "Civil Calendar (includes Regular Holidays)";
         WIDTH  270 HEIGHT 24 VALUE .T.
         
      @ 115, 20 CHECKBOX chkCivilVatican2 OF frmGregCivil ;
         CAPTION "Include Lists of Pre-Vatican II Feast Related to Easter";
         WIDTH  310 HEIGHT 24 VALUE .T.
         
      @ 160,170 BUTTON btnOk OF frmGregCivil CAPTION "&Ok" ACTION ButtonOk() WIDTH 80 HEIGHT 24 FONT "Arial" SIZE 9
         
      @ 160,260 BUTTON btnCancel OF frmGregCivil CAPTION "&Cancel" ACTION frmGregCivil.Release();
         WIDTH 80 HEIGHT 24 FONT "Arial" SIZE 9

      @ 158, 10 PROGRESSBAR pBarCalendar OF frmGregCivil RANGE 1,366 WIDTH  150 HEIGHT 18 SMOOTH
         
      @ 177, 11 LABEL lblFormat OF frmGregCivil VALUE "Formatting calendar, please wait...."; 
         ACTION Nil WIDTH  149 HEIGHT 18 FONT "Arial" SIZE 7
         
   END WINDOW
   frmGregCivil.Center
   frmGregCivil.pBarCalendar.Hide
   frmGregCivil.lblFormat.Hide
   frmGregCivil.Activate
   RETURN NIL



***************************
function ChkYear1582(nYear)

   LOCAL lRetVal

   IF nYear <= 1582
      lRetVal := MSGOKCANCEL("Easter Sunday cannot be calculated accurately beyond 1582 because " + CRLF +;
                             "Pope Gregory XIII has just revised the Julian Calendar that year  " + CRLF +;
                             "to properly align the sun and moon with the seasons. During that  " + CRLF +;
                             "time Julian Calendar is out of syncronization with the solar year." + CRLF +;
                             "On the otherhand Gregorian calendar is accurate with a plus or    " + CRLF +;
                             "minus one day error with the solar year. It will be accurate until" + CRLF +;
                             "the Year 3300.                                                    " + CRLF +;
                             " " + CRLF +;
                             "For curiosity reason you can click OK and go ahead otherwise click" + CRLF +;
                             "the cancel button.                                                " + CRLF,;
                             "Do you know that...")
   ENDIF
   RETURN lRetVal




**************************
static function ButtonOk()

   LOCAL nYear := frmGregCivil.txbYear.Value
   LOCAL IsLiturgyFeast := frmGregCivil.chkCivilVatican2.Value

   LOCAL BaseDate := CTOD("")
   LOCAL BeginOfYear := CTOD("")
   LOCAL EndOfYear := CTOD("")
   
   LOCAL CurrentMonth := 0,;
       EndDate := CTOD("")
  
   LOCAL NbrOfWeek := 0        
       
   LOCAL aGregorianColumn_ := {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
   
   
   ///////////////////////////////////////////////////////////////
   // LOCAL Variable declaration, exlusively used in formatting //
   //   Microsoft Excel thru HMG OLE.                           //
   /////////////////////////////////////////////////////////////// 
   LOCAL oExcel, oSheet, nSheets, oSelection, oWindow
   
   LOCAL xCounter    := 0,;
       nArrayIndex := 0
   
   LOCAL nRow := 1, nColumn := 1
   
   LOCAL acMonths_    := {"J A N U A R Y","F E B R U A R Y","M A R C H","A P R I L","M A Y","J U N E",;
                       "J U L Y","A U G U S T","S E P T E M B E R","O C T O B E R","N O V E M B E R",;
                       "D E C E M B E R"},;
       cYear        := "",;
       ColSwitch    := 0,;
       BorderSwitch := 0,;
       BorderTop    := 0,;
       BorderBottom := 0,;
       RowReset     := .T.,;
       ForLoopStart := 1,;
       ForLoopEnd   := 0,;
       cRange       := ""
          
   LOCAL lHolidayBaIto := .F.,;
         acHolidayDesc_ := {},;
         acShortMonthNm_ := {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    
   ////////////////////////////////////////////////////////////////////////////////////
   // Variable decalarations used to determine Pre-Vatican II Feast Related to Easter //
   ////////////////////////////////////////////////////////////////////////////////////        
   LOCAL ChristmasDay             
   LOCAL acFeastDays_ := {}
   LOCAL LoopStart, LoopEnd
          
   *- variables to format Liturgical Feast Days in Excel          
   LOCAL dEaster      := CTOD(""),;
         dGFriday     := CTOD(""),;
         dMThursday   := CTOD(""),;
         adFeastDays_ := {},;
         xx
   
   LOCAL pBarCounter := 0        // variable to update progress bar
          
   PRIVATE aHolidays_   := {}    // array to hold all regular holidays. The values are built on fly.
                                 // needed to be private to read it's contents anywhere on this source code.
   
   BEGIN SEQUENCE
   
   frmGregCivil.pBarCalendar.Show
   frmGregCivil.lblFormat.Show 
   
   * do some validation routine againts the entered information  
   DO CASE
      CASE frmGregCivil.txbYear.Value = 0
         MSGSTOP( "No year has been specified.","Try again" )
         frmGregCivil.txbYear.Setfocus
         BREAK
      
      CASE frmGregCivil.txbYear.Value < 1582
         IF .NOT. ChkYear1582(frmGregCivil.txbYear.Value)
            frmGregCivil.txbYear.Setfocus
            BREAK
         ENDIF
   ENDCASE
   
   IF .NOT. frmGregCivil.chkCivilNormal.Value
      MSGSTOP("Please put a check or thick mark on Civil Calendar (includes Regular Holidays)", "Try again!")
      frmGregCivil.chkCivilNormal.Setfocus
      BREAK
   ENDIF
 
   BeginOfYear := CTOD("01/01/" + ALLTRIM(STR(nYear)))
   EndOfYear   := CTOD("12/31/" + ALLTRIM(STR(nYear)))
   
   BaseDate := BeginOfYear
   
   *- make a character year to be used as calendar title 
   cYear := SUBSTR(ALLTRIM(STR(YEAR(EndOfYear))),1,1) + " " +;
            SUBSTR(ALLTRIM(STR(YEAR(EndOfYear))),2,1) + " " +;
            SUBSTR(ALLTRIM(STR(YEAR(EndOfYear))),3,1) + " " +;
            SUBSTR(ALLTRIM(STR(YEAR(EndOfYear))),4,1)
    
   *- calculate Easter Sunday
   dEaster    := EASTER(nYear)
   dGFriday   := dEaster - 2
   dMThursday := dEaster - 3
   ChristmasDay := CTOD( "12/25/" + ALLTRIM( STR( nYear ) ) )

   **- Build the list of Philippines Regular Holidays and Holiday descriptions
   **- accounting for EDSA revolution in 1986
   IF nYear < 1986
      aHolidays_ := { CTOD( "01/01/" + ALLTRIM( STR( nYear ) ) ),;  // New Year'S Day
                      CTOD( "04/09/" + ALLTRIM( STR( nYear ) ) ),;  // Bataan Day
                      CTOD( "05/01/" + ALLTRIM( STR( nYear ) ) ),;  // Labor Day
                      CTOD( "05/06/" + ALLTRIM( STR( nYear ) ) ),;  // Araw ng Kagitingan
                      CTOD( "06/12/" + ALLTRIM( STR( nYear ) ) ),;  // Independence Day
                      CTOD( "08/27/" + ALLTRIM( STR( nYear ) ) ),;  // National Heroes Day
                      CTOD( "11/01/" + ALLTRIM( STR( nYear ) ) ),;  // All Saints Day
                      CTOD( "11/30/" + ALLTRIM( STR( nYear ) ) ),;  // Bonifacio Day
                      CTOD( "12/25/" + ALLTRIM( STR( nYear ) ) ),;  // Christmas Day
                      CTOD( "12/30/" + ALLTRIM( STR( nYear ) ) ) ;  // Rizal Day
                    }
                 
      *--> define holiday descriptions
      acHolidayDesc_ := { "New Year's Day",;
                          "Bataan Day",;
                          "Labor Day",;
                          "Araw ng Kagitingan",;
                          "Independence Day",;
                          "National Heroes Day",;
                          "All Saints Day",;
                          "Bonifacio Day",;
                          "Christmas Day",;
                          "Rizal Day",;
                          "Easter Sunday",;
                          "Good Friday",;
                          "Mundy Thursday"}
   
   ELSE
      aHolidays_ := { CTOD( "01/01/" + ALLTRIM( STR( nYear ) ) ),;  // New Year'S Day
                      CTOD( "02/25/" + ALLTRIM( STR( nYear ) ) ),;  // Edsa Revolution
                      CTOD( "04/09/" + ALLTRIM( STR( nYear ) ) ),;  // Bataan Day
                      CTOD( "05/01/" + ALLTRIM( STR( nYear ) ) ),;  // Labor Day
                      CTOD( "05/06/" + ALLTRIM( STR( nYear ) ) ),;  // Araw ng Kagitingan
                      CTOD( "06/12/" + ALLTRIM( STR( nYear ) ) ),;  // Independence Day
                      CTOD( "08/27/" + ALLTRIM( STR( nYear ) ) ),;  // National Heroes Day
                      CTOD( "11/01/" + ALLTRIM( STR( nYear ) ) ),;  // All Saints Day
                      CTOD( "11/30/" + ALLTRIM( STR( nYear ) ) ),;  // Bonifacio Day
                      CTOD( "12/25/" + ALLTRIM( STR( nYear ) ) ),;  // Christmas Day
                      CTOD( "12/30/" + ALLTRIM( STR( nYear ) ) ) ;  // Rizal Day
                    }
                 
      *--> define holiday descriptions
      acHolidayDesc_ := { "New Year's Day",;
                          "Edsa Revolution",;
                          "Bataan Day",;
                          "Labor Day",;
                          "Araw ng Kagitingan",;
                          "Independence Day",;
                          "National Heroes Day",;
                          "All Saints Day",;
                          "Bonifacio Day",;
                          "Christmas Day",;
                          "Rizal Day",;
                          "Easter Sunday",;
                          "Good Friday",;
                          "Mundy Thursday"}
   ENDIF    

   AADD( aHolidays_, dEaster )
   AADD( aHolidays_, dGFriday )
   AADD( aHolidays_, dMThursday )
   
   ///////////////////////////////////////////////////////////////////////////
   // Calculate Pre-Vatican II Feast Days Related to Easter assembled into  //
   // code blocks confined in an array.                                     //
   ///////////////////////////////////////////////////////////////////////////
   adFeastDays_ := {;
                     {| SolemnityofMary | CTOD( "1/1/"   + ALLTRIM( STR( nYear ) ) ) },;          // January 1
                     {| Septuagesima  | dEaster - 63 },;                                          // 3rd Sunday before Lent  or 9th Sunday            
                     {| Quinquagesima | dEaster - 49 },;                                          // The Sunday before Ash Wednesday beginning of Lent
                     {| PresentationoftheLord  | CTOD( "2/2/"   + ALLTRIM( STR( nYear ) ) ) },;   // February 2
                     {| AshWednesday  | dEaster - 46 },;                                          // 7th Wednesday before Easter, first day of Lent   
                     ;                                                                            // the day following the Mardi Gras (Fat Tuesday)   
                     ;                                                                            // and the day of fasting and repentance. 
                     {| TheAnnunciation        | CTOD( "3/25/"  + ALLTRIM( STR( nYear ) ) ) },;   // 25 March          
                     {| PalmSunday | dEaster - 7 },;                                              // Sunday before Easter 
                     {| dMThursday | dEaster - 3 },;
                     {| dGFriday   | dEaster -2  },;
                     {||  dEaster  },;
                     {| RogationSunday | dEaster + 35 },;                                         // Solemn supplication ceremony prescribed by Church
                     {| Ascension  | dEaster + 39 },;                                             // Ascencion of Christ into heaven, observed on the 
                     ;                                                                            // 40th day after Easter.                           
                     {| Pentecost | dEaster + 49 },;                                              // 7th Sunday after Easter; commemorates the        
                     ;                                                                            // emanation of the Holy Spirit to the Apostles;    
                     ;                                                                            // Jewish: 6th of Sivan to celebrate Moses receiving
                     ;                                                                            // the Ten Commandments;                            
                     ;                                                                            // Scotland: Quarter day                            
                     {| TrinitySunday |  dEaster + 56 },;                                         // 8th Sunday after Easter                          
                     {| CorpusChristi |  dEaster + 60 },;                                         // Thursday after Trinity Sunday; first celebrated  
                     ;                                                                            // in the year 1246 AD.                             
                     {| TransfigurationofJesus | CTOD( "8/6/"   + ALLTRIM( STR( nYear ) ) ) },;   // August 6
                     {| TheAssumptionofMary    | CTOD( "8/15/"  + ALLTRIM( STR( nYear ) ) ) },;   // August 15
                     {| BirthofVirginMary      | CTOD( "9/8/"   + ALLTRIM( STR( nYear ) ) ) },;   // September 8
                     {| Santacruzan            | CTOD( "9/14/"  + ALLTRIM( STR( nYear ) ) ) },;   // September 14 (To commemorate St. Helena's quest for the Cross of Calvary)   
                     {| CelebrationofHolyCross | CTOD( "9/18/"  + ALLTRIM( STR( nYear ) ) ) },;   // September 18
                     {| TheMassoftheArchangels | CTOD( "9/29/"  + ALLTRIM( STR( nYear ) ) ) },;   // September 29
                     {| AllSaintsDay           | CTOD( "11/1/"  + ALLTRIM( STR( nYear ) ) ) },;   // November 1
                     {| AllSoulsDay            | CTOD( "11/2/"  + ALLTRIM( STR( nYear ) ) ) },;   // November 2
                     ; 
                     {|| FindSunday( CTOD( "11/20/" + ALLTRIM( STR( nYear ) ) ) ) },;             // Christ the King, Sunday on or After November 20
                     ;//
                     ;// * Find or calculate the Sundays of Advent
                     {|| FindSunday( CTOD( "11/27/" + ALLTRIM( STR( nYear ) ) ) ) },;             // First Sunday of Advent on or after November 27
                     {|| FindSunday( CTOD( "12/4/"  + ALLTRIM( STR( nYear ) ) ) ) },;             // Second Sunday of Advent on or After December 4
                     {|| FindSunday( CTOD( "12/11/" + ALLTRIM( STR( nYear ) ) ) ) },;             // Third Sunday of Advent on or after December 11
                     {|| FindSunday( CTOD( "12/18/" + ALLTRIM( STR( nYear ) ) ) ) },;             // Fourth Sunday of Advent on or after December 18
                     {| ChristmasDay           | CTOD( "12/25/" + ALLTRIM( STR( nYear ) ) ) },;   // December 25
                     {| Epiphany1 | ChristmasDay + 12 },;                                         // 12 days after Christmas - Traditional Ephiphany Three Kings
                     {|| EpiphanySunday(ChristmasDay) } }                                         // 2nd Sunday after Christmas
                      
    
   acFeastDays_ := { "Solemnity of Mary",;
                     "Septuagesima",;
                     "Quinquagesima",;
                     "Presentation of the Lord",;
                     "Ash Wednesday",;
                     "The Annunciation",;
                     "Palm Sunday",;
                     "Mundy Thursday",;
                     "Good Friday",;
                     "Easter Sunday",;
                     "Rogation Sunday",;
                     "Ascension",;
                     "Pentecost",;
                     "Trinity Sunday",;
                     "Corpus Christi",;
                     "Transfiguration of Jesus",;
                     "The Assumption of Mary",;
                     "Birth of Virgin Mary",;
                     "Santacruzan",;
                     "Celebration of Holy Cross",;
                     "The Mass of the Archangels",;
                     "All Saints Day",;
                     "All Souls Day",;
                     "Christ The King",;
                     "First Sunday of Advent",;
                     "Second Sunday of Advent",;
                     "Third Sunday of Advent",;
                     "Fourth Sunday of Advent",;
                     "Christmas Day",;
                     "Epiphany (Traditional - Three Kings)",;
                     "Epiphany - 2nd Sunday after Christmas" }
    
    
    
   oExcel := CreateObject("Excel.Application")	// Open Microsoft Excel
   oExcel:Workbooks:Add()						      // Add a Workbook
   nSheets := oExcel:Sheets:Count()					// Get the number of sheets contained in the Workbook
   oExcel:DisplayAlerts := .F.						// Force Excel to work in background
   
   ////////////////////////////////////////////////////////
   //- step #1 delete other empty sheets if there is any //
   ////////////////////////////////////////////////////////
   FOR xCounter = 1 TO nSheets - 1
     oExcel:Worksheets(xCounter):Delete()
   NEXT
   
   oSheet := oExcel:ActiveSheet()         // select the actual worksheet
   oSheet:Name := cYear                   // set name of the excel sheet in the bottom tab
    
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // -step #2 set standard fonts for all cells, change row height and column width. Center everything.  //
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   oSheet:Cells:Font:Name := "Arial"
   oSheet:Cells:Font:Size := 10
   oSheet:Cells:RowHeight := 20
   oSheet:Cells:ColumnWidth := 4
   oSheet:Cells:HorizontalAlignment := xlCenter
   oSheet:Cells:VerticalAlignment := xlCenter  
    
    
   EndDate := BaseDate
   CurrentMonth := 13  
   DO WHILE EndDate <= EndOfYear
    
        *- write out the column headings if month is not the same
        IF CurrentMonth <> MONTH(EndDate)
        
            *---> put borders around the monthly calendars
            IF BorderSwitch = 0
                BorderSwitch++
            ELSE
                IF ColSwitch = 0
                    cRange := "A" + ALLTRIM(STR(BorderTop)) + ":" + "G" + ALLTRIM(STR(nRow))
                ELSE
                    cRange := "I" + ALLTRIM(STR(BorderTop)) + ":" + "O" + ALLTRIM(STR(nRow))
                ENDIF
                oSelection := oSheet:Range(cRange)
                oSelection:Borders:Weight := xlThin
            ENDIF
            
            *----> Month heading controls, counters and switches
            IF MONTH(EndDate) > 6
                ForLoopStart := LEN(aGregorianColumn_) + 2
                ForLoopEnd   := LEN(aGregorianColumn_) * 2 + 1
                ColSwitch    := 1
            ELSE
                ForLoopStart := 1
                ForLoopEnd   := LEN(aGregorianColumn_)
                ColSwitch    := 0
            ENDIF
        
            *---> Row counter and reset logic to display the calendar in second set
            IF ColSwitch = 1 .AND. RowReset = .T.
                RowReset := .F.
                nRow     := 1
            ENDIF          
        
            nRow +=2
            
            IF ColSwitch = 0
                nColumn := 1
                cRange := "A" + ALLTRIM(STR(nRow)) + ":" + "G" + ALLTRIM(STR(nRow))
            ELSE
                nColumn := LEN(aGregorianColumn_) + 2
                cRange := "I" + ALLTRIM(STR(nRow)) + ":" + "O" + ALLTRIM(STR(nRow))
            ENDIF
            
            *--> step #3 write out the month name, centered, black background and white foreground
            oSheet:Cells(nRow, nColumn):Value := acMonths_[MONTH(EndDate)]
            oSheet:Cells(nRow, nColumn):Font:Size := 14
            oSheet:Cells(nRow, nColumn):Font:Bold := .T.
            
            oSelection := oSheet:Range(cRange)          // define cell range
            oSelection:MergeCells := .T.                // and merge the month name and center it
            
            oSelection:Interior:ColorIndex := 1
            oSelection:Font:ColorIndex := 2
                    
            nRow++
            
            FOR xCounter := ForLoopStart TO ForLoopEnd
            
                IF ColSwitch = 0
                    nArrayIndex := xCounter
                ELSE
                    nArrayIndex := (xCounter - (LEN(aGregorianColumn_) + 1))
                ENDIF
            
                oSheet:Cells(nRow, nColumn):Value := aGregorianColumn_[nArrayIndex]
                oSheet:Cells(nRow, nColumn):Font:Bold := .T.
               
                nColumn++
            NEXT        
            
            *---> change Day Names background and foreground to match the month names and year
            IF ColSwitch = 0
                cRange := "A" + ALLTRIM(STR(nRow)) + ":" + "G" + ALLTRIM(STR(nRow))
            ELSE
                cRange := "I" + ALLTRIM(STR(nRow)) + ":" + "O" + ALLTRIM(STR(nRow))
            ENDIF            
            oSelection := oSheet:Range(cRange)      // define cell range
            oSelection:Interior:ColorIndex := 1     // set selected range cell backbround to BLACK
            oSelection:Font:ColorIndex := 2         // set selected range cell font color to WHITE           
            
            nRow++
            CurrentMonth := MONTH(EndDate)
            BorderTop := nRow
            
        ENDIF   
    
        IF DOW(EndDate) = 1    // Check for sunday and make it red
           *- make Sunday on red background and fontcolor to white
           cRange := IF(ColSwitch = 0,"A","I") + ALLTRIM(STR(nRow))
           oSelection := oSheet:Range(cRange)
           oSelection:Interior:ColorIndex := 3
           oSelection:Font:ColorIndex := 2  
        ENDIF
      
        *- check EndDate if it falls on Regular Holidays, Sundays are ignored, because it's a Holiday already
        lHolidayBaIto := IsHoliday( EndDate )
      
        IF ColSwitch = 0
            nColumn := DOW(EndDate)
        ELSE
            nColumn := LEN(aGregorianColumn_) + 1 + DOW(EndDate)
        ENDIF        
   
        //////////////////////////////////////////////////
        // Move one Row Below if Sat Column is updated. //
        //////////////////////////////////////////////////
        IF DOW(EndDate) = 7  && Saturday
            oSheet:Cells(nRow,nColumn):Value := DAY(EndDate)
            oSheet:Cells(nRow,nColumn):Font:Bold := .T.
            
            *- set font color to red if the day falls on holiday
            IF .NOT. IsHoliday( EndDate )
               oSheet:Cells(nRow,nColumn):Font:ColorIndex := 3
            ENDIF
            nRow++
        ELSE
            oSheet:Cells(nRow,nColumn):Value := DAY(EndDate)
            oSheet:Cells(nRow,nColumn):Font:Bold := .T.
            IF .NOT. IsHoliday( EndDate ) .AND. DOW( EndDate ) # 1
               oSheet:Cells(nRow,nColumn):Font:ColorIndex := 3
            ENDIF
            
        ENDIF

        EndDate++
        frmGregCivil.pBarCalendar.Value := pBarCounter++

   ENDDO

   *--> Border for the Month of December
   cRange := "I" + ALLTRIM(STR(BorderTop)) + ":" + "O" + ALLTRIM(STR(nRow))
   oSelection := oSheet:Range(cRange)
   oSelection:Borders:Weight := xlThin
   
   *---> write out the main title
   oSheet:Cells(1,1):Value      := "C A L E N D A R  " + cYear    // define title
   oSheet:Cells(1,1):Font:Size  := 16                             // define font size
   oSheet:Cells(1,1):Font:Bold := .T.
   oSelection := oSheet:Range("A1:O1")                            // select title range
   oSelection:MergeCells := .T.                                   // merge cells 
   oSheet:Cells(2,1)                                              // reposition the cursor
   
   *---> write out the regular Holidays   
   nRow := 3
   nColumn := 17
   LoopEnd := LEN( aHolidays_ )
   oSheet:Cells(nRow, nColumn):ColumnWidth := 49
   oSheet:Cells(nRow, nColumn):HorizontalAlignment := xlLeft
   
   oSheet:Cells(nRow, nColumn):Value := "Regular Holidays:"
   oSheet:Cells(nRow, nColumn):Font:ColorIndex := 11
   oSheet:Cells(nRow++, nColumn):Font:Bold := .T.

   FOR LoopStart = 1 TO LoopEnd
      oSheet:Cells(nRow, nColumn):HorizontalAlignment := xlLeft
      oSheet:Cells(nRow, nColumn):Value := "   " + acShortMonthNm_[ MONTH(aHolidays_[LoopStart])] + " " + ALLTRIM( STR( DAY( aHolidays_[ LoopStart ] ) ) ) + " - " + acHolidayDesc_[ LoopStart ]
      oSheet:Cells(nRow++, nColumn):Font:ColorIndex := 11
   NEXT
   
   IF IsLiturgyFeast
      ++nRow
      LoopEnd := LEN( acFeastDays_ )   
      oSheet:Cells(nRow, nColumn):Value := "Liturgical Feast Days:"
      oSheet:Cells(nRow, nColumn):Font:ColorIndex := 11
      oSheet:Cells(nRow, nColumn):Font:Bold := .T.   
      oSheet:Cells(nRow++, nColumn):HorizontalAlignment := xlLeft

      FOR LoopStart = 1 TO LoopEnd
         xx := EVAL(adFeastDays_[LoopStart])
         IF YEAR( xx ) # YEAR( EndOfYear )
            oSheet:Cells(nRow, nColumn):Value := "   " + acShortMonthNm_[ MONTH( xx ) ] +;
                                                 ". " + ALLTRIM( STR( DAY( xx ) ) ) +;
                                                 ", " + ALLTRIM( STR( YEAR( xx ) ) ) +;
                                                 " - " + acFeastDays_[ LoopStart ]
         
         ELSE
            oSheet:Cells(nRow, nColumn):Value := "   " + acShortMonthNm_[ MONTH( xx ) ] +;
                                                 " " + ALLTRIM( STR( DAY( xx ) ) ) +;
                                                 " - " + acFeastDays_[ LoopStart ]
         ENDIF
         oSheet:Cells(nRow, nColumn):HorizontalAlignment := xlLeft
         oSheet:Cells(nRow++, nColumn):Font:ColorIndex := 11
      NEXT
   ENDIF   
   
   
   oWindow := oExcel:ActiveWindow     // Get active Window
   
   oExcel:Visible := .T.   // Show Microsoft Excel Window
   
   *---------------------------- OLE commands Ends Here ---------------------------------------------*
   
   MSGINFO("Calendar has been built for the year requested is completed successfuly.","Calculation Done")
        
   END SEQUENCE
   frmGregCivil.pBarCalendar.Hide
   frmGregCivil.pBarCalendar.Value := 0
   frmGregCivil.lblFormat.Hide
   RETURN NIL



********************************
static function IsHoliday(ThisDate)

   LOCAL lRetVal := ASCAN( aHolidays_, { | x | DTOS( x ) == DTOS( ThisDate ) } )
   RETURN (lRetVal = 0 )
