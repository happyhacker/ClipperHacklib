*========================={ DIALOG.PRG }===========================
*  parameters  <optional>
*
*        nTRow      := NUMERIC     TOP ROW OF BOX
*        nLCol      := NUMERIC     LEFT COLUMN OF BOX
*        nBRow      := NUMERIC     BOTTOM ROW OF BOX
*        nRCol      := NUMERIC     RIGHT COLUMN OF BOX
*  < cTitle >       := CHARACTER   OPTIONAL TITLE FOR TOP OF BOX
*  < cFrame >       := CHARACTER   S = SINGLE  D= DOUBLE  W = WIDE  N = NONE
*                                  A = Single/Blank on top
*  < lShadow >      := LOGICAL    .T. = SHADOW   .F. = NO SHADOW
*  < cBoxClr >      := CHARACTER   BOX COLOR STRING
*  < cTitleClr >    := CHARACTER   TITLE COLOR STRING
*
*  returns
*    cRet           := CHARACTER   string of screen coordinates + cursor + screen
*...................................................................*
*========================[ ALL RIGHTS RESERVED ]====================*
FUNCTION Dialog(nTRow, nLCol, nBRow, nRCol, cTitle, cFrame, lShadow, cBoxClr,cTitleClr)

LOCAL ;
    cDevice     := SET(_SET_DEVICE,'SCREEN') ,;
    cOldColor  ,;
    cOldScreen ,;
    cRet       ,;
    cShadow    ,;
    nOldCol    ,;
    nOldRow

cTitle    := IIF(PCOUNT() < 5 .OR. cTitle==NIL ,'',' ' + cTitle + ' ')
cFrame    := IIF(PCOUNT() < 6 .OR. cFrame==NIL ,'D',cFrame)
lShadow   := IIF(PCOUNT() < 7 .OR. lShadow==NIL,.T.,lShadow)

* next line stores color to longest possible string
cOldColor := SUBSTR(SETCOLOR() + SPACE(28),1,28)
cBoxClr   := SETCOLOR(IIF(PCOUNT() < 8, cOldColor,cBoxClr))
cTitleClr := IIF(PCOUNT() < 9, GetColor(cBoxClr), cTitleClr)

* not used by make_box() vars become part of cRet and are used by kill_box()
nOldRow   := ROW()
nOldCol   := COL()

IF nBRow < 24 .AND. nRCol < 77 .AND. lShadow
   cOldScreen := SAVESCREEN(nTRow,nLCol,nBRow + 1,nRCol + 2)
ELSE
   cOldScreen := SAVESCREEN(nTRow,nLCol,nBRow,nRCol)
   lShadow    := .F.
ENDIF

DO CASE
   CASE UPPER(cFrame) == 'D'
      @ nTRow,nLCol,nBRow,nRCol BOX 'ÉÍ»º¼ÍÈº '

   CASE UPPER(cFrame) == 'W'
      @ nTRow,nLCol,nBRow,nRCol BOX 'ÛßÛÛÛÜÛÛ '

   CASE UPPER(cFrame) == 'N'
      @ nTRow,nLCol,nBRow,nRCol BOX '         '

   CASE UPPER(cFrame) == 'A'
      @ nTRow,nLCol,nBRow,nRCol BOX  'Ú ¿³ÙÄÀ³ '

   OTHERWISE
      @ nTRow,nLCol,nBRow,nRCol BOX  'ÚÄ¿³ÙÄÀ³ '
ENDCASE

IF lShadow
   NEWCOLOR(nBRow+1,nLCol+2,nBRow+1,nRCol+2,'N+/N')
   NEWCOLOR(nTrow+1,nRCol+1,nBRow,nRCol+2,'N+/N')

   cRet    := CHR(nTRow) + CHR(nLCol) + CHR(nBRow + 1) + CHR(nRCol + 2)+;
       CHR(nOldRow) + CHR(nOldCol) + cOldColor + cOldScreen
ELSE
   cRet    := CHR(nTRow) + CHR(nLCol) + CHR(nBRow) + CHR(nRCol) + ;
       CHR(nOldRow) + CHR(nOldCol) + cOldColor + cOldScreen
ENDIF

IF cFrame=='A'
   @ nTRow,nLCol SAY SPACE(nRCol+1-nLCol) COLOR cTitleClr
   SETCOLOR(cTitleClr)
   Center(IIF(EMPTY(cTitle),'',cTitle),nTRow,nLCol,nRCol)
   SETCOLOR(cBoxClr)
ELSE
   Center(IIF(EMPTY(cTitle),'',cTitle),nTRow,nLCol,nRCol)
ENDIF

SET(_SET_DEVICE,cDevice)

RETURN cRet

**********************************************************************
*  procedure KillDialog()
*  parameters
*    cScr      := character  string created by make_box
**********************************************************************
PROCEDURE KillDialog(cScr)

LOCAL ;
    cDevice     := SET(_SET_DEVICE,'SCREEN') ,;
    cOldScreen  := SUBSTR(cScr,35)        ,;
    cOrigColor  := SUBSTR(cScr,7,28)      ,;
    nBRow       := ASC(SUBSTR(cScr,3,1))  ,;
    nCursorCol  := ASC(SUBSTR(cScr,6,1))  ,;
    nCursorRow  := ASC(SUBSTR(cScr,5,1))  ,;
    nLCol       := ASC(SUBSTR(cScr,2,1))  ,;
    nRCol       := ASC(SUBSTR(cScr,4,1))  ,;
    nTRow       := ASC(SUBSTR(cScr,1,1))

SETCOLOR(cOrigColor)

RESTSCREEN(nTRow,nLCol,nBRow,nRCol,cOldScreen)
SETPOS(nCursorRow,nCursorCol)

SET(_SET_DEVICE,cDevice)

RETURN
