/*
 * Locale Information
 * Constants defined: https://msdn.microsoft.com/en-us/library/windows/desktop/dd464799(v=vs.85).aspx
 */

#define LOCALE_ILANGUAGE 0x00000001				//LANGID in hexadecimal digits
#define LOCALE_SLANGUAGE 0x00000002				//Full localized name of the language
#define LOCALE_SENGLANGUAGE 0x00001001			//Full English U.S. name of the language ISO Standard 639
#define LOCALE_SABBREVLANGNAME 0x00000003		//Abbreviated name of the language, ISO Standard 639
#define LOCALE_SNATIVELANGNAME 0x00000004		//Native name of the language
#define LOCALE_ICOUNTRY 0x00000005				//Country code, based on international phone codes
#define LOCALE_SCOUNTRY 0x00000006				//The full localized name of the country.
#define LOCALE_SENGCOUNTRY 0x00001002			//The full English U.S. name of the country.
#define LOCALE_SABBREVCTRYNAME 0x00000007		//Abbreviated name of the country ISO Standard 3166.
#define LOCALE_SNATIVECTRYNAME 0x00000008		//Native name of the country.
#define LOCALE_IDEFAULTLANGUAGE 0x00000009		//LANGID for the principal language spoken in this locale.
#define LOCALE_IDEFAULTCOUNTRY 0x0000000a		//Country code for the principal country in this locale.
#define LOCALE_IDEFAULTCODEPAGE 0x0000000b		//OEM code page associated with the country.
#define LOCALE_SLIST 0x0000000c					//Characters used to separate list items.
#define LOCALE_IMEASURE 0x0000000d				//0 for metric system (S.I.) and 1 for the U.S.
#define LOCALE_SDECIMAL 0x0000000e				//Decimal separator
#define LOCALE_STHOUSAND 0x0000000f				//Thousand separator
#define LOCALE_SGROUPING 0x00000010				//Sizes for each group of digits to the left of the decimal.
#define LOCALE_IDIGITS 0x00000011				//Number of fractional digits
#define LOCALE_ILZERO 0x00000012				//Leading zeros: 0 means use no leading zeros; 1 means use leading zeros.
#define LOCALE_INEGNUMBER 0x00001010			//Negative number mode
#define LOCALE_SNATIVEDIGITS 0x00000013			//Ten characters equivalent of the ASCII 0-9.
#define LOCALE_SCURRENCY 0x00000014				//Local monetary symbol
#define LOCALE_SINTLSYMBOL 0x00000015			//International monetary symbol ISO 4217.
#define LOCALE_SMONDECIMALSEP 0x00000016		//Monetary decimal separator
#define LOCALE_SMONTHOUSANDSEP 0x00000017		//Monetary thousand separator
#define LOCALE_SMONGROUPING 0x00000018			//Monetary grouping, see:LOCALE_SGROUPING
#define LOCALE_ICURRDIGITS 0x00000019			//# local monetary digits
#define LOCALE_IINTLCURRDIGITS 0x0000001a		//# intl monetary digits
#define LOCALE_ICURRENCY 0x0000001b				//Positive currency mode
#define LOCALE_INEGCURR 0x0000001c				//Negative currency mode
#define LOCALE_SDATE 0x0000001d					//Date separator
#define LOCALE_STIME 0x0000001e					//Time separator
#define LOCALE_SSHORTDATE 0x0000001f			//Short date format string
#define LOCALE_SLONGDATE 0x00000020				//Long date format string
#define LOCALE_STIMEFORMAT 0x00001003			//Time format string
#define LOCALE_IDATE 0x00000021					//Short date format, 0 M-D-Y,1 D-M-Y,2 Y-M-D
#define LOCALE_ILDATE 0x00000022				//Long date format, 0 M-D-Y,1 D-M-Y,2 Y-M-D
#define LOCALE_ITIME 0x00000023					//Time format, 0 AM/PM 12-hr format, 1 24-hr format
#define LOCALE_ITIMEMARKPOSN 0x00001005			//Specifier indicating whether the time marker string (AM or PM) precedes or follows the time string.
#define LOCALE_ICENTURY 0x00000024				//Use full 4-digit century, 0 Two digit.1 Full century
#define LOCALE_ITLZERO 0x00000025				//Leading zeros in time field, 0 No , 1 yes
#define LOCALE_IDAYLZERO 0x00000026				//Leading zeros in day field, 0 No , 1 yes
#define LOCALE_IMONLZERO 0x00000027				//Leading zeros in month field, 0 No , 1 yes
#define LOCALE_S1159 0x00000028					//AM designator
#define LOCALE_S2359 0x00000029					//PM designator
#define LOCALE_SDAYNAME1 0x0000002a				//Long name for Monday
#define LOCALE_SDAYNAME2 0x0000002b				//Long name for Tuesday
#define LOCALE_SDAYNAME3 0x0000002c				//Long name for Wednesday
#define LOCALE_SDAYNAME4 0x0000002d				//Long name for Thursday
#define LOCALE_SDAYNAME5 0x0000002e				//Long name for Friday
#define LOCALE_SDAYNAME6 0x0000002f				//Long name for Saturday
#define LOCALE_SDAYNAME7 0x00000030				//Long name for Sunday
#define LOCALE_SABBREVDAYNAME1 0x00000031		//Abbreviated name for Monday
#define LOCALE_SABBREVDAYNAME2 0x00000032		//Abbreviated name for Tuesday
#define LOCALE_SABBREVDAYNAME3 0x00000033		//Abbreviated name for Wednesday
#define LOCALE_SABBREVDAYNAME4 0x00000034		//Abbreviated name for Thursday
#define LOCALE_SABBREVDAYNAME5 0x00000035		//Abbreviated name for Friday
#define LOCALE_SABBREVDAYNAME6 0x00000036		//Abbreviated name for Saturday
#define LOCALE_SABBREVDAYNAME7 0x00000037		//Abbreviated name for Sunday
#define LOCALE_SMONTHNAME1 0x00000038			//Long name for January
#define LOCALE_SMONTHNAME2 0x00000039			//Long name for February
#define LOCALE_SMONTHNAME3 0x0000003a			//Long name for March
#define LOCALE_SMONTHNAME4 0x0000003b			//Long name for April
#define LOCALE_SMONTHNAME5 0x0000003c			//Long name for May
#define LOCALE_SMONTHNAME6 0x0000003d			//Long name for June
#define LOCALE_SMONTHNAME7 0x0000003e			//Long name for July
#define LOCALE_SMONTHNAME8 0x0000003f			//Long name for August
#define LOCALE_SMONTHNAME9 0x00000040			//Long name for September
#define LOCALE_SMONTHNAME10 0x00000041			//Long name for October
#define LOCALE_SMONTHNAME11 0x00000042			//Long name for November
#define LOCALE_SMONTHNAME12 0x00000043			//Long name for December
#define LOCALE_SMONTHNAME13 0x0000100e			//Native long name for 13th month, if it exists.
#define LOCALE_SABBREVMONTHNAME1 0x00000044		//Abbreviated name for January
#define LOCALE_SABBREVMONTHNAME2 0x00000045		//Abbreviated name for February
#define LOCALE_SABBREVMONTHNAME3 0x00000046		//Abbreviated name for March
#define LOCALE_SABBREVMONTHNAME4 0x00000047		//Abbreviated name for April
#define LOCALE_SABBREVMONTHNAME5 0x00000048		//Abbreviated name for May
#define LOCALE_SABBREVMONTHNAME6 0x00000049		//Abbreviated name for June
#define LOCALE_SABBREVMONTHNAME7 0x0000004a		//Abbreviated name for July
#define LOCALE_SABBREVMONTHNAME8 0x0000004b		//Abbreviated name for August
#define LOCALE_SABBREVMONTHNAME9 0x0000004c		//Abbreviated name for September
#define LOCALE_SABBREVMONTHNAME10 0x0000004d	//Abbreviated name for October
#define LOCALE_SABBREVMONTHNAME11 0x0000004e	//Abbreviated name for November
#define LOCALE_SABBREVMONTHNAME12 0x0000004f	//Abbreviated name for December
#define LOCALE_SABBREVMONTHNAME13 0x0000100f	//Native abbreviated name for 13th month, if it exists.

#define LOCALE_SPOSITIVESIGN 0x00000050			//Localized string value for the positive sign for the locale.
#define LOCALE_SNEGATIVESIGN 0x00000051			//String value for the negative sign
#define LOCALE_IPOSSIGNPOSN 0x00000052			//Formatting index for positive values.
#define LOCALE_INEGSIGNPOSN 0x00000053			//Formatting index for the negative sign in currency values. 
#define LOCALE_IPOSSYMPRECEDES 0x00000054		//Position of the monetary symbol in a positive monetary value.
#define LOCALE_IPOSSEPBYSPACE 0x00000055		//Separation of monetary symbol in a positive monetary value.
#define LOCALE_INEGSYMPRECEDES 0x00000056		//Position of the monetary symbol in a negative monetary value.
#define LOCALE_INEGSEPBYSPACE 0x00000057 		//Separation of monetary symbol in a negative monetary value.

#define LOCALE_IDIGITSUBSTITUTION 0x00001014	//The shape of digits.
