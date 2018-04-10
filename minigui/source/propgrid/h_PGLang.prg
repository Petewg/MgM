/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

   "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2012, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
     Copyright 2001-2009 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/

#include "minigui.ch"

*------------------------------------------------------------------------------*
Procedure InitPGMessages
*------------------------------------------------------------------------------*
#ifdef _MULTILINGUAL_
   Local cLang
#endif

// PropGrid MESSAGES (ENGLISH DEFAULT)

_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }

_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

#ifdef _MULTILINGUAL_

// LANGUAGE IS NOT SUPPORTED BY hb_langSelect() FUNCTION

IF _HMG_LANG_ID == 'FI'      // FINNISH
   cLang := 'FI'
ELSE
   cLang := Upper( Left( Set ( _SET_LANGUAGE ), 2 ) )
ENDIF

do case

case cLang == "CS" /*.OR. cLang == "CSWIN"*/
/////////////////////////////////////////////////////////////
// CZECH
////////////////////////////////////////////////////////////

// PropGrid MESSAGES

_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }
/*
_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", :"Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/
/////////////////////////////////////////////////////////////
// CROATIAN
////////////////////////////////////////////////////////////
case cLang == "HR" /*.OR. cLang == "HR852"*/  // Croatian

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/
case cLang == "EU"  // Basque
/////////////////////////////////////////////////////////////
// BASQUE
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", :"Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "FR"        // French
/////////////////////////////////////////////////////////////
// FRENCH
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case /*cLang == "DEWIN" .OR.*/ cLang == "DE"  // German
/////////////////////////////////////////////////////////////
// GERMAN
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "IT"        // Italian
/////////////////////////////////////////////////////////////
// ITALIAN
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "PL" /*.OR. cLang == "PLWIN" .OR. cLang == "PL852" .OR. cLang == "PLISO" .OR. cLang == "PLMAZ"*/  // Polish
/////////////////////////////////////////////////////////////
// POLISH
////////////////////////////////////////////////////////////

// PropGrid MESSAGES

_HMG_PGLangButton := { "Akceptuj"   ,;
                       "Pomoc"    ,;
                       "Rezygnuj" ,;
                       "OK"      ,;
                       "Zapisz"   }

_HMG_PGLangError  := { "Property Item typu: "                     ,;
                       " B≥Ídnie zdefiniowana."                          ,;
                       "Property Item ID podwÛjnie zdefiniowana"         ,;
                       "Property wartoúÊ dla "                      ,;
                       "Property InputMask dla "                  ,;
                       "Property Data dla "                       ,;
                       "Item nie jest typu Category!"            ,;
                       "Category "                                ,;
                       " nie znaleziono!"                              ,;
                       "Property Item ID "                        ,;
                       " podwÛjnie zdefiniowano."+CRLF+" Item nie zosta≥ dodany"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Czy jesteú pewny ?' , "Nie zdefiniowano zbioru do zapisu", "B≥πd", "Ostrzerzenie" }

_HMG_PGEncodingXml := "ISO-8859-2"


case cLang == "PT"        // Portuguese
/////////////////////////////////////////////////////////////
// PORTUGUESE
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "RU" /*.OR. cLang == "RUWIN" .OR. cLang == "RU866" .OR. cLang == "RUKOI8"*/  // Russian
/////////////////////////////////////////////////////////////
// RUSSIAN
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "UK" .OR. cLang == "UA" /*.OR. cLang == "UAWIN" .OR. cLang == "UA866"*/  // Ukrainian
/////////////////////////////////////////////////////////////
// UKRAINIAN
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "ES" /*.OR. cLang == "ESWIN"*/  // Spanish
/////////////////////////////////////////////////////////////
// SPANISH
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "FI"        // Finnish
///////////////////////////////////////////////////////////////////////
// FINNISH
///////////////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "NL"        // Dutch
/////////////////////////////////////////////////////////////
// DUTCH
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case  cLang == "SL" /*.OR. cLang == "SLWIN" .OR. cLang == "SLISO" .OR. cLang == "SL852" .OR. cLang == "SL437"*/ // Slovenian
/////////////////////////////////////////////////////////////
// SLOVENIAN
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "SK" /*.OR. cLang == "SKWIN"*/  // Slovak
/////////////////////////////////////////////////////////////
// SLOVAK
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "HU" /*.OR. cLang == "HUWIN"*/  // Hungarian
/////////////////////////////////////////////////////////////
// HUNGARIAN
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "EL" /*.OR. cLang == "ELWIN"*/  // Greek - Ellinika
/////////////////////////////////////////////////////////////
// GREEK - ≈ÀÀ«Õ… ¡ - EL
/////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

case cLang == "BG" /*.OR. cLang == "BGWIN" .OR. cLang == "BG866"*/ // Bulgarian
/////////////////////////////////////////////////////////////
// BULGARIAN
////////////////////////////////////////////////////////////

// PropGrid MESSAGES
/*
_HMG_PGLangButton := { "Apply"   ,;
                       "Help"    ,;
                       "Cancel"  ,;
                       "OK"      ,;
                       "Save"    }

_HMG_PGLangError  := { "Property Item type: "                     ,;
                       " wrong defined."                          ,;
                       "Property Item ID double defined."         ,;
                       "Property Value for "                      ,;
                       "Property InputMask for "                  ,;
                       "Property Data for "                       ,;
                       "Item is not type of Category!"            ,;
                       "Category "                                ,;
                       " not found!"                              ,;
                       "Property Item ID "                        ,;
                       " double defined."+CRLF+" Not added Item"  ,;
                       "Invalid Entry"                            }


_HMG_PGLangMessage := { 'Are you sure ?' , "No File to save", "Error", "Warning" }

_HMG_PGEncodingXml := "UTF-8"

*/

endcase

#endif

Return
