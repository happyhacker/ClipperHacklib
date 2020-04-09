*=========================={ LISTRP1.PRG }===========================
* Copyright (c) 1991 Larry Hack
*...................................................................*
* Revision: 0000 Modified on : 05-08-91 09:13:22am
* Description: Orignal creation By Larry Hack
*========================[ ALL RIGHTS RESERVED ]====================*
#INCLUDE 'HACKINCL.CH'
FUNCTION LISTRP1(cLibrary,cPrinter)
LOCAL aRrHackIn:={}, cDispBox, cFilter:=SPACE(254), cRrParam, nPickBoxLen:=3,;
      aRrLib:={}, nChoice, nReports, nRrChoice, nCopies:=1, nOverlay,;
      cOldScreen:=SAVESCREEN(0,0,24,79), nOldArea:=SELECT(), nRecord:=0

MEMVAR GETLIST
DEFAULT cPrinter TO '1'

SET SCOREBOARD OFF

BEGIN SEQUENCE
   IF PCOUNT()=0
      ? 'Syntax: LISTRP1 rp1_file  WHERE rp1_file is the R&R library file'
      BREAK
   ENDIF

   cLibrary:=UPPER(cLibrary)
   IF SUBSTR(cLibrary,-4)#'.RP1'
      cLibrary:=TRIM(cLibrary)+'.RP1'
   ENDIF

   IF .NOT. FILE(cLibrary)
      ? 'File does not exist'
      BREAK
   ENDIF

   // Build array
   aRrLib:=RRLib(cLibrary)
   nReports:=LEN(aRrLib)

   // Check validity of file & number of reports
      IF nReports > 500
         ? 'File is not a valid R&R file'
      BREAK
   ENDIF

   IF nReports == 0
      ? 'File does not contain any reports'
      BREAK
   ENDIF

   // Size box for number of reports - max at line 21, we start at 5
   nPickBoxLen:=IF(nReports<=15,nReports+6,21)

   // Display pick box for selection of report
   nRrChoice := APick(5,20,nPickBoxLen,60,aRrLib,"Select an R&R Report",'W+/B,BG+/BR')

   // If they picked a report
   IF nRrChoice > 0
      // If the configuration file doesn't exist, create it
      IF .NOT. FILE('RRUNIN.DBF')
         AADD(aRrHackIn,{"RI_REPORT",  "C", 30,0})
         AADD(aRrHackIn,{"RI_LIBRARY", "C", 80,0})
         AADD(aRrHackIn,{"RI_MASTER",  "C", 80,0})
         AADD(aRrHackIn,{"RI_MINDEX",  "C", 80,0})
         AADD(aRrHackIn,{"RI_FONTFIL", "C", 80,0})
         AADD(aRrHackIn,{"RI_MEMO",    "C", 80,0})
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
         AADD(aRrHackIn,{"RI_STATUS",  "L",  1,0})
         DBCREATE("RRUNIN",aRrHackIn)
      ENDIF

      // Let's get outa here if we can't get access to control file
      SELECT 0
      IF .NOT. NetUse('RRUNIN',.F.,5)
         BREAK
      ENDIF

      APPEND BLANK
      cDispBox:=DIALOG(10,5,12,78,'','',.T.,'w+/b')

      // Set any valid dbase filter condition
      @ 11,7 SAY 'Filter' GET cFilter PICTURE '@S62'
      READ
      KILLDIALOG(cDispBox)

      cDispBox:=DIALOG(10,29,12,51,'','',.T.,'w+/b')
      @ 11,32 PROMPT "SCREEN"
      @ 11,41 PROMPT "PRINTER"
      MENU TO nChoice
      IF nChoice == 1
         REPLACE RRUNIN->ri_printer WITH 'D'
      ELSE
         REPLACE RRUNIN->ri_printer WITH cPrinter
         @ 11,31 SAY 'Number of copies '
         @ 11,48 GET nCopies PICTURE '99'
         READ
      ENDIF
      REPLACE RRUNIN->RI_REPORT  WITH aRrLib[nRrChoice]
      IF cLibrary $ ':\'
         REPLACE RRUNIN->RI_LIBRARY WITH cLibrary
      ELSE
         REPLACE RRUNIN->RI_LIBRARY WITH '\'+CURDIR()+'\'+cLibrary
      ENDIF
      REPLACE RRUNIN->RI_DISPERR WITH .T.
      REPLACE RRUNIN->RI_COPIES  WITH nCopies
      REPLACE RRUNIN->RI_STATUS  WITH .T.
      IF .NOT. EMPTY(cFilter)
         REPLACE RRUNIN->RI_QUERY   WITH 'O'
         REPLACE RRUNIN->RI_FILTER  WITH cFilter
      ENDIF

      // Build string for calling R&R runtime
      //cRrParam := "RRUN RRUNIN " + LTRIM(STR(RECNO()))
      nRecord:=RECNO()
      USE
      @ 11,31 SAY 'Printing R&R Report '

      // Shell out and run R&R runtime
      RrExecute('RRUNIN',{nRecord})

      //nOverlay := RunIt(cRrParam,0,'c:\')

      RESTSCREEN(0,0,24,79,cOldScreen)
   ENDIF
END

SELECT(nOldArea)

RETURN NIL
