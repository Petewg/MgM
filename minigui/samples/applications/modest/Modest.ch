/******
*
*       Modest.ch
*
*       System definitions
*/

// New row symbol

#define CRLF                         HB_OSNewLine()

// About information

#define APPNAME                     'Modest'
#define APPVERSION                  'February 2008, v.1'
#define COPYRIGHT                   ( 'V.V.Chumachenko' + CRLF + '(c) 2008' )

// Ini file full name

#define MODEST_INI                  ( GetStartupFolder() + '\' + APPNAME + '.ini' )

// Array elements indices. First four elements coincide with definitions
// in DbStruct.ch for function DbStruct() and uses a similar definitions for
// indices (DBS_NAME, DBS_TYPE, DBS_LEN, DBS_DEC)

//#define DBS_NAME                      1            Field name
//#define DBS_TYPE                      2            Field type
//#define DBS_LEN                       3            Field length
//#define DBS_DEC                       4            Field decimal
#define DBS_COMMENT                   ( DBS_ALEN + 1 )           // Comment
#define DBS_FLAG                      ( DBS_ALEN + 2 )           // Category flag
#define DBS_OLDNAME                   ( DBS_ALEN + 3 )           // Original field name
#define DBS_OLDTYPE                   ( DBS_ALEN + 4 )           // Original field type
#define DBS_OLDLEN                    ( DBS_ALEN + 5 )           // Original field length
#define DBS_OLDDEC                    ( DBS_ALEN + 6 )           // Original field decimal
#define DBS_RULE                      ( DBS_ALEN + 7 )           // Transformation rule

#define DBS_NEW_ALEN                  ( DBS_ALEN + 7 )

// Values of flag DBS_FLAG

#define FLAG_DEFAULT                  0           // Inalterable row
#define FLAG_INSERTED                 1           // New element
#define FLAG_DELETED                  2           // Deleted element

// Filter for functions GetFile() and PutFile()

#define FILEDLG_FILTER                { { 'dBASE (*.dbf)'  , '*.dbf' }  , ;
                                        { 'All files (*.*)', '*.*'   }    ;
                                      }

// Definition for transformation rule

#define THIS_VALUE                    '%VAL%'

// Definitions for tag's names in XML

#define XML_TAG_DATABASE              'Database'          // Main block
#define XML_TAG_DESCRIPTION           'Description'       // Description of database
#define XML_TAG_FILE                  'file'              // Full name of database
#define XML_TAG_STRUCTURE             'Structure'         // Block of fields description
#define XML_TAG_FIELD                 'Field'             // Field's description
#define XML_ATTR_NAME                 'name'              // Field name
#define XML_ATTR_TYPE                 'type'              // Field type
#define XML_ATTR_LEN                  'len'               // Field length
#define XML_ATTR_DEC                  'dec'               // Field decimal
