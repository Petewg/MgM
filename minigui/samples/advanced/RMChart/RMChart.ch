* RMCHART.CH

// Thanks to Michael Henning, who ported the original PowerBASIC include file 
// to rmchartbcx.inc. 

// Then Roger Seiler made the translation from Henning's BCX code to FWH.

// Color constants...

#define ColorAliceBlue               0xFFF0F8FF
#define ColorAntiqueWhite            0xFFFAEBD7
#define ColorAquamarine              0xFF7FFFD4
#define ColorArmyGreen               0xFF669966
#define ColorAutumnOrange            0xFFFF6633
#define ColorAvocadoGreen            0xFF669933
#define ColorAzure                   0xFFF0FFFF
#define ColorBabyBlue                0xFF6699FF
#define ColorBananaYellow            0xFFCCCC33
#define ColorBeige                   0xFFF5F5DC
#define ColorBisque                  0xFFFFE4C4
#define ColorBlack                   0xFF000000
#define ColorBlanchedAlmond          0xFFFFEBCD
#define ColorBlue                    0xFF0000FF
#define ColorBlueViolet              0xFF8A2BE2
#define ColorBrown                   0xFFA52A2A
#define ColorBurlyWood               0xFFDEB887
#define ColorCadetBlue               0xFF5F9EA0
#define ColorChalk                   0xFFFFFF99
#define ColorChartreuse              0xFF7FFF00
#define ColorChocolate               0xFFD2691E
#define ColorCoral                   0xFFFF7F50
#define ColorCornflowerBlue          0xFF6495ED
#define ColorCornsilk                0xFFFFF8DC
#define ColorCrimson                 0xFFDC143C
#define ColorCyan                    0xFF00FFFF
#define ColorDarkBlue                0xFF00008B
#define ColorDarkBrown               0xFF663333
#define ColorDarkCrimson             0xFF993366
#define ColorDarkCyan                0xFF008B8B
#define ColorDarkGold                0xFFCC9933
#define ColorDarkGoldenrod           0xFFB8860B
#define ColorDarkGray                0xFFA9A9A9
#define ColorDarkGreen               0xFF006400
#define ColorDarkKhaki               0xFFBDB76B
#define ColorDarkMagenta             0xFF8B008B
#define ColorDarkOliveGreen          0xFF556B2F
#define ColorDarkOrange              0xFFFF8C00
#define ColorDarkOrchid              0xFF9932CC
#define ColorDarkRed                 0xFF8B0000
#define ColorDarkSalmon              0xFFE9967A
#define ColorDarkSeaGreen            0xFF8FBC8B
#define ColorDarkSlateBlue           0xFF483D8B
#define ColorDarkSlateGray           0xFF2F4F4F
#define ColorDarkTurquoise           0xFF00CED1
#define ColorDarkViolet              0xFF9400D3
#define ColorDeepAzure               0xFF6633FF
#define ColorDeepPink                0xFFFF1493
#define ColorDeepPurple              0xFF330066
#define ColorDeepRiver               0xFF6600CC
#define ColorDeepRose                0xFFCC3399
#define ColorDeepSkyBlue             0xFF00BFFF
#define ColorDefault                 0
#define ColorDeepYellow              0xFFFFCC00
#define ColorDesertBlue              0xFF336699
#define ColorDimGray                 0xFF696969
#define ColorDodgerBlue              0xFF1E90FF
#define ColorDullGreen               0xFF99CC66
#define ColorEasterPurple            0xFFCC99FF
#define ColorFadeGreen               0xFF99CC99
#define ColorFirebrick               0xFFB22222
#define ColorFloralWhite             0xFFFFFAF0
#define ColorForestGreen             0xFF228B22
#define ColorGainsboro               0xFFDCDCDC
#define ColorGhostGreen              0xFFCCFFCC
#define ColorGhostWhite              0xFFF8F8FF
#define ColorGold                    0xFFFFD700
#define ColorGoldenrod               0xFFDAA520
#define ColorGrape                   0xFF663399
#define ColorGrassGreen              0xFF009933
#define ColorGray                    0xFF808080
#define ColorGreen                   0xFF008000
#define ColorGreenYellow             0xFFADFF2F
#define ColorHoneydew                0xFFF0FFF0
#define ColorHotPink                 0xFFFF69B4
#define ColorIndianRed               0xFFCD5C5C
#define ColorIndigo                  0xFF4B0082
#define ColorIvory                   0xFFFFFFF0
#define ColorKentuckyGreen           0xFF339966
#define ColorKhaki                   0xFFF0E68C
#define ColorLavender                0xFFE6E6FA
#define ColorLavenderBlush           0xFFFFF0F5
#define ColorLawnGreen               0xFF7CFC00
#define ColorLemonChiffon            0xFFFFFACD
#define ColorLightBlue               0xFFADD8E6
#define ColorLightCoral              0xFFF08080
#define ColorLightCyan               0xFFE0FFFF
#define ColorLightGoldenrod          0xFFEEDD82
#define ColorLightGoldenrodYellow    0xFFFAFAD2
#define ColorLightGray               0xFFD3D3D3
#define ColorLightGreen              0xFF90EE90
#define ColorLightOrange             0xFFFF9933
#define ColorLightPink               0xFFFFB6C1
#define ColorLightSalmon             0xFFFFA07A
#define ColorLightSeaGreen           0xFF20B2AA
#define ColorLightSkyBlue            0xFF87CEFA
#define ColorLightSlateGray          0xFF778899
#define ColorLightSteelBlue          0xFFB0C4DE
#define ColorLightViolet             0xFFFF99FF
#define ColorLightYellow             0xFFFFFFE0
#define ColorLime                    0xFF00FF00
#define ColorLimeGreen               0xFF32CD32
#define ColorLinen                   0xFFFAF0E6
#define ColorMagenta                 0xFFFF00FF
#define ColorMaroon                  0xFF800000
#define ColorMartianGreen            0xFF99CC33
#define ColorMediumAquamarine        0xFF66CDAA
#define ColorMediumBlue              0xFF0000CD
#define ColorMediumOrchid            0xFFBA55D3
#define ColorMediumPurple            0xFF9370DB
#define ColorMediumSeaGreen          0xFF3CB371
#define ColorMediumSlateBlue         0xFF7B68EE
#define ColorMediumSpringGreen       0xFF00FA9A
#define ColorMediumTurquoise         0xFF48D1CC
#define ColorMediumVioletRed         0xFFC71585
#define ColorMidnightBlue            0xFF191970
#define ColorMintCream               0xFFF5FFFA
#define ColorMistyRose               0xFFFFE4E1
#define ColorMoccasin                0xFFFFE4B5
#define ColorMoonGreen               0xFFCCFF66
#define ColorMossGreen               0xFF336666
#define ColorNavajoWhite             0xFFFFDEAD
#define ColorNavy                    0xFF000080
#define ColorOceanGreen              0xFF669999
#define ColorOldLace                 0xFFFDF5E6
#define ColorOlive                   0xFF808000
#define ColorOliveDrab               0xFF6B8E23
#define ColorOrange                  0xFFFFA500
#define ColorOrangeRed               0xFFFF4500
#define ColorOrchid                  0xFFDA70D6
#define ColorPaleGoldenrod           0xFFEEE8AA
#define ColorPaleGreen               0xFF98FB98
#define ColorPaleTurquoise           0xFFAFEEEE
#define ColorPaleVioletRed           0xFFDB7093
#define ColorPaleYellow              0xFFFFFFCC
#define ColorPapayaWhip              0xFFFFEFD5
#define ColorPeachPuff               0xFFFFDAB9
#define ColorPeru                    0xFFCD853F
#define ColorPink                    0xFFFFC0CB
#define ColorPlum                    0xFFDDA0DD
#define ColorPowderBlue              0xFFB0E0E6
#define ColorPurple                  0xFF800080
#define ColorRed                     0xFFFF0000
#define ColorRosyBrown               0xFFBC8F8F
#define ColorRoyalBlue               0xFF4169E1
#define ColorSaddleBrown             0xFF8B4513
#define ColorSalmon                  0xFFFA8072
#define ColorSand                    0xFFFFCC99
#define ColorSandyBrown              0xFFF4A460
#define ColorSeaGreen                0xFF2E8B57
#define ColorSeaShell                0xFFFFF5EE
#define ColorSienna                  0xFFA0522D
#define ColorSilver                  0xFFC0C0C0
#define ColorSkyBlue                 0xFF87CEEB
#define ColorSlateBlue               0xFF6A5ACD
#define ColorSlateGray               0xFF708090
#define ColorSnow                    0xFFFFFAFA
#define ColorSpringGreen             0xFF00FF7F
#define ColorSteelBlue               0xFF4682B4
#define ColorTan                     0xFFD2B48C
#define ColorTeal                    0xFF008080
#define ColorThistle                 0xFFD8BFD8
#define ColorTomato                  0xFFFF6347
#define ColorTransparent             0xFFFFFFFE
#define ColorTropicalPink            0xFFFF6666
#define ColorTurquoise               0xFF40E0D0
#define ColorViolet                  0xFFEE82EE
#define ColorVioletRed               0xFFD02090
#define ColorWalnut                  0xFF663300
#define ColorWheat                   0xFFF5DEB3
#define ColorWhite                   0xFFFFFFFF
#define ColorWhiteSmoke              0xFFF5F5F5
#define ColorYellow                  0xFFFFFF00
#define ColorYellowGreen             0xFF9ACD32

// No data symbol
#define RMC_NO_DATA     0    // 0xC521974F - this only works in VB

// Control styles
#define RMC_CTRLSTYLEFLAT           0
#define RMC_CTRLSTYLEFLATSHADOW     1
#define RMC_CTRLSTYLE3D             2
#define RMC_CTRLSTYLE3DLIGHT        3
#define RMC_CTRLSTYLEIMAGE          4
#define RMC_CTRLSTYLEIMAGETILED     5

//Chart types
#define RMC_BARSINGLE              1
#define RMC_BARGROUP               2
#define RMC_BARSTACKED             3
#define RMC_BARSTACKED100          4
#define RMC_FLOATINGBAR            5
#define RMC_FLOATINGBARGROUP       6
#define RMC_LINE                   21
#define RMC_AREA                   22
#define RMC_LINE_INDEXED           23
#define RMC_AREA_INDEXED           24
#define RMC_AREA_STACKED           25
#define RMC_AREA_STACKED100        26
#define RMC_LINE_STACKED           27
#define RMC_LINE_STACKED100        28
#define RMC_VOLUMEBAR              31
#define RMC_HIGHLOW                41
#define RMC_GRIDLESS               51
#define RMC_XYCHART                70
#define RMC_GRIDBASED              10  // only for tRMC_INFO

// BarSeries styles
#define RMC_BAR_FLAT                1
#define RMC_BAR_FLAT_GRADIENT1      2
#define RMC_BAR_FLAT_GRADIENT2      3
#define RMC_BAR_HOVER               4
#define RMC_COLUMN_FLAT             5
#define RMC_BAR_3D                  6
#define RMC_BAR_3D_GRADIENT         7
#define RMC_COLUMN_3D               8
#define RMC_COLUMN_3D_GRADIENT      9
#define RMC_COLUMN_FLUTED           10

// LineSeries styles
#define RMC_LINE_FLAT                21
#define RMC_LINE_FLAT_DOT            19
#define RMC_LINE_FLAT_DASH           18
#define RMC_LINE_FLAT_DASHDOT        17
#define RMC_LINE_FLAT_DASHDOTDOT     16
#define RMC_LINE_FASTLINE            15
#define RMC_LINE_CABLE               22
#define RMC_LINE_3D                  23
#define RMC_LINE_3D_GRADIENT         24
#define RMC_AREA_FLAT                25
#define RMC_AREA_FLAT_GRADIENT_V     26
#define RMC_AREA_FLAT_GRADIENT_H     27
#define RMC_AREA_FLAT_GRADIENT_C     28
#define RMC_AREA_3D                  29
#define RMC_AREA_3D_GRADIENT_V       30
#define RMC_AREA_3D_GRADIENT_H       31
#define RMC_AREA_3D_GRADIENT_C       32
#define RMC_LINE_FLAT_SHADOW         33
#define RMC_LINE_CABLE_SHADOW        34
#define RMC_LINE_SYMBOLONLY          35

// HighLowSeries styles
#define RMC_OHLC                     1
#define RMC_CANDLESTICK              2

// GridlessSeries styles
#define RMC_PIE_FLAT                 51
#define RMC_PIE_GRADIENT             52
#define RMC_PIE_3D                   53
#define RMC_PIE_3D_GRADIENT          54
#define RMC_DONUT_FLAT               55
#define RMC_DONUT_GRADIENT           56
#define RMC_DONUT_3D                 57
#define RMC_DONUT_3D_GRADIENT        58
#define RMC_PYRAMIDE                 59
#define RMC_PYRAMIDE3                60

// XY-Series styles
#define RMC_XY_LINE                  70
#define RMC_XY_LINE_DOT              69
#define RMC_XY_LINE_DASH             68
#define RMC_XY_LINE_DASHDOT          67
#define RMC_XY_LINE_DASHDOTDOT       66
#define RMC_XY_FASTLINE              65
#define RMC_XY_SYMBOL                71
#define RMC_XY_LINESYMBOL            RMC_XY_LINE
#define RMC_XY_CABLE                 73
#define RMC_XY_CABLESYMBOL           RMC_XY_CABLE
#define RMC_XY_AREA                  75

// Pie and Donut alignments
#define RMC_FULL                     1
#define RMC_HALF_TOP                 2
#define RMC_HALF_RIGHT               3
#define RMC_HALF_BOTTOM              4
#define RMC_HALF_LEFT                5

// Line styles for data- and label axes
#define RMC_LINESTYLESOLID         0
#define RMC_LINESTYLEDASH          1
#define RMC_LINESTYLEDOT           2
#define RMC_LINESTYLEDASHDOT       3
#define RMC_LINESTYLENONE          6

// BiColor mode for data- and label axes
#define RMC_BICOLOR_NONE           0
#define RMC_BICOLOR_DATAAXIS       1
#define RMC_BICOLOR_LABELAXIS      2
#define RMC_BICOLOR_BOTH           3  

// Orientation of the data- and label axes
#define RMC_DATAAXISLEFT           1
#define RMC_DATAAXISRIGHT          2
#define RMC_DATAAXISTOP            3
#define RMC_DATAAXISBOTTOM         4
#define RMC_LABELAXISLEFT          5
#define RMC_LABELAXISRIGHT         6
#define RMC_LABELAXISTOP           7
#define RMC_LABELAXISBOTTOM        8
#define RMC_YAXISLEFT              9
#define RMC_YAXISRIGHT             10
#define RMC_XAXISTOP               11
#define RMC_XAXISBOTTOM            12

// Text alignments for the label axis
#define RMC_TEXTCENTER             0
#define RMC_TEXTLEFT               1
#define RMC_TEXTRIGHT              2
#define RMC_TEXTDOWNWARD           3
#define RMC_TEXTUPWARD             4

// LineStyles for line charts
#define RMC_LSTYLE_LINE              1
#define RMC_LSTYLE_SPLINE            2
#define RMC_LSTYLE_STAIR             3
#define RMC_LSTYLE_LINE_AREA         4 // Draws a line and a transparent area
#define RMC_LSTYLE_SPLINE_AREA       5 // Draws a spline and a transparent area
#define RMC_LSTYLE_STAIR_AREA        6 // Draws a stair and a transparent area

// Symbols for line series
// Symbols
#define RMC_SYMBOL_NONE               0
#define RMC_SYMBOL_BULLET             21
#define RMC_SYMBOL_ROUND              1
#define RMC_SYMBOL_DIAMOND            2
#define RMC_SYMBOL_SQUARE             3
#define RMC_SYMBOL_STAR               4
#define RMC_SYMBOL_ARROW_DOWN         5
#define RMC_SYMBOL_ARROW_UP           6
#define RMC_SYMBOL_POINT              7
#define RMC_SYMBOL_CIRCLE             8
#define RMC_SYMBOL_RECTANGLE          9
#define RMC_SYMBOL_CROSS              10
#define RMC_SYMBOL_BULLET_SMALL       22
#define RMC_SYMBOL_ROUND_SMALL        11
#define RMC_SYMBOL_DIAMOND_SMALL      12
#define RMC_SYMBOL_SQUARE_SMALL       13
#define RMC_SYMBOL_STAR_SMALL         14
#define RMC_SYMBOL_ARROW_DOWN_SMALL   15
#define RMC_SYMBOL_ARROW_UP_SMALL     16
#define RMC_SYMBOL_POINT_SMALL        17
#define RMC_SYMBOL_CIRCLE_SMALL       18
#define RMC_SYMBOL_RECTANGLE_SMALL    19
#define RMC_SYMBOL_CROSS_SMALL        20

// Hatchmodes
#define RMC_HATCHBRUSH_OFF            0
#define RMC_HATCHBRUSH_ON             1
#define RMC_HATCHBRUSH_ONPRINTING     2


// Orientation for the legend
#define RMC_LEGEND_NONE            -1
#define RMC_LEGEND_TOP             1
#define RMC_LEGEND_LEFT            2
#define RMC_LEGEND_RIGHT           3
#define RMC_LEGEND_BOTTOM          4
#define RMC_LEGEND_UL              5
#define RMC_LEGEND_UR              6
#define RMC_LEGEND_LL              7
#define RMC_LEGEND_LR              8
#define RMC_LEGEND_ONVLABELS       9
#define RMC_LEGEND_CUSTOM          10
#define RMC_LEGEND_CUSTOM_TOP      11
#define RMC_LEGEND_CUSTOM_LEFT     12
#define RMC_LEGEND_CUSTOM_RIGHT    13
#define RMC_LEGEND_CUSTOM_BOTTOM   14
#define RMC_LEGEND_CUSTOM_UL       15
#define RMC_LEGEND_CUSTOM_UR       16
#define RMC_LEGEND_CUSTOM_LL       17
#define RMC_LEGEND_CUSTOM_LR       18
#define RMC_LEGEND_CUSTOM_CENTER   19
#define RMC_LEGEND_CUSTOM_CR       20
#define RMC_LEGEND_CUSTOM_CL       21

// Legendstyle
#define RMC_LEGENDNORECT           1
#define RMC_LEGENDRECT             2
#define RMC_LEGENDRECTSHADOW       3
#define RMC_LEGENDROUNDRECT        4
#define RMC_LEGENDROUNDRECTSHADOW  5


// Errors 
#define RMC_ERROR_MAXINST          -1
#define RMC_ERROR_MAXREGION        -2
#define RMC_ERROR_MAXSERIES        -3
#define RMC_ERROR_ALLOC            -4
#define RMC_ERROR_NODATA           -5
#define RMC_ERROR_CTRLID           -6
#define RMC_ERROR_SERIESINDEX      -7
#define RMC_ERROR_CREATEBITMAP     -8
#define RMC_ERROR_WRONGREGION      -9
#define RMC_ERROR_PARENTHANDLE     -10
#define RMC_ERROR_CREATEWINDOW     -11
#define RMC_ERROR_INIGDIP          -12
#define RMC_ERROR_PRINT            -13
#define RMC_ERROR_NOGDIP           -14  
#define RMC_ERROR_RMCFILE          -15
#define RMC_ERROR_FILEFOUND        -16
#define RMC_ERROR_READLINES        -17
#define RMC_ERROR_XYAXIS           -18
#define RMC_ERROR_LEGENDTEXT       -19
#define RMC_ERROR_EMF              -20
#define RMC_ERROR_NODATA_COUNT     -21
#define RMC_ERROR_NODATA_ZERO      -22
#define RMC_ERROR_NOCOLOR          -23
#define RMC_ERROR_CLIPBOARD        -24
#define RMC_ERROR_CBINFO           -25
#define RMC_ERROR_FILECREATE       -26
#define RMC_ERROR_DATAINDEX        -28
#define RMC_ERROR_AXISALIGNMENT    -29
#define RMC_ERROR_RANGE            -30
#define RMC_ERROR_WRONGSERIESTYPE  -31
#define RMC_ERROR_MAXCUSTOM        -50
#define RMC_ERROR_CUSTOMINDEX      -51
#define RMC_ERROR_LEGENDSIZE       1

// Options for Value labels
#define RMC_VLABEL_NONE            0
#define RMC_VLABEL_DEFAULT         1
#define RMC_VLABEL_PERCENT         5
#define RMC_VLABEL_ABSOLUTE        6
#define RMC_VLABEL_TWIN            7
#define RMC_VLABEL_LEGENDONLY      8
#define RMC_VLABEL_DEFAULT_NOZERO    11
#define RMC_VLABEL_PERCENT_NOZERO    15
#define RMC_VLABEL_ABSOLUTE_NOZERO   16
#define RMC_VLABEL_TWIN_NOZERO       17


#define RMC_MOUSEMOVE            0x200
#define RMC_LBUTTONDOWN          0x201 
#define RMC_LBUTTONUP            0x202
#define RMC_LBUTTONDBLCLK        0x203
#define RMC_RBUTTONDOWN          0x204
#define RMC_RBUTTONUP            0x205
#define RMC_RBUTTONDBLCLK        0x206
#define RMC_MBUTTONDOWN          0x207
#define RMC_MBUTTONUP            0x208
#define RMC_MBUTTONDBLCLK        0x209
#define RMC_SHIFTLBUTTONDOWN     0x20A
#define RMC_SHIFTLBUTTONUP       0x20B
#define RMC_SHIFTLBUTTONDBLCLK   0x20C
#define RMC_SHIFTRBUTTONDOWN     0x20D
#define RMC_SHIFTRBUTTONUP       0x20E
#define RMC_SHIFTRBUTTONDBLCLK   0x20F
#define RMC_SHIFTMBUTTONDOWN     0x210
#define RMC_SHIFTMBUTTONUP       0x211
#define RMC_SHIFTMBUTTONDBLCLK   0x212
#define RMC_CTRLLBUTTONDOWN      0x213
#define RMC_CTRLLBUTTONUP        0x214
#define RMC_CTRLLBUTTONDBLCLK    0x215
#define RMC_CTRLRBUTTONDOWN      0x216
#define RMC_CTRLRBUTTONUP        0x217
#define RMC_CTRLRBUTTONDBLCLK    0x218
#define RMC_CTRLMBUTTONDOWN      0x219
#define RMC_CTRLMBUTTONUP        0x21A
#define RMC_CTRLMBUTTONDBLCLK    0x21B

#define RMC_EMF          1
#define RMC_EMFPLUS      2
#define RMC_BMP          3


// Custom Objects
#define RMC_CO_TEXT            1
#define RMC_CO_BOX             2
#define RMC_CO_CIRCLE          3
#define RMC_CO_LINE            4
#define RMC_CO_IMAGE           5
#define RMC_CO_SYMBOL          6
#define RMC_CO_POLYGON         7


// Anchors for custom lines
#define RMC_ANCHOR_NONE           0
#define RMC_ANCHOR_ROUND          1
#define RMC_ANCHOR_BULLET         2
#define RMC_ANCHOR_ARROW_CLOSED   3
#define RMC_ANCHOR_ARROW_OPEN     4

// Line alignment for custom text
#define RMC_LINE_HORIZONTAL      0
#define RMC_LINE_UPWARD          1
#define RMC_LINE_DOWNWARD        3

// Styles for custom box/text
#define RMC_BOX_NONE                  0
#define RMC_BOX_FLAT                  1
#define RMC_BOX_ROUNDEDGE             2
#define RMC_BOX_RHOMBUS               3
#define RMC_BOX_GRADIENTH             4
#define RMC_BOX_GRADIENTV             5
#define RMC_BOX_3D                    6
#define RMC_BOX_FLAT_SHADOW           7
#define RMC_BOX_GRADIENTH_SHADOW      8
#define RMC_BOX_GRADIENTV_SHADOW      9
#define RMC_BOX_3D_SHADOW             10

// Styles for custom Circle
#define RMC_CIRCLE_FLAT               1
#define RMC_CIRCLE_BULLET             2

// Zoom mode 
#define RMC_ZOOM_DISABLE              0
#define RMC_ZOOM_EXTERNAL             1  // for gridbased series
#define RMC_ZOOM_INTERNAL             2  // for gridbased series
#define RMC_ZOOM_XY_EXTERNAL          3  // for XY-series
#define RMC_ZOOM_XY_INTERNAL          4  // for XY-series

// nChartType in tRMC_INFO holds one of these when in zoom- or magnifier-mode
#define RMC_ZOOM_MODE                 -99
#define RMC_MAGNIFIER_MODE            -98

// If you want to stamp your own watermark, put here 
// your individual watermark and properties for the watermark (WM). 
// See the help file for more informations.   
#define RMC_USERWM   ""                     // Your watermark
#define RMC_USERWMCOLOR   ColorBlack        // Color for the watermark
#define RMC_USERWMLUCENT   30               // Lucent factor between 1(=not visible) and 255(=opaque)
#define RMC_USERWMALIGN   RMC_TEXTCENTER    // Alignment for the watermark
#define RMC_USERFONTSIZE   0                // Fontsize; if 0: maximal size is used

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2
