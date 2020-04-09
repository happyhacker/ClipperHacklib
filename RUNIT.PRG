*=========================={ RUNIT.PRG }===========================
*      Function: RunIt()
*    Parameters: cCommand -DOS command to run
*                nMemFree -memory to free up DEFAULT ALL
*                cPath    -Run drive & path
*                cTempPath-Drive & path for SWAP TEMP file
*                lChkErr  -have function check for dos error level
*                          defaults to .t.
*       Returns: n        -dos error level or -1 if unsuccessful swap
*                          DOS errorlevel of child process if swap run
*   Description: Used to run external programs from clipper
*                uses Blinker 2.00 Swap commands
*...................................................................*
*========================[ ALL RIGHTS RESERVED ]====================*
#INCLUDE "HACKINCL.CH"

*ý***************************************************************
FUNCTION RunIt(cCommand, nMemFree, cPath, cTempPath, lChkErr)

LOCAL ;
    nOldCursor := SET(_SET_CURSOR)  ,;
    nRet       := 0

DEFAULT nMemFree  TO 0
DEFAULT cPath     TO ''
DEFAULT cTempPath TO GETENV('TEMP')
DEFAULT lChkErr   TO .T.
cPath := ALLTRIM(cPath)
cPath := IIF(RIGHT(cPath,1) = '\',SUBS(cPath,1,LEN(cPath) -1), cPath)

IF .NOT. SWPRUNCMD(cCommand,nMemFree,cPath,cTempPath)
   nRet := -1
   ErrDraw('SWAP ERROR -MAJOR ERROR # ' + ERRORMAJ(),'MINOR ERROR # ' + ERRORMIN())
ELSE
   nRet := SWPERRLEV()
   IF nRet # 0 .AND. lChkErr
      ErrDraw('Error Running: ' + cPath + cCommand,'DOS Error: ' + DOSERROR(nRet))
   ENDIF
ENDIF

SET(_SET_CURSOR, IIF(SET(_SET_CURSOR) = 0, 1, 0))  //problem with clipper not
SET(_SET_CURSOR, nOldCursor)                       //resetting cursor on return

RETURN nRet

*ý***************************************************************
STATIC FUNCTION ErrorMaj

LOCAL ;
    cRet := '' ,;
    nError := SWPERRMAJ()

DO CASE
   CASE nError = 0
      cRet := '0: No error.'

   CASE nError = 1
      cRet := '1: Disk full.'

   CASE nError = 2
      cRet := '2: File Not found.'

   CASE nError = 3
      cRet := '3: Disk I/O error.'

   CASE nError = 4
      cRet := '4: Change directory error.'

   CASE nError = 5
      cRet := '5: Temp file create error.'

   CASE nError = 6
      cRet := '6: Change drive error.'

   CASE nError = 7
      cRet := '7: EMS error.'

   CASE nError = 8
      cRet := '8: XMS error.'

   CASE nError = 9
      cRet := '9: SHELL error.'

   CASE nError = 10
      cRet := '10: Handle table too large to save.'

   CASE nError = 11
      cRet := '11: Top of memory error.'

   CASE nError = 12
      cRet := '12: MCB chain corrupt.'

   CASE nError = 13
      cRet := '13: Too many MCBs.'

   CASE nError = 14
      cRet := '14: DOS memory function call error.'

   CASE nError = 15
      cRet := '15: Unable to allocate same segment.'

   CASE nError = 16
      cRet := '16: Unable to find COMSPEC in environment.'

   CASE nError = 254
      cRet := '254: Swap internal error.'

   CASE nError = 255
      cRet := '255: Swap internal error.'
ENDCASE

RETURN cRet

*ý***************************************************************
STATIC FUNCTION ErrorMin()

LOCAL ;
    cRet := '' ,;
    nMajor := SWPERRMAJ()

DO CASE
   CASE nMajor >= 1 .AND. nMajor <= 6
      cRet := DOSERROR(SWPERRMIN())

   CASE nMajor = 7
      cRet := EMSERROR(SWPERRMIN())

   CASE nMajor = 8
      cRet := XMSERROR(SWPERRMIN())

   CASE nMajor = 9
      cRet := DOSERROR(SWPERRMIN())

   CASE nMajor = 10
      cRet := 'Handles In Current Table: ' + NTRIM(SWPERRMIN())

   CASE nMajor = 11
      cRet := 'Top Of Memory Segment Address: ' + NTRIM(SWPERRMIN())

   CASE nMajor = 12
      cRet := 'MCB Segment Address: ' + NTRIM(SWPERRMIN())

   CASE nMajor = 13
      cRet := 'Number of MCBs: ' + NTRIM(SWPERRMIN())

   CASE nMajor = 14
      cRet := DOSERROR(SWPERRMIN())

   CASE nMajor = 15
      cRet := 'Segment Address: ' + NTRIM(SWPERRMIN())

   CASE nMajor = 16
      cRet := 'Check COMSPEC Setting.'

   OTHERWISE
      cRet := NTRIM(SWPERRMIN()) + ': Call With Details Of Situation.'
ENDCASE

RETURN cRet


*ý***************************************************************
STATIC FUNCTION EmsError(nError)

LOCAL ;
    cRet := 'EMS Error.'

DO CASE
   CASE nError = 128
      cRet += 'Internal Error In Expanded Memory Manager Software.'
   CASE nError = 129
      cRet += 'Malfunction In Expanded Memory Hardware.'
   CASE nError = 130
      cRet += 'Memory Manager Busy.'
   CASE nError = 131
      cRet += 'Invalid Handle.'
   CASE nError = 132
      cRet += 'Function Not Defined.'
   CASE nError = 133
      cRet += 'Handles Exhausted.'
   CASE nError = 134
      cRet += 'Error In Save Or Restore Of Mapping Context.'
   CASE nError = 135
      cRet += 'Allocaton Request Sprcified More Pages Than Are Available.'
   CASE nError = 136
      cRet += 'Allocaton Request Sprcified More Pages Than Are Available.'
   CASE nError = 137
      cRet += 'Zero Pages Cannot Be Allocated.'
   CASE nError = 138
      cRet += 'Requested Logical Page Is Outside Range.'
   CASE nError = 139
      cRet += 'Illegal Physical Page Number In Mapping Request.'
   CASE nError = 140
      cRet += 'Page Mapping Hardware State Save Area Is Full.'
   CASE nError = 141
      cRet += 'Mapping Context Save Failed.'
   CASE nError = 142
      cRet += 'Mapping Context Restor Failed.'
   CASE nError = 143
      cRet += 'Subfunction Parameter Not Defined.'
   CASE nError = 144
      cRet += 'Attribute Type Not Defined.'
   CASE nError = 145
      cRet += 'Feature Not Supported.'
   CASE nError = 146
      cRet += 'Source & Destination Memory Regions Overlap.'
   CASE nError = 147
      cRet += 'Length Of Region Longer Than Actual Allocated Length.'
   CASE nError = 148
      cRet += 'Conventional Memory Region & Expanded Memory Region Ovelap.'
   CASE nError = 149
      cRet += 'Specified Offset Is Outside Logical Page.'
   CASE nError = 150
      cRet += 'Region Length Exceeds 1 Megabyte.'
   CASE nError = 151
      cRet += 'source & Destination Regions Overlap.'
   CASE nError = 152
      cRet += 'Memory Source & Destination Types Are Undefined.'
   CASE nError = 153
      cRet += 'Error Code Currently Unused.'
   CASE nError = 154
      cRet += 'Specified Alternate Register Set Is Not Supported.'
   CASE nError = 155
      cRet += 'All Alternate Register Set Are Currently Allocated.'
   CASE nError = 156
      cRet += 'Specified Alternate Register Set Is Not Zero.'
   CASE nError = 157
      cRet += 'Alternate Register Set Specified Is Not Defined Or Not Allocated.'
   CASE nError = 158
      cRet += 'Dedicated DMA Channel Is Not Supported.'
   CASE nError = 159
      cRet += 'Specified DMA Channel Is Not Supported.'
   CASE nError = 160
      cRet += 'No Handle Found For Specifed Name.'
   CASE nError = 161
      cRet += 'Handle With Same Name Already Exists.'
   CASE nError = 163
      cRet += 'Invalid Pointer Passed To Function/Contents Of Source Array Corrupted.'
   CASE nError = 164
      cRet += 'Access To Function Denied By Operating System.'
ENDCASE

RETURN cRet

*ý***************************************************************
STATIC FUNCTION XmsError(nError)

LOCAL ;
    cRet := 'XMS Error.'

DO CASE
   CASE nError = 128
      cRet := 'Function Not Implemented.'
   CASE nError = 129
      cRet := 'VDISK Device Driver Was Detected.'
   CASE nError = 130
      cRet := 'a20 Error Occurred.'
   CASE nError = 142
      cRet := 'General Driver Error.'
   CASE nError = 143
      cRet := 'Unrecoverable Driver Error.'
   CASE nError = 144
      cRet := 'High Memory Area Does Not Exist.'
   CASE nError = 145
      cRet := 'High Memory Area Already In Use.'
   CASE nError = 146
      cRet := 'DX Is Less Than /HMAMIN = Parameter.'
   CASE nError = 147
      cRet := 'High Memory Area Not Allocated.'
   CASE nError = 148
      cRet := 'A20 Line Still Enabled.'
   CASE nError = 160
      cRet := 'All Extended Memory Is Allocated.'
   CASE nError = 161
      cRet := 'Extended Memory Handles Exhaused.'
   CASE nError = 162
      cRet := 'Invalid Handle.'
   CASE nError = 163
      cRet := 'Invalid Source Handle.'
   CASE nError = 164
      cRet := 'Invalid Source Offset.'
   CASE nError = 165
      cRet := 'Invalid Destination Handle.'
   CASE nError = 166
      cRet := 'Invalid Destination Offset.'
   CASE nError = 167
      cRet := 'Invalid Length.'
   CASE nError = 168
      cRet := 'Invalid Overlap In Move Request.'
   CASE nError = 169
      cRet := 'Parity Error Detected.'
   CASE nError = 170
      cRet := 'Block Is Not Locked.'
   CASE nError = 171
      cRet := 'Block Is Locked.'
   CASE nError = 172
      cRet := 'Lock Count Overflowed.'
   CASE nError = 173
      cRet := 'Lock Failed.'
   CASE nError = 176
      cRet := 'Smaller UMB Is Available.'
   CASE nError = 177
      cRet := 'No UMBs Are Available.'
   CASE nError = 178
      cRet := 'Invalid UMB Segment Number.'
ENDCASE

RETURN cRet


/*
FROM BLINKER: README.200

Swap function error codes

The SWPRUNCMD function returns a numeric result code to the calling
program following the swap. If the error occurs following the
execution of the child process, and the parent program image cannot
be restored correctly, an error message will be displayed detailing
the error and the error number that occurred, and the swap function
will exit to DOS.

The return codes have the following meanings:

0     No error
1     Disk full
2     File Not found
3     Disk I/O error
4     Change directory error
5     Temp file create error
6     Change drive error
7     EMS error
8     XMS error
9     SHELL error
10    Handle table too large to save
11    Top of memory error
12    MCB chain corrupt
13    Too many MCBs
14    DOS memory function call error
15    Unable to allocate same segment
254   Swap internal error
255   Swap internal error

In the event that the return code is 0, indicating success, the minor
error code may be set to one of the following three values:

0    No error
1    The swap function removed a TSR
2    Top of DOS memory increased

In case 1, a TSR (or other memory block) had to be freed on return to
the parent program. This will succeed in almost all circumstances, but
is it always recommended that the TSR's owm removal mechanisms be used
in preference. This return code will allow you to warn your user of
the situation.

In case 2, a utility such as Quarterdeck's VIDRAM ON may have been
used during the swap to increase DOS memory. This utility should not
be used to change memory sizes during the swap.

Taken in turn:

0     No error

A return value of zero indicates that the swap function successfully
executed the command interpreter, and restored the program image.

1     Disk full

The disk on which the swap function was attempting to save the program
image is full.

2     File not found

DOS returned a 'file not found' error when the swap function attempted
to restore the program image from a disk swap file. The swap file may
have been deleted.

3     Disk I/O error

DOS returned an unexpected error while the swap function was either
reading from or writing to the disk file containing the program image.

4     Change directory error

The swap function encountered an error either when changing to the
requested directory passed as a parameter to the swap function, or
when restoring the current directory following the swap.

5     Temp file create error

DOS returned an error when the swap function attempted to create a
temporary file to store the program image. Check that the path
specified for the temporary file is valid.

6     Change drive error

The swap function encountered an error either when changing to the
requested drive passed as a parameter to the swap function, or when
restoring the current drive following the swap.

7     EMS error

An unexpected error occurred during an EMS operation.

8     XMS error

An unexpected error occurred during an XMS operation.

9     SHELL error

The swap function was unable to execute the command processor. Check
that the COMSPEC environment variable was set correctly.

10    Handle table too large to save

The swap function can only save an expanded handle table that contains
255 (or less) handles.

11    Top of memory error

The top of DOS memory was at a lower address following the swap than
it was before the swap. Do not execute programs like Quarterdeck's
VIDRAM utility while a program is swapped out.

12    MCB chain corrupt

The swap funtion detected that the DOS memory control block chain was
corrupted.

13    Too many MCBs

The swap function can only save programs that own 128 or less DOS
memory control blocks, which is more than sufficient in most cases.

14    DOS memory function call error

DOS returned an error on a memory related function call. Please
contact technical support with full details of the situation causing
this error.

15    Unable to allocate same segment

In order to restore the program image correctly, the swap function
must be able to allocate the same memory blocks that the program
originally owned. This message indicates that DOS returned a block at
a different address than the swap function expected. The program
cannot be correctly restored.

254   Swap internal error

Please contact technical support with full details of the situation
causing this error.

255   Swap internal error

Please contact technical support with full details of the situation
causing this error.

*/