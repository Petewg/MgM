/*
 * Copyright 2017 (C) P.Chornyj <myorg63@mail.ru>
 * Based on original work of John McNamara, jmcnamara@cpan.org
 *
 */

#define CELL( cell )		lxw_name_to_row(cell), lxw_name_to_col(cell)
#define COLS( cols )		lxw_name_to_col(cols), lxw_name_to_col_2(cols)
#define RANGE( range )	lxw_name_to_row(range), lxw_name_to_col(range), lxw_name_to_row_2(range), lxw_name_to_col_2(range)

/* Error codes from libxlsxwriter functions. */
/* No error. */
#define LXW_NO_ERROR										0

/* Memory error, failed to malloc() required memory. */
#define LXW_ERROR_MEMORY_MALLOC_FAILED				1

/* Error creating output xlsx file. Usually a permissions error. */
#define LXW_ERROR_CREATING_XLSX_FILE				2

/* Error encountered when creating a tmpfile during file assembly. */
#define LXW_ERROR_CREATING_TMPFILE					3

/* Zlib error with a file operation while creating xlsx file. */
#define LXW_ERROR_ZIP_FILE_OPERATION				4

/* Zlib error when adding sub file to xlsx file. */
#define LXW_ERROR_ZIP_FILE_ADD						5

/* Zlib error when closing xlsx file. */
#define LXW_ERROR_ZIP_CLOSE							6

/* NULL function parameter ignored. */
#define LXW_ERROR_NULL_PARAMETER_IGNORED			7

/* Function parameter validation error. */
#define LXW_ERROR_PARAMETER_VALIDATION				8

/* Worksheet name exceeds Excel's limit of 31 characters. */
#define LXW_ERROR_SHEETNAME_LENGTH_EXCEEDED		9

/* Worksheet name contains invalid Excel character: '[]:*?/\\' */
#define LXW_ERROR_INVALID_SHEETNAME_CHARACTER	10

/* Worksheet name is already in use. */
#define LXW_ERROR_SHEETNAME_ALREADY_USED			11

/* Parameter exceeds Excel's limit of 128 characters. */
#define LXW_ERROR_128_STRING_LENGTH_EXCEEDED		12

/* Parameter exceeds Excel's limit of 255 characters. */
#define LXW_ERROR_255_STRING_LENGTH_EXCEEDED		13

/* String exceeds Excel's limit of 32,767 characters. */
#define LXW_ERROR_MAX_STRING_LENGTH_EXCEEDED		14

/* Error finding internal string index. */
#define LXW_ERROR_SHARED_STRING_INDEX_NOT_FOUND 15

/* Worksheet row or column index out of range. */
#define LXW_ERROR_WORKSHEET_INDEX_OUT_OF_RANGE	16

/* Maximum number of worksheet URLs (65530) exceeded. */
#define LXW_ERROR_WORKSHEET_MAX_NUMBER_URLS_EXCEEDED 17

/* Couldn't read image dimensions or DPI. */
#define LXW_ERROR_IMAGE_DIMENSIONS					18

#define LXW_MAX_ERRNO                           19


/* Format underline values for format_set_underline(). */
/* Single underline */
#define LXW_UNDERLINE_SINGLE		1

/* Double underline */
#define LXW_UNDERLINE_DOUBLE		2

/* Single accounting underline */
#define LXW_UNDERLINE_SINGLE_ACCOUNTING	3

/* Double accounting underline */
#define LXW_UNDERLINE_DOUBLE_ACCOUNTING	4


/* Superscript and subscript values for format_set_font_script(). */
/* Superscript font */
#define LXW_FONT_SUPERSCRIPT		1

/* Subscript font */
#define LXW_FONT_SUBSCRIPT			2


/* Alignment values for format_set_align(). */
/* No alignment. Cell will use Excel's default for the data type */
#define LXW_ALIGN_NONE				0

/* Left horizontal alignment */
#define LXW_ALIGN_LEFT				1

/* Center horizontal alignment */
#define LXW_ALIGN_CENTER			2

/* Right horizontal alignment */
#define LXW_ALIGN_RIGHT				3

/* Cell fill horizontal alignment */
#define LXW_ALIGN_FILL				4

/* Justify horizontal alignment */
#define LXW_ALIGN_JUSTIFY			5

/* Center Across horizontal alignment */
#define LXW_ALIGN_CENTER_ACROSS	6

/* Left horizontal alignment */
#define LXW_ALIGN_DISTRIBUTED		7

/* Top vertical alignment */
#define LXW_ALIGN_VERTICAL_TOP	8

/* Bottom vertical alignment */
#define LXW_ALIGN_VERTICAL_BOTTOM		9

/* Center vertical alignment */
#define LXW_ALIGN_VERTICAL_CENTER		10

/* Justify vertical alignment */
#define LXW_ALIGN_VERTICAL_JUSTIFY		11

/* Distributed vertical alignment */
#define LXW_ALIGN_VERTICAL_DISTRIBUTED	12

#define LXW_DIAGONAL_BORDER_UP			1
#define LXW_DIAGONAL_BORDER_DOWN			2
#define LXW_DIAGONAL_BORDER_UP_DOWN		3

/* Predefined values for common colors. */
/* Black */
#define LXW_COLOR_BLACK				0x1000000
#define LXW_COLOR_BLUE				0x0000FF
#define LXW_COLOR_BROWN				0x800000
#define LXW_COLOR_CYAN				0x00FFFF
#define LXW_COLOR_GRAY				0x808080
#define LXW_COLOR_GREEN				0x008000
#define LXW_COLOR_LIME				0x00FF00
#define LXW_COLOR_MAGENTA			0xFF00FF
#define LXW_COLOR_NAVY				0x000080
#define LXW_COLOR_ORANGE			0xFF6600
#define LXW_COLOR_PINK				0xFF00FF
#define LXW_COLOR_PURPLE			0x800080
#define LXW_COLOR_RED				0xFF0000
#define LXW_COLOR_SILVER			0xC0C0C0
#define LXW_COLOR_WHITE				0xFFFFFF
#define LXW_COLOR_YELLOW			0xFFFF00

/* Pattern value for use with format_set_pattern(). */
/* Empty pattern */
#define LXW_PATTERN_NONE			0

/* Solid pattern */
#define LXW_PATTERN_SOLID			1

/* Medium gray pattern */
#define LXW_PATTERN_MEDIUM_GRAY	2

/* Dark gray pattern */
#define LXW_PATTERN_DARK_GRAY		3

/* Light gray pattern */
#define LXW_PATTERN_LIGHT_GRAY	4

/* Dark horizontal line pattern */
#define LXW_PATTERN_DARK_HORIZONTAL	5

/* Dark vertical line pattern */
#define LXW_PATTERN_DARK_VERTICAL	6

/* Dark diagonal stripe pattern */
#define LXW_PATTERN_DARK_DOWN		7

/* Reverse dark diagonal stripe pattern */
#define LXW_PATTERN_DARK_UP		8

/* Dark grid pattern */
#define LXW_PATTERN_DARK_GRID		9

/* Dark trellis pattern */
#define LXW_PATTERN_DARK_TRELLIS	10

/* Light horizontal Line pattern */
#define LXW_PATTERN_LIGHT_HORIZONTAL	11

/* Light vertical line pattern */
#define LXW_PATTERN_LIGHT_VERTICAL		12

/* Light diagonal stripe pattern */
#define LXW_PATTERN_LIGHT_DOWN	13

/* Reverse light diagonal stripe pattern */
#define LXW_PATTERN_LIGHT_UP		14

/* Light grid pattern */
#define LXW_PATTERN_LIGHT_GRID	15

/* Light trellis pattern */
#define LXW_PATTERN_LIGHT_TRELLIS		16

/* 12.5% gray pattern */
#define LXW_PATTERN_GRAY_125		17

/* 6.25% gray pattern */
#define LXW_PATTERN_GRAY_0625		18


/* Cell border styles for use with format_set_border(). */
/* No border */
#define LXW_BORDER_NONE		0

/* Thin border style */
#define LXW_BORDER_THIN		1

/* Medium border style */
#define LXW_BORDER_MEDIUM	2

/* Dashed border style */
#define LXW_BORDER_DASHED	3

/* Dotted border style */
#define LXW_BORDER_DOTTED	4

/* Thick border style */
#define LXW_BORDER_THICK	5

/* Double border style */
#define LXW_BORDER_DOUBLE	6

/* Hair border style */
#define LXW_BORDER_HAIR		7

/* Medium dashed border style */
#define LXW_BORDER_MEDIUM_DASHED		8

/* Dash-dot border style */
#define LXW_BORDER_DASH_DOT			9

/* Medium dash-dot border style */
#define LXW_BORDER_MEDIUM_DASH_DOT	10

/* Dash-dot-dot border style */
#define LXW_BORDER_DASH_DOT_DOT		11

/* Medium dash-dot-dot border style */
#define LXW_BORDER_MEDIUM_DASH_DOT_DOT	12

/* Slant dash-dot border style */
#define LXW_BORDER_SLANT_DASH_DOT	13
