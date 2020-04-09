*****************************************************************
*      Function: MSG()
*    Parameters: a -array of lines to display on screen
*                c -title for top border  defaults to ''
*                c -border type: D/S      defaults to S
*                l -use shadow            defaults to .T.
*                c -color string          defaults to 'W+/BR'
*                n -top row for display   defaults 3
*                c -justification c-r-l-n defaults to c
*
*       Returns: c -string for use by KillDialog
*    Description: displays messages on screen
*                 centered, starting on line 3
#INCLUDE "HACKINCL.CH"

FUNCTION MSG(aMsg, cTitle, cBorder, lShadow, cColor, nTRow, cJustify)

LOCAL ;
    cDevice := SET(_SET_DEVICE,'SCREEN')  ,;
    cScr                   ,;
    ii                     ,;
    nArrayLen := LEN(aMsg) ,;
    nLCol                  ,;
    nLen      := 0         ,;
    nRCol

DEFAULT cTitle    TO ''
DEFAULT cBorder   TO 'S'
DEFAULT lShadow   TO .T.
DEFAULT cColor    TO 'W+/BR'
DEFAULT nTRow     TO 3
DEFAULT cJustify  TO 'C'

cJustify  := UPPER(cJustify)
nLen      := LEN(cTitle) + 4

FOR ii := 1 TO nArrayLen
   nLen := MAX(LEN(aMsg[ii]),nLen)
NEXT

FOR ii = 1 TO nArrayLen
   IF cJustify = 'C'
      aMsg[ii] := PADC(aMsg[ii],nLen," ")

   ELSEIF cJustify = 'R'
      aMsg[ii] := PADL(aMsg[ii],nLen," ")

   ELSEIF cJustify = 'L'
      aMsg[ii] := PADR(aMsg[ii],nLen," ")
   ENDIF
NEXT

nLCol := (40 - (nLen / 2)) - 2
nRCol := (40 + (nLen / 2)) + 1
cScr  := Dialog(nTRow,nLCol,nTRow + 1 + nArrayLen,nRCol,cTitle,cBorder,.T.,cColor)

FOR ii = 1 TO nArrayLen
   @ nTrow + ii,nLCol + 2 SAY aMsg[ii]
NEXT

SET(_SET_DEVICE,cDevice)

RETURN cScr