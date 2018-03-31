HMG GridPrint

HMG GridPrint is a small add-on functionality which can be attached to a HMG Grid control.
It is an interface to HMG print facility to print the contents of a grid along with some additional features.
It can be called by two ways, viz., method and command.


Syntax for both the ways are,


Method:  

<WindowName>.<ControlName>.Print( aHeaders )


Command:

PRINT GRID <GridName>  
OF <ParentName>  
[ FONT <cFontName> ]  
[ SIZE <nFontSize> ]  
[ ORIENTATION <cOrientation> ]  
[ HEADERS <aHeaders> ]  
[ SHOWWINDOW ]  
[ MERGEHEADERS <aMergeHeaders> ]  
[ COLUMNSUM <aColumnSum> ]  

Parameters for this command:

GridName: Name of the grid control

ParentName: Name of the parent window of the grid control

Font: Name of the font as a character string

Size: Size of the font in points

Orientation: "P" for Portrait and "L" for Landscape

Headers: An array of strings for the custom headers for the report. (Maximum of three headers allowed)

ShowWindow: If omitted, the grid would be printed directly to the printer without showing the GridPrint features window.
            Even though 'showwindow' is omitted, if the columns don't fit in the page width, the GridPrint window will be shown.

MergeHeaders: To merge two or more columns and have a common header. For using this feature, a two dimensional array of details
              of merged headers shall be passed with each element in the following format,
              {{nStartCol1,nEndCol1,cMergedHeader1},{nStartCol2,nEndCol2,cMergedHeader2},...}

ColumnSum: Page-wise summation of some columns of the grid control can be achieved using this parameter.
           A two dimensional array with number of elements equal to the number of columns, in the following format,
           {{lSumReqdCol1,cTransformMask1},{lSumReqdCol2,cTransformMask2},{lSumReqdCol3,cTransformMask3}...} shall be passed.


Sample:

PRINT GRID grid_1;
	OF form_1;
	FONT "Arial";
	SIZE 12;
	ORIENTATION "P";
	HEADERS {"Header1","Header2","Header3"};
	SHOWWINDOW;
	MERGEHEADERS {{1,3,"Merged Header1"},{5,6,"Merged Header2"}};
	COLUMNSUM {{.f.,''},{.f.,''},{.t.,"99,999.99"},{.t.,"$ 999,999,999"},{.f.,''},{.f.,''}}


GridPrint Window:

This window has many features to configure the report which are all self explanatory. They are listed below:

- Selection of columns to report (You can remove a particular column of the grid in reporting)
- The print size of the columns can be altered.
- Headers and Footers can be added/modified. 
- Page numbers are printed on each page. It can be printed either on top or bottom of the page. Or, if it is not needed that can be removed too.
- Font size of the report can be changed.
- Column wise, row wise grid lines can be printed/removed.
- Report can be vertically centered to look neatly.
- Extra White space between the columns can be spread, so that the report is to fill the width of the paper excluding the margin.
- Orientation of the report can be selected
- Printer can be selected from a list
- Standard page sizes or custom page size can be selected, so are the margins.
- A blue print preview of the first page is shown before getting printed.  


S.Rathinagiri <srgiri@dataone.in>