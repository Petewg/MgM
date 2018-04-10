/*

  NUMBERS.PRG   Numeric and math functions

*/
#include "default.ch"


Function Crop(nMin, nValue, nMax)
/*
  "Crops" a value to make sure it falls between the minimum and maximum
  values.  Used primarily because I'm always reversing the functions min()
  and max() and messing things up.  Works on dates too.

  Either nMin or nMax may be omitted.
*/
  local nRet := nValue

  if nMin <> NIL
    nRet := max(nMin, nRet)
  endif

  if nMax <> NIL
    nRet := min(nMax, nRet)
  endif

Return(nRet)



Function CtoN(c, lBigEndian)
/*
  Converts a character binary representation of a number into a positive
  integer numeric.  Works on any length string, but two- or four- byte
  strings would be most common.

  By default, the string is processed in little-endian format (with the least
  significant digit first).  Setting lBigEndian to true will reverse this.

  See also: NtoC()

  Similar Clipper functions: BIN2I(), BIN2L(), BIN2W()
*/
  local n := 0, nMod := 1
  local x, nFrom := 1, nTo := len(c), nStep := 1

  default lBigEndian := .F.

  if lBigEndian
    nFrom := nTo
    nTo   := 1
    nStep := -1
  endif

  for x := nFrom to nTo step nStep
    n += asc(substr(c, x, 1)) * nMod
    nMod *= 256
  next

Return(n)



Function Factorial(n)
/*
  Returns the factorial (n!) of an integer.
*/
  local f := n
  local x, y := n - 1

  for x := y to 2 step -1
    f *= x
  next

Return(f)



Function HtoN(cHex)
/*
  Converts a two-character hex string to a number from 0-255.

  Example: HtoN("FF") -> 255
*/
  local cDigits := "0123456789ABCDEF"
  local n

  n := max(at(substr(cHex, 1, 1), cDigits) - 1, 0) * 16

  n += max(at(substr(cHex, 2, 1), cDigits) - 1, 0)

Return(n)



Function NtoC(nValue, nLen, lBigEndian)
/*
  Converts a positive integer into a binary character string.

  nLen determines the length of the resulting string and defaults to 2.

  By default, the string is created in little-endian format (with the least
  significant digit first).  Setting lBigEndian to true will reverse this.

  See also: CtoN()

  Similar Clipper functions: I2BIN(), L2BIN()
*/
  local nMod, x, c
  local cRet := ""

  default nLen := 2, ;
          lBigEndian := .F.

  nMod := 256 ^ (nLen - 1) // x ^ 0 = 1

  for x := 1 to nLen
    c := chr(int(nValue / nMod))
    if lBigEndian
      cRet += c
    else
      cRet := c + cRet
    endif
    nValue %= nMod
    nMod /= 256
  next

Return(cRet)



Function NtoH(n)
/*
  Converts a numeric byte value (0-255) into a 2-character hex string.

  Example: NtoH(255) -> "FF"
*/
  local cDigits := "0123456789ABCDEF"
  local cHex := substr(cDigits, int((n % 256) / 16) + 1, 1) + ;
                substr(cDigits, (n % 16) + 1, 1)

Return(cHex)



Function XFix(x, nDec)
/*
  "Fixes" a number with the correct number of decimal places.
  First, it is turned into a string with (nDec + 1) decimal places.  The
  extra decimal is truncated and the val() of that string is returned.

  nDec defaults to 2.
*/
  local cNum

  default nDec := 2

  cNum := ltrim(str(x, 15, nDec + 1))

  cNum := left(cNum, len(cNum) - iif(nDec > 0, 1, 2))

Return(val(cNum))



Function XRound(x, nDec)
/*
  A replacement for round() that apparently really works.
  Originally by Richard Fagen and retrieved from the CIS Clipper forum.

  nDec defaults to 2 decimal places.
*/
  local nExp, nMod := iif(x < 0, -.50001, .50001)

  default nDec := 2  // Default to 2 decimal places

  nExp := 10 ^ nDec
  x := int(x * nExp + nMod) / nExp

  // Give x the proper number of decimal places upon returning:

Return(XFix(x, nDec))

