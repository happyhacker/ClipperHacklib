*========================={ GRAPHIND.PRG }==========================
* Copyright (c) 1992 Larry Hack
*...................................................................*
* Created on : 11-19-92 11:16:10am By Larry Hack
* Description: Display graph durring index
*========================[ ALL RIGHTS RESERVED ]====================*
#INCLUDE "HACKINCL.CH"
EXTERNAL DESCEND, STRZERO, PADL, PADR, PADC
EXTERNAL LEFT, RIGHT

STATIC PROCEDURE DUMMY()
* dummy calls to include in obj
STR(5)
DTOC(DATE())
DTOS(DATE())
VAL('5')
SUBST(' ',1,1)

RETURN

FUNCTION GraphIndex(cDBFName, cNTXName, cIndexKey, cPath,lDisplay)

MEMVAR ;
   XPOP_UP   ,;
   GRAPH_CLR, ;
   P_cNetDrive

LOCAL ;
   lSuccess      := .T.                           ,;
   cErrorMsg     := ""                            ,;
   cTempClr := IIF(TYPE("XPOP_UP") $ 'UE~UI','W+/BR',xpop_up)  ,;
   cOldColor     := SETCOLOR()                    ,;
   cSaveScreen   := "",;
   nOldArea:=SELECT()

DEFAULT cPath TO '\'+CURDIR()+'\'

lDisplay:=IIF(lDisplay = NIL, .T., lDisplay)

BEGIN SEQUENCE
   IF .NOT. NetUse(cPath+cDbfName,.T.,5)
      BREAK
   ENDIF
   IF FILE(cPath +cNTXName)
      ERASE (cPath + cNTXName)
   ENDIF
   cErrorMsg := "BUILDING INDEX "+Upper(cNtxName)+" on "+upper(cDBFname)+;
      " DATABASE"
   IF lDisplay
      SETCOLOR(cTempClr)
      cSaveScreen :=Dialog(18,3,21,76,'','D')
      Center(cErrorMsg,19)
      SETCOLOR(IIF(TYPE('GRAPH_CLR') = 'U','GR+/W',graph_clr))
      @ 20,12 SAY REPLICATE(CHR(176), 60)     && °
   ENDIF
   // "("+var+")" forces function to eval codeblock
   DBCreateIndex(cPath + cNTXName,"("+cIndexKey+")",{||ShowProgress(cTempClr)})
   KillDialog(cSaveScreen)
   setcolor(cOldColor)
   USE

RECOVER
   ErrDraw(cErrorMsg)
   lSuccess := .F.
END SEQUENCE

SELECT(nOldArea)
RETURN lSuccess

**********************************************************************
static function ShowProgress(XPOP_UP)

LOCAL ;
   cOldColor := SETCOLOR(XPOP_UP)  ,;
   nPos := RECNO()                 ,;
   nTot := LASTREC()

IF nPos < nTot .and. npos%10 = 1
   @ 20, 6 SAY (nPos * 100) / nTot pict "999%"
   SETCOLOR(cOldColor)
   @ 20,12 SAY REPLICATE('Û',(npos/ntot) * 60)
ENDIF

IF nPos = nTot
   @ 20, 6 SAY 100 pict "999%"
   SETCOLOR(cOldColor)
   @ 20,12 SAY REPLICATE('Û',60)
ENDIF

RETURN .T.
