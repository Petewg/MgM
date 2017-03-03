/*
 *	MiniGUI Basic NetIO Server Sample.
 *	Roberto Lopez <mail.box.hmg@gmail.com>
*/

#include <hmg.ch>

Function Main

LOCAL nPort		:= 50000
LOCAL cIfAddr		:= '0.0.0.0'
LOCAL cRootDir		:= '.'
LOCAL lRPC		:= .T.
LOCAL cPasswd		:= 'secret'
LOCAL nCompressionLevel	:= 9
LOCAL nStrategy		:= NIL
LOCAL pSockSrv		:= NIL


	* Start Server

	pSockSrv := NETIO_MTSERVER( nPort , cIfAddr , cRootDir , lRPC , cPasswd , nCompressionLevel , nStrategy )
	if empty( pSockSrv )
		MSGSTOP("Can't Start Server!")
		Return Nil
	endif

        Load Window Main

        Main.Activate

Return Nil


Function ServerStop( pSockSrv )

	* Stop Server

	netio_serverstop( pSockSrv , .t. )

Return Nil
