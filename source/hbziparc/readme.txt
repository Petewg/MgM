2014-08-25 14:05 UTC+0200 Viktor Szakats (vszakats users.noreply.github.com) 
  * contrib/hbziparc/ziparc.prg
    ! hb_ZipFile() fixed to strip drive letter from stored filenames
    * deleted an unnecessary HB_SYMBOL_UNUSED()
    + hb_ZipFile() clear the archive file attribute of input files
...

2011-10-21 15:46 UTC+0200 Viktor Szakats (harbour.01 syenar.hu)
  * contrib/hbziparc/ziparc.prg
    + added support for HB_UNZIPFILE() lWithPath parameter
    ! fixed HB_UNZIPFILE() after latest patch and added better error checking
    ! fixed setting attribs
    ; Patch by Grigory Filatov, with these changes of mine:
      * deleted changes to existing code and replaced it with optimizated code
      * deleted reformatting of existing code
      ! fixed adding ending pathsep
      * minor simplification
    ! fixed RTE when using progress bar (from Leandro's new patch)
...

2008-09-03 15:47 UTC+0200 Viktor Szakats (harbour.01 syenar hu)
     + Added .prg level implementation of old hbziparch interface.
       It's based on Toninho's functions sent to the list, but 
       synced with old interface and extended with new features, 
       fixes and all the remaining interface functions, and old 
       doc.
       There are some non-implemented stuff, and a couple of 
       NOTEs and TOFIXes, if someone wants, these can be addressed.
       (some not, as hbmzip doesn't support multi-volume archives.)
     ; NOTE: This implementation is based on hbmzip.lib, so you 
             MUST link it, to make it work.
