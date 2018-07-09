/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 * Copyright 2018 Sidorov Aleksandr <aksidorov@mail.ru>  Dmitrov, Moscow region
 *
*/
#define _HMG_OUTLOG

#include "minigui.ch"
#include "tsbrowse.ch"
#include "word.ch"

#define wdWord8TableBehavior 0 
#define wdWord9TableBehavior 1
#define wdAutoFitFixed       0
#define wdAutoFitContent     1
#define wdLineStyleSingle    1

#define PBM_SETPOS          1026
#xcommand TRY                           => BEGIN SEQUENCE WITH {|__o| break(__o) }
#xcommand CATCH [<!oErr!>]              => RECOVER [USING <oErr>] <-oErr->

* =====================================================================================
FUNCTION Brw2Doc(oBrw, cFile, lActivate, hProgress, aTitle, hFont, lSave, bExtern )
   LOCAL oWord, oText, oRange, oTbl, oActive, oMarks, cText, aRepl
   LOCAL cMsg, nRowDbf, nColDbf, cVal, cTitle, nStart, aFont
   LOCAL nTotal, nLine  := 1, nCount := 0, nLenHead := 0
   LOCAL nmerge := 1, flag_new_OutWrd:=.f.
   Local nRow, nCol, uData, nEvery, nColHead, nVar
   Local nRecNo := ( oBrw:cAlias )->( RecNo() ), ;
         nOldRow := oBrw:nLogicPos(), ;
         nOldCol := oBrw:nCell
   Local aColSel   := nil   // ���������� �� �������� �������� (�� ����� �������) ����� ����� ��� ����� ������������
   Local bPrintRow := nil   // ���� ���� �� ������ ������, ���������� T/F - ���� .F. ���������� ������
   Local findObject, aClr, nWidthTsb, nLeftRightMargin, nPxLRM
   Local oColumn, nWidth, nWidthWordTsb, nPxToPnt
  
   Default cFile := "", lActivate := .T., hProgress := nil
   Default aTitle := {"",0}, hFont := 10, lSave := .F. , bExtern := nil

   CursorWait()

   If oBrw:lSelector
      oBrw:aClipBoard := { ColClone( oBrw:aColumns[ 1 ], oBrw ), 1, "" }
      oBrw:DelColumn( 1 )
   EndIf

   If hProgress != Nil
      SendMessage(hProgress, PBM_SETPOS, nCount, 0)
   EndIf

   oBrw:lNoPaint := .F.

   If hProgress != Nil
      nTotal := oBrw:nLen  
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * .02 ) ) // refresh hProgress every 2 %
   EndIf

   // ���������� Ole �� HBOLE.lib
   //oWord := TOleAuto():New( "Word.Application" )
   //IF Ole2TxtError() != 'S_OK'

   // ���������� Ole �� HBWIN.lib
   // ��� ������ Harbour MiniGUI Extended Edition 18.05 � ����
   Try
      oWord := CreateObject( "Word.Application" )
   Catch
      cMsg := REPLICATE( "-._.", 16 ) + ";;"
      IF Hb_LangSelect() == "ru.RU1251"
         cMsg += SPACE( 5 ) + "�� ���� ���������� MS Word �� ���������� !;;"
         cMsg += SPACE( 5 ) + " ��� ������ [" + win_oleErrorText() + "];;"
         cVal := "������!"
      ELSE
         cMsg += SPACE( 5 ) + "On this computer MS Word is not installed !;;"
         cMsg += SPACE( 5 ) + " Error code [" + win_oleErrorText() + "];;"
         cVal := "Error!"
      ENDIF
      cMsg += REPLICATE( "-._.", 16 ) + ";;"
      cMsg := AtRepl( ";", cMsg, CRLF )
      MsgStop( cMsg , cVal )
      Return .F.
   End Try

   oWord:Documents:Add()
   oActive := oWord:ActiveDocument()
   oMarks  := oActive:BookMarks
   oText   := oWord:Selection()
   oWord:Visible := .F.  // ���� ������� ������ ��������� � Word-�

   // ����� ������������ � �������� ����� ��� DOC.
   // ������� ��������� ��� Word ����� ������� (points)
   // ��� ��� ������ ������� ������������ � ��������, �� ����� ������� ����� � �������� 
   nWidthTsb := oBrw:GetAllColsWidth()    // ������ ���� ������� ������� (�������)
   ?  "  ------ nWidthTsb=",nWidthTsb,"(px, �������)"

   // ������ ������ ������
   // ��������: http://biznessystem.ru/kakoj-razmer-v-pikselyah-imeet-list-formata-a4/
   // �4 = 2480 x 3508 px ��� dpi=300  // �4 = 1240 x 1754 px ��� dpi=150
   // �3 = 3508 x 4961 px ��� dpi=300  // �3 = 1754 x 2480 px ��� dpi=150

   // ������ ������ ������� �� ����� = ������ ����� + ������ ������ 
   nLeftRightMargin := 29     // ������� (points) (�������� 1 ��) - ������ �����
   nPxLRM := 38.8 * 2         // �������� - ������ ����� + ������ ������
   
   // ------- ��������� ���������� �������� (�����) ------- 
   If nWidthTsb + nPxLRM >= 1754
      ? "  ==> The size of the paper to print the table is larger than A4"
      // Word ����� ����������� � ��������� �������� - 55,87 �� �� ����� �� ������ �����. 
      // 55.87 ����������� ����� 1 583.717 �������
      // ������ ����� ������� ��� � A4 (210�297 ��) == 297
      // 297 ����������� ����� 841.889862 ������ 
      oWord:ActiveDocument:PageSetup:PageWidth = 1583
      oWord:ActiveDocument:PageSetup:PageHeight = 841
      // ������� ����������
      oWord:ActiveDocument:PageSetup:Orientation := wdOrientPortrait
   Else
      ? "  ==> The size of the paper to print the table is A4 "
      oWord:ActiveDocument:PageSetup:PaperSize := wdPaperA4 
      If nWidthTsb + nPxLRM < 1240
         // ������� ����������
         oWord:ActiveDocument:PageSetup:Orientation := wdOrientPortrait
      Else
         // ��������� ����������
         oWord:ActiveDocument:PageSetup:Orientation := wdOrientLandscape
      Endif
   Endif
   
   // ���� �������� (������ ����� � ������)
   oWord:ActiveDocument:PageSetup:LeftMargin  := nLeftRightMargin //~1 ��
   oWord:ActiveDocument:PageSetup:RightMargin := nLeftRightMargin //~1 ��
   // ���� �������� (������ ������ � �����)
   oWord:ActiveDocument:PageSetup:TopMargin    := nLeftRightMargin //~1 ��
   oWord:ActiveDocument:PageSetup:BottomMargin := nLeftRightMargin //~1 ��

   // ------- ��������� ������������ ������ ��������� -------
   oWord:Options:CheckSpellingAsYouType := .F.

   // -------- ��������� ������� ------------------
   cTitle:= aTitle[1]
   cTitle := AllTrim( cTitle )
   if !Empty(cTitle) 
     oText:HomeKey(wdStory)         // � ������ ������
     aFont := GetFontParam( aTitle[2] )
     oText := oWord:Selection()
     oText:Text := cTitle + CRLF
     oText:InsertAfter(CRLF) 
     oText:Font:Name = aFont[1]
     oText:Font:Size = aFont[2]
     oText:Font:Bold = aFont[3]
     aClr := BLACK
     oText:Font:Color = RGB(aClr[1],aClr[2],aClr[3])
     oText:ParagraphFormat:Alignment = wdAlignParagraphRight
     oText:ParagraphFormat:Alignment = wdAlignParagraphCenter
     oText:HomeKey(wdStory)        // � ������ ������
   endif

   if ! Empty( oBrw:aSuperHead )
     nLenHead++
   endif

   nLenHead++ // ����� �������
   if AScan( oBrw:aColumns, { |o| o:cFooting != Nil  } ) > 0
     nLenHead++
   endif
   nRowDbf := oBrw:nLen - oBrw:nAt + nLenHead + 1  // ���-�� ����� � ������� + ����� + ������ �������
   nColDbf := Len( oBrw:aColumns )                 // ���-�� �������� � �������

   // ------- �������� ������� ---------------
   oRange = oActive:Range(len(cTitle)+2)

   ////////// ������� � ��������������� �� ������ �������� (������� 1) //////////////
   //oTbl:= oWord:ActiveDocument:Tables:Add(oRange,nRowDbf,nColDbf,wdWord9TableBehavior,wdAutoFitContent)

   ///////// ������� ��� �������������� �� ������ �������� (������� 2)  ////////////
   oTbl:= oWord:ActiveDocument:Tables:Add(oRange,nRowDbf,nColDbf,wdWord8TableBehavior,wdAutoFitFixed)
   oTbl:Borders:OutsideLineStyle := wdLineStyleSingle 
   oTbl:Borders:OutsideLineWidth := wdLineWidth100pt 
   oTbl:Borders:InsideLineStyle := wdLineStyleSingle 

   nWidth := oWord:ActiveDocument:PageSetup:PageWidth  
   nWidthWordTsb := oWord:PixelsToPoints( nWidthTsb, 0 )

   // ������ ������ ������� ��������������� ������ Tsbrowse 
   oColumn := oTbl:Columns 
   For nCol := 1 To Len( oBrw:aColumns )
      nPxToPnt := oWord:PixelsToPoints( oBrw:aColumns[ nCol ]:nWidth, 0 )
      oColumn[ nCol ]:Width := (nWidth - 2 * nLeftRightMargin) / nWidthWordTsb * nPxToPnt
   Next
   ///////// ������� ��� �������������� �� ������ �������� (������� 2)  ////////////

   ( oBrw:cAlias )->( Eval( oBrw:bGoTop ) )  // �� ������ ������ � �������

   cText := ""

   oText:ParagraphFormat:Alignment = wdAlignParagraphCenter
   For nRow := 1 To oBrw:nLen

      If nRow == 1

         nStart := nLine

         If ! Empty( oBrw:aSuperHead )

            For nCol := 1 To Len( oBrw:aSuperHead )
               nVar := If( oBrw:lSelector, 1, 0 )
               uData := If( ValType( oBrw:aSuperhead[ nCol, 3 ] ) == "B", Eval( oBrw:aSuperhead[ nCol, 3 ] ), ;
                                     oBrw:aSuperhead[ nCol, 3 ] )
               oRange:=oActive:Range(oTbl:Cell( nLine, nmerge):Range:Start, oTbl:Cell( nLine, nmerge+oBrw:aSuperHead[ nCol, 2 ] - oBrw:aSuperHead[ nCol, 1 ]):Range:End)
               oRange:Cells:Merge()
               oTbl:Cell(nLine, nmerge):Range:ParagraphFormat:Alignment:= wdAlignParagraphCenter
               oTbl:Cell(nLine, nmerge ):Range:Text := uData
               nmerge++
            Next

            nStart := nLine ++
         EndIf

         nColHead := 0

         For nCol := 1 To Len( oBrw:aColumns )

            If aColSel != Nil .and. AScan( aColSel, nCol ) == 0
               Loop
            EndIf

            uData := If( ValType( oBrw:aColumns[ nCol ]:cHeading ) == "B", Eval( oBrw:aColumns[ nCol ]:cHeading ), ;
                                  oBrw:aColumns[ nCol ]:cHeading )

            If ValType( uData ) != "C"
               Loop
            EndIf

            uData := StrTran( uData, CRLF, Chr( 10 ) )
            nColHead ++
            oTbl:Cell(nLine, nColHead ):Range:ParagraphFormat:Alignment:= wdAlignParagraphCenter
            oTbl:Cell( nLine, nColHead ):Range:Text := uData

            If hProgress != Nil

               If nCount % nEvery == 0
                  SendMessage(hProgress, PBM_SETPOS,nCount,0)
               EndIf

               nCount ++
            EndIf
         Next

         nStart := ++ nLine

      EndIf

      If bPrintRow != Nil .and. ! Eval( bPrintRow, nRow )
         oBrw:Skip( 1 )
         Loop
      EndIf

      aRepl := {}
      For nCol := 1 To Len( oBrw:aColumns )
         If aColSel != Nil .and. AScan( aColSel, nCol ) == 0
            Loop
         EndIf

         uData := Eval( oBrw:aColumns[ nCol ]:bData )
         If ValType( uData ) == "C" .and. At( CRLF, uData ) > 0
            uData := StrTran( uData, CRLF, "&&" )
            If AScan( aRepl, nCol ) == 0
               AAdd( aRepl, nCol )
            EndIf
         EndIf
         uData := If( uData == NIL, "", Transform( uData, oBrw:aColumns[ nCol ]:cPicture ) )
         uData  :=  If( ValType( uData )=="D", DtoC( uData ), If( ValType( uData )=="N", Str( uData ) , ;
                    If( ValType( uData )=="L", If( uData ,".T." ,".F." ), cValToChar( uData ) ) ) )

         cText += Trim( uData ) + Chr( 9 )

         If hProgress != Nil

            If nCount % nEvery == 0
               SendMessage(hProgress, PBM_SETPOS, nCount, 0)
            EndIf

            nCount ++
         EndIf
      Next

      oBrw:Skip( 1 )

      IF (Len( cText ) < 20000).and.!(nRow == oBrw:nLen)
        cText += CRLF
      ELSE
	flag_new_OutWrd:=.t.
      ENDIF
      ++nLine

      //
      // Every 20k set text into Word , using Clipboard , very easy and faster.
      //

      IF flag_new_OutWrd
        CopyToClipboard(cText)
        oRange:=oActive:Range(oTbl:Cell( nStart, 1):Range:Start, oTbl:Cell( nLine-1, nColDbf):Range:End)
        oRange:Select()
        oRange:Paste()
        cText := ""
        nStart := nLine 
        flag_new_OutWrd:=.f.
      EndIf

   Next

   If AScan( oBrw:aColumns, { |o| o:cFooting != Nil  } ) > 0

      For nCol := 1 To Len( oBrw:aColumns )

         If ( aColSel != Nil .and. AScan( aColSel, nCol ) == 0 ) .or. oBrw:aColumns[ nCol ]:cFooting == Nil
            Loop
         EndIf

         uData := If( ValType( oBrw:aColumns[ nCol ]:cFooting ) == "B", Eval( oBrw:aColumns[ nCol ]:cFooting ), ;
                      oBrw:aColumns[ nCol ]:cFooting )
         uData := cValTochar( uData )
         uData := StrTran( uData, CRLF, Chr( 10 ) )
         oTbl:Cell( nLine, nCol):Range:Text := uData
      Next
   EndIf

   If oBrw:lIsDbf
      ( oBrw:cAlias )->( DbGoTo( nRecNo ) )
      oBrw:GoPos(nOldRow, nOldCol)
   EndIf

   // ��������� ����� ���������� ���� "&&" - ������������� ������ �������
   If ! Empty( aRepl )
      For nCol := 1 To Len( aRepl )
        oRange:=oActive:Range(oTbl:Cell( nLenHead+1, nCol):Range:Start, oTbl:Cell( nRowDbf-1, nColDbf):Range:End)
        oRange:Select()
        findObject := oRange:Find
        MSWordFind_Replace(findObject, "&&", "^l") 
      Next           
   EndIf

   CLEARCLIPBOARD()

   If oBrw:lSelector
      oBrw:InsColumn( oBrw:aClipBoard[ 2 ], oBrw:aClipBoard[ 1 ] )
      oBrw:lNoPaint := .F.
   EndIf

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, nCount, 0 )
   EndIf

   If bExtern != Nil
      Eval( bExtern, oTbl, oBrw, oActive )
   EndIf

   If ! Empty( cFile ) .and. lSave
      oActive:SaveAs( cFile, wdFormatDocument )

      If ! lActivate
         CursorArrow()
         oWord:Quit()
         oBrw:Reset()
         Return Nil
      EndIf
   EndIf

   CursorArrow()

   oBrw:Reset()
   oBrw:Display()

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

   If lActivate
      oText:HomeKey(wdStory)           // � ������ ������
      oWord:Visible := .T.
      SetWordWindowToForeground(oWord) // ���� Word �� �������� ����
   EndIf

RETURN NIL

//////////////////////////////////////////////////////////////////////
PROCEDURE MSWordFind_Replace(oFind, cFind, cReplace) 

   With object oFind 
   :ClearFormatting() 

   :Execute(cFind,0,0,0,0,0,1,1,0,cReplace,wdReplaceAll) 

   :ClearFormatting() 
   END 

RETURN 

//////////////////////////////////////////////////////////////////////
// ���� Word �� �������� ����
FUNCTION SetWordWindowToForeground(oWord)
   LOCAL hWnd, nVer, cCaption, cTitle

   // ------------------- ����� ������ ��������� ���� ��������� --------------
   hWnd := 0
   nVer := VAL( oWord:Version ) // ������ Word
   IF nVer > 14  // Word 2010
      hWnd := oWord:ActiveDocument:ActiveWindow:Hwnd 
   ELSE
      //hWnd:=oWord:hwnd - ��� ������ ������ !
      cCaption := oWord:Windows[1]:Caption  
      cTitle := cCaption + " - MICROSOFT WORD"
      hWnd := FindWindowEx(,,, cTitle )    
      IF hWnd == 0
         cTitle := cCaption + " [����� ������������ ����������������] - MICROSOFT WORD"
         hWnd := FindWindowEx(,,, cTitle )    
      ENDIF
   ENDIF

   IF hWnd > 0
      ShowWindow( hWnd, 6 )      // MINIMIZE windows
      ShowWindow( hWnd, 3 )      // MAXIMIZE windows
      BringWindowToTop( hWnd )   // A window on the foreground
   ENDIF
  
   RETURN NIL

* =======================================================================================
FUNCTION WordOleExtern( hProgress, lTsbFont, oTbl, oBrw, oActive )
   LOCAL nLine, nCol, nRow, aFColor, nBColor, nFColor, nStart, oPar
   LOCAL nCount, nTotal, nEvery, aFont, oCol, hFont, nmerge 

   // nLine := 1  // ����� ������� 
   // nLine := 2  // ������ ������ 
   // nLine := 3  // ���������� �������, ���� ���� 
   // nLine := 4  // ����� �������, ���� ���� 
   // nLine := 5  // ������ �������, ������ ������ (���� ���� ���������� � ����� �������)
   // nLine := nLine + oBrw:nLen // ������ �������, ���� ���� 

   // ���� ������ ������ ������� (������ ����� �����)
   aFColor := BLUE
   nLine := 1  
   oTbl:Cell(nLine, 1):Range:Font:Color := RGB(aFColor[1],aFColor[2],aFColor[3])

   nStart := 1

   // ������� ����� ���� � ������ ����������� �������
   If oBrw:lDrawSuperHd //! Empty( oBrw:aSuperHead )

      nmerge :=1
      nLine := nStart  // ���������� �������, ���� ���� 

      For nCol := 1 To Len( oBrw:aSuperHead )

         nFColor := myColorN     ( oBrw:aSuperhead[ nCol, 4 ], oBrw, nCol ) // oBrw:nClrSpcHdFore
         nBColor := myColorN     ( oBrw:aSuperhead[ nCol, 5 ], oBrw, nCol ) // oBrw:nClrSpcHdBack
         aFont   := GetFontParam( oBrw:aSuperHead[ nCol, 7 ] )  // ����� �����������

         oTbl:Cell(nLine, nmerge):Range:Font:Color    := nFColor  // ���� ������ �����
         oTbl:Cell(nLine, nmerge):Range:Shading:BackgroundPatternColor := nBColor

         If lTsbFont 
           oTbl:Cell(nLine, nmerge):Range:Font:Name := aFont[ 1 ]
           oTbl:Cell(nLine, nmerge):Range:Font:Size := aFont[ 2 ]
           oTbl:Cell(nLine, nmerge):Range:Font:Bold := aFont[ 3 ]
         Endif
         nmerge++

      Next
  
      nStart ++
   EndIf

   // ������� ����� ���� � ������ ����� �������
   If oBrw:lDrawHeaders    

      nLine := nStart

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ]
          nFColor := myColorN( oCol:nClrHeadFore, oBrw, nCol ) 
          nBColor := myColorN( oCol:nClrHeadBack, oBrw, nCol ) 

          oTbl:Cell(nLine, nCol):Range:Font:Color    := nFColor  // ���� ������ �����
          oTbl:Cell(nLine, nCol):Range:Shading:BackgroundPatternColor := nBColor // ���� ���� �����
          If lTsbFont 
            hFont := oCol:hFontHead              // ����� ����� �������
            aFont := myFontParam( hFont, oBrw, nCol, 0 )
            oTbl:Cell(nLine, nCol):Range:Font:Name := aFont[ 1 ]
            oTbl:Cell(nLine, nCol):Range:Font:Size := aFont[ 2 ]
            oTbl:Cell(nLine, nCol):Range:Font:Bold := aFont[ 3 ]
          Endif
      Next
      nStart ++
   Endif

   If hProgress != Nil
      nTotal := oBrw:nLen 
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * 0.05 ) ) // refresh hProgress every 5 %
   EndIf

   Eval( oBrw:bGoTop )  // ������� �� ������ �������
   nCount := 0

   // ������� ����� ���� � ������ ����� ���� ������� �������
   For nLine := 1 TO oBrw:nLen

      nRow := nStart + nLine - 1 

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ] 
          nFColor := myColorN( oCol:nClrFore, oBrw, nCol, oBrw:nAt ) 
          nBColor := myColorN( oCol:nClrBack, oBrw, nCol, oBrw:nAt ) 
 
          oTbl:Cell(nRow, nCol):Range:Font:Color    := nFColor  // ���� ������ �����
          oTbl:Cell(nRow, nCol):Range:Shading:BackgroundPatternColor := nBColor // ���� ���� �����

         If lTsbFont 
            aFont := myFontParam( oCol:hFont, oBrw, nCol, oBrw:nAt )
            oTbl:Cell(nRow, nCol):Range:Font:Name := aFont[ 1 ]
            oTbl:Cell(nRow, nCol):Range:Font:Size := aFont[ 2 ]
            oTbl:Cell(nRow, nCol):Range:Font:Bold := aFont[ 3 ]
         Endif
      Next

      If hProgress != Nil

         If nCount % nEvery == 0
            SendMessage(hProgress, PBM_SETPOS,nCount,0)
         EndIf

         nCount ++
      EndIf

      oBrw:Skip(1)
   Next
 
   nStart := nRow + 1

 
   // ������� ����� ���� � ������ ������� �������
   If oBrw:lDrawFooters

      nLine := nStart

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ] 
          nFColor := myColorN( oCol:nClrFootFore, oBrw, nCol, oBrw:nAt ) 
          nBColor := myColorN( oCol:nClrFootBack, oBrw, nCol, oBrw:nAt ) 

          oTbl:Cell(nLine, nCol):Range:Font:Color    := nFColor  // ���� ������ �����
          oTbl:Cell(nLine, nCol):Range:Shading:BackgroundPatternColor := nBColor // ���� ���� �����
   
          If lTsbFont 
             aFont := myFontParam( oCol:hFontFoot, oBrw, nCol, 0 )
   
            oTbl:Cell(nLine, nCol):Range:Font:Name := aFont[ 1 ]
            oTbl:Cell(nLine, nCol):Range:Font:Size := aFont[ 2 ]
            oTbl:Cell(nLine, nCol):Range:Font:Bold := aFont[ 3 ]
          Endif
      Next

      nLine++                          
      nStart := nLine
   Endif

   // ���.������� ��� ��������
   nLine := nStart + 1
   aFColor := RED
   oPar := oActive:Paragraphs:Add()
   oPar:Range:Font:Color := RGB(aFColor[1],aFColor[2],aFColor[3])   
   oPar:Range:Font:Name  := "Times New Roman"   
   oPar:Range:Font:Size  := 14   
   oPar:Range:Font:Bold  := .T.   
   oPar:Range:Text:= CRLF + "End table !" + CRLF

   RETURN Nil

* =======================================================================================
STATIC FUNCTION myColorN( nColor, oBrw, nCol, nAt )

   If Valtype( nColor ) == "B"
      If empty(nAt) 
         nColor := Eval( nColor, nCol, oBrw )
      Else
         nColor := Eval( nColor, nAt, nCol, oBrw )
      EndIf
   EndIf  

   If Valtype( nColor ) == "A"
      nColor := nColor[1]
   EndIf  

RETURN nColor

* =======================================================================================
STATIC FUNCTION myFontParam( hFont, oBrw, nCol, nAt )
   LOCAL aFont, oCol := oBrw:aColumns[ nCol ] 
   DEFAULT nAt := 0
   // ����� ����� �������
   hFont := If( hFont == Nil, oBrw:hFont, hFont )  
   hFont := If( ValType( hFont ) == "B", Eval( hFont, nAt, nCol, oBrw ), hFont )  

   If empty(hFont)
      aFont    := array(3) 
      aFont[1] := _HMG_DefaultFontName
      aFont[2] := _HMG_DefaultFontSize
      aFont[3] := .F.
   Else
      aFont := GetFontParam( hFont )
   EndIf

RETURN aFont
