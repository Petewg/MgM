/*
 * demo2.prg
 *
 * This file is part of "SQLite3Facade for Harbour".
 *
 * This work is licensed under the Creative Commons Attribution 3.0 
 * Unported License. To view a copy of this license, visit 
 * http://creativecommons.org/licenses/by/3.0/ or send a letter to 
 * Creative Commons, 444 Castro Street, Suite 900, Mountain View, 
 * California, 94041, USA.
 *
 * Copyright (c) 2013, Richard Visscher
 */

PROCEDURE Main()
    LOCAL oSQL
    LOCAL aStruct := {}
    LOCAL nStart
    LOCAL n,nRecords
    LOCAL aFirstNames,aMidNames,aSurNames,aData
    LOCAL nFName,nMName,nSName
    LOCAL nAge
    LOCAL cName	
    LOCAL stmt,rs

    IF File("sqlite.db")
       FErase("sqlite.db")
    ENDIF

    IF File("mixed.dbf")
       FErase("mixed.dbf")
    ENDIF

    AAdd( aStruct,{ "mytext"  , "C", 100,0 } )
    AAdd( aStruct,{ "myint"   , "N",  2,0 } )
    AAdd( aStruct,{ "myfloat" , "N", 10,2 } )  
    AAdd( aStruct,{ "mydate"  , "D",  8,0 } )
    AAdd( aStruct,{ "mybool"  , "L",  1,0 } )

    // populate table with random compounded names
    aFirstNames := { "John", "Mike", "Willian", "Richard" }
    aMidNames := { "Hammer", "Pliers", "Screw", "Bolt" }
    aSurNames := { "Strawberry", "Water", "Coffee", "Pineapple", "Crookie" }

    ? "=================================================="
    ? "Creating DBF file"     
    ? "=================================================="

    nStart := Seconds()
    DbCreate( "mixed.dbf", aStruct )

    ? "=================================================="
    ? "Insert [exclusive] 5000 records into DBF"
    ? "=================================================="

	USE mixed EXCLUSIVE 

	nRecords := 0

	FOR n := 1 TO 5000

		nFName := HB_RandomInt( 1, LEN( aFirstNames ) )
		nMName := HB_RandomInt( 1, LEN( aMidNames ) )
		nSName := HB_RandomInt( 1, LEN( aSurNames ) )

		cName := aFirstNames[ nFName ] + " " + ;
					aMidNames[ nMName ]   + " " + ;
					aSurNames[ nSName ]

		nAge := HB_RandomInt( 1, 95 )

		mixed->( DbAppend() )
		mixed->mytext  := cName
		mixed->myint   := nAge
		mixed->myfloat := 1234.67
		mixed->mydate  := Date() - nAge
		mixed->mybool  := .F.

		nRecords++	

	NEXT	

	mixed->(DbCommit() )

	? "============================================================"
	? " Added " + AllTrim( Str( nRecords ) ) + " records into DBF" 
	? " Done in ", Alltrim( Str( Seconds() - nStart) )   
	?? " seconds"
	? "============================================================"
	? ""

	? "Press any key for next test"
	inkey(0)

	? "=================================================="
	? "Creating SQLite file"
	? "=================================================="

	nStart := Seconds()
	nRecords := 0

	oSQL := SQLiteFacade():New("sqlite.db") 
	oSQL:Open()
	oSQL:CreateTable("mixed",aStruct)

	? "=================================================="
	? "Insert 5000 records with transaction into SQLite"
	? "=================================================="

	stmt := oSQL:Prepare("INSERT INTO mixed ( mytext,myint,myfloat,mydate,mybool) VALUES(:mytext,:myint,:myfloat,:mydate,:mybool);")
	oSQL:BeginTransaction()

	FOR n := 1 TO 5000

		nFName := HB_RandomInt( 1, LEN( aFirstNames ) )
		nMName := HB_RandomInt( 1, LEN( aMidNames ) )
		nSName := HB_RandomInt( 1, LEN( aSurNames ) )

		cName := aFirstNames[ nFName ] + " " + ;
					aMidNames[ nMName ]   + " " + ;
					aSurNames[ nSName ]

		nAge := hb_RandomInt( 1, 95 )

		stmt:SetString(":mytext",cName)
		stmt:SetInteger(":myint",nAge)
		stmt:SetFloat(":myfloat",1234.67)
		stmt:SetDate(":mydate", Date() - nAge )
		stmt:SetBoolean(":mybool",.F.)
		stmt:ExecuteUpdate()

		nRecords++	

		stmt:reuse():clear()

	NEXT

	oSQL:CommitTransaction()

	? "=============================================================="
	? " Added " + AllTrim( Str( nRecords ) ) + " records into SQLite" 
	? " Done in ", Alltrim( Str( Seconds() - nStart ) )
	?? " seconds"
	? "=============================================================="
	? ""

	? "Press any key for next test"
	inkey(0)

	nStart := Seconds()
	aData := {}

	? "Loop through DBF records"

	mixed->(DbGoTop())
	DO WHILE !mixed->(EoF())
		AAdd( adata, Alltrim(mixed->mytext) )
		mixed->(DbSkip())
	ENDDO 		

	? "=============================================================="	 
	? "Added " + Str(Len( aData)) + " DBF records into array in ", Seconds() - nStart   
	?? " seconds"
	? "=============================================================="	
	? ""

	inkey(0)
	? "Press any key for next test"

	nStart := Seconds()
	aData := {}

	? "Loop through SQLite records"

	stmt := oSQL:prepare("SELECT mytext FROM mixed;")
	rs := stmt:ExecuteQuery()
   

	WHILE rs:Next()
		AAdd( aData, Alltrim(rs:getString("mytext")) )
	END

	? "=============================================================="	 
	? "Added " + Str(Len(aData)) + " SQLite records into array in ", Seconds() - nStart   
	?? " seconds"
	? "=============================================================="	
	inkey(0)

	mixed->(DbCloseArea())

	stmt:Close()
	rs:close()
	oSQL:Close()

RETURN
