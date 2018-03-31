#include 'hmg.ch'

Memvar nPage
Memvar aItems
Memvar cPage
Memvar cText
Memvar cLabel
Memvar cCombo

Function Main
Local nWidthWindow  := int(( GetDesktopWidth()  / 2 ))
Local nHeightWindow := int(( GetDesktopHeight() / 2 ))
Local cUser         := "User : "    + getenv("UserName")
Local cPc           := "Station : " + getenv("ComputerName")
Local i

Public nPage        := 0
Public aItems       := {}
Public cPage        := "Page"  + ltrim(str(nPage))
Public cText        := "Text"  + ltrim(str(nPage))
Public cLabel       := "Label" + ltrim(str(nPage))
Public cCombo       := "Combo" + ltrim(str(nPage))

for i=1 to 1000
	aadd(aItems, "$" + ltrim(str(i)))
next

SET NAVIGATION EXTENDED
SET MENUSTYLE EXTENDED
SetMenuBitmapHeight( BmpSize( "delete.bmp" )[ 1 ] )

DEFINE WINDOW Principal                        ;
           AT 0, 0                             ;
           WIDTH nWidthWindow                  ;
           HEIGHT nHeightWindow                ;
           TITLE "Example of using Method AddPage, AddControl and BackColor in TAB" ;
           ICON "pc.ico"                       ;
           ON SIZE  SizeTest()                 ;
           ON INIT AddNewPage()                ;
           ON MOUSECLICK AddNewPage()          ;
           NOMAXIMIZE                          ;
           MAIN                                ;
           BACKCOLOR TEAL

    DEFINE TAB Container_Tab                   ;
           AT 2, 2                             ;
           WIDTH  Principal.Width  - 10        ;
           HEIGHT Principal.Height - 60        ;
           VALUE 1                             ;
           FONT "Arial"                        ;
           SIZE 9                              ;
           ON CHANGE AddNewPage()              ;
           HOTTRACK                            ;
           BACKCOLOR TEAL
    END TAB

    DEFINE STATUSBAR
        STATUSITEM cPC   WIDTH 100 ICON "pc.ico"
        STATUSITEM cUser WIDTH 300 ICON "User.ico"
    END STATUSBAR

    DEFINE CONTEXT MENU
           MENUITEM "Delete Select Page" ACTION DeletePage() NAME delete IMAGE "delete.bmp"
    END MENU

END WINDOW

Principal.Center
Principal.Activate

Return nil

Procedure DeletePage()
Local nDelete

nDelete:= Principal.Container_Tab.Value
cLabel := "Label" + ltrim(str(nDelete))
cText  := "Text"  + ltrim(str(nDelete))
cCombo := "Combo" + ltrim(str(nDelete))

IF nDelete == Principal.Container_Tab.ItemCount - 1 .and. iscontroldefined(&cLabel,Principal)
   Principal.&(cLabel).Release
   Principal.&(cText).Release
   Principal.&(cCombo).Release
   Principal.Container_Tab.DeletePage(nDelete)
   nPage--
   IF nPage == 1
      AddNewPage()  
   ENDIF
ELSE 
   MsgInfo( "No se puede borrar el PAGE '"+Principal.Container_Tab.Caption(nDelete)+"'", "   Info  " )    
ENDIF

Return


Function AddNewPage()

IF nPage == 1
   cPage := 'Page'+ltrim(str(nPage))
   Principal.Container_Tab.AddPage ( nPage, cPage )
   AddControls()
   nPage++
   Principal.Container_Tab.Value := nPage - 1
   Return nil
ENDIF

IF Principal.Container_Tab.Value == nPage
   IF nPage >= 2
      cPage := 'Page'+ltrim(str(nPage))
      Principal.Container_Tab.DeletePage(nPage)
      Principal.Container_Tab.AddPage ( nPage, cPage )
      AddControls()
      nPage++
      Principal.Container_Tab.AddPage ( nPage, 'Add+', 'New.bmp', 'Click over Add+ add new Page' )
      Principal.Container_Tab.Value  := nPage - 1
   ELSE 
      nPage++
      cPage := 'Page'+ltrim(str(nPage))
      Principal.Container_Tab.AddPage ( nPage, cPage )
      AddControls()
      nPage++
      Principal.Container_Tab.AddPage ( nPage, 'Add+', 'New.bmp', 'Click over Add+ add new Page' )
      Principal.Container_Tab.Value  := 1
   ENDIF
ENDIF

Return nil

Function AddControls()

cLabel := "Label" + ltrim(str(nPage))
cText  := "Text"  + ltrim(str(nPage))
cCombo := "Combo" + ltrim(str(nPage))

@ 50 , 10  LABEL &cLabel  PARENT Principal  ;
           VALUE cLabel ;
           TRANSPARENT AUTOSIZE
           
@ 46 , 70  TEXTBOX &cText PARENT Principal  ;
           VALUE cText ;
           MAXLENGTH 10
           
@ 80 , 20 COMBOBOX &cCombo PARENT Principal ;
          ITEMS aItems ;
          VALUE 500+nPage

Principal.Container_Tab.AddControl(cLabel, nPage, 50 , 20 )
Principal.Container_Tab.AddControl(cText , nPage, 46 , 70 )
Principal.Container_Tab.AddControl(cCombo, nPage, 80 , 20 )

Return nil

Procedure SizeTest()

	Principal.Container_Tab.Width := Principal.Width - 10
	Principal.Container_Tab.Height := Principal.Height - 60

Return
