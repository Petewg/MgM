BUILDER OF THE FUNCTION LIST

DESIGNATION

The program is intended for creating the list of procedures/functions,
which are contained in the Harbour-programs. It were created in the process
of acquaintance with MiniGUI's distribution, since in examples contained
the using of functions, which are not described in the documentation.
Arose the thought to once create catalog, instead of repeated searches by FAR
in the files of distribution.

Additional possibilities - simple formatting of the source code.

CREATION OF THE LIST

For creating the list it is necessary to indicate the catalog, which contains
files PRG and C. At the end of the working program will ask to introduce
the designation of the obtained list, which will be mapped into the title of
main window and file for the retention. In the process of working will recognize
the procedures and the functions, determined by operators [ STATIC ] PROCEDURE,
[ STATIC ] FUNCTION, HB_FUNC. Will recognize also their reduced writing, for example
[ STAT ] PROC. Purely the C-functions (for example, WORD DIBNumColors(LPSTR)),
which are not utilized directly in calls Harbour, will not recognize.

Program was intended for creating the catalog of functions in the MiniGUI's distribution;
therefore the sorting of the obtained list was oriented to the pair it was file h_*.prg-c_*.c,
for example:

.........
h_btntextbox.prg
	_DefineBtnTextBox
	InitDialogBtnTextBox
c_btntextbox.c
	INITBTNTEXTBOX
	REDEFBTNTEXTBOX
h_button.prg
.........

ACTIONS WITH THE LIST

- the search for the expression (it is tuned in the parameters of program);
  it is carried out from the current position.
- the search for all entries in the list of the desired fragment (result it depends on
  the established in the tuning mode). Application - for example, for the development
  of all similar procedures/functions.
- the introduction of commentaries into the line
- the saving of the obtained list into the text file and load from the file
- the call of external editor for treating the module (it is tuned)

FORMATTING OF THE PROGRAMS TEXT

In the working fall only the files with expansion PRG, the resulting files are placed
into <project_folder>\Stock.src.
The compiler directive #define, #command, #xcommand, #translate are transferred "as is"
into the resulting file in the process of building.
The keywords are determined in files Data\commands.lst and Data\Phrases.lst.
The first one - the list of the converted commands and functions, the second - composite
commands (for example, Copy structure).
The rules of filling of the keywords files is:
- for each keyword (expression) is removed the separate line;
- empty lines are ignored;
- the line of commentary begins with symbol ";" and also it is not processed;
- for the substitution into the formatting file of word in accurately the same form
  as assignedly in the list, word should be begun from the asterisk ("*").

Example.

Commands.lst		The result 

ElseIf			elseif, Elseif, ELSEIF (depending on the installation of a change in the register)
*ElseIf			ElseIf (register it does not change)

TABLE OF CALLS FUNCTIONS

In the table fall only accessible of all it is file the programs of procedures/functions
(i.e. definition as Procedure, Function, HB_FUNC).
Possible application - reorganization of the structure of program.
For example, for the isolation of general functions into the separate procedural file.

TUNING

Lingual files can be edited with the aid of the INI File Editor from MiniGUI's distribution,
it is necessary to change expansion only.

"Action at startup"
	Selector makes it possible to select the variant of the starting of the program:
		with the load of the last preserved list or without.

"Search in the list"
	the installation of search mode: is accurate correspondence or to the entry of fragment.

"External editor"
	in the line is indicated external editor for changing the programm's modules.
	For example, C:\Tools\PsPad\PsPad.exe. The mode of the loading is assigned additionally:

	- "To open file without the conditions"
		Program file simply is opened in the predetermined program of the editing

	- "To determine and to transmit the number of line %N"
		In editor, besides the name of file, is transferred the number of the line,
		which contains the current procedure.
		The parameter, corresponding to the parameter of the call of editor,
		it is indicated in the field opposite the switch.
		Editor must support a similar variant of starting.
		For the large is file this the slowest method.

	Expression %N is used by a program for the substitution of necessary value.

Example.

Format of the calling for editor PsPad in this case: PsPad /nnn. In the field of the name of editor
indicates <path>PsPad.exe, selector - to the position "To determine and to transmit the number of line %N"
and in the field opposite the position become accessible we enter /%N

For editor SciTe. Format of the calling: SciTE <filename> -goto:<nnn>. We assign editor <path>SciTE.exe,
and against the position of the selector: -goto:%N

- "To transmit the name of procedure %P"
	Editor additionally obtains line for the search for necessary procedure.

Expression %P is used by a program for the substitution of necessary value.

Example.

This calling for PsPad does not support; therefore only for SciTE. Format of call
SciTE <filename> -find:<sting>.
To establish selector into the position "To transmit the name of procedure %P",
in that become accessible field opposite the switch to enter: -find:%P

Passage can be not precise, since the function can be used to its determination.
But search can be continued already in the editor.

REFERENCES

PSPad http://www.pspad.com/en/pspad.htm
SciTE http://scite.ruteam.ru/
