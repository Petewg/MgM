DirTree

Program allows to construct the tree of files for the selected catalog (disk).
It is possible to indicate the template of the switch oned files and to consider archives as catalogs.
In the latter case in construction are included all content of archive without the calculation masks.

By the means of program itself are processed archives ZIP. The archives of other types are revealed 7-Zip.
In this case the program selects one of the possible methods of the call of 7-Zip:
- turning to the installed version
- the version of the arrangement of 7z.exe and 7z.dll in the catalog of program itself
- the presence in catalog of the program of the console version of 7za.exe (is supported a smaller quantity of types of archives)

After the construction of structure it is possible to open the current element:
- for not packed folders and files is executed a command of "Open"
- the packed files are extracted into the system catalog of temporary files and an attempt at the discovery also is carried out.
  The extracted files and catalogs are moved away after closing of viewer.

!!! The main window of DirTree is blocked when the survey of the element of tree.

Deficiencies.

- for the survey is called the program, associated with the type of file; therefore not all files are opened.
- files with attribute "Hidden" for the survey they are not opened (function File(), caused before the discovery for their checking it does not see)