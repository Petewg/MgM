Backup Utility for Windows 9x/NT/2000/XP
Copyright (c) 2003 Grigory Filatov. All rights reserved.

Adapted (2012-06-07) by Tsakalidis G. Evangelos <tsakal@otenet.gr>
Main adaptations :
	recursive backUp of a folder
	keeping specific number of backUps for a specific number of days and deleting unnecessary backUps

DESCRIPTION:
~~~~~~~~~~~~
Backup Utility is a application that makes ZIP compatible files.
Via Backup.ini you can setup what files needs to be included in the
ZIP file. (See further for more settings)

Have fun with Backup Utility!

DISTRIBUTION: 
~~~~~~~~~~~~~
This program is FREE, and may be freely copied and distributed, 
as long as it is not modified in any way, and no fee is charged for 
its distribution (small shipping and handling fee is acceptable). 

Explanation of Backup.ini
~~~~~~~~~~~~~~~~~~~~~~~~~

[BACKUP]
; If 'Confirm start' is set to NO, Backup will start the backup
; without asking.
Confirm start=Yes

;Compression ratio, a higher number is more compression (From 0-9)
Compression ratio=9

; "Skin" uses BMP's as the skin for Backup.
; The skins are in the "Skins" folder. (256 Colors 580x160 pixels BMP)
Skin=Backup.bmp

[BACKUP]
; If 'Confirm start' is set to NO, Backup will start the backup
; without asking.
Confirm Start=No

; Compression ratio, a higher number is more compression (From 0-9)
Compression Ratio=9
; 
TargetFolder=%H\myBACKUP
TargetPrefix=BackUp_
TargetExtension=.zip
; How many days minimum to keep a backUp
minDaysToKeep=7
; How many backUps minimum to keep
minBackUpsToKeep=7
Skin=Backup.bmp

; "Skin" uses BMP's as the skin for Backup.
; The skins are in the "Skins" folder. (256 Colors 580x160 pixels BMP)
Skin=Backup.bmp

; You can setup 100 different Source settings!
[SOURCE-00/99]
; You can use variables in the 'Files' settings.
SourceDir=%W
FileIncludeMask=*.ini
SubFolders=No
IsActive=No

[SOURCE-01/99]
SourceDir=%S
FileIncludeMask=*.scr
IsActive=No

[SOURCE-02/99]
; specific folder on drive p:
SourceDir=t:\forms
; only *.exe files
FileIncludeMask=*.exe
; no recursive folders backUp
; activated

[SOURCE-03/99]
; specific folder on drive p:
SourceDir=p:\forms\exaidw
; only *.dat files
FileIncludeMask=*.dat
; recursive folders backUp
SubFolders=Yes
; activated

[SOURCE-04/99]
; specific folder on drive t:
SourceDir=t:\forms\src
; only *.prg files
FileIncludeMask=*.prg
; no recursive folders backUp
; activated

[SOURCE-05/99]
; specific folder on drive t:
SourceDir=t:\kin32\src
; only *.prg files
FileIncludeMask=*.prg
; recursive folders backUp
SubFolders=Yes
; activated

[SOURCE-06/99]
; user's OutLook Files
SourceDir=%U\Local Settings\Application Data\Microsoft\Outlook
; all files
FileIncludeMask=*.*
; no recursive folders backUp
SubFolders=No
; defined but not activated
IsActive=No

[SOURCE-07/99]
; user's OutLook Express Files
SourceDir=%U\Local Settings\Application Data\Identities
; all files
FileIncludeMask=*.*
; recursive folders backUp
SubFolders=yes
; defined but not activated
IsActive=No

[SOURCE-08/99]
; user's Favorites
SourceDir=%U\Favorites
FileIncludeMask=*.*
SubFolders=No
IsActive=Yes

[SOURCE-09/99]
; C:\WINDOWS\Fonts
SourceDir=%W\Fonts
FileIncludeMask=*.*
SubFolders=No
IsActive=No

; Usable variables in "SourceDir" settings
; %H=Home dir            ( ex. G:\DIRECTORY )
; %C=Current drive       ( ex. F: )
; %W=Windows dir         ( ex. C:\WINDOWS )
; %S=Windows system dir  ( ex. C:\WINDOWS\SYSTEM )
; %U=UserDirectory       ( ex. C:\Documents and Settings\Administrator ) 
; %U\Local Settings\Application Data\Microsoft\Outlook
; %U\Desktop
; %U\My Documents
; %U\Favorites
; %U\Local Settings\Application Data\Identities\{D5B7EB25-0A94-4B5E-A0F6-CBF8A32E443F}\Microsoft\Outlook Express
; %W\Fonts

; in every [SOURCE-DD/99] default values :
; SourceDir  DEFAULT ""
; SubFolders DEFAULT "No"
; FileIncludeMask   DEFAULT "*.*"
; IsActive   DEFAULT "Yes"
; %W\Fonts

; All the text used in Backup can be changed through the 
; LANGUAGE section.
[LANGUAGE]
1=Cancel this backup?
2=Cannot find skin %1...
4=Confirm Start
9=Start backup now?
10=Cannot find directory %1...
20=Rate
30=Total Time
85=No files to backUp...
86=Back-up ready!
89=Back-up to %1 failed...
90=Cannot create %1...
99=Deleting : %1...