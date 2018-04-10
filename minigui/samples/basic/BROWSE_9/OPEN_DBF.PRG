*:***********************
*: Program OPEN_DBF.PRG 
*:***********************
PROCEDURE open_dbf

LOCAL alist_fld

if ! file ("EMPLOYE.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"CLI_ID","N",5,0})
   aadd(alist_fld,{"CLI_SNAM","C",12,0})
   aadd(alist_fld,{"CLI_NAME","C",12,0})
   aadd(alist_fld,{"CLI_TLF","C",11,0})
   aadd(alist_fld,{"CLI_DAYS","N",2,0})
   aadd(alist_fld,{"CLI_WAGE","N",4,2})
   aadd(alist_fld,{"CLI_BDATE","D",8,0})
   aadd(alist_fld,{"CLI_HDATE","D",8,0})
   aadd(alist_fld,{"CLI_SALARY","N",8,2})
   aadd(alist_fld,{"CLI_CITY","C",10,0})
   dbcreate("EMPLOYE",alist_fld)
endif

RETURN 
