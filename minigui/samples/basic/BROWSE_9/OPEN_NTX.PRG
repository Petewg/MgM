*:**************************
*: Program OPEN_NTX.PRG 
*:**************************
PROCEDURE open_ntx 

if ! file ("EMPLOYE.ntx")
   use EMPLOYE
   index on FIELD->CLI_ID to EMPLOYE
   use 
endif

if ! file ("EMPLOYEC.ntx")
   use EMPLOYE
   index on FIELD->CLI_CITY to EMPLOYEC
   use 
endif

RETURN
