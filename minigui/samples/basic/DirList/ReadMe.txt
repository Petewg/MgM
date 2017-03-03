  f.GetDIRList() : 
  
  Syntax : GetDIRList( <acFilter>, <cTitle>, <cBegFolder>, <nIncludes>, <lMultiSelect>, <lChangeDir> ) ==> <aDIRList>
                       
  Arguments : <acFilter>     : File skeleton ( with wildcard characters )
              <cTitle>       : GetDIRList() form title
              <cBegFolder>   : Beginning path
              <nIncludes>    : 1: Files, 2: DIRs, 3: DIRs and Files
              <lMultiSelect> : Allow Multiple selection
              <lChangeDir>   : Allow Change DIR
                   
   Return   : <aDIRList> : DIR list with selected DIR entries.
   
   History  : 9.2008 : First Release
  
   Description :
   
     Reinvention of wheel ?   
     
     Not quite ...   
     
     Main difference is allowing file(s) and folder(s) selection together.
     
     Another difference is implementing of <lNoChangeDir> parameter. Unlike GetFile(), GetDIRList() uses this value 
     for allowing change directory ability to user.
     
     Furthermore sorting grid columns by three (not two) ways, GetVolumLabel(), List2Arry() and Arry2List() 
     functions may be useful.
     
     Also, test program ( TestGDL.prg ) may be a sample for .fmg based application.
     
     I need your help; please feel free to share your impressions. 
     
     Regards
     
     esgici

     Copyright 2006-2008 Bicahi Esgici <esgici@gmail.com>
