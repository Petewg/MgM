*=============================================================================
* TSBrowse.ch  Version 9.0 1/Nov/2009
* Creating Browse From Code
*=============================================================================
#xcommand @ <row>,<col> TBROWSE <name> ;
        [ ID <nId> ] ;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ WIDTH <w> ]  ;
        [ HEIGHT <h> ] ;
        [ <head: HEAD,HEADER,HEADERS> <aHeaders,...> ] ;
        [ <sizes: WIDTHS, FIELDSIZES, SIZES, COLSIZES> <aColSizes,...> ] ;
        [ <format: PICTURE, FORMAT> <aPicture,...> ] ;
        [ <alias: ALIAS, ITEMS, ARRAY, WORKAREA, RECORDSET, RECSET> <uAlias> ] ;
        [ FIELDS <Fields,...> ] ;
        [ <enum: ENUMERATOR> ] ;
        [ <autosearch: AUTOSEARCH>  [ USERSEARCH <uUserSearch> ] ];
        [ <autofilter: AUTOFILTER>  [ USERFILTER <uUserFilter> ] ];
        [ VALUE <value> ]           ;
        [ FONT <fontname> ]         ;
        [ SIZE <fontsize> ]         ;
        [ <bold : BOLD> ]           ;
        [ <italic : ITALIC> ]       ;
        [ <underline : UNDERLINE> ] ;
        [ <strikeout : STRIKEOUT> ] ;
        [ TOOLTIP <tooltip> ]       ;
        [ BACKCOLOR <backcolor> ]   ;
        [ FONTCOLOR <fontcolor> ] ;
        [ <color: COLOR, COLORS> <aColors,...> ] ;
        [ ON GOTFOCUS <gotfocus> ]     ;
        [ ON CHANGE <uChange> ]        ;
        [ ON LOSTFOCUS <lostfocus> ]   ;
        [ ON DBLCLICK <uLDblClick> ]   ;
        [ <cell: CELL, CELLED, GRID> ] ;
        [ STYLE <nStyle> ]             ;
        [ <append : APPEND> ]          ;
        [ ON HEADCLICK <aHeadClick> ]  ;
        [ WHEN <uWhen> ]               ;
        [ VALID <aValidFields> ]       ;
        [ VALIDMESSAGES <aValidMessages> ] ;
        [ MESSAGE <cMsg> ]             ;
        [ READONLY <aReadOnly> ]       ;
        [ <lock: LOCK> ]               ;
        [ <Delete: DELETE> ]           ;
        [ <style: NOLINES> ]           ;
        [ IMAGE <aImages,...> ]        ;
        [ JUSTIFY <aJust> ]            ;
        [ HELPID <helpid> ]            ;
        [ <break: BREAK> ]             ;
        [ <lTransparent: TRANSPARENT> ] ;
        [ SELECTOR <uSelector> ] ;
        [ <lEditable: EDIT, EDITABLE> ] ;
        [ <lAutoCol: AUTOCOLS> ] ;
        [ <colsel:COLUMNS, INCLUDE> <aColSel,...> ] ;
        [ <names: NAMES,COLNAMES> <aNames> ] ;
        [ <foot: FOOT,FOOTER,FOOTERS> <aFooters> ] ;
        [ <keyno: NUMBER,COLKEYNO,COLNUMBER> <number> ] ;
        [ <edits: COLEDIT,COLSEDIT,EDITCOL,EDITCOLS> <aEdit> ] ;
        [ <adjus: COLADJUST,COLSADJUST> <Adjust> ] ;
        [ <ladjust: ADJUST> ] ;
        [ BRUSH <aBrush> ] ;
        [ <load: LOADFIELDS> ] ;
        [ <cur: DBLCURSOR, DOUBLE CURSOR, FIXED> ] ;
        [ <emptyval: COLEMPTY,COLSEMPTY,EMPTYVALUE> ] ;
        [ <gotfocusel: GOTFOCUSSELECT,GOTFOCUSELECT> ] ;
    =>;
<name> :=_DefineTBrowse (<(name)> ,    ;
       <(parent)>,      ;
       [ <col> ],       ;
       [ <row> ],       ;
       [ <w> ],         ;
       [ <h> ],         ;
       [ \{<aHeaders>\}] , ;
       [ \{<aColSizes>\}], ;
       [  \{|| \{ <Fields> \} \} ], ;
       [ <value> ],        ;
       [ <fontname> ],     ;
       [ <fontsize> ],     ;
       [ <tooltip> ],      ;
       [ <{uChange}> ],    ;
       [ \{|nRow,nCol,nFlags|(nRow,nCol,nFlags),<uLDblClick>\} ], ;
       [ <aHeadClick> ],   ;
       [ <{gotfocus}> ],   ;
       [ <{lostfocus}> ],  ;
       [ <uAlias> ],       ;
       [ <.Delete.> ],     ;
       [ <.style.> ],      ;
       [  \{<aImages>\} ], ;
       [ <aJust> ], ;
       [ <helpid> ], ;
       [ <.bold.> ], ;
       [ <.italic.> ], ;
       [ <.underline.> ], ;
       [ <.strikeout.> ], ;
       [ <.break.> ] , ;
       [ <backcolor> ], ;
       [ <fontcolor> ], ;
       [ <.lock.>  ], ;
       [ <.cell.> ], ;
       [ <nStyle> ], ;
       [ <.append.> ], ;
       [ <aReadOnly> ], ;
       [ <{aValidFields}> ], ;
       [ <aValidMessages> ], ;
       [ \{<aColors>\} ], ;
       [ <{uWhen}> ],[ <nId> ],[\{<(Fields)>\}],[<cMsg>], .t. ,;
       [ <.enum.> ],[ <.autosearch.> ],[ <{uUserSearch}> ],;
       [ <.autofilter.> ], [ <{uUserFilter}> ], [\{<aPicture>\}],;
       [ <.lTransparent.> ],[ <uSelector> ], [ <.lEditable.> ], ;
       [ <.lAutoCol.> ], [ \{<aColSel>\} ] ;
       [ <.load.> ], [ <.cur.> ], [ <aNames> ], [ <aFooters> ], ;
       [ <number> ], [ <aBrush> ], [ <aEdit> ], [ <Adjust> ], [ <.ladjust.> ], ;
       [ <.emptyval.> ], [ <.gotfocusel.> ] )

#xcommand DEFINE TBROWSE <name> ;
        AT <row>,<col> ;
        [ ID <nId> ] ;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ WIDTH <w> ]  ;
        [ HEIGHT <h> ] ;
        [ <head: HEAD,HEADER,HEADERS> <aHeaders,...> ] ;
        [ <sizes: WIDTHS, FIELDSIZES, SIZES, COLSIZES> <aColSizes,...> ] ;
        [ <format: PICTURE, FORMAT> <aPicture,...> ] ;
        [ <alias: ALIAS, ITEMS, ARRAY, WORKAREA, RECORDSET, RECSET> <uAlias> ] ;
        [ FIELDS <Fields,...> ] ;
        [ <enum: ENUMERATOR> ] ;
        [ <autosearch: AUTOSEARCH> [ USERSEARCH <uUserSearch> ] ];
        [ <autofilter: AUTOFILTER> [ USERFILTER <uUserFilter> ] ];
        [ VALUE <value> ]         ;
        [ FONT <fontname> ]         ;
        [ SIZE <fontsize> ]         ;
        [ <bold : BOLD> ] ;
        [ <italic : ITALIC> ] ;
        [ <underline : UNDERLINE> ] ;
        [ <strikeout : STRIKEOUT> ] ;
        [ TOOLTIP <tooltip> ]          ;
        [ BACKCOLOR <backcolor> ] ;
        [ FONTCOLOR <fontcolor> ] ;
        [ <color: COLOR, COLORS> <aColors,...> ] ;
        [ ON GOTFOCUS <gotfocus> ]     ;
        [ ON CHANGE <uChange> ]      ;
        [ ON LOSTFOCUS <lostfocus> ]     ;
        [ ON DBLCLICK <uLDblClick> ]      ;
        [ <cell: CELL, CELLED, GRID> ]        ;
        [ STYLE <nStyle> ]             ;
        [ <append : APPEND> ]         ;
        [ ON INIT <bInit> ] ;
        [ ON HEADCLICK <aHeadClick> ]     ;
        [ WHEN <uWhen> ]        ;
        [ VALID <aValidFields> ]    ;
        [ VALIDMESSAGES <aValidMessages> ] ;
        [ MESSAGE <cMsg> ] ;
        [ READONLY <aReadOnly> ]     ;
        [ <lock: LOCK> ]         ;
        [ <Delete: DELETE> ]        ;
        [ <style: NOLINES> ]         ;
        [ IMAGE <aImages,...> ]         ;
        [ JUSTIFY <aJust> ]         ;
        [ HELPID <helpid> ]         ;
        [ <break: BREAK> ]         ;
        [ <lTransparent: TRANSPARENT> ] ;
        [ SELECTOR <uSelector> ] ;
        [ <lEditable: EDIT, EDITABLE> ] ;
        [ <lAutoCol: AUTOCOLS> ] ;
        [ <colsel:COLUMNS, INCLUDE> <aColSel,...> ] ;
        [ <names: NAMES,COLNAMES> <aNames> ] ;
        [ <foot: FOOT,FOOTER,FOOTERS> <aFooters> ] ;
        [ <keyno: NUMBER,COLKEYNO,COLNUMBER> <number> ] ;
        [ <edits: COLEDIT,COLSEDIT,EDITCOL,EDITCOLS> <aEdit> ] ;
        [ <adjus: COLADJUST,COLSADJUST> <Adjust> ] ;
        [ <ladjust: ADJUST> ] ;
        [ BRUSH <aBrush> ] ;
        [ <load: LOADFIELDS> ] ;
        [ <cur: DBLCURSOR, DOUBLE CURSOR, FIXED> ] ;
        [ <emptyval: COLEMPTY,COLSEMPTY,EMPTYVALUE> ] ;
        [ <gotfocusel: GOTFOCUSSELECT,GOTFOCUSELECT> ] ;
    =>;
<name> :=_DefineTBrowse (<(name)> ,    ;
       <(parent)>,      ;
       [ <col> ],       ;
       [ <row> ],       ;
       [ <w> ],         ;
       [ <h> ],         ;
       [ \{<aHeaders>\}] ,     ;
       [ \{<aColSizes>\}]  ,     ;
       [  \{|| \{ <Fields> \} \} ], ;
       [ <value> ],    ;
       [ <fontname> ],     ;
       [ <fontsize> ],     ;
       [ <tooltip> ],     ;
       [ <{uChange}> ], ;
       [ \{|nRow,nCol,nFlags|(nRow,nCol,nFlags),<uLDblClick>\} ], ;
       [ <aHeadClick> ],  ;
       [ <{gotfocus}> ],    ;
       [ <{lostfocus}> ],     ;
       [ <uAlias> ],    ;
       [ <.Delete.> ],      ;
       [ <.style.> ],    ;
       [  \{<aImages>\} ],    ;
       [ <aJust> ], ;
       [ <helpid> ] , ;
       [ <.bold.> ], ;
       [ <.italic.> ], ;
       [ <.underline.> ], ;
       [ <.strikeout.> ], ;
       [ <.break.> ] , ;
       [ <backcolor> ], ;
       [ <fontcolor> ], ;
       [ <.lock.>  ], ;
       [ <.cell.> ], ;
       [ <nStyle> ], ;
       [ <.append.> ], ;
       [ <aReadOnly> ], ;
       [ <{aValidFields}> ], ;
       [ <aValidMessages> ], ;
       [ \{<aColors>\} ], ;
       [ <{uWhen}> ],[ <nId> ],[\{<(Fields)>\}],[<cMsg>], .f. ,;
       [ <.enum.> ],[ <.autosearch.> ],[ <{uUserSearch}> ],;
       [ <.autofilter.> ], [ <{uUserFilter}> ], [\{<aPicture>\}],;
       [ <.lTransparent.> ],[ <uSelector> ], [ <.lEditable.> ], ;
       [ <.lAutoCol.> ], [ \{<aColSel>\} ],  [ <{bInit}> ], ;
       [ <.load.> ], [ <.cur.> ], [ <aNames> ], [ <aFooters> ], ;
       [ <number> ], [ <aBrush> ], [ <aEdit> ], [ <Adjust> ], [ <.ladjust.> ], ;
       [ <.emptyval.> ], [ <.gotfocusel.> ] ) ;;
       with object <name>

#xcommand DEFINE TBROWSE <name> OBJ <obrw> ;
       [ AT <row>,<col> ] ;
       [ ID <nId> ] ;
       [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
       [ WIDTH <w> ]  ;
       [ HEIGHT <h> ] ;
       [ <head: HEAD,HEADER,HEADERS> <aHeaders,...> ] ;
       [ <sizes: WIDTHS, FIELDSIZES, SIZES, COLSIZES> <aColSizes,...> ] ;
       [ <format: PICTURE, FORMAT> <aPicture,...> ] ;
       [ <alias: ALIAS, ITEMS, ARRAY, WORKAREA, RECORDSET, RECSET> <uAlias> ] ;
       [ FIELDS <Fields,...> ] ;
       [ <enum: ENUMERATOR> ] ;
       [ <autosearch: AUTOSEARCH> [ USERSEARCH <uUserSearch> ] ];
       [ <autofilter: AUTOFILTER> [ USERFILTER <uUserFilter> ] ];
       [ VALUE <value> ]         ;
       [ FONT <fontname> ]         ;
       [ SIZE <fontsize> ]         ;
       [ <bold : BOLD> ] ;
       [ <italic : ITALIC> ] ;
       [ <underline : UNDERLINE> ] ;
       [ <strikeout : STRIKEOUT> ] ;
       [ TOOLTIP <tooltip> ]          ;
       [ BACKCOLOR <backcolor> ] ;
       [ FONTCOLOR <fontcolor> ] ;
       [ <color: COLOR, COLORS> <aColors,...> ] ;
       [ ON GOTFOCUS <gotfocus> ]     ;
       [ ON CHANGE <uChange> ]      ;
       [ ON LOSTFOCUS <lostfocus> ]     ;
       [ ON DBLCLICK <uLDblClick> ]      ;
       [ <cell: CELL, CELLED, GRID> ]        ;
       [ STYLE <nStyle> ]             ;
       [ <append : APPEND> ]         ;
       [ ON INIT <bInit> ] ;
       [ ON HEADCLICK <aHeadClick> ]     ;
       [ WHEN <uWhen> ]        ;
       [ VALID <aValidFields> ]    ;
       [ VALIDMESSAGES <aValidMessages> ] ;
       [ MESSAGE <cMsg> ] ;
       [ READONLY <aReadOnly> ]     ;
       [ <lock: LOCK> ]         ;
       [ <Delete: DELETE> ]        ;
       [ <style: NOLINES> ]         ;
       [ IMAGE <aImages,...> ]         ;
       [ JUSTIFY <aJust> ]         ;
       [ HELPID <helpid> ]         ;
       [ <break: BREAK> ]         ;
       [ <lTransparent: TRANSPARENT> ] ;
       [ SELECTOR <uSelector> ] ;
       [ <lEditable: EDIT, EDITABLE> ] ;
       [ <lAutoCol: AUTOCOLS> ] ;
       [ <colsel:COLUMNS, INCLUDE> <aColSel,...> ] ;
       [ <names: NAMES,COLNAMES> <aNames> ] ;
       [ <foot: FOOT,FOOTER,FOOTERS> <aFooters> ] ;
       [ <keyno: NUMBER,COLKEYNO,COLNUMBER> <number> ] ;
       [ <edits: COLEDIT,COLSEDIT,EDITCOL,EDITCOLS> <aEdit> ] ;
       [ <adjus: COLADJUST,COLSADJUST> <Adjust> ] ;
       [ <ladjust: ADJUST> ] ;
       [ BRUSH <aBrush> ] ;
       [ <load: LOADFIELDS> ] ;
       [ <cur: DBLCURSOR, DOUBLE CURSOR, FIXED> ] ;
       [ <emptyval: COLEMPTY,COLSEMPTY,EMPTYVALUE> ] ;
       [ <gotfocusel: GOTFOCUSSELECT,GOTFOCUSELECT> ] ;
    =>;
<obrw> :=_DefineTBrowse (<(name)> ,    ;
       <(parent)>,      ;
       [ <col> ],       ;
       [ <row> ],       ;
       [ <w> ],         ;
       [ <h> ],         ;
       [ \{<aHeaders>\}] ,     ;
       [ \{<aColSizes>\}]  ,     ;
       [  \{|| \{ <Fields> \} \} ], ;
       [ <value> ],    ;
       [ <fontname> ],     ;
       [ <fontsize> ],     ;
       [ <tooltip> ],     ;
       [ <{uChange}> ], ;
       [ \{|nRow,nCol,nFlags|(nRow,nCol,nFlags),<uLDblClick>\} ], ;
       [ <aHeadClick> ],  ;
       [ <{gotfocus}> ],    ;
       [ <{lostfocus}> ],     ;
       [ <uAlias> ],    ;
       [ <.Delete.> ],      ;
       [ <.style.> ],    ;
       [  \{<aImages>\} ],    ;
       [ <aJust> ], ;
       [ <helpid> ] , ;
       [ <.bold.> ], ;
       [ <.italic.> ], ;
       [ <.underline.> ], ;
       [ <.strikeout.> ], ;
       [ <.break.> ] , ;
       [ <backcolor> ], ;
       [ <fontcolor> ], ;
       [ <.lock.>  ], ;
       [ <.cell.> ], ;
       [ <nStyle> ], ;
       [ <.append.> ], ;
       [ <aReadOnly> ], ;
       [ <{aValidFields}> ], ;
       [ <aValidMessages> ], ;
       [ \{<aColors>\} ], ;
       [ <{uWhen}> ],[ <nId> ],[\{<(Fields)>\}],[<cMsg>], .f. ,;
       [ <.enum.> ],[ <.autosearch.> ],[ <{uUserSearch}> ],;
       [ <.autofilter.> ], [ <{uUserFilter}> ], [\{<aPicture>\}],;
       [ <.lTransparent.> ],[ <uSelector> ], [ <.lEditable.> ], ;
       [ <.lAutoCol.> ], [ \{<aColSel>\} ],  [ <{bInit}> ] ;
       [ <.load.> ], [ <.cur.> ], [ <aNames> ], [ <aFooters> ], ;
       [ <number> ], [ <aBrush> ], [ <aEdit> ], [ <Adjust> ], [ <.ladjust.> ], ;
       [ <.emptyval.> ], [ <.gotfocusel.> ] ) ;;
       with object <obrw>

#command END TBROWSE ;
       [ ON END <bOnEnd> ] ;
   =>;
       _EndTBrowse ( <{bOnEnd}> );;
       end with

*=============================================================================
* Creating Browse From resources
*=============================================================================

#xcommand REDEFINE TBROWSE <name>   ;
        ID <nId> ;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ <head: HEAD,HEADER,HEADERS> <aHeaders,...> ] ;
        [ <sizes: WIDTHS, FIELDSIZES, SIZES, COLSIZES> <aColSizes,...> ] ;
        [ <format: PICTURE, FORMAT> <aPicture,...> ] ;
        [ <alias: ALIAS, ITEMS, ARRAY, WORKAREA, RECORDSET, RECSET> <uAlias> ] ;
        [ FIELDS <Fields,...> ] ;
        [ <enum: ENUMERATOR> ] ;
        [ <autosearch: AUTOSEARCH> [ USERSEARCH <uUserSearch> ] ];
        [ <autofilter: AUTOFILTER> [ USERFILTER <uUserFilter> ] ];
        [ VALUE <value> ]           ;
        [ FONT <fontname> ]         ;
        [ SIZE <fontsize> ]         ;
        [ <bold : BOLD> ]           ;
        [ <italic : ITALIC> ]       ;
        [ <underline : UNDERLINE> ] ;
        [ <strikeout : STRIKEOUT> ] ;
        [ TOOLTIP <tooltip> ]       ;
        [ BACKCOLOR <backcolor> ]   ;
        [ FONTCOLOR <fontcolor> ]   ;
        [ <color: COLOR, COLORS> <aColors,...> ] ;
        [ ON GOTFOCUS <gotfocus> ]   ;
        [ ON CHANGE <uChange> ]      ;
        [ ON LOSTFOCUS <lostfocus> ] ;
        [ ON DBLCLICK <uLDblClick> ] ;
        [ <cell: CELL, CELLED, GRID> ]        ;
        [ STYLE <nStyle> ]           ;
        [ <append : APPEND> ]        ;
        [ ON HEADCLICK <aHeadClick> ]     ;
        [ WHEN <uWhen> ]        ;
        [ VALID <aValidFields> ]    ;
        [ VALIDMESSAGES <aValidMessages> ] ;
        [ MESSAGE <cMsg> ] ;
        [ READONLY <aReadOnly> ]     ;
        [ <lock: LOCK> ]         ;
        [ <Delete: DELETE> ]        ;
        [ <style: NOLINES> ]         ;
        [ IMAGE <aImage> ]         ;
        [ JUSTIFY <aJust> ]         ;
        [ HELPID <helpid> ]         ;
        [ <break: BREAK> ]         ;
        [ <lTransparent: TRANSPARENT> ] ;
        [ SELECTOR <uSelector> ] ;
        [ <lEditable: EDIT, EDITABLE> ] ;
        [ <lAutoCol: AUTOCOLS> ] ;
        [ <colsel:COLUMNS, INCLUDE> <aColSel,...> ] ;
    =>;
<name> :=_DefineTBrowse (<(name)> , ;
       <(parent)> , ;
       0,        ;
       0,        ;
       0,         ;
       0,         ;
       [ \{<aHeaders>\}] ,     ;
       [ \{<aColSizes>\}]  ,     ;
       [  \{|| \{ <Fields> \} \} ], ;
       [ <value> ],    ;
       [ <fontname> ],     ;
       [ <fontsize> ],     ;
       [ <tooltip> ],     ;
       [ <{uChange}> ], ;
       [ \{|nRow,nCol,nFlags|(nRow,nCol,nFlags),<uLDblClick>\} ], ;
       [ <aHeadClick> ],  ;
       [ <{gotfocus}> ],    ;
       [ <{lostfocus}> ],     ;
       [ <uAlias> ],    ;
       [ <.Delete.> ],      ;
       [ <.style.> ],    ;
       [ <aImage> ],    ;
       [ <aJust> ], ;
       [ <helpid> ] , ;
       [ <.bold.> ], ;
       [ <.italic.> ], ;
       [ <.underline.> ], ;
       [ <.strikeout.> ], ;
       [ <.break.> ] , ;
       [ <backcolor> ], ;
       [ <fontcolor> ], ;
       [ <.lock.>  ], ;
       [ <.cell.> ], ;
       [ <nStyle> ], ;
       [ <.append.> ], ;
       [ <aReadOnly> ], ;
       [ <{aValidFields}> ], ;
       [ <aValidMessages> ], ;
       [ \{<aColors>\} ], ;
       [ <{uWhen}> ],[ <nId> ],[\{<(Fields)>\}],[ <cMsg> ], .t. ,;
       [ <.enum.> ],[ <.autosearch.> ],[ <{uUserSearch}> ],;
       [ <.autofilter.> ], [ <{uUserFilter}> ], [\{<aPicture>\}],;
       [ <.lTransparent.> ],[ <uSelector> ], [ <.lEditable.> ], ;
       [ <.lAutoCol.> ], [ \{<aColSel>\} ] )

*=============================================================================
* Defining Column Objects ( General Data )
*=============================================================================

#command DEFINE COLUMN <oCol> ;
             [ <dat: DATA, SHOWBLOCK> <uData> ] ;
             [ <tit: TITLE, HEADER> <cHead> [ <oem: OEM, ANSI, CONVERT>] ];
             [ <foot: FOOT,FOOTER,FOOTERS> <cFoot> [ <oem2: OEM, ANSI, CONVERT>] ] ;
             [ <color: COLOR, COLORS> <aColors,...> ] ;
             [ <align: ALIGN, ALIN> <aAlign,...> ] ;
             [ <wid: WIDTH, SIZE> <nWidth> [ PIXELS ] ] ;
             [ PICTURE <cPicture> ] ;
             [ <bit: BITMAP, CHECK, CHECKBOX, COMBO, COMBOBOX> ] ;
             [ <edit: EDITABLE> ] ;
             [ VALID <uValid> ] ;
             [ <lite: NOBAR, NOHILITE> ] ;
             [ <idx: ORDER, INDEX, TAG> <cOrder> ] ;
             [ <pre: PRE EDIT, PREEDIT> <bPrevBlock> ] ;
             [ <pst: POST EDIT,POSTEDIT> <bPostBlock> ] ;
             [ <mov: MOVE, SHIFT> <nMoveDir> ] ;
             [ <cur: DBLCURSOR, DOUBLE CURSOR, FIXED> ] ;
             [ <l3D: LOOK3D, 3DLOOK> <a3DLook,...> ] ;
             [ WHEN <uWhen> ] ;
             [ MESSAGE <cMsg> ] ;
             [ TOOLTIP <cToolTip> ] ;
             [ <total: TOTAL, TOTALIZE> ] ;
             [ NAME <name> ] ;
             [ ALIAS <alias> ] ;
       => ;
   <oCol> := TSColumn():New( ;
             [ If(<.oem.>, OemToAnsi(<cHead>), <cHead>) ], ;
             [ If( ValType(<uData>) $ "BC", <uData>, <{uData}> ) ], ;
             [ <cPicture> ], [ \{<aColors>\} ], [ \{<aAlign>\} ], ;
             [ <nWidth> ], [ Upper(<(bit)>) ], [ <.edit.> ], ;
             [ \{|uVar,This| <uValid> \}], ;
             [ <.lite.> ], [ <(cOrder)> ], ;
             [ If(<.oem2.>, OemToAnsi(<cFoot>), <cFoot>) ], ;
             [ <{bPrevBlock}> ], [ <{bPostBlock}> ], [ <nMoveDir> ], ;
             [ <.cur.> ], [ \{<a3DLook>\} ], [ <{uWhen}> ],, <(uData)>, ;
             [ <(uWhen)> ], [<(uValid)>], [<(bPrevBlock)>], [<(bPostBlock)>], ;
             [<cMsg>], [ <cToolTip> ], [ <.total.> ],,,,,,,,, [ <(name)> ], [ <(alias)> ], .T. )

*=============================================================================
* Adding Column to Browse( General Data )
*=============================================================================

#command ADD [ COLUMN ] TO [ TBROWSE ] <oBrw> ;
             [ <dat: DATA, SHOWBLOCK> <uData> ] ;
             [ <tit: TITLE, HEADER> <cHead> [ <oem: OEM, ANSI, CONVERT>] ] ;
             [ <foot: FOOT,FOOTER,FOOTERS> <cFoot> [ <oem2: OEM, ANSI, CONVERT>] ] ;
             [ <color: COLOR, COLORS> <aColors,...> ] ;
             [ <align: ALIGN, ALIGNS> <aAlign,...> ] ;
             [ <wid: WIDTH, SIZE> <nWidth> [ PIXELS ] ] ;
             [ PICTURE <cPicture> ] ;
             [ <bit: BITMAP, CHECK, CHECKBOX, COMBO, COMBOBOX> ] ;
             [ <edit: EDITABLE> ] ;
             [ VALID <uValid> ] ;
             [ <lite: NOBAR, NOHILITE> ] ;
             [ <idx: ORDER, INDEX, TAG> <cOrder> ] ;
             [ <pre: PRE EDIT, PREEDIT> <bPrevBlock> ] ;
             [ <pst: POST EDIT,POSTEDIT> <bPostBlock> ] ;
             [ <mov: MOVE, SHIFT> <nMoveDir> ] ;
             [ <cur: DBLCURSOR, DOUBLE CURSOR, FIXED> ] ;
             [ <look3d: LOOK3D, 3DLOOK> <a3DLook,...> ] ;
             [ WHEN <uWhen> ] ;
             [ MESSAGE <cMsg> ] ;
             [ TOOLTIP <cToolTip> ] ;
             [ <total: TOTAL, TOTALIZE> ] ;
             [ NAME <name> ] ;
             [ ALIAS <alias> ] ;
       => ;
    <oBrw>:AddColumn( TSColumn():New( ;
             [ If(<.oem.>, OemToAnsi(<cHead>), <cHead>) ], ;
             [ If( ValType(<uData>)=="B", <uData>, <{uData}> ) ], ;
             [ <cPicture> ], [ \{<aColors>\} ], ;
             [ \{<aAlign>\} ], [ <nWidth> ], ;
             [ Upper(<(bit)>) ], [ <.edit.> ], ;
             [ \{|uVar,This| <uValid> \}], ;
             [ <.lite.> ], [ <(cOrder)> ], ;
             [ If(<.oem2.>, OemToAnsi(<cFoot>), <cFoot>) ], ;
             [ <{bPrevBlock}> ], [ <{bPostBlock}> ], [ <nMoveDir> ], ;
             [ <.cur.> ], [ \{<a3DLook>\} ], ;
             [ If( ValType(<uWhen>)=="B", <uWhen>, <{uWhen}> ) ], <oBrw>, ;
             <(uData)>, [<(uWhen)>], [<(uValid)>], [<(bPrevBlock)>], ;
             [<(bPostBlock)>], [<cMsg>], [ <cToolTip> ], [ <.total.> ],,,,,,,,, ;
             [ <(name)> ], [ <(alias)> ] ) )

*=============================================================================
* Adding Column to Browse ( Array Data )
*=============================================================================

#command ADD [ COLUMN ] TO [ TBROWSE ] <oBrw> [ DATA ] ARRAY ;
             [ <el: ELM, ELEMENT> <elm> ] ;
             [ <tit: TITLE, HEADER> <cHead> [ <oem: OEM, ANSI, CONVERT>] ];
             [ <foot: FOOT,FOOTER,FOOTERS> <cFoot> [ <oem2: OEM, ANSI, CONVERT>] ] ;  // <new193>  added by LKM 28/Mar/97
             [ <color: COLOR, COLORS> <aColors,...> ] ;
             [ <align: ALIGN, ALIGNS> <aAlign,...> ] ;
             [ <wid: WIDTH, SIZE> <nWidth> [ PIXELS ] ] ;
             [ PICTURE <cPicture> ] ;
             [ <bit: BITMAP, CHECK, CHECKBOX, COMBO, COMBOBOX> ] ;
             [ <edit: EDITABLE> ] ;
             [ VALID <uValid> ] ;
             [ <lite: NOBAR, NOHILITE> ] ;
             [ <pre: PRE EDIT, PREEDIT> <bPrevBlock> ] ;
             [ <pst: POST EDIT,POSTEDIT> <bPostBlock> ] ;
             [ <mov: MOVE, SHIFT> <nMoveDir> ] ;
             [ <cur: DBLCURSOR, DOUBLE CURSOR, FIXED> ] ;
             [ <l3D: LOOK3D, 3DLOOK> <a3DLook,...> ] ;
             [ WHEN <uWhen> ] ;
             [ MESSAGE <cMsg> ] ;
             [ TOOLTIP <cToolTip> ] ;
             [ <total: TOTAL, TOTALIZE> ] ;
             [ NAME <name> ] ;
             [ ALIAS <alias> ] ;
       => ;
    <oBrw>:AddColumn( TSColumn():New( ;
             [ If(<.oem.>, OemToAnsi(<cHead>), <cHead>) ], ;
             \{|x| If(PCount() > 0, <oBrw>:aArray\[<oBrw>:nAt, <elm>\] := x, ;
                      <oBrw>:aArray\[<oBrw>:nAt, <elm>\])\}, [ <cPicture> ], ;
             [ \{<aColors>\} ], [ \{<aAlign>\} ], [ <nWidth> ], ;
             [ Upper(<(bit)>) ], [ <.edit.> ], ;
             [ \{|uVar,This| <uValid> \}], ;
             [ <.lite.> ], Nil, ;
             [ If(<.oem2.>, OemToAnsi(<cFoot>), <cFoot>) ], ;
             [ <{bPrevBlock}> ], [ <{bPostBlock}> ], [ <nMoveDir> ], ;
             [ <.cur.> ], [ \{<a3DLook>\} ], ;
             [ If( ValType(<uWhen>)=="B", <uWhen>, <{uWhen}> ) ], <oBrw>,, ;
             [<(uWhen)>], [<(uValid)>], [<(bPrevBlock)>], [<(bPostBlock)>], ;
             [<cMsg>], [ <cToolTip> ], [ <.total.> ],,,,,,,,, [ <(name)> ], [ <(alias)> ] ) )

*=============================================================================
* Adding Column to Browse ( TDataBase .and. TMultiDBF Classes Data )
*=============================================================================

#command ADD [ COLUMN ] TO [ TBROWSE ] <oBrw> [ DATA ] ;
               <fi: oDBF, FIELD> [FIELD] <field> ;
             [ ALIAS <cAlias> ] ;
             [ <tit: TITLE, HEADER> <cHead> [ <oem: OEM, ANSI, CONVERT>] ] ;
             [ <foot: FOOT,FOOTER,FOOTERS> <cFoot> [ <oem2: OEM, ANSI, CONVERT>] ] ;  // <new193>  added by LKM 28/Mar/97
             [ <color: COLOR, COLORS> <aColors,...> ] ;
             [ <align: ALIGN, ALIGNS> <aAlign,...> ] ;
             [ <wid: WIDTH, SIZE> <nWidth> [ PIXELS ] ] ;
             [ PICTURE <cPicture> ] ;
             [ <bit: BITMAP, CHECK, CHECKBOX, COMBO, COMBOBOX> ] ;
             [ <edit: EDITABLE> ] ;
             [ VALID <uValid> ] ;
             [ <lite: NOBAR, NOHILITE> ] ;
             [ <idx: ORDER, INDEX, TAG> <cOrder> ] ;
             [ <pre: PRE EDIT, PREEDIT> <bPrevBlock> ] ;
             [ <pst: POST EDIT,POSTEDIT> <bPostBlock> ] ;
             [ <mov: MOVE, SHIFT> <nMoveDir> ] ;
             [ <cur: DBLCURSOR, DOUBLE CURSOR, FIXED> ] ;
             [ <l3D: LOOK3D, 3DLOOK> <a3DLook,...> ] ;
             [ MESSAGE <cMsg> ] ;
             [ TOOLTIP <cToolTip> ] ;
             [ <total: TOTAL, TOTALIZE> ] ;
             [ NAME <name> ] ;
             [ ALIAS <alias> ] ;
       => ;
    <oBrw>:AddColumn( TSColumn():New( ;
             [ If(<.oem.>, OemToAnsi(<cHead>), <cHead>) ], ;
               \{|x| If(PCount() > 0, <oBrw>:oDbf:[<cAlias>:]<field> := x, ;
                       <oBrw>:oDbf:[<cAlias>:]<field>) \}, [ <cPicture> ], ;
             [ \{<aColors>\} ], [ \{<aAlign>\} ], [ <nWidth> ], ;
             [ Upper(<(bit)>) ], [ <.edit.> ], [ \{|uVar,This| <uValid> \}], ;
             [ <.lite.> ], [ <(cOrder)> ], ;
             [ If(<.oem2.>, OemToAnsi(<cFoot>), <cFoot>) ] , ;
             [ <{bPrevBlock}> ], [ <{bPostBlock}> ], [ <nMoveDir> ], ;
             [ <.cur.> ], [ \{<a3DLook>\} ],, <oBrw>,,, [<(uValid)>], ;
             [ <(bPrevBlock)> ], [<(bPostBlock)>], [<cMsg>], [ <cToolTip> ], [ <.total.> ],,,,,,,,, ;
             [ <(name)> ], [ <(alias)> ] ) )

*=============================================================================
* Adding Super Headings to Browse
*=============================================================================

#command ADD [ SUPER ] HEADER TO <oBrw> ;
             FROM [ COLUMN ] <nFrom> ;
             TO [ COLUMN ] <nTo> ;
             [ <head:TITLE, HEADER> <cHead> ] ;
             [ HEIGHT <nHeight> ] ;
             [ <color:COLOR, COLORS> <aColors,...> ] ;
             [ <l3dLook: 3DLOOK, LOOK3D> ] ;
             [ FONT <uFont> ] ;
             [ <lGrid:NOGRID, NOLINES> ] ;
             [ BITMAP <uBmp> ] ;
             [ <lAdj:ADJUST> ] ;
             [ <lTra:TRANSPARENT> ] ;
             [ <horz:HORZ, HORZ ALIGN> <nHAlign> ] ;
             [ <vert:VERT, VERT ALIGN> <nVAlign> ] ;
       => ;
       <oBrw>:AddSuperHead( <nFrom>, <nTo>, <cHead>, [ <nHeight> ], ;
                            [ \{<aColors>\} ], <.l3dLook.>, <uFont>, ;
                            <uBmp>, <.lAdj.>, <.lTra.>, <.lGrid.>, ;
                            <nHAlign>, <nVAlign> )

*=============================================================================
* Enable/Disable commands of Browse
*=============================================================================

#xcommand ENABLE EDIT [ CONTROL ] [ TBROWSE ] <oBrw> COLUMN <nColumn> ;
            =>  <oBrw>:aColumns\[ <nColumn> \]:lEdit  := .T.
#xcommand DISABLE EDIT [ CONTROL ][ TBROWSE ] <oBrw> COLUMN <nColumn> ;
            =>  <oBrw>:aColumns\[ <nColumn> \]:lEdit  := .F.

#xcommand ENABLE NORESETPOS [ CONTROL ] [ TBROWSE ] <oBrw> ;
            => <oBrw>:lNoResetPos( .T. )
#xcommand DISABLE NORESETPOS [ CONTROL ] [ TBROWSE ] <oBrw> ;
            => <oBrw>:lNoResetPos( .F. )

#xcommand ENABLE APPENDMODE [ CONTROL ] [ TBROWSE ] <oBrw> ;
            => <oBrw>:SetAppendMode( .T. )
#xcommand DISABLE APPENDMODE [ CONTROL ] [ TBROWSE ] <oBrw> ;
            => <oBrw>:SetAppendMode( .F. )

#xcommand ENABLE LOOK3D ALL [ CONTROL ] [ TBROWSE ] <oBrw> [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .T., , , <.lPhantom.> )
#xcommand ENABLE LOOK3D [ CONTROL ][ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .T., <nColumn>, 1, <.lPhantom.> )
#xcommand ENABLE LOOK3D HEADER [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .T., <nColumn>, 2, <.lPhantom.> )
#xcommand ENABLE LOOK3D FOOTER [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .T., <nColumn>, 3, <.lPhantom.> )

#xcommand DISABLE LOOK3D ALL [ CONTROL ] [ TBROWSE ] <oBrw> [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .F., , , <.lPhantom.> )
#xcommand DISABLE LOOK3D [ CONTROL ][ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .F., <nColumn>, 1, <.lPhantom.> )
#xcommand DISABLE LOOK3D HEADER [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .F., <nColumn>, 2, <.lPhantom.> )
#xcommand DISABLE LOOK3D FOOTER [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ <lPhantom : PHANTOM> ] ;
            => <oBrw>:Look3D( .F., <nColumn>, 3, <.lPhantom.> )

*=============================================================================
* Insert/Modify commands of Browse
*=============================================================================

#xcommand INSERT [ CONTROL ][ TBROWSE ] <oBrw> COLUMN <nColumn> TO <oColumn> ;
            => <oBrw>:InsColumn( <nColumn>, <oColumn> )

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ PROPERTY ] LINESTYLE TO <nLineStyle> ;
            => <oBrw>:nLineStyle := <nLineStyle>

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ PROPERTY ] FREEZE TO <nFreeze> ;
            => <oBrw>:nFreeze := <nFreeze>

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> COLUMN <nColumn> [ PROPERTY ] DATA TO <bData>;
            => <oBrw>:aColumns\[ <nColumn> \]:bData := <bData>
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> COLUMN <nColumn> [ PROPERTY ] VALID TO <bValid>;
            => <oBrw>:aColumns\[ <nColumn> \]:bValid := <bValid>

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> COLUMN <nColumn> [ PROPERTY ] ALIGN TO <ConstAlign>;
            => <oBrw>:SetAlign( <nColumn>, 1, <ConstAlign> )
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> COLUMN <nColumn> [ PROPERTY ] HEADER ALIGN TO <ConstAlign>;
            => <oBrw>:SetAlign( <nColumn>, 2, <ConstAlign> )
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> COLUMN <nColumn> [ PROPERTY ] FOOTER ALIGN TO <ConstAlign>;
            => <oBrw>:SetAlign( <nColumn>, 3, <ConstAlign> )

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ PROPERTY ] FONT TO <cFont>;
               => <oBrw>:ChangeFont( GetFontHandle( <"cFont"> ), <nColumn>, 1 )
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ PROPERTY ] HEADER FONT TO <cFont>;
               => <oBrw>:ChangeFont( GetFontHandle( <"cFont"> ), <nColumn>, 2 )
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ PROPERTY ] FOOTER FONT TO <cFont>;
               => <oBrw>:ChangeFont( GetFontHandle( <"cFont"> ), <nColumn>, 3 )
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ PROPERTY ] SUPERHEADER FONT TO <cFont>;
               => <oBrw>:ChangeFont( GetFontHandle( <"cFont"> ), <nColumn>, 4 )

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> COLUMN <nColumn> [ PROPERTY ] COLSIZE TO <nSize> ;
               => <oBrw>:SetColSize( <nColumn>, <nSize> )
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> COLUMNS <aColumns> [ PROPERTY ] COLSIZE TO <aSizes> ;
               => <oBrw>:SetColSize( <aColumns>, <aSizes> )

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ PROPERTY ] INDEXCOLS TO <nCol,...> ;
            => <oBrw>:SetIndexCols( {<nCol>} )

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ PROPERTY ] COLORS <lConst,...> TO <nColor,...> ;
            => <oBrw>:SetColor( {<lConst>}, {<nColor>}, <nColumn> )

#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ PROPERTY ] TEXT COLOR TO <nColor> ;
            => <oBrw>:SetColor( {CLR_TEXT}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ CONTROL ] [ TBROWSE ] <oBrw> [ COLUMN <nColumn> ] [ PROPERTY ] BACKGROUND COLOR TO <nColor> ;
            => <oBrw>:SetColor( {CLR_PANE}, {<nColor>}, <nColumn> )

#xcommand MODIFY [ PROPERTY ] LINE COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_LINE}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] HEADER COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_HEADF, CLR_HEADB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] FOCUS COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_FOCUSF, CLR_FOCUSB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] EDIT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_EDITF, CLR_FOCUSB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SELECT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SELEF, CLR_SELEB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] ORDER COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_ORDF, CLR_ORDB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SUPERHEADER COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SUPF, CLR_SUPB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SPECHEADER COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SPCF, CLR_SPCB, CLR_SPCA}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] HEADER TEXT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_HEADF}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] HEADER BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_HEADB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] FOCUS TEXT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_FOCUSF}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] FOCUS BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_FOCUSB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] EDIT TEXT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_EDITF}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] EDIT BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_FOCUSB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SELECT TEXT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SELEF}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SELECT BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SELEB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] ORDER TEXT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_ORDF}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] ORDER BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_ORDB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SUPERHEADER TEXT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SUPF}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SUPERHEADER BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SUPB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SPECHEADER TEXT COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SPCF}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SPECHEADER BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SPCB}, {<nColor>}, <nColumn> )
#xcommand MODIFY [ PROPERTY ] SPECHEADER ACTIV BACKGROUND COLOR [ COLUMN <nColumn> ] OF [ CONTROL ] [ TBROWSE ] <oBrw> TO <nColor> ;
            => <oBrw>:SetColor( {CLR_SPCA}, {<nColor>}, <nColumn> )

*=============================================================================
* Predefined Constants
*=============================================================================
#ifndef __NO_REDEFINE__
#define __NO_REDEFINE__

// Horizontal alignment
#ifndef DT_LEFT
   #define DT_LEFT              0
   #define DT_CENTER            1
   #define DT_RIGHT             2
#endif
#define DT_VERT              3  // vertical text (only for headers)
#define DT_CENTERED          DT_CENTER

// Vertical alignment
#ifndef DT_TOP
#define DT_TOP               0
#define DT_BOTTOM            2
#endif
// Cursor movement after editing
#define DT_DONT_MOVE         0
#define DT_MOVE_RIGHT        1
#define DT_MOVE_DOWN         2
#define DT_MOVE_LEFT         3
#define DT_MOVE_UP           4
#define DT_MOVE_NEXT         5

// Report method() language text selection
#define DT_DATE              1
#define DT_PAGE              2
#define DT_TIME              3
#define DT_PREVIEW           4

#define DT_SPANISH           1
#define DT_ENGLISH           2

// Flags for phantom column: with or without a grid
#define PHCOL_GRID          -1
#define PHCOL_NOGRID        -2

// Default text sizes
#define SCRL_CHARPIX_H      14
#define SCRL_CHARPIX_W       8

// Line Styles
#define LINES_NONE           0
#define LINES_ALL            1
#define LINES_VERT           2
#define LINES_HORZ           3
#define LINES_3D             4
#define LINES_DOTTED         5

// aColors items number
#define CLR_TEXT             1   // text
#define CLR_PANE             2   // back
#define CLR_HEADF            3   // header text
#define CLR_HEADB            4   // header back
#define CLR_FOCUSF           5   // focused text
#define CLR_FOCUSB           6   // focused back
#define CLR_EDITF            7   // editing text
#define CLR_EDITB            8   // editing back
#define CLR_FOOTF            9   // footer text
#define CLR_FOOTB           10   // footer back
#define CLR_SELEF           11   // focused inactive (or selected) text
#define CLR_SELEB           12   // focused inactive (or selected) back
#define CLR_ORDF            13   // order column text
#define CLR_ORDB            14   // order column back
#define CLR_LINE            15   // grid lines
#define CLR_SUPF            16   // superheader text
#define CLR_SUPB            17   // superheader back
#define CLR_SPCF            18   // specheader text
#define CLR_SPCB            19   // specheader back
#define CLR_SPCA            20   // active specheader back

// System Colors
#define COLOR_ACTIVECAPTION           2
#define COLOR_INACTIVECAPTION         3
#define COLOR_WINDOW                  5
#define COLOR_WINDOWTEXT              8
#define COLOR_CAPTIONTEXT             9
#define COLOR_HIGHLIGHT               13
#define COLOR_HIGHLIGHTTEXT           14
#define COLOR_BTNFACE                 15
#define COLOR_BTNSHADOW               16
#define COLOR_BTNTEXT                 18
#define COLOR_INACTCAPTEXT            19
#define COLOR_BTNHIGHLIGHT            20
#define COLOR_INFOTEXT                23
#define COLOR_INFOBK                  24
#define COLOR_GRADIENTINACTIVECAPTION 28
#define COLOR_GRID                    GetSysColor( COLOR_GRADIENTINACTIVECAPTION )

// Styles
#define DS_3DLOOK           4
#define GWL_STYLE           -16

#define bSETGET( x )        { | u | If( PCount() == 0, x, x := u ) }

#define CS_DBLCLKS          8

#ifndef TRUE
   #define TRUE             .T.
   #define FALSE            .F.
#endif
#define VK_PASTE            86
#define VK_COPY             67
#define VK_CUT              88

//------------------------------------------------------------------------//
#translate VALID <if: IF, CONDITION> <cond> => ;
                   VALID \{|o, x| x := o:varGet(), <cond> \}
//------------------------------------------------------------------------//
#xtranslate GetSysMetrics( <p> )      => GetSystemMetrics( <p> )
#xtranslate SysRefresh()              => DoEvents()
#xtranslate nMakeLong( <p1> , <p2> )  => MakeLong( <p1> , <p2> )

#define BN_CLICKED                 0

#define EN_SETFOCUS              256  // 0x0100
#define EN_KILLFOCUS             512  // 0x0200

#define CS_VREDRAW                 1  // 0x0001
#define CS_HREDRAW                 2  // 0x0002
#define CS_GLOBALCLASS         16384  // 0x4000

#define CS_OWNDC                  32  // 0x0020
#define CS_CLASSDC                64  // 0x0040
#define CS_PARENTDC              128  // 0x0080

#define CS_BYTEALIGNCLIENT      4096  // 0x1000
#define CS_BYTEALIGNWINDOW      8192  // 0x2000

#define WS_OVERLAPPED              0  // 0x00000000L
#define WS_POPUP          2147483648  // 0x80000000L
#define WS_CHILD          1073741824  // 0x40000000L

#define WS_CLIPSIBLINGS     67108864  // 0x04000000L
#define WS_CLIPCHILDREN     33554432  // 0x02000000L

#define WS_VISIBLE         268435456  // 0x10000000L
#define WS_DISABLED        134217728  // 0x08000000L

#define WS_MINIMIZE        536870912  // 0x20000000L
#define WS_MAXIMIZE         16777216  // 0x01000000L

#define WS_CAPTION          12582912  // 0x00C00000L
#define WS_BORDER            8388608  // 0x00800000L
#define WS_DLGFRAME          4194304  // 0x00400000L
#define WS_VSCROLL           2097152  // 0x00200000L
#define WS_HSCROLL           1048576  // 0x00100000L
#define WS_SYSMENU            524288  // 0x00080000L
#define WS_THICKFRAME         262144  // 0x00040000L
#define WS_MINIMIZEBOX        131072  // 0x00020000L
#define WS_MAXIMIZEBOX         65536  // 0x00010000L

#define WS_GROUP              131072  // 0x00020000L
#define WS_TABSTOP             65536  // 0x00010000L

#define WS_OVERLAPPEDWINDOW (WS_OVERLAPPED + WS_CAPTION + WS_SYSMENU + WS_THICKFRAME + WS_MINIMIZEBOX + WS_MAXIMIZEBOX)
#define WS_POPUPWINDOW        (WS_POPUP + WS_BORDER + WS_SYSMENU)
#define WS_CHILDWINDOW        (WS_CHILD)

#define ES_LEFT                    0
#define ES_CENTER                  1
#define ES_RIGHT                   2
#define ES_MULTILINE               4
#define ES_AUTOHSCROLL           128    // 0x0080
#define ES_READONLY             2048    // 0x0800
#define ES_WANTRETURN           4096    // 0x1000

#define WM_NULL                    0    // 0x0000
#define WM_DESTROY                 2    // 0x0002
#define WM_MOVE                    3
#define WM_SIZE                    5    // 0x0005
#define WM_SETFOCUS                7    // 0x0007
#define WM_KILLFOCUS               8    // 0x0008
#define WM_PAINT                  15    // 0x000F
#define WM_CLOSE                  16    // 0x0010
#define WM_QUERYENDSESSION        17    // 0x0011
#define WM_QUIT                   18    // 0x0012
#define WM_SYSCOLORCHANGE         21    // 0x0015
#define WM_ENDSESSION             22    // 0x0016
#define WM_SYSTEMERROR            23    // 0x0017
#define WM_WININICHANGE           26    // 0x001A
#define WM_DEVMODECHANGE          27    // 0x001B
#define WM_FONTCHANGE             29    // 0x001D
#define WM_TIMECHANGE             30    // 0x001E
#define WM_SPOOLERSTATUS          42    // 0x002A
#define WM_COMPACTING             65    // 0x0041
#define WM_NOTIFY                 78

#define WM_GETDLGCODE            135    // 0x0087
#define WM_CHAR                  258    // 0x0102
#define WM_COMMAND               273    // 0x0111
#define WM_MOUSEMOVE             512    // 0x0200
#define WM_LBUTTONDOWN           513    // 0x0201
#define WM_LBUTTONUP             514    // 0x0202
#define WM_RBUTTONDOWN           516    // 0x0204
#define WM_RBUTTONUP             517    // 0x0205
#define WM_KEYDOWN               256    // 0x0100
#define WM_KEYUP                 257    // 0x0101
#define WM_INITDIALOG            272    // 0x0110
#define WM_TIMER                 275    // 0x0113
#define WM_HSCROLL               276    // 0x0115
#define WM_VSCROLL               277    // 0x0115

#define WM_QUERYNEWPALETTE       783    // 0x030F
#define WM_PALETTEISCHANGING     784    // 0x0310
#define WM_PALETTECHANGED        785    // 0x0311

//#define WM_USER                 1024    // 0x0400
#define WM_DRAWITEM               43
#define WM_ERASEBKGND             20
#define WM_ASYNCSELECT            WM_USER+1041

#define DS_SYSMODAL                2
#define DS_MODALFRAME            128  // 0x80

// Dialogs

#define DLGC_WANTARROWS                    1
#define DLGC_WANTTAB                       2
#define DLGC_WANTALLKEYS                   4
#define DLGC_WANTCHARS                   128


// ListBox Styles

#define LBS_NOTIFY               1
#define LBS_SORT                 2
#define LBS_OWNERDRAWFIXED      16  //    0x10
#define LBS_USETABSTOPS        128  //    0x80
#define LBS_NOINTEGRALHEIGHT   256  //   0x100
#define LBS_WANTKEYBOARDINPUT 1024  //   0x400
#define LBS_DISABLENOSCROLL   4096  //  0x1000
#define LBS_STANDARD      10485763  //0xA00003

// ComboBox Styles

#define CBS_SIMPLE               1  // 0x0001
#define CBS_DROPDOWN             2  // 0x0002
#define CBS_DROPDOWNLIST         3  // 0x0003
#define CBS_OWNERDRAWFIXED      16  // 0x0010
#define CBS_AUTOHSCROLL         64  // 0x0040
#define CBS_OEMCONVERT         128  // 0x0080
#define CBS_SORT               256  // 0x0100
#define CBS_DISABLENOSCROLL   2048  // 0x0800

// ScrollBar

#define SB_LINEUP                          0
#define SB_LINELEFT                        0
#define SB_LINEDOWN                        1
#define SB_LINERIGHT                       1
#define SB_PAGEUP                          2
#define SB_PAGELEFT                        2
#define SB_PAGEDOWN                        3
#define SB_PAGERIGHT                       3
#define SB_THUMBPOSITION                   4
#define SB_THUMBTRACK                      5
#define SB_TOP                             6
#define SB_LEFT                            6
#define SB_BOTTOM                          7
#define SB_RIGHT                           7
#define SB_ENDSCROLL                       8

// Scroll Bar styles

#define SBS_HORZ                           0
#define SBS_VERT                           1

// CheckBox

#define BS_PUSHBUTTON                     0
#define BS_DEFPUSHBUTTON                  1
#define BS_CHECKBOX                       2
#define BS_AUTOCHECKBOX                   3   // 0x00000003
#define BS_GROUPBOX                       7
#define BS_AUTORADIOBUTTON                9

/* Pen Styles */
#ifndef PS_SOLID
#define PS_SOLID                          0
#define PS_DASH                           1
#define PS_DOT                            2
#define PS_DASHDOT                        3
#define PS_DASHDOTDOT                     4
#define PS_NULL                           5
#define PS_INSIDEFRAME                    6
#endif

#define SS_BLACKRECT                      4
#define SS_WHITERECT                      6
#define SS_WHITEFRAME                     9
#define SS_LEFT                           0
#define SS_SIMPLE                        11   // 0x0B

#define FM_SCROLLUP    WM_USER+1025
#define FM_SCROLLDOWN  WM_USER+1026
#define FM_SCROLLPGUP  WM_USER+1027
#define FM_SCROLLPGDN  WM_USER+1028

#define FM_CHANGE      WM_USER+1029
#define FM_COLOR       WM_USER+1030
#define FM_MEASURE     WM_USER+1031
#define FM_DRAW        WM_USER+1032
#define FM_LOSTFOCUS   WM_USER+1033
#define FM_THUMBPOS    WM_USER+1034
#define FM_THUMBTRACK  WM_USER+1038

#ifndef CLR_BLACK
//----------------------------------------------------------------------------//
//                        Low Intensity colors
//----------------------------------------------------------------------------//

#define CLR_BLACK             0               // RGB(   0,   0,   0 )
#define CLR_BLUE        8388608               // RGB(   0,   0, 128 )
#define CLR_GREEN         32768               // RGB(   0, 128,   0 )
#define CLR_CYAN        8421376               // RGB(   0, 128, 128 )
#define CLR_RED             128               // RGB( 128,   0,   0 )
#define CLR_MAGENTA     8388736               // RGB( 128,   0, 128 )
#define CLR_BROWN         32896               // RGB( 128, 128,   0 )
#define CLR_HGRAY      12632256               // RGB( 192, 192, 192 )
#define CLR_LIGHTGRAY  CLR_HGRAY

//----------------------------------------------------------------------------//
//                       High Intensity Colors
//----------------------------------------------------------------------------//

#define CLR_GRAY        8421504               // RGB( 128, 128, 128 )
#define CLR_HBLUE      16711680               // RGB(   0,   0, 255 )
#define CLR_HGREEN        65280               // RGB(   0, 255,   0 )
#define CLR_HCYAN      16776960               // RGB(   0, 255, 255 )
#define CLR_HRED            255               // RGB( 255,   0,   0 )
#define CLR_HMAGENTA   16711935               // RGB( 255,   0, 255 )
#define CLR_YELLOW        65535               // RGB( 255, 255,   0 )
#define CLR_WHITE      16777215               // RGB( 255, 255, 255 )

#endif
//----------------------------------------------------------------------------//
//                       ADO constants
//----------------------------------------------------------------------------//
#ifndef _ADORDD_CH

// open and lock
#define adOpenDynamic       2
#define adLockOptimistic    3
#define adUseClient         3

// ADO Find constans
#define adSearchForward     1
#define adSearchBackward   -1

//ADO Filter constans
#define adFilterNone        0

// data types
#define adSmallInt          2
#define adInteger           3
#define adSingle            4
#define adDouble            5
#define adCurrency          6
#define adDate              7
#define adBSTR              8
#define adDecimal          14
#define adUnsignedTinyInt  17
#define adTinyInt          16
#define adUnsignedSmallInt 18
#define adUnsignedInt      19
#define adBigInt           20
#define adUnsignedBigInt   21
#define adChar            129
#define adWChar           130
#define adNumeric         131
#define adDBDate          133
#define adVarNumeric      139
#define adVarChar         200
#define adVarWChar        202
#define adLongVarWChar    203

// group
#define adIndex 8388608

#endif

#endif  // __NO_REDEFINE__
