How to use the library

The THaruPdf class tries to provide the same functions of the Tprinter class of
FW so that it can be used in its replacement with the minimum of changes.

Declaration of the printing object

    oPrint: = THaruPdf():New()

optionally we can indicate from the beginning the name of the pdf and the values
of the passwords. The complete parameters are

    oPrint: = THaruPdf():New( cFileName, cPassword, cOwnerPassword, nPermission, lPreview )

cPassword is the key to access the pdf with the limits indicated by
nPermission, cOwnerPassword is to be able to modify it.
nPermission is set by default as HPDF_ENABLE_READ + HPDF_ENABLE_PRINT + HPDF_ENABLE_COPY
The security parameters are completely optional.
lPreview indicates whether, at the end of the generation, the program should launch the visualization of the generated pdf.
For this the library will launch the opening manager that the user has defined in the operating system of
automatic way This behavior can be changed by defining the codeblock :bPreview of the class.

If these values are set when the object is created, when End() is invoked
it will automatically record the pdf. If nothing is indicated when creating the object, it is recorded
manually with the Save method

    oPrint:Save( cFileName ) // -> returns a numeric value

The Save() method returns a numeric value. If everything is fine, return 0, a
value different from 0 indicates some Haru error. See the respective error table in the library itself.

Start and End of page

    oPrint:StartPage()
    oPrint:EndPage()

Use of commands

Optionally, some commands equivalent to those of printing with TPrinter are available, defined
in the include 'HaruPrint.ch'

- Declaration of the object THaruPdf

	PRINT <oPrint> TO HARU [ FILE <cFile> ] ;
          [ <lPreview: PREVIEW> ] ;
          [ USER PASS <cUserpass>  ] ;
          [ OWNER PASS <cOwnerpass>  ] ;
          [ PERMISION  <nPermision>  ] ;

- Start and end of page

PRINTPAGE
...
ENDPAGE

- End of printing

ENDPRINT


Fontes

In THaruPdf :

   oFont1 := oPrint:DefineFont( 'Courier', 8 )

An important detail is what type of font we use, if it is a predefined one, or
a TrueType font.

The predefined fontes (known as Base14) are the lightest in terms
of the size of the generated pdf, because they are not inserted in the pdf when they are already included
in pdf readers like Acrobat Reader, Foxit, etc. They are the following:

    Courier
    Courier-Bold
    Courier-Oblique
    Courier-BoldOblique
    Helvetica
    Helvetica-Bold
    Helvetica-Oblique
    Helvetica-BoldOblique
    Times-Roman
    Times-Bold
    Times-Italic
    Times-BoldItalic
    Symbol
    ZapfDingbats

TrueType fonts must be included in the generated pdf, therefore the fi-
ler <font> .ttf must be available. The name of the sources does not match,
in general, with the name of the file, so you have to include the name of the
file in the declaration of the sources using the function:

    HaruAddFont( cFontName, cTtfFile )

*cFontName* is the name of the source, and *cTtfFile* is the .ttf file that
define
For convenience and frequency of use, the following sources are already predefined,
so it is not necessary to declare them.

    Arial
    Verdana
    Courier New
    Calibri
    Tahoma

Also, for convenience, the HaruAddFont function looks for the file in the directory
current, and if you can not find it, in the Windows source directory. We can
declare an alternative directory to include our own sources with the
function:

    SetHaruFontDir( cDir )

where cDir is the directory where we want to find the sources.

Images

At the moment the library only supports images in PNG and JPG format.
Attention/Achtung/Warning: The tests carried out indicate that using generated pngs
with Paint they produce huge pdfs and they are very slow.
The library has been optimized to load the images in an indexed way, it is
say that when we repeat an image on several pages, the library loads the image
within the pdf once, and use the same image copy each time it is referenced,
for example as background of each page.

How to save the file

It is not necessary to indicate ENDPRINT nor to destroy the sources, that is to say
    ENDPRINT is not necessary
    oFont:End() is not necessary

Put password

The password of the user and / or owner can be indicated at the time of
creation of the print object, or manually assign the DATAs of the class
before calling the Save() or End() method

    DATA nPermission
    DATA cPassword
    DATA cOwnerPassword

How to link

In addition to including *PdfPrinter.lib*, *libhpdf.lib* and *png.lib* are required, which
found in the same project directory as the library, and the libraries
*hbhpdf.lib* and *hbzlib.lib* from Harbor itself.

Limits

The most important limit is the number of pages, which is quite high.
Generating payroll with a background bitmap, pdfs of up to 8000 have been generated
pages. Apparently exceeding that amount of pages errors occur because
the lack of capacity of the internal structures of the pdfs, which requires
internal restructuring of the page that Haru is not able to do.

Errors, things that are missing...

As it is a very early version, it is likely that something does not work as it is
wait or miss some functionality. In order to implement new
functions or correct/modify existing ones, the class is assembled with the master
'protected variations', using as facade an empty intermediate class (THaruPDF),
that inherits all the functionality of the real implementation (THaruPDFBase).
This is to allow us to introduce settings and new functions without having
that modify the original code. If we want to modify something of the class, IN
OUR PROJECT will create a new prg and we will declare the class THaruPDF that
inherit THaruPDFBase, we can copy the prg vate that is already in the project
from the bookstore, and we will add all the new code there. With this we will achieve that
the class does what we want or add some benefit without interfering with the
public library code, used in all projects.

    #include 'hbclass.ch'
    #include 'harupdf.ch'

    #define __NODEBUG__
    #include 'debug.ch'

    // ------------------------------------------------------------------------------
    CLASS THaruPDF FROM THaruPDFBase
       // Intermediate class to provide protected variations
    ENDCLASS


When any new functionality is incorporated into the library, it automatically
will include in our project, without affecting the local part of the additional code that
has been defined in our project.

Carlos Mora
25/02/2017
