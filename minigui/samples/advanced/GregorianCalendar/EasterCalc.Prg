/***********************************************************************************
*  Purpose: Find the Easter Sunday date after year AD 1582.
*           Optionaly displays the Feast Related to Easter.
*
*  Well this is how the Gregorian Calendar is built. It is centered on Easter Sunday.
*  
*  The Algorithm:
*  It is a simple Integral Calculation for which all decimals is drop.
*  
*  You can do whatever you want with this code, even if you modify it into something more
*  useful or if you are curious enough to find that the cycle of Gregorian Calendar is 
*  every 400 years. I bet you already you knew it. So the date for every month for year 
*  2008 will repeat again on 2408 except the holidays date and Easter Date.
*  
*  Note: Calculation of Easter Sunday beyond 4th millenium will not be accurate
*        because Solar Days and Calendar Days is not exactly equal. So by that time
*        the errors is accumulated.
*  
*  
*  Developed under Harbour + MiniGUI by Roberto Lopez
*  
*  Thanks,
*
*  Danny del Pilar
*  Manila, Philippines
*  dhaine_adp@yahoo.com
*
************************************************************************************/




#include "minigui.ch"


*********************
function Main1()

   IF ISWINDOWDEFINED(frmEasterCalc)
      DOMETHOD("frmEasterCalc","Setfocus")
      RETURN NIL
   ENDIF

   SET NAVIGATION STANDARD
   DEFINE WINDOW frmEasterCalc;
      AT 0,0;
      WIDTH 378 HEIGHT 135;
      TITLE "Easter Sunday Calculator";
      MAIN ICON NIL;
      NOMAXIMIZE;
      FONT "Arial" SIZE 9
         
      ON KEY RETURN ACTION BtnOk()         
         
      @  32, 30 LABEL lblYear OF frmEasterCalc VALUE "Enter Gregorian Year after 1582 AD"; 
         ACTION Nil WIDTH  200 HEIGHT 20 FONT "Arial" SIZE 9
         
      @  29,230 TEXTBOX txbYear OF frmEasterCalc HEIGHT 24 VALUE "0"; 
          WIDTH 100 NUMERIC INPUTMASK "9999"
          
      @  10, 20 FRAME Frame_1 OF frmEasterCalc CAPTION "Please enter the year in 4 digit Century format"; 
         WIDTH  340 HEIGHT 55 FONT "Arial" SIZE 9 BACKCOLOR NIL FONTCOLOR NIL OPAQUE
         
      @  70, 90 BUTTON btnOk OF frmEasterCalc CAPTION "&Ok" ACTION BtnOk() FONT "Arial" SIZE 9
         
      @  70,190 BUTTON btnCancel OF frmEasterCalc CAPTION "&Cancel" ACTION frmEasterCalc.Release FONT "Arial" SIZE 9
         
   END WINDOW
   frmEasterCalc.Center
   frmEasterCalc.Activate
   RETURN NIL


************************
static function BtnOk()

   LOCAL nYear := frmEasterCalc.txbYear.Value
   
   IF LEN( ALLTRIM( STR( nYear ) ) ) < 4
      nYear := 1970
   ENDIF
   Easter( nYear, .T. )     // Call Easter Calculator engine and display result
   RETURN NIL





****************************************
function Easter(nYear,lDispResult)

   **---------------------- Start of Variable declaration for Easter Sunday Calculation -----------------------*
   LOCAL nCentury     := 0
   LOCAL nLeapDrop    := 0
   LOCAL nCorrection  := 0
   LOCAL nSunMoon     := 0
   LOCAL nLunarCycle  := 0
   LOCAL nEccFullMoon := 0
   LOCAL nMonth       := 0
   LOCAL nDay         := 0

   LOCAL dEasterSunday
   LOCAL acMessage    := {}
   **---------------------- Variable declaration for Easter Sunday Calculation End's here ---------------------*
   
   **---------------------- Other Dates associated with Easter Sunday -----------------------------------------*
   LOCAL ChristmasDay             
   LOCAL SolemnityofMary          
   LOCAL PresentationoftheLord    
   LOCAL TheAnnunciation          
   LOCAL TransfigurationofJesus   
   LOCAL TheAssumptionofMary      
   LOCAL BirthofVirginMary        
   LOCAL CelebrationofHolyCross   
   LOCAL TheMassoftheArchangels   
   LOCAL AllSaintsDay             
   LOCAL AllSoulsDay              
      
   LOCAL ChristtheKing   
   LOCAL FirstAdvent     
   LOCAL SecondAdvent    
   LOCAL ThirdAdvent     
   LOCAL FourthAdvent    
   LOCAL Epiphany1       
   LOCAL Epiphany2       
   **---------------------- End of other Dates associated with Easter Sunday ----------------------------------*   
   
   LOCAL Septuagesima
   LOCAL Quinquagesima
   LOCAL AshWednesday
   LOCAL PalmSunday
   LOCAL GoodFriday
   LOCAL RogationSunday
   LOCAL Ascension
   LOCAL Pentecost
   LOCAL TrinitySunday
   LOCAL CorpusChristi
   
   DEFAULT lDispResult TO .F.   
   
   **---------------------- Easter Calculation -----------------------------------------------------------------*
   
   nCentury     := INT( nYear / 100 )
   nLeapDrop    := nYear - 19 * INT( ( nYear / 19 ) )
   nCorrection  := INT( ( nCentury - 17 ) / 25 )
   nSunMoon     := nCentury - INT( nCentury / 4 ) - INT( ( nCentury - nCorrection ) / 3 ) + 19 * nLeapDrop + 15 
   nSunMoon     := nSunMoon - 30 * INT( ( nSunMoon / 30 ) )
   
   nSunMoon     := nSunMoon - INT( ( nSunMoon / 28 ) ) *;
                      ( 1 - INT( ( nSunMoon / 28 ) ) *;
                      ( INT( 29 / ( nSunMoon + 1 ) ) ) *;
                      ( INT( ( 21 - nLeapDrop ) / 11 ) ) )
                      
   nLunarCycle  := nYear + INT( nYear / 4 ) + nSunMoon + 2 - nCentury + INT( nCentury / 4 )
   nLunarCycle  := nLunarCycle - 7 * INT( ( nLunarCycle / 7 ) )
   nEccFullMoon := nSunMoon - nLunarCycle
   nMonth       := 3 + INT( ( nEccFullMoon + 40 ) / 44 )
   nDay         := nEccFullMoon + 28 - 31 * INT( ( nMonth / 4 ) )

   ** Easter Sunday
   dEasterSunday := CTOD( ALLTRIM( STR( nMonth ) ) + "/" + ALLTRIM( STR( nDay ) ) + "/" + ALLTRIM( STR( nYear ) ) )

   **--------------------- Easter Calculation Ends here ---------------------------------------------------------*


   **--------------------- Easter related date events -----------------------------------------------------------*
   //////////////////////////////////////////
   // Pre-Vatican II Feast Related to Easter//
   //////////////////////////////////////////
   Septuagesima    := dEasterSunday - 63  // 3rd Sunday before Lent  or 9th Sunday            
   Quinquagesima   := dEasterSunday - 49  // The Sunday before Ash Wednesday beginning of Lent
   AshWednesday    := dEasterSunday - 46  // 7th Wednesday before Easter, first day of Lent   
                                          // the day following the Mardi Gras (Fat Tuesday)   
                                          // and the day of fasting and repentance.           
   PalmSunday      := dEasterSunday - 7   // Sunday before Easter                             
   GoodFriday      := dEasterSunday - 2   // Friday before Easter                             
   RogationSunday  := dEasterSunday + 35  // Solemn supplication ceremony prescribed by Church
   Ascension       := dEasterSunday + 39  // Ascencion of Christ into heaven, observed on the 
                                          // 40th day after Easter.                           
   Pentecost       := dEasterSunday + 49  // 7th Sunday after Easter; commemorates the        
                                          // emanation of the Holy Spirit to the Apostles;    
                                          // Jewish: 6th of Sivan to celebrate Moses receiving
                                          // the Ten Commandments;                            
                                          // Scotland: Quarter day                            
   TrinitySunday   := dEasterSunday + 56  // 8th Sunday after Easter                          
   CorpusChristi   := dEasterSunday + 60  // Thursday after Trinity Sunday; first celebrated  
                                          // in the year 1246 AD.                             

   SolemnityofMary        := CTOD( "1/1/"   + ALLTRIM( STR( nYear ) ) )   // January 1
   PresentationoftheLord  := CTOD( "2/2/"   + ALLTRIM( STR( nYear ) ) )   // February 2
   TheAnnunciation        := CTOD( "3/25/"  + ALLTRIM( STR( nYear ) ) )   // 25 March
   TransfigurationofJesus := CTOD( "8/6/"   + ALLTRIM( STR( nYear ) ) )   // August 6
   TheAssumptionofMary    := CTOD( "8/15/"  + ALLTRIM( STR( nYear ) ) )   // August 15
   BirthofVirginMary      := CTOD( "9/8/"   + ALLTRIM( STR( nYear ) ) )   // September 8
   CelebrationofHolyCross := CTOD( "9/18/"  + ALLTRIM( STR( nYear ) ) )   // September 18
   TheMassoftheArchangels := CTOD( "9/29/"  + ALLTRIM( STR( nYear ) ) )   // September 29
   AllSaintsDay           := CTOD( "11/1/"  + ALLTRIM( STR( nYear ) ) )   // November 1
   AllSoulsDay            := CTOD( "11/2/"  + ALLTRIM( STR( nYear ) ) )   // November 2
   ChristmasDay           := CTOD( "12/25/" + ALLTRIM( STR( nYear ) ) )   // December 25

   ChristtheKing := FindSunday( CTOD( "11/20/" + ALLTRIM( STR( nYear ) ) ) )  // Sunday on or After November 20
   
   * Find or calculate the Sundays of Advent
   FirstAdvent   := FindSunday( CTOD( "11/27/" + ALLTRIM( STR( nYear ) ) ) )   // Sunday on or after November 27
   SecondAdvent  := FindSunday( CTOD( "12/4/"  + ALLTRIM( STR( nYear ) ) ) )   // Sunday on or After December 4
   ThirdAdvent   := FindSunday( CTOD( "12/11/" + ALLTRIM( STR( nYear ) ) ) )   // Sunday on or after December 11
   FourthAdvent  := FindSunday( CTOD( "12/18/" + ALLTRIM( STR( nYear ) ) ) )   // Sunday on or after December 18
   
   Epiphany1     := ChristmasDay + 12   // 12 days after Christmas - Traditional Ephiphany Three Kings
   
   Epiphany2     := EpiphanySunday(ChristmasDay)    // 2nd Sunday after Christmas

   IF lDispResult

      MultiMessage( { "Septuagesima: "    + CDOW( Septuagesima )   + ", " + DTOC( Septuagesima )   ,;
                      " ",;
                      "Quinquagesima: "   + CDOW( Quinquagesima )  + ", " + DTOC( Quinquagesima )  ,;
                      " ",;
                      "Ash Wednesday: "   + CDOW( AshWednesday )   + ", " + DTOC( AshWednesday )   ,;
                      " ",;
                      "Palm Sunday: "     + CDOW( PalmSunday )     + ", " + DTOC( PalmSunday )     ,;
                      " ",;
                      "Good Friday: "     + CDOW( GoodFriday )     + ", " + DTOC( GoodFriday )     ,;
                      " ",;
                      "Easter Sunday: "   + CDOW( dEasterSunday )  + ", " + DTOC( dEasterSunday )  ,;
                      " ",;
                      "Rogation Sunday: " + CDOW( RogationSunday ) + ", " + DTOC( RogationSunday ) ,;
                      " ",;
                      "Ascension: "       + CDOW( Ascension )      + ", " + DTOC( Ascension )      ,;
                      " ",;
                      "Pentecost: "       + CDOW( Pentecost )      + ", " + DTOC( Pentecost )      ,;
                      " ",;
                      "Trinity Sunday: "  + CDOW( TrinitySunday )  + ", " + DTOC( TrinitySunday )  ,;
                      " ",;
                      "Corpus Christi: "  + CDOW( CorpusChristi )  + ", " + DTOC( CorpusChristi )  ,;
                      " ",;
                      "Solemnity of Mary : " + CDOW( SolemnityofMary ) + ", " + DTOC( SolemnityofMary ),;
                      " ",;
                      "Presentation of the Lord : " + CDOW( PresentationoftheLord ) + ", " + DTOC( PresentationoftheLord ) ,;
                      " ",;
                      "The Annunciation : " + CDOW( TheAnnunciation ) + ", " + DTOC( TheAnnunciation ),;
                      " ",;
                      "Transfiguration of Jesus : " + CDOW( TransfigurationofJesus ) + ", " + DTOC( TransfigurationofJesus ),;
                      " ",;
                      "The Assumption of Mary : " + CDOW( TheAssumptionofMary ) + ", " + DTOC( TheAssumptionofMary ),;
                      " ",;
                      "Birth of Virgin Mary : " + CDOW( BirthofVirginMary ) + ", " + DTOC( BirthofVirginMary ),; 
                      " ",;
                      "Celebration of Holy Cross : " + CDOW( CelebrationofHolyCross ) + ", " + DTOC( CelebrationofHolyCross ) ,;
                      " ",;
                      "The Mass of the Archangels : " + CDOW( TheMassoftheArchangels ) + ", " + DTOC( TheMassoftheArchangels ),;
                      " ",;
                      "All Saints Day : " + CDOW( AllSaintsDay ) + ", " + DTOC( AllSaintsDay ),;
                      " ",;
                      "All Souls Day : " + CDOW( AllSoulsDay ) + ", " + DTOC( AllSoulsDay ),;
                      " ",;
                      "Christ The King : " + CDOW( ChristtheKing ) + ", " + DTOC( ChristtheKing ),;
                      " ",;
                      "First Sunday of Advent : " + CDOW( FirstAdvent ) + ", " + DTOC( FirstAdvent ),;
                      " ",;
                      "Second Sunday of Advent : " + CDOW( SecondAdvent ) + ", " + DTOC( SecondAdvent ),;
                      " ",;
                      "Third Sunday of Advent : " + CDOW( ThirdAdvent ) + ", " + DTOC( ThirdAdvent ),;
                      " ",;
                      "Fourth Sunday of Advent : " + CDOW( FourthAdvent ) + ", " + DTOC( FourthAdvent ),;
                      " ",;
                      "Christmas Day : " + CDOW( ChristmasDay ) + ", " + DTOC( ChristmasDay ),;
                      " ",;
                      "Epiphany (Traditional - Three Kings) : " + CDOW( Epiphany1 ) + ", " + DTOC( Epiphany1 ),;
                      " ",;
                      "Epiphany - 2nd Sunday after Christmas : " + CDOW( Epiphany2 ) + ", " + DTOC( Epiphany2 ) },;
                      "Church Holiday for the Year " + ALLTRIM( STR( nYear ) ) )   
   ENDIF

   RETURN dEasterSunday




**************************
function FindSunday(dDate)

   LOCAL Sunday := CTOD("")

   IF UPPER( CDOW( dDate ) ) == "SUNDAY"
      Sunday := dDate
   ELSE
      DO WHILE .t.
         ++dDate
         IF UPPER( CDOW( dDate ) ) == "SUNDAY"
            Sunday := dDate
            EXIT
         ENDIF
      ENDDO
   ENDIF
   RETURN Sunday




********************************
function EpiphanySunday(dDate)

   LOCAL Sunday := CTOD("")
   LOCAL Counter := 0

   WHILE .T.
      ++dDate
      IF UPPER( CDOW( dDate ) ) == "SUNDAY"
         ++Counter
         IF Counter > 2
            Sunday := dDate
            EXIT
         ENDIF
      ENDIF
   END
   RETURN Sunday




*********************************************************
// MULTI-MESSAGE CONTRIBUTION taken from HMG Community //
*********************************************************

#define NTrim( n ) LTRIM( STR( n, IF( n == INT( n ), 0, 2 ) ))
********************************************************************************
function Convert2String( xParam )

   LOCAL cRetVal := ""
   LOCAL nType  :=  0
   LOCAL aCases_ := { { "A", { | x | "{...}" } },;                
                      { "B", { | x | "{||}" } },;                
                      { "C", { | x | x }},;
                      { "M", { | x | x   } },;                   
                      { "D", { | x | DTOC( x ) } },;             
                      { "L", { | x | IF( x,"On","Off") } },;    
                      { "N", { | x | NTrim( x )  } },;
                      { "O", { | x | ":Object:" } },;
                      { "U", { | x | "<NIL>" } } }
                    
   IF (nType := ASCAN( aCases_, { | a1 | VALTYPE( xParam ) == a1[ 1 ] } ) ) > 0
      cRetVal := EVAL( aCases_[ nType, 2 ], xParam )
   ENDIF    
   RETURN cRetVal


********************************************************************************
procedure MultiMessage(xMessage, cTitle)

   LOCAL cMessage := ""
    
   IF xMessage # NIL
   
      IF cTitle == NIL
         cTitle := PROCNAME(1) + "\" +   NTrim( PROCLINE(1) ) 
      ENDIF
      
      IF VALTYPE( xMessage  ) # "A"
         xMessage := { xMessage }
      ENDIF
      
      AEVAL( xMessage, { | x1 | cMessage +=  Convert2String( x1 ) + HB_OSNEWLINE() } )
      
      MsgInfo( cMessage, cTitle )
      
   ENDIF
   RETURN


