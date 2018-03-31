
#define _use_CallDLL        // choses to use to code to explictly load the dll

*#define _debug             // writes command lines sent to Blat to a log file blatdebug.log

#ifdef _use_CallDLL

STATIC nLoadedBlat:=0       // blat load count 
STATIC hInstDLL             // handle to DLL

#endif

#include "hbclass.ch"

/*

   The class BlatMail is a wrapper to use the BLAT email sending program as a DLL.  
   Blat is an email program that is available as either an executable or a DLL.  It has
   been available for many years and handles many variations found in SMTP systems such as
   authenticated logins, POP3 login before SMTP, etc.  It handles HTML mail with alternative text
   as well as plain text messages.  It handles attached files, embeded files for HTML and many
   more options.  Thus it is a convenient way of sending emails.  Blat information can be found
   at www.blat.net

   BlatMail can be used in one of two ways.  One way is to have the DLL loaded only when needed and the
   other is to access it via it link library which means it is loaded at the start of the program.

   The object contains a number of variables which are described below with their corresponding
   blat switches. A number of parameters can be obtained from either a disk file or place directly
   on the command line.  For example, the message can be either in a file or placed on the command line or
   the list of recipients could be in a file or on the command line.  So parameters are provided for
   both.  In most cases, the file takes precedence over the command line version.

NOTES:  cSendAddress must be given and is often the same a cSMTPLogin.  However, since there could be
        cases where they are not, they are kept separate.
        
* Addresses and passwords

    VAR cSMTPServer         -server <addr>  : specify SMTP server to be used
    VAR nSMTPPort  INIT 25  -port <nSMTPport> : port to be used on the SMTP server, defaults to SMTP (25)
    VAR cSMTPLogin          -u <username>   : username for AUTH LOGIN (use with -pw)
    VAR cSMTPPassword       -pw <password>  : password for AUTH LOGIN (use with -u)
    
    VAR cPOP3Server         -serverPOP3 <addr>: specify POP3 server to be used (optionally, addr:port)
                                             when POP3 access is required before sending email
    VAR nPOP3Port INIT 110  -portPOP3 <nPOP3port>: port to be used on the POP3 server, defaults to POP3 (110)
    VAR cPOP3Login          -pu <username>  : username for POP3 LOGIN (use with -ppw)
    VAR cPOP3Password       -ppw <password> : password for POP3 LOGIN (use with -pu)
    VAR cProfile            -p <profile>    : send with server, user, and port defined in <profile>
                                            : use username and password if defined in <profile>
    VAR cSendAddress        -f <sender>     : sender address (must be known to server)
    VAR cAltSendAddress     -i <addr>       : a 'From:' address, not necessarily known to the server used
                                            : cFromName if give to form "cFromName <cAltSendAddress>"
    VAR cFromName                           : used with cAltSendAddress -Plain text name - e.g. John Doe - shown as the sender
    
* Lists of recipients and flags

    VAR cToList             -to <recipient> : recipient list (comma separated)
    VAR cCCList             -cc <recipient> : carbon copy recipient list (comma separated)
    VAR cBCCList            -bcc <recipient>: blind carbon copy recipient list (comma separated)
    VAR cToFile             -tf <File>      : recipient list filename
    VAR cCCFile             -cf <file>      : cc recipient list filename
    VAR cBCCFile            -bf <file>      : bcc recipient list filename
    VAR nMaxNames           -maxNames <x>   : send to groups of <x> number of recipients
    VAR lUndisclosed        -ur             : set To: header to Undisclosed Recipients if not using the
                                            : -to and -cc options
    
    VAR lDisposition        -d              : request disposition notification
    VAR lReturnReceipt      -r              : request return receipt
    VAR nPriority           -priority <pr>  : set message priority 0 for low, 1 for high

* The message to be sent out

    VAR cMessageFile                        : file with the message body to be sent
    VAR cMessage            -body <text>    : message body, BlatMail will surround with quotes to include 
                                              spaces - cMessageFile takes precidence
    VAR lHTML INIT .F.      -html           : send an HTML message (Content-Type=text/html)
    VAR cAltText            -alttext <text> : plain text for use as alternate text
    VAR cAltFile            -alttextf <file>: plain text file for use as alternate text
    VAR cSubject            -subject <subj> : subject line, BlatMail will surround with quotes to include spaces
    VAR cSubjectFile        -sf <file>      : file containing subject line

    VAR cTagFile            -tag <file>     : text file containing taglines, to be randomly chosen
    VAR cSigFile            -sig <file>     : text file containing your email signature
    VAR cPSFile             -ps <file>      : final message text, possibly for unsubscribe instructions
    VAR cAttachFiles        -attach <file>  : attach binary file(s) to message (filenames comma separated)
    VAR cAttachFileList     -af <file>      : file containing list of binary file(s) to attach (comma separated)
    VAR cAttachTextFiles    -attacht <file> : attach text file(s) to message (filenames comma separated)
    VAR cAttachTextList     -atf <file>     : file containing list of text file(s) to attach (comma separated)
    VAR cAttachInlineFiles  -attachi <file> : attach text file(s) as INLINE (filenames comma separated)
    VAR cEmbedFiles         -embed <file>   : embed file(s) in HTML.  Object tag in HTML must specify
                                            : content-id using cid: tag.  eg: <img src="cid:image.jpg">
    VAR cEmbedFilesList     -aef <file>     : file containing list of embed file(s) to attach (comma separated)
    
* Other options

    VAR lBase64 INIT .F.    -base64         : send binary files using base64 (binary MIME)
    VAR lUUEncode INIT .F.  -uuencode       : send binary files UUEncoded
    VAR lEnriched INIT .F.  -enriched       : send an enriched text message (Content-Type=text/enriched)
    VAR lUnicode INIT .F.   -unicode        : message body is in 16- or 32-bit Unicode format
    VAR lMime INIT .F.      -mime           : MIME Quoted-Printable Content-Transfer-Encoding
    VAR l8BitMime INIT .F.  -8bitmime       : ask for 8bit data support when sending MIME
    
    VAR lDebug INIT .F.     -debug          : echoes server communications to a log file
    VAR lSuperDebug INIT .F.-superdebugT    : ascii dump the data between Blat and the server

    VAR lLogFile INIT .F.    -log <file>     : log everything but usage to <cLogFile> - see below
    VAR cLogFile INIT "BlatLog.Log" // log file if any debug option turned on
    VAR lTimeStamp INIT .T.  -timestamp      : when -log is used, a timestamp is added to each log line
    VAR nTimeOut INIT 0      -ti <n>         : set timeout to 'n' seconds.  Blat will wait 'n' seconds for
                                             : server responses
    VAR nTry INIT 1          -try <n times>  : how many times blat should try to send (1 to 'INFINITE')
    VAR nDelay INIT 0        -delay <x>      : wait x seconds between messages being sent when used with
                                             : -maxnames or -multipart

    VAR lNoHeader INIT .F.   -noh            : prevent X-Mailer/User-Agent header from showing Blat homepage
    VAR lNoHeaderAtAll INIT .F. -noh2        : prevent X-Mailer header entirely

    VAR cOtherSwitches       // set this to send switches not covered in the above variables

    VAR lDontUseRegistry INIT .T. // do not set the registry with blat variables


Methods available in this class include:
   
    METHOD NEW()            : create the class and if you are loading the DLL dynamically then load BLAT
       
    METHOD SetCommandLine() : initialize command line common switches.  Many of the "command line" switches remain 
                              the same if you are sending more than one email.  So this method lets you set the command
                              line up after setting the requisite VARS
    METHOD SetProfile()     : Blat can use a profile for many of the sending address and server address parameters.
                              These are saved in the registry.  See the BLAT Syntax document for information about
                              the parameters that are sent
    METHOD MailSend()       : Send the mail out
    METHOD BlatUnload()     : If you have dynamically loaded BLAT then this will unload it
       
*/

CLASS BlatMail

    METHOD New()               // create class - Load BLAT if needed
    METHOD SetCommandLine()    // initialize command line common switches
    METHOD SetProfile()        // set the default profile
    METHOD MailSend()          // Actually send the mail
    METHOD BlatUnload()

* Addresses and passwords

    VAR cPOP3Server            // POP3 Server for POP login before SMTP
    VAR nPOP3Port  INIT  110   // POP3 port
    VAR cSMTPServer            // SMTP Server address
    VAR nSMTPPort  INIT 25     // SMTP port
    VAR cPOP3Login             // POP3 Account name
    VAR cPOP3Password          // POP3 Account Password
    VAR cSMTPLogin             // SMTP authenticated login account
    VAR cSMTPPassword INIT '-' // Password for SMTP authenticated login - default is skip value
    VAR cProfile               // Account profile to use when sending email
    VAR cSendAddress           // senders email address
    VAR cAltSendAddress        // address displayed as from address - used for reply to
    VAR cFromName              // Plain text name - e.g. John Doe - shown as the sender
    
* Lists of recipients and flags

    VAR cToList                // List of recipients comma delimited
    VAR cCCList                // List of carbon copy recipients, comma delimited
    VAR cBCCList               // List of Blind CC recipients, comma delimited
    VAR cToFile                // filename of file containing recipients
    VAR cCCFile                // Filename of file containing CC'd recipients
    VAR cBCCFile               // Filename of file containing BCC'd recipients
    VAR nMaxNames INIT 0       // Send in groups of nMaxNames
    VAR lUndisclosed INIT .F.  // Use "undisclosed recipients" when to: and cc: not used
    
    VAR lDisposition INIT .F.  // Request disposition information
    VAR lReturnReceipt INIT .F.// Request return receipt
    VAR nPriority              // NIL for normal, 0 for low, 1 for high

* The message to be sent out

    VAR cMessageFile           // File name of file containing message text
    VAR cMessage               // message - cMessageFile takes precedence
    VAR lHTML INIT .F.         // Main message is HTML
    VAR cAltText               // alternative test for HTML message
    VAR cAltFile               // alternative text file for HTML message
    VAR cSubject               // Subject line
    VAR cSubjectFile           // Subject line file
    
    VAR cTagFile               // File containing tag lines randomly chosen
    VAR cSigFile               // File containing signature line
    VAR cPSFile                // File containing final lines - possibly unsubscribe info
    VAR cAttachFiles           // names of binary files to attach, comma separated
    VAR cAttachFileList        // name of file containing list of binary files to attach
    VAR cAttachTextFiles       // names of text files to attach, comma separated
    VAR cAttachTextList        // name of file containing list of text files to attach
    VAR cAttachInlineFiles     // names of INLINE files to attach, comma separated
    VAR cEmbedFiles            // names of embeded files to attach, comma delimited
    VAR cEmbedFilesList        // name of file containing a list of embeded files
    
* Other options

    VAR lBase64 INIT .F.       // include switch to send binaries using base64
    VAR lUUEncode INIT .F.     // include switch to send binaries UUEncoded
    VAR lEnriched INIT .F.     // include switch to send an enriched text message
    VAR lUnicode INIT .F.      // include switch to indicate message body is 16 or 32 bit unicode format
    VAR lMime INIT .F.         // include switch to indicate MIME
    VAR l8BitMime INIT .F.     // include switch to ask for 8bit data support when sending MIME
    
    VAR lDebug INIT .F.        // debug turned on
    VAR lSuperDebug INIT .F.   // super debug (ascii mode) turned on
    VAR lLogFile INIT .F.      // use a log file
    VAR cLogFile INIT "BlatLog.Log" // log file if any debug option turned on
    VAR lTimeStamp INIT .T.    // Include time stamps in debog
    VAR nTimeOut INIT 0        // Time out setting
    VAR nTry INIT 1            // 1 to "infinite" for infinite set to -1
    VAR nDelay INIT 0          // delay between messages when using maxnames of multipart
    VAR lNoHeader INIT .F.     // set the noh flag to prevent X-Mailer/User-Agent header from showing Blat homepage
    VAR lNoHeaderAtAll INIT .F.// set the noh2 flag to prevent X-Mailer header entirely

    VAR cOtherSwitches         // set this to send switches not covered in the above variables

    VAR lDontUseRegistry INIT .T. // do not set the registry with blat variables
    
    VAR lCommand INIT .F. HIDDEN  // command line has been initialized
    VAR cCommand HIDDEN        // common commands
    
    
ENDCLASS

* Initializes the BlatMail Class.  Loads DLL if that option is selected
* Really doesn't do much if link library is used for blat
*
* Calling Parameters:  None
*
* Returns:  Self

METHOD New() CLASS BLATMAIL
    
#ifdef _use_CallDLL

   IF nLoadedBlat=0
      hInstDLL:=LoadLibrary('BLAT.DLL')
      nLoadedBlat:=1
   ELSE
      nLoadedBlat++
   ENDIF

   RETURN (IIF(hInstDLL>0,self,NIL))

#else

   RETURN (self)

#endif

*********************************************************************************************
* This routine sets standard command line setting to be used for subsequent mailings
*
* Calling parameters: None
*
* Returns: self
*
* Note:  The following blat settings are set in this routine
*    -i cFromName "<cAltSendAddress>" ; address displayed as from address - used for reply to
*    -ur  ; use undisclosed recipients base upon value of ::lUndisclosed
*    -d ; request disposition based upon value of lDisposition
*    -r ; request return receipt based upon value of lReturnReceipt
*    -priority ::nPriority ; set priority: NIL for normal, 0 for low, 1 for high
*    -tag cTagFile ; set file containing tag lines randomly chosen
*    -sig cSigFile ; set file containing signature line
*    -ps cPSFile ; set file containing final lines - possibly unsubscribe info
*    -base64 ; based upon value of lBase64 to send binaries using base64
*    -uuencode ; based upon value of lUUEncode to send binaries UUEncoded
*    -enriched ; based upon value of lEnriched to send an enriched text message
*    -unicode ; based upon value of lUnicode to indicate message body is 16 or 32 bit unicode format
*    -mime ; based upon value of lMime to indicate MIME
*    -8bitmime ; based upon value of l8BitMime to ask for 8bit data support when sending MIME
*    -debug ; based upon value of lDebug to turn on debug
*    -superdebugT based upon value of lSuperDebug to turn on super debug (ascii mode)
*    -log cLogFile ; to set the logfile name if lLogFile is .T.
*    -timestamp ; based upon value of lTimeStamp to Include time stamps in debog
*    -ti nTimeout ; if nTimeOut > 0 set time out setting
*    -try nTry ; if nTry>0 set number of tries to nTry. If nTry -1 set to "infinite"
*    -delay nDelay ; if nDelay > 0 set delay between messages when using maxnames of multipart
*    -maxnames nMaxnames ; maximum number of names sent out at once
*    -noh ; prevent X-Mailer/User-Agent header from showing Blat homepage
*    -noh2 ; prevent X-Mailer header entirely
*
* If ::lDontUseRegistry is .T. then the following values are also set on the command line:
*
*     -server ; SMTP Server in the form of servername:Port
*     -serverPOP3 ; POP3 server in the form servername:port
*     -u ; username for SMTP login
*     -pw ; password for SMTP login
*     -pu ; username for POP3 login
*     -ppw ; password for POP3 login

METHOD SetCommandLine() CLASS BLATMAIL
   
::cCommand=''

IF ::lDontUseRegistry

* Basic SMTP server information
   ::cCommand+='-server '+::cSMTPServer+' -f '+::cSendAddress+;
                 IIF(::nSMTPPort!=25,' -port '+LTRIM(STR(::nSMTPPort,3,0)),'')+' '

* Login for SMTP
   IF !EMPTY(::cSMTPLogin)
      ::cCommand+='-u '+::cSMTPLogin+' '
   ENDIF

* Password for authenticated login
   IF ::cSMTPPassword!='-'
      ::cCommand+='-pw '+::cSMTPPassword+' '
   ENDIF

* POP3 login required
   IF !EMPTY(::cPOP3Server).AND.!EMPTY(::cPOP3Login)
      ::cCommand+='-ServerPOP3 '+::cPOP3Server+' -pu '+::cPOP3Login+' -ppw '+::cPOP3Password+' '
   ENDIF

ENDIF

* Alternative send name
IF !EMPTY(::cAltSendAddress)
* If there is a real name put it in the form of "John Smith<John.Smith@TheSmiths.org>"
   IF !EMPTY(::cFromName)
      ::cCommand+='-i "'+::cFromName+' <'+::cAltSendAddress+'>" '
   ELSE
* No real name so just put the alternate address      
      ::cCommand+='-i "'+::cAltSendAddress+'" '
   ENDIF
   
ENDIF

* Include undisclosed recipents message
IF ::lUndisclosed
   ::cCommand+='-ur '
ENDIF

* Request disposition
IF ::lDisposition
   ::cCommand+='-d '
ENDIF

* Request return receipt
IF ::lReturnReceipt
   ::cCommand+='-r '
ENDIF

* Set priority if high or low
IF ::nPriority!=NIL
   ::cCommand+='-priority '+STR(::nPriority,1,0)+' '
ENDIF

* Inlcude a list of tags
IF !EMPTY(::cTagFile)
   ::cCommand+='-tag '+::cTagFile+' '
ENDIF

* include a signature file
IF !EMPTY(::cSigFile)
   ::cCommand+='-sig '+::cSigFile+' '
ENDIF

* Include a PS file
IF !EMPTY(::cPSFile)
   ::cCommand+='-ps '+::cPSFile+' '
ENDIF

* Set maximum number of names to send at one time

IF ::nMaxNames>0
   ::cCommand+='-maxnames '+LTRIM(STR(::nMaxNames,5,0))+' '
ENDIF

* Use base 64 encoding
IF ::lbase64
   ::cCommand+='-base64 '
ENDIF

* Use uuencode
IF ::lUUEncode
   ::cCommand+='-uuencode '
ENDIF

* Use enriched coding
IF ::lEnriched
   ::cCommand:='-enriched '
ENDIF

* Unicode message
IF ::lUnicode
   ::cCommand+='-unicode '
ENDIF

* Use mime
IF ::lMime
   ::cCommand+='-mime '
ENDIF

* Use 8 bit mime
IF ::l8BitMime
   ::cCommand+='-8bitmime '
ENDIF

* Set debug flag

IF ::lDebug
   ::cCommand+='-debug '
ENDIF

* Set super debug text mode flag
IF ::lSuperDebug
   ::cCommand+='-superdebugT '
ENDIF

* Set log file on
IF ::lLogFile.AND.!EMPTY(::cLogFile)
   ::cCommand+='-log '+::cLogFile+' '
ENDIF

* Time stamp entries in log file
IF ::lTimeStamp
   ::cCommand+='-timestamp '
ENDIF

* Change timeout settings
IF ::nTimeOut>0
   ::cCommand+='-ti '+LTRIM(STR(::nTimeout,5,0))+' '
ENDIF

* Set number of times to try

IF !(::nTry=0.OR.::nTry=1)    // 0 or 1 indicate the default value of 1
   ::cCommand+='-try '+IIF(::nTry>0,LTRIM(STR(::nTry,6,0)),'INFINITE')+' '
ENDIF

* Set delay 
IF ::nDelay>0
   ::cCommand+='-delay '+LTRIM(STR(::nDelay,6,0))+' '
ENDIF

* No website in header 
IF ::lNoHeader
   ::cCommand+='-noh '
ENDIF

* No header at all
IF ::lNoHeaderAtAll
   ::cCommand+='-noh2 '
ENDIF

* Add other switch that are no covered by this logic

IF !EMPTY(::cOtherSwitches)
   ::cCommand+=::cOtherSwitches+' '
ENDIF

::lCommand=.T.

RETURN (self)

*********************************************************************************************
* This routine sets the default profile using blat.  Blat stores these values in the registry
* for future use.
*
* Calling parameters:
*         cProfile - the name of the profile to use in setting parameters - if blank the
*                    value of ::cProfile is used - if both are blank, BLAT's default is used
*
* Returns: Self
*
* Discussion:  This routine sets the login profile using the POP and SMTP account and password
*              information.  Set POP3 server, password and account values to use POP login prior to
*              SMTP login.  On exit, ::cProfile is set to either cProfile or "<default>" - Blat's default
*
*              If you have a profile stored on the computer already, then you do not need to call
*              this routine
*
*              The profile name cannot contain spaces
*

METHOD SetProfile(cProfile) CLASS BLATMAIL
   
LOCAL cActualProfile   // the profile we will actually use

* Fix up the profile if needed
IF !EMPTY(cProfile)
   cActualProfile=cProfile
ELSEIF !EMPTY(::cProfile)
   cActualProfile=::cProfile
ELSE
   cActualProfile='"<default>"'
ENDIF

cActualProfile:=ALLTRIM(cActualProfile)   // trim because blat is overly space sensitive

* Clear our any old values

CallSend('-profile -delete '+cActualProfile+' -q')

* Reestablish profile

IF EMPTY(::cSMTPPassword)
* No SMTP logins required
    CallSend('-install '+::cSMTPServer+' '+::cSendAddress+' - '+LTRIM(STR(::nSMTPPort,3,0)) + cActualProfile)
ELSE
    CallSend('-install '+::cSMTPServer+' '+::cSendAddress+' - '+LTRIM(STR(::nSMTPPort,3,0))+' '+cActualProfile;
        +' '+::cSMTPLogin+' '+::cSMTPPassword+' -q')
ENDIF

* IF POP3 login is needed then set that

IF !EMPTY(::cPOP3Server).AND.!EMPTY(::cPOP3Login)
     CallSend('-installPOP3 '+::cPOP3Server+' - - '+LTRIM(STR(::nPOP3Port,3,0))+' '+::cProfile+' '+::cPOP3Login;
         +' '+::cPOP3Password+' -q')
ENDIF

* Set actual profile being used

::cProfile=cActualProfile

RETURN Self

*********************************************************************************************
* This routine actually sends the mail out.
*
* Calling Parameters: None
*
* Returns: nReturn - value returned by blat
*
* Description:  This routine uses the following values to send out the actual email
*
* The message is sent from either cMessageFile (takes precidence) or cMessage
* The message is set to be an HTML file if lHTML is .T.
*    If lHTML is .T. then:
*
*       Embeded files are included if cEmbedFiles or cEmbedFilesList is not NIL (comma delimited for a list)
*       Alternative text is provided if cAltText or cAltFile (takes precidence) is not empty
*
* The message subject is set to cSubject or cSubjectFile (takes presidence) is not empty
*
* Attachents can be added as follows:
*   Binary: cAttachFiles or cAttachFileList (takes presidence) 
*   Text:   cAttachTextFiles or cAttachTextList (takes presidence)
*   Inline: cAttachInlineFiles 

* Message additions are added with:
*     cTagFile which is a file containing tag lines randomly chosen
*     cSigFile which is a file containing signature line
*     cPSFile which is a file containing final lines - possibly unsubscribe info
*
* Recipients:
*     To recipients: cToList (a list of recipients comma delimited) or cToFile (Filename of file 
*                    containing recipients) (takes presidence)
*     To carbon copied recipients: cCCList (List of carbon copy recipients, comma delimited) or
*                    cCCFile (Filename of file containing CC'd recipients) (takes presidence)
*     To Blind CC'd recipients: cBCCList (list of Blind CC recipients, comma delimited) or
*                   cBCCFile (Filename of file containing BCC'd recipients) (takes presidence)

METHOD MailSend() CLASS BLATMAIL     // Actually send the mail

LOCAL cFinalCommand   // actual command
LOCAL nReturn         // return value from Blat

* If basic switches haven't been initialized then do it now

IF !::lCommand
   ::SetCommandLine()
ENDIF

* Message

IF EMPTY(::cMessageFile)
* Command line message - put a place holder since the body command must come later
   cFinalCommand="- "
ELSE
* message in a file
   cFinalCommand=::cMessageFile+' '
ENDIF

IF !EMPTY(::cToFile)
* Recipents in a file
   cFinalCommand+='-to - -tf '+::cToFile+' '
ELSE
* Recipents on the command line
   cFinalCommand+='-to '+::cToList+' '
ENDIF

* Message body if not in text

IF EMPTY(::cMessageFile)
   cFinalCommand+='-body "'+::cMessage+'" '
ENDIF

* Subject

IF !EMPTY(::cSubjectFile)
* Subject line in a file
   cFinalCommand+='-sf '+::cSubjectFile+' '
ELSEIF !EMPTY(::cSubject)
* Subject line on command line
   cFinalCommand+='-s "'+::cSubject+'" '
ENDIF

* CC'd recipients

IF !EMPTY(::cCCFile)
* Carbon copied recipents in a file   
   cFinalCommand+='-cf '+::cCCFile+' '
ELSEIF !EMPTY(::cCCList)
* Carbon copied recipents on the command line   
   cFinalCommand+='-cc '+::cCCList+' '
ENDIF

* BC'd recipients

IF !EMPTY(::cBCCFile)
* BCC list in a file
   cFinalCommand+='-bf '+::cBCCFile+' '
ELSEIF !EMPTY(::cBCCList)
* BCC on the command line
   cFinalCommand+='-bcc '+::cBCCList+' '
ENDIF

* Handle HTML files

IF ::lHTML
* First indicate that the message body is an HTML file

   cFinalCommand+='-html '

* Now add any files for embeded references

   IF !EMPTY(::cEmbedFilesList)
      cFinalCommand+='-aef '+::cEmbedFilesList+' '
   ELSEIF !EMPTY(::cEmbedFiles)
      cFinalCommand+='-embed '+::cEmbedFiles+' '
   ENDIF

* Alternate text

   IF !EMPTY(::cAltFile)
* Alternate text is in a file      
      cFinalCommand+='-alttextf '+::cAltFile+' '
* Alternate text is on the command line      
   ELSEIF !EMPTY(::cAltText)
      cFinalCommand+='-alttext '+::cAltText+' '    
   ENDIF

ENDIF

* Attach binary files

IF !EMPTY(::cAttachFileList)
* Attached files list is contained in a file   
   cFinalCommand+='-af '+::cAttachFileList+' '
ELSEIF !EMPTY(::cAttachFiles)
* Attached files are listed on the command line   
   cFinalCommand+='-attach '+::cAttachFiles+' '
ENDIF

* Attach text file

IF !EMPTY(::cAttachTextList)
* Attached files list is in a file   
   cFinalCommand+='-atf '+::cAttachTextList+' '
ELSEIF !EMPTY(::cAttachTextFiles)
* Attached files are put on the command line   
   cFinalCommand+='-attacht '+::cAttachTextFiles+' '
ENDIF

* Inline files go here

IF !EMPTY(::cAttachInlineFiles)
   cFinalCommand+='-attachi '+::cAttachInLineFiles+' '
ENDIF

* Add the constant command line stuff

cFinalCommand+=::cCommand

* Send the mail out

nReturn:=CallSend(cFinalCommand+'-q')

RETURN (nReturn)

*********************************************************************************************
* This routine unloads the blat DLL if it has been loaded
*
* Calling parameters: lAbsolute - Unload in spite of the load count
*
* Returns:  Self
*
* Discussion:  This routine will unload the BLAT DLL if it has been loaded
*              using a call to LOADLIBRARY.  Normally, these routines keep
*              track of a load count.  When the count is 1 and this routine
*              is called, the DLL will be unloaded.  If you want to override
*              this behavour, call with lAbsolute = .T. which will cause the
*              DLL to be unloaded if it has been loaded at any time.

METHOD BlatUnload(lAbsolute)  CLASS BLATMAIL

#ifdef _use_CallDLL

   IF VALTYPE(lAbsolute)!='L'
      lAbsolute:=.F.
   ENDIF
   IF nLoadedBlat=1.OR.(lAbsolute.AND.nLoadedBlat>0)

* If have Blat loaded once or we are wanting to do it no matter how many times
* we have loaded it then unload it

      FreeLibrary(hInstDLL)
      nLoadedBlat:=0
   ELSEIF nLoadedBlat>0

* If we are called to unload and it has been loaded more than once, then decrement
* the counter

      nLoadedBlat--
   ENDIF
    
#endif

RETURN (Self)

STATIC FUNCTION CallSend(cCommand)
LOCAL nReturn

#ifdef _debug
  SET ALTE TO 'blatdebug.log' ADDITIVE
  SET ALTE ON
  QOUT(cCommand)
  SET ALTE TO
  SET ALTE OFF
#endif

#ifdef _use_CallDLL

  nReturn:=CallDLL(hInstDLL,GetProcAddress(hInstDLL,'cSend'),,3,10,cCommand)

#else

  nReturn:=BlatSend(cCommand)

#endif

RETURN nReturn

#ifndef _use_CallDLL

#pragma BEGINDUMP

#include <windows.h>
#include "hbapiitm.h"

extern int __cdecl cSend (LPCSTR sCmd);

HB_FUNC_STATIC( BLATSEND )
{
   LPCSTR Command;
   int nReturn;

   Command = hb_parc(1);
   nReturn = cSend(Command);

   hb_retnl(nReturn);
}

#pragma ENDDUMP

#endif
