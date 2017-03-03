/*
   This is the demo program compiled with Clipper 5.2e
*/

#include "inkey.ch"

function Main()
local GetList:={}, cName, cStreet1, cStreet2, cCity, cState, cZipcode

cName:=space(40)
cStreet1:=cStreet2:=cCity:=space(40)
cState:=space(2)
cZipcode:=space(5)

cls

@02,00 say "Enter Name    " get cName picture "@!";
   valid CheckEmpty(cName,"You must enter a name")

@04,00 say "Enter street 1" get cStreet1;
   valid CheckEmpty(cStreet1,"You must enter a street address")

@06,00 say "Enter street 2" get cStreet2

@08,00 say "Enter City    " get cCity picture "@!";
   valid CheckEmpty(cCity,"You must enter a city name")

@10,00 say "Enter state   " get cState picture "@!" valid {|| IfState(cState)}

@12,00 say "Enter zipcode " get cZipcode picture "99999";
   valid CheckEmpty(cZipcode,"You must enter a zipcode")

read

if lastkey() # K_ESC
   alert(alltrim(cName)+";"+alltrim(cStreet1)+";"+;
   alltrim(cStreet2)+iif(!empty(cStreet2),";","")+alltrim(cCity)+" "+cState+"  "+cZipcode)
endif

return(nil)

/****************************************************************************/
static function CheckEmpty(cVar, cMsg)
local lRetVal:=.t.

if empty(cVar)
   alert(cMsg)
   lRetVal:=.f.
endif

return(lRetVal)

/****************************************************************************/
#define STATES_ARRAY { "AK = Alaska","AL = Alabama","AR = Arkansas","AZ = Arizona",;
   "CA = California","CO = Colorado","CT = Connecticut","DC = Dist. of Col.",;
   "DE = Delaware","FL = Florida","GA = Georgia","HI = Hawaii","IA = Iowa",;
   "ID = Idaho","IL = Illinois","IN = Indiana","KS = Kansas","KY = Kentucky",;
   "LA = Louisiana","MA = Massachusetts","MD = Maryland","ME = Maine","MI = Michigan",;
   "MN = Minnesota","MO = Missouri","MS = Mississippi","MT = Montana","NE = Nebraska",;
   "NC = North Carolina","ND = North Dakota","NH = New Hampshire","NJ = New Jersey",;
   "NM = New Mexico","NV = Nevada","NY = New York","OH = Ohio","OK = Oklahoma",;
   "OR = Oregon","PA = Pennsylvania","PR = Puerto Rico","RI = Rhode Island",;
   "SC = South Carolina","SD = South Dakota","TN = Tennessee","TX = Texas",;
   "UT = Utah","VA = Virginia","VT = Vermont","WA = Washington","WI = Wisconsin",;
   "WV = West Virginia","WY = Wyoming"}

static function IfState(cState)

LOCAL lExact,nPosition
lExact:=SET(_SET_EXACT,.F.)
nPosition:=ASCAN(STATES_ARRAY,UPPER(cState)) // STATES_ARRAY is a #define
SET(_SET_EXACT,lExact)
IF nPosition=0
   ALERT("Invalid State Abbreviation.")
ENDIF

RETURN( nPosition>0 )

/****************************************************************************/
