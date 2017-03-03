
FUNCTION MAIN
	Local cServer := "127.0.0.1"
	Local cPort := "2941"

	NETIO_CONNECT()

	use ("net:" + cServer + ":" + cPort + ":base\test")

	browse()

RETURN NIL
