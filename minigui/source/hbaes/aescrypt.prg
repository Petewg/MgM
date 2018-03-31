# include <hmg.ch>

function EncryptFileAES( cFileIn, cFileOut, cPassword )
   local nMode := 0
   if file( cFileOut )
      if ! msgyesno( 'Destination File ' + cFileIn + ' already exists. Do you want to overwrite?' )
         return .f.
      endif   
   endif

   if ! file( cFileIn )
      msgstop( 'Source File ' + cFileIn + ' not found!' )
      return .f.
   endif
   
   if lower( alltrim( cFileIn ) ) == lower( alltrim( cFileOut ) )
      msgstop( 'Source File and Destination File can not be the same!' )
      return .f.
   endif
   
   if len( cPassword ) == 0
      msgstop( 'Password can not be empty!' )
      return .f.
   endif
   
   if CryptFileAES( cFileIn, cFileOut, cPassword, nMode ) == 1
      msgstop( 'Destination file can not be created successfully!' )
      return .f.
   endif

   return .t.

function DecryptFileAES( cFileIn, cFileOut, cPassword )
   local nMode := 1
   if file( cFileOut )
      if ! msgyesno( 'Destination File ' + cFileIn + ' already exists. Do you want to overwrite?' )
         return .f.
      endif   
   endif

   if ! file( cFileIn )
      msgstop( 'Source File ' + cFileIn + ' not found!' )
      return .f.
   endif
   
   if lower( alltrim( cFileIn ) ) == lower( alltrim( cFileOut ) )
      msgstop( 'Source File and Destination File can not be the same!' )
      return .f.
   endif
   
   if len( cPassword ) == 0
      msgstop( 'Password can not be empty!' )
      return .f.
   endif
   
   if CryptFileAES( cFileIn, cFileOut, cPassword, nMode ) == 1
      msgstop( 'Destination file can not be created successfully!' )
      return .f.
   endif

   return .t.

