*=============================={ GRAPHIT.PRG }===============================
* Copyright (c) 1994 Michigan National Bank
*...........................................................................*
* Revision: 0000
* Created on : 02-27-95 12:09:22pm By Larry Hack
* Description: Display a graph of progress
*==========================[ ALL RIGHTS RESERVED ]==========================*
*ý***************************************************************************
*    Function: GraphIt
*  Parameters: cStr, nRow, nPos, nTot
*     Returns: NIL
* Description: Display a graph of progress
*  Created by: Larry Hack   02-27-95
*
* example: GraphIt('Updating',12,RECNO(),LASTREC(),'W+/B','BG/BR')
*****************************************************************************
#INCLUDE "HACKINCL.CH"

FUNCTION GraphIt(cStr, nRow, nPos, nTot, cBoxClr, cGraphClr)

LOCAL cOldClr:='', nPerc:=0, cGraphBox:=''

DEFAULT cStr TO 'Updating'
DEFAULT nRow TO 10
DEFAULT nPos TO RECNO()
DEFAULT nTot TO LASTREC()
DEFAULT cBoxClr TO SETCOLOR()
DEFAULT cGraphClr TO GetColor(SETCOLOR())

cOldclr = SETCOLOR()

DO CASE
  CASE nTot = 0
    BREAK
  CASE nPos = 1
    SETCOLOR(cBoxClr)
    cGraphBox:=Dialog(nRow-2,3,nRow+1,76,cStr,'D')
    SETCOLOR(cGraphClr)
    @ nRow,12 SAY REPLICATE(CHR(176), 60)
  CASE nPos > 1
    nPerc = nPos / nTot
    SETCOLOR(cBoxClr)
    @ nRow, 6 SAY nPerc*100 PICT '999%'
    SETCOLOR(cGraphClr)
    @ nRow,12 SAY REPLICATE(CHR(219), nPerc*60)
  CASE nPos > nTot
    KillDialog(cGraphBox)
    BREAK
ENDCASE

SETCOLOR(cOldClr)

RETURN NIL
