dbAnalyser
(c) Phil Ide 2004, All Rights Reserved

Call the application passing the name (and path if required) of a
database on the command line.  Note that the file extension is required.

The application opens the table in binary mode (using FOpen()) and
analyses the headers and the data area.

It displays the results of the analysis on the left side of the screen,
with an AChoice() of the fields displayed on the right.  Use the
up/down arrow keys to navigate the AChoice(), a left, right cursor or
ESC to quit.

In the future I intend to build in some routines to perform integrity
checking on the data area (ensure that text fields do not contain
binary data, numeric field areas contain numbers etc.) and may also
perform some checking on dbt/fpt files.
