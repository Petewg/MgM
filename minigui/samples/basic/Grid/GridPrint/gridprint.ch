#xcommand PRINT GRID <cGridName> ;
   OF <cParentName> ;
	[ FONT <cFontName> ]   ;
	[ SIZE <nFontSize> ]   ;
	[ ORIENTATION <cOrientation> ] ;
	[ HEADERS <aHeaders> ] ;
	[ <showwindow : SHOWWINDOW> ] ;
	[ MERGEHEADERS <aMergeHeaders> ] ;
	[ COLUMNSUM <aColumnSum> ] ;
	=> ;
	_GridPrint(<"cGridName">,<"cParentName">,<nFontSize>,<cOrientation>,<aHeaders>,<cFontName>,<.showwindow.>,<aMergeHeaders>,<aColumnSum>)
