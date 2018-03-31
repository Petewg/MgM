/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Program : Test03.prg
 * Purpose : TData class test showing how to create an index of a database with a progress meter.
*/

#include "hmg.ch"

function main
   local oDB

   SET WINDOW MAIN OFF

   // setup test.dbf
   dbcreate('test',{{'FLD1',"+",8,0}})
   use test
   while lastrec() < 100000
      append blank
   end
   use

   oDB:=tdata():new(,"test")
   if oDB:use()
      oDB:createIndex("test",,"fld1",,,.t.,5)
   endif
   oDB:close()

return nil
