[ITA]
A causa di uno stop forzato mi sono incontrato in questa utility.
Mi � piaciuta subito, quindi ho voluto adattarla a Minigui Extended,
non solo, ma ne ho aumentato le funzionalit�, corretto i bug e facilitato
la possibilit� di implementare nuove modifiche a questo che � ora
diventato un RAD a tutti gli effetti.
Alcune delle funzioni sono generate per sviluppi futuri , ma non sono
problematiche, sta a voi toglierle e /o adattarle.

Questo programma non � un' ide e non pretende di essere alla pari di un rad...

Il progetto iniziale � di un utente di HMG il cui alias � Dragancesu
e che ringrazio per l'idea.
Ringrazio inoltre Grigory Filatov quale supervisore e beta tester.

Spero che vi possa essere utile.
/* "stars wars" style note  "Che Minigui Extended sia con Voi"
01/09/2017 Pierpaolo Martinello

[ENG]
Due to a forced stop I met in this utility.
I liked it right away, so I wanted to adapt it to Minigui Extended,
not only that, but I've increased the features, fixed bugs and facilitated
implementing new changes to this which is now become a RAD for all respects.
Some of the functions are generated for future developments, but are not
problems, it is up to you to remove them and/or adapt them.

This program is not an IDE and does not pretend to be like a RAD ...

The initial project is a HMG user whose alias is Dragancesu
and that I thank for the idea.
I also thank Grigory Filatov as supervisor and beta tester.

I hope it will be useful.
/* "stars wars" style note "That Minigui Extended be with you"
01/09/2017 Pierpaolo Martinello

[SPA]
Debido a una parada obligada que conoc� en esta utilidad.
Me encant�, as� que quer�a encajar en Minigui Extended,
no s�lo eso, sino he aumentado las caracter�sticas, se han corregido errores
y facilitado implementar nuevos cambios a esto que es ahora
convertido en una RAD para todos los efectos.
Algunas de las funciones se generan para desarrollos futuros, pero no se
problemas, depende de usted para sacarlos y / o ajuste.

Este programa no es un IDE y no pretende ser como un RAD ...

El proyecto inicial es un usuario HMG cuyo alias es Dragancesu
y a quien doy las gracias por la idea.
Tambi�n agradezco a Grigory Filatov como supervisor y beta-testers.

Espero que sea �til.
/* "stars wars" estilo notas "Que Minigui Extended estar contigo"
01/09/2017 Pierpaolo Martinello

[PT]
Devido a uma paragem for�ada conheci este utilit�rio.
Eu gostei, eu queria se encaixam Minigui estendido,
N�o s� isso, mas eu aumentei as caracter�sticas, corrigido bugs e facilitada
implementar novas muda para este que � agora
tornar-se um RAD para todos os efeitos.
Algumas das fun��es s�o geradas para os desenvolvimentos futuros, mas n�o s�o
problemas, � at� voc� para tir�-las e / o fit.

Este programa n�o � uma IDE e n�o pretende ser como um RAD ...

O projeto inicial � um usu�rio HMG cujo apelido � Dragancesu
e a quem agrade�o a ideia.
Agrade�o, tamb�m, Grigory Filatov como supervisor e beta-testers.

Espero que voc� seja �til.
/* "estrelas guerras" estilo notas "Que Minigu�a Extended esteja com voc�"
01/09/2017 Pierpaolo Martinello

History: (Only English)

02/01/2018 Implemented full support for barcode, solved miscellaneous bugs.
           Full support for barcode, checksum for all types, possibilty of saving as image,
           to insert in std easyreport and, if requested, immediate check of selected code.
           Adopted resources from dll, new internal batch for compile the generated sources.

13/12/2017 Add a new routine for choice the print export format (see Scegli Function)
           New implementation of spanish language (Special thanks to Jos� Luis Otermin)
           If you export on pdf format, we encourage to use a portable SumatraPdf to
           print or set your Acrobat Rreader to print in actual dimensions.
           I have changed the way of choosing the export format.
           Fix control Image (not always visible at runtime)
           Fixed saving report after removed some field columns
           Fixed wrong import of rpt.

04/11/2017 New: a click on FieldName obtain a column focus
           New: possibility of column deletion
           New: exportation on WinReport format (not yet finish! but work for basic functions))
           For Windows Report Interpreter (hbprinter driver only)
           New: add command SET GROUPBOLD    // Default .T.
           New: add command SET HGROUPCOLOR  // Default BLUE
           New: add command SET GTGROUPCOLOR // Default BLUE
           New: add support for the main languages

01/11/2017 Move the function Writefile from Quickb.prg to treport.prg,
           because is More fast than Strfile

23/10/2017 Added User Report Editor with autosize for Window and main grid.
           Now is possible to save and import of report definition.
           Added the option to change the order of columns to print.
           The report can be saved as Template or Standard DO REPORT syntax.
           The import check the syntax of report readed.
           The automatic assigning of Picture is only a suggestion for
           the correct printing, but may be require a manually correction.

01/09/2017 First Release
