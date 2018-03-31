#include "HBCompat.ch"
#include "MiniGUI.ch"
#include "DbStruct.ch"
#include "HBXml.ch"         // HBXml.ch from folder HARBOUR\CONTRIB\XHB
#include "Modest.ch"


// Program messages

#define MSG_SAVE_STARTED             'Save started '
#define MSG_SAVE_ERROR               'Execute error'
#define MSG_SAVE_SUCCESS             'Finished successful'
#define MSG_ERROR_CREATE             'Error create file '
#define MSG_ERROR_CREATE_MEMO        'Error create file Memo '
#define MSG_ERROR_CREATE_XML         'Error create file XML-description '
#define MSG_TRANSFER_PROGRESS        'Transfer in progress. Wait...'
#define MSG_TRANSFER_FINISH          'Transfer completed'
#define MSG_ERROR_BACKUP_BASE        'Error create backup base '
#define MSG_ERROR_BACKUP_MEMO        'Error create backup memo '
#define MSG_ERROR_BACKUP_XML         'Error create backup XML-description '


Declare window wModest


/******
*
*       SaveData() --> lSuccess
*
*       Reorganization of database, preservation of description
*
*/

Function SaveData
Memvar aStat, oEditStru, aCollector, aParams
Local lSuccess := .F., ;
      aStru    := {} , ;
      aTmp           , ;
      Cycle          , ;
      nLen

// Array of working params

Private aParams := { 'SaveStru'   => .F., ;    // Keep of database structure
                     'SaveDesc'   => .F., ;    // Keep of description
                     'DeletedOff' => .T., ;    // Transfer the deleted records
                     'CreateBAK'  => .F., ;    // Create backup
                     'NewFile'    => .T., ;    // Flag: new file creation
                     'Path'       => '' , ;    // Path to preservation
                     'File'       => '' , ;    // File name (without path)
                     'Ext'        => '' , ;    // File extension
                     'RDD'        => '' , ;    // Database RDD
                     'TmpFile'    => ''   ;    // Temporary file
                   }

Load window DbSave as wSave

If !Empty( aStat[ 'FileName' ] )
   wSave.btnDatabase.Value := aStat[ 'FileName' ]
Else
   wSave.btnDatabase.Value := ( hb_DirSepDel( GetCurrentFolder() ) + '\NewBase.dbf' )
Endif

wSave.cmbRDD.Value := Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 2, 1 )

wSave.Title := APPNAME + ' - Save file'

// Only changed parts for keep

wSave.cmbRDD.Enabled := aStat[ 'ChStruct' ]

wSave.cbxSaveStru.Value   := aStat[ 'ChStruct' ]
wSave.cbxSaveStru.Enabled := aStat[ 'ChStruct' ]

wSave.cbxSaveDescript.Value   := aStat[ 'ChDescript' ]
wSave.cbxSaveDescript.Enabled := aStat[ 'ChDescript' ]

wSave.cbxDeleted.Enabled   := aStat[ 'ChStruct' ]
wSave.cbxCreateBAK.Value   := .T.
wSave.cbxCreateBAK.Enabled := ( aStat[ 'ChStruct' ] .or. aStat[ 'ChDescript' ] ) 

On key Escape of wSave Action { || lSuccess := .F., wSave.Release }

// Because of this procedure may be evoked at Main form closing
// (exit without saving changed data), when repeatedly pressing Alt+X
// will be close program immediately.
 
On key Alt+X of wSave Action ReleaseAllWindows()

SetEnabled()        // Availability of controls

Center window wSave
Activate window wSave

// If saving was confirmed

If lSuccess

   // In this place lSuccess is not saving result, but
   // result of setting of saving params in form.
   
   If ( lSuccess := DoSave() )
      
      // Change the data in edit form. For example, user
      // was change something and decide to select other file. The data was saved,
      // but he was refuse from selected file - and datas at editing
      // are remain as is.
      
      nLen := oEditStru : nLen
     
      For Cycle := 1 to nLen
     
        If !( oEditStru : aArray[ Cycle, DBS_FLAG ] == FLAG_DELETED )
           aTmp := Array( DBS_NEW_ALEN )
     
           aTmp[ DBS_FLAG    ] := FLAG_DEFAULT
           aTmp[ DBS_NAME    ] := oEditStru : aArray[ Cycle, DBS_NAME    ]
           aTmp[ DBS_TYPE    ] := oEditStru : aArray[ Cycle, DBS_TYPE    ]
           aTmp[ DBS_LEN     ] := oEditStru : aArray[ Cycle, DBS_LEN     ]
           aTmp[ DBS_DEC     ] := oEditStru : aArray[ Cycle, DBS_DEC     ]
           aTmp[ DBS_OLDNAME ] := oEditStru : aArray[ Cycle, DBS_NAME    ]
           aTmp[ DBS_OLDTYPE ] := oEditStru : aArray[ Cycle, DBS_TYPE    ]
           aTmp[ DBS_OLDLEN  ] := oEditStru : aArray[ Cycle, DBS_LEN     ]
           aTmp[ DBS_OLDDEC  ] := oEditStru : aArray[ Cycle, DBS_DEC     ]
           aTmp[ DBS_COMMENT ] := oEditStru : aArray[ Cycle, DBS_COMMENT ]
           aTmp[ DBS_RULE    ] := ''
           
           AAdd( aStru, aTmp )
     
        Endif
     
      Next
     
      oEditStru : SetArray( aStru )
     
      oEditStru : Display()
     
      oEditStru : goTop()
      oEditStru : Refresh()
     
      SetWinTitle()
      SetIconSave( 0 )
      SetRDDName()
      
      // Process the collector after successful saving.
      // Because the database already exists, all fields, which are placed in the collector
      // get flag "New field". Transformation rules are destroyed.

      AEval( aCollector, { | aItem | aItem[ DBS_FLAG    ] :=  FLAG_INSERTED, ;
                                     aItem[ DBS_OLDNAME ] := ''            , ;
                                     aItem[ DBS_OLDTYPE ] := ''            , ;
                                     aItem[ DBS_OLDLEN  ] := ''            , ;
                                     aItem[ DBS_OLDDEC  ] := ''            , ;
                                     aItem[ DBS_RULE    ] := ''              ;
                         } )
      FillCollector()   // Collector refreshing
      
   Endif
   
Endif

Return lSuccess

****** End of SaveData ******


/******
*
*       SetEnabled()
*
*       Control for availability of controls in dialog
*
*/

Static Procedure SetEnabled
Memvar aStat

wSave.btnDatabase.Enabled := wSave.cbxSaveStru.Value 

If Empty( wSave.btnDatabase.Value )
   wSave.btnOK.Enabled := .F. 
Else
   wSave.btnOK.Enabled := ( ( wSave.cbxSaveStru.Value          .or. ;
                              wSave.cbxSaveDescript.Value           ;
                            )                                 .and. ;
                            !Empty( wSave.btnDatabase.Value )       ;
                          )
Endif

Return

****** End of SetEnabled ******


/******
*
*      WhatSave()
*
*      Select file for preservation
*
*/

Static Procedure WhatSave
Local cFile := PutFile( FILEDLG_FILTER, 'Select dBASE file', , .T. )

If !Empty( cFile )
   wSave.btnDatabase.Value := cFile
Endif
                
Return

****** End of WhatSave ******


/******
*
*       KeepParams()
*
*       Bring the setting to working array
*
*/

Static Procedure KeepParams
Memvar aParams
Local cFile, ;
      nPos

aParams[ 'SaveStru'   ] := wSave.cbxSaveStru.Value
aParams[ 'SaveDesc'   ] := wSave.cbxSaveDescript.Value
aParams[ 'DeletedOff' ] := wSave.cbxDeleted.Value
aParams[ 'CreateBAK'  ] := wSave.cbxCreateBAK.Value
aParams[ 'RDD'        ] := Iif( ( GetProperty( 'wSave', 'cmbRDD', 'Value' ) == 1 ), 'DBFNTX', 'DBFCDX' )

// Allocate from full name the path, file name and extension

cFile := AllTrim( wSave.btnDatabase.Value )

If ( ( nPos := RAt( '.', cFile ) ) > 0 )
   aParams[ 'Ext' ] := Substr( cFile, ( nPos + 1 ) )
   cFile := Substr( cFile, 1, ( nPos - 1 ) )
Endif 

If ( ( nPos := RAt( '\', cFile ) ) > 0 )
   aParams[ 'File' ] := Substr( cFile, ( nPos + 1 ) )
   aParams[ 'Path' ] := Substr( cFile, 1, ( nPos - 1 ) )
Else
   aParams[ 'File' ] := cFile
   aParams[ 'Path' ] := GetCurrentFolder()
Endif 

If Empty( aParams[ 'Ext' ] )
   aParams[ 'Ext' ] := 'dbf'       // Typical extension
Endif
 
cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
WriteMsg( MSG_SAVE_STARTED + cFile )

// If file is not exest, when keeping will be easier. Therefore
// check for parameter.

aParams[ 'NewFile' ] := !File( cFile )

Return

****** End of KeepParams ******
 

/******
*
*       DoSave() --> lSuccess
*
*       Description keeping
*
*/

Static Function DoSave
Memvar oEditStru, aStat, aParams, aStru
Local lSuccess := .F., ;
      cFile          , ;
      Cycle          , ;
      nLen           , ;
      aTmp

// Expanded array of fields description for function DbCreate(). It's possible, because
// this function have used DBS_NAME, DBS_TYPE, DBS_LEN, DBS_DEC and ignore
// the others elements.

Private aStru := {}  
 
// Fill of the structure description. Deleted fileds are ignored.

nLen := oEditStru : nLen

For Cycle := 1 to nLen

  If !( oEditStru : aArray[ Cycle, DBS_FLAG ] == FLAG_DELETED )
     
     aTmp := Array( DBS_NEW_ALEN )
     
     aTmp[ DBS_NAME    ] := oEditStru : aArray[ Cycle, DBS_NAME    ]
     aTmp[ DBS_TYPE    ] := oEditStru : aArray[ Cycle, DBS_TYPE    ]
     aTmp[ DBS_LEN     ] := oEditStru : aArray[ Cycle, DBS_LEN     ]
     aTmp[ DBS_DEC     ] := oEditStru : aArray[ Cycle, DBS_DEC     ]
     aTmp[ DBS_OLDNAME ] := oEditStru : aArray[ Cycle, DBS_OLDNAME ]
     aTmp[ DBS_OLDTYPE ] := oEditStru : aArray[ Cycle, DBS_OLDTYPE ]
     aTmp[ DBS_RULE    ] := oEditStru : aArray[ Cycle, DBS_RULE    ]
     aTmp[ DBS_COMMENT ] := oEditStru : aArray[ Cycle, DBS_COMMENT ]
     
     AAdd( aStru, aTmp )
     
  Endif

Next

Begin Sequence

   If aParams[ 'SaveStru' ]      // Keep structure
   
      If !aParams[ 'NewFile' ]
        // Create tempfile at database folder.
        aParams[ 'TmpFile' ] := TempFileName()
      Endif
      
      If !CreateEmpty()
         Break
      Endif
      
      If !aParams[ 'NewFile' ]
      
         // If it modify of existing base, transfer the records in a new structure
            
         If !Transfer()
            Break
         Endif
          
         // Create backup if its needed
      
         If aParams[ 'CreateBAK' ]
          
            // Backup name is construct by add the complementary
            // extension .bak
            // Existed backups should be erased before renaming,
            //  otherwise FRename() will finished with error.
             
            cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
      
            If File( cFile + '.bak' )
               Erase ( cFile + '.bak' )
            Endif
             
            If Empty( FRename( cFile, ( cFile + '.bak' ) ) )
                
               // If database have the comment file
                
               cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' )
               cFile += Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )
      
               If File( cFile + '.bak' )
                  Erase ( cFile + '.bak' )
               Endif
                
               If File( cFile )
                  If !Empty( FRename( cFile, ( cFile + '.bak' ) ) )
                     WriteMsg( MSG_ERROR_BACKUP_MEMO + cFile )
                     Break
                  Endif
               Endif
                
            Else
               WriteMsg( MSG_ERROR_BACKUP_BASE + cFile )
               Break
            Endif
            
         Endif
          
         // If backup was not created, it is needed before renaming
         // to erase the initial (output) files
      
         cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
         Erase ( cFile )
      
         cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' )
         cFile += Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )
         Erase ( cFile )

          
         // Rename the tempfile to working file.
      
         cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
          
         If Empty( FRename( aParams[ 'TmpFile' ], cFile ) )
                
            // File of comments
      
            aParams[ 'TmpFile' ] := Left( aParams[ 'TmpFile' ], ( Len( aParams[ 'TmpFile' ] ) - 3 ) )
            aParams[ 'TmpFile' ] += Iif( ( aParams[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )
      
            If File( aParams[ 'TmpFile' ] )
      
               cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' )
               cFile += Iif( ( aParams[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )
             
               If !Empty( FRename( aParams[ 'TmpFile' ], cFile ) )
                  WriteMsg( MSG_ERROR_CREATE_MEMO + cFile )
                  Break
               Endif
            Endif
                
         Else
            WriteMsg( MSG_ERROR_CREATE + cFile )
            Break
         Endif
      
      Endif

   Endif
   
   If aParams[ 'SaveDesc' ]        // Keep the database description

      cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.xml' )

      If aParams[ 'CreateBAK' ]

         If File( cFile + '.bak' )
            Erase ( cFile + '.bak' )
         Endif
         
         If File( cFile ) 
            If !Empty( FRename( cFile, ( cFile + '.bak' ) ) )
               WriteMsg( MSG_ERROR_BACKUP_XML + cFile )
               Break
            Endif
         Endif

     Endif

     If File( cFile )
        Erase ( cFile )
     Endif

     If !SaveXML()
        WriteMsg( MSG_ERROR_CREATE_XML + cFile )
        Break
     Endif
        
   Endif
      
   lSuccess := .T.
   
End

If lSuccess

   // Change the array of working params
   
   aStat[ 'FileName'   ] := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
   aStat[ 'RDD'        ] := aStat[ 'RDD' ]
   aStat[ 'ChStruct'   ] := .F.          // Changing is absent
   aStat[ 'ChDescript' ] := .F.

   WriteMsg( MSG_SAVE_SUCCESS )
   Do Events
   
Else
   WriteMsg( MSG_SAVE_ERROR )
   
Endif

wModest.StatusBar.Item( 2 ) := ''

Return lSuccess

****** End of DoSave ******


/******
*
*       TempFileName() --> cFile
*
*       Create the temporary file
*
*/

Static Function TempFileName
Memvar aParams
Local nHandle, cFile

Do while .T.

   If ( ( nHandle := HB_FTempCreate( aParams[ 'Path' ],,, @cFile ) ) > 0 )
      FClose( nHandle )
      Erase ( cFile )
   Endif
   
   // Change the extension of .tmp file, which is created by HB_FTempCreate()
   // to standard. Reason - database must be contain the fields of comments.
   
   If !File( cFile := Left( cFile, ( Len( cFile ) - 3 ) ) + 'dbf' )
      Exit
   Endif

Enddo

Return cFile

****** End of TempFileName
 

/******
*
*       CreateEmpty() --> lSuccess
*
*       Create the empty base with the declared structure
*
*/

Static Function CreateEmpty
Memvar aParams, aStru
Local cFile          , ;
      lSuccess := .F.

If !aParams[ 'NewFile' ]
  cFile := aParams[ 'TmpFile' ]
Else
  cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
Endif

Try
  DbCreate( cFile, aStru, aParams[ 'RDD' ] )
  lSuccess := .T.
Catch
  WriteMsg( MSG_ERROR_CREATE + cFile )
End

Return lSuccess

****** End of CreateEmpty ******


/******
*
*       Transfer() --> lSuccess
*
*       Transfer the records to database with a new structure
*
*/

Static Function Transfer
Memvar aStat, aParams
Local lSuccess := .T.

Try

  DbUseArea( .T., aStat[ 'RDD'   ], ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] ), 'OldBase' )
  DbUseArea( .T., aParams[ 'RDD' ], aParams[ 'TmpFile' ], 'NewBase' )

  WriteMsg( MSG_TRANSFER_PROGRESS )
  OldBase->( DbEval( { || ChangeRecord() }, { || Iif( aParams[ 'DeletedOff' ], .T., !Deleted() ) } ) )
  WriteMsg( MSG_TRANSFER_FINISH )  

Catch
  lSuccess := .F.
Finally
  DbCloseAll()
End

Return lSuccess

****** End of Transfer ******


/******
*
*       ChangeRecord()
*
*       Transfer the fields contents
*
*/

Static Procedure ChangeRecord
Memvar aParams, aStru
Local nRecno := OldBase->( Recno() )   , ;
      nCount := OldBase->( Reccount() ), ;
      nElems := Len( aStru )           , ;
      Cycle                            , ;
      cField                           , ;
      nField                           , ;
      xValue
      
wModest.StatusBar.Item( 2 ) := ( LTrim( Str( nRecno ) ) + '/' + LTrim( Str( nCount ) ) )
Do Events

NewBase->( DbAppend() )

For Cycle := 1 to nElems

   // If previous field name is absent, means that it a new field,
   // no need to tarnster data from old base

   If !Empty( cField := aStru[ Cycle, DBS_OLDNAME ] )
   
      nField := OldBase->( FieldPos( cField ) )
      
      If !( ( xValue := EqnType( nField, Cycle ) ) == nil )
         NewBase->( FieldPut( Cycle, xValue ) )
      Endif

   Endif

Next

// Restore the deletion flag at transfering of deleted records

If aParams[ 'DeletedOff' ]
   If OldBase->( Deleted() )
      NewBase->( DbDelete() )
   Endif
Endif

Return

****** End of ChangeRecord ******


/******
*
*       EqnType( nField, nElem ) --> xVar
*
*       The coordination of field's types
*
*/

Static Function EqnType( nField, nElem )
Memvar aStru, aStat, xVar
Local cOldType := aStru[ nElem, DBS_OLDTYPE ], ;
      cNewType := aStru[ nElem, DBS_TYPE    ], ;
      cName                                  , ;
      cRule

If Empty( aStru[ nElem, DBS_RULE ] )

   // If rule is not set, transformation is typical
    
   Private xVar := OldBase->( FieldGet( nField ) )

   Do case
      Case ( ( cOldType == 'C' ) .or. ( cOldType == 'M' ) )

        Do case
           Case ( cNewType == 'C' )
             xVar := Left( xVar, aStru[ nElem, DBS_LEN ] )

           Case ( cNewType == 'N' )
             xVar := Iif( ( Type( 'Val( xVar )' ) == 'N' ), Val( xVar ), 0 )

           Case ( cNewType == 'D' )
             xVar := Iif( ( Type( 'CtoD( xVar )' ) == 'D' ), ;
                          CtoD( xVar ), CtoD( '' ) )

           Case ( cNewType == 'L' )
             xVar := AllTrim( xVar )
             If ( Len( xVar ) == 1 )
                xVar := Iif( ( xVar == 'T' ), .T., .F. )
             Else
                xVar := .F.
             Endif

        Endcase

      Case ( cOldType == 'N' )

        Do case
           Case ( ( cNewType == 'C' ) .or. ( cNewType == 'M' ) )
             xVar := Str( xVar, aStru[ nElem, DBS_LEN ], ;
                                aStru[ nElem, DBS_DEC ] )

           Case ( cNewType == 'D' )
             xVar := CtoD( AllTrim( Str( xVar ) ) )

           Case ( cNewType == 'L' )
             xVar := Iif( ( xVar == 1 ), .T., .F. )

        Endcase

      Case ( cOldType == 'D' )

        Do case
           Case ( ( cNewType == 'C' ) .or. ( cNewType == 'M' ) )
             xVar := DtoC( xVar )

           Case ( cNewType == 'N' )
             xVar := Val( DtoC( xVar ) )

          Case ( cNewType == 'L' )
            xVar := .F.

        Endcase

      Case ( cOldType == 'L' )

        Do case
           Case ( ( cNewType == 'C' ) .or. ( cNewType == 'M' ) )
             xVar := Iif( xVar, 'T', 'F' )

           Case ( cNewType == 'N' )
             xVar := Iif( xVar, 1, 0 )

           Case ( cNewType == 'D' )
             xVar := CtoD( '' )

        Endcase

   Endcase

Else

  cName := aStru[ nElem, DBS_OLDNAME ]
  cName := ( 'OldBase->' + cName )
  
  cRule := aStru[ nElem, DBS_RULE ]
  cRule := StrTran( cRule, aStat[ 'Expression' ], cName )
        
  Try
    cRule := &( '{ || ' + cRule + ' }' )
    xVar  := Eval( cRule )
  Catch
    xVar := nil
  End
          
Endif

Return xVar

****** End of EqnType ******


/******
*
*       SaveXML() --> lSuccess
*
*       Keep the database description
*
*/

Static Function SaveXML
Memvar aParams, aStru
Local lSuccess     := .T.                                                  , ;
      cFile        := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' ), ;
      oXMLDoc                                                              , ;
      oXMLDatabase                                                         , ;
      oXMLHeader                                                           , ;
      oXMLStruct                                                           , ;
      oXMLField                                                            , ;
      aField                                                               , ;
      aAttr                                                                , ;
      nFileHandle

Try

   /*
     The result is a file with the following contents:

     <?xml version="1.0"?>
     <Database file="D:\Programs\Modest\FOXHELP.DBF">
       <Description>FoxPro Help</Description>
       <Structure>
         <Field dec="0" len="30" name="TOPIC" type="C">Topic</field>
         <Field dec="0" len="10" name="DETAILS" type="M">Text</field>
         <Field dec="0" len="20" name="CLASS" type="C"/>
       </Structure>
     </Database>
       
   */
   
   // Create empty XML-document with header

   oXMLDoc := TXMLDocument() : New( '<?xml version="1.0"?>' )

   // Create main XML node

   oXMLDatabase := TXMLNode() : New( , XML_TAG_DATABASE, { XML_TAG_FILE => ( cFile + aParams[ 'Ext' ] ) } )
   oXMLDoc : oRoot : AddBelow( oXMLDatabase )

   // Add node with the database description

   oXMLHeader := TXMLNode() : New( HBXML_TYPE_TAG, XML_TAG_DESCRIPTION, nil, AllTrim( wModest.edtGeneral.Value ) )
   oXMLDatabase : AddBelow( oXMLHeader )

   // Section of field's description
   oXMLStruct := TXMLNode() : New( , XML_TAG_STRUCTURE )
   oXMLDatabase : AddBelow( oXMLStruct )

   For each aField in aStru
      aAttr := { XML_ATTR_NAME => aField[ DBS_NAME ]              , ;
                 XML_ATTR_TYPE => aField[ DBS_TYPE ]              , ;
                 XML_ATTR_LEN => LTrim( Str( aField[ DBS_LEN ] ) ), ;
                 XML_ATTR_DEC => LTrim( Str( aField[ DBS_DEC ] ) )  ;
               }

      If !Empty( aField[ DBS_COMMENT ] )
         oXMLField := TXMLNode() : New( HBXML_TYPE_TAG, XML_TAG_FIELD, aAttr, aField[ DBS_COMMENT ] )
      Else
         oXMLField := TXMLNode() : New( HBXML_TYPE_TAG, XML_TAG_FIELD, aAttr )
      Endif

      oXMLStruct : AddBelow( oXMLField )

   Next

   // Create XML file
   nFileHandle := FCreate( cFile + 'XML')
   
   If Empty( FError() )
   
      // Keep XML tree
      oXmlDoc : Write( nFileHandle, HBXML_STYLE_INDENT )
      FClose( nFileHandle )
      
   Endif

Catch
   lSuccess := .F.
End

Return lSuccess

****** End of SaveXML ******
