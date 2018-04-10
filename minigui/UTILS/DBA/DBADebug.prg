#include <minigui.ch>
#include "miniprint.ch"
#include "DBA.ch"

PROC ToDo(cMesaj)    // Bu DispArry()'dan çaðrýldýðý için böyle oldu.
   MsgBox("Ýnþallah bir gün" + CRLF2 + ;
          IF(cMesaj#NIL,cMesaj,PROCNAME(1)) + CRLF2 +;
          "Ýþi de olacak ..." )
RETU // ToDo()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  p.DispAnyA()

  Catergory  : Debug
  Purpose    : Display Any Array.
  Syntax     : DispArr(<aArry>, [ <cTitle> ])
  Argument   : <aArry>  : Any Array
               <cTitle> : Windows Title. Default : Called Procname and line no   
  Return     : None
  Caution    : Length (elem count) of array to Display
  Requires   : save.bmp, print.bmp, close.bmp              (???)
  Dependency : MakSHArr.Prc,
               AnyToStr.Fnc,
               ArMaxL.Fnc
  Revision   : 28/07/1998
                1/10/1999 : Empty Array control added.
               21/04/2004 : Converted to HMG
               30.12.2005  : <cTitle> param added
               
               6201 : ASAPrint ve OREX'de bir hayli deðiþti.
               6517 : ExprChek esnasýnda 1az deðiþti.

                
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

PROC DispAnyA( aArry, cTitle, lHex )                  // Display any (dim/elem/type) array

   LOCA aDispArr  := {},;
        cDispArr  := "",;
        nCounter  :=  0,;
        cMsgEmpt  := 'Arry is Empty',;
        cWinTitle := PROCNAME(1) + "\" + NTrim( PROCLINE(1) ),;
        cCmd1Head := 'Save',;
        cCmd2Head := 'Print',;
        cCmd3Head := 'Close',;
        nMaxLengt := 0
       
   IF cTitle == NIL
      cTitle := cWinTitle
   ENDIF   
   
   DEFAULT lHex TO .F.
   
   IF !ISARRY( aArry )
      MsgBox( "Non-Array ( " + VALTYPE( aArry ) +" ) Argument" ,cTitle )
   ELSE   
      IF EMPTY(aArry)                                    
         MsgBox(cMsgEmpt,cTitle)                         
      ELSE                                
                     
         MakSHArr( aDispArr, aArry, 1, , lHex )                      
         
         AEVAL( aDispArr, { | c1 | nMaxLengt := MAX( nMaxLengt, LEN( c1 ) ) } )
                                                         
         FOR nCounter := 1 TO LEN(aDispArr)   
            IF lHex           
               cDispArr += aDispArr[nCounter] + CRLF        
            ELSE
               cDispArr += aDispArr[nCounter] + CRLF        
            ENDIF lHex           
         NEXT nCounter                                   
                       
         cDispArr := STRTRAN( cDispArr, CHR( 11 ), "<eofMarker>" ) 
                                           
         DEFINE WINDOW winDispAArr ;                     
           AT        0,0 ;                               
           WIDTH     MIN( 500, nMaxLengt * 10 + 100 ) ;                               
           HEIGHT    435 ;                               
           TITLE     cTitle ;                            
           MODAL ;                                       
           ON SIZE Dock_WAA() ;
           ON INIT winDispAArr.cmdClose.SetFocus                            
                                                         
           ON KEY ESCAPE ACTION {||winDispAArr.Release}  
                                                         
           DEFINE EDITBOX edtDispArr                     
              ROW      0
              COL      0 
              WIDTH    390                            
              HEIGHT   345                            
              READONLY .T.                              
              FONTNAME "Courier New"
              FONTSIZE 10                                
              VALUE cDispArr                          
           End EDITBOX // edtDispArr
                       
           DEFINE BUTTON cmdSave
              ROW      0
              COL      0
              CAPTION  cCmd1Head
              ACTION   USavKatr( cDispArr, "Save Array as .." )
              WIDTH    41
              HEIGHT   21
              TOOLTIP cCmd1Head                       
           END BUTTON // cmdSave
                                
           DEFINE BUTTON cmdClose
              ROW      0
              COL      0
              CAPTION  cCmd3Head                      
              TOOLTIP  cCmd3Head                      
              WIDTH    41                             
              HEIGHT   21                             
              ACTION winDispAArr.Release              
           END BUTTON // cmdClose
                                                         
         END WINDOW                                      
                                                         
         CENTER   WINDOW winDispAArr                     
         Dock_WAA()                                      
         ACTIVATE WINDOW winDispAArr                     
                                                         
      ENDIF EMPTY(aArry)                                 
   
   ENDIF !ISARRY( aArry )

   RETU // DispAnyA()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC Dock_WAA()                           // Docking Controls For DispAnyA()

   winDispAArr.edtDispArr.WIDTH  :=  winDispAArr.WIDTH  - 10
   winDispAArr.edtDispArr.HEIGHT :=  winDispAArr.HEIGHT - 63
   winDispAArr.cmdSave.Row       :=  winDispAArr.HEIGHT - 57
   winDispAArr.cmdSave.Col       :=  ( winDispAArr.WIDTH - 82 ) / 3
   winDispAArr.cmdClose.Row   	 :=  winDispAArr.cmdSave.Row
   winDispAArr.cmdClose.Col   	 :=  ( winDispAArr.WIDTH - 82 ) / 3 * 2 + 41

RETU // Dock_WAA()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   p.USavKatr() :  Kullanýcýya, belli bir katarý dosya halinde kaydettirme.
   
   Syntax    : USavFile( <cKatar>, <cTitle> ) --> NIL
   
   Arguments : <cKatar> : Kaydedilecek katar
               <cTitle> : Dosyaya isim verme penceresinin baþlýðý.
               
   Dikkat : cAra1Rehbr : PUBL
   
*/
PROC USavKatr( cKatar, cTitle)
    
    LOCA cFileNam := "",;
         lKaydet  := .T.,;
         cAra1Rehbr := GetCurrentFolder()
    
    DEFAULT cTitle TO "Dosya Kaydet"
    
    cFileNam := PutFile( "", cTitle, cAra1Rehbr, .F. ) // .F. : DIR deðiþtirebilir demek
    
    IF !EMPTY( cFileNam ) // Kullanýcý vazgeçerse EMPTY olur.
       IF FILE( cFileNam )    
          lKaydet := MsgYesNo( cFileNam + CRLF2 + ;
                               "Adýnda bir dosya var; Üstüne yazýlsýn mý ?", "Tasdik" )
       
       ENDIF FILE( cFileNam )    
       IF lKaydet
          MEMOWRIT( cFileNam, cKatar )
       ENDIF lKaydet
    ENDIF !EMPTY( cFileNam )
       
RETU // USavKatr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
     
PROC PrintList( cMesaj )

   LOCA nWinLen := 0 , n

   Local mPageNo := 0 ,;
        mLineNo := 0 ,;
        mPrinter
   
   mPrinter := GetPrinter()

   If Empty (mPrinter)
      RETURN
   EndIf

   nWinLen := IF( CRLF $ cMesaj, HL_MAXLINE( cMesaj ), LEN( cMesaj ) )

   IF nWinLen < 95
      SELECT PRINTER mPrinter ORIENTATION PRINTER_ORIENT_PORTRAIT PREVIEW
   ELSE
      SELECT PRINTER mPrinter ORIENTATION PRINTER_ORIENT_LANDSCAPE PREVIEW
   ENDIF

   START PRINTDOC NAME "Print List"
   START PRINTPAGE

   FOR n := 1 TO MLCOUNT( cMesaj, nWinLen )

      IF mLineNo >= IIF(nWinLen < 95, 270, 185) .OR. mPageNo == 0
         mPageNo++
         IF mPageNo > 1
            mLineNo += 5
            @ mLineNo, 150 PRINT "Continue to Page "+LTRIM(STR(mPageNo)) CENTER
            END PRINTPAGE
            START PRINTPAGE
         ENDIF

         mLineNo := 20
         @ mLineNo - 7, nWinLen * 2 - 4 PRINT "Page "+LTRIM(STR(mPageNo))
         @ mLineNo,20 PRINT LINE TO mLineNo,nWinLen * 2 + 8
         mLineNo += 5
      ENDIF

      @ mLineNo, 20 PRINT MEMOLINE( cMesaj, nWinLen, n ) FONT "Courier New" SIZE 9
      mLineNo += 5

   NEXT n

   END PRINTPAGE
   END PRINTDOC

RETU // PrintArr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
     
FUNC SayBekle( xMesaj, cTitle )

   LOCA cMesaj  := "",;
        nWinLen := 0 ,;
        nWinHig := 0 ,;
        lRVal  
        
   LOCA cCmd1Head := 'Save',;
        cCmd2Head := 'Print',;
        cCmd3Head := 'Close'
    
   DEFAULT cTitle TO PROCNAME(1) + "\" +   NTrim( PROCLINE(1) )
   
   IF ISARRY( xMesaj  )
      AEVAL( xMesaj, { | x1 | cMesaj +=  Crocked( AnyToStr( x1, .T. ) ) + CRLF } )
      AEVAL( xMesaj, { | x1 | nWinLen := MAX( LEN(Crocked(AnyToStr( x1,.T. ))), nWinLen ) } )
      nWinHig := MIN( 45, LEN( xMesaj ) )
   ELSE
      IF ISCHAR( xMesaj  )   
         cMesaj :=  xMesaj 
      ELSE
         cMesaj :=  AnyToStr( xMesaj, .T. )
      ENDIF
      nWinLen := IF( CRLF $ cMesaj, HL_MAXLINE( cMesaj ), LEN( cMesaj ) )
      nWinHig := IF( CRLF $ cMesaj, HL_NUMLINE( cMesaj ), 1 )
   ENDIF
   
   nWinLen := MIN( 600, nWinLen * 12 + 100 )
   nWinHig := MIN( 440, nWinHig * 16 + 100 )

   DEFINE WINDOW winSayBekle ;
      AT        0,0 ;
      WIDTH     nWinLen ;
      HEIGHT    nWinHig ;
      TITLE     cTitle ;
      MODAL ;
      ON SIZE Dock_SBek() ;
      ON INIT ( Dock_SBek(), winSayBekle.cmdClose.SetFocus )
      
      ON KEY ESCAPE ACTION { || winSayBekle.Release }
        
      DEFINE EDITBOX edtSayBekle 
         ROW        0
         COL        0
         WIDTH      nWinLen - 14
         HEIGHT     nWinHig - 40
         READONLY   .T.
         FONTNAME   "Courier New" 
         FONTSIZE   10 
         VALUE      cMesaj
      END EDITBOX // edtSayBekle 
            
      DEFINE BUTTON cmdSave
         ROW        0
         COL        0
         CAPTION    cCmd1Head                      
         ACTION     USavKatr( cMesaj, "Save" )
         WIDTH      41
         HEIGHT     21
         TOOLTIP    cCmd1Head                       
      END BUTTON // cmdSave
                                                         
      DEFINE BUTTON cmdPrint
         ROW      0
         COL      0
         CAPTION  cCmd2Head
         ACTION   PrintList( cMesaj )
         WIDTH    41
         HEIGHT   21
         TOOLTIP cCmd2Head               
      END BUTTON // cmdPrint
                                
      DEFINE BUTTON cmdClose
          CAPTION cCmd3Head
          TOOLTIP cCmd3Head
          WIDTH   41
          HEIGHT  21
          ACTION winSayBekle.Release              
      END BUTTON // cmdClose

   END WINDOW // winSayBekle

   CENTER   WINDOW winSayBekle

   ACTIVATE WINDOW winSayBekle
   
RETU lRVal // SayBekle() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC Dock_SBek()                           // SayBekle'de kontrol ebadýný ayarlama

   winSayBekle.edtSayBekle.WIDTH  := winSayBekle.WIDTH  - 2 * GetBorderWidth()
   winSayBekle.edtSayBekle.HEIGHT := winSayBekle.HEIGHT - iif(IsAppXPThemed(), 70, 65)
   winSayBekle.cmdSave.Row        := winSayBekle.HEIGHT - iif(IsAppXPThemed(), 65, 57)
   winSayBekle.cmdSave.Col        := ( winSayBekle.WIDTH - 123 ) / 4 
   winSayBekle.cmdPrint.Row       := winSayBekle.cmdSave.Row
   winSayBekle.cmdPrint.Col       := ( winSayBekle.WIDTH - 123 ) / 4 * 2 + 41 / 2
   winSayBekle.cmdClose.Row       := winSayBekle.cmdSave.Row
   winSayBekle.cmdClose.Col       := ( winSayBekle.WIDTH - 123 ) / 4 * 3 + 41
   
RETU // Dock_SBek()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*

  p.WhereIsIt()  : Produces a message that say program execution point and backward 
                   calling sequence. 
                   
  Purpose : for debugging purposes only
                   
  Syntax : WhereIsIt() => NIL
  
  Parameters : No parameter required
  
  Return : WhereIsIt() always returns NIL
  
  History : 8.2006 : First releas                  

*/
PROC WhereIsIt()

   LOCA nLevel   := 0,;
        cMessage := ''

   WHILE !(PROCNAME(++nLevel) == "")
      cMessage += IF( nLevel < 2, SPAC( 11 ), "from : " ) + ;
                          PROCNAME( nLevel ) + ;
                          " (" + LTRIM( STR( PROCLINE( nLevel ) ) ) + ")" + CRLF
   ENDDO
      
   MsgInfo( cMessage, "It's in :" )
            
RETU // WhereIsIt()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC DisKunye(;
               cDisKod,; 
               nInfTyp )  // 0/NIL : Volume Serial ( In Hex ), 1: Volum Label, 2: Serial + Label
               
   LOCA cLabel  := '',;
        cVolSer := '',;
        cRVal   := '',;
        cComand := '',;
        cFName1 := TempFile( ,'bat' ),;
        cFName2 := TempFile( ,'tmp' ),;
        cDisKun

   DEFAULT cDisKod TO "C",;
           nInfTyp TO  0
   
   cDisKod += IF( ":" $ cDisKod, '', ':' )
   
   cComand := "VOL " + cDisKod // + " > " + cFName2
      
   MEMOWRIT( cFName1, cComand )

   WaitRunPipe( cFName1 + " > " + cFName2, 0, "dummy" )
   
   IF FILE( "dummy" )
      ERASE "dummy"
   ENDIF
      
   cDisKun := HB_OEMTOANSI( MEMOREAD( cFName2 ) )
   
   FileWipe( { cFName1, cFName2 }  )
   
   ExtrcSFS( @cDisKun, CRLF )   // Bir Boþ satýr kalýyor
   ExtrcSFS( @cDisKun, CRLF )   // Bir satýr da komutu yazýyor
   
   cLabel  := ALLTRIM( ExtrcSIS( @cDisKun, ":", CRLF ) )
   cVolSer := ALLTRIM( STRTRAN( ExtrcSIS( @cDisKun, ":", CRLF ), "-", '' ) )
    
   cRVal := IF( nInfTyp < 1, cVolSer,  IF( nInfTyp > 1, cVolSer + cLabel, cLabel ) )
         
RETU cRVal // DisKunye()
                   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC TempFile( ;
                cDirName,;
                cExtentn )
                
   LOCA cSeconds := '',;
        cRVal    := '',;
        lLoop    := .T.
        
   DEFAULT cDirName TO GetTempFolder()

   WHILE lLoop         
   
      cSeconds := STRTRAN( LTRIM( STR( SECONDS(), 8, 2 ) ), '.', '' ) 
      cRVal    := DTOS( DATE() ) + cSeconds 
   
      IF ISNIL( cExtentn )
         cRVal := LEFT( SUBS( cRVal, LEN( cRVal ) - 11 ), 8 ) + "." + RIGHT( cRVal, 3 )
      ELSE
         cRVal := SUBS( cRVal, LEN( cRVal ) - 8 ) + '.' + cExtentn
      ENDIF      
    
      cRVal := cDirName + IF( RIGHT(cDirName,1) # '\', '\','') + cRVal
      
      lLoop := FILE( cRVal )
      
   ENDDO
   
   MEMOWRIT( cRVal,'' )
      
RETU cRVal // TempFile()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FileWipe( ;                          // Wipe out file(s)
                aFile )  // File(s) name
                
   LOCA nFInd := 0,;
        c1Fil := ''
   
   IF ISCHAR( aFile )
      aFile := { aFile }
   ENDIF   
   
   FOR nFInd := 1 TO LEN( aFile )
      c1Fil := aFile[ nFInd ]
      MEMOWRIT( c1Fil, REPL( CHR(0), 1024 ) )
      ERAS ( c1Fil )
   NEXT nFInd

RETU // FileWipe()          

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

                   


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
/*
   
  p.MsgMulty()  : Display a message with any type data
  
  Syntax        : MsgMulty( <xMesaj> [, <cTitle> ] ) -> NIL
  
  Arguments     : <xMesaj> : Any type data value.
  
                             If <xMesaj> is an array, each element will display as 
                             a seperated line.
                             
                  <cTitle> : Title of message box. 
                             Default is calling module name and line number.
  
  Return        : NIL
  
  History :
  
            7.2006 : First Release  

*/
PROC MsgMulty( xMesaj, cTitle )

   LOCA cMessage := ""
    
   IF xMesaj # NIL
   
      IF cTitle == NIL
         cTitle := PROCNAME(1) + "\" +   LTRIM(STR( PROCLINE(1) ) )
      ENDIF
      
      IF VALTYPE( xMesaj  ) == "A"
         AEVAL( xMesaj, { | x1 | cMessage +=  Any2Strg( x1 ) + CRLF } )
      ELSE
         IF VALTYPE( xMesaj  ) == "C"  
            cMessage:=  xMesaj 
         ELSE
            cMessage:=  Any2Strg( xMesaj )
         ENDIF
      ENDIF
   
      MsgInfo( cMessage, cTitle )
      
   ENDIF
   
RETU //  MsgMulty()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*
    f.Any2Strg() : Covert any type data to string
    
    Syntax       : Any2Strg( <xAny> ) -> <cString>
    
    Argument     : <xAny> : A value in any data type
    
    Return       : <cString> : String equivalent of <xAny>
    
    History      :
    
                   7.2006 : First Release  
       
*/

FUNC Any2Strg( xAny )

   LOCA cRVal  := '???',;
        nType  :=  0,;
        aCases := { { "A", { || "{...}" } },;                
                    { "B", { || "{||}" } },;                
                    { "C", { | x | x }},;
                    { "M", { | x | x   } },;                   
                    { "D", { | x | DTOC( x ) } },;             
                    { "L", { | x | IF( x,".T.",".F.") } },;    
                    { "N", { | x | NTrim( x )  } },;
                    { "O", { || ":Object:" } },;
                    { "U", { || "<NIL>" } } }
                    
   IF (nType := ASCAN( aCases, { | a1 | VALTYPE( xAny ) == a1[ 1 ] } ) ) > 0
      cRVal := EVAL( aCases[ nType, 2 ], xAny )
   ENDIF    
                   
RETU cRVal // Any2Strg()
          
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
 
FUNC HL_MAXLINE( cString )

   LOCA nRVal := 0,;
        c1Lin := ''
   
   WHILE !EMPTY( cString )
      c1Lin := ExtrcSFS( @cString, CRLF )
      nRVal := MAX( nRVal, LEN( c1Lin ) ) 
   ENDDO   
   
RETU nRVal // HL_MAXLINE()   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC HL_NUMLINE( cString )

   LOCA nRVal := 0,;
        c1Lin := ''
   
   WHILE !EMPTY( cString )
      c1Lin := ExtrcSFS( @cString, CRLF )
      ++nRVal
   ENDDO   
   
RETU nRVal // HL_NUMLINE()   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC IndxInfA( nWArea )

   LOCA aRVal    := {},;
        nBagNo   :=  0,;
        nOrdNo   :=  0,;
        cBagName := '',;
        cOrdName := '',;
        cOrdKey  := '',;
        nCurWA   := SELECT()
   
   DEFAULT nWArea TO SELECT()
   
   DBSELECTAR( nWArea )
   
   FOR nOrdNo := 1 TO 99
      cBagName := ORDBAGNAME( nOrdNo )
      cOrdName := ORDNAME( nOrdNo )
      cOrdKey  := ORDKEY( nOrdNo )
      IF EMPTY( cBagName ) 
         EXIT FOR
      ENDIF 
      IF EMPTY( aRVal ) .OR. ASCAN( aRVal, { | a1 | cBagName == a1[ 1 ] } ) < 1
         AADD( aRVal, { cBagName, {} } )
      ENDIF   
      AADD( aRVal[ LEN( aRVal ), 2 ], { cOrdName, cOrdKey } )
   NEXT nBagNo
   
   DBSELECTAR( nCurWA )

RETU aRVal // IndxInfA()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC IndxInfC( nWArea )                   // Indeks info, Verbose     

   LOCA aIndxs := IndxInfA( nWArea ),;
        cAlias := ALIAS( nWArea ),; 
        cRVal  := 'Indexs :',;
        a1Bag  := {},;
        aOrds  := {},;
        a1Ord  := {},;
        nBag   :=  0,;
        nOrd   :=  0,;
        cBag   := '',;
        cOrd   := '',;
        cKey   := '',;
        lCur   := .F. 
        
   FOR nBag := 1 TO LEN( aIndxs )
      a1Bag := aIndxs[ nBag ]
      cBag  := a1Bag[ 1 ]
      cRVal += CRLF + "   File (Bag) " + NTrim( nBag) + " : " + cBag + CRLF
      aOrds := a1Bag[ 2 ]
      FOR nOrd := 1 TO LEN( aOrds )
         cRVal += CRLF + SPACE( 8 ) + "Order " + IF( LEN( aOrds ) > 1, NTrim( nOrd), '') + " : " + CRLF
         a1Ord := aOrds[ nOrd ]
         cOrd  := a1Ord[ 1 ]
         cKey  := a1Ord[ 2 ]
         IF "NTX" $ (cAlias)->(RDDNAME()) 
            lCur := ( nBag == INDEXORD() )
         ELSE   
            lCur := ( nOrd == INDEXORD() )
         ENDIF       
         cRVal += SPACE( 12 ) + "Name : " + cOrd + IF( lCur, ' (*)','' ) + CRLF + ;
                  SPACE( 12 ) + "Key  : " + cKey
      NEXT nOrd   
   NEXT nBag
   
   IF HL_NUMLINE( cRVal ) < 2
      cRVal := PADL( cRVal, 18 ) + ' None' + CRLF
   ELSE
      cRVal := CRLF + cRVal + CRLF
   ENDIF   
      
RETU cRVal // IndxInfC()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStatus()

   LOCA nCurSel   := SELECT(),;
        cAlias    := '',;
        cDBFExtn  := '',;
        cDBFName  := '',;
        dLastUpt  := DATE(),;
        nHeadSiz  :=  0,;
        nFldCoun  :=  0,;
        nRecSize  :=  0,;
        nRecCoun  :=  0,;
        nCurRecN  :=  0,;   
        cOrdBagEx := '',;
        cRDDName  := '',;
        aIndekss  := {},;
        nOrdCoun  :=  0,;   
        aOrdBags  := {},;
        nOrdBCou  :=  0 
        
   LOCA nSInfoNo  := 0,;
        cStatus   := '',;
        cHaTahdt  := REPL( ".-._", 13 ) + ".",;  // Hatt-ý tahdid
        nWANo

   FOR nWANo := 1 TO 255 
       SELECT( nWANo )
       IF !EMPTY( ALIAS() )
          
          cStatus  +=  PADL( 'Work Area No : ',    19 ) + NTrim( SELE() )     +;
                                             IF( nWANo == nCurSel, " (*)", '')+ CRLF +;  
                       PADL( 'RDD Name : ',        19 ) + RDDNAME()           + CRLF+;                 
                       PADL( 'Table Extention : ', 19 ) + DBINFO(  9 )        + CRLF+;                 
                       PADL( 'Bag Extention : ',   19 ) + ORDBAGEXT()         + CRLF+;  
                       PADL( 'Table Name : ',      19 ) + ExOFNFFP( DBINFO( 10 ) ) + CRLF+;  
                       PADL( 'Table Full Name : ', 19 ) + DBINFO( 10 )        + CRLF+;                 
                       PADL( 'Alias : ',           19 ) + ALIAS()             + CRLF+;     
                       PADL( 'Last Update : ',     19 ) + DTOC( LUPDATE())    + CRLF+;  
                       PADL( 'Header Size : ',     19 ) + NTrim( HEADER() )   + CRLF+;  
                       PADL( 'Field Count : ',     19 ) + NTrim( FCOUNT() )   + CRLF+;  
                       PADL( 'Record Size : ',     19 ) + NTrim( RECSIZE() )  + CRLF+;  
                       PADL( 'Record Count : ',    19 ) + NTrim( LASTREC() )  + CRLF+;  
                       PADL( 'Current RecNo : ',   19 ) + NTrim( RECNO() )    + CRLF+;  
                       PADL( 'Current Order : ',   19 ) + NTrim( INDEXORD() ) + CRLF+;  
                       IndxInfC( nWANo ) + cHaTahdt + CRLF2

       ENDIF !EMPTY( ALIAS() )
       
   NEXT nWANo
   
   SayBekle( cStatus )
   
   DBSELECTAR( nCurSel )
        
RETU // DBStatus()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

