*=============================={ PRINTRR.PRG }===============================
* Copyright (c) 1994 Michigan National Bank
*...........................................................................*
* Revision: 0000
* Created on : 1992? By Larry Hack
* Description: Prints R&R report
*...........................................................................*
* Revision: 1.1 Modified on : 06-02-94 04:14:24pm By Larry Hack
* Description: Default # of copies to 1
*==========================[ ALL RIGHTS RESERVED ]==========================*
*********************************************************************
* Function: PrintRR(cReport,cLibrary,cPrinter,cBoxClr,cbCond,cID)
* Parameters: cReport  - Report name
*             cLibrary - Library file report is in
*             cPrinter - Printer to send it to
*             cBoxClr  - color of display box
*             cbCond   - CodeBlock to set filter conditions
*             cName    - Unique ID for temporary files (for multi-user)
* Returns: NIL
* Description: Prints R&R report
*********************************************************************
#INCLUDE 'HACKINCL.CH'
FUNCTION PrintRR(cReport,cLibrary,cPrinter,cBoxClr,cbCond,cID)

LOCAL aRrHackIn:={},;
    cDispBox,;
    nChoice,;
    cRrParam,;
    cOldScreen:=SAVESCREEN(0,0,24,79),;
    cOldClr:=SETCOLOR(),;
    nOldCursor:=SETCURSOR(),;
    nOverlay,;
    nCopies:=1,;
    cFilter:='',;
    nDosErr,;
    cOutFile:=SPACE(100)

MEMVAR GETLIST
DEFAULT cLibrary TO 'REPORTS'
DEFAULT cPrinter TO '1'
DEFAULT cBoxClr TO 'W+/BR,W+/BG'
DEFAULT cID TO 'DEFLT'

nOldCursor:=SETCURSOR()
SETCOLOR(cBoxClr)

BEGIN SEQUENCE

   // If the configuration file doesn't exist, create it
   IF .NOT. FILE('rrhackin.dbf')
      AADD(aRrHackIn,{"RI_REPORT",  "C", 30,0})
      AADD(aRrHackIn,{"RI_LIBRARY", "C", 80,0})
      AADD(aRrHackIn,{"RI_MASTER",  "C", 80,0})
      AADD(aRrHackIn,{"RI_MINDEX",  "C", 80,0})
      AADD(aRrHackIn,{"RI_OUTFILE", "C", 80,0})
      AADD(aRrHackIn,{"RI_OUTAPPNL","L",  1,0})
      AADD(aRrHackIn,{"RI_CHKTIME", "C",  1,0})
      AADD(aRrHackIn,{"RI_NOESC",   "L",  1,0})
      AADD(aRrHackIn,{"RI_PRINTER", "C",  1,0})
      AADD(aRrHackIn,{"RI_BEGPAGE", "N",  4,0})
      AADD(aRrHackIn,{"RI_ENDPAGE", "N",  4,0})
      AADD(aRrHackIn,{"RI_TEST",    "L",  1,0})
      AADD(aRrHackIn,{"RI_SCOPE",   "C",  1,0})
      AADD(aRrHackIn,{"RI_LOSCOPE", "C",100,0})
      AADD(aRrHackIn,{"RI_HISCOPE", "C",100,0})
      AADD(aRrHackIn,{"RI_COPIES",  "N",  4,0})
      AADD(aRrHackIn,{"RI_FILTER",  "C",254,0})
      AADD(aRrHackIn,{"RI_QUERY",   "C",  1,0})
      AADD(aRrHackIn,{"RI_DISPERR", "L",  1,0})
      AADD(aRrHackIn,{"RI_ALIAS1",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS2",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS3",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS4",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS5",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS6",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS7",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS8",  "C",172,0})
      AADD(aRrHackIn,{"RI_ALIAS9",  "C",172,0})
      AADD(aRrHackIn,{"RI_FONTFIL", "C", 80,0})
      AADD(aRrHackIn,{"RI_MEMO",    "C", 80,0})
      AADD(aRrHackIn,{"RI_STATUS",  "L",  1,0})
      AADD(aRrHackIn,{"RI_PREVIEW", "C",  1,0})
      AADD(aRrHackIn,{"RI_UDF",     "C",  1,0})
      AADD(aRrHackIn,{"CFIELD1",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD2",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD3",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD4",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD5",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD6",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD7",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD8",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD9",    "C", 80,0})
      AADD(aRrHackIn,{"CFIELD10",   "C", 80,0})
      DBCREATE("RRHACKIN",aRrHackIn)
   ENDIF

   // Let's get outa here if we can't get access to control file
   IF .NOT. NetUse('rrhackin',.F.,5)
      BREAK
   ENDIF

   APPEND BLANK

   //Run codeblock if one was passed
   IF VALTYPE(cbCond) == 'B'
     cFilter:=EVAL(cbCond)
   ENDIF

   cDispBox:=Dialog(10,27,12,54,'','',.T.,cBoxClr)
   @ 11,29 PROMPT "SCREEN"
   @ 11,38 PROMPT "PRINTER"
   @ 11,48 PROMPT "FILE"
   MENU TO nChoice
   DO CASE
   CASE nChoice == 0
      BREAK
   CASE nChoice == 1
      REPLACE rrhackin->ri_printer WITH 'D'
   CASE nChoice == 2
      REPLACE rrhackin->ri_printer WITH cPrinter
      @ 11,31 SAY 'Number of copies '
      @ 11,48 GET nCopies PICTURE '99'
      READ
  CASE nChoice == 3
      @ 11,29 SAY 'File name '
      @ 11,39 GET cOutFile PICTURE '@S14'
      SETCURSOR(1)
      READ
      SETCURSOR(0)
      REPLACE rrhackin->ri_printer WITH cPrinter
      REPLACE RRHACKIN->RI_OUTFILE WITH cOutFile
   ENDCASE
   REPLACE RRHACKIN->RI_REPORT  WITH cReport
   REPLACE RRHACKIN->RI_LIBRARY WITH cLibrary
   REPLACE RRHACKIN->RI_DISPERR WITH .T.
   REPLACE RRHACKIN->RI_COPIES  WITH nCopies
   REPLACE RRHACKIN->RI_STATUS  WITH .T.

   // Build string for calling R&R runtime
   cRrParam := "RRUN rrhackin "+LTRIM(STR(RECNO()))+' '+TRIM(cId)+'/I'
   USE
   SETCURSOR(0)
   @ 11,29 SAY '  Printing R&R Report    '
   // Shell out and run R&R runtime
   nDosErr  := RunIt(cRrParam)

END
SETCURSOR(nOldCursor)
SETCOLOR(cOldClr)
RESTSCREEN(0,0,24,79,cOldScreen)

RETURN NIL
