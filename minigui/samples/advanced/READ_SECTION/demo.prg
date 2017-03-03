#include <minigui.ch>

Function Main

	Load Window readsection
        readsection.title := "Reading of Exe file internal sections - Test Program <arcangelo.molinaro@fastwebnet.it>"
	readsection.Center
	readsection.Activate

Return nil

function leggi_Sezioni
Local cFileName,aReturn:={},nLen:=0,i:=0
Local cVirtualAddress:="",cVirtualSize:="",cSectionName:=""
Local cPRawData:="",cSRawData:="",cCharacter:="" ,nChar:=0
 cFilename:=HBChoose_File()
   if empty(cFilename)
      return nil
   endif
aReturn:=HBR_DCSECT(cFilename)

readsection.Title:="Sections for "+cFilename+ " file."
readsection.Lbl_1.value:="Section Name"+CRLF+CRLF
readsection.Lbl_2.value:="Virtual Address "+CRLF+CRLF
readsection.Lbl_3.value:="Virtual Size "+CRLF+CRLF
readsection.Lbl_4.value:="Raw Address "+CRLF+CRLF
readsection.Lbl_5.value:="Raw Size "+CRLF+CRLF
readsection.Lbl_6.value:="Characteristics"+CRLF+CRLF
readsection.Lbl_7.value:="Note"+CRLF+CRLF

nLen:=len(aReturn)
if nLen<>0
  for i=1 to nLen
     cSectionName:= aReturn[i][1]+CRLF
     cVirtualAddress:="0x"+IF(Empty( DecToHexa(aReturn[i][2]) ),"00",IF(LEN(DecToHexa(aReturn[i][2]))<2,"0"+DecToHexa(aReturn[i][2]),DecToHexa(aReturn[i][2])))+CRLF
     cVirtualSize:=  alltrim(str(aReturn[i][3]))+CRLF
     cpRawData:= "0x"+IF(Empty( DecToHexa(aReturn[i][4]) ),"00",IF(LEN(DecToHexa(aReturn[i][4]))<2,"0"+DecToHexa(aReturn[i][4]),DecToHexa(aReturn[i][4])))+CRLF
     cSRawData:= alltrim(str(aReturn[i][5]))+CRLF
     if aReturn[i][6] > 0
       cCharacter:="0x"+IF(Empty( DecToHexa(aReturn[i][6]) ),"00",IF(LEN(DecToHexa(aReturn[i][6]))<2,"0"+DecToHexa(aReturn[i][6]),DecToHexa(aReturn[i][6])))+CRLF
     else
       nChar:=( +4294967295+(aReturn[i][6])+1)  // 4294967295 => 0xFFFFFF
       cCharacter:="0x"+IF(Empty( DecToHexa(nChar) ),"00",IF(LEN(DecToHexa(nChar))<2,"0"+DecToHexa(nChar),DecToHexa(nChar)))+CRLF
     endif
     readsection.Lbl_1.value:=readsection.Lbl_1.value+ cSectionName
     readsection.Lbl_2.value:=readsection.Lbl_2.value+ cVirtualAddress
     readsection.Lbl_3.value:=readsection.Lbl_3.value+ cVirtualSize
     readsection.Lbl_4.value:=readsection.Lbl_4.value+ cPRawData
     readsection.Lbl_5.value:=readsection.Lbl_5.value+ cSRawData
     readsection.Lbl_6.value:=readsection.Lbl_6.value+ cCharacter
     DO CASE
        CASE cCharacter=="0xC0000040"+CRLF
            readsection.Lbl_7.value:=readsection.Lbl_7.value+"Contains initialized data,Readable,Writeable"+CRLF
        CASE cCharacter=="0x60000020"+CRLF
            readsection.Lbl_7.value:=readsection.Lbl_7.value+"Contains code,Executable,Readable"+CRLF
        CASE cCharacter=="0x50000040"+CRLF
            readsection.Lbl_7.value:=readsection.Lbl_7.value+"Contains initialized data,Shareable,Readable"+CRLF
        CASE cCharacter=="0x40000040"+CRLF
            readsection.Lbl_7.value:=readsection.Lbl_7.value+"Contains initialized data,Readable"+CRLF
        CASE cCharacter=="0xE0000040"+CRLF
            readsection.Lbl_7.value:=readsection.Lbl_7.value+"Contains initialized data,Executable,Shareable,Readable,Writable"+CRLF
        CASE cCharacter=="0xE0000080"+CRLF
            readsection.Lbl_7.value:=readsection.Lbl_7.value+"Contains uninitialized data,Executable,Shareable,Readable,Writable"+CRLF
     OTHERWISE
            readsection.Lbl_7.value:=readsection.Lbl_7.value+substr(cCharacter,1,len(cCharacter)-2)+"=> not coded YET"+CRLF
     ENDCASE
  next i
endif
return nil

function HBChoose_File()
Local cFileName
 cFileName := Getfile ( { {'Executable Files','*.exe'} } , 'Open a File' , , .f. , .t. )
// msginfo ( IF (EMPTY( cFilename), "Empty Filename!", cFilename ) )
Return cFileName


#PRAGMA BEGINDUMP
#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#define WINVER   0x0400
#include <windows.h>
#include <io.h>
#include <hbapiitm.h>

HB_FUNC( HBR_DCSECT )
{
  HANDLE hFile;
  BYTE *BaseAddress;
  WORD x;
  DWORD FileSize, BR;

  IMAGE_DOS_HEADER      *ImageDosHeader;
  IMAGE_NT_HEADERS      *ImageNtHeaders;
  IMAGE_SECTION_HEADER  *ImageSectionHeader;
  PHB_ITEM              pReturn;
  PHB_ITEM              pData;
  const char            *FileName = hb_parc(1);

  hFile = CreateFile(FileName, GENERIC_READ, FILE_SHARE_READ, 0,OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  {
  if (hFile == INVALID_HANDLE_VALUE)
    hb_retc("Cannot Open the File");
  }

  FileSize = GetFileSize(hFile, NULL);
  BaseAddress = (BYTE *) malloc(FileSize); 

 if (!ReadFile(hFile, BaseAddress, FileSize, &BR, NULL))
  {
    free (BaseAddress);
    CloseHandle (hFile); 
    hb_retc("Cannot Read the File");
  }

  ImageDosHeader = (IMAGE_DOS_HEADER *) BaseAddress;

//	controlliamo il Dos Header

if (ImageDosHeader->e_magic != IMAGE_DOS_SIGNATURE)
 {  
  free (BaseAddress); 
  CloseHandle(hFile); 
  hb_retc("Invalid Dos Header");
 }

 ImageNtHeaders = (IMAGE_NT_HEADERS *)(ImageDosHeader->e_lfanew + (DWORD) ImageDosHeader);

// controlliamo il PE Header
 if (ImageNtHeaders->Signature != IMAGE_NT_SIGNATURE)
 {
  free (BaseAddress);
  CloseHandle (hFile);
  hb_retc("Invalid PE Header");  
 }


  pReturn = hb_itemNew(NULL);
  pData = hb_itemNew(NULL);
  hb_arrayNew(pReturn,0);
  hb_arrayNew(pData,6);

// prende l'indirizzo della prima sezione
 ImageSectionHeader = IMAGE_FIRST_SECTION(ImageNtHeaders);

//      mostra la section table
 for (x = 0; x < ImageNtHeaders->FileHeader.NumberOfSections; x++)
    {
     hb_arraySetC (pData,1,ImageSectionHeader[x].Name );
     hb_arraySetNL(pData,2,ImageSectionHeader[x].VirtualAddress );
     hb_arraySetNL(pData,3,ImageSectionHeader[x].Misc.VirtualSize);
     hb_arraySetNL(pData,4,ImageSectionHeader[x].PointerToRawData);
     hb_arraySetNL(pData,5,ImageSectionHeader[x].SizeOfRawData );
     hb_arraySetNI(pData,6,ImageSectionHeader[x].Characteristics );
     hb_arrayAdd(pReturn,pData);
     hb_arrayNew(pData,6);
     }
   free (BaseAddress);
   CloseHandle (hFile);
   hb_itemRelease(pData);
   hb_itemRelease(hb_itemReturn(pReturn));
}

#PRAGMA ENDDUMP
