/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"
#include "tsbrowse.ch"

REQUEST DBFCDX

FIELD id, info, sum, pvn, itg

MEMVAR nSum, nPvn, nItg, nCnt, nKfc, nEdit

*-----------------------------------
PROCEDURE Main()
*-----------------------------------
LOCAL i, oBrw, oCol, aStru

 RddSetDefault("DBFCDX")

 SET CENTURY      ON
 SET DATE         GERMAN
 SET DELETED      ON
 SET EXCLUSIVE    ON
 SET EPOCH TO     2000
 SET AUTOPEN      ON
 SET EXACT        ON
 SET SOFTSEEK     ON

 SET NAVIGATION   EXTENDED

 PRIVATE nSum := 0, nPvn := 0, nItg := 0, nCnt := 0, nKfc := 0.21, nEdit := 3

 aStru := { { "ID"  , "N",  5, 0 }, ;
            { "INFO", "C", 15, 0 }, ;
            { "SUM" , "N", 15, 2 }, ;
            { "PVN" , "N", 15, 2 }, ;
            { "ITG" , "N", 15, 2 }  ;
          }

 IF ! hb_FileExists( "datab.dbf" )
    dbCreate( "datab", aStru )
 ENDIF

 USE datab ALIAS base NEW

 IF LastRec() == 0
    FOR i := 1 TO 1000
       APPEND BLANK
       REPLACE ID   WITH i, ;
               INFO WITH RandStr(15),  ;
               SUM  WITH RecNo() * 2.5, ;
               PVN  WITH SUM * nKfc, ;
               ITG  WITH SUM + PVN
    NEXT
 ENDIF

 dbGoTop()

 INDEX ON ID          TAG KOD  FOR ! deleted()
 INDEX ON UPPER(INFO) TAG NAM  FOR ! deleted()

 OrdSetFocus("KOD")
 dbGoTop()

 dbEval({|| nSum += SUM, nPvn += PVN, nItg += ITG, nCnt += 1 })

 GO TOP

 DEFINE FONT FontBold FONTNAME _HMG_DefaultFontName ;
                          SIZE _HMG_DefaultFontSize BOLD  // Default for TsBrowse

 DEFINE WINDOW win_1 AT 0, 0 WIDTH 610 HEIGHT 500 ;
    MAIN TITLE "TSBrowse Add Record Demo" NOMAXIMIZE NOSIZE

    @ 06,  10  BUTTON BADD CAPTION "Add Record" ACTION AddRecord( oBrw ) DEFAULT
    @ 06, 110  BUTTON BORD CAPTION "Set Orders" ACTION SetOrders( oBrw )
    
    DEFINE TBROWSE obrw AT 40, 10 GRID ALIAS "base"  WIDTH 580 HEIGHT 418
     
       oBrw:hFontHead := GetFontHandle( "FontBold" )
       oBrw:hFontFoot := oBrw:hFontHead

       ADD COLUMN TO oBrw   DATA  {|| ("base")->( OrdKeyNo() ) } ;
           HEADER "No"                 FOOTER "" ;
           ALIGN DT_CENTER, DT_CENTER, DT_CENTER ;
           SIZE 60 

       ADD COLUMN TO oBrw   DATA  FieldWBlock( "ID", Select( "base" ) ) ;
           HEADER "ID"                 FOOTER hb_ntos(nCnt) ;
           ALIGN DT_CENTER, DT_CENTER, DT_CENTER ;
           SIZE 60 
          
       ADD COLUMN TO oBrw  DATA  FieldWBlock( "INFO", Select( "base" ) ) ;
           HEADER "Name"+CRLF+"info"  FOOTER "Total: " ;
           ALIGN DT_LEFT,  DT_CENTER, DT_RIGHT  ;
           SIZE 150
     
       ADD COLUMN TO oBrw  DATA  FieldWBlock( "SUM", Select( "base" ) ) ;
           HEADER "Amount"            FOOTER hb_ntos(nSum) ;
           ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT  ;
           SIZE 90
     
       ADD COLUMN TO oBrw  DATA  FieldWBlock( "PVN", Select( "base" ) ) ;
           HEADER "Pvn"               FOOTER hb_ntos(nPvn) ;
           ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT  ;
           SIZE 90
     
       ADD COLUMN TO oBrw  DATA  FieldWBlock( "ITG", Select( "base" ) ) ;
           HEADER "Total"             FOOTER hb_ntos(nItg) ;
           ALIGN DT_RIGHT, DT_CENTER, DT_RIGHT  ;
           SIZE 90
           
     
       AEval( oBrw:aColumns, {|oCol,nCol| oCol:lFixLite := .T., ;
                  oCol:lEdit := nCol >= nEdit,                 ;
                  oCol:cName := If( nCol > 1, aStru[nCol-1][1], "NN" ) } )
                                         
       oBrw:nWheelLines := 1
       oBrw:nClrLine    := COLOR_GRID
     
//     oBrw:nHeightHead += 4
       oBrw:nHeightCell += 4
       oBrw:nHeightFoot += 10
     
       oBrw:aSortBmp := { LoadImage("br_up.bmp"), LoadImage("br_dn.bmp") }
     
//     oBrw:SetColor( { 2 }, { {|| iif( base->( ordKeyNo() ) % 2 == 0, RGB( 255, 255, 255 ), RGB( 230, 230, 230 ) ) } } )
       oBrw:SetColor( { 6 }, { { |a,b,c| If( c:nCell == b, {Rgb( 66, 255, 236), Rgb(209, 227, 248)}, ; 
                                                           {Rgb(220, 220, 220), Rgb(220, 220, 220)} ) } } )           
     
       oCol            := oBrw:GetColumn("ID")
       oCol:cOrder     := "KOD"
       oCol:lNoDescend := .T.

       oCol            := oBrw:GetColumn("INFO")
       oCol:cOrder     := "NAM"
       oCol:lNoDescend := .T.

   For i := 1 To Len(oBrw:aColumns)
       oCol           := oBrw:GetColumn(i)
       oCol:bPrevEdit := { |val,brw    | Prev(val,brw    ) }
       oCol:bPostEdit := { |val,brw,add| Post(val,brw,add) }
       If oCol:cName == "ITG"
          oCol:lEdit := .F.
       EndIf
   Next

       oBrw:cToolTip := {|oBr,nNr,nLn| "My TsBrowse tooltip. "+CRLF+"nCol ="+str(nNr,3)+" nRow ="+str(nLn,3) }
       aEval(oBrw:aColumns, {|oCol| oCol:cToolTip := {|oBr,nNr,nLn| "My columns Header. nCol ="+str(nNr,3)+" nRow ="+str(nLn,3) } })
     
       oBrw:SetIndexCols( oBrw:nColumn("ID"),  ;
                          oBrw:nColumn("INFO") )
       oBrw:SetOrder( oBrw:nColumn("ID") )
    
    END TBROWSE

 END WINDOW

 oBrw:SetFocus()

 CENTER   WINDOW win_1
 ACTIVATE WINDOW win_1

RETURN

*-----------------------------------
FUNCTION Prev( uVal, oBrw )
*-----------------------------------
Local nCol := oBrw:nCell
Local oCol := oBrw:aColumns[ nCol ]

 oCol:Cargo := uVal        // old value

RETURN .T.

*-----------------------------------
FUNCTION Post( uVal, oBrw, lAppend )
*-----------------------------------
Local nCol := oBrw:nCell
Local oCol := oBrw:aColumns[ nCol ]
Local cNam := oCol:cName
Local uOld := oCol:Cargo
Local lMod := ! uVal == uOld      // .T. - modify value
Local cAls := oBrw:cAlias
Local nPos, nTmp
 
 If lMod 
    If     oCol:cName == "INFO"
       If ( cAls )->( IndexOrd() ) == 2     // modify order key
          oBrw:GotoRec(( cAls )->(RecNo()))
       EndIf
    ElseIf oCol:cName == "SUM"
       nSum -= uOld
       nSum += uVal
       nTmp := uVal * nKfc
       nPos := ( cAls )->( FieldPos("PVN") )
       nPvn -= ( cAls )->( FieldGet(nPos) )
       nPvn += nTmp
       ( cAls )->( FieldPut(nPos, nTmp) )
       nPos := ( cAls )->( FieldPos("ITG") )
       nItg -= ( cAls )->( FieldGet(nPos) )
       nItg += uVal + nTmp
       oBrw:GetColumn("SUM"):cFooting := hb_ntos(nSum)
       oBrw:GetColumn("PVN"):cFooting := hb_ntos(nPvn)
       oBrw:GetColumn("ITG"):cFooting := hb_ntos(nItg)
       oBrw:DrawFooters()
    ElseIf oCol:cName == "PVN"
       nPvn -= uOld
       nPvn += uVal
       nPos := ( cAls )->( FieldPos("ITG") )
       nItg -= ( cAls )->( FieldGet(nPos) )
       nItg += uVal
       oBrw:GetColumn("PVN"):cFooting := hb_ntos(nPvn)
       oBrw:GetColumn("ITG"):cFooting := hb_ntos(nItg)
       oBrw:DrawFooters()
    EndIf
 EndIf

RETURN .T.

*-----------------------------------
PROCEDURE SetOrders( oBrw )
*-----------------------------------
LOCAL cCol := If( ( oBrw:cAlias )->( IndexOrd() ) == 1, "INFO", "ID" )
LOCAL nCol := oBrw:nColumn(cCol)

 oBrw:SetOrder(nCol)
 oBrw:SetFocus()

RETURN

*-----------------------------------
PROCEDURE AddRecord( oBrw )
*-----------------------------------
LOCAL nIdNew, lAdd 
LOCAL nInd := ( oBrw:cAlias )->( IndexOrd() )
LOCAL nRec := ( oBrw:cAlias )->( RecNo() )

   If nInd != 1; OrdSetFocus(1)
   EndIf

   dbGoBottom()
   nIdNew := ID + 1

   lAdd := nIdNew <= 99999

   If lAdd
      APPEND BLANK
      REPLACE ID  WITH nIdNew, INFO WITH RandStr(15),  ;
              SUM WITH RecNo() * 1.3, ;
              PVN WITH SUM * nKfc, ;
              ITG WITH SUM + PVN

      nSum += SUM
      nPvn += PVN
      nItg += ITG
      nCnt += 1

      oBrw:GetColumn("ID" ):cFooting := hb_ntos(nCnt)
      oBrw:GetColumn("SUM"):cFooting := hb_ntos(nSum)
      oBrw:GetColumn("PVN"):cFooting := hb_ntos(nPvn)
      oBrw:GetColumn("ITG"):cFooting := hb_ntos(nItg)

      nRec := RecNo()
      dbSkip(-1)
      If RecNo() == nRec; dbSkip(1)
      EndIf
   EndIf

   If nInd != 1; OrdSetFocus(nInd)
   EndIf

   oBrw:GoToRec(nRec)
   oBrw:SetFocus()

RETURN

*-----------------------------------
FUNCTION RandStr( nLen )
*-----------------------------------
   LOCAL cSet  := "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
   LOCAL cPass := ""
   LOCAL i

   If pCount() < 1
      cPass := " "
   Else
      FOR i := 1 TO nLen
         cPass += SubStr( cSet, Random( 52 ), 1 )
      NEXT
   EndIf

RETURN cPass
