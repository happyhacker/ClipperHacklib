*========================={ RREXECUT.PRG }==========================
* Revision: 0000 Modified on : 11-17-92 08:37:42am
*  Parameters: c -controling DBF name (with path)
*              a -array of record numbers to process
*              c -user name (for unique error file name)
*              c -drive/path to run r&r from
*              c -configuration file for r&r
*========================[ ALL RIGHTS RESERVED ]====================*
#INCLUDE "HACKINCL.CH"

*ý***************************************************************
FUNCTION RREXECUTE(cRRuninDBF, aRRecNos, cUserName, cDrivePath, cConfig)

LOCAL ;
    cCommand         ,;
    cRecords := ''   ,;
    cScr             ,;
    nLoop            ,;
    lRet := .F.      ,;
    nDosErr

DEFAULT aRRecNos     TO {}
DEFAULT cUserName    TO 'UNOUT'
DEFAULT cDrivePath   TO STRTRAN('\' + CURDIR() + '\','\\','\')
DEFAULT cConfig      TO ''

//cDrivePath := FormatPath(cDrivePath)

FOR nLoop = 1 to LEN(aRRecNos)
   cRecords += NTRIM(aRRecNos[nLoop]) + ' '
NEXT

cScr     := PlsWait('Running R&R Report Writer Reports.')
cCommand := "RRUN " + cRRuninDBF + " " + cRecords + ALLTRIM(cUserName) + '/I'
cCommand += IF(EMPTY(cConfig),'',' ' + cConfig + '/C')
nDosErr  := RunIt(cCommand, , cDrivePath, , .F.)

IF nDosErr > 1    // 0 = ok, 1 = escape pressed - don't display error for these
   ErrDraw('Error Running: ' + cCommand,'DOS Error: ' + DOSERROR(nDosErr))
ENDIF

lRet := RRError(cDrivePath + 'RR' + ALLTRIM(cUserName))

KillDialog(cScr)


RETURN lRet

*ý***************************************************************
STATIC FUNCTION RRError(cFile)

LOCAL ;
    aErrMsg[0]                ,;
    cScr                      ,;
    lRet := .F.               ,;
    nOldArea:=SELECT()

BEGIN SEQUENCE
   IF .NOT. NetUse(cFile,.F.,5)
      ErrDraw(cFile + ' NOT AVAILABLE.')
      BREAK
   ENDIF

   DO CASE
      CASE FIELD->RO_ECODE = 'N'
         lRet := .T.

      CASE FIELD->RO_ECODE = 'C'
         AADD(aErrMsg,'[ESC] PRESSED.')

      CASE FIELD->RO_ECODE = 'J'
         AADD(aErrMsg,'SYNTAX ERROR:')

      CASE FIELD->RO_ECODE = 'R'
         AADD(aErrMsg,'REPORT ERROR:')
   ENDCASE

   IF .NOT. lRet
      AADD(aErrMsg,ALLTRIM(FIELD->RO_EMSG))
   ENDIF
END SEQUENCE

USE

IF .NOT. EMPTY(aErrMsg)
   AADD(aErrMsg,'')
   AADD(aErrMsg,'Press Any Key To Continue...')
   cScr := MSG(aErrMsg,'R&R REPORT WRITER',,,'W+/R')
   INKEY(0)
   KillDialog(cScr)
ENDIF

SELECT(nOldArea)
RETURN lRet