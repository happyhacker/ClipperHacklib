* parameters: 1) char - first message line to display
*             2) char - (opt.) second message line to display
*             3) char - (opt.) Title
*    returns: lastkey()
*
*    purpose: to draw error/warning message.
*             displays 'press any key to continue' at bottom of box.
*...................................................................*
#INCLUDE 'Hackincl.ch'

FUNCTION ErrDraw(cMsg1, cMsg2, cTitle)

LOCAL ;
    cDevice   := SET(_SET_DEVICE, 'SCREEN')  ,;
    cOldColor := SETCOLOR(IIF(TYPE('xpop_up') = 'U','W+/BR',xpop_up))   ,;
    cScr       ,;
    nCursor   := SET(_SET_CURSOR,0) ,;
    nMax       ,;
    nTRow

DEFAULT ctitle TO ''
cMsg2     := IIF(cMsg2 = NIL, '', cMsg2)
nTRow     := IIF(EMPTY(cMsg2), 11, 9)
nMax      := MAX(30,   LEN(cMsg1))
nMax      := MAX(nMax, LEN(cMsg2))
nMax      := (nMax + 8) / 2
cScr      := Dialog(nTRow,40 - nMax,15,40 + nMax,cTitle)

Center(cMsg1,nTRow + 2)
Center(cMsg2,nTRow + 4)
Center(' PRESS ANY KEY TO CONTINUE... ',IIF(EMPTY(cMsg1),13,15))

INKEY(0)
KillDialog(cScr)

SETCOLOR(cOldColor)
SET(_SET_DEVICE,cDevice)
SET(_SET_CURSOR,nCursor)

RETURN LASTKEY()
