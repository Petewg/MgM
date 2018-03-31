/*
 * Harbour MiniGUI File Downloader Demo
 * My Version of Download-Manager on MiniGUI
 * Works in separate Thread 
 *
 * (c) 2009-2013 Artyom Verchenko <artyomskynet@gmail.com>
 *
*/

#include "minigui.ch"
#include "hbthread.ch" 

#define SITE_URL "harbour.github.io"
#define FILE_URL "/images/header_01.jpg"

#define SAVE_NAME CurDrive() + ":\" + CurDir() + "\MyPicture.jpg"
#define PROGRAM  'Download from Internet with MultiThreading v1.1'

MEMVAR nBytesDownloaded, nBytesTotal, nPercents

// Main window
FUNCTION Main
  PUBLIC nBytesDownloaded := 0, nBytesTotal := -1, nPercents := 0

  DEFINE WINDOW Win_1 ;
	ROW 0 COL 0 ;
	WIDTH 455 HEIGHT 280 ;
	TITLE PROGRAM ;
	ICON "ICON_MAIN";
	WINDOWTYPE MAIN;
	NOSIZE NOMAXIMIZE NOMINIMIZE ;
	FONT 'Tahoma' SIZE 10             

  @ 5,80 ANIMATEBOX Avi_1 ;
      WIDTH 32  HEIGHT 40 ;
      FILE 'LOGO' AUTOPLAY TRANSPARENT NOBORDER

  @ 80,10 LABEL Label_1 ;
      WIDTH 440 HEIGHT 16 ;
      VALUE 'http://'+SITE_URL+FILE_URL ;
      CENTERALIGN

  @ 100,20 PROGRESSBAR Pg_1 ;
      RANGE 0,100 ;
      VALUE 0;
      WIDTH 410 HEIGHT 34 ;
      TOOLTIP "Progress of downloading"

  @ 135,10 LABEL Label_2 ;
      WIDTH 440 HEIGHT 16 ;
      VALUE 'To '+SAVE_NAME ;
      CENTERALIGN

  @ 180,40 BUTTONEX BUTTON_1 ;
      CAPTION "Open folder" ;
      ACTION OpenFolder();
      WIDTH 120 HEIGHT 38 ;
      FONT 'Tahoma' SIZE 12 BOLD

  @ 180,170 BUTTONEX BUTTON_2 ;
      CAPTION "Download file" ;
      ACTION ButtonMain();
      WIDTH 130 HEIGHT 38 ;
      FONT 'Tahoma' SIZE 12 BOLD
			
  @ 180,310 BUTTONEX BUTTON_3 ;
      CAPTION "Exit" ;
      ACTION ReleaseAllWindows();
      WIDTH 120 HEIGHT 38 ;
      FONT 'Tahoma' SIZE 12 BOLD
      
  @ 220,20 LABEL Label_3 ;
      WIDTH 410 HEIGHT 16 ;
      VALUE 'Press the button to download the file' ;
      CENTERALIGN

  END WINDOW
	
  Win_1.BUTTON_1.Enabled := .F.

  Win_1.Center
  Win_1.Activate

Return Nil


// On Click of Button "Download file"
PROCEDURE ButtonMain
  LOCAL threadA

  Win_1.Button_2.Enabled := .F.                              
  Win_1.Button_2.Caption := "Loading..."

  // Start a new Thread
  threadA := hb_threadStart( HB_THREAD_INHERIT_PUBLIC, @DownloadFile() )
  hb_threadDetach( threadA )
RETURN


// On Click of Button "Open Folder"
PROCEDURE OpenFolder()
  // Using ShellExecute for opening Explorer with selected File
  ShellExecute(0,"open","explorer.exe","/select,"+SAVE_NAME,NIL,1)
RETURN


// When the file was successfully downloaded
PROCEDURE DownloadSuccess()
  MsgInfo("File was downloaded successfully !","Success")
  // Activate button "Open folder"
  Win_1.BUTTON_1.Enabled := .T.
RETURN


// When we get error
PROCEDURE DownloadError()
  MsgStop("Critical Error !" + CRLF + "Please, restart this application and try again","Critical Error")
RETURN


// When we get regular buffer
PROCEDURE UpdateCur()
LOCAL nXB := 1024 // Unit in KiloBytes

  Win_1.Label_1.Caption := ALLTRIM(STR(INT(M->nBytesDownloaded/nXB))) + " KB from " + ALLTRIM(STR(INT(M->nBytesTotal/nXB))) + " KB"
  // Get Status in Percents
  M->nPercents := (M->nBytesDownloaded / M->nBytesTotal) * 100
  // Set the ProgressBar value
  Win_1.Pg_1.Value := INT(M->nPercents)
  DO EVENTS
RETURN


// Main Download Procedure
// Warning ! Start ONLY in the separate Thread
FUNCTION DownloadFile()
      LOCAL cRequest, cResponse
      
      // send HTTP request to server
      cRequest := "GET " + FILE_URL + " HTTP/1.1"        + CRLF + ;
                  "Host: "+SITE_URL                      + CRLF + ;
                  "User-Agent: Downloader (Version 1.1)" + CRLF + ;
                  "Connection: close" + CRLF + CRLF      

      // get Response
      cResponse := SendPacket(SITE_URL,cRequest,80)
RETURN cResponse


// Socket-Chat Function
FUNCTION SendPacket(cURL,cRequest,nPort)
LOCAL cResponse, oSocket, lNoError
LOCAL nFile
LOCAL cI, cTemp
LOCAL nLen, lHaveLen := .F., cErrorStatus
// Standard buffer size is 4 KBytes
LOCAL nBuffer := 4096

     // Create a new Socket-Object
     oSocket := TSocket():New()
     // Try Connect to server
     lNoError := oSocket:Connect(cUrl,nPort)
     // On Error
     IF lNoError == .F.
        MsgStop("Error on request of URL "+cURL)
        oSocket:Close()
        cResponse := "Error"
     ELSE

       nFile := CreateFile()
       // If send was successfully
       IF oSocket:SendString(cRequest)       
         // While True
         WHILE .T.
           // Get HTTP header line
           cI := oSocket:ReceiveLine()
	   // Get the first HTTP header line, that contains a status code
           IF AT("http/1.1",LOWER(cI)) != 0 .OR. AT("http/1.0",LOWER(cI)) != 0
	     // If status code is not "200 OK"
	     IF AT("200",cI) == 0
                // Writing status code to string var
		cErrorStatus := SUBSTR(cI,AT(" ",cI)+1)  
	     END
	   ENDIF
           // If text match file size
           IF RAt(LOWER("content-length:"),LOWER(cI)) != 0
             // Get len of this file
             nLen := Substr(cI,At(": ",cI)+2)
             nLen := VAL(nLen)+1
             // Write to a global var
             M->nBytesTotal := nLen

             lHaveLen := .T.
           ENDIF

           // If this line is last
           IF (cI == "")
             // And we don't get the File length
             IF lHaveLen == .F.
               MsgStop("Can't find the file length !","Error")
             ENDIF
             // Exit from While
             EXIT
           ENDIF
         END

         // We have 2 ways to download file
         // If we have file length
         IF lHaveLen .AND. EMPTY(cErrorStatus)
           // While True
           DO WHILE .T.
             // Get the current buffer from socket
             cTemp := oSocket:ReceiveChar(nBuffer)
             // Write this buffer to file
             WriteFile(nFile,cTemp)
             // Add bytes to info for ProgressBar
             M->nBytesDownloaded += LEN(cTemp)
             // If we have got 0 bytes
             IF LEN(cTemp) == 0
               // And if download is finish 
               IF M->nBytesDownloaded + 1 >= M->nBytesTotal
                 DownloadSuccess()
               // Else - error
               ELSE
                 DownloadError()
               ENDIF
               EXIT
             ENDIF
             // Debug information
             //cTempText += CRLF + "GET BYTES: " + ALLTRIM(STR(LEN(cTemp)))
             //cTempText += CRLF + "VALTYPE: " + VALTYPE(cTemp)
             // Set ProgressBar and Label
             UpdateCur()
           ENDDO
           // Write debug infromation
           //MemoWrit("download.log",cTempText)

         // If we don't have a file length
         ELSE
           IF !EMPTY(cErrorStatus)
		// Writing HTTP server requested code
		MsgStop(cErrorStatus,"Server Code")
           ENDIF
           // Get this file without any information
           cTemp := oSocket:ReceiveString()
           WriteFile(nFile,cTemp)
         ENDIF
         oSocket:Close()
         CloseFile(nFile)
         cResponse := "Success"
       ENDIF
     ENDIF
RETURN cResponse


// Create file function, with name in const SAVE_NAME
FUNCTION CreateFile()
  LOCAL nFileHandler
  // Try to create file
  nFileHandler := FCreate(SAVE_NAME)
  // If we catch error
  IF FError() <> 0 
    MsgStop("Error on create file: "+SAVE_NAME+" !"+CRLF+FError(),"Error")
    // Return value -1
    nFileHandler := -1
  ENDIF
RETURN nFileHandler


// Write to file function, file handler in parameters
FUNCTION WriteFile(nFileHandler,cText)
  LOCAL nSuccess
  nSuccess := FWrite(nFileHandler,cText)
  IF nSuccess <> LEN(cText)
    MsgStop("Error on write to file:" + CRLF + FError(),"Error")
  ENDIF
RETURN nSuccess


// Close file function, file handler in parameters
FUNCTION CloseFile(nFileHandler)
  LOCAL lClosed
  lClosed := FClose(nFileHandler)
  IF lClosed == .F.
    MsgStop("Error on close file:" + CRLF + FError(),"Error")
  ENDIF
RETURN lClosed
