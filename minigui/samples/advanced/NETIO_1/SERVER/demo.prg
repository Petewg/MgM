procedure main( nPort, cIfAddr, cRootDir, xRPC, ... )

local pListenSocket

	pListenSocket := netio_mtserver( nPort, cIfAddr, cRootDir, xRPC, ... )

	if empty( pListenSocket )
		? "Cannot start server."
	else
		wait "Press any key to stop NETIO server."
		netio_serverstop( pListenSocket )
		pListenSocket := NIL
	endif

return
