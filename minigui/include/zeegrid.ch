/*
 * This file is a part of HbZeeGrid library.
 * Copyright 2017 (C) P.Chornyj <myorg63@mail.ru>
 *
 * Based on the Original Work by David Hillard
 *
 * //////////////////////////////////////////////////////
 * //////////////////////////////////////////////////////
 * //////                                        ////////
 * //////                                        ////////
 * //////     ZeeGrid Copyright(C) 2002-2015     ////////
 * //////                 by                     ////////
 * //////            David Hillard               ////////
 * //////                                        ////////
 * //////                                        ////////
 * //////        email: david@kycsepp.com        ////////
 * //////                                        ////////
 * //////////////////////////////////////////////////////
 * //////////////////////////////////////////////////////
 */

#ifndef __HB_CH__HBZEEGRID__
#define __HB_CH__HBZEEGRID__

/* ZeeGrid CONTROL MESSAGES */

#ifndef WM_USER
#define WM_USER      1024 // 0x0400
#endif

#define ZGM_LOADICON                             WM_USER + 1
#define ZGM_SETCELLICON                          WM_USER + 2
#define ZGM_SETROWHEIGHT                         WM_USER + 3
#define ZGM_SETCELLFONT                          WM_USER + 4
#define ZGM_SETCELLFCOLOR                        WM_USER + 5
#define ZGM_SETCELLBCOLOR                        WM_USER + 6
#define ZGM_SETTITLEHEIGHT                       WM_USER + 7
#define ZGM_SETCELLJUSTIFY                       WM_USER + 8
#define ZGM_GETCRC                               WM_USER + 9
#define ZGM_ENABLETBEDIT                         WM_USER + 10
#define ZGM_ENABLETBSEARCH                       WM_USER + 11
#define ZGM_SHOWTOOLBAR                          WM_USER + 12
#define ZGM_SHOWEDIT                             WM_USER + 13
#define ZGM_SHOWSEARCH                           WM_USER + 14
#define ZGM_GRAYBGONLOSTFOCUS                    WM_USER + 15
#define ZGM_ALLOCATEROWS                         WM_USER + 16
#define ZGM_SETAUTOINCREASESIZE                  WM_USER + 17
#define ZGM_APPENDROW                            WM_USER + 18
#define ZGM_DELETEROW                            WM_USER + 19
#define ZGM_SHRINKTOFIT                          WM_USER + 20
#define ZGM_SETRANGE                             WM_USER + 21
#define ZGM_GETRANGESUM                          WM_USER + 22
#define ZGM_SHOWTITLE                            WM_USER + 23
#define ZGM_ENABLESORT                           WM_USER + 24
#define ZGM_ENABLECOLMOVE                        WM_USER + 25
#define ZGM_SELECTCOLUMN                         WM_USER + 26
#define ZGM_DIMGRID                              WM_USER + 27
#define ZGM_SETROWNUMBERSWIDTH                   WM_USER + 28
#define ZGM_SETDEFAULTBCOLOR                     WM_USER + 29
#define ZGM_SETGRIDLINECOLOR                     WM_USER + 30
#define ZGM_SETCELLTEXT                          WM_USER + 31
#define ZGM_SETCOLWIDTH                          WM_USER + 32
#define ZGM_INSERTROW                            WM_USER + 33
#define ZGM_SHOWROWNUMBERS                       WM_USER + 34
#define ZGM_GETROWS                              WM_USER + 35
#define ZGM_REFRESHGRID                          WM_USER + 36
#define ZGM_SETDEFAULTFCOLOR                     WM_USER + 37
#define ZGM_SETDEFAULTFONT                       WM_USER + 38
#define ZGM_MERGEROWS                            WM_USER + 39
#define ZGM_SETDEFAULTJUSTIFY                    WM_USER + 40
#define ZGM_SETCELLTYPE                          WM_USER + 41
#define ZGM_SETCELLFORMAT                        WM_USER + 42
#define ZGM_SETCOLFORMAT                         WM_USER + 43
#define ZGM_SETCOLTYPE                           WM_USER + 44
#define ZGM_SETCOLJUSTIFY                        WM_USER + 45
#define ZGM_SETCOLFONT                           WM_USER + 46
#define ZGM_GETCELLINDEX                         WM_USER + 47
#define ZGM_ENABLETBMERGEROWS                    WM_USER + 48
#define ZGM_SHOWCURSORONLOSTFOCUS                WM_USER + 49
#define ZGM_EMPTYGRID                            WM_USER + 50
#define ZGM_ENABLETBROWNUMBERS                   WM_USER + 51
#define ZGM_GETFIXEDCOLUMNS                      WM_USER + 52
#define ZGM_SETCOLFCOLOR                         WM_USER + 53
#define ZGM_SETLEFTINDENT                        WM_USER + 54
#define ZGM_SETRIGHTINDENT                       WM_USER + 55
#define ZGM_ENABLEICONINDENT                     WM_USER + 56
#define ZGM_GETROWHEIGHT                         WM_USER + 57
#define ZGM_ENABLECOLRESIZING                    WM_USER + 58
#define ZGM_GETCOLWIDTH                          WM_USER + 59
#define ZGM_SETCOLBCOLOR                         WM_USER + 60
#define ZGM_SELECTROW                            WM_USER + 61
#define ZGM_SHOWCURSOR                           WM_USER + 62
#define ZGM_SETCELLEDIT                          WM_USER + 63
#define ZGM_GETCELLEDIT                          WM_USER + 64
#define ZGM_GETCURSORINDEX                       WM_USER + 65
#define ZGM_AUTOSIZE_ALL_COLUMNS                 WM_USER + 66
#define ZGM_SETCOLUMNHEADERHEIGHT                WM_USER + 67
#define ZGM_GETEDITEDCELL                        WM_USER + 68
#define ZGM_GOTOCELL                             WM_USER + 69
#define ZGM_SETCELLMARK                          WM_USER + 70
#define ZGM_MARKTEXT                             WM_USER + 71
#define ZGM_SETMARKTEXT                          WM_USER + 72
#define ZGM_ENABLETOOLBARTOGGLE                  WM_USER + 73
#define ZGM_HIGHLIGHTCURSORROW                   WM_USER + 74
#define ZGM_HIGHLIGHTCURSORROWINFIXEDCOLUMNS     WM_USER + 75
#define ZGM_GETROWOFINDEX                        WM_USER + 76
#define ZGM_GETCOLOFINDEX                        WM_USER + 77
#define ZGM_GETCELLTEXT                          WM_USER + 78
#define ZGM_SETDEFAULTEDIT                       WM_USER + 79
#define ZGM_SETCOLEDIT                           WM_USER + 80
#define ZGM_SHOWGRIDLINES                        WM_USER + 81
#define ZGM_ENABLEROWSIZING                      WM_USER + 82
#define ZGM_GETGRIDWIDTH                         WM_USER + 83
#define ZGM_SETCOLUMNORDER                       WM_USER + 84
#define ZGM_ENABLETBEXPORT                       WM_USER + 85
#define ZGM_ENABLETBPRINT                        WM_USER + 86
#define ZGM_SHOWHSCROLL                          WM_USER + 87
#define ZGM_SHOWVSCROLL                          WM_USER + 88
#define ZGM_AUTOVSCROLL                          WM_USER + 89
#define ZGM_AUTOHSCROLL                          WM_USER + 90
#define ZGM_EXPORT                               WM_USER + 91
#define ZGM_COMPARETEXT                          WM_USER + 92
#define ZGM_GETEDITTEXT                          WM_USER + 93
#define ZGM_SETEDITTEXT                          WM_USER + 94
#define ZGM_COMPARETEXT2STRING                   WM_USER + 95
#define ZGM_GETMOUSEROW                          WM_USER + 96
#define ZGM_GETMOUSECOL                          WM_USER + 97
#define ZGM_SETCURSORCELL                        WM_USER + 98
#define ZGM_CURSORFOLLOWMOUSE                    WM_USER + 99
#define ZGM_GETROWSPERPAGE                       WM_USER + 100
#define ZGM_GETTOPROW                            WM_USER + 101
#define ZGM_SETTOPROW                            WM_USER + 102
#define ZGM_AUTOSIZECOLONEDIT                    WM_USER + 103
#define ZGM_SETSORTLIMIT                         WM_USER + 105  //unused build 8+
#define ZGM_SORTONCOLDCLICK                      WM_USER + 106  //unused build 8+
#define ZGM_STOPWATCH_START                      WM_USER + 107
#define ZGM_STOPWATCH_STOP                       WM_USER + 108
#define ZGM_SORTCOLUMNASC                        WM_USER + 109
#define ZGM_SORTCOLUMNDESC                       WM_USER + 110
#define ZGM_GETCOLS                              WM_USER + 111
#define ZGM_SETSORTESTIMATE                      WM_USER + 112  //unused build 8+
#define ZGM_GETCELLTYPE                          WM_USER + 113
#define ZGM_GETCELLJUSTIFY                       WM_USER + 114
#define ZGM_GETCELLFCOLOR                        WM_USER + 115
#define ZGM_GETCELLBCOLOR                        WM_USER + 116
#define ZGM_GETCELLFONT                          WM_USER + 117
#define ZGM_GETCELLMARK                          WM_USER + 118
#define ZGM_GETCELLICON                          WM_USER + 119
#define ZGM_SETROWTYPE                           WM_USER + 120
#define ZGM_SETROWJUSTIFY                        WM_USER + 121
#define ZGM_SETROWFCOLOR                         WM_USER + 122
#define ZGM_SETROWBCOLOR                         WM_USER + 123
#define ZGM_SETROWFONT                           WM_USER + 124
#define ZGM_SETROWMARK                           WM_USER + 125
#define ZGM_SETROWICON                           WM_USER + 126
#define ZGM_SETROWEDIT                           WM_USER + 127
#define ZGM_SEARCHEACHKEYSTROKE                  WM_USER + 128
#define ZGM_COMBOCLEAR                           WM_USER + 129
#define ZGM_COMBOADDSTRING                       WM_USER + 130
#define ZGM_CLEARMARKONSELECT                    WM_USER + 131
#define ZGM_SETCOLICON                           WM_USER + 132
#define ZGM_SETCOLMARK                           WM_USER + 133
#define ZGM_SETDEFAULTTYPE                       WM_USER + 134
#define ZGM_SETDEFAULTMARK                       WM_USER + 135
#define ZGM_SETDEFAULTICON                       WM_USER + 136
#define ZGM_SORTSECONDARY                        WM_USER + 137
#define ZGM_GETSORTCOLUMN                        WM_USER + 138
#define ZGM_GETCURSORROW                         WM_USER + 139
#define ZGM_GETCURSORCOL                         WM_USER + 140
#define ZGM_GETSIZEOFCELL                        WM_USER + 141
#define ZGM_GETCELLDOUBLE                        WM_USER + 142
#define ZGM_SETCELLDOUBLE                        WM_USER + 143
#define ZGM_SETDEFAULTNUMWIDTH                   WM_USER + 144
#define ZGM_SETDEFAULTNUMPRECISION               WM_USER + 145
#define ZGM_SETCELLNUMWIDTH                      WM_USER + 146
#define ZGM_SETCOLNUMWIDTH                       WM_USER + 147
#define ZGM_SETROWNUMWIDTH                       WM_USER + 148
#define ZGM_SETCELLNUMPRECISION                  WM_USER + 149
#define ZGM_SETCOLNUMPRECISION                   WM_USER + 150
#define ZGM_SETROWNUMPRECISION                   WM_USER + 151
#define ZGM_SETCELLINT                           WM_USER + 152
#define ZGM_GETCELLINT                           WM_USER + 153
#define ZGM_INTERPRETBOOL                        WM_USER + 154
#define ZGM_INTERPRETNUMERIC                     WM_USER + 155
#define ZGM_SETCOLOR                             WM_USER + 157
#define ZGM_GETCOLOR                             WM_USER + 158
#define ZGM_SETFONT                              WM_USER + 159
#define ZGM_GETFONT                              WM_USER + 160
#define ZGM_SETPRINTPOINTSIZE                    WM_USER + 161
#define ZGM_GETROWSALLOCATED                     WM_USER + 162
#define ZGM_GETCELLSALLOCATED                    WM_USER + 163
#define ZGM_GETSIZEOFGRID                        WM_USER + 165
#define ZGM_PRINT                                WM_USER + 166
#define ZGM_SETITEMDATA                          WM_USER + 167
#define ZGM_GETITEMDATA                          WM_USER + 168
#define ZGM_ALTERNATEROWCOLORS                   WM_USER + 169
#define ZGM_UNLOCK                               WM_USER + 170
#define ZGM_QUERYBUILD                           WM_USER + 171
#define ZGM_SAVEGRID                             WM_USER + 172
#define ZGM_LOADGRID                             WM_USER + 173
#define ZGM_GETCELLTEXTLENGTH                    WM_USER + 174
#define ZGM_AUTOSIZECOLUMN                       WM_USER + 175
#define ZGM_ISGRIDDIRTY                          WM_USER + 176
#define ZGM_INTERPRETDATES                       WM_USER + 177
#define ZGM_SETCELLCDATE                         WM_USER + 178
#define ZGM_SETCELLJDATE                         WM_USER + 179
#define ZGM_GETJDATE                             WM_USER + 180
#define ZGM_GETCDATE                             WM_USER + 181
#define ZGM_GETTODAY                             WM_USER + 182
#define ZGM_SETREGCDATE                          WM_USER + 183
#define ZGM_SETREGJDATE                          WM_USER + 184
#define ZGM_GETREGDATEFORMATTED                  WM_USER + 185
#define ZGM_ISDATEVALID                          WM_USER + 186
#define ZGM_GETREGDATEYEAR                       WM_USER + 187
#define ZGM_GETREGDATEMONTH                      WM_USER + 188
#define ZGM_GETREGDATEDAY                        WM_USER + 189
#define ZGM_GETREGDATEDOW                        WM_USER + 190
#define ZGM_GETDOW                               WM_USER + 191
#define ZGM_GETDOWLONG                           WM_USER + 192
#define ZGM_GETDOWSHORT                          WM_USER + 193
#define ZGM_GETREGDATEDOY                        WM_USER + 194
#define ZGM_GETREGDATEWOY                        WM_USER + 195
#define ZGM_GETDOY                               WM_USER + 196
#define ZGM_GETWOY                               WM_USER + 197
#define ZGM_GETLASTBUTTONPRESSED                 WM_USER + 198
#define ZGM_ENABLECOLUMNSELECT                   WM_USER + 199
#define ZGM_KEEP3DONLOSTFOCUS                    WM_USER + 200
#define ZGM_SETLOSTFOCUSHIGHLIGHTCOLOR           WM_USER + 201
#define ZGM_GOTOFIRSTONSEARCH                    WM_USER + 202
#define ZGM_GETSELECTEDROW                       WM_USER + 203
#define ZGM_GETSELECTEDCOL                       WM_USER + 204
#define ZGM_COPYCELL                             WM_USER + 205
#define ZGM_GETCOLUMNORDER                       WM_USER + 206
#define ZGM_GETDISPLAYPOSITIONOFCOLUMN           WM_USER + 207
#define ZGM_GETCOLUMNINDISPLAYPOSITION           WM_USER + 208
#define ZGM_SCROLLDOWN                           WM_USER + 209
#define ZGM_SCROLLUP                             WM_USER + 210
#define ZGM_SCROLLRIGHT                          WM_USER + 211
#define ZGM_SCROLLLEFT                           WM_USER + 212
#define ZGM_SETBACKGROUNDBITMAP                  WM_USER + 213
#define ZGM_ENABLECOPY                           WM_USER + 214
#define ZGM_ENABLECUT                            WM_USER + 215
#define ZGM_ENABLEPASTE                          WM_USER + 216
#define ZGM_EXPANDROWSONPASTE                    WM_USER + 217
#define ZGM_SETCELLRESTRICTION                   WM_USER + 218
#define ZGM_SETROWRESTRICTION                    WM_USER + 219
#define ZGM_SETCOLRESTRICTION                    WM_USER + 220
#define ZGM_SETDEFAULTRESTRICTION                WM_USER + 221
#define ZGM_GETCELLRESTRICTION                   WM_USER + 222
#define ZGM_SETROWNUMBERFONT                     WM_USER + 223
#define ZGM_SETGRIDBGCOLOR                       WM_USER + 224
#define ZGM_GETCELLFORMAT                        WM_USER + 225
#define ZGM_SHOWCOPYMENU                         WM_USER + 226
#define ZGM_ADJUSTHEADERS                        WM_USER + 227
#define ZGM_ENABLETRANSPARENTHIGHLIGHTING        WM_USER + 228
#define ZGM_GETCELLADVANCE                       WM_USER + 229
#define ZGM_SETCELLADVANCE                       WM_USER + 230
#define ZGM_SETCOLADVANCE                        WM_USER + 231
#define ZGM_SETROWADVANCE                        WM_USER + 232
#define ZGM_SETDEFAULTADVANCE                    WM_USER + 233
#define ZGM_GETCELLINTSAFE                       WM_USER + 234
#define ZGM_GETROWNUMBERSWIDTH                   WM_USER + 235
#define ZGM_SPANCOLUMN                           WM_USER + 236
#define ZGM_GETAUTOINCREASESIZE                  WM_USER + 237


/* NOTIFICATION MESSAGES */

#define ZGN_MOUSEMOVE               1
#define ZGN_SORT                    2
#define ZGN_CURSORCELLCHANGED       3
#define ZGN_EDITEND                 4
#define ZGN_RIGHTCLICK              5
#define ZGN_LOADCOMBO               6
#define ZGN_INSERT                  7
#define ZGN_DELETE                  8
#define ZGN_F1                      9
#define ZGN_F2                      10
#define ZGN_F3                      11
#define ZGN_F4                      12
#define ZGN_F5                      13
#define ZGN_F6                      14
#define ZGN_F7                      15
#define ZGN_F8                      16
#define ZGN_EDITCOMPLETE            17
#define ZGN_DOUBLECLICKREADONLY     18
#define ZGN_DOUBLECLICKFIXEDCOLUMN  19
#define ZGN_SORTCOMPLETE            20
#define ZGN_BUTTONPRESSED           21
#define ZGN_CELLCLICKED             22
#define ZGN_COLUMNMOVED             23
#define ZGN_PASTECOMPLETE           24
#define ZGN_GOTFOCUS                25
#define ZGN_LOSTFOCUS               26
#define ZGN_ROWSELECTED             27

/* FILE EXPORT FLAGS */

#define EF_FILENAMESUPPLIED         0x01
#define EF_DELIMITERSUPPLIED        0x02
#define EF_SILENT                   0x04
#define EF_NOHEADER                 0x08

/* TEXT JUSTIFICATION CONSTANTS */

#define LEFT_SINGLE                 1
#define CENTER_SINGLE               4
#define RIGHT_SINGLE                7
#define LEFT_MULTI                  9
#define CENTER_MULTI                10
#define RIGHT_MULTI                 11

/* AVAILABLE CELL TYPES */

#define CELLTYPE_BOOLEAN_FALSE      0
#define CELLTYPE_BOOLEAN_TRUE       1
#define CELLTYPE_TEXT               2
#define CELLTYPE_NUMERIC            3
#define CELLTYPE_DATE               4
#define CELLTYPE_BUTTON             5
#define CELLTYPE_EMPTY_CELL         127

#endif
