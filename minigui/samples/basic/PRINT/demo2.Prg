/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com/
*/

#include <minigui.ch>
#include "miniprint.ch"

//============================================================================================
Function Main()
   Local myPrinters:=aPrinters(), lPreview:=.F.
   Local aPapers:={ PRINTER_PAPER_LETTER ,;
      PRINTER_PAPER_LEGAL,;
      PRINTER_PAPER_A4,;
      PRINTER_PAPER_CSHEET,;
      PRINTER_PAPER_DSHEET,;
      PRINTER_PAPER_ESHEET,;
      PRINTER_PAPER_LETTERSMALL,;
      PRINTER_PAPER_TABLOID,;
      PRINTER_PAPER_LEDGER,;
      PRINTER_PAPER_EXECUTIVE }

   Local papers_to_select:={ "Letter, 8 1/2- by 11-inches",;
      "Legal, 8 1/2- by 14-inches",;
      "A4 Sheet, 210- by 297-millimeters",;
      "C Sheet, 17- by 22-inches",;
      "D Sheet, 22- by 34-inches",;
      "E Sheet, 34- by 44-inches",;
      "Letter Small, 8 1/2- by 11-inches",;
      "Tabloid, 11- by 17-inches",;
      "Ledger, 17- by 11-inches",;
      "Executive, 7 1/4- by 10 1/2-inches" }

   Load Window demo2 As Main
   Main.Combo_Printers.Value:=1
   Main.Combo_Papers.Value:=1
   Main.preview_not_yes.Value:=lPreview
   Main.RadioGroup_1.Value:=1
   Main.Combo_Printers.SetFocus
   Main.Center
   Main.Activate

Return Nil
//============================================================================================
Function printers_filter()
   Local k, newPrinters:={}, combo_item
   if Main.Check_1.Value
      if Main.Combo_Printers.ItemCount > 0
         For k:=1 to Main.Combo_Printers.ItemCount
            combo_item:=Main.Combo_Printers.Item(k)
            if Left(combo_item,2) <> "\\"
               AADD(newPrinters,combo_item)
            endif
         Next k
         if Len(newPrinters) <= 0
            MsgExclamation("No Local Printers Installed in this System !!")
         endif
      else
         MsgExclamation("No printers Installed !!")
      endif
   else
      newPrinters:=aPrinters()
   endif
   if Len(newPrinters) > 0
      Main.Combo_Printers.DeleteAllItems
      For k:=1 to Len(newPrinters)
         Main.Combo_Printers.AddItem(newPrinters[k])
      Next k
      Main.Combo_Printers.Value:=1
   else
      MsgExclamation("No printers Installed !!")
   endif
   Main.Combo_Printers.SetFocus
Return Nil
//============================================================================================
Function _Print_My_Job(xPaper)
   Local lSuccess, myDataToPrint:={}, i, k, lResponse:=.T., zLine
   Local wPrinter:=Alltrim(Main.Combo_Printers.Item(Main.Combo_Printers.Value)), docName:="Print test"

   if Main.Combo_Printers.Value <=0 .OR. Main.Combo_Printers.Value == Nil
      MsgExclamation("Please, select a valid printer !!")
      Main.Combo_Printers.SetFocus
      Return Nil
   endif

   For k:=1 to 10
      AADD( myDataToPrint, "This is My Print Job - Line "+StrZero(k,2) )
   Next k

   if Main.preview_not_yes.Value == .F.
      PlayBeep()
      lresponse:=MsgYesNo("Are you sure that you want to print this job ??","Confirm Please")
   endif

   if lresponse == .F.
      Main.Combo_Printers.SetFocus
      Return Nil
   endif

   if Main.preview_not_yes.Value == .F.
      SELECT PRINTER wPrinter TO lSuccess;
         ORIENTATION Main.RadioGroup_1.Value;
         PAPERSIZE xPaper[Main.Combo_Papers.Value];
         DEFAULTSOURCE PRINTER_BIN_AUTO;					// Select your own Paper Source
         QUALITY PRINTER_RES_MEDIUM						// Select your own print quality
   else
      SELECT PRINTER wPrinter TO lSuccess PREVIEW;
         ORIENTATION Main.RadioGroup_1.Value;
         PAPERSIZE xPaper[Main.Combo_Papers.Value];
         DEFAULTSOURCE PRINTER_BIN_AUTO;					// Select your own Paper Source
         QUALITY PRINTER_RES_MEDIUM						// Select your own print quality
   endif	

   if lSuccess == .F.
      MsgStop("Print Error !", "Stop")
      Main.Combo_Printers.SetFocus
      Return Nil
   endif

   START PRINTDOC NAME docName

   For i:=1 to 10

      zLine:=20

      START PRINTPAGE

      @zLine-7,180 PRINT "Page Number : " + Ltrim(Str(i)) ;
         FONT "Arial" SIZE 09 RIGHT

      For k:=1 to Len(myDataToPrint)
         @zLine,030 PRINT myDataToPrint[k] ;
            FONT "Arial" SIZE 10 COLOR BLACK

         zLine += 7
      Next k

      END PRINTPAGE

   Next i

   END PRINTDOC

Return Nil
//============================================================================================