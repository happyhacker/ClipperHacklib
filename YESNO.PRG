*=========================={ YES_NO.PRG }===========================
#INCLUDE "HACKINCL.CH"

FUNCTION YesNo(cMsg, lDefault, nTop)

LOCAL ;
    nLeft      ,;
    nRight     ,;
    cOldColor  ,;
    cScr       ,;
    nChoice    ,;
    cDevice := SET(_SET_DEVICE,'SCREEN')


DEFAULT cMsg   TO 'Is This Information Correct?'
DEFAULT lDefault  TO .T.
DEFAULT nTop TO 10

cOldColor := SETCOLOR(IIF(TYPE('XPOP_UP') = 'U','W+/BR,N/W',xpop_up))
cMsg      := ALLTRIM(cMsg)

IF LEN(cMsg) > 70
   cMsg := SUBSTR(cMsg,1,70)
ENDIF

IF LEN(cMsg) < 11
   nLeft  := 32
   nRight := 47
ELSE
   nLeft  := (40 - LEN(cMsg) / 2) - 3
   nRight := nLeft + LEN(cMsg) + 6
ENDIF

cScr := Dialog(nTop,nLeft,nTop+4,nRight)

@ nTop+1,40 - LEN(cMsg) / 2 SAY cMsg
@ nTop+3,34 PROMPT ' YES '
@ nTop+3,40 PROMPT '  NO  '

nChoice := IIF(lDefault,1,2)
MENU TO nChoice

KillDialog(cScr)
SETCOLOR(cOldColor)
SET(_SET_DEVICE,cDevice)

RETURN (nChoice = 1)
