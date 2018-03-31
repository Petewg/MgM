#include <minigui.ch>
#include "DBA.ch"

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC Txt2Arr(cText,bInclude)   
   LOCA aRVal := {},;
        cLine := ""
   
   DEFAULT bInclude TO {||.T.}
   
   WHIL !EMPTY(cText)
      cLine := ExtrcSFS(@cText,CRLF)
      IF EVAL(bInclude,cLine)
         AADD(aRVal,cLine )
      ENDIF   
   ENDDO
   
RETU aRVal // Txt2Arr(cText)   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC MakMPrgNam(cName1)         // from main proc name   
   LOCA cRValu := "",;
        nPnter := 0 

   WHIL ++nPnter <= LEN(cName1) .AND. ISALPHA(SUBS(cName1,nPnter,1))
       cRValu += SUBS(cName1,nPnter,1)   
   ENDDO
           
RETU cRValu // MakMPrgNam()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

   f.BBTUsing() :  Bir baþka türlü Using

   Maksat : Sayýsal bir deðeri formatlanmýþ katara çevirmek.
     Ýmlâ : BBTUsing(<nVal>,<nLen>,[<nDec>],[<ZSpr>]) -> cVal
   Delâil : <nVal> : Formatlanacak sayýsal deðer
            <nLen> : <nVal>'ýn (formatlanmamýþ) boyu
            [<nDec>] : Decimal basamak sayýsý (verilemezse 0)
            [<ZSpr>] : (Zero Suppress) :  T : nVal sýfýrsa sonuç boþlukla (def)
                                          F :   "     "      "   sýfýrla
    Alâka : f.FUsing(), MakePict()
            f.FUsingAP'de formatlanmýþ halinin boyu,
              bunda formatlanmamýþ  "     "   veriliyor;
              Yâni nLen ile nDec STRU'daki deðerler.
    Sýnýf : CNV      A D D D E F F K K M M N P S S S C P U L M M A S
                     R A B B R L R B M N S U D C E T N R I O M E F P
                     R T G S R W M D S U J M T R C R V F N G O M L S
                     - - - - - - - - - - - + - + - + + - - - - - - -
    Hikâye : ....
             6.2K : Ýzahlandý, Sýnýflandý.
             3.04 : Windows'a çevrildi ( muhavele )
             
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

FUNC BBTUsing(nVal,nLen,nDec,ZSpr)        // Bir baþka türlü Using
   LOCA cRVal := '',;          //
        cPict := '',;          // Picture Kalýp Katarý
        nPInd := 0,;           // Picture indisi
        nSay9 := 0             // Picture'daki 9 sayýsý

   nDec  := IF(nDec==NIL,0,nDec)     // nDec 0'sa verilmeyebilir
   ZSpr  := IF(ZSpr==NIL,.T.,ZSpr)  // nVal sýfýrsa boþluða çevir
   cPict := REPL(",999",9) + IF(nDec>0,"." + REPL("9",nDec),'')
   nPInd := LEN(cPict)
   WHIL nSay9 < nLen
      nSay9 += IF(SUBS(cPict,nPInd--,1)==",",0,1)
   ENDD
   cPict := SUBS(cPict,nPInd+1)
   IF ZSpr
      cRVal := IF(nVal#0, TRAN(nVal,cPict), SPAC(LEN(cPict)))
   ELSE
      cRVal := TRAN(nVal,cPict)
   ENDI
   RETU cRVal // f.BBTUsing()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  f.IndInglz()

  Maksat : Bir katardaki Türkçe karakterleri Ýng.Alf.'deki muadiline çevirme.
    Ýmlâ : IndInglz(<cKatar>) => cKatar
  Delâil : <cKatar> : HH1 Katar (TUpper()'lenmiþ olmalý)
  Semere : <cKatar>'ýn dönüþtürülmüþ hâli.
  Dikkat : <cKatar> TUpper()'lenmiþ olmalý.
   Alâka : f.TUpper()

  History :  3.04 : Windows'a çevrildi ( muhavele )
   
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/

FUNC IndInglz(cKatar)                     // TürkChr'larý Ýng.e Ýndirgeme
   LOCA cRVal := '',;
        nCInd :=  0,;
        cChr1 := '',;
        nCPos :=  0,;
        cTUpC := "ÇÐIÝÖÞÜâäàåîûôêëèïÄÅÉÆôòùø£áíóúñÑ",; // daha ne'dîm ???
        cIngC := "CGIIOSUAAAAIUOEEEIAAEAOOUCLAIOUNN"
   FOR nCInd := 1 TO LEN(cKatar)
      IF !ISALPHA((cChr1 := SUBS(cKatar,nCInd,1)))
         IF (nCPos := AT(cChr1,cTUpC)) > 0
            cChr1  := SUBS(cIngC,nCPos,1)
         ENDIF
      ENDIF !ISALFA()
      cRVal += cChr1
   NEXT nCInd
   RETU cRVal // f.IndInglz()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC Lst2Arr( ;                           // Liste halindeki Katarý Array'a
              cKatar, ;
              cDelimiter )  
              
   LOCA aRVal  := {},;
        x1Val  := NIL
        
   DEFAULT cDelimiter TO ";"
   
   WHIL !EMPTY( cKatar )
      x1Val := Strg2Any( ALLTRIM(ExtrcSFS( @cKatar, cDelimiter )) )
      AADD( aRVal, x1Val )
   ENDDO   
    
RETU aRVal // Lst2Arr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
/*
   MTrim() : Uzun küsuratlý NTrim()
*/
FUNC MTrim( nValue ) 

  LOCA cRVal := ""

  IF nValue # INT( nValue )
     cRVal := LTrim( TRAN( nValue,"999,999,999,999,999,999.999999999999" ) )
     WHILE RIGHT( cRVal,1 ) == "0"
        cRVal := LEFT( cRVal, LEN( cRVal ) - 1 )      
     ENDDO
     IF RIGHT( cRVal,1 ) == "."
        cRVal := LEFT( cRVal, LEN( cRVal ) - 1 )      
     ENDIF      
   ELSE
      cRVal := NTrim( nValue )
   ENDIF   
  
RETU cRVal // MTrim()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   ExtrcSFS() : Extract String From LEFT of String

   Syntax     : ExtrcSFS(<[@]cUpStr>,<cDelimiter>) -> cExtractedSubString

   Arguments  : <[@]cUpStr> : String to extracted from. If passed by referance
                (prefixed by '@') changed after (begin after <cDelimiter>).

                <cDelimiter>   : Sub-string delimiter

   Return     : A sub-string from beginning (left-most) position of <cUpStr>
                to <cDelimiter>. (Not include <cDelimiter>).

   Category   : String Handling

   See also   : ExtrcSIS(), ExtrcSES()


*/

FUNC ExtrcSFS(;                    // Extract String From String
               cUpStr,cDelmtr)     // Up-String, Delimiter

   LOCA cRVal := ''

   IF cDelmtr $ cUpStr
      cRVal  := LEFT(cUpStr,AT(cDelMtr,cUpStr)-1)
      cUpStr := SUBS(cUpStr,AT(cDelMtr,cUpStr)+LEN(cDelMtr))
   ELSE
      cRVal  := cUpStr
      cUpStr := ''
   ENDIF cDelmtr $ cUpStr

   RETU cRVal // ExtrcSFS()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._



FUNC PAT(BasPos,AraKtr,InKtr)             // Positional AT

   LOCA RetVal := 0

   IF BasPos <= LEN(InKtr)
      RetVal := AT(AraKtr,SUBS(InKtr,BasPos))
      IF RetVal > 0
         RetVal := BasPos + RetVal - 1
      ENDI
   ENDI // IF BasBos <= LEN(AraKtr)

   RETU RetVal // f.PAT()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*
   MaxLine() : Lenght of the longest line within a string
   
   6210 : GUI p.SayBekle() için doðdu.
   
*/
FUNC MaxLine( cString )
   LOCA nRVal := 0,;
        nBeg  := 1,;
        nEnd  := 0
   IF ISCHAR( cString ) .AND. !EMPTY( cString )
      WHIL .T.
         nEnd := AT( CRLF, SUBS( cString, nBeg ) )
         IF nEnd > 0 
            nEnd  += nBeg
            nRVal := MAX( nRVal, nEnd - nBeg - 1 )
            nBeg  := nEnd + 2 
         ELSE
            EXIT   
         ENDIF
      ENDDO   
   ENDIF ISCHAR( cString ) .AND. !EMPTY( cString )
RETU nRVal // MaxLine()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*
   NumLine() : Number of lines within a string.
  
   6210 : GUI p.SayBekle() için doðdu.
    
*/   

FUNC NumLine( cString )
   LOCA nRVal := 0,;
        nBeg  := 1,;
        nEnd  := 0
   IF ISCHAR( cString ) .AND. !EMPTY( cString )
      WHIL .T.
         nEnd := AT( CRLF, SUBS( cString, nBeg ) )
         IF nEnd > 0 
            nEnd  += nBeg
            ++nRVal
            nBeg := nEnd + 2 
         ELSE
            EXIT   
         ENDIF
      ENDDO   
   ENDIF ISCHAR( cString ) .AND. !EMPTY( cString )
RETU nRVal // NumLine()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  f.AnyToStr()

  Purpose  : Convert any data type to String.
  Syntax   : AnyToStr(xAny)
  Argument : <xAny> : Any type data to be converted to string
  Return   : String form of <xAny)
  Uses     : f.NTrim()
  Caution  : 'U' type difference between TYPE() & VALTYPE()

  Revision : 0:20:06  29/7/1998
  
             6503 : lRForm added    ( for only C type )
             
             VALTYPE() 'M' sonucu ver(E)mez gibi geldiyse de, veriyormuþ;
             ÝBG bak : ama nasýl ? 
             
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

FUNC AnyToStr( xAny,;
               lRForm )  // // Convert CHR(0..31) to readable format

   LOCA cRVal := '',;
        cVTip := VALTYPE( xAny )
        
* MsgBox( cVTip )

   DEFAULT lRForm TO .F.
      
   DO CASE
      CASE cVTip == "A"
           cRVal := "{...}"                // Array
      CASE cVTip == "B"
           cRVal := "{||}"                 // Block
      CASE cVTip == "C" .OR. cVTip == "M"
           IF lRForm
              cRVal := StpCtrlCods( xAny ) // Convert CHR(0..31) to readable format
           ELSE
              cRVal := xAny       // Character
           ENDIF   
      CASE cVTip == "D"
           cRVal := DTOC(xAny)             // Date
      CASE cVTip == "L"
           cRVal := IF(xAny,".T.",".F.")       // Logical
      CASE cVTip == "N"
           cRVal := MTrim(xAny)            // Numeric
      CASE cVTip == "O"
           cRVal := ":Object:"             // Object
      CASE cVTip == "U"
           cRVal := "<NIL>"                // NIL (Undefined)
   ENDC // CASE cVTip
   
   RETU cRVal // AnyToStr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   ExtrcSIS() : Extract String From IN String

   Syntax     : ExtrcSIS(<[@]cUpString>,<cDelimiter1>,<cDelimiter2>) ->
                        cExtractedSubString

   Arguments  : <[@]cUpStr> : String to extracted from. If passed by referance
                (prefixed by '@') changed after (begin after <cDelimiter>).

                <cDelimiter1>  : Sub-string beginning delimiter

                <cDelimiter2>  : Sub-string ending delimiter

   Return     : A sub-string from beginning with <cDelmtr1> and ending with
                <cDelmtr2> of <cUpStr> (Not include <cDelimiter1> nor
                <cDelimiter2>).

   Category   : String Handling

   See also   : ExtrcSFS(), ExtrcSES()

   Description :

      ExtrcSFS() : Bir katarýn baþýndan (solundan) belirtilen (sýnýrlayýcý)
                   katar'a kadar olan katarý;

      ExtrcSIS() : Bir katarýn ÝÇÝNDEN belirtilen ÝKÝ (sýnýr) katar arasýndaki
                   katarý

      çýkarýr.

      iki func'da da sýnýrlayýcý katarlar;

      alt (yeni) katara dahil edilmez,

      üst katardan da,  (<cUpStr> 'by referance' ('@' ile) gönderilmiþse)

      çýkarýlýr, deðilse üst katar deðiþmez.

      ExtrcSIS()'de :

        üst Katarda :

          1.nci sýnýrlayýcý :

          1'den fazla varsa :  (soldan) ilki esas alýnýr.

          Yoksa : ikinci sýnýrlayýcýya bakýlmaz,
                  boþ alt katar döndürülür,
                  üst katar deðiþmez.

          1.nci sýnýrlayýcý var;

          2.ci sýnýrlayýcý :

             - 1'den fazla varsa : 1.inci'den sonra gelen ilki esas alýnýr.

             - yoksa : (hiç yok veya 1.inci'den sonra (saðýnda) yoksa)

               Alt Katar : Üst Katar'ýn 1.inci sýnýrlayýcýdan sonrasý,
               üst Katar : Kendinin 1.inci sýnýrlayýcýya kadar olan kýsmý

             olur.
             
   6213 : WOREX esnasýna, LEN(cDelm)'lere -1 eklendi 

*/

FUNC ExtrcSIS(;                           // Extract String IN String
               cUpStr,;    // Up-String
               cDelm1,;    // Delimiter - 1
               cDelm2)     // Delimiter - 2

   LOCA cRVal := '',;
        nPos1 :=  0,;
        nPos2 :=  0

   IF cDelm1 $ cUpStr
      nPos1 := AT( cDelm1, cUpStr ) +  LEN( cDelm1 )
      IF cDelm2 $ SUBS( cUpStr, nPos1 )
         nPos2  := PAT( nPos1, cDelm2, cUpStr )
         cRVal  := SUBS( cUpStr, nPos1, nPos2-nPos1 )
         cUpStr := SUBS( cUpStr, 1, nPos1 - LEN( cDelm1 )  - 1 ) + ;
                   SUBS( cUpStr, nPos2 + LEN(cDelm2) )
      ELSE
         cRVal  := SUBS( cUpStr, nPos1 )
         cUpStr := LEFT( cUpStr, nPos1 )
      ENDIF cDelm2 $ SUBS( cUpStr, nPos1 )
   ENDIF cDelm1 $ cUpStr

   RETU cRVal // ExtrcSIS()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC ShrnkFFN( cFName )	// Shrink Full ( with path) file name    

  LOCA cRVal := cFName
  
  IF LEN( cRVal ) > 80
     cRVal := LEFT( cRVal, 7 ) + '...' + RIGHT( cRVal, 70 ) 
  ENDIF 
  
RETU cRVal // ShrnkFFN()  

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC ExOFNFFP( ;              // Extract Only File Name from Full File Path
               cFFName,;      // Full File Name    
               lExcExtn,;     // Exclude file extention ( Default : .F. )
               lSqueez )      // Squeez to 11 ( Default : .F. )
                
   LOCA cRVal := cFFName,;
        cName := '',;
        cExtn := ''
        
   DEFAULT lExcExtn TO .F.,;
           lSqueez  TO .F.
   
   IF "\" $ cRVal
      cRVal := SUBS( cRVal, RAT( "\", cRVal)+1)
      IF "." $ cRVal
         cName := LEFT( cRVal, RAT( ".", cRVal)-1)
         cExtn := SUBS( cRVal, RAT( ".", cRVal)+1)
      ELSE
         cName := cRVal
         cExtn := ''
      ENDIF   
      IF lSqueez .AND. LEN( cName ) > 8
         cName := LEFT( cName, 7 ) + "~"
      ENDIF
      IF lExcExtn 
         cRVal := cName
      ELSE
         cRVal := cName + IF( EMPTY( cExtn ), '', "." + cExtn )
      ENDIF
   ENDIF
   
RETU cRVal // ExOFNFFP()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC ExOPFFFS( ;              // Extract Only Path Name from Full File Specification
               cFFFSpec )     // Full File Specification
                
   LOCA cRVal := cFFFSpec
      
   IF "\" $ cRVal
      cRVal := LEFT( cRVal, RAT( "\", cRVal ) -1 )  // No last "\"
   ENDIF
   
RETU cRVal // ExOPFFFS()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GeTWinPt()                         // Turkish Alphabet
   RETU "AaBbCcÇçDdEeFfGgÐðHhIýÝiJjKkLlMmNnOoÖöPpQqRrSsÞþTtUuÜüVvWwXxYyZz"
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

******
*
* WTAltSeq    : Turkish Alternate Collating Sequence
*
FUNC WTAltSeq(InStr)                       // Turkish Alt.Collating Sequence
   LOCA OutStr   := '',;
        Sayac    :=  0,;
        ChrPtr   :=  0,;
        TAltPtrn := GeTWinPt()

   FOR  Sayac  := 1 TO LEN(InStr)
      ChrPtr := AT(SUBS(InStr,Sayac,1),TAltPtrn)
      OutStr := OutStr + IF(ChrPtr==0,SUBS(InStr,Sayac,1),CHR(63+ChrPtr))
   NEXT

   RETU OutStr // WTAltSeq()
   
*_.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC Char2Hex( cString )
   LOCA cRVal := '',;
        nSInd := 0
        
   FOR nSInd := 1 TO LEN( cString )
      cRVal += NTOC( ASC( SUBS( cString, nSInd, 1 ) ), 16, 2, "0" )
   NEXT nSInd
      
RETU cRVal // Char2Hex()
   
*_.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.


* 04 00 03 00 00 00 FF FF 04 00 48 02 00 00 10 00 00 00 18 03 00 00 7F 00 00 00 00 00 00 00 00 00 00 00 87 12 00 00 00 00 00 00 00 00 00 00 00 00 00 00 43 6F 75 72 69 65 72 20 4E 65 77 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0A 00 00 00 A2 01 00 00 00


FUNC RFCtrlCods( cString )                // Convert CHR(0..31) to readable format

   LOCA cRVal := cString,;
        nCInd
   
   FOR nCInd := 0 TO 32
      nCInd += IF( nCInd == 10 .OR. nCInd == 13, 1, 0 ) 
      cRVal := STRTRAN( cRVal, CHR( nCInd ), '<c' + NTrim( nCInd ) + '>' )  
   NEXT nCInd
   
   cRVal := STRTRAN( cRVal, CHR( 255 ), '<c255>' )
   
RETU cRVal // RFCtrlCods()   
   
*_.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC StpCtrlCods( cString )                // Strip Out  CHR(0..31) 

   LOCA cRVal := cString,;
        nCInd
   
   FOR nCInd := 0 TO 32
      nCInd += IF( nCInd == 10 .OR. nCInd == 13, 1, 0 ) 
      cRVal := STRTRAN( cRVal, CHR( nCInd ), '' )  
   NEXT nCInd
   
RETU cRVal // StpCtrlCods()   

*_.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC SEVAL(;                              // String Evaluation
            cSource ,; // Source (String)
            xRVal ,;   // Return Value ( any type )
            nStep ,;
            bBlock )   // Code Block tý evaluate

   LOCA nSInd  := 0,;
        c1Char := ''
        
   DEFAULT nStep TO 1
   
   FOR nSInd := 1 TO LEN( cSource ) STEP nStep 
      c1Char := SUBS( cSource, nSInd, 1 )
      EVAL( bBlock, c1Char, nSInd, @xRVal )
   NEXT 
   
RETU xRVal // SEVAL()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC SubStrng2( ;                         // Sub String defined two position
                cString,;
                nBegPos,;
                nEndPos ) 
                
   LOCA cRVal := ''
   
   cRVal := SUBS( cString,  nBegPos, nEndPos - nBegPos + 1 )
                                    
                  
RETU cRVal //  SubStrng2()
                   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*
   f.ExpL2Arr() : cExpressionsList => aExpressionsList 
   
   6517 : Born while ExprChek.prg
*/
FUNC ExpL2Arr( ;                           // Expression List to Array
              cExpList )
              
   LOCA aRVal  := {},;
        c1Char := '',;
        c1Expr := '',;
        cDelmt := ',',;
        nPnter :=  0,;
        nOpBlk :=  0,;             // Open Block Count
        cBlBeg := '',;             // Block beginning Char
        cBlEnd := '',;             // Block ending Char 
        cOBMrks := "([{'" + '"',;  // Open block markers
        cOEMrks := ")]}'" + '"'    // End of block markers
   
   WHILE !EMPTY( cExpList )
      c1Char := SUBS( cExpList, ++nPnter, 1 )
      IF c1Char == cDelmt
         c1Expr := LEFT( cExpList, nPnter - 1 )
         AADD( aRVal, c1Expr  )
         cExpList := ALLTRIM( SUBS( cExpList, nPnter + 1 ) )
         nPnter := 0  
      ELSE   
         IF c1Char $ cOBMrks
            cBlBeg := c1Char
            cBlEnd := SUBS( cOEMrks, AT( c1Char, cOBMrks ), 1 )
            nOpBlk := 1  
            WHILE nOpBlk > 0 .AND. ++nPnter < LEN( cExpList )
               c1Char := SUBS( cExpList, nPnter, 1 )
               IF c1Char == cBlEnd 
                  --nOpBlk
               ELSEIF c1Char == cBlBeg
                  ++nOpBlk
               ENDIF
            ENDDO
            IF nOpBlk > 0      // Syntax ERROR ! ( açýlýp sarmamýþ yârin kollarý ! )
               c1Expr   := ALLTRIM( cExpList )
               AADD( aRVal, c1Expr  )
               cExpList := ''
            ENDIF nOpBlk > 0      
         ENDIF c1Char $ cOBMrks
      ENDIF c1Char == cDelmt
      IF ! cDelmt $ cExpList .OR. nPnter >= LEN( cExpList )
         c1Expr  := ALLTRIM( cExpList )
         IF !EMPTY( c1Expr )
            AADD( aRVal, c1Expr  )
         ENDIF   
         cExpList := ''
      ENDIF cDelmt $ cExpList 
   ENDDO   
    
RETU aRVal // ExpL2Arr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   f.ExprChek( <cMultipleExpressions> ) => <cResult> 
   
   <cResult> : '', if passed; else erroneous claus.
   
   6517 : Born while ExprChek.prg
   
   Usage Example :
   
PROC TestExpr( cExprs )
   LOCA cResult := ExprChek( cExprs )
   MsgBox( IF( EMPTY( cResult ), "passed.",;
               "Syntax error in expression :" + CRLF2 + cResult ) )
               
RETU // TestExpr() 
   
   
*/

FUNC ExprChek( cExpress )

   LOCA aExpress := ExpL2Arr( cExpress ),;
        nEInd    :=  0,;
        c1Exprsn := '',;
        cRVal    := ''
        
   FOR nEInd := 1 TO LEN( aExpress )
      c1Exprsn := aExpress[ nEInd ]
      IF !EMPTY( cRVal := Exp1Chek( c1Exprsn ) )
         EXIT FOR         
      ENDIF
   NEXT nEInd 
   
RETU cRVal // ExprChek()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*
   f.Exp1Chek( <cSingleExpression> ) => <cResult> 
   
   <cResult> : '', if passed; else erroneous claus.
   
   6517 : Born while ExprChek.prg
*/
FUNC Exp1Chek( ;                          // Syntax Checking on a single expression  
                 c1Exprsn )
                 
   LOCA cRVal   := '',;
        c1Char  := '',;
        c1Atom  := '',;
        cDelmt  := ',',;
        nPnter  :=  0,;
        cBPrnts := "([{'" + '"',;  // Parantesis Begin
        cEPrnts := ")]}'" + '"',;  // Parantesis End
        cOprtrs := "+-/*,@$&!<>=#",;
        cVoidEs := '"(' + "'",;
        c1stChr := '',;
        aLogics := { "AND", "OR", "NOT"  },;
        aBrackts := { 0, 0, 0, 0, 0 },;
        nBracket := 0

   LOCA cTermtors := cBPrnts + cEPrnts + cOprtrs + ". ",;
        nAInd := 0,;
        c1ExpSav := c1Exprsn
        

   c1Exprsn := STRTRAN( c1Exprsn,' ', '' )  // Is this NoP ?
   
   WHILE nPnter < LEN( c1Exprsn )
   
      c1Char := SUBS( c1Exprsn, ++nPnter, 1 )
      
      IF ISALPHA( c1Char ) .OR. ( !EMPTY( c1Atom ) .AND. c1Char == "_" )
         IF EMPTY( c1Atom ) .AND. nPnter > 1 
            c1stChr := SUBS( c1Exprsn, nPnter -1, 1 )
         ENDIF
         c1Atom += c1Char
      ELSE
         IF ISDIGIT( c1Char )
            c1Atom += IF( EMPTY( c1Atom ), '', c1Char )
         ELSE   
            IF c1Char $ cTermtors 
               IF c1Char == "." .AND. c1stChr == "."
                  IF ( ASCAN( aLogics, UPPE( SubStrng2( c1Exprsn, nPnter-3, nPnter-1 ))) > 0 .OR. ; 
                       ASCAN( aLogics, UPPE( SubStrng2( c1Exprsn, nPnter-2, nPnter-1 ))) > 0 )
                     c1Atom := ''
                     c1stChr := ''
                  ENDIF ASCAN( ...                     
               ENDIF c1Char == "."
               IF !EMPTY( c1Atom ) .AND. !c1Char $ cVoidEs
                  IF "U" $ TYPE( c1Atom  ) 
                     cRVal := c1Atom 
                     EXIT 
                  ENDIF   
               ENDIF   
               c1Atom  := ''
               c1stChr := ''
               IF c1Char $ cBPrnts .OR. c1Char $ cEPrnts
                  IF c1Char $ cBPrnts 
                     nBracket := AT( c1Char, cBPrnts )
                     IF nBracket > 3
                        IF aBrackts[ nBracket ] > 0
                           --aBrackts[ nBracket ]
                        ELSE
                           ++aBrackts[ nBracket ]
                        ENDIF
                     ELSE      
                        ++aBrackts[ nBracket ]
                     ENDIF nBracket > 3
                  ELSE // c1Char $ cEPrnts
                     nBracket := AT( c1Char, cEPrnts )
                     IF nBracket > 3
                        IF aBrackts[ nBracket ] > 0
                           --aBrackts[ nBracket ]
                        ELSE
                           ++aBrackts[ nBracket ]
                        ENDIF
                     ELSE      
                        --aBrackts[ nBracket ]
                     ENDIF nBracket > 3
                  ENDIF c1Char $ cBPrnts
               ENDIF c1Char $ cBPrnts .OR. c1Char $ cEPrnts
            ENDIF c1Char $ cTermtors   
         ENDIF ISDIGIT( c1Char )
      ENDIF ISALPHA( c1Char )
   ENDDO  nPnter < LEN( c1Exprsn )
   
   IF ASCAN( aBrackts, { | n1 | n1 # 0 } ) > 0 
      cRVal := c1ExpSav
   ENDIF   
   
   IF !EMPTY( c1Atom ) .AND. EMPTY( cRVal )  
      IF "U" $ TYPE( c1Atom  ) 
         cRVal := c1Atom 
      ENDIF   
   ENDIF   
   
RETU cRVal // Exp1Chek()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC ExpTChek(;                           // Expression Type Check
               cExpression,;
               cType ) 
               
   LOCA lRVal := ( VALTYPE( &cExpression ) == cType )           
   
RETU lRVal // ExpTChek()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
