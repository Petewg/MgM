Greetings,

I have posted a file at http://groups.yahoo.com/group/harbourminigui/files/CONTRIB/IncrementalSearch.ZIP.

The enclosed files represent my effort to add an INCREMENTAL SEARCH capability to BROWSE controls in HMG. I want to enable a user to press a succession of keys (such as "S", "M", "I") in order to SEEK for the string "SMI" in an indexed data table. I want to do this in a way that does not make the blue record-pointer highlight disappear from the BROWSE -- so the user always sees where the record pointer is located, and he can either press the <Enter> key to select the highlighted record or he can continue to type additional characters to lengthen the search string.

This INCREMENTAL SEARCH allows the user to press the cursor-arrow keys while browsing, in which case the record pointer is updated and the search string is reset to a blank value. The <Backspace> key works as expected, shortening the search string by one character.

The IncrementalSearch() function acts only when the user has pressed a key whose value is stored in the variable cValSrchStr, enabling the programmer to create filters for the characters typed by the user). The function also checks whether a hyphen or comma was pressed, because some of my index keys ignore those two characters.

In order to create this function, I modified my copy of h_windows.prg and you will need to add those changes to your own copy in order to make the function work. PLEASE make a backup copy of your file h_windows.prg before copying the attached revised version into your \SOURCE folder and recompiling with MAKELIB.BAT. I made a number of changes which I described, and I changed some punctuation (mostly removing extra spaces, such as changing "LOCAL  i , c , u" to "LOCAL i, c, u") and I converted the names of some functions into upper case for consistency throughout the code (such as changing "aadd (" to "AADD()". I checked the revised version for accuracy many times, but there's always the possibility of a typographical error. Please let me know if you find one! :)

Your comments and feedback are welcome, since I am still learning to use HMG and always appreciate suggestions how to improve my code. Thanks to Grigory, Jacek, Janusz, and Ryszard (and the others who have sent suggestions to me -- you know who you are) for helping me learn this VERY functional language.

Joe Fanucchi
drjoe@meditrax.com
meditrax_drjoe@yahoo.com

12 October 2005