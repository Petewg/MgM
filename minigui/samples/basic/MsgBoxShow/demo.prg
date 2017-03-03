ANNOUNCE RDDSYS

#include "minigui.ch"

*------------------------------------------------------------------------------*
Procedure Main
*------------------------------------------------------------------------------*

	LOAD WINDOW Demo
	CENTER WINDOW Demo
	ACTIVATE WINDOW Demo

Return

#define IDI_MAIN 1001
#define MsgInfo( c, t ) MsgInfo( c, t, IDI_MAIN, .f. )
*------------------------------------------------------------------------------*
Function MsgAbout()
*------------------------------------------------------------------------------*
Return MsgInfo(padc('Message Box Show - FREEWARE', 36) + CRLF + ;
	"Copyright " + Chr(169) + " 2007 by Grigory Filatov" + CRLF + CRLF + ;
	padc("eMail: gfilatov@inbox.ru", 36) + CRLF + CRLF + ;
	padc("This program is Freeware!", 36) + CRLF + ;
	padc("Copying is allowed!", 40), 'About')

#define MB_OK                                 0
#define MB_OKCANCEL                           1
#define MB_ABORTRETRYIGNORE                   2
#define MB_YESNOCANCEL                        3
#define MB_YESNO                              4
#define MB_RETRYCANCEL                        5
#define MB_CANCELTRYCONTINUE                  6
#define MB_ICONHAND                          16
#define MB_ICONQUESTION                      32
#define MB_ICONEXCLAMATION                   48
#define MB_ICONASTERISK                      64
#define MB_USERICON                         128
#define MB_ICONWARNING              MB_ICONEXCLAMATION
#define MB_ICONERROR                MB_ICONHAND
#define MB_ICONINFORMATION          MB_ICONASTERISK
#define MB_ICONSTOP                 MB_ICONHAND
*------------------------------------------------------------------------------*
Function TestMessage()
*------------------------------------------------------------------------------*
Local nStyle := MB_OK
Local title := Demo.Text_1.Value
Local message := Demo.Edit_1.Value
Local icon := Demo.RadioGroup_1.Value
Local btns := Demo.RadioGroup_2.Value

switch btns
	case 2
		nStyle := MB_OKCANCEL
		exit
	case 3
		nStyle := MB_ABORTRETRYIGNORE
		exit
	case 4
		nStyle := MB_YESNOCANCEL
		exit
	case 5
		nStyle := MB_YESNO
		exit
	case 6
		nStyle := MB_RETRYCANCEL
end

switch icon
	case 2
		nStyle += MB_ICONERROR
		exit
	case 3
		nStyle += MB_ICONWARNING
		exit
	case 4
		nStyle += MB_ICONINFORMATION
		exit
	case 5
		nStyle += MB_ICONQUESTION
end

	MESSAGEBOXINDIRECT( , message, title, nStyle )

Return NIL

*------------------------------------------------------------------------------*
Function ChangeImage()
*------------------------------------------------------------------------------*
Local icon := Demo.RadioGroup_1.Value

switch icon
	case 1
		Demo.Image_1.Picture := ""
		Demo.Image_1.Refresh
		exit
	case 2
		Demo.Image_1.Picture := "STOP"
		exit
	case 3
		Demo.Image_1.Picture := "EXCL"
		exit
	case 4
		Demo.Image_1.Picture := "INFO"
		exit
	case 5
		Demo.Image_1.Picture := "QUES"
end

Return NIL
