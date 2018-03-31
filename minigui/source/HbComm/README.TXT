
        HBComm Library

This is the latest iteration of the HBComm library.  The modifications made
by me reflect my needs for a serial port library that could talk to more than
one serial port at a time.  Further, the original routines would handle only
clear text and would not correctly pass data containing null characters
(Chr(0)).  Finally, accessing ports above COM9 was a must.

The major difference in syntax is the need for the user to receive the
"Handle" returned by Init_Port() and pass it to all other routines whenever
referencing a port.  This is equivalent to the nComm variable used in the
old Clipper/Fivewin serial routines.

Function Information:
---------------------

Init_Port( cPort, nBaudrate, nDatabits, nParity, nStopbits, nBuffersize ) --> nHandle

   Port opener and initializer.

   Where:

     cPort      Port designator.  Can either be old form 'COMn' or the more
                general form '\\.\COMn'.  The general form is required for
                ports higher than COM9.

     nBaudrate  Just like you're used to (e.g., 2400, 4800, 9600, etc. )

     nDatabits  Usually 8, but can be 7 or 4.

     nParity    coded: 0,1,2,3 -> none, odd, mark, even

     nStopbits  coded: 0,1,2 -> 1, 1.5, 2

     nBuffersize I'm using 8000 at 38,400 baud.

     nHandle    returned instance identifier.  A numeric >= 256.  If nHandle
                is negative, the open failed.

OutBufClr( nHandle ) --> lSuccess

     Clear the output buffer.  lSuccess will always be TRUE unless a bad
     nHandle is used.

IsWorking( nHandle ) --> lSuccess

     Check to see if port is operative.  Failures can occur if a bad nHandle
     is used or if remote party drops the line.

InChr( nHandle, nChar, @cBuff ) --> nBytesRead

     Fetch data from the input buffer.  Note the by reference argument passing
     for the buffer.  nChar can be determined by calling InBufSize().
     nBytesRead is the actual number of bytes loaded into cBuff (usually
     equal to nChar unless there is a problem or nChar is overstated.)

InBufSize( nHandle ) --> nNumberofBytesInInputBuffer

     Get the count of bytes waiting in the input buffer.  Usually followed by
     a call to Inchr to fetch the bytes for processing.

OutChr( nHandle, cBytesToWrite, nCount ) --> lSuccess

     Write the first nCount bytes from the string cBytesToWrite.  Usually,
     nCount == Len( cBytesToWrite ).

OutBufSize( nHandle ) --> nBytesInOutputBuffer

     Get the byte count of characters awaiting transmission.

UnInt_Port( nHandle ) --> lSuccess

     Uninitialize (Close) the port and free the handle.

USAGE:
------

Here's how I do this stuff...

STATIC nHandle

...Mainline...


IF OpenOk()

   DOProcessing()

ELSE

   MsgStop( 'Cannot open port!' )

   QUIT

ENDIF

Function OpenOk()

// Open the port

IF ( nHandle := Init_Port( 'COM1', 9600, 8, 0, 0, 8000 ) ) > 0

   OutBufClr( nHandle )   // Saw this somewhere...probably ok if unnecessary

   Return IsWorking( nHandle )

ENDIF

Return FALSE

Function DOProcessing()

...

// Get a chunk from the COM port

nChr := InBuffSize( nHandle )
cBuff := Space( nHandle )

IF nChr != InChr( nHandle, @cBuff, nChr )

   MsgStop( 'Some kind of read failure on COM Port.' )

   Return FALSE

ENDIF

// process data in cBuff

// write some stuff to port

IF ! OutChr( nHandle, cSomeStuff, Len( cSomeStuff ) )

   MsgStop( 'Write error on COM Port.' )

   Return FALSE

ENDIF

// ...etc

// and finally, when night is nigh...

// Close the port

UnInt_Port( nHandle )

Return NIL


Any further contributions to this library are most welcome.

Ned Robertson
XpertCTI, LLC
Richmond, VA  USA

July 21, 2003

