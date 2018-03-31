#include "minigui.ch"
#include "Dbstruct.ch"

MEMVAR met

Function Main
   Local aColor := { || if ( rEven() == .F. , RGB( 0, 0, 0 ) , RGB( 255, 0, 0 ) ) }
   Local rfi1 := { 'Test->Code','Test->First', 'Test->Last' , 'Test->Birth', 'Test->Balance' }
   Local rfi2 := { 'Test1->Code' , 'Test1->Sum1' , 'Test1->Sum2' , 'Test1->Sum3' }

   Public met:={}

   SET DELETED ON
   SET BROWSESYNC ON

   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Form_1;
      AT 0,0;
      WIDTH 880;
      HEIGHT 450;
      TITLE 'MiniGUI Browse test';
      MAIN NOMAXIMIZE NOSIZE;
      ON INIT OpenTables();
      ON RELEASE dbcloseall()

      DEFINE STATUSBAR
      STATUSITEM 'Mouse Right Click To Mark / Unmark a record'
      STATUSITEM '<Delete> : Delete record(s)' WIDTH 200
      END STATUSBAR

      @ 10,10 BROWSE Browse_1;
         WIDTH 400;
         HEIGHT 370;
         HEADERS { 'Code', 'First Name', 'Last Name', 'Birth Date', "Balance" };
         WIDTHS { 50 , 100 , 100 , 100 , 100 };
         WORKAREA Test;
         FIELDS rfi1;
         DYNAMICFORECOLOR {acolor, acolor, acolor, acolor, acolor};
         DYNAMICBACKCOLOR inmet(rfi1)

      @ 10,450 BROWSE Browse_2;
         WIDTH 400;
         HEIGHT 370;
         HEADERS { 'Code' , 'Summa1' , 'Summa2', 'Summa3'};
         WIDTHS { 50 , 100 , 100 , 100 };
         WORKAREA Test1;
         FIELDS rfi2;
         DYNAMICFORECOLOR {acolor, acolor, acolor, acolor};
         DYNAMICBACKCOLOR inmet(rfi2)

      ON KEY ESCAPE ACTION Form_1.Release
      ON KEY DELETE ACTION rdel()

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1


Return Nil

Procedure OpenTables()

   if !file("test.dbf")
      CreateTable()
   endif
   if !file("test1.dbf")
      CreateTable()
   endif

   Use Test new
   Use Test1 new

Return

Procedure CreateTable
   Local aDbf[5][4], i, bdbf[4][4]

   aDbf[1][ DBS_NAME ] := "Code"
   aDbf[1][ DBS_TYPE ] := "Numeric"
   aDbf[1][ DBS_LEN ] := 3
   aDbf[1][ DBS_DEC ] := 0
   //
   aDbf[2][ DBS_NAME ] := "First"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ] := 25
   aDbf[2][ DBS_DEC ] := 0
   //
   aDbf[3][ DBS_NAME ] := "Last"
   aDbf[3][ DBS_TYPE ] := "Character"
   aDbf[3][ DBS_LEN ] := 25
   aDbf[3][ DBS_DEC ] := 0
   //
   aDbf[4][ DBS_NAME ] := "Birth"
   aDbf[4][ DBS_TYPE ] := "Date"
   aDbf[4][ DBS_LEN ] := 8
   aDbf[4][ DBS_DEC ] := 0
   //
   aDbf[5][ DBS_NAME ] := "Balance"
   aDbf[5][ DBS_TYPE ] := "Numeric"
   aDbf[5][ DBS_LEN ] := 10
   aDbf[5][ DBS_DEC ] := 2

   delete file test.dbf
   delete file test1.dbf
   DBCREATE("Test", aDbf)

   Use Test

   For i:= 1 To 100
      append blank
      Replace code with i
      Replace First With 'First Name '+ Ltrim(Str(i))
      Replace Last With 'Last Name '+ Ltrim(Str(i))
      replace birth with date()-Max(10000, Random(20000))+Random(LastRec())
      replace Balance with i*10*if(i/5-int(i/5)=0,-1,1)
   Next i

   use

   bDbf[1][ DBS_NAME ] := "Code"
   bDbf[1][ DBS_TYPE ] := "Numeric"
   bDbf[1][ DBS_LEN ] := 3
   bDbf[1][ DBS_DEC ] := 0
   //
   bDbf[2][ DBS_NAME ] := "Sum1"
   bDbf[2][ DBS_TYPE ] := "Numeric"
   bDbf[2][ DBS_LEN ] := 10
   bDbf[2][ DBS_DEC ] := 2
   //
   bDbf[3][ DBS_NAME ] := "Sum2"
   bDbf[3][ DBS_TYPE ] := "Numeric"
   bDbf[3][ DBS_LEN ] := 10
   bDbf[3][ DBS_DEC ] := 2
   //
   bDbf[4][ DBS_NAME ] := "Sum3"
   bDbf[4][ DBS_TYPE ] := "Numeric"
   bDbf[4][ DBS_LEN ] := 10
   bDbf[4][ DBS_DEC ] := 2

   DBCREATE("Test1", bDbf)

   Use Test1
   For i:= 1 To 30
      append blank
      Replace code with i
      Replace sum1 With i*2*if(i/4-int(i/4)=0,-1,1)
      Replace sum2 With i*3*if(i/6-int(i/6)=0,-1,1)
      replace sum3 with i*10*if(i/5-int(i/5)=0,-1,1)
   Next i
   use

Return

#define WM_NOTIFY 78
#define NM_CLICK (-2)
#define NM_RCLICK (-5)

Function MyEvents ( hWnd, nMsg, wParam, lParam )
   Local i, cFormName, cControlName, result, cControlType, BrowseArea
   if nMsg == WM_NOTIFY
      if GetNotifyCode ( lParam ) == NM_RCLICK
         i := Ascan( _HMG_aFormHandles , hWnd )
         cFormName := if( i > 0, _HMG_aFormNames[ i ], "" )
         i := Ascan( _HMG_aControlHandles, GetHwndFrom( lParam ) )
         cControlName := if( i > 0, _HMG_aControlNames[ i ], "" )
         cControlType := if( i > 0, _HMG_aControlType[ i ], "" )
         BrowseArea := if(cControlType=="",0,_HMG_aControlSpacing[ i ])
         if cControlType == "BROWSE"
            result:= pomet(cFormName, cControlName, BrowseArea)
         else
            result:= Events ( hWnd, nMsg, wParam, lParam )
         endif
      else
         result:= Events ( hWnd, nMsg, wParam, lParam )
      endif
   else
      result:= Events ( hWnd, nMsg, wParam, lParam )
   endif
Return result

procedure pomet(cFormName, cControlName, BrowseArea)
   local namv := GetProperty( cFormName, cControlName , "Value")
   local jj
   IF Select (BrowseArea) != 0
      Select &BrowseArea
      go namv
      jj:=ascan(met, alias()+' '+str(recno()))
      if jj=0
         aadd(met,alias()+" "+str(recno())+"~"+cFormName+"`"+cControlName)
      else
         adel(met, jj)
         asize(met, len(met)-1)
      endif
      namv:=recno()
      skip
      if eof()
         go namv
         skip -1
      endif

   endif
   SetProperty( cFormName, cControlName , "Value",recno())
   DoMethod( cFormName , cControlName, "Refresh" )
return

function rEven()
   Local i, result:=.F., BrowseArea, BackArea, BackRec

   i := ASCAN( _HMG_aControlhandles, GetFocus())

   if i>0
      BrowseArea := _HMG_aControlSpacing[ i ]
      BackArea := Alias()
      BackRec := RecNo()
      IF Select (BrowseArea) != 0
         Select &BrowseArea
         result:= if ( ascan(MET,alias()+' '+str(recno())) = 0 , .F. , .T. )
         dbselectarea(BackArea)
         go BackRec
      endif
   endif

return result

function cEven(rfi)
   Local result:=.F.

   if Valtype(rfi)=="N"
      if rfi<0
         result:=.T.
      endif
   endif

return result

function kolmet()
   Local i, ii, ij, nStart := 1
   Local BrowseArea, BackArea, BackRec, cAlias
   Local cArri:={}

   i := ASCAN( _HMG_aControlhandles, GetFocus())

   if i>0
      BrowseArea := _HMG_aControlSpacing[ i ]
      BackArea := Alias()
      BackRec := RecNo()
      IF Select (BrowseArea) != 0
         Select &BrowseArea
         cAlias:=alias()+' '
         ii:=len(cAlias)
         WHILE nstart > 0
            nstart:=ascan(MET, cAlias,nstart)
            if nstart>0
               ij:=len(met[nstart])-ii
               aadd(cArri,substr(met[nstart],ii+1,ij))
               nstart:=nstart+1
            endif
         ENDDO
         dbselectarea(BackArea)
         go BackRec
      endif
   endif

return cArri

procedure rdel()
   Local sumrec, sumrec2, cArri:=kolmet()
   Local i, ii, ij, cFormName, cControlName, pod1, pod2
   Local BrowseArea, BackArea, BackRec, cAlias
   sumrec:=len(cArri)
   sumrec2:=sumrec
   if sumrec2=0
      return
   endif
   if msgYesNo("Delete "+ltrim(str(sumrec2))+" record"+if(sumrec2=1,"?","s?"), "Delete records")
      i := ASCAN( _HMG_aControlhandles, GetFocus())
      if i>0
         BrowseArea := _HMG_aControlSpacing[ i ]
         BackArea := Alias()
         BackRec := RecNo()
         IF Select (BrowseArea) != 0
            Select &BrowseArea
            cAlias:=alias()+' '
            if sumrec=0
               delete
               Skip
               if eof()
                  Go Bottom
               EndIf
            else
               pod1:=at("~",cArri[1])
               pod2:=at("`",cArri[1])
               cFormName:=substr(cArri[1],pod1+1,pod2-1-pod1)
               cControlName:=substr(cArri[1],pod2+1,len(cArri[1])-pod2)
               for ii:=1 to sumrec
                  go val(substr(cArri[ii],1,pod1-1))
                  delete
                  ij:=ascan(MET, cAlias+cArri[ii])
                  adel(met, ij)
                  asize(met, len(met)-1)
               next
               go top
            endif
            SetProperty( cFormName, cControlName , "Value",recno())
            DoMethod( cFormName , cControlName, "Refresh" )
            dbselectarea(BackArea)
            go BackRec
         endif
      endif
   endif
return

function inmet(rfi)
   Local il, i, ii, ij, ccolor:={}

   ij:=len(rfi)
   for il=1 to ij
      ii:="{ || if ( cEven("+rfi[il]+")= .F. , ( 255 + ( 255 * 256 ) + ( 255 * 65536 ) ) , ( 255 + ( 255 * 256 ) + ( 0 * 65536 ) ) ) }"
      i:=&(ii)
      aadd(ccolor,i)
   next

return ccolor
