/*

   Floating Buttons Moduls

*/

#include <minigui.ch>
#include "DBA.ch"

/*

  FB Modüllerindeki PUBL ler :
  
   A :
       aOpnDatas
        
   C :
       cMWinName

   N : 
       nOpTablCo  
       nOpnPagCo  
       nCurDatNo 
       nCurPagNo 
       n1PagDtNo 
       nBtnWidth  
       nPrvBtLen
       nNxtBtLen
       
   MC : ( Manifest Contant ) :
   
      lFBDebug
   
         
   Interaction :
   
      Open : Açan açar,       aData'yý günceller, FB_RefrsAll() yapar
      Clos : Kapayan kapatýr, aData'yý günceller, FB_RefrsAll() yapar
      Sele : FB_SetDatas() çalýþýr. Bu "olay" da yapýlacak iþler FB_SetDatas()'a 
             yerleþtirilmelidir.

            
   FB_Moduls :
         
      p.FB_InitBtns()   // Initialize all controls 
      p.FB_SelePage()   // Select Page ( Data )
      p.FB_RefrsAll()   // Refresh all
      p.FB_SetBtLens()  // Set Buttons lengths
      p.FB_RefrNavB()   // Refresh Navigation ( prev-next page ) Buttons
      p.FB_PrevPage()   // PrevPage button pressed, float all buttons to the left
      p.FB_NextPage()   // NextPage button pressed, float all buttons to the right
      p.FB_ScalTabs()   // escaleid (?!) tabs
      
      
  aOpenDatas <-> aOpenTables iliþkisi :
  
  aOpenDatas : Açýk "bütün" dosyalar demektir. Her dosyanýn bir "sayfasý" (page'i) olmalýdýr.
               FB rutinleri hep buna bakar. Dosya ve sayfanýn cinsi, yapýsý, biçimi vs FB'leri
               ilgilendirmez. 
               
  nOpenDataCo <= LEN( aOpenDatas ) dýr.
  
  aOpenTables : "Work Area"larýn çetelesidir. "Table" tabanýndaki iþler bunun üzerinde, buna 
                göre yapýlýr. Bu bilgi dahi FB'Nin ilgi alanýnýn dýþýndadýr.
                
  nOpenTablesCo <= LEN( aOpenTables ) dir.
                
  
  Table'lerin, Data'lar içinde hýfzý ve idaresi mümkün ve ekonomik gibi görünüyorsa da; 
  yapý, özellik ve kullaným benzemezliði sebepleriyle bu iki kavramýn biribirinden ayrý 
  tutulmasý müreccah görüldü.
  
  Bu tasnif, aOpenDatas içinde bir "Data tipi" kavramýný icabettirir :
  
     T : Table    ( .dbf )
     C : Catalog   
     V : View   
     Q : Query  
     F : Format 
     R : Report 
     L : Label  
     X : Text   
     
  Ve de aOpenDatas için bir "yapý"  :
  
     1°  Tip ( T/C/V/Q/F/R/L/X )
     2°  FName : Full ( With path & extn) Name
     3°  OName : Only ( wout path & extn) Name
     4°  Table ise : WANo / aOpenTables'deki sýra no 
       
  Bu da aOpenTables'e bir yapý :
  
     Þimdiki yapý ( data/table karýþýk )
     
     1° Only Name
     2°   "    "  + "isimli data" ( StatBar'a yazýlýyor )
     3°   "    "  + "Kodlu data'nýn muhtevasý buraya gelecek ..."  ( Page'e yazýlýyor)

*/

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC FB_InitBtns()                       // Initialize all FB Buttons

   LOCA nButton  := 0,;
        cButtNam := ''
   
   _HideControl ( "btnPrev", cMWinName )
   _HideControl ( "btnNext", cMWinName )
   _HideControl ( "btnClose", cMWinName )
        
   FOR nButton := 1 TO nMaxPageCo
      cButtNam := "btnPag" + STRZERO( nButton, 2 ) //   PADL( nButton, 2, "0" )
      _HideControl ( cButtNam, cMWinName )
   NEXT nButton 
   
RETU // FB_InitBtns()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FB_SelePage( nPageNo )               // Select Data Page
   nCurDatNo := n1PagDtNo + nPageNo - 1
   nCurPagNo := nCurDatNo - n1PagDtNo + 1
   FB_ScalTabs()
   ScrnPlay()
   RefrStBar("7° ")
RETU // SelePage()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC FB_RefrsAll()                        // Refresh All Elements of Floating Buttons

   LOCA nButton   := 0,;
        cButtNam  ,;
        nPOPageCo ,;
        cMark     ,;
        nMainULen := GetProperty( cMWinName, "Width"  ),;
        nMainUHig := GetProperty( cMWinName, "Height" )

   SetProperty( cMWinName, "Width",  MAX( nMinMWWid, nMainULen ) )
   SetProperty( cMWinName, "Height", MAX( nMinMWHig, nMainUHig ) )

   nMainULen -= ( nNavBtWdt + 2 * GetBorderWidth() )
   
   IF nOpTablCo > 0   
      IF nMainULen < ( nMinBtWdt * nOpTablCo )
         nPOPageCo := MIN( nMaxPageCo, INT( ( nMainULen - nNavBtWdt * 2 ) / nMinBtWdt ) )  // Possible Open Page Count 
         IF nPOPageCo <  nOpTablCo
            cMark := "2°"
            nOpnPagCo := nPOPageCo
            n1PagDtNo := MIN( nOpTablCo - nOpnPagCo + 1, nCurDatNo )
            nCurPagNo := nCurDatNo - n1PagDtNo + 1
         ELSE
            cMark := "3°"
            n1PagDtNo := 1
            nOpnPagCo := nOpTablCo 
            nCurPagNo := nCurDatNo
         ENDIF nPOPageCo > nOpTablCo
      ELSE 
         IF nOpTablCo > nMaxPageCo
            cMark := "4°"
            nOpnPagCo := nMaxPageCo
            n1PagDtNo := nOpTablCo - nOpnPagCo + 1
            nCurPagNo := nCurDatNo - n1PagDtNo + 1
         ELSE
            cMark := "1°"
            n1PagDtNo := 1
            nOpnPagCo := nOpTablCo 
            nCurPagNo := nCurDatNo
         ENDIF nOpTablCo > nMaxPageCo  
      ENDIF nMainULen < ( nMinBtWdt * nOpTablCo ) // Pencere, bütün sayfalarý alamýyor
   ELSE
      * "Cloase All" veya tek açýk sayfanýn kapatýlmasý hâli
      cMark := "9°"
      n1PagDtNo := 0
      nOpnPagCo := 0 
      nCurDatNo := 0
      nCurPagNo := 0
      FOR nButton := 1 TO 10
         cButtNam := "btnPag" + PADL( nButton, 2, "0" )
        _HideControl ( cButtNam, cMWinName )
      NEXT nButton 
   ENDIF nOpTablCo > 0   

   FB_SetBtLens()  // Set Buttons lengths
   
   FB_RefrNavB()   // Refresh Navigation buttons
     
   FB_ScalTabs()   // escaleid (?!) tabs
   
   RefrStBar( cMark )
   
RETU // FB_RefrsAll() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FB_SetBtLens()                       // Set Buttons lengths

   LOCA nMainULen := GetProperty( cMWinName, "Width" ) - 2 * GetBorderWidth() + 1

   IF n1PagDtNo > 0
      nPrvBtLen := IF( n1PagDtNo > 1,                         nNavBtWdt, 0 )        
      nNxtBtLen := IF( n1PagDtNo + nOpnPagCo - 1 < nOpTablCo, nNavBtWdt, 0 )        
      nBtnWidth := INT( ( nMainULen - ( nPrvBtLen + nNxtBtLen + nNavBtWdt ) ) / nOpnPagCo )
   ELSE
      nPrvBtLen := 0
      nNxtBtLen := 0
      nBtnWidth := 0
   ENDIF n1PagDtNo > 0
      
RETU // FB_SetBtLens()     

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FB_RefrNavB()                        // Refresh Navigation ( prev-next page ) Buttons

   LOCA nNxtBtnCol  := 0,;
        nClosBtnCol := 0,;
        nClosBtnLen := 0
    
   IF nPrvBtLen > 0
      _ShowControl ( "btnPrev", cMWinName )
   ELSE   
      _HideControl ( "btnPrev", cMWinName )
   ENDIF
   
   IF nNxtBtLen > 0
      nNxtBtnCol := nPrvBtLen + nBtnWidth * nOpnPagCo
      SetProperty ( cMWinName, "btnNext", "COL", nNxtBtnCol )
      _ShowControl ( "btnNext", cMWinName )
   ELSE   
      _HideControl ( "btnNext", cMWinName )
   ENDIF
   
   IF nOpnPagCo > 0
       nClosBtnCol := nPrvBtLen + nBtnWidth * nOpnPagCo + nNxtBtLen
       nClosBtnLen := GetProperty( cMWinName, "Width" ) - nClosBtnCol - 2 * GetBorderWidth()
       SetProperty ( cMWinName, "btnClose", "WIDTH",  nClosBtnLen )
       SetProperty ( cMWinName, "btnClose", "COL",  nClosBtnCol )
      _ShowControl ( "btnClose", cMWinName )
   ELSE
      _HideControl ( "btnClose", cMWinName )
   ENDIF nOpnPagCo > 0
   
   ScrnPlay()
      
RETU // FB_RefrNavB() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
     
PROC FB_PrevPage()                        // PrevPage button pressed, float all buttons to the left

   n1PagDtNo := MAX( --n1PagDtNo, 1 )
   
   nCurPagNo := nCurDatNo - n1PagDtNo + 1
   
   IF nCurPagNo > nOpnPagCo 
      --nCurDatNo
      --nCurPagNo
   ENDIF   
   
   FB_SetBtLens()  
   FB_RefrNavB()   
   FB_ScalTabs()   
   RefrStBar( "5° " )
   
RETU // PrevPage()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FB_NextPage()                        // NextPage button pressed, float all buttons to the right

   n1PagDtNo := MIN( ++n1PagDtNo, (nOpTablCo - nOpnPagCo + 1 ) )
   
   nCurPagNo := nCurDatNo - n1PagDtNo + 1
   
   IF nCurPagNo < nOpnPagCo 
      ++nCurDatNo
      ++nCurPagNo
   ENDIF   
   
   FB_SetBtLens()  
   FB_RefrNavB()   
   FB_ScalTabs()   
   RefrStBar( "6° " )
   
RETU // FB_NextPage()         

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FB_ScalTabs()                        // escaleid (?!) tabs

   LOCA nButton   :=  0,;
        cButnNam  := '',;
        cButnCapt := '',;
        nDataNum  :=  0,;
        nBegColm  := GetProperty( cMWinName, "btnPrev", "Col" ) + nPrvBtLen 

   FOR nButton := 1 TO nMaxPageCo
      cButnNam := "btnPag" + PADL( nButton, 2, '0' )
      IF nOpnPagCo < nButton  
         _SetControlWidth( cButnNam, cMWinName, 0 ) 
         _HideControl ( cButnNam, cMWinName )
      ELSE
         _SetControlCol ( cButnNam, cMWinName, nBegColm )
         _SetControlWidth( cButnNam, cMWinName, nBtnWidth ) 
        nDataNum  :=  n1PagDtNo + nButton - 1
        
        cButnCapt := ExOFNFFP( aOpnDatas[ nDataNum, 4 ] )
                     
        SetProperty(  cMWinName, cButnNam, "CAPTION", cButnCapt  )
        SetProperty(  cMWinName, cButnNam, "FONTSIZE", IF( nButton # nCurPagNo, 7, 8 )  )
        _SetFontBold( cButnNam,  cMWinName, ( nButton == nCurPagNo ) )   
        nBegColm += nBtnWidth 
        _ShowControl ( cButnNam, cMWinName )
      ENDI
   NEXT nButton 
   
RETU // FB_ScalTabs()                        

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

