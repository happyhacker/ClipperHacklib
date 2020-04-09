*=========================={ _RRFUNC.PRG }===========================
#INCLUDE "HACKINCL.CH"
#INCLUDE "RRIFACE.CH"

/* manifest constant for the dos command line length     */
#DEFINE M_nDOSCOMMANDLENGTH   127   /* dos command line length             */

STATIC;
   aRecNumbers    /* array of rrunin record numbers            */ ,;
   aROStatus      /* array of rrunout type file information    */ ,;
   cConfigFile    /* r&r configuration file to use             */ ,;
   cRRDbfPath     /* path to r&r .dbf files                    */ ,;
   cRRExePath     /* path to the R&R exe files                 */ ,;
   cUserId        /* user id to use with /i on runtime         */ ,;
   lAlreadyOpen   /* was the rrunin already open?              */ ,;
   nTotReports    /* total number of reports ran (rrrun)       */


*ý***************************************************************
*      Function: RRInit
*    Parameters: character - user identification
*                character - where to find the r&r rrunin file
*                character - where to find the r&r executable file
*                character - which configuration file to use
*       Returns: logical - was the initialization successful
*   Description: initializes system to print r&r
*       Project: 8324
*    Created by: Adam Howard   08-07-92
*****************************************************************
FUNCTION RRInit(cUser,cRRDbfDir,cRRExeDir,cConfig)
LOCAL;
   lRet  := .F.   /* was the setup successful   */


DEFAULT cRRDbfDir TO STRTRAN("\" + CURDIR() + "\","\\","\")
DEFAULT cRRExeDir TO STRTRAN("\" + CURDIR() + "\","\\","\")

IF RIGHT(cRRDbfDir,1) # "\" .AND. RIGHT(cRRDbfDir,1) # ":"
   cRRDbfDir += "\"
ENDIF
IF RIGHT(cRRExeDir,1) # "\" .AND. RIGHT(cRRExeDir,1) # ":"
   cRRExeDir += "\"
ENDIF

BEGIN SEQUENCE
   /* try to open the rrunin.dbf   */
   SELECT SELECT("RRUNIN")
   IF .NOT. USED()
      IF .NOT. NET_USE(cRRDbfDir + "RRUNIN")
         BREAK                // problem - cannot have access to rrunin file
      ENDIF
      lAlreadyOpen := .F.     // close the rrunin file in the cleanup routine
   ELSE
      lAlreadyOpen := .T.     // leave the rrunin file open in cleanup routine
   ENDIF

   /* now set up the other information */
   cUserId     := ALLTRIM(cUser)    // user identification used for rrunout
   cRRDbfPath  := cRRDbfDir         // path to r&r .dbf files
   cRRExePath  := cRRExeDir         // path to r&r .exe files
   cConfigFile := cConfig           // which r&r configuration file to use
   aRecNumbers := {}                // array of rrunin record numbers to run
   nTotReports := 0                 // total number of reports run so far
   lRet := .T.                      // everything is now aok!
END
RETURN lRet


*!short: RRCREATE       (_RRFUNC.PRG)
*ý***************************************************************
*      Function: RRCreate
*    Parameters: character - report name to print
*                character - library which stores the report
*       Returns: numeric - record number that was set up for the report
*   Description: sets up a blank rrunin record to be used for this report
*****************************************************************
FUNCTION RRCreate(cReport,cLibrary)
LOCAL;
   aSetting := {}       /* array of settings information for rrunin  */ ,;
   lContinue := .T.     /* continue through the get rrunin record loop  */ ,;
   lOldDel  := SET(_SET_DELETED,.F.)   /* store old deleted setting  */ ,;
   nOldArea := 0        /* store the old area so we can go back      */ ,;
   nRet     := 0        /* record number in rrunin                   */

DEFAULT cReport  TO SPACE(30)
DEFAULT cLibrary TO SPACE(80)

BEGIN SEQUENCE
   IF .NOT. RRMiscCheck("RRCREATE")    // make sure rrinit was called
      BREAK
   ENDIF

   SELECT RRUNIN
   nRet := D_ReuseRec()

   /* "blanks" the rrunin record */
   IF nRet # 0
      AADD(aRecNumbers,nRet)     // add the record number to the list

      /* this array will tell the rrsetfld() to blank out every field in rrunin  */
      AADD(aSetting,{ "RI_REPORT" , cReport    } )
      AADD(aSetting,{ "RI_LIBRARY", cLibrary   } )
      AADD(aSetting,{ "RI_MASTER" , SPACE(80)  } )
      AADD(aSetting,{ "RI_MINDEX" , SPACE(93)  } )
      AADD(aSetting,{ "RI_ALIAS1" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS2" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS3" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS4" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS5" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS6" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS7" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS8" , SPACE(172) } )
      AADD(aSetting,{ "RI_ALIAS9" , SPACE(172) } )
      AADD(aSetting,{ "RI_FONTFIL", SPACE(80)  } )
      AADD(aSetting,{ "RI_MEMO"   , SPACE(80)  } )
      AADD(aSetting,{ "RI_OUTFILE", SPACE(80)  } )
      AADD(aSetting,{ "RI_OUTAPPN", .F.        } )
      AADD(aSetting,{ "RI_CHKTIME", SPACE(1)   } )
      AADD(aSetting,{ "RI_NOESC"  , .F.        } )
      AADD(aSetting,{ "RI_PRINTER", SPACE(1)   } )
      AADD(aSetting,{ "RI_BEGPAGE", 0          } )
      AADD(aSetting,{ "RI_ENDPAGE", 0          } )
      AADD(aSetting,{ "RI_TEST"   , .F.        } )
      AADD(aSetting,{ "RI_SCOPE"  , SPACE(1)   } )
      AADD(aSetting,{ "RI_LOSCOPE", SPACE(250) } )
      AADD(aSetting,{ "RI_HISCOPE", SPACE(250) } )
      AADD(aSetting,{ "RI_COPIES" , 0          } )
      AADD(aSetting,{ "RI_FILTER" , SPACE(254) } )
      AADD(aSetting,{ "RI_QUERY"  , SPACE(1)   } )
      AADD(aSetting,{ "RI_DISPERR", .F.        } )
      AADD(aSetting,{ "RI_STATUS" , .T.        } )

      RRSetFld(nRet,aSetting)    // this actually does the blanking!
   ENDIF
END

SET(_SET_DELETED,lOldDel)
SELECT (nOldArea)

RETURN nRet


*!short: RRSETFLD       (_RRFUNC.PRG)
*ý***************************************************************
*      Function: RRSetFld
*    Parameters: numeric  - record number to update
*                variable - name of field to replace OR array of replaces
*                variable - value to put in the field
*       Returns: logical - did the update go smoothly
*   Description: updates fields in the rrunin file
*       Project: 8324
*    Created by: Adam Howard   08-07-92
*****************************************************************
FUNCTION RRSetFld(nRecNo,xVar2,xVar3)
LOCAL;
   aList                /* array of items to update         */ ,;
   ii       := 0        /* loop counter                     */ ,;
   lRet     := .F.      /* return value - did update go ok  */ ,;
   nOldArea := SELECT() /* save the old area                */ ,;
   nPos     := 0        /* position of field in record      */

BEGIN SEQUENCE
   IF .NOT. RRMiscCheck("RRSetFld")    // make sure rrinit was called
      BREAK
   ENDIF

   nPos := ASCAN(aRecNumbers,nRecNo)   // make sure this user is working with this record
   IF nPos = 0
      ErrDraw("INVALID R&R RECORD NUMBER PASSED TO RRSetFld()")
      BREAK
   ENDIF

   SELECT RRUNIN
   GOTO (nRecNo)                       // go to the record number that is passed in
   IF .NOT. REC_LOCK()                 // and lock it to update the record
      ErrDraw("UNABLE TO CHANGE VALUES FOR R&R REPORT #" + NTRIM(nRecNo))
      BREAK
   ENDIF

   /* this sets up the parameters to consistently be an array - easier to work with */
   IF VALTYPE(xVar2) = 'A'
      aList := xVar2
   ELSEIF VALTYPE(xVar2) = 'C' .AND. xVar3 # NIL
      aList := {{ xVar2, xVar3 }}
   ELSE
      ErrDraw("INVALID FIELD NAME OR VALUE SENT TO RRSetFld()")
      BREAK
   ENDIF

   /* now loop through the array and replace the fields as necessary */
   FOR ii = 1 TO LEN(aList)
      nPos := FIELDPOS(aList[ii,M_nRRFLDNAME])     // find out which field
      IF nPos # 0
         FIELDPUT(nPos,aList[ii,M_nRRFLDVALUE])    // replace that field with the information
      ENDIF
   NEXT
   lRet := .T.                                     // everything aok!
END
SELECT (nOldArea)
RETURN lRet


*!short: RRSTATUS       (_RRFUNC.PRG)
*ý***************************************************************
*      Function: RRStatus
*    Parameters: numeric - which field to return
*       Returns: variable - contents of an rrunout field, or an array of vals
*   Description: reads information from the rrunout.dbf, and returns req. inf
*****************************************************************
FUNCTION RRStatus(nField)
LOCAL;
   cFile                /* file to open for status (rrunout)   */ ,;
   nOldArea := SELECT() /* save old area to return to          */ ,;
   xRet     := NIL

/* if the array is nil, then load it in from the disk */
BEGIN SEQUENCE
   IF .NOT. RRMiscCheck("RRStatus")    // make sure rrinit was called
      BREAK
   ENDIF

   IF aROStatus = NIL                  // if empty, then we need to load it
      cFile := cRRExePath + "RR"
      cFile += IIF(cUserId = NIL,"UNOUT",ALLTRIM(cUserId))  // set up the file name
      IF NetUse(cFile,.f.,0,"RRUNOUT")
         /* now load the information into the array   */
         aROStatus := ARRAY(M_nROSTATSIZE)
         aROStatus[M_nRO_ECODE]   := RRUNOUT->RO_ECODE
         aROStatus[M_nRO_EMSG]    := RRUNOUT->RO_EMSG
         aROStatus[M_nRO_REPORTS] := RRUNOUT->RO_REPORTS
         aROStatus[M_nRO_PAGES]   := RRUNOUT->RO_PAGES
         aROStatus[M_nRO_RIRECNO] := RRUNOUT->RO_RIRECNO
         nTotReports              += aROStatus[M_nRO_REPORTS]
         USE
      ENDIF
   ENDIF

   /* now return what the user wants */
   IF nField = NIL                  // if user didn't pass a field name,
      xRet := aROStatus             // return whole array
   /* if arostatus is still nil, then an error occurred and you don't want to
      try to access it as an array, so return a nil value to indicate an error */
   ELSEIF nField = M_nTOTAL_REPORTS
      xRet := nTotReports
   ELSEIF VALTYPE(aROStatus) = "A"
      xRet := aROStatus[nField]
   ENDIF
END
SELECT (nOldArea)

RETURN xRet

*ý***************************************************************
*     Procedure: RRCleanup
*    Parameters: none
*   Description: "cleans up" after a r&r document run - deletes records,etc.
*****************************************************************
PROCEDURE RRCleanup
LOCAL;
   ii                   /* loop counter                  */ ,;
   nOldArea := SELECT() /* store old area to return to   */

BEGIN SEQUENCE
   IF .NOT. RRMiscCheck("RRCleanup")   // make sure rrinit was called
      BREAK
   ENDIF

   /* delete the rrunin records  */
   SELECT RRUNIN
   /* now delete all the records used in this runnin */
   FOR ii = 1 TO LEN(aRecNumbers)
      GOTO aRecNumbers[ii]
      IF REC_LOCK()
         DELETE
      ENDIF
   NEXT

   /* close out the rrunin file  */
   IF .NOT. lAlreadyOpen
      SELECT SELECT("RRUNIN")
      USE
   ENDIF

   /* reset the variables        */
   aRecNumbers    := NIL
   aROStatus      := NIL
   cUserId        := NIL
   cRRDbfPath     := NIL
   cConfigFile    := NIL
   lAlreadyOpen   := NIL
   nTotReports    := NIL
END

RETURN

*ý***************************************************************
*      Function: RRRun
*    Parameters: none - receives info from static variables above
*       Returns: logical - did the r&r report running go smoothly
*   Description: does some final preparation prior to calling the shell out
*                routine to run r&r
*****************************************************************
FUNCTION RRRun
LOCAL;
   cConfigSwitch  := ""    /* configuration switch    */ ,;
   cUserSwitch    := ""    /* user id switch          */ ,;
   cCommand       := ""    /* command line passed     */ ,;
   cBaseCommand   := ""    /* base command line       */ ,;
   cScr           := ""    /* screen for PlsWait      */ ,;
   ii             := 1     /* loop counter            */ ,;
   lContinue      := .T.   /* continue processing     */ ,;
   lRet           := .F.   /* did it run ok?          */ ,;
   nMaxLength     := M_nDOSCOMMANDLENGTH                 ,;
   nLevel         := 0                                   ,;
   nOldArea       := SELECT()


BEGIN SEQUENCE
   IF .NOT. RRMiscCheck("RRRun")      // make sure rrinit was called
      BREAK
   ENDIF

   SELECT RRUNIN
   COMMIT
   UNLOCK

   /* set up the switches and the "base" part of the command line */
   cConfigSwitch := IIF(cConfigFile # NIL,cConfigFile + "/C","")
   cUserSwitch   := IIF(cUserId # NIL,ALLTRIM(cUserId) + "/I","")
   cBaseCommand  := cRRExePath + "RRUN " + cRRDbfPath + "RRUNIN.DBF "
   cCommand      := cBaseCommand

   /* figure out how much room is left for the record numbers!    */
   nMaxLength    := M_nDOSCOMMANDLENGTH - LEN(cConfigSwitch + cUserSwitch) - 5

   cScr     := PlsWait('Running R&R Report Writer Reports.')
   /* don't even start this if there are no reports to run        */
   DO WHILE lContinue .AND. LEN(aRecNumbers) > 0

      /* this loop adds as many record numbers to the command line as it
         can before doing a shell out to run r&r then returning to finish
         the job if it has to                                              */
      DO WHILE LEN(cCommand) <= nMaxLength .AND. ii <= LEN(aRecNumbers)
         cCommand += NTRIM(aRecNumbers[ii]) + " "
         ii++
      ENDDO

      /* put finishing touches on the command line */
      cCommand += cUserSwitch + " " + cConfigSwitch
      nLevel := RunIt(cCommand,,cRRExePath,,.F.)    // run rrun
      IF nLevel > 1                 // 0 = ok, 1 = escape pressed - don't display error for these
         ErrDraw('Error Running: ' + cCommand,'DOS Error: ' + DOSERROR(nLevel))
      ELSEIF nLevel > 0             // something happened - so don't continue
         lContinue := .F.
      ENDIF

      /* check for any errors, if any occurred then stop */
      aROStatus := NIL     // force this to be reloaded to update total report count!
      lRet := RRError()
      IF lRet
         lContinue := ii <= LEN(aRecNumbers)
      ELSE
         lContinue := .F.
      ENDIF

      /* reset the command line in case you have to start again   */
      cCommand := cBaseCommand
   ENDDO
   KillDialog(cScr)
END
SELECT (nOldArea)

RETURN lRet

*ý***************************************************************
*      Function: RRError
*    Parameters: none
*       Returns: logical - were any errors encountered during the run
*   Description: checks to see if any errors occurred during the run and
*                displays a message box to alert user of any problems
*****************************************************************
STATIC FUNCTION RRError
LOCAL;
   aErrMsg  := {}    /* array to pass to MSG()      */ ,;
   cError            /* type of error that occurred   */ ,;
   cScr              /* screen saving variable        */ ,;
   lRet     := .F.   /* did everything go ok!         */

BEGIN SEQUENCE
   IF .NOT. RRMiscCheck("RRError")     // make sure rrinit was called
      BREAK
   ENDIF

   cError := RRStatus(M_nRO_ECODE)     // look for the rrunout->ro_ecode field

   IF cError # NIL                     // rrunout not accessible - somthing happened
      DO CASE
         CASE cError = 'N'             // no errors (YAY! KNOCK ON WOOD!)
            lRet := .T.

         CASE cError = 'C'             // user hit the escape key
            AADD(aErrMsg,'[ESC] PRESSED.')

         CASE cError = 'J'             // some kind of syntax error
            AADD(aErrMsg,'SYNTAX ERROR:')

         CASE cError = 'R'             // some kind of report error
            AADD(aErrMsg,'REPORT ERROR:')
      ENDCASE
   ELSE
      AADD(aErrMsg,"UNABLE TO ACCESS R&R STATUS FILE")
   ENDIF

   IF .NOT. lRet .AND. cError # NIL
      AADD(aErrMsg,ALLTRIM(RRStatus(M_nRO_EMSG)))   // add in specific error description
   ENDIF

   /* display any errors on screen  */
   IF .NOT. EMPTY(aErrMsg)
      AADD(aErrMsg,'')
      AADD(aErrMsg,'Press Any Key To Continue...')
      cScr := MSG(aErrMsg,'R&R REPORT WRITER',,,'W+/R')
      INKEY(0)
      KillDialog(cScr)
   ENDIF
END

RETURN lRet

*ý***************************************************************
*      Function: rrMiscCheck
*    Parameters: character - message part showing where this function was cal
*       Returns: logical - .t. if rrinit has been called before!
*   Description: makes sure that rrinit has been called already
*****************************************************************
STATIC FUNCTION RRMiscCheck(cMessage)
LOCAL;
   lRet  := .T.

DEFAULT cMessage TO "(somewhere)"   // hope this is never used, but...

/* if the aRecNumbers variable is not initialized, then rrinit was never
   called, so let the users know!                                          */
IF aRecNumbers = NIL
   ErrDraw("INVALID ATTEMPT TO ACCESS R&R FROM " + cMessage,"RRINIT HAS NOT BEEN CALLED")
   lRet := .F.
ENDIF

RETURN lRet

*ý***************************************************************
*      Function: ReuseRec
*    Parameters: none
*       Returns: numeric - record number locked - 0 if error (works in c++)
*   Description: finds a deleted record and locks it, or will add new rec
*****************************************************************
FUNCTION ReuseRec
LOCAL;
   lContinue      := .T.   ,;
   nRet           := 0

/* this next section will try to lock a deleted record and recall it for
   use.  If it cannot find any deleted records, it will try to add a new
   record.  If it gets to the point of being unable to add a record - it
   simply exits with no record selected for use.  Things to watch out for -
   just because you found a deleted record then locked it you still need
   to check that it is deleted after you lock it - somebody may have
   recalled it after you found it and before you locked it!                */
lContinue := .T.
LOCATE FOR DELETED()             // try to find a deleted record
DO WHILE lContinue
   IF .NOT. FOUND()              // if cannot find a deleted record
      IF ADD_REC()               // try to add a record
         nRet := RECNO()         // if you can add one, that is the one you want
      ENDIF
      lContinue := .F.           // exit this loop - THIS SHOULD BE A LAST RESORT!
   ELSEIF RecLock(.F.)           // you did find a deleted record, so lock it
      IF DELETED()               // make sure it is still deleted - somebody else may have used it!
         RECALL                  // undelete it so you can use it
         nRet := RECNO()         // that is the one you want to use
         lContinue := .F.        // exit this loop
      ELSE
         CONTINUE                // look for the next deleted record
      ENDIF
   ELSEIF YesNo(ALIAS() + " RECORD " + NTRIM(RECNO()) + " IN USE - TRY ANOTHER RECORD?",.T.)
      lContinue := .T.
      CONTINUE                   // look for the next deleted record
   ELSE
      lContinue := .F.
   ENDIF
ENDDO

RETURN nRet

*ý***************************************************************
*     Procedure: RRRemove
*    Parameters: none
*   Description: removes a single report from the list to print
*****************************************************************
PROCEDURE RRRemove(nRecNo)
LOCAL;
   ii                   /* loop counter                  */ ,;
   nOldArea := SELECT() /* store old area to return to   */ ,;
   nPos     := 0

BEGIN SEQUENCE
   IF .NOT. RRMiscCheck("RRRemove")    // make sure rrinit was called
      BREAK
   ENDIF

   /* make sure the record is valid for this user this run  */
   nPos := ASCAN(aRecNumbers,nRecNo)   // make sure this user is working with this record
   IF nPos = 0
      ErrDraw("INVALID R&R RECORD NUMBER PASSED TO RRRemove()")
      BREAK
   ENDIF

   /* now delete the record from runnin */
   SELECT RRUNIN
   GOTO nRecNo
   IF REC_LOCK()
      DELETE
   ELSE
      ErrDraw("UNABLE TO DELETE RRUNIN RECORD #" + NTRIM(nRecNo))
   ENDIF

   /* remove the "record" from those listed to print  */
   ADEL(aRecNumbers,nPos)
   ASIZE(aRecNumbers,LEN(aRecNumbers) - 1)
END
RETURN