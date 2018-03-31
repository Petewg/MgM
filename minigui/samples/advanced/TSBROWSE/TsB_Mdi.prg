/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Adaptation of TsBrowse for HMG 1.2 Experimental
 * (C)2005-2006 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"
#include "tsbrowse.ch"


#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)
#define CLR_NBROWN  RGB( 130, 99, 53)
#define CLR_1 RGB( 190, 215, 190 )
#define CLR_2 RGB( 230, 230, 230 )
#define CLR_3 RGB( 217, 217, 255 )


Static oWnd, aFont[ 5 ], aBrush[ 7 ], aBmp[ 6 ]
STATIC nWinWidth, nWinHeight


Function Main
Local n, Btn_bar, cName
   Local oBmp,  oBar, cTitle, oBtn[ 9 ], aColor[ 2 ], ;
         lNoBlink := .F.

    SET CENTURY ON
    SET DELETED ON
    SET NAVIGATION EXTENDED

    nWinWidth  := GetDesktopWidth() * 0.8
    nWinHeight := GetDesktopHeight() * 0.8

    aBrush[ 1 ] := CLR_NBLUE
    aBrush[ 2 ] := CLR_NBROWN
    aBrush[ 3 ] := CLR_1
    aBrush[ 4 ] := CLR_2
    aBrush[ 5 ] := CLR_3
    aBrush[ 6 ] := CLR_BLACK
    aBrush[ 7 ] := CLR_WHITE

    aBmp[ 1 ] := LoadImage ("Bitmaps\Head.bmp")
    aBmp[ 2 ] := LoadImage ("Bitmaps\Mark.bmp")
    aBmp[ 3 ] := LoadImage ("Bitmaps\Ok.bmp")
    aBmp[ 4 ] := LoadImage ("Bitmaps\Cancel.bmp")
    aBmp[ 5 ] := LoadImage ("Bitmaps\Cake.bmp")
    aBmp[ 6 ] := LoadImage ("Bitmaps\Clipv.bmp" )

   DEFINE FONT Font_1  FONTNAME "Arial" SIZE 12
   DEFINE FONT Font_2  FONTNAME "Wingdings" SIZE 18
   DEFINE FONT Font_3  FONTNAME "MS Sans Serif" SIZE 9
   DEFINE FONT Font_4  FONTNAME "Arial" SIZE 14 BOLD ITALIC
   DEFINE FONT Font_5  FONTNAME "Arial" SIZE 12 UNDERLINE ITALIC

   aFont[ 1 ] := GetFontHandle( "Font_1"  )
   aFont[ 2 ] := GetFontHandle( "Font_2"  )
   aFont[ 3 ] := GetFontHandle( "Font_3"  )
   aFont[ 4 ] := GetFontHandle( "Font_4"  )
   aFont[ 5 ] := GetFontHandle( "Font_5"  )


    DEFINE WINDOW Form_1 ;
        AT 0,0 ;
        WIDTH  nWinWidth HEIGHT  nWinHeight ;
        TITLE 'MiniGUI TsBrowse MDI Demo - Adaptation TsBrowse 7.0' ;
        ICON "Demo.ico" ;
        MAIN MDI ;
        ON INIT OpenTables() ;
        ON RELEASE CloseTables() ;
        FONT "Arial" SIZE 9 ;

    BuildMenu()
    DEFINE SPLITBOX
        DEFINE TOOLBAREX oBar  BUTTONSIZE 55,35 FONT "Arial" SIZE 7

            BUTTON Btn_1  PICTURE "Super16" ;
                CAPTION "Sample 1";
                TOOLTIP "Sample 1" ACTION fWindow( 1 )

            BUTTON Btn_2 PICTURE "Super16"  ;
                CAPTION "Sample 2";
                TOOLTIP "Sample 2" ACTION fWindow( 2 )

            BUTTON Btn_3 PICTURE "Super16" ;
                CAPTION "Sample 3";
                TOOLTIP "Sample 3" ACTION fWindow( 3 )

            BUTTON Btn_4 PICTURE "Super16"  ;
                CAPTION "Sample 4";
                TOOLTIP "Sample 4" ACTION fWindow( 4 )

            BUTTON Btn_5 PICTURE "Super16"  ;
                CAPTION "Sample 5";
                TOOLTIP "Sample 5" ACTION fWindow( 5 )

            BUTTON Btn_6 PICTURE "Super16"  ;
                CAPTION "Sample 6";
                TOOLTIP "Sample 6" ACTION fWindow( 6 )

            BUTTON Btn_7 PICTURE "Super16"  ;
                CAPTION "Sample 7";
                TOOLTIP "Sample 7" ACTION fWindow( 7 )

            BUTTON Btn_8 PICTURE "Super16"  ;
                CAPTION "Sample 8";
                TOOLTIP "Sample 8" ACTION fWindow( 8 )

            BUTTON Btn_9 PICTURE "ExitB16"  ;
                CAPTION "Exit";
                ACTION Form_1.Release ;
                TOOLTIP "Exit"
        END TOOLBAR
     END SPLITBOX



     DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
            STATUSITEM "HMG Power Ready!"
            CLOCK
            DATE
        END STATUSBAR

    END WINDOW

    CENTER WINDOW Form_1

    ACTIVATE WINDOW Form_1

Return Nil

//---------------------------------------------------------------------------------------//

Function BuildMenu()

    DEFINE MAIN MENU
        POPUP "TSBrowse"
            POPUP "Samples on Windows"
                MENUITEM "Sample 1" ACTION fWindow( 1 )
                MENUITEM "Sample 2" ACTION fWindow( 2 )
                MENUITEM "Sample 3" ACTION fWindow( 3 )
                MENUITEM "Sample 4" ACTION fWindow( 4 )
                MENUITEM "Sample 5" ACTION fWindow( 5 )
                MENUITEM "Sample 6" ACTION fWindow( 6 )
                MENUITEM "Sample 7" ACTION fWindow( 7 )
                MENUITEM "Sample 8" ACTION fWindow( 8 )
            END POPUP
            SEPARATOR
            MENUITEM "&Exit" ACTION Form_1.Release
        END POPUP
        POPUP 'Child Windows'
            POPUP '&Tiled'
                ITEM '&Horizontal '    ACTION WinChildTile(.f.)
                ITEM '&Vertical '    ACTION WinChildTile(.t.)
            END POPUP
            ITEM '&Cascade'        ACTION WinChildCascade()
            ITEM 'Arrange &Icons'     ACTION WinChildIcons()
            SEPARATOR
            ITEM 'Close &All'        ACTION WinChildCloseAll()
            ITEM '&Restore All'        ACTION WinChildRestoreAll()
        END POPUP

        POPUP 'Help'
            ITEM 'HMG Version'      ACTION MsgInfo (MiniGuiVersion(), , ,.f.)
            ITEM 'About'            ACTION  MsgInfo (padc("MiniGUI TsBrowse MDI Demo", Len(MiniguiVersion()))+CRLF+ ;
                                "Contributed by Janusz Pora <januszpora@onet.eu>"+CRLF+CRLF+ ;
                                MiniguiVersion(),"A COOL Feature ;)", ,.f.)
        END POPUP
   END MENU

Return Nil

//---------------------------------------------------------------------------------------//

Procedure OpenTables()
   Field First, Last, Married, Age, Salary, State
   RddSetDefault( "DBFNTX" )    // Clipper-Harbour

   USE States ALIAS Sta SHARED NEW
   Index On State To States       // NTX


   USE Employee SHARED NEW
   Index On First+Last To Name    // NTX
   Index On State To State        // NTX
   Set Index To Name, State       // NTX

Return

Procedure CloseTables()
    DbCloseAll()
Return

//---------------------------------------------------------------------------------------//

Function fWindow(nSample)

    Local cWnd, cBrw, cTitle, nBrwWidth, nEle, nBrwHeight, nFrm, n, actpos,;
          nMarried, nSingle, nTotSal, nAgeTot, nOldAge, nOldSal, aStates, ;
          bBlock, aRect, ix, cSelState,lNew:=.T., ChildHandle, ChildName, cTit
    Local Brw_1, Brw_2, Brw_3, Brw_4, Brw_5, Brw_6, Brw_7, Brw_8

    Field First, Last, Married, Age, Salary, State
    DEFAULT nSample:=0

    cWnd    := "Sample_"+LTrim( Str( nSample ) )
    cBrw    := "Brw_"+LTrim( Str( nSample ) )
    cTitle  := "Sample " + LTrim( Str( nSample ) )
    nBrwWidth := nWinWidth-100
    nBrwHeight:= nWinHeight-150

    nFrm := len(_HMG_aFormHandles)
    For n:=1 to nFrm
        if _HMG_aFormType  [n] ==  'Y'
            ChildHandle := _HMG_aFormHandles  [n]
            ChildName   := _HMG_aFormNames  [n]
            ctit :=  _GetWindowProperty(ChildHandle, "PROP_CFILE")
            if !empty(ctit) .and. cTit == cTitle
                _MdiWindowsActivate(ChildHandle)
                lNew := .f.
                exit
            endif
        endif
    Next

   IF  lNew
        Select ("Employee" )

        nMarried := 0
        nSingle  := 0
        nTotSal  := 0
        nAgeTot  := 0
        nOldAge  := 0
        nOldSal  := 0
        aStates  := {}


        DEFINE WINDOW ChildMdi ;
            WIDTH  nBrwWidth HEIGHT  nBrwHeight ;
            TITLE cTitle;
            MDICHILD;
            ON INIT ResizeEdit();
            ON SIZE ResizeEdit();
            ON MAXIMIZE ResizeEdit();
            ON MINIMIZE ResizeEdit();
            ON MOUSECLICK SetEditFocus()


          actpos := _GetClientRect(GetActiveMdiHandle())
         nBrwWidth := actpos[3]-actpos[1]
         nBrwHeight := actpos[4]-actpos[2]

            DO Case
            Case nSample = 1


                DEFINE TBROWSE Brw_1 AT 0, 0 ALIAS "Employee" ;
                    COLORS {CLR_BLACK, CLR_NBLUE} ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    MESSAGE "Cell height idependent of the font size using oBrw:nHeightCell. " +;
                            "Also try multi-select feature by double clicking."

                    Brw_1:LoadFields( .F. )

                    Brw_1:SetColor( { 1, 3, 5, 6, 13, 15 }, ;
                              { CLR_BLACK, CLR_WHITE, CLR_BLACK, ;
                                { CLR_WHITE, CLR_BLACK }, ; // degraded cursor background color
                                CLR_WHITE, CLR_BLACK } )  // text colors
                    Brw_1:SetColor( { 2, 4, 14 }, ;
                          { { CLR_WHITE, CLR_NBLUE }, ;  // degraded cells background color
                            { CLR_WHITE, CLR_BLACK }, ;  // degraded headers backgroud color
                            { CLR_HRED, CLR_BLACK } } )  // degraded order column background color

                    Brw_1:nHeightCell += 6
                    Brw_1:nHeightHead += 4

      // activating Multi Selection
      Brw_1:SetSelectMode( .T., { | oBrw, nI, lSel | ;
                               Tone( If( lSel, 500, 100 ) ) }, ;
                               aBmp[ 2 ], 1, DT_RIGHT ) // New V.7.0 BitMap marker


      // vertical header in columns 8 y 9
                    Brw_1:SetAlign( 8, 2, DT_VERT )
                    Brw_1:SetAlign( 9, 2, DT_VERT )

      // changing width of columns 8 y 9
                    Brw_1:SetColSize( 8, 25)
                    Brw_1:SetColSize( 9, 25)

      // activating incremental search with two tags in columns 1 and 5
                    Brw_1:aColumns[ 1 ]:cOrder := "Name"
                    Brw_1:aColumns[ 5 ]:cOrder := "State"

      // degraded colors look better without horizontal lines
                    Brw_1:nLineStyle := LINES_VERT
      // this is very important when working with the same database
                    Brw_1:lNoResetPos := .F.

                END TBROWSE

            Case nSample = 2

                DbSelectArea( "Sta" )
                DbEval( { || AAdd(aStates, State ) } )
                DbSelectArea( "Employee" )


                DEFINE TBROWSE Brw_2 AT 0,0 CELLED ALIAS "Employee" ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    MESSAGE "Auto-Append pressing down arrow at last row using" + ;
                            "::SetAppendMode( .T. )"


                    Brw_2:LoadFields( .T. )
                    Brw_2:nFreeze := 1
                    Brw_2:SetAppendMode( .T. )

     // flagging columns that affect index key to issue UpStable() when fields change
                    Brw_2:SetIndexCols( 1, 2 )

                    Brw_2:Look3d( .T.,,, .F. )  // ( lOnOff, nColumn, nLevel, lPhantomGrid )

                    Brw_2:SetColor( { 1, 2, 3, 4, 5, 6, 15 }, ;
                         { CLR_WHITE, CLR_BLACK, CLR_WHITE, aBrush[ 5 ], ;
                           CLR_BLACK, RGB( 236, 160, 19 ), CLR_BLACK } )

     // changing colors to column 2
                    Brw_2:SetColor( { 1, 2 }, { CLR_BLACK, CLR_WHITE }, 2 )

//     Brw_2:InsColumn( 8, OClone( Brw_2:aColumns[ 8 ] ) )  // Not implement yet

     // Windings font for happy/unhappy face
                    Brw_2:aColumns[ 9 ]:bData := { | x | If( Employee->Married, "L", "J" ) }

     // avoid edition of column 9
                    Brw_2:aColumns[ 9 ]:lEdit := .F.

     // we don't want empty names
                    Brw_2:aColumns[ 1 ]:bValid := { | uVar | ! Empty( uVar ) }
                    Brw_2:aColumns[ 2 ]:bValid := { | uVar | ! Empty( uVar ) }

     // Changing alignment to cells of columns 8 and 9
                    Brw_2:SetAlign( 8, 1, DT_CENTER )   // ( nCol, nLevel, nAlign )
                    Brw_2:SetAlign( 9, 1, DT_CENTER )   // nLevel 1=Cell, 2=Header, 3=Footer

     // now, setting a font to a single column
                    Brw_2:ChangeFont( aFont[ 2 ], 9, 1 )   // 9 = column  1 = Nivel Celdas

     // next, setting colors at cell level for columns 9, 10 and 11
                    Brw_2:SetColor( { 1, 2, 5, 6 }, ;
                         { CLR_BLACK, { || If( Employee->Married, CLR_HRED, CLR_HGREEN ) }, ;
                           CLR_WHITE, CLR_BLACK }, 9 )

                    Brw_2:SetColor( { 1, 2, 5, 6 }, ;
                         { CLR_BLACK, { || If( Employee->Age > 60, CLR_HRED, CLR_HGREEN ) }, ;
                           CLR_WHITE, CLR_BLACK }, 10 )

                    Brw_2:SetColor( { 1, 2, 5, 6 }, ;
                         { { || If( Employee->Salary < 10001, CLR_WHITE, CLR_BLACK ) } , ;
                           { || If( Employee->Salary > 50000,CLR_HGREEN, ;
                                If( Employee->Salary > 10000,CLR_HRED, ;
                                    CLR_RED ) ) }, ;
                           CLR_WHITE, CLR_BLACK }, 11 )

     // setting bData and related table for showing the combobox use at column 4
                    Brw_2:SetData( 5, ComboWBlock( Brw_2, "State", 5 , aStates ) )

     // changing the width of columns 5 and 7 to fit the ComboBox and the BtnGet
                    Brw_2:SetColSize( 5, 130 )  // SetColSize( nColumn, nWidth )
                    Brw_2:SetColSize( 7, 85 )

     // now changing the width of columns 8, 9 and 10 to fit new font
                    Brw_2:SetColSize( { 8, 9, 10 }, { 55, 55, 40 } )  // ( aColumn, aWidth )

     // setting font aFont[ 4 ] to every header
                    Brw_2:ChangeFont( aFont[ 4 ],,2 )  // ( aFont[ 1 ], nCol, nLevel )

     // activating BtnGet to column  7    - not implement yet
//                  Brw_2:SetBtnGet( 7, "Calen16", { | oGet, dVar | aRect := GetCoors( oGet:hWnd ), ;
//                      dVar := FwCalendar( oGet:Value(), aRect[ 1 ], aRect[ 2 ], oGet:oWnd ),;
//                      oGet:cText( dVar ), oGet:Refresh(), oGet:KeyDown( VK_RETURN, 0 ) }, 16 )

     // this is very important when working with the same database
                    Brw_2:lNoResetPos := .F.

                END TBROWSE

            Case nSample = 3

                DEFINE TBROWSE Brw_3 AT 0,0 ALIAS "Employee" ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    MESSAGE 'Double Click on headers "Name" or "State" to stablish ' + ;
                            'the active index for incremental search.'

                    Brw_3:LoadFields()

                    Brw_3:SetColor( { 1, 3, 5, 13 }, { CLR_BLACK, CLR_BLACK, CLR_BLACK, ;
                                             CLR_BLACK } )

      // new degraded colors and brushed background
                    Brw_3:SetColor( { 2, 4, 6, 12, 14 }, { aBrush[ 1 ], ;  // brushed cells
                          { CLR_WHITE, CLR_NBROWN }, ;  // degraded headers
                          { CLR_WHITE, CLR_NBROWN }, ;  // degraded cursor
                          { CLR_HRED, CLR_BLACK }, ;    // degraded selected cells
                          { CLR_HGREEN, CLR_BLACK } } ) // degraded active index header

                    Brw_3:nHeightCell += 6
                    Brw_3:nHeightHead += 4

      // activating Multi Selection
                  Brw_3:SetSelectMode( .T., { | oBrw, nI, lSel | ;
                               MsgInfo( "Record " + Ltrim( Str( nI ) ) + ;
                                        If( lSel, " Selected", " Unselected" ) ) } )

      // brushing browse background
                    Brw_3:hBrush := aBrush[ 1 ]

      // vertical header in columns 8 y 9
                    Brw_3:SetAlign( 8, 2, DT_VERT )
                    Brw_3:SetAlign( 9, 2, DT_VERT )

      // changing width of columns 8 y 9
                    Brw_3:SetColSize( 8, 25)
                    Brw_3:SetColSize( 9, 25)

      // activating incremental search with two tags in columns 1 and 5
                    Brw_3:aColumns[ 1 ]:cOrder := "Name"
                    Brw_3:aColumns[ 5 ]:cOrder := "State"

      // 3D text raised in all levels and all columns
                    Brw_3:Set3DText( .T., .T. )
     // this is very important when working with the same database
                    Brw_3:lNoResetPos := .F.

                END TBROWSE

            Case nSample = 4

                DbEval( { || nAgeTot += Employee->Age } )
                DbGotop()

                DEFINE TBROWSE Brw_4 AT 0,0 GRID ALIAS "Employee" ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    COLORS {CLR_BLACK, CLR_PINK} ;
                    MESSAGE "Fonts, colors and bitmaps different for cells, headers and footers"

                    ADD COLUMN TO Brw_4;
                        HEADER "F i r s t" ;
                        SIZE 130 ;
                        DATA FieldWBlock( "First", Select() ) ;
                        VALID { | uVar | ! Empty( uVar ) } ;  // don't want empty names
                        ALIGN DT_LEFT, nMakeLong( DT_CENTER, DT_CENTER ) ; // V.7.0 alignment changes for bitmaps
                        COLORS CLR_BLACK, { CLR_PINK, CLR_BLACK } ; // degraded background color
                        3DLOOK FALSE, TRUE, TRUE ; // 3D look only for header and footer
                        EDITABLE MOVE DT_MOVE_RIGHT

      // new V.7.0 merging bitmaps and text in cells, headers and footers
                    Brw_4:aColumns[ 1 ]:uBmpHead := aBmp[ 1 ]

                    ADD COLUMN TO Brw_4;
                        HEADER "Last" + CRLF + "Name" ;  // multi-line feature on headers
                        DATA FieldWblock( "Last", Select() ) ;
                        VALID { | uVar | ! Empty( uVar ) } ;  // don't want empty names
                        COLORS CLR_BLACK, { CLR_PINK, CLR_BLACK } ; // degraded background color
                        3DLOOK FALSE, TRUE, TRUE ; // 3D look only for header and footer
                        ALIGN DT_LEFT, DT_LEFT, DT_RIGHT ;
                        FOOTER "Average->" ;
                        EDITABLE MOVE DT_MOVE_RIGHT

      // new V.7.0 showing a cake in aniversaries
                    Brw_4:aColumns[ 2 ]:uBmpCell := ;
                        {||If(Month(Employee->HireDate)==Month(Date()).and.;
                        Day(Employee->HireDate)==Day(Date()),aBmp[5],Nil)}

      // next column shows the Vertical Header and Check Box editing control
                    ADD COLUMN TO Brw_4;
                        HEADER "Married" ;
                        SIZE 25 PIXELS ;
                        DATA FieldWblock( "Married", Select("Employee") ) ;
                        COLORS CLR_BLACK,CLR_NBLUE ;
                        3DLOOK TRUE CHECKBOX ;          // Editing with Check Box
                        ALIGN DT_CENTER, DT_VERT ;      // Cells centered, Header Vertical
                        EDITABLE MOVE DT_MOVE_RIGHT

                    ADD COLUMN TO Brw_4 ;
                        HEADER "Age" ;
                        SIZE 37 PIXELS ;
                        3DLOOK TRUE;
                        DATA FieldWBlock( "Age", Select("Employee") ) ;
                        COLORS CLR_BLACK, CLR_PINK ;
                        FOOTER { || Ltrim( Str( Round( nAgeTot / Max(Brw_4:nLen+1,1), 0 ) ) ) + CRLF + ;
                            "Years" } ;  // multi-line feature on footers
                        ALIGN DT_CENTER, DT_VERT ;  // Cells centered, Header Vertical
                        VALID {|uVar| If( Empty( uVar ), ( Brw_4:PostMsg( WM_KEYDOWN, VK_RETURN ), ;
                            .F. ), .T. ) } ;
                        EDITABLE MOVE DT_MOVE_RIGHT

      // New TSBrowse V.7.0 External Data Edition
                    Brw_4:aColumns[ 4 ]:bExtEdit := { |nAge,oBrw| fExternal( nAge, oBrw ) }
                    Brw_4:aColumns[ 4 ]:bValid := {|nAge| ! Empty( nAge ) }

                    ADD COLUMN TO Brw_4 ;
                        HEADER "Salary" ;
                        SIZE 80 PIXELS ;
                        3DLOOK TRUE;
                        DATA FieldWBlock( "Salary", Select("Employee") ) ;
                        COLORS {||If(Employee->Salary>100000,CLR_WHITE,CLR_BLACK)}, CLR_NBLUE ;
                        ALIGN DT_RIGHT ;  // defaults right alignment at 3 levels
                        EDITABLE MOVE DT_MOVE_NEXT

      // New V.7.0 fonts dinamically asigned through a code block
                    bBlock := {||If(Employee->Salary>100000, aFont[ 5 ], aFont[ 1 ] ) }
                    Brw_4:ChangeFont( bBlock, 5, 1 )

                    ADD COLUMN TO Brw_4 ;
                        HEADER "Hire" + CRLF + "Date" ;   // multi-line feature on headers
                        SIZE 85 PIXELS ;
                        3DLOOK TRUE;
                        DATA FieldWBlock( "Hiredate", Select("Employee") ) ;
                        ALIGN DT_LEFT, DT_CENTER, DT_CENTER ;
                        COLORS CLR_BLACK,CLR_PINK ;
                        EDITABLE MOVE DT_MOVE_NEXT

                    ADD COLUMN TO Brw_4 ;
                        HEADER "Address" ;
                        SIZE 270 PIXELS ;
                        3DLOOK TRUE ;
                        ALIGN DT_LEFT, nMakeLong( DT_CENTER, 3 ) ; // bitmap aligned to the left of centered text
                        DATA { || Brw_4:Proper( Employee->Street ) + CRLF + ;
                            Trim( Employee->Zip ) + Space( 1 ) + ;
                            Brw_4:Proper( Trim( Employee->City ) ) + ", " + ;
                            Employee->State } ;  // multi-line feature on cells
                        COLORS CLR_BLACK,CLR_PINK


      // new V.7.0 merging bitmaps and text in cells, headers and footers
                    Brw_4:aColumns[ 7 ]:uBmpHead := aBmp[ 6 ]


                    Brw_4:lNoHScroll := .T.
                    Brw_4:nHeightCell += 2
                    Brw_4:nHeightHead += 3

      // setting font to column 2 at all levels (Nil)
                    Brw_4:ChangeFont( aFont[ 4 ], 2, Nil )  // (aFont[ 1 ], nColumn, nLevel)

                    Brw_4:SetColor({ 5, 6 },{ CLR_WHITE, CLR_BLACK } ) // cursor background
                    Brw_4:SetColor({ 5 },{ CLR_RED }, 2 )  // cursor background column 2
                    Brw_4:aColumns[ 2 ]:cMsg := "A different font for each column."

      // flagging columns that affect index key to issue UpStable() when fields change
                    Brw_4:SetIndexCols( 1, 2 )

      // activating BtnGet to column 5
           //       Brw_4:SetBtnGet( 6, "Date", { | oGet, dVar | aRect := {0,0,0,0} , ;
           //             GetWindowRect(oGet:hWnd,aRect),;
           //           oGet:cText( dVar ), oGet:Refresh(), oGet:KeyDown( VK_RETURN, 0 ) }, 16 )

//                  Brw_4:SetBtnGet( 6, "Calen16", { | oGet, dVar | aRect := GetCoors( oGet:hWnd ), ;
//                          dVar := FwCalendar( oGet:Value(), aRect[ 1 ], aRect[ 2 ], oGet:oWnd ),;
//                          oGet:cText( dVar ), oGet:Refresh(), oGet:KeyDown( VK_RETURN, 0 ) }, 16 )

      // managing var value for footing of column 3
      // and showing the use of codeblocks bPrevEdit and bPostEdit
                    Brw_4:aColumns[ 4 ]:bPrevEdit := { | uVal | If( PCount() > 0, ;
                                               nOldAge := uVal, .T. ) }
                    Brw_4:aColumns[ 4 ]:bPostEdit := ;
                        { | uVal | nAgeTot += ( uVal - nOldAge ), ;
                           If( Brw_4:lChanged, Brw_4:DrawFooters(), ) }

      // 3D text bas-relief in all headers
                    Brw_4:Set3DText( .T., .F.,, 2 )

      // 3D text raised in cells of column 2
                    Brw_4:Set3DText( .T., .T., 2, 1 )

      // lines to show with memo fields or cell data containing Chr( 13 )
                    Brw_4:nMemoHV := 2
      // this is very important when working with the same database
                    Brw_4:lNoResetPos := .F.

                END TBROWSE

            Case nSample = 5

                DEFINE TBROWSE Brw_5 AT 0, 0 GRID ALIAS "Employee" ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    COLORS {CLR_BLACK, CLR_PINK} ;
                    MESSAGE "oBrw:lNoHScroll, eliminates horizontal scroll bar."

                    Brw_5:LoadFields( .T. )

      // we don't want any cursor
                    Brw_5:lNoLiteBar := .T.

      // we don't want horizontal scroll bar
                    Brw_5:lNoHScroll := .T.

      // neither grid lines
                    Brw_5:nLineStyle := LINES_NONE

      // setting font aFont[ 1 ] to every header
                    Brw_5:ChangeFont( aFont[ 1 ],, 2 )  // ChangeFont( aFont[ 1 ], nColumn, nLevel )
                                         // nLevel 1 = Cells 2= Headers  3 = Footers

      // brushing cells background
                    Brw_5:SetColor( { 2, 4 }, { aBrush[ 7 ], aBrush[ 3 ] } )

      // brushing browse background
                    Brw_5:hBrush := aBrush[ 7 ]

                    Brw_5:nHeightCell := 20
      // this is very important when working with the same database
                    Brw_5:lNoResetPos := .F.

                END TBROWSE

            Case nSample = 6

                DbSelectArea( "Sta" )
                DbEval( { || AAdd(aStates, State ) } )
                DbSelectArea( "Employee" )

                DEFINE TBROWSE Brw_6 AT 0,0 GRID ALIAS "Employee" ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    COLORS {CLR_BLACK, CLR_PINK} ;
                    MESSAGE "oBrw:LoadFields(), creates columns for every field in the active DB."


                    Brw_6:LoadFields( .T. )
                    Brw_6:nLineStyle := LINES_DOTTED
                    Brw_6:nHeightCell += 6
                    Brw_6:nHeightHead += 4

      // flagging columns that affect index key to issue UpStable() when fields change
                    Brw_6:SetIndexCols( 1, 2 )
                    Brw_6:Look3d( .T.,,, .F. )  // ( lOnOff, nColumn, nLevel, lPhantomGrid )

                    Brw_6:SetColor( { 2, 3, 4, 5, 6, 15 }, ;
                          { { || Brw_6:BiClr( aBrush[ 2 ], aBrush[ 1 ] ) }, ; // brushed cells using BiClr method
                           CLR_BLACK, aBrush[ 6 ], ; // brushed headers
                           CLR_WHITE, { CLR_WHITE, CLR_BLACK }, ; // degraded cursor
                           CLR_GRAY } )  // grid lines color

      // activating continuous editing mode
                  Brw_6:lAutoEdit := .T.    // don't work propertly //JP

      // interchanging positions between columns 4 and 5
//                  Brw_6:Exchange( 4, 5 )    // don't work propertly //JP

      // changing the width of columns 4 and 7 to fit the ComboBox and the BtnGet
                    Brw_6:SetColSize( 4, 130 )  // ( nColumn, nWidth )
                    Brw_6:SetColSize( 7, 80 )

      // setting bData and related table for showing the combobox use at column 4
                    Brw_6:SetData( 4, ComboWBlock( Brw_6, "State", 4, aStates ) )


      // activating BtnGet to column  7   - not impement yet
//                  Brw_6:SetBtnGet( 7, "Calen16", { | oGet, dVar | aRect := GetCoors( oGet:hWnd ), ;
//                      dVar := FwCalendar( oGet:Value(), aRect[ 1 ], aRect[ 2 ], oGet:oWnd ),;
//                          oGet:cText( dVar ), oGet:Refresh(), oGet:KeyDown( VK_RETURN, 0 ) }, 16 )

                    Brw_6:nLineStyle := LINES_VERT

      // 3D text raised in all headers, special colors for 3D effect
                    Brw_6:Set3DText( .T., .T.,, 2, CLR_YELLOW, CLR_RED )

      // all headers centered
                    Brw_6:SetAlign( , 2, DT_CENTER )

      // vertical header in column 9
                    Brw_6:SetAlign( 9, 2, DT_VERT )

      // adjust the header height
                    Brw_6:nHeightHead := 45
      // this is very important when working with the same database
                    Brw_6:lNoResetPos := .F.

                END TBROWSE

            Case nSample = 7

                DbEval( { || If( Employee->Married, ++nMarried, ++nSingle ), nTotSal += Employee->Salary } )
                DbGotop()

                DEFINE TBROWSE Brw_7 AT 0,0 CELLED ALIAS "Employee" ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    COLORS {CLR_BLACK, CLR_PINK} ;
                    MESSAGE "oBrw:bPrevEdit and oBrw:bPostEdit, can control the footer's value."


                    ADD COLUMN TO Brw_7 ;
                        HEADER "Index" ;
                        DATA   Brw_7:nLogicPos ;
                        SIZE 40 PIXELS ;
                        FOOTER LTrim( Str( Brw_7:nLen ) ) ;
                        3DLOOK TRUE,TRUE,FALSE ;  // cels, header, footer
                        ALIGN DT_CENTER,DT_CENTER,DT_CENTER ;   // cells, header, footer
                        COLORS CLR_BLACK, CLR_HGRAY

      // building columns for every field making each editable (.T.)
                    Brw_7:LoadFields( .T. )

      // new V.7.0 feature text and bitmaps in cells, headers and footers
                    Brw_7:aColumns[ 3 ]:uBmpCell := {||If(Employee->Age>65,aBmp[3],aBmp[4])}
                    Brw_7:aColumns[ 3 ]:nAlign := nMakeLong( DT_LEFT, DT_RIGHT )

                    Brw_7:SetColor( { 9, 10 }, { CLR_WHITE, CLR_GRAY } )  // footers
                    Brw_7:SetColor( { 5, 6, 4, 15 }, { CLR_BLACK, -2, ;   // new rectangled cursor
                                          aBrush[ 2 ], ; // brushed headers background
                                          CLR_BLACK } )  // grid lines

                    Brw_7:SetColor( { CLR_EDITF, CLR_EDITB }, { CLR_BLACK, CLR_HGRAY } )  // Edicion

      // activating footers
                    Brw_7:lFooting := .T.

      // freezing up to column 2
                    Brw_7:nFreeze := 2

      // blocking frozen columns
                    Brw_7:lLockFreeze := .T.

      // avoid edition of columns 2 and 3
                    Brw_7:aColumns[ 2 ]:lEdit := .F.
                    Brw_7:aColumns[ 3 ]:lEdit := .F.

      // changing colors to a single cell
                    Brw_7:SetColor( { 1, 2, 5 }, { CLR_WHITE, { || If( Employee->Married, ;
                           CLR_HRED, CLR_NBLUE ) }, CLR_BLACK }, 9 )
                    Brw_7:SetColor( { 1, 2, 5 }, { CLR_BLACK, ;
                          { || If( Employee->Age >= 60, ;
                           CLR_HRED, CLR_HGREEN ) }, CLR_WHITE }, 10 )
                    Brw_7:SetColor( { 1, 2, 5 }, { { || If( Employee->Salary < 10001, CLR_WHITE, CLR_BLACK ) } , ;
                                     { || If( Employee->Salary > 50000,CLR_HGREEN, ;
                                         If( Employee->Salary > 10000,CLR_HRED, ;
                                             CLR_RED ) ) }, CLR_BLACK }, 11 )

      // changing background color of cells of column 12
                    Brw_7:SetColor( { 2 }, { { CLR_YELLOW, CLR_BLACK } }, 12 ) // degraded color

                    Brw_7:SetColor( { 9, 10 }, { CLR_BLACK, aBrush[ 2 ] } )  // brushed Footers background

      // setting footers to columns 2, 8, 9, 11 y 12 using multi-line feature
                    Brw_7:aColumns[ 2 ]:cFooting := "<-Total" + CRLF + "   Records"
                    Brw_7:aColumns[ 8 ]:cFooting := "Married->" + CRLF + "Single->"
                    Brw_7:Acolumns[ 9 ]:cFooting := { || LTrim( Str( nMarried ) ) + " T" + CRLF + ;
                                               LTrim( Str( nSingle ) ) + " F"}
                    Brw_7:Acolumns[ 11 ]:cFooting := { || LTrim( Transform( nTotSal, ;
                                                "$##,###,###" ) ) }
                    Brw_7:Acolumns[ 12 ]:cFooting := "<--Look at the font size."

      // changing footer font of column 11
                    Brw_7:ChangeFont( aFont[ 3 ], 11, 3 )  // 3 = footer

      // centering text of column 9, all levels
                    Brw_7:SetAlign( 9, , DT_CENTER )  // SetAlign( nColumn, nLevel, nAlign )

      // calculating vars value for footings
      // and showing the use of codeblocks bPrevEdit and bPostEdit
                    Brw_7:aColumns[ 9 ]:bPostEdit := ;
                        { | uVal | If( Brw_7:lChanged, ;
                           ( If( uVal, ( --nSingle, ++nMarried ), ;
                                     ( ++nSingle, --nMarried ) ), ;
                                       Brw_7:DrawFooters() ), ) }

                    Brw_7:aColumns[ 11 ]:bPrevEdit := { | uVal | If( PCount() > 0, ;
                                               nOldSal := uVal, .T. ) }
                    Brw_7:aColumns[ 11 ]:bPostEdit := ;
                        { | uVal | nTotSal += ( uVal - nOldSal ), ;
                           If( Brw_7:lChanged, Brw_7:DrawFooters(), ) }

      // changing header colors of columns from 9 to 11
                    For nEle := 9 TO 11
                        Brw_7:SetColor( { 3, 4 }, { CLR_WHITE, CLR_GRAY }, nEle )
                    Next

      // increasing cells height
                    Brw_7:nHeightCell += 3

      // changing headings to columns 3 and 8 using multi-line
                    Brw_7:aColumns[ 3 ]:cHeading := "Last" + CRLF + "Name"
                    Brw_7:aColumns[ 8 ]:cHeading := "Hire" + CRLF + "Date"

/*
      // another fancy use of BtnGet (Combo Browse)
                    Brw_7:SetBtnGet( 6, "Help16", { | oGet, cVar | ;
                        aRect := GetCoors( oGet:hWnd ), cVar := oGet:Value(), ;
                        cVar := ComboBrowse( cVar, aRect[ 1 ], aRect[ 2 ], oGet:oWnd ), ;
                        oGet:cText( cVar ), oGet:Refresh(), oGet:KeyDown( VK_RETURN, 0 ) }, 16 )
*/
      // editing message for column 6
                    Brw_7:aColumns[ 6 ]:cMsg := "Press F2 or Click button to see the list"

      // lines to skip with mouse wheel action
                    Brw_7:nWheelLines := 3

      // New TSBrowse V.7.0 bCustomEdit shows the list only if the code typed is not valid
                    Brw_7:aColumns[ 6 ]:bCustomEdit := ;
                              {|cSta,oGet| ix:= (oGet:Atx), aRect:= {0,0,0,0},GetWindowRect( _HMG_aControlHandles [ix],aRect), ;
                               ComboBrowse(cSta,aRect[ 2 ],aRect[ 1 ],oGet,.T.) }

/*
                    Brw_7:aColumns[ 6 ]:bCustomEdit := ;
                               {|cSta,oGet| aRect:= {0,0,0,0},GetWindowRect( oGet:hWnd,aRect), ;
                               ComboBrowse(cSta,aRect[ 2 ],aRect[ 1 ],oGet,.T.) }
*/
                    Brw_7:aColumns[ 6 ]:bValid := {|cSta| ! Empty( cSta ) }

      // this is very important when working with the same database
                    Brw_7:lNoResetPos := .F.

                 END TBROWSE

            Case nSample = 8

            // let's suppose the folowing index:
                Index on State+Last To StName
                Index on Last To Last
		Set Index To StName, Last

            // variable to stablish the filter:
                cSelState := "NY"

                DEFINE TBROWSE Brw_8 AT 0, 0 ALIAS "Employee" ;
;//                    SELECTFILTER "State+Last" FOR cSelState ;
                    WIDTH nBrwWidth HEIGHT nBrwHeight  ;
                    MESSAGE "Incremental search uses a instance variable ::cPrefix to be used with " +;
                            "compound indexes, specially usefull with filtered databases "

                    Brw_8:LoadFields( .F. , { "First","Last","State","City","Street" })


                    Brw_8:SetColor( { 1, 3, 5, 6, 13, 15 }, ;
                              { CLR_BLACK, CLR_WHITE, CLR_BLACK, ;
                                { CLR_WHITE, CLR_BLACK }, ; // degraded cursor background color
                                CLR_WHITE, CLR_BLACK } )  // text colors
                    Brw_8:SetColor( { 2, 4, 14 }, ;
                          { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
                            { CLR_WHITE, CLR_BLACK }, ;  // degraded headers backgroud color
                            { CLR_HGREEN, CLR_BLACK } } )  // degraded order column background color

                    Brw_8:nHeightCell += 6
                    Brw_8:nHeightHead += 4

                // Alternative method for index based filter:
                // setting the index based filter:
//                    Brw_8:SetFilter( "State+Last", cSelState )

                // SetOrder method new syntax: oBrw:SetOrder( nColumn, cTag, cPrefix )
                    Brw_8:SetOrder( 1, "StName", "NY" )

                // you can also directly assign the cPrefix value:
                    Brw_8:cPrefix := "NY"

                // activating incremental search in columns 2
                    Brw_8:aColumns[ 2 ]:cOrder := "Last"
                    Brw_8:aColumns[ 2 ]:cMsg := "Click to activation incremental search in columns 2 "

                // degraded colors look better without horizontal lines
                    Brw_8:nLineStyle := LINES_VERT

                // this is very important when working with the same database
                    Brw_8:lNoResetPos := .F.

                END TBROWSE

            EndCase

   // this is very important when working with the same database
//          oBrw[ nSample ]:lNoResetPos := .F.


        END WINDOW

//    ResizeEdit(cBrw)


    endif
/*
    RELEASE FONT Font_1
     RELEASE FONT Font_2
     RELEASE FONT Font_3
     RELEASE FONT Font_4
     RELEASE FONT Font_5
*/

Return Nil



Function ResizeChildEdit(ChildName)
   Local hwndCln, cBrw, actpos:={0,0,0,0}
   Local i, w, h, k

   i := aScan ( _HMG_aFormNames , ChildName)
   if i > 0
      hwndCln := _HMG_aFormHandles  [i]
      k := aScan ( _HMG_aControlParenthandles , hwndCln)
      IF k > 0
         cBrw :=  _HMG_aControlNames  [k]
         actpos := _GetClientRect(hwndCln)
         w := actpos[3]-actpos[1]
         h := actpos[4]-actpos[2]
         IF w !=0 .and. h != 0
            _SetControlHeight( cBrw, ChildName, h)
            _SetControlWidth( cBrw, ChildName,w)
         ENDIF
      endif
   endif

Return NIL

Procedure ResizeAllChildEdit()
    Local nfrm, ChildName, n

    nFrm := len(_HMG_aFormHandles)
    For n:=1 to nFrm
        if _HMG_aFormType [n] == 'Y'
            ChildName := _HMG_aFormNames  [n]
            ResizeChildEdit(ChildName)
        endif
    Next

Return


Function ResizeEdit()
    Local hwndCln, i, ChildName

    hwndCln :=GetActiveMdiHandle()
    i := aScan ( _HMG_aFormHandles , hwndCln )
    if i > 0
       ChildName := _HMG_aFormNames  [i]
       ResizeChildEdit(ChildName)
    endif

Return Nil

Procedure SetEditFocus()
   Local ChildHandle, ChildName, cBrw
   Local i,k

   ChildHandle := GetActiveMdiHandle()
   i := aScan ( _HMG_aFormHandles , ChildHandle )
   if i > 0
      ChildName := _HMG_aFormNames [i]
      k := aScan ( _HMG_aControlParenthandles ,ChildHandle)
      IF k > 0
         cBrw :=  _HMG_aControlNames  [k]
        _SetFocus (  cBrw, ChildName)
      endif
   endif
Return


Function fExternal( nAge, oBrw )

   Local oDlg, oFont, oSay, oGet, ;
         nNewAge := Space( 2 ), ;
         lOk     := .F.,;
         cClientMdi

         cClientMdi := _GetWindowProperty ( GetActiveMdiHandle(), "PROP_FORMNAME" )


   DEFINE FONT Font_7 FONTNAME "Arial" SIZE 9


   DEFINE DIALOG Dlg_1 OF &cClientMdi  AT 20, 20 WIDTH 300 HEIGHT 200 FONT "Font_7" ;
        CAPTION "TSBrowse External Data Edition Sample" MODAL;
        DIALOGPROC  nNewAge := DialogFun(@lOk, @nNewAge, oBrw) ;
        ON INIT SetInitItem()

   @ 10, 10 LABEL Lb1 VALUE "Employee: " + AllTrim( EMPLOYEE->FIRST ) + ;
                Space( 1 ) + AllTrim( EMPLOYEE->LAST ) WIDTH 280 ID 100

   @ 50, 10 LABEL Lb2 VALUE "Old Age:" WIDTH 90 ID 101


   @ 90, 10 LABEL Lb3 VALUE "New Age:" WIDTH 90 ID 103
   @ 90, 100 TEXTBOX tbox_2 VALUE nNewAge HEIGHT 24 WIDTH 50   ID 104 //INPUTMASK "99"

   @ 50, 100 TEXTBOX tbox_1 VALUE str(nAge,2) HEIGHT 24 WIDTH 50   READONLY NUMERIC ID 102

   @ 130, 10 BUTTON Btn1 ID 105 CAPTION "&Accept"  WIDTH 60 HEIGHT 24 ;
            DEFAULT

   @ 130, 80 BUTTON Btn2 ID 106 CAPTION "&Cancel" WIDTH 60 HEIGHT 24
   @ 130, 150 BUTTON Btn3 ID 107 CAPTION "&Exit" WIDTH 60 HEIGHT 24

END DIALOG

RELEASE FONT Font_7

Return If( lOk, Val( nNewAge ), nAge )

Static Function DialogFun(lOk, nNewAge,oBrw)
Local   ret := 0, cValue
    if DLG_ID != Nil
        do case
        case DLG_ID == 104 .and. DLG_NOT ==1024
            cValue := GetEditText (DLG_HWND, 104 )
            if !empty(cValue)
                EnableDialogItem (DLG_HWND, 105)
            else
                DisableDialogItem (DLG_HWND, 105)
            endif
        case DLG_ID == 105 .and. DLG_NOT ==0
            ret := GetEditText (DLG_HWND, 104 )
            nNewAge := ret
            lOk := .t.
            oBrw:oWnd:nLastKey := VK_RETURN
            _ReleaseDialog ( )
        case DLG_ID == 106 .and. DLG_NOT ==0
             SetDialogItemText(DLG_HWND, 104,"  " )
             DisableDialogItem (DLG_HWND, 105)
        case DLG_ID == 107 .and. DLG_NOT ==0
            oBrw:oWnd:nLastKey := VK_ESCAPE
            _ReleaseDialog ( )
        endcase
    endif
Return ret

Static Function SetInitItem()
    DisableDialogItem (DLG_HWND, 105)
Return Nil

//---------------------------------------------------------------------------------------//

Static Function ComboBrowse( cState, nRow, nCol, oWnd, lCustom )

   Local oDlg, oBrw, oFont, nEle, ix,;
         nArea := Select(), ;
         lOk   := .F.

   Default nRow    := 0, ;
           nCol    := 0, ;
           lCustom := .F.   // called from bCustomEdit

   DbSelectArea( "Sta" )
   DbSeek( AllTrim( Upper( cState ) ), .T.  ) // soft seek to search the closest code

   If lCustom .and. ;
      SubStr( STA->STATE, 1, 2 ) == Upper( cState ) // if found don't need to see the list
                                                    // then, return
      DbSelectArea( nArea )
      Return SubStr( STA->STATE, 1, 2 )

   EndIf

   If Eof()
      DbGoTop()
   EndIf

   If ValType( oWnd ) == "O"

      ix := &(oWnd:Name)

      nRow += _HMG_aControlHeight [ix]   //oWnd:nBottom -  oWnd:nTop
      nCol += _HMG_aControlWidth  [ix]   //oWnd:nRight -  oWnd:nLeft

      If ( nEle := ( GetSysMetrics( 1 ) - ( nRow + 157 ) ) ) < 0
         nRow += nEle
      EndIf

      If ( nEle := ( GetSysMetrics( 0 ) - ( nCol + 197 ) ) ) < 0
         nCol += nEle
      EndIf

   Else
      nRow := Nil
   EndIf

   IF ! _IsControlDefined ("Font_6","Main")
      DEFINE FONT Font_6 FONTNAME "Arial" SIZE 9
   ENDIF


   DEFINE WINDOW Form_dlg ;
        AT nRow,nCol ;
        WIDTH 197 HEIGHT 157 ;
        TITLE  "TSBrowse External Data Edition Sample" ;
        MODAL ;
        ON RELEASE DbSelectArea( nArea )

   @0,0 TBROWSE oBrw ALIAS "Sta" OF Form_dlg WIDTH  190 HEIGHT 123  FONT "Font_6" ;
        COLORS CLR_WHITE, RGB(128,0,255)

   ADD COLUMN TO oBrw TITLE "Code" DATA SubStr( Sta->State, 1, 2 ) ;
       SIZE 40 PIXELS ;
       COLORS CLR_WHITE, RGB(128,0,255),,, CLR_WHITE, CLR_BLACK ;
       ORDER "States"

   ADD COLUMN TO oBrw TITLE "State" DATA SubStr( Sta->State, 3 ) ;
       SIZE 118 PIXELS ;
       COLORS CLR_WHITE, RGB(128,0,255),,, CLR_WHITE, CLR_BLACK

   oBrw:bKeyDown := { | nKey | If( nKey == VK_RETURN .or. nKey == VK_ESCAPE, ;
                              DoMethod ( "Form_dlg" , "release" ), Nil ), lOk := nKey != VK_ESCAPE }
   oBrw:lNoHScroll  := .T.
   oBrw:lNoResetPos := .T.
   oBrw:nLineStyle  := 0
   oBrw:SetColor( { 15 }, { CLR_BLACK } )

    END WINDOW
   ACTIVATE WINDOW  Form_dlg

Return If( lOk, SubStr( Sta->State, 1, 2 ), If( ! lCustom, cState, Space(2 ) ) )

//---------------------------------------------------------------------------------------//

Function WinChildTile(lVert)
    if lVert
        TILE MDICHILDS VERTICAL
    else
        TILE MDICHILDS HORIZONTAL
    endif
    ResizeAllChildEdit()
Return Nil

Function WinChildCascade()
    CASCADE MDICHILDS
    ResizeAllChildEdit()
Return Nil

Function WinChildIcons()
    ARRANGE MDICHILD ICONS
Return Nil

Function WinChildCloseAll()
    CLOSE MDICHILDS ALL
Return Nil

Function WinChildRestoreAll()
    RESTORE MDICHILDS ALL
Return Nil
