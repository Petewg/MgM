/* 
 * MINIGUI - Harbour Win32 GUI library Demo 
 * 
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com> 
 * http://harbourminigui.googlepages.com/ 
 * 
 * From original source by '2005 Grigory Filatov <gfilatov@front.ru>
 * Improved at 2016 By Pierpaolo Martinello <pier.martinello[at]alice.it>
 * 
*/ 

ANNOUNCE RDDSYS 

#include "minigui.ch"
#include "fileio.ch"

#define PROGRAM "Harbour Log Mailer 1.7"
#define DBG .F.
#define IDI_MAIN 1001
DECLARE WINDOW FORM_2

#define MB_ICONEXCLAMATION 0x30
#define MB_OK 0
#define MB_ICONINFORMATION 64
#define MB_ICONSTOP 16
#define MB_OKCANCEL 1
#define MB_RETRYCANCEL 5
#define MB_SETFOREGROUND 0x10000
#define MB_SYSTEMMODAL 4096
#define MB_TASKMODAL 0x2000
#define MB_YESNO 4
#define MB_YESNOCANCEL 3

*--------*
* SYNTAX: SENDMAIL [silent clog compress ]
* With silent, it doesn't open any window
*
* With compress the compressed filename declares him that will contain the attached ones
*
* Ie. SendMail Y N Test 
* It will send an e-mail without windows and the attached file it is "Test.zip"
*
* Ie Sendmail Y
* It will send an e-mail without windows.
* The possible File attached is drawn by the file Ini
*
* In both the cases will be written the "Sendmail.log" file
*
* for silent and clog are valid Y N or 1 0 or .T. .F. or any char (=.F.)
* Compress arg require silent arg
*
*-----------------------------------------------------------------------------*

Memvar cCfgFile, cLogFile,LogPath
Memvar aEntry, cCryptKey

DECLARE WINDOW Form_2

Static aGet, lchg, namelog
*-----------------------------------------------------------------------------*
PROCEDURE Main( Silent, cLog, Compress)
*-----------------------------------------------------------------------------*
LOCAL cPath := GetStartUpFolder() + "\", cFileName := cFileNoExt( GetExeFileName() )
LOCAL extraTitle , i

   PRIVATE cCfgFile := cPath + Lower(cFileName) + ".ini"
   PRIVATE cLogFile := cPath + Lower(cFileName) + ".log"
   PRIVATE aEntry   := {}, cCryptKey := REPL( "#$@%&", 2 )
   Private LogPath  := GetcurrentFolder()

   DEFAULT Silent to .F., Compress to '', Clog to .F.

   IF valtype(clog) == "C" .and. !empty(clog)
      clog := Lower(clog)
      clog := IF(clog=".t." .or. clog="clog" .or. clog="y" .or. val(clog)>0, .T., .F.)
   ENDIF

   IF File( cLogFile )
      IF clog .or. FileSize( cLogFile ) > 1000000
         Ferase( cLogFile )
      ENDIF
   ENDIF

   aAdd( aEntry, "SMTP" )              //  1
   aAdd( aEntry, "From" )              //  2
   aAdd( aEntry, "To" )                //  3
   aAdd( aEntry, "CC" )                //  4
   aAdd( aEntry, "BCC" )               //  5
   aAdd( aEntry, "Subject" )           //  6
   aAdd( aEntry, "Attachment" )        //  7
   aAdd( aEntry, "Message" )           //  8
   aAdd( aEntry, "Login" )             //  9
   aAdd( aEntry, "LoginMD5" )          // 10
   aAdd( aEntry, "User" )              // 11
   aAdd( aEntry, "PassWord" )          // 12
   aAdd( aEntry, "HTML" )              // 13
   aAdd( aEntry, "Silent" )            // 14
   aAdd( aEntry, "Compress")           // 15
   aAdd( aEntry, "LogPath")            // 16
   aAdd( aEntry, "SendLog")            // 17
   aAdd( aEntry, "Shutdown")           // 18

   aGet := ARRAY(18)
   lchg := .f.                         

   DEFAULT aget[1] TO "smtp.domain.com"
   DEFAULT aget[2] TO "Sender <sender@domain.com>"
   DEFAULT aget[3] TO "Recipient <recipient@domain.com>"
   DEFAULT aget[4] TO SPACE(30)
   DEFAULT aget[5] TO SPACE(30)
   DEFAULT aget[6] TO "Put here only the name of your customer !"
   DEFAULT aget[7] TO {}
   DEFAULT aget[8] TO "This is a Test"
   aGet[ 9] := .F.
   aGet[10] := .F.
   DEFAULT aget[11] TO ""
   DEFAULT aget[12] TO ""
   aGet[13] := 1
   DEFAULT aget[14] TO Silent

   IF Pcount() = 3
      Compress := Lower(Compress)
      Compress := STRTRAN(Compress, ".zip", "")
   ENDIF

   DEFAULT aget[15] TO Compress
   DEFAULT aget[16] TO Left( ExeName(), RAt( "\", ExeName() ) )
   DEFAULT aget[17] TO 1
   DEFAULT aget[18] TO 0

   IF File( cCfgFile )

      BEGIN INI FILE cCfgFile

         For i := 1 To Len(aEntry)
             GET aGet[i] SECTION "Data" ENTRY aEntry[i]
         Next i
         aGet[8]  := STRTRAN( aGet[8], Chr(250), CRLF )
         aGet[12] := decripta( aGet[12], cCryptKey )

      END INI

      LogPath := aget[16]+"\"

   ENDIF
   IF aget[17] = 0
      aget[17] ++
   ENDIF

   aget[18] := min( aget[18],10 )

   IF Empty(Compress)
      compress := aget[15]
   ELSE
      aget[15] := Compress
   ENDIF

   IF valtype(Silent) == "C" .and. !empty(Silent)
      silent := Lower(Silent)
      IF "?" $ silent
          MsgInfo( [Syntax: ] + "Sendmail [Silent] [clear log] [Zipname] "+CRLF+CRLF+;
                  [ ] + "where Silent are Y [.T. or 1 or silent] or N [.F. or 0]" +CRLF+;
                  [ ] + "where clearlog are Y [.T. or 1 or clog] or N [.F. or 0] "+CRLF+;
                  [ ] + "Zipname no need name extension '.zip'"+CRLF+CRLF+;
                  "Ie: SendMail 0 .T. (or SendMail N 1)"+CRLF+;
                  " Will take action clear log and open main window."+CRLF+CRLF+;
                  "Ie: SendMail Y .T. (or SendMail clog silent)"+CRLF+;
                  " Will take action clear log and send mail without GUI.", "Syntax Help" )
          Return
      ENDIF
      silent := IF(Silent=".t." .or. Silent="silent" .or. silent="y" .or. val(silent)>0, .T., .F.)

   ENDIF

   aget[14] := Silent

   SET CENTURY ON 
   SET DATE GERMAN 

   IF Silent
      M_Send(.F.)
      Return
   ENDIF

   extratitle := " [ I send the file(s) attached as "+Compress+".Zip ]" 

   DEFINE WINDOW Form_1 ;
          AT 131,220 ;
          WIDTH 663 ;
          HEIGHT 545 + IF(IsXPThemeActive(), 6, 0) ;
          TITLE PROGRAM ;
          ICON IDI_MAIN ;
          MAIN ;
          NOMINIMIZE NOMAXIMIZE NOSIZE ;
          On INIT ReadLog() ;
          ON RELEASE if(lchg,SaveData(.t.),nil) ;
          FONT "MS Sans Serif" SIZE 10

          DEFINE STATUSBAR
                STATUSITEM ""
                DATE
                CLOCK
          END STATUSBAR

          @ 9,7 FRAME Frame_1 WIDTH 640 HEIGHT 45

          //@ 17,20 BUTTON PicButton_1 PICTURE "SEND" ACTION Readlog() WIDTH 24 HEIGHT 24 TOOLTIP "Send Mail (Alt+S)"
          @ 17,20 BUTTON PicButton_1 PICTURE "SEND" ACTION m_send(.T.) WIDTH 30 HEIGHT 30 TOOLTIP "Send Mail (Alt+S)"
          @ 17,52 BUTTON PicButton_2 PICTURE "CONFIG" ACTION m_config() WIDTH 30 HEIGHT 30 TOOLTIP "Config (Alt+C)"
          @ 17,84 BUTTON PicButton_3 PICTURE "TRASH" ACTION File_Attached(.T.) WIDTH 30 HEIGHT 30 TOOLTIP "Clear the Attachment List (Alt+T)"
          @ 17,116 BUTTON PicButton_4 PICTURE "INFO" ACTION m_about() WIDTH 30 HEIGHT 30 TOOLTIP "About (Alt+A)"
          @ 17,148 BUTTON PicButton_5 PICTURE "SAVE" ACTION Savedata() WIDTH 30 HEIGHT 30 TOOLTIP "Save options"
          @ 17,180 BUTTON PicButton_6 PICTURE "EXIT" ACTION Form_1.Release WIDTH 30 HEIGHT 30 TOOLTIP "Exit (Alt+X)"

          @ 21,240 LABEL Label_0 VALUE "Message Priority:" WIDTH 120 HEIGHT 20
          @ 17,370 RADIOGROUP Radio_0 OPTIONS { "Normal", "Highest", "Low" } VALUE 1 ;
                   WIDTH 66 SPACING 14 TOOLTIP "Select a Message Priority" ON CHANGE Changeinfo() HORIZONTAL

          @ 62,7 FRAME Frame_2 WIDTH 640 HEIGHT 404 //370
          @ 205,15 FRAME Frame_3 WIDTH 135 HEIGHT 55

          @ 84,24 LABEL Label_1 VALUE "SMTP Server" WIDTH 100 HEIGHT 20
          @ 108,24 LABEL Label_2 VALUE "From" WIDTH 100 HEIGHT 20
          @ 131,24 LABEL Label_3 VALUE "To" WIDTH 100 HEIGHT 20
          @ 158,24 LABEL Label_4 VALUE "Cc" WIDTH 100 HEIGHT 20
          @ 158,377 LABEL Label_5 VALUE "Bcc" WIDTH 58 HEIGHT 20
          @ 185,24 LABEL Label_6 VALUE "Subject" WIDTH 100 HEIGHT 20
          @ 210,24 LABEL Label_7 VALUE "Attachment" WIDTH 100 HEIGHT 20
          @ 262,24 LABEL Label_8 VALUE "Message Type" WIDTH 100 HEIGHT 20
          @ 315,24 LABEL Label_9 VALUE "Log Folder" WIDTH 100 HEIGHT 20
          @ 370,24 LABEL Label_10 VALUE "Send Log" WIDTH 100 HEIGHT 20
          @ 472,24 LABEL Label_11 VALUE "LOG FOLDER PATH NOT SET !!! " AUTOSIZE
          @ 434,84 Label 12 Value "Time Shutdown (minutes): After sending the log mail, shutdown the pc ( 0 = disabled )." AUTOSIZE ;
                   TOOLTIP "Shutdown require Admin Rights"

          @ 78,155 TEXTBOX Text_1 HEIGHT 23 WIDTH 480 ON CHANGE  ( aget[1] := Form_1.Text_1.Value, ChangeInfo() )
          Form_1.Text_1.Value := aget[1] 

          @ 104,155 TEXTBOX Text_2 HEIGHT 22 WIDTH 480 ON CHANGE ( aget[2] := Form_1.Text_2.Value , ChangeInfo() )
          Form_1.Text_2.Value := aget[2]

          @ 129,155 TEXTBOX Text_3 HEIGHT 22 WIDTH 480 ON CHANGE ( aget[3] := Form_1.Text_3.Value , ChangeInfo() )
          Form_1.Text_3.Value := aget[3]

          @ 155,155 TEXTBOX Text_4 HEIGHT 22 WIDTH 200 ON CHANGE ( aget[4] := Form_1.Text_4.Value, ChangeInfo() )
          Form_1.Text_4.Value := aget[4]

          @ 155,435 TEXTBOX Text_5 HEIGHT 22 WIDTH 200 ON CHANGE ( aget[5] := Form_1.Text_5.Value, ChangeInfo() )
          Form_1.Text_5.Value := aget[5]

          @ 180,155 TEXTBOX Text_6 HEIGHT 22 WIDTH 480 ON CHANGE ( aget[6] := Form_1.Text_6.Value , ChangeInfo() )
          Form_1.Text_6.Value := aget[6]

          @ 205,155 COMBOBOXEX Combo_7 ITEMS aget[7] HEIGHT 200 WIDTH 450 Tooltip "Attached File List";
                    ON GOTFOCUS MCONTEXT() ON CHANGE SetFcompress()

          Form_1.Combo_7.Value := IF(Len(aget[7]) == 0, 0, 1)

          @ 205,610 BUTTON PicButton_7 PICTURE "OPEN" ACTION File_Attached() ;
                    WIDTH 24 HEIGHT 24 TOOLTIP "Select a File(s) To Attach"

          @ 234,24 CHECKBOX Check_1 CAPTION " Compress" WIDTH 100 HEIGHT 20 ;
                   ;// VALUE ( !Empty(Form_1.Combo_7.DisplayValue) .and. !Empty(Compress) .or. aget[17] > 1) ;
                   VALUE ( !Empty(compress) .or. aget[17] > 1) ;
                   ON CHANGE SetFcompress()

          @ 232,155 EDITBOX Edit_1 WIDTH 480 HEIGHT 190 ON CHANGE aget[8] := Form_1.Edit_1.Value NOHSCROLL

          @ 280,24 RADIOGROUP Radio_1 OPTIONS {"Text","HTML" } VALUE aget[13] ;
                   WIDTH 64 SPACING 0 TOOLTIP "Select a Message Format" ;
                   ON CHANGE ( aget[13] := Form_1.Radio_1.Value,Changeinfo() ) TRANSPARENT HORIZONTAL

          @310,100 BUTTON PicButton_8 PICTURE "OPEN" ACTION LogFolder() ;
                   WIDTH 24 HEIGHT 24 TOOLTIP "Select a log folder."

          @ 345,24 RADIOGROUP Radio_2 OPTIONS { "No send log", "Send only IF fail", "Send always log" } VALUE aget[17] ;
                   WIDTH 120 TOOLTIP "Select a Log options" ;
                   ON CHANGE Changelog() 

          @ 430,24 SPINNER Spinner_1 RANGE 0,10 VALUE aget[18] WIDTH 50 TOOLTIP "Range 0,10 minutes (Shutdown require Admin Rights)" ON CHANGE ( aget[18]:= this.value, Changelog() )

          Form_1.Edit_1.Value := aget[8]

          DEFINE CONTEXT MENU CONTROL Combo_7
                MENUITEM "Add a File(s) To Attach" ACTION File_Attached(.F.,.F.,.T.) NAME ADDFILE
                MENUITEM "Remove from list" ACTION File_Attached(.T.,.T.,.T.) NAME DELFILE DISABLED
          END MENU

          ON KEY ALT+S ACTION m_send(.T.)
          ON KEY ALT+C ACTION m_config()
          ON KEY ALT+T ACTION File_Attached(.T.)
          ON KEY ALT+A ACTION m_about()
          ON KEY ALT+X ACTION ReleaseAllWindows()

   END WINDOW 

   Form_1.Title := PROGRAM + IF(Form_1.Check_1.Value == .T., extratitle, "")

   Displaystatus()

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return
/*
*/
*-----------------------------------------------------------------------------*
Function Readlog( nogui )
*-----------------------------------------------------------------------------*
Local cExePath := LogPath+"*.txt"
local dirLog   := directory(cExePath), cString:='', le := len(dirlog)
local filename := LogPath  , hnd, start, stop, n
Local cBuff    , arow := {} ,nerr := 0 ,cntbr, artv := {}
Local outFile  := Left( ExeName(), RAt( "\", ExeName() ) )+"Log.txt"
Local lr       := {462,1156}, Mr , cdt, nLength
Local destHandle, TmpBuff, LastPos, BuffPos, ByteCount
Local cPrgPath := GetStartUpFolder()+"\"

DEFAULT Nogui TO .F.

if !lchg
   IF !nogui
      Form_1.PicButton_5.enabled := .F.
   ENDIF
ENDIF

* se non trovo file di testo esco dalla procedura
* IF I find I get out of text files from the procedure
if le < 1
   IF !nogui
      msgexclamation(LogPath+CRLF+CRLF+"No log available on this folder!")
   ENDIF
   * tolgo la richiesta di salvataggio in uscita
   * remove the prompt to save on exit
   lchg := .f.
   Return .F.
ENDIF

*Cancello il file di log precedente
* Gate the previous log file
Ferase(outfile)
* una pausa per permettere a Cobian di generare il log completo solo se attivo il modo silent
* A break to allow Cobian to generate the complete log only IF activated the silent mode
if nogui
   inkey(5,128)
ENDIF
* Metto in ordine di data
* I put in order of date
ASort(dirlog,,, { |x, y| x[3] > y[3] })

*Se ci sono più log devo estrarre l'ultimo generato
* IF there are more I have to pull out the last log generated
cdt := dirlog[1,3]
aeval(dirlog,{ |x| if(x[3]=cdt,aadd(artv,x),) } )
ASort( artv ,,, { |x, y| x[4] > y[4] })

cntbr := rat("]",aget[6])
*controllo se è il log desiderato
* Check IF the desired log
if date() > artv[1,3]
   IF !nogui
      msgstop("Report non ancora elaborato !";
      ,if (" PROPERLY "$ Form_1.Label_11.VALUE,"LOG FOLDER PATH NOT SET !!! ","Data esecuzione superiore a quella di log!" ) )
   ENDIF
   aget[ 8] := "Report non ancora elaborato !"+Hb_eol()+"Trovato il file: "+artv[1,1]
   Success( .F. , cntbr, nogui )
   IF !Nogui
      Form_1.Edit_1.Value := aget[8]
   ENDIF
   * tolgo la richiesta di savataggo in uscita
   * remove the prompt to save on exit
   lchg := .f.
   SaveEnable(nogui)
   Return aget[17] = 3
ENDIF

* apro il file in lettura
* I open the file for reading
filename += artv[1,1]

Aget[15] := Lower( cFileNoExt( FileName ) )
namelog  := GetcurrentFolder()+"\"+aget[15]+".Txt"

* Creo una copia pronta per la spedizione previa cancellazione
* I create a copy ready for shipping after deletion
if file (namelog)
   Ferase ( namelog )
ENDIF

hnd := FOPEN(filename,64)
If Ferror() <> 0
   IF !Nogui
      msgStop("Error opening file : "+filename,"Readlog 364")
   ENDIF
   * Procedura abortita
   * Abortive Procedure
   Return .F.
ENDIF

* Mi adatto alla dimensione del Log
* I adapt to the size of the Log
Mr := if( artv[1,2] <= lr[1],lr[1],lr[2] )
* vado alla file del file
* I go to the file
nLength := FSEEK(Hnd, 0, 2 )
* Torno indietro di 462 o 1156 Bytes
* Back to 462 or 1156 Bytes
FSEEK(Hnd, nLength-Mr,0 )
* ora pulisco i caratteri indesiderati
* now I'm cleaning the unwanted characters
FOR N = 1 TO Mr   //462
    cBuff := FREADSTR(Hnd, 1)
    IF cBuff = CHR(13)
       IF !empty(cstring)
          aadd (arow,alltrim(cstring))
       ENDIF
       cstring := ''
    ELSE
       cString += cBuff
    ENDIF
    FSEEK(hnd,1,1)
NEXT

* se trovate le righe giuste  altrimenti genera l'errore
* IF you find the right lines otherwise generates error
if len(arow) > 2
   for n =  1 to len(arow)
       start := at("Error",arow[n])
       stop  := at("File ",arow[n])
       nerr  += trueval(substr(arow[n],start,stop-start))
   next
   * formatto in modo che la procedura ripetuta generi lo stesso subject
   * I format so that the procedure repeated kinds the same subject
   Success( nerr < 1, cntbr ,nogui )
   IF !Nogui
      Form_1.Text_6.Value := aget[6]
   ENDIF
   aget[ 8] := "File: "+artv[1,1]+CrLf
   aeval(arow,{|x| aget[ 8] += x+CrLf })
ELSE
   aget[ 8] := "File: "+artv[1,1]+CrLf
   aeval(arow,{|x| aget[ 8] += x+CrLf })
   Success( .F. , cntbr, nogui )
ENDIF

writefile( outfile, arow )

* quì la procedura di copia poichè con Filecopy fallisce
* Here the copy procedure as with filecopy fails
If aget[17] > 1
   namelog := cprgpath+aget[15]+".Txt"
   IF ( (destHandle:= fcreate(namelog, 0)) != -1 )
      LastPos:= fseek(hnd, 0, 2)
      BuffPos:= 0
      fseek(hnd, 0, 0)
      Do While (BuffPos < LastPos)
         TmpBuff := Space(8192)
         BuffPos += (ByteCount:= fread(hnd, @TmpBuff,8192))
         fwrite(destHandle, TmpBuff, ByteCount)
      EndDo
      fclose(destHandle)
   ENDIF
ENDIF

if !Nogui
   Form_1.Edit_1.Value := aget[8]
ENDIF
fclose(hnd)

* tolgo la richiesta di savataggoi in uscita
* remove the prompt to save on exit
lchg := .f.

Return .T.
/*
*/
*-----------------------------------------------------------------------------*
Procedure Success( Yes,cntbr, nogui )
*-----------------------------------------------------------------------------*
Local vCombo
default yes to .F., nogui to .f.

if !Yes
    IF cntbr < 1
       aget[ 6] := "[ Fail ] " +aget[6]
    ELSE
       aget[ 6] := substr(aget[6],cntbr+2 )
       aget[ 6] := "[ Fail ] " +aget[6]
    ENDIF
ELSE
    IF cntbr < 1
       aget[ 6] := "[ Success ] " +aget[6]
    ELSE
       aget[ 6] := substr(aget[6],cntbr+2 )
       aget[ 6] := "[ Success ] " +aget[6]
    ENDIF
ENDIF

if aget[17] = 3 .or. ("Fail" $ aget[ 6] .and. aget[17] = 2 )   // send the log IF always request or IF fail)
      * is there same item ?
      vcombo := ascan(aget[7],namelog)
      IF vCombo < 1
         aAdd(aGet[7], nameLog)
         IF !nogui
            Form_1.Combo_7.AddItem(nameLog)
            Form_1.Combo_7.Value := len(aget[7])
         ENDIF
      else
         IF !nogui
            Form_1.Combo_7.AddItem(nameLog)
            Form_1.Combo_7.Value := vCombo
         ENDIF
      ENDIF
ENDIF

if !Nogui
   Form_1.Text_6.Value := aget[6]
ENDIF

Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Trueval(string)
*-----------------------------------------------------------------------------*
   local Lenx,I,outval:='',letter
   default string to ''
   Lenx := LEN(string)
   For i = 1 TO Lenx
       letter = SUBST(string,i,1)
       IF letter $ "-0123456789."
          outval += letter
       ENDIF
   NEXT
Return VAL(outval)
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Writefile(filename,arrayname)
*-----------------------------------------------------------------------------*
Local f_handle,kounter
* open file and position pointer at the end of file
IF VALTYPE("filename")=="C"
  f_handle = FOPEN(filename,2)
  *- IF not joy opening file, create one
  IF Ferror() <> 0
    f_handle := Fcreate(filename,0)
  ENDIF
  FSEEK(f_handle,0,2)
ELSE
  f_handle := filename
  FSEEK(f_handle,0,2)
ENDIF

IF VALTYPE(arrayname) == "A"
   * IF its an array, do a loop to write it out
   FOR kounter = 1 TO len(arrayname)
       *- append a CR/LF
       FWRITE(f_handle,arrayname[kounter]+CRLF )
   NEXT
ELSE
  * must be a character string - just write it
  FWRITE(f_handle,arrayname+CRLF )
ENDIF (VALTYPE(arrayname) == "A")

* close the file
IF VALTYPE("filename") == "C"
   Fclose(f_handle)
ENDIF

Return .T.
/*
*/
*-----------------------------------------------------------------------------*
Function LogFolder()
*-----------------------------------------------------------------------------*
  Local nFolder, cPath ,fTitle := Form_1.Title

  IF empty(aget[16])
     nFolder := Left( ExeName(), RAt( "\", ExeName() ) )
  ELSE
     nFolder := aget[16]
  ENDIF
  Form_1.Title := PROGRAM 
  IF !Empty( (cPath := getfolder("Browse for log folder ....",nFolder)) )
     LogPath := cPath +"\"
     aget[16] := cPath
     Form_1.Label_11.VALUE := "Log folder path = "+LogPath
  End If
  Form_1.Title := fTitle
  IF nfolder <> aget [16]
     Changeinfo()
  ENDIF
Return Nil

/*
*/
*-----------------------------------------------------------------------------* 
STATIC PROCEDURE Mcontext(ACT) 
*-----------------------------------------------------------------------------* 
DEFAULT ACT TO .T.

IF ACT
   // DO EVENTS
   IF EMPTY(FORM_1.COMBO_7.DISPLAYVALUE)
       DISABLE MENUITEM DELFILE OF FORM_1
   ELSE
       ENABLE MENUITEM DELFILE OF FORM_1
   ENDIF
ENDIF

Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC PROCEDURE DisplayStatus() 
*-----------------------------------------------------------------------------* 
local lpf := "Log folder path = "+LogPath

If alltrim(LogPath) <> "\"
    IF LogPath == GetcurrentFolder()+"\"
      lpf := "LOG FOLDER PATH ( "+logpath +" ) NOT SET PROPERLY !!! "
    ENDIF
    Form_1.Label_11.VALUE := lpf
ENDIF

if Empty(Form_1.Combo_7.DisplayValue)
   _setTooltip("combo_7","Form_1","Attached File(s) List")
else
   _setitem("statusbar","Form_1",1,SPACE(8)+"File: "+cfilenopath(Form_1.combo_7.displayvalue))
   _setTooltip("combo_7","Form_1","Attached File: "+cfilenopath(Form_1.combo_7.displayvalue))
ENDIF

Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC PROCEDURE SetFcompress() 
*-----------------------------------------------------------------------------* 
Local Compress := Lower( aGet[15] ), new := Lower( cFileNoExt( Form_1.Combo_7.DisplayValue ) )

If Form_1.Check_1.Value == .T. .and. !Empty(new)
   IF !Empty(compress) .and. compress <> new
      PlayExclamation()
      IF msgYesNo("Do you want to replace the file "+compress+".Zip" + CRLF + ;
                  "with the new "+new+".Zip ?", "Confirm", , IDI_MAIN, .f.)
         aGet[15] := new
      ENDIF
   ELSE
      aGet[15] := new
   ENDIF
ELSE
   aGet[15] := ''
ENDIF

If Empty(new)
   IF aget[17] < 2
      Form_1.Check_1.Value := .F.
   ENDIF
   Form_1.Title := PROGRAM
ELSE
   Form_1.Title := PROGRAM + IF(Empty(aGet[15]), "", " [ I send the file(s) attached as "+aGet[15]+".Zip ]")
ENDIF

if aget[17] > 1
   IF len(aget[7]) < 1
      aget[15] := ""
      Form_1.Check_1.Value := .F.
   ENDIF
ENDIF

ChangeInfo()
DisplayStatus()
MCONTEXT()

Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC PROCEDURE m_Send(gui)
*-----------------------------------------------------------------------------*
   LOCAL i, oSocket, cSMTP, cFrom, cTo, cCC, cBCC, cSubject, cMsgBody, aAttachment 
   LOCAL lLogin, lLoginMD5, cUserID, cPassWord, lHTML, cUser := "" 
   LOCAL Silent, Fcompress, nCompress := 9, nPriority := 3, nPort := 25
   LOCAL cPrgPath := GetStartUpFolder()+"\" 
   Local nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONEXCLAMATION

   default gui to .T. 

   IF !Readlog(!gui)
      MessageBoxTimeout("Non verrà inviata alcuna mail !","",nflag ,3000)
      Return
   ENDIF

   cSMTP       := aget[ 1]
   cFrom       := aget[ 2]
   cTo         := aget[ 3]
   cCC         := aget[ 4]
   cBCC        := aget[ 5]
   cSubject    := aget[ 6]
   aAttachment := aget[ 7]
   cMsgBody    := aget[ 8]
   lLogin      := aGet[ 9]
   lLoginMD5   := aGet[10]
   cUserID     := aGet[11]
   cPassWord   := aGet[12]
   lHTML       := ( aget[13] == 2 )
   Silent      := aGet[14]
   Fcompress   := aGet[15]
   // aGet[16] "LogPath"
   // aGet[17] "SendLog"


   IF Gui
      nPriority	:= if(Form_1.Radio_0.Value == 2, 1, if(Form_1.Radio_0.Value == 3, 5, nPriority))
      Silent	:= .F.
   ENDIF

   IF "Fail" $ aget[ 6] .and. aget[17] = 1
      Fcompress := ""
   ENDIF

   IF len (aget[7]) > 1
      Fcompress   := aGet[15]
   ENDIF

   IF !Empty(Fcompress).and. len(aget[7]) > 0
      IF aget[17] > 1
         aAttachment = cPrgPath+Fcompress+".Txt"
      ENDIF

      HB_ZIPFILE( cPrgPath+Fcompress+".Zip", aAttachment, nCompress , , .T. , , .F. )
      aAttachment := { cPrgPath+Fcompress+".Zip" }
   ENDIF

   oSocket := TSMTP():New()

   IF oSocket:Connect( cSMTP, nPort )

      i := At("<", cFrom)
      IF i > 0
         cUser := Chr(34) + Alltrim(Left(cFrom, i-1)) + Chr(34)
         cFrom := Substr(cFrom, i+1, Len(cFrom)-i-1)
      ENDIF

      i := At("<", cTo)
      IF i > 0
         cTo := Substr(cTo, i+1, Len(cTo)-i-1)
      ENDIF

      i := At("<", cCC)
      IF i > 0
         cCC := Substr(cCC, i+1, Len(cCC)-i-1)
      ENDIF
      i := At("<", cBCC)
      IF i > 0
         cBCC := Substr(cBCC, i+1, Len(cBCC)-i-1)
      ENDIF

      oSocket:ClearData()
      oSocket:SetPriority( nPriority )

      oSocket:SetFrom( cUser, "<"+ cFrom +">")

      oSocket:AddTo( cUser, "<"+ cTo +">" )

      IF ! Empty( cCC )
         oSocket:AddCc( cUser,"<"+ cCC +">")
      ENDIF
      IF ! Empty( cBCC )
         oSocket:AddBcc( cUser, "<"+ cBCC +">" )
      ENDIF

      oSocket:SetSubject( cSubject )

      IF Len( aAttachment ) > 0
         aeval( aAttachment, { |x| oSocket:AddAttach(x) } )
      ENDIF

      oSocket:SetData( cMsgBody, lHTML )

      IF lLogin
         IF lLoginMD5
            IF ! oSocket:LoginMD5( cUserID, cPassWord )
               IF Silent
                  LogFile( cLogFile, {oSocket:GetLastError()+" While trying to login got an error messages from server"} )
               ELSE
                  MsgStop( oSocket:GetLastError(), "While trying to login got an error messages from server" )
               ENDIF
               oSocket:Close()
               Return
            ENDIF
         ELSEIF ! oSocket:Login( cUserID, cPassWord )
            IF Silent
               LogFile( cLogFile, {oSocket:GetLastError()+" While trying to login got an error messages from server"} )
            ELSE
               MsgStop( oSocket:GetLastError(), "While trying to login got an error messages from server" )
            ENDIF
            oSocket:Close()
            Return
         ENDIF
      ENDIF

      IF ! oSocket:Send(.T.)
         IF Silent
            LogFile( cLogFile, {oSocket:GetLastError()+" While trying to send data got an error messages from server"} )
         ELSE
            MsgStop( oSocket:GetLastError(), "While trying to send data got an error messages from server" )
         ENDIF
         oSocket:Close()
         Return
      ENDIF

      oSocket:Close()

      IF Silent
         LogFile( cLogFile, {"Mail sent to " + cTo + " successfully"} )
      ELSE
         MsgInfo( "Mail sent to " + cTo + " successfully!", PROGRAM )
      ENDIF

   ELSE

      IF Silent
         LogFile( cLogFile, {"Can't connect to SMTP server: " + cSMTP} )
      ELSE
         MsgStop( "Can't connect to SMTP server: " + cSMTP, "Error while trying to connect to SMTP server" )
      ENDIF

   ENDIF
*/
* Clean Files tmp now after a little pause
inkey(10)
Ferase(GetStartUpFolder()+"\"+aget[15]+".txt")
Ferase(GetStartUpFolder()+"\"+aget[15]+".Zip")
* Can I shutdown The Pc ?

if aget[18] > 0
   SetTimer()
ENDIF
Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC PROCEDURE m_config() 
*-----------------------------------------------------------------------------* 

   DEFINE WINDOW Form_2 ;
      AT 199,144 WIDTH 374 HEIGHT 221 ;
      TITLE Left(PROGRAM, Len(PROGRAM)-3)+"Config" ;
      ICON IDI_MAIN ;
      MODAL NOSIZE ;
      ON INIT Form_2.Button_1.Setfocus ;
      FONT "MS Sans Serif" SIZE 10

      @ 8,8 FRAME Frame_1 WIDTH 350 HEIGHT 138

      @ 22,25 CHECKBOX CheckBox_1 CAPTION "My server requires authentication" ;
              WIDTH 240 HEIGHT 22 ON CHANGE ( aget[9] := Form_2.CheckBox_1.Value, ChangeInfo() )
      Form_2.CheckBox_1.Value := aget[9]

      @ 46,45 CHECKBOX CheckBox_2 CAPTION "MD5 Password Authentication" ;
              WIDTH 200 HEIGHT 22 ON CHANGE ( aget[10] := Form_2.CheckBox_2.Value, ChangeInfo() )
      
      Form_2.CheckBox_2.Value := aget[10]

      @ 81,25 LABEL Label_1 VALUE "User Name" WIDTH 90 HEIGHT 22
      @ 107,25 LABEL Label_2 VALUE "Password" WIDTH 92 HEIGHT 22

      @ 76,125 TEXTBOX Text_1 HEIGHT 22 WIDTH 222 ON CHANGE ( aget[11] := Form_2.Text_1.Value, ChangeInfo() )
      Form_2.Text_1.Value := aget[11]

      @ 103,125 TEXTBOX Text_2 HEIGHT 22 WIDTH 222 PASSWORD ON CHANGE ( aget[12] := Form_2.Text_2.Value, ChangeInfo() )
      Form_2.Text_2.Value := aget[12]

      @ 156,140 BUTTON Button_1 CAPTION "OK" ACTION Form_2.Release WIDTH 80 HEIGHT 26 DEFAULT

      ON KEY ESCAPE ACTION Form_2.Button_1.OnClick

   END WINDOW

   CENTER WINDOW Form_2

   ACTIVATE WINDOW Form_2
   
Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC FUNCTION m_about() 
*-----------------------------------------------------------------------------*
Return MsgInfo(padc(PROGRAM + " - Freeware", 44) + CRLF + ;
   "Copyright (c) 2005-2006 Grigory Filatov" + CRLF + CRLF + ;
   padc("Email: gfilatov@front.ru", 40) + CRLF + CRLF + ;
   "Improved by Pierpaolo Martinello 2016-2018"+ CRLF + CRLF + ;
   hb_compiler() + CRLF + ;
   version() + CRLF + ;
   MiniGuiVersion(), "About", IDI_MAIN, .f.)
/*
*/
*-----------------------------------------------------------------------------*
STATIC PROCEDURE File_Attached( lClear, lcOne, oAdd , sLog )
*-----------------------------------------------------------------------------*
   LOCAL i,ync, cNewAtt, c := .F., v := aget[7], cv := Form_1.Combo_7.Value
   //Local Ichk := GetComboArray( "Combo_7", "Form_1" )

   Default lClear to .F., lcOne to .F., oAdd to .F. , slog to .f.

   IF slog
      cNewAtt := v
   ELSE
      IF len(v) > 0 .and. !lClear .and. Form_1.Combo_7.ItemCount > 0
         IF !oadd
            PlayExclamation()
            ync := msgYesNoCancel("Add a new file or make a new selection?", "Choice", IDI_MAIN, .f.)
            IF ync = -1
               Return
            else
               c := ( ync == 0 )
            ENDIF
         ENDIF
      ENDIF

      IF !lClear
         cNewAtt := GetFile( { {"All Files", "*.*"}, ;
            {"ZIP Archives", "*.zip"}, {"RAR Archives", "*.rar"} }, ;
            "Select a File(s) To Attach", , .T. )
      ENDIF

   ENDIF

   IF !empty( cNewAtt )

      IF C
         aGet[7] := {}
         Form_1.Combo_7.DeleteAllItems
         v := {}
      ENDIF

      IF valtype(cNewAtt) == 'C'

         IF ascan(v,cNewAtt) < 1
            Form_1.Combo_7.AddItem(cNewAtt)
            aAdd(aGet[7], cNewAtt)
         ENDIF

      elseif valtype(cNewAtt) == 'A'

         for i := 1 to len(cNewAtt)

             IF ascan(aget[7],cNewAtt[i]) < 1
                Form_1.Combo_7.AddItem(cNewAtt[i])
                aAdd(aGet[7], cNewAtt[i])
             ENDIF

         next i

      ENDIF

      Form_1.Combo_7.Value := 1

   elseif lClear

      IF LcOne
         Form_1.Combo_7.DeleteItem( cv )
         aGet[7] := GetComboArray( "Combo_7", "Form_1" )
         Form_1.Combo_7.Value := if( cv >= 1, cv - 1, 1 )
      else
         aGet[7] := {}
         Form_1.Combo_7.DeleteAllItems
         Form_1.Check_1.Value := .F.
         aGet[15] := ''
      ENDIF

   ENDIF

   // DO EVENTS

   IF EMPTY(FORM_1.COMBO_7.DISPLAYVALUE)
       DISABLE MENUITEM DELFILE OF FORM_1
   ELSE
       ENABLE MENUITEM DELFILE OF FORM_1
   ENDIF

   SetFCompress()

Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC PROCEDURE SaveData(out) 
*-----------------------------------------------------------------------------*
   LOCAL i, s := aget[14], q := .T.
   Default out to .F.
   
   IF !s
      IF out
         PlayExclamation()
         q := msgYesno("Do you want to save these parameters ?", "Exit from application.", q, IDI_MAIN, .f.)
      ENDIF
   ENDIF

   IF q
      BEGIN INI FILE cCfgFile

            SET SECTION Left(PROGRAM, Len(PROGRAM)-4) ENTRY "Release" to Right(PROGRAM, 3)

            For i := 1 To Len(aEntry)
                IF i == 8
                   aGet[i] := STRTRAN( aGet[i], CRLF, Chr(250) )
                ELSEIF i == 12
                   aGet[i] := ENCRIPTA( aGet[i], cCryptKey )
                ENDIF
                SET SECTION "Data" ENTRY aEntry[i] TO aGet[i]
            Next i

      END INI
   ENDIF
   aGet[12] := decripta( aGet[12], cCryptKey )
   lchg := .F.
   SaveEnable()
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure SaveEnable(nogui)
*-----------------------------------------------------------------------------*
   default nogui to .F.
   IF !nogui
      Form_1.PicButton_5.enabled := lchg
   ENDIF
Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC PROCEDURE LogFile( cFileName, acInfo ) 
*-----------------------------------------------------------------------------*
   LOCAL hFile, cLine := DToC( Date() ) + " " + Time() + " : ", n

   For n = 1 to Len( acInfo )
      cLine += acInfo[ n ] + Chr( 9 )
   Next
   cLine += CRLF

   IF ! File( cFileName )
      FClose( FCreate( cFileName ) )
   ENDIF

   if( ( hFile := FOpen( cFileName, FO_WRITE + FO_SHARED ) ) != -1 )
      FSeek( hFile, 0, FS_END )
      FWrite( hFile, cLine, Len( cLine ) )
      FClose( hFile )
   ENDIF

Return
/*
*/
*-----------------------------------------------------------------------------*
STATIC Function GetComboArray( ControlName, ParentWindow ) 
*-----------------------------------------------------------------------------*
Local n, cnt := GetProperty( ParentWindow, ControlName, "ITEMCOUNT" ), aret := {}

for n = 1 to cnt
    aadd( aret, GetProperty( ParentWindow, ControlName, "ITEM", n ) )
next

Return aret
/*
*/
*-----------------------------------------------------------------------------*
Procedure ChangeLog()
*-----------------------------------------------------------------------------*
Local ret, q:= .t.,  cmp := Empty(Form_1.Combo_7.DisplayValue)
    ret := Form_1.Radio_2.Value

    IF ret = 1
         IF cmp
            Form_1.Check_1.Value := .F.
         ENDIF
         aget[17]:= ret

    ELSE
         IF Form_1.Check_1.Value .and. !cmp
            q := msgYesno("Do you want to compress these files ?", "Confirmation.", q, IDI_MAIN, .f.)
            Form_1.Check_1.Value := q
         ENDIF
         aget[17]:= ret
    ENDIF

    ChangeInfo()

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure ChangeInfo()
*-----------------------------------------------------------------------------*
    lchg := .T.
    SaveEnable()
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure SetTimer()
*-----------------------------------------------------------------------------*
    Local cTime := Time(), lExit := .t., cWindow := "", cLabel, nMode := 1

    Local nTime1 := left(cTime,3)
    Local nTime2 := val(substr(ctime,4,2))+ aget[18]
    Local nTime3 := right(ctime,3)

    PUBLIC cTimeExit

    m->cTimeExit := nTime1 + StrZero(nTime2,2) + nTime3

    m->cTimeExit := TimeDiff( ctime, m->cTimeExit )

    cLabel := "Tempo rimanente prima della chiusura:"

    IF !aget[14]

       Set InteractiveClose Off

       DEFINE WINDOW Form_2 AT 0,0 WIDTH 250 HEIGHT IF(Empty(cWindow), 162, 206) ;
              TITLE "Shutdown attivato!" ;
              ICON "MAIN" ;
              NOMINIMIZE NOMAXIMIZE NOSIZE ;
              ON RELEASE Form_2.Timer_1.Enabled := .f. ;
              ON PAINT Form_2.Button_1.SetFocus

       @  10,  5 LABEL Label_1 ;
                 VALUE cLabel  ;
                 WIDTH  240    ;
                 HEIGHT 22     ;
                 FONT "Arial"  ;
                 SIZE 9 BOLD

       @  35, 25 LABEL TimeExit  ;
                 VALUE m->cTimeExit ;
                 WIDTH  200      ;
                 HEIGHT 52       ;
                 FONT "Arial"    ;
                 SIZE 36 BOLD

       @ 100, 75 BUTTON Button_1 CAPTION "Annulla" ;
                 ACTION ( lExit := .f., Form_2.release ) ;
                 WIDTH 100 HEIGHT 24 FONT "MS Sans Serif" SIZE 9

       DEFINE TIMER Timer_1 ;
              INTERVAL 1000 ;
              ACTION SetTimeExit( cWindow )

       END WINDOW

       CENTER WINDOW Form_2

       ACTIVATE WINDOW Form_2

    ENDIF

    IF lExit
       WinExit(nMode)
    ELSE
       RELEASE m->cTimeExit
       Set InteractiveClose On
       Form_1.Show
    ENDIF

    Set InteractiveClose ON

Return
/*
*/
#define GW_HWNDFIRST    0
#define GW_HWNDNEXT    2
#define GW_OWNER        4
*-----------------------------------------------------------------------------*
Function SetTimeExit( cTitle )
*-----------------------------------------------------------------------------*
    LOCAL aWnd := {}, hWnd, cAppTitle

    m->cTimeExit := TimeAsString( TimeAsSeconds( m->cTimeExit ) - 1 )

    Form_2.TimeExit.Value := m->cTimeExit

    IF m->cTimeExit == "00:00:00"
       Form_2.Release
    ENDIF

    IF !Empty(cTitle)
        hWnd := GetWindow( _HMG_MainHandle, GW_HWNDFIRST )    // Get the first window
        WHILE hWnd != 0                        // Loop through all the windows
            cAppTitle := GetWindowText( hWnd )
            IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.;    // IF it is an owner window
                IsWindowVisible( hWnd ) .AND.;        // IF it is a visible window
                hWnd != _HMG_MainHandle .AND.;        // IF it is not this app
                !EMPTY( cAppTitle ) .AND.;        // IF the window has a title
                !( "DOS Session" $ cAppTitle ) .AND.;    // IF it is not DOS session
                !( cAppTitle == "Program Manager" )    // IF it is not the Program Manager

                Aadd( aWnd, ALLTRIM(cAppTitle) )
            ENDIF

            hWnd := GetWindow( hWnd, GW_HWNDNEXT )        // Get the next window
        ENDDO
        IF EMPTY( Ascan( aWnd, ALLTRIM(cTitle) ) )
            Form_2.Release
        ENDIF
    ENDIF

Return .t.
/*
*/
#define EWX_LOGOFF   0
#define EWX_SHUTDOWN 1
#define EWX_REBOOT   2
#define EWX_FORCE    4
#define EWX_POWEROFF 8
*-----------------------------------------------------------------------------*
Procedure WinExit( nFlag )
*-----------------------------------------------------------------------------*

   IF IsWinNT()
      EnablePermissions()
   ENDIF

   nFlag := EWX_SHUTDOWN
   nFlag += EWX_POWEROFF
   nFlag += EWX_FORCE

   IF !ExitWindowsEx(nFlag, 0)
      ShowError()
   else
      ReleaseAllWindows()
   ENDIF

Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION TimeDiff( cStartTime, cEndTime )
*-----------------------------------------------------------------------------*
Return TimeAsString(IF(cEndTime < cStartTime, 86400, 0) + ;
       TimeAsSeconds(cEndTime) - TimeAsSeconds(cStartTime))
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION TimeAsSeconds( cTime )
*-----------------------------------------------------------------------------*
Return VAL(cTime) * 3600 + VAL(SUBSTR(cTime, 4)) * 60 + ;
       VAL(SUBSTR(cTime, 7))
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION TimeAsString( nSeconds )
*-----------------------------------------------------------------------------*
Return StrZero(INT(Mod(nSeconds / 3600, 24)), 2, 0) + ":" + ;
       StrZero(INT(Mod(nSeconds / 60, 60)), 2, 0) + ":" + ;
       StrZero(INT(Mod(nSeconds, 60)), 2, 0)
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION TimeIsValid( cTime )
*-----------------------------------------------------------------------------*
Return VAL(cTime) < 24 .AND. VAL(SUBSTR(cTime, 4)) < 60 .AND. ;
       VAL(SUBSTR(cTime, 7)) < 60

/*
* Add By Pierpaolo 2018
*/

*--------------------------------------------------------*
FUNCTION Decripta ( cString,chiave )
*--------------------------------------------------------*
   LOCAL nTam, cCrypt := "", i

   Chiave  := iif( Empty( Chiave ), "@#$%", Chiave )
   Chiave  := _adc( chiave, ordinale( 1 ) )
   cString := iif( Empty( cString ) .OR. Len ( cString ) < 3  ;
      , "NOPASSW0RD",cString )
   nTam := Len( cString )
   DO WHILE Len( Chiave ) < nTam
      Chiave += Chiave
   ENDDO
   cCrypt := ""
   FOR i := 1 TO nTam
      cCrypt += Chr( Asc( SubStr( cString, i, 1 ) ) - Asc( SubStr( Chiave, i, 1 ) ) )
   NEXT

Return cCrypt
/*
*/
*--------------------------------------------------------*
FUNCTION Encripta( cString,chiave )
*--------------------------------------------------------*
   LOCAL nTam, cCrypt := "", i

   Chiave  := iif( Empty( Chiave ), "@#$%", Chiave )
   Chiave  := _adc( chiave, ordinale( 1 ) )
   cString := iif( Empty( cString ) .OR. Len ( cString ) < 3  ;
      , "NOPASSW0RD",cString )
   nTam := Len( cString )
   DO WHILE Len( Chiave ) < nTam
      Chiave += Chiave
   ENDDO
   cCrypt := ""
   FOR i := 1 TO nTam
      cCrypt += Chr( Asc( SubStr( cString, i, 1 ) ) + Asc( SubStr( Chiave, i, 1 ) ) )
   NEXT

Return cCrypt
/*
*/
*--------------------------------------------------------*
FUNCTION Ordinale( nmb )
*--------------------------------------------------------*
   LOCAL nString
   nmb     := iif( nmb == NIL, 0, nmb )
   nString := Right( Str( nmb ), 1 )

Return nString
/*
*/
*--------------------------------------------------------*
FUNCTION _adc ( iString, adc )
*--------------------------------------------------------*
   LOCAL lRes := '', i
   FOR i = 1 TO Len ( iString )
      lres += SubStr( iString, i, 1 )
      IF i = Val( adc )
         lres += adc
      ENDIF
   NEXT

Return lres
/*
*/
*--------------------------------------------------------*
FUNCTION _sdc ( iString, adc )
*--------------------------------------------------------*
   LOCAL lRes := '', i
   FOR i = 1 TO Len ( iString )
      IF i = Val( adc )
         LOOP
      ENDIF
      lres += SubStr( iString, i, 1 )
   NEXT

Return lres
/*
* End of Patch Pierpaolo 2018
*/

/*
*/
*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_BOOL SwitchToThisWindow( DLL_TYPE_LONG hWnd, DLL_TYPE_BOOL lRestore ) ;
    IN USER32.DLL

#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( SHOWERROR )

{
   LPVOID lpMsgBuf;
   DWORD dwError  = GetLastError();

   FormatMessage(
      FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
      NULL,
      dwError,
      MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
      (LPTSTR) &lpMsgBuf,
      0,
      NULL
   );

   MessageBox(NULL, (LPCSTR)lpMsgBuf, "Shutdown", MB_OK | MB_ICONEXCLAMATION);
   // Free the buffer.
   LocalFree( lpMsgBuf );
}

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeShutdownPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC( EXITWINDOWSEX )

{
   hb_retl( ExitWindowsEx( (UINT) hb_parni( 1 ), (DWORD) hb_parnl( 2 ) ) );
}

#pragma ENDDUMP
