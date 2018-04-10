/*
 * .Exe to .C (Pcode) Harbour Recover Code
 *
 * Copyright 2008-2009 Arcangelo Molinaro <arcangelo.molinaro@fastwebnet.it>
 * Donated to Public Domain.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

#include "minigui.ch"

FUNCTION MAIN
 LOAD WINDOW DECOMPILER
 CENTER WINDOW DECOMPILER
 ACTIVATE WINDOW DECOMPILER
RETURN NIL

function E2CHD
Local cFileName:="", aReturn:={},aPrgName:="",cPrgName:=""
Local aStringa:={},cReturn:="",aLatest:={},cValue1:="",cValue2:=""
Local cFuncName:="", cFuncScope:="" ,aFuncName:={},nFuncAdr:=0
Local BaseMemory:=0, Offset:=0, aTrans:={},cTrans,nStartReadBufferAddress:=0
Local RvaDataSection:=0,RvaCodeSection:=0, VaDataSection:=0,VaCodeSection:=0
Local OffsetDataSection:=0,OffsetCodeSection:=0
Local nLen:=0,nLen1:=0,I:=0
Local aGlobalByteCode:={},aByteCodeFunc:={},aReturnByteCodeFunc:={}
Local j:=0,nTime:=0,aComodo:={},OffsetImageBase:=0
Local aSaddress:={},nSectionAlignement:=0,nFileAlignement:=0
Local cEndReadFunc:="",DataEntryPoint:=0,OffsetOfEntryPoint:=0
Local flag:=.t., q:=1,cNumero:="",nNumero:=0,cPcodeFile:=""
Local aAddrName:={},aScopeFunc:={},aCodeFunc:={},aNullFunc:={},aNameFunc:={}

DECLARE WINDOW DECOMPILER
SET DECIMALS TO 0
SET DATE BRITISH
 cFilename:=HBChoose_File()
   if empty(cFilename)
      return nil
   endif
 cReturn:=HBPeFileCheck(cFileName)
 IF (cReturn<>"S_OK") 
     MsgInfo("Check Failed - Not a PE file","EXIT PROGRAM")
     return nil
 ENDIF
 aSaddress         := HBLoadBasicAddresses(cFilename)
 BaseMemory        := asAddress[1]
 RVaCodeSection    := asAddress[2]
 RVaDataSection    := asAddress[3]
 nSectionAlignement:= asAddress[4]
 nFileAlignement   := asAddress[5]
 VaCodeSection     := asAddress[6]
 VaDataSection     := asAddress[7]
 DataEntryPoint    := asAddress[8]
 OffsetImageBase   := asAddress[9]
 OffsetCodeSection := asAddress[10]
 OffsetDataSection := asAddress[11]
 OffsetOfEntryPoint:= asAddress[12]

 aadd(aComodo,"0x"+;
   IF(Empty( DecToHexa(asAddress[13]) ),"00",IF(LEN(DecToHexa(asAddress[13]))<2,"0"+DecToHexa(asAddress[13]),DecToHexa(asAddress[13])))+;
   IF(Empty( DecToHexa(asAddress[14]) ),"00",IF(LEN(DecToHexa(asAddress[14]))<2,"0"+DecToHexa(asAddress[14]),DecToHexa(asAddress[14])))+;
   IF(Empty( DecToHexa(asAddress[15]) ),"00",IF(LEN(DecToHexa(asAddress[15]))<2,"0"+DecToHexa(asAddress[15]),DecToHexa(asAddress[15])))+;
   IF(Empty( DecToHexa(asAddress[16]) ),"00",IF(LEN(DecToHexa(asAddress[16]))<2,"0"+DecToHexa(asAddress[16]),DecToHexa(asAddress[16]))))

   nStartReadBufferAddress:=HBRvaToOffset(cFilename,(HexaToDec(aComodo[1])-BaseMemory))
   nNumero:=HexaToDec(RIGHT(aComodo[1],4))+12
   cNumero:=DecToHexa(nNumero)
   cEndReadFunc:=SUBSTR(aComodo[1],3,4)+cNumero   
 q:=0
 do while (flag = .t.)
   aReturn:=HBRead16Offset(cFileName,nStartReadBufferAddress+12)
   for i:=1 to 16 step 4
     aadd(aStringa,;
     IF(Empty( DecToHexa(aReturn[i+3]) ),"00",IF(LEN(DecToHexa(aReturn[i+3]))<2,"0"+DecToHexa(aReturn[i+3]),DecToHexa(aReturn[i+3])))+;
     IF(Empty( DecToHexa(aReturn[i+2]) ),"00",IF(LEN(DecToHexa(aReturn[i+2]))<2,"0"+DecToHexa(aReturn[i+2]),DecToHexa(aReturn[i+2])))+;
     IF(Empty( DecToHexa(aReturn[i+1]) ),"00",IF(LEN(DecToHexa(aReturn[i+1]))<2,"0"+DecToHexa(aReturn[i+1]),DecToHexa(aReturn[i+1])))+;
     IF(Empty( DecToHexa(aReturn[i] )  ),"00",IF(LEN(DecToHexa(aReturn[i] ) )<2,"0"+DecToHexa(aReturn[i]  ),DecToHexa(aReturn[i]  ))))
   next i
   IF (aStringa[4*q+1] == cEndReadFunc)
     I:=0
     for i=1 to 4
       ASIZE(aStringa,len(aStringa)-1)
     next i
     Flag:=.f.
     EXIT
   ELSE
     q++
     nStartReadBufferAddress:=nStartReadBufferAddress+16
   ENDIF
 enddo
 nLen:=LEN(aStringa)
 for i= 1 to nLen step 4
   Offset:= HBRvaToOffset(cFilename,(HexaToDec(aStringa[i])-BaseMemory))
   aFuncName:=HBReadFunctionName(cFileName,Offset)
   for nTime =1 to len(aFuncName)
        cFuncName:=cFuncName+CHR(aFuncName[nTime][1])
   next nTime
   aadd(aStringa,cFuncName)
   cFuncName:=""
   aFuncName:={}
 next i
 i:=0
 nLen:=0
 nLen:=len(aStringa)* 0.80
 nLen1:=len(aStringa)* 0.20
 aAddrName:={}
 aScopeFunc:={}
 aCodeFunc:={}
 aNullFunc:={}
 aNameFunc:={}
 for i=1 to nLen  Step 4
    aadd(aAddrName,aStringa[i])
    aadd(aScopeFunc,aStringa[i+1])
    aTrans:= HBRead04Offset (cFilename, HBRvaToOffset(cFilename,( HexaToDec("0x"+aStringa[i+2])-BaseMemory+7)))
    cTrans:="0x"+;
    IF(Empty( DecToHexa(aTrans[4]) ),"00",IF(LEN(DecToHexa(aTrans[4]))<2,"0"+DecToHexa(aTrans[4]),DecToHexa(aTrans[4])))+;
    IF(Empty( DecToHexa(aTrans[3]) ),"00",IF(LEN(DecToHexa(aTrans[3]))<2,"0"+DecToHexa(aTrans[3]),DecToHexa(aTrans[3])))+;
    IF(Empty( DecToHexa(aTrans[2]) ),"00",IF(LEN(DecToHexa(aTrans[2]))<2,"0"+DecToHexa(aTrans[2]),DecToHexa(aTrans[2])))+;
    IF(Empty( DecToHexa(aTrans[1]) ),"00",IF(LEN(DecToHexa(aTrans[1]))<2,"0"+DecToHexa(aTrans[1]),DecToHexa(aTrans[1])))
    aadd( aCodeFunc, { aStringa[i+2],cTrans } )
    aadd(aNullFunc,aStringa[i+3])
 next i
 i:=0
 for i = nLen+1 to (nLen+nLen1)
      aadd(aNameFunc,aStringa[i])
 next i
 i:=0
 nLen:=LEN(aCodeFunc)
 aGlobalByteCode:={}
 for i = 1 to nLen
      aByteCodeFunc:={}
      aReturnByteCodeFunc:={}
      if aCodeFunc[i][1]<>"00000000"
        nFuncAdr:= HBRvaToOffset(cFilename,(HexaToDec(aCodeFunc[i][2])-BaseMemory))
        IF nFuncAdr<>0
          aReturnByteCodeFunc:=HBReadByteCode(cFilename,nFuncAdr)
        ENDIF
      endif
        aadd(aByteCodeFunc,aReturnByteCodeFunc)
        aadd(aGlobalByteCode,aByteCodeFunc[1])
 next i
  aLatest:=HBRead16Offset(cFileName,OffsetOfEntryPoint+336)
  cVaLUE1:="0x"+IF(Empty( DecToHexa(aLatest[4]) ),"0",IF(LEN(DecToHexa(aLatest[4]))<2,"0"+DecToHexa(aLatest[4]),DecToHexa(aLatest[4])))
  cValue2:="0x"+IF(Empty( DecToHexa(aLatest[2]) ),"0000",IF(LEN(DecToHexa(aLatest[2]))<2,"000"+DecToHexa(aLatest[2]),"0"+DecToHexa(aLatest[2])))
  cTrans:="0x"+;
    IF(Empty( DecToHexa(aLatest[9]) ),"00",IF(LEN(DecToHexa(aLatest[9]))<2,"0"+DecToHexa(aLatest[9]),DecToHexa(aLatest[9])))+;
    IF(Empty( DecToHexa(aLatest[8]) ),"00",IF(LEN(DecToHexa(aLatest[8]))<2,"0"+DecToHexa(aLatest[8]),DecToHexa(aLatest[8])))+;
    IF(Empty( DecToHexa(aLatest[7]) ),"00",IF(LEN(DecToHexa(aLatest[7]))<2,"0"+DecToHexa(aLatest[7]),DecToHexa(aLatest[7])))+;
    IF(Empty( DecToHexa(aLatest[6]) ),"00",IF(LEN(DecToHexa(aLatest[6]))<2,"0"+DecToHexa(aLatest[6]),DecToHexa(aLatest[6])))
  Offset:= HBRvaToOffset(cFilename,(HexaToDec(cTrans)-BaseMemory))
  aPrgName:=HBReadFunctionName(cFileName,Offset)
  nLen:=LEN(aPrgNamE)
  FOR i= 1 TO nLen
      cPrgName:=cPrgName+CHR(aPrgName[i][1])
  NEXT i
  wri_file(cPrgName,cValue1,cValue2,aNameFunc,aScopeFunc,aGlobalByteCode)
  cPcodeFile:=substr(cPrgName,1,len(cPrgName)-4)+".c"
  decompiler.RichEdit_1.value:=memoread(cPcodeFile)  
  decode_c2prg(cPcodeFile)
return nil

Function HBChoose_File()
Local cFileName
 cFileName := Getfile ( { {'*.Exe Files','*.exe'} } , 'Open a File' , , .f. , .t. )
 //msginfo ( IF (EMPTY( cFilename), "Empty Filename!", cFilename ) )
Return cFileName

function HBReadFunctionScope(cScope)
Local cStringScope:=""
if cScope =="00000205"
  cStringScope:="{HB_FS_PUBLIC | HB_FS_FIRST | HB_FS_LOCAL}"
elseif cScope =="00000201"
  cStringScope:="{HB_FS_PUBLIC | HB_FS_LOCAL}"
elseif cScope =="00000202"
  cStringScope:="{HB_FS_STATIC | HB_FS_LOCAL}"
elseif cScope =="00000001"
  cStringScope:="{HB_FS_PUBLIC}"
elseif cScope =="00000081"
  cStringScope:="{HB_FS_PUBLIC | HB_FS_MEMVAR}"
elseif cScope =="00000218"
  cStringScope:="{HB_FS_INITEXIT | HB_FS_LOCAL}"
endif
return cStringScope

function wri_file(cPrgName,cValue1,cValue2,aFuncName,aFuncScope,aGlobalByteCode)
Local cRecover:=substr(cPrgName,1,len(cPrgName)-4)+".c"
Local nLenA:=LEN(aFuncName), i:=0,k:=0
Local nLenB:=0,aFunctionNumber:=aGlobalByteCode[1],aAtomFunc:={}
Local cString:="",cString1:="",cString2:="",cCompVer:=""
Local cHarbVers:="",cHarbDecVers:="",cOs:="",cHarbBuildDate:="",cPcodeVer:=""
cCompVer:=HB_COMPILER()
cHarbVers:=VERSION()
cOs:=OS()
cHarbBuildDate:=HB_BUILDDATE()
cHarbDecVers:="Harbour Decompiler Alpha 0.1"
cPcodeVer:=HB_PCODEVER()
cString:="/*"+CRLF+;
         " * "+cHarbDecVers+" "+CRLF+;
         " * "+cHarbVers+" "+CRLF+;
         " * Built on "+cHarbBuildDate+" "+CRLF+;
         " * "+cPcodeVer+" "+CRLF+;
         " * "+cCompVer+" "+CRLF+;
         " * "+cOs+" "+CRLF+;
         " * Recovered C source from "+'"'+cPrgName+'"'+CRLF+;
         "*/"+CRLF+CRLF+;
         "#include " + '"'+"hbvmpub.h"+'"'+CRLF+;
         "#include " + '"'+"hbinit.h"+'"'+CRLF+CRLF+CRLF

      FOR I= 1 TO nLena
        IF aFuncScope[i]=="00000205"
          cString:=cString+"HB_FUNC( " + aFuncName[i] + " );" +CRLF
        ENDIF
      NEXT I               /* Main Original Function */

      FOR I= 1 TO nLena
        IF aFuncScope[i]=="00000201"
          cString:=cString+"HB_FUNC( " + aFuncName[i] + " );" +CRLF
        ENDIF
      NEXT I               /* Other Original Functions */

      FOR I= 1 TO nLena
        IF aFuncScope[i]=="00000202"
          cString:=cString+"HB_FUNC_STATIC( " + aFuncName[i] + " );" +CRLF
        ENDIF
      NEXT I               /* Static Original Functions */


      FOR I= 1 TO nLena
        IF aFuncScope[i]=="00000218"
           cString:=cString+"HB_FUNC"+substr(aFuncName[i],2,LEN(aFuncName[i])-2) + "();" +CRLF
        ENDIF
      NEXT I               /* Other Original Functions */


      FOR I= 1 TO nLena
        IF (aFuncScope[i]=="00000001" .OR. aFuncScope[i]=="00000081")
          cString:=cString+"HB_FUNC_EXTERN( " + aFuncName[i] + " );" +CRLF
        ENDIF
      NEXT I               /* External Function */

cString1:="HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_"+ UPPER(Substr(cPrgName,1,len(cPrgName)-4))+" )"+CRLF

     cString:=cString+CRLF+CRLF+CRLF+cString1

       FOR I = 1 TO nLenA
        cString:=cString+;
          "{ "+'"'+aFuncName[I]+'"'+", "+HBReadFunctionScope(aFuncScope[i])+", "
        if aFuncScope[i]=="00000081"
           cString:=cString+"{NULL}, NULL },"+CRLF

        elseif aFuncScope[i]=="00000218"
           cString:=cString+ "{hb"+SUBSTR(aFuncName[I],2,LEN(aFuncName[I])-2)+ "}, NULL },"+CRLF
        else
           cString:=cString+"{HB_FUNCNAME( "+aFuncName[I]+ " )}, NULL },"+CRLF
        endif
       NEXT I

cString:=substr(cString,1,LEN(cString)-3)+CRLF
cString2:="HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_" +UPPER(Substr(cPrgName,1,len(cPrgName)-4))+", "+'"'+ cPrgName+'", ' + cValue1 +", "+ cValue2 + ")"+CRLF+CRLF
cString:=cString+cString2
cString1:="#if defined( HB_PRAGMA_STARTUP )"+CRLF+;
          "   #pragma startup hb_vm_SymbolInit_"+UPPER(Substr(cPrgName,1,len(cPrgName)-4))+CRLF+;
          "#elif defined( HB_MSC_STARTUP )"+CRLF+;
          "   #if defined( HB_OS_WIN_64 )" +CRLF+;
          "      #pragma section( HB_MSC_START_SEGMENT, long, read )"+CRLF+;
          "   #endif"+CRLF+;
          "   #pragma data_seg( HB_MSC_START_SEGMENT )"+CRLF+;
          "   static HB_$INITSYM hb_vm_auto_SymbolInit_"+UPPER(Substr(cPrgName,1,len(cPrgName)-4))+;
          " = hb_vm_SymbolInit_"+ UPPER(Substr(cPrgName,1,len(cPrgName)-4))+";"+CRLF+;
          "   #pragma data_seg()"+CRLF+;
          "#endif"+CRLF+CRLF
       cString:=cString+cString1
       I:=0
       K:=0
       FOR I=1 TO nLena
         nLenB:=LEN(aGlobalByteCode[i])
         IF (aFuncScope[i]<>"00000001" .AND. aFuncScope[i]<>"00000081")
           IF aFuncScope[i]=="00000218"
               cString1:="HB_FUNC"+SUBSTR(aFuncName[i],2,len(aFuncName[i])-2)+"()"+CRLF
           ELSEIF aFuncScope[i]=="00000202"
               cString1:="HB_FUNC_STATIC( "+aFuncName[i]+" )"+CRLF
           ELSE
               cString1:="HB_FUNC( "+SUBSTR(aFuncName[i],1,len(aFuncName[i]))+" )"+CRLF
           ENDIF
             cString1:=cString1+"{"+CRLF+;
                     "      static const BYTE pcode[] ="+CRLF+;
                     "      {"+CRLF+;
                     "            "
                     for k= 1 to nLenB 
                       cString1:=cString1+ALLTRIM(STR(aGlobalByteCode[i][k][1]))+","
                       IF ( (K/14=INT(K/14)) .AND. (K<>nLenB) )
                         cString1:=cString1+CRLF+"            "
                       ENDIF
                     next k                     
                IF (RIGHT(alltrim(cString1),1)==",")
                   cString1:=substr(ALLTRIM(cString1),1,len(cstring1)-1)
                endif
                cString:=cString+cString1
                cString:=cString+CRLF+"       };"+CRLF+CRLF
                cString:=cString+"       hb_vmExecute( pcode, symbols );"+CRLF+"}"+CRLF+CRLF
                cString1:=""
         ENDIF
       NEXT I
       memowrit(cRecover,cString)
return nil


#pragma BEGINDUMP
#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#define WINVER   0x0400

#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <tchar.h>
#include <commctrl.h>
#include <hbapi.h>
#include <hbvm.h>
#include <hbstack.h>
#include <imagehlp.h>
#include <hbapiitm.h>
#include <imagehlp.h>

DWORD RvaToOffset( IMAGE_NT_HEADERS *NtHeaders, DWORD Rva);

HB_FUNC( HBPEFILECHECK )
{

   HANDLE                hFile;   
   HANDLE                hMapFile;
   LPTSTR                pBuf;
   const char            *filename = hb_parc(1);
   DWORD                 FileSize;
   BYTE                  *BaseAddress;
   IMAGE_NT_HEADERS      *ImageNtHeaders;
   IMAGE_DOS_HEADER      *ImageDosHeader;
   IMAGE_SECTION_HEADER  *ImageSectionHeader;
   IMAGE_OPTIONAL_HEADER *ImageOptionalHeader; 
   DWORD                 BR;

   hFile = CreateFile( filename, GENERIC_READ,FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
   if( hFile == INVALID_HANDLE_VALUE )
         {
            MessageBox(NULL,"Could not open file","ABORT PROGRAM",MB_ICONWARNING);
            hb_retc("Could not open file");
            return;
         }

    /* Allocate Memory Buffer */

    FileSize = GetFileSize(hFile,NULL);
    BaseAddress = (BYTE *) malloc(FileSize);
    if (!ReadFile(hFile,BaseAddress, FileSize, &BR, NULL))
       {
         free(BaseAddress);
         CloseHandle(hFile);
         MessageBox(NULL,"Could not allocate memory buffer","ABORT PROGRAM",MB_ICONWARNING);         
         hb_retc("Could not allocate buffer memory");
         return;
       }

    /* Check Dos Header */
    ImageDosHeader = (IMAGE_DOS_HEADER *) BaseAddress;
    if (ImageDosHeader->e_magic != IMAGE_DOS_SIGNATURE)
      {
         free(BaseAddress);
         CloseHandle(hFile);
         MessageBox(NULL,"Invalid DOS Header","ABORT PROGRAM",MB_ICONWARNING);
         hb_retc("Invalid Dos Header");
         return;
      }

    /* Check PE Header */
    ImageNtHeaders = (IMAGE_NT_HEADERS *) (ImageDosHeader->e_lfanew+(DWORD) ImageDosHeader);
    if (ImageNtHeaders->Signature != IMAGE_NT_SIGNATURE)
      {
         free(BaseAddress);
         CloseHandle(hFile);
         MessageBox(NULL,"Invalid PE Header","ABORT PROGRAM",MB_ICONWARNING);
         hb_retc("Invalid PE Header");
         return;
      }

    hMapFile = CreateFileMapping( hFile , 0, PAGE_READONLY , 0, 0,0); 
    if (hMapFile == NULL) 
      {  
        MessageBox(NULL,"Could not create file mapping object","ABORT PROGRAM",MB_ICONWARNING);
        free(BaseAddress);
        CloseHandle( hFile );
        hb_retc("Could not create file mapping object");
      }

      pBuf =   MapViewOfFile(hMapFile,FILE_MAP_READ,0,0,0);

   if (pBuf == NULL)
     { 
        MessageBox(NULL,"Could not map view of file","ABORT PROGRAM",MB_ICONWARNING);
        CloseHandle(hMapFile);
        CloseHandle( hFile );
        free(BaseAddress);
        UnmapViewOfFile(pBuf);
        hb_retc( "Could not map view of file" );
        return;
     }

   UnmapViewOfFile(pBuf);
   CloseHandle(hMapFile);
   CloseHandle( hFile );
   free(BaseAddress);
   hb_retc("S_OK");
   return;
   
}

HB_FUNC(HBREADFUNCTIONNAME)
{

   HINSTANCE              hLib = LoadLibrary( "ImageHlp.Dll" );
   const char             *ImageName = hb_parc(1);
   PSTR                   DllPath = NULL;
   BOOL                   DotDll= 0;
   BOOL                   ReadOnly = 1 ; 
   LOADED_IMAGE           LoadedImage;
   PUCHAR                 pBuf;
   DWORD                  NewOffset = hb_parnl(2);
   PHB_ITEM               pReturn;
   PHB_ITEM               pData;
   int                    scroll=1;
   int                    j;

   pReturn = hb_itemNew(NULL);
   pData = hb_itemNew(NULL);
   hb_arrayNew(pReturn,0);
   hb_arrayNew(pData,1);

   MapAndLoad( (char*) ImageName,DllPath, &LoadedImage, DotDll, ReadOnly );
   pBuf = LoadedImage.MappedAddress;

   if (pBuf == NULL)
     { 
        printf("Could not map view of file - error (%d).\n",GetLastError()); 
        UnMapAndLoad(&LoadedImage);
        FreeLibrary( hLib );
        hb_itemRelease(pData);
        hb_itemRelease(pReturn);
        hb_retc( "Map view of file failed !" );
        return;
     }

      j=NewOffset;     
      while (*(pBuf+j+scroll-1) !=0)
      {       
       hb_arraySetNL(pData,1,*(pBuf+j+scroll-1));
       hb_arrayAdd(pReturn,pData);
       ++scroll;
       hb_arrayNew(pData,1);
      }

   UnMapAndLoad(&LoadedImage);
   FreeLibrary( hLib );
   hb_itemRelease(pData);
   hb_itemRelease(hb_itemReturn(pReturn));
   return;   
}


HB_FUNC(HBRVATOOFFSET)
 {
   const char              *ImageName = hb_parc(1);
   PSTR                    DllPath = NULL;
   LOADED_IMAGE            LoadedImage;
   PIMAGE_NT_HEADERS       NtHeaders;
   DWORD                   ImageBase;
   BOOL                    DotDll= 0;
   BOOL                    ReadOnly = 1 ; 
   DWORD                   Offset ;
   DWORD                   Rva=hb_parnl(2);
   HINSTANCE              hLib = LoadLibrary( "ImageHlp.Dll" );
   MapAndLoad( (char *) ImageName,DllPath, &LoadedImage, DotDll, ReadOnly );
   NtHeaders = LoadedImage.FileHeader;
   Offset = RvaToOffset( NtHeaders, Rva);
   UnMapAndLoad(&LoadedImage);
   FreeLibrary( hLib );
   hb_retnl(Offset);
   return;
 }


HB_FUNC( HBREAD16OFFSET )
{
   const char             *ImageName = hb_parc(1);
   PSTR                   DllPath = NULL;
   BOOL                   DotDll= 0;
   BOOL                   ReadOnly = 1 ; 
   LOADED_IMAGE           LoadedImage;
   PUCHAR                 pBuf;
   DWORD                  Offset = hb_parnl(2);
   PHB_ITEM               pReturn;
   PHB_ITEM               pData;
   HINSTANCE              hLib = LoadLibrary( "ImageHlp.Dll" );

   MapAndLoad( (char *) ImageName,DllPath, &LoadedImage, DotDll, ReadOnly );
   pBuf = LoadedImage.MappedAddress;
   pReturn = hb_itemNew(NULL);
   pData = hb_itemNew(NULL);
   hb_arrayNew(pReturn,0);
   hb_arrayNew(pData,16);
   if (pBuf == NULL)
     { 

        MessageBox(NULL,"Could not map view of file","ABORT PROGRAM",MB_ICONWARNING);
        UnMapAndLoad(&LoadedImage);
        FreeLibrary( hLib );
        hb_retc( "Map view of file failed !" );
        return;
     }
   hb_arraySetNI(pData,1, *(pBuf+Offset));
   hb_arraySetNI(pData,2, *(pBuf+Offset+1));
   hb_arraySetNI(pData,3, *(pBuf+Offset+2));
   hb_arraySetNI(pData,4, *(pBuf+Offset+3));
   hb_arraySetNI(pData,5, *(pBuf+Offset+4));
   hb_arraySetNI(pData,6, *(pBuf+Offset+5));
   hb_arraySetNI(pData,7, *(pBuf+Offset+6));
   hb_arraySetNI(pData,8, *(pBuf+Offset+7));
   hb_arraySetNI(pData,9, *(pBuf+Offset+8));
   hb_arraySetNI(pData,10, *(pBuf+Offset+9));
   hb_arraySetNI(pData,11, *(pBuf+Offset+10));
   hb_arraySetNI(pData,12, *(pBuf+Offset+11));
   hb_arraySetNI(pData,13, *(pBuf+Offset+12));
   hb_arraySetNI(pData,14, *(pBuf+Offset+13));
   hb_arraySetNI(pData,15, *(pBuf+Offset+14));
   hb_arraySetNI(pData,16, *(pBuf+Offset+15));

   UnMapAndLoad(&LoadedImage);
   FreeLibrary( hLib );
   hb_itemRelease(hb_itemReturn(pData));
   return;
  }

HB_FUNC( HBREAD04OFFSET )
{
   const char             *ImageName = hb_parc(1);
   PSTR                   DllPath = NULL;
   BOOL                   DotDll= 0;
   BOOL                   ReadOnly = 1 ; 
   LOADED_IMAGE           LoadedImage;
   PUCHAR                 pBuf;
   DWORD                  Offset = hb_parnl(2);
   PHB_ITEM               pData;
   HINSTANCE              hLib = LoadLibrary( "ImageHlp.Dll" );

   MapAndLoad( (char *) ImageName,DllPath, &LoadedImage, DotDll, ReadOnly );
   pBuf = LoadedImage.MappedAddress;   
   pData = hb_itemNew(NULL);
   hb_arrayNew(pData,4);
   if (pBuf == NULL)
     { 
        printf("Could not map view of file - error (%d).\n",GetLastError()); 
        UnMapAndLoad(&LoadedImage);
        FreeLibrary( hLib );
        hb_itemRelease(pData);
        hb_retc( "Map view of file failed !" );
        return;
     }
   hb_arraySetNI(pData,1, *(pBuf+Offset));
   hb_arraySetNI(pData,2, *(pBuf+Offset+1));
   hb_arraySetNI(pData,3, *(pBuf+Offset+2));
   hb_arraySetNI(pData,4, *(pBuf+Offset+3));
   UnMapAndLoad(&LoadedImage);
   FreeLibrary( hLib );
   hb_itemRelease(hb_itemReturn(pData));
   return;
  }


HB_FUNC( HBREADBYTECODE )
{
   HINSTANCE              hLib = LoadLibrary( "ImageHlp.Dll" );
   const char             *ImageName = hb_parc(1);
   PSTR                   DllPath = NULL;
   BOOL                   DotDll= 0;
   BOOL                   ReadOnly = 1 ; 
   BOOL                   lFlag = 0 ; 
   LOADED_IMAGE           LoadedImage;
   PUCHAR                 pBuf;
   int                    j=1;
   DWORD                  Offset = hb_parnl(2);
   PHB_ITEM               pReturn;
   PHB_ITEM               pData;

   MapAndLoad( (char *) ImageName,DllPath, &LoadedImage, DotDll, ReadOnly );
   pBuf = LoadedImage.MappedAddress;
   pReturn = hb_itemNew(NULL);
   pData = hb_itemNew(NULL);
   hb_arrayNew(pReturn,0);
   hb_arrayNew(pData,1);
   if (pBuf == NULL)
     { 
        printf("Could not map view of file - error (%d).\n",GetLastError()); 
        UnMapAndLoad(&LoadedImage);
        FreeLibrary( hLib );
        hb_itemRelease(pData);
        hb_itemRelease(pReturn);
        hb_retc( "Map view of file failed !" );
        return;
     }

     do
     {
       hb_arraySetNI(pData,1, *(pBuf+Offset+j-1));
       hb_arrayAdd(pReturn,pData);
       hb_arrayNew(pData,1);
       j++;
       if (  ( *(pBuf+Offset+j-1)==0x6E ) && ( *(pBuf+Offset+j)==0x07 ) )
                {
                 if (*(pBuf+Offset+j+1) !=0x24)
                   {
                     lFlag=1;
                   }
                }          

     }  while ( !lFlag );

     {
       hb_arraySetNI(pData,1, *(pBuf+Offset+j-1));
       hb_arrayAdd(pReturn,pData);
       hb_arrayNew(pData,1);
       j++;
       hb_arraySetNI(pData,1, *(pBuf+Offset+j-1));
       hb_arrayAdd(pReturn,pData);
     }

   UnMapAndLoad(&LoadedImage);
   FreeLibrary( hLib );
   hb_itemRelease(pData);
   hb_itemRelease(hb_itemReturn(pReturn));
   return;
  }


HB_FUNC( HBLOADBASICADDRESSES ) 
{
   const char             *ImageName = hb_parc(1);
   PSTR                   DllPath = NULL;
   LOADED_IMAGE           LoadedImage;
   PIMAGE_NT_HEADERS      NtHeaders;
   PUCHAR                 pBuf;
   DWORD                  k;
   DWORD                  Offset;
   BOOL                   DotDll= 0;
   BOOL                   ReadOnly = 1 ; 
   HINSTANCE              hLib = LoadLibrary( "ImageHlp.Dll" );
   PHB_ITEM               pData;
   pData = hb_itemNew(NULL);
   hb_arrayNew(pData,16);
   MapAndLoad( (char *) ImageName,DllPath, &LoadedImage, DotDll, ReadOnly );
   NtHeaders = LoadedImage.FileHeader;

   hb_arraySetNL(pData,1,NtHeaders->OptionalHeader.ImageBase );
   hb_arraySetNL(pData,2,NtHeaders->OptionalHeader.BaseOfCode);
   hb_arraySetNL(pData,3,NtHeaders->OptionalHeader.BaseOfData);   
   hb_arraySetNL(pData,4,NtHeaders->OptionalHeader.SectionAlignment);   
   hb_arraySetNL(pData,5,NtHeaders->OptionalHeader.FileAlignment);   
   hb_arraySetNL(pData,6,(NtHeaders->OptionalHeader.ImageBase)+(NtHeaders->OptionalHeader.BaseOfCode));   
   hb_arraySetNL(pData,7,(NtHeaders->OptionalHeader.ImageBase)+(NtHeaders->OptionalHeader.BaseOfData));   
   hb_arraySetNL(pData,8,NtHeaders->OptionalHeader.AddressOfEntryPoint);
   hb_arraySetNL(pData,9 ,RvaToOffset(NtHeaders,NtHeaders->OptionalHeader.ImageBase));
   hb_arraySetNL(pData,10,RvaToOffset(NtHeaders,NtHeaders->OptionalHeader.BaseOfCode));
   hb_arraySetNL(pData,11,RvaToOffset(NtHeaders,NtHeaders->OptionalHeader.BaseOfData));   
   hb_arraySetNL(pData,12,RvaToOffset(NtHeaders,NtHeaders->OptionalHeader.AddressOfEntryPoint));   

   pBuf = LoadedImage.MappedAddress;
   if (pBuf == NULL)
     { 
        MessageBox(NULL,"Could not map view of file ","ABORT PROGRAM",MB_ICONWARNING);         
        UnMapAndLoad(&LoadedImage);
        FreeLibrary( hLib );
        hb_itemRelease(pData);
        hb_retc( "Map view of file failed !" );
        return;
     }

      {

       k = RvaToOffset(NtHeaders,NtHeaders->OptionalHeader.AddressOfEntryPoint);
       hb_arraySetNL(pData,13,*(pBuf+k+17));
       hb_arraySetNL(pData,14,*(pBuf+k+16));
       hb_arraySetNL(pData,15,*(pBuf+k+15));
       hb_arraySetNL(pData,16,*(pBuf+k+14));

      }
   UnMapAndLoad( &LoadedImage );
   FreeLibrary( hLib );
   hb_itemRelease(hb_itemReturn(pData));
   return;
 }


DWORD RvaToOffset( IMAGE_NT_HEADERS *NtHeaders, DWORD Rva)
{
   IMAGE_SECTION_HEADER   *Section;
   DWORD                   Offset = Rva, Limit ;
   WORD                    i;

   Section = IMAGE_FIRST_SECTION ( NtHeaders );
   if (Rva < Section->PointerToRawData)
        return Rva ;
   for (i = 0; i < NtHeaders->FileHeader.NumberOfSections; i++)
	{
          if (Section[i].SizeOfRawData)
                  Limit = Section[i].SizeOfRawData;
          else
                  Limit = Section[i].Misc.VirtualSize;

          if (Rva >= Section[i].VirtualAddress && Rva < (Section[i].VirtualAddress + Limit))
		{
                    if (Section[i].PointerToRawData != 0)
                      {
                           Offset -= Section[i].VirtualAddress;
                           Offset += Section[i].PointerToRawData;
                       }                        

                      return Offset;
		}
           }
     return NULL;
 }

#pragma ENDDUMP

#include "rcvrdbl.prg"
#include "recc2prg.prg"
