#include "minigui.ch"

Memvar cBaseLang, aLangStrings, cFileLng
*--------------------------------------------------
Function GetLangArr()
*--------------------------------------------------
    Local aStr := { ;
	"&File", ;		// Main Menu
	"&Open...", ;
	"&Open in", ;
	"&Close", ;
	"&Save", ;
	"Save &As/Export...", ;
	'Recent Files', ;
	'Empty', ;
	"E&xit", ;
	"&Edit", ;
	"&Find...", ;
	"&Replace...", ;
	"&Go To...", ;
	"&Append Record", ;
	"Emp&ty", ;
	"Copy C&urrent", ;
	"&Delete status", ;
	"&Delete Record", ;
	"&Undelete Record", ;
	"&Toggle Delete", ;
	"Delete &All", ;
	"U&ndelete All", ;
	"&Pack Table", ;
	"&Zap Table", ;
	"&View", ;
	"&Adjust Columns", ;
	"&Refresh", ;
	"&Background color...", ;
	"&Font...", ;
	"&Language...", ;
	"&Table", ;
	"&Codepage...", ;
	"&Query...", ;
	"&Properties...", ;
	"&Window", ;
	"&Cascade", ;
	"&Tile", ;
	"&Hide All", ;
	"&Show All", ;
	"&Help", ;
	"&Index", ;
	"&About", ;
	"Open", ;		// Tooltips
	"Save", ;
	"Toggle delete", ;
	"Find", ;
	"Go To", ;
	"Codepage", ;
	"Properties", ;
	"Adjust columns", ;
	"Query", ;
	"Refresh", ;
	"About", ;
	"Font Name", ;
	"Font Size", ;
	"Table", ;		// Child window
	"Append &New", ;
	"Append C&opy", ;
	"Record", ;
	"of", ;
	"already exists", ;  // Export
	"Overwrite existing file?", ;
	"Sorry, you may open 12 files only!", ;
	"<all columns>", ;	// S&R
	"Replace", ;
	"Search", ;
	"Look for", ;
	"Replace with", ;
	"Direction", ;
	"Forward" , ;
	"Backward" , ;
	"Entire scope", ;
	"Search in column", ;
	"Match &case", ;
	"Match &whole word only", ;
	"&Find Next", ;
	"Replace &All", ;
	"Can not find the string", ;
	"There are no still such records!", ;
	"Go to", ;		// Go To
	"&Top", ;
	"&Bottom", ;
	"Ro&w", ;
	"&Record", ;
	"OK", ;
	"Cancel", ;
	"Select language", ; // Lang
	"Date format", ;
	"<no codepage set>", ; // CP
	"Select codepage", ;
	"Select codepage for the current table", ;
	"Table properties", ;	// Prop
	"File", ;
	"Size", ;
	"byte(s)", ;
	"Created", ;
	"Modified", ;
	"Number of records", ;
	"Header size", ;
	"Record size", ;
	"Number of fields", ;
	"Packing the table permanently removes records that are marked for deletion", ;
	"Pack the table", ;
	"Zaping the table permanently removes the ALL records", ;
	"Zap the table", ;
	"The file is not found", ; // Open
	"Query", ;		// Query
	"Field", ;
	"Comparison", ;
	"== Equal           ", ;
	"<> Not equal       ", ;
	"<  Less than       ", ;
	">  Greater than    ", ;
	"<= Less or equal   ", ;
	">= Greater or equal", ;
	"() Contains        ", ;
	"$  Is contained in ", ;
	'"" Is empty (blank)', ;
	"deleted()", ;
	"Value", ;
	"Character", ;
	"Numeric", ;
	"Date", ;
	"Logical", ;
	"Query expression", ;
	"A&dd", ;
	"&Undo", ;
	".and.", ;
	".or.", ;
	".not.", ;
	"&Apply", ;
	"&Load", ;
	"There are no such records!", ;
	"Enter a brief description of this query", ;
	"Query Description", ;
	"Save Query", ;
	"A query with the same description was found for this database", ;
	"Do you wish to overwrite the existing query or append a new one?", ;
	"Duplicate Query", ;
	"Query Saved", ;
	"Select a Query to Load", ;
	"does not contain any queries", ;
	"Load Query", ;
	"Database", ;
	"Description", ;
	"Query Expression", ;
	"&Delete", ;
	"is not a DataBase query file", ;
	"The query's filename does not match that of the currently loaded file", ;
	"Load it anyway?", ;
	"Different Filename", ;
	"Are you sure you wish to recall this record?", ;
	"Recall", ;
	"Are you sure you wish to delete this record?", ;
	"Delete", ;
	"Syntax error in Query expression!" }

Return aStr

*--------------------------------------------------
Procedure SetBaseLang()
*--------------------------------------------------
    Local cSec := UPPER(cBaseLang)

    DO CASE
	CASE cSec == 'SPANISH'
		SET LANGUAGE TO SPANISH
	CASE cSec == 'FRENCH'
		SET LANGUAGE TO FRENCH
	CASE cSec == 'PORTUGUESE'
		SET LANGUAGE TO PORTUGUESE
	CASE cSec == 'ITALIAN'
		SET LANGUAGE TO ITALIAN
	CASE cSec == 'GERMAN'
		SET LANGUAGE TO GERMAN
	CASE cSec == 'RUSSIAN'
		SET LANGUAGE TO RUSSIAN
	CASE cSec == 'POLISH'
		SET LANGUAGE TO POLISH
	CASE cSec == 'FINNISH'
		SET LANGUAGE TO FINNISH
	CASE cSec == 'DUTCH'
		SET LANGUAGE TO DUTCH
	CASE cSec == 'BULGARIAN'
		SET LANGUAGE TO BULGARIAN
	OTHERWISE
		SET LANGUAGE TO ENGLISH
    ENDCASE

Return

*--------------------------------------------------
Procedure LoadLangArr()
*--------------------------------------------------
	Local i

	BEGIN INI FILE cFileLng
		For i:=1 To Len(aLangStrings)
			aLangStrings[i] := GetSetting(cBaseLang, Ltrim(Str(i)))
		Next
	END INI

Return

*--------------------------------------------------
Static Function GetSetting (cSec, cEnt)
*--------------------------------------------------
    Local cVal := ''

    GET cVal SECTION cSec ENTRY cEnt DEFAULT ""
 
Return cVal