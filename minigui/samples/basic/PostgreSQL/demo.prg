/*
 
  Postgress console sample for Harbour/MiniGUI
  2011-05-06 by Mitja Podgornik

  Console version only: compile with: /PG /C /NX

 */


#include "common.ch"

static oServer

*-------------------------------------------------*
function main( cHost, cBase, cUser, cPass, cPort )
*-------------------------------------------------*
local oQuery, cQuery, oRow, i

set century on
set date german

if pcount() < 4
  ? "Use: test <Host> <Database> <User> <Password> [port]"
  return -1
endif

oServer := TPQServer():New( cHost, cBase, cUser, cPass, iif(cPort==nil, 5432, val(cPort)) )
if oServer:NetErr()
  ? oServer:ErrorMsg()
  return -2
endif

oServer:SetVerbosity(2)

if oServer:TableExists( "simple2" )

   ? oQuery := oServer:Execute( "DROP TABLE simple2" )
   if oQuery:neterr()
     oServer:Destroy()
     return -3
   endif

   oQuery:Destroy()

endif

? "Creating table: "+cBase+"."+"simple2 ..."

cQuery := "CREATE TABLE simple2 ("
cQuery += " id integer not null, "
cQuery += " name Char(40), "
cQuery += " age Integer, "
cQuery += " weight Float4, "
cQuery += " budget Numeric(12,2), "
cQuery += " birth Date ) "

oQuery := oServer:Query( cQuery )
if oQuery:neterr()
   ? oQuery:ErrorMsg()
   oServer:Destroy()
   return -3
endif

oQuery:Destroy()

? "Inserting with declared transaction control ..."

oServer:StartTransaction()

for i:=1 to 10

   cQuery := "INSERT INTO simple2 (id, name, age, weight, budget, birth) "+;
              "VALUES ( " + ntrim(i) + ", 'Jon Doe', "+ntrim(i*2)+", "+ntrim(12.34*i, 2)+", "+ntrim(123.56*i, 2)+", '"+d2pg(date()+i)+"')"

   oQuery := oServer:Query( cQuery )
   if oQuery:neterr()
     ? oQuery:errorMsg()
     oServer:Destroy()
     return -3
   endif

   oQuery:destroy()

next

oServer:Commit()

? "Retreiving data ..."

oQuery := oServer:Query( "SELECT id, name, age, weight, budget, birth FROM simple2" )
if oQuery:neterr()
  ? oQuery:errorMsg()
  oServer:Destroy()
  return -3
endif

if oQuery:Lastrec() > 0

  for i:=1 to oQuery:Lastrec()

   oRow := oQuery:getrow(i)

   ? ntrim(oRow:Fieldget(1))   +","+;
     alltrim(oRow:Fieldget(2)) +","+;
     ntrim(oRow:Fieldget(3))   +","+;
     ntrim(oRow:Fieldget(4),2) +","+;
     ntrim(oRow:Fieldget(5),2) +","+;
     dtoc(oRow:Fieldget(6))

  next

endif

oQuery:Destroy()

? "Closing..."
oServer:Destroy()

return 0



*-------------------*
function d2pg(dDate)
*-------------------*
return strzero(year(dDate),4)+"-"+strzero(month(dDate),2)+"-"+strzero(day(dDate),2)



*-------------------------*
function ntrim(nVal, nDec)
*-------------------------*
return iif(nVal==0, "0", alltrim(str(nVal, 20, iif(nDec==nil, 0, nDec))))






