  #xcommand DECLARE <return> [<static:STATIC>] <FuncName>( [ <type1> <uParam1> ] ;
							[, <typeN> <uParamN> ] ) ;
             [FLAGS <flags>] IN <*DllName*> ;
       => ;
          [<static>] function <FuncName>( [<uParam1>] [,<uParamN>] ) ;;
             local uResult ;;
             Local hDLL := If( ValType(<DllName>) == "N", <DllName>, LoadLibrary(<(DllName)>) );;
             Local nProcAddr := GetProcAddress(hDLL,<(FuncName)>);;
             uResult := CallDLL(hDLL, nProcAddr, [<flags>], <return> [, <type1>, <uParam1> ] [, <typeN>, <uParamN> ] ) ;;
             If( ValType(<DllName>) == "N",, FreeLibrary(hDLL) );;
             return uResult

  #xcommand DECLARE <return> [<static:STATIC>] <FuncName>( [ <type1> <uParam1> ] ;
							[, <typeN> <uParamN> ] ) ;
             ALIAS <alias> [FLAGS <flags>] IN <*DllName*> ;
       => ;
          [<static>] function <alias>( [<uParam1>] [,<uParamN>] ) ;;
             local uResult ;;
             Local hDLL := If( ValType(<DllName>) == "N", <DllName>, LoadLibrary(<(DllName)>) );;
             Local nProcAddr := GetProcAddress(hDLL,<(FuncName)>);;
             uResult := CallDLL(hDLL, nProcAddr, [<flags>], <return> [, <type1>, <uParam1> ] [, <typeN>, <uParamN> ] ) ;;
             If( ValType(<DllName>) == "N",, FreeLibrary(hDLL) );;
             return uResult
