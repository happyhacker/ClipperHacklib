*==========================={ APICK.PRG }============================
* Copyright (c) 1992 Larry Hack
*...................................................................*
* Created on : 11-19-92 04:29:17pm By Larry Hack
* Description: Select multiple array elements
*========================[ ALL RIGHTS RESERVED ]====================*
#INCLUDE 'HACKINCL.CH'

STATIC nRelRow

FUNCTION Apick

PARA nTop, nLeft, nBottom, nRight, aArray, cBoxTitle, cBoxClr,;
     cTitleClr, cBarClr, actual_len, lTagging, nInitRow

LOCAL nLoop, cOldColor, cScr, nChoice

DEFAULT cBoxTitle TO ''
DEFAULT cBoxClr TO SETCOLOR()
DEFAULT cTitleClr TO cBoxClr
DEFAULT cBarClr TO SetColor()
DEFAULT lTagging TO .F.
DEFAULT nInitRow TO 0

PRIVATE lDrawBar, nBarLine, nMidPoint, nLastEle, cSearchStr

cSearchStr := ''
nMidPoint := nLeft + INT((nRight - nLeft) / 2) - 4

** determine # of last element by grabbing length of array,
** unless of course the actual length was passed as parameter #9
nLastEle := IF(TYPE('actual_len') != "N", LEN(aArray), actual_len)

** if all of the array elements fit in the window, no need for the status bar
lDrawBar := (nLastEle > nBottom - nTop - 1)

** establish startup row for status bar
nBarLine := nTop + 2    && this will force status bar to be drawn on 1st pass


// determine initial element if not passed as parameter 13
//nInitRow   := IF(PCOUNT() < 14 .OR. nInitRow==NIL, 0, nInitRow)
nRelRow := nInitRow           && relative row for ACHOICE() window

// are we allowing the user to tag elements?
//lTagging := IF(PCOUNT() < 11 .OR. lTagging==NIL, .F., lTagging)

** add a spaces to each array element to even out hilite bar
FOR nLoop = 1 TO nLastEle
   aArray[nLoop] := PADR(aArray[nLoop],nRight-nLeft-2)
NEXT

** build parallel array for available choices by looping through main array
** unavailable selections will begin with a tilde ("~")
** you can also have horizontal lines for aesthetic purposes by having
** array elements of tilde and the character to use for the line.  For
** example, "~Ä" will be expanded into a line such as "ÄÄÄÄÄÄÄÄÄÄÄÄ" and
** will encompass the width of the achoice() box.

PRIVATE choices[nLastEle]
AFILL(choices, .T.)

FOR nLoop = 1 TO nLastEle
   IF SUBSTR(aArray[nLoop], 1, 1) = '~'
      choices[nLoop] := .F.
      aArray[nLoop]  := SUBSTR(aArray[nLoop], 2)
      *** see if they want to draw a horizontal line - if so, the trimmed
      *** length of this array element will now be one.
      IF LEN(TRIM(aArray[nLoop])) = 1
         aArray[nLoop] := REPLICATE(TRIM(aArray[nLoop]), nRight - nLeft - 1)
      ENDIF
   ENDIF
NEXT

** draw box and status bar
cOldColor := SETCOLOR(cBoxClr)

cScr:=DIALOG(nTop,nLeft,nBottom,nRight,cBoxTitle,'S',,cBoxClr,cTitleClr)

IF lDrawBar
   SETCOLOR(cBarClr)
   FOR nLoop = nTop + 1 TO nBottom - 1
      @ nLoop, nRight SAY '°'
   NEXT
ENDIF

//SETCOLOR(cBoxClr + ',' + hilite_clr + ',,,' + unsel_clr)
SETCOLOR(cBoxClr)

** stuff weirdo character into buffer to force drawing status indicator
** on 1st pass without actually moving the highlight bar - sneaky sneaky
KEYBOARD CHR(255)

DO WHILE .T.
   nChoice := ACHOICE(nTop + 1, nLeft + 1, nBottom - 1, nRight - 2, ;
      aArray, choices, 'dpick_func', nInitRow, nRelRow)
   IF LASTKEY() = K_RETURN .OR. LASTKEY() = K_ESC
      EXIT
   ENDIF
ENDDO

KillDialog(cScr)
SETCOLOR(cOldColor)

RETURN nChoice

*!*********************************************************************
*!
*!       Function: dPICK_FUNC()
*!
*!*********************************************************************
FUNCTION dpick_func(nStatus, nCurElem, nCurRow)
LOCAL nRetVal:=2,;
      nOldRow:=ROW(),;
      nOldCol:=COL(),;
      key:=LASTKEY(),;
      cOldColor,;
      nElem,;
      nLoop

MEMVAR lDrawBar, nBarLine, nMidPoint, nLastEle, cSearchStr
MEMVAR nTop, nLeft, nBottom, nRight, aArray, cBoxTitle, cBoxClr,;
       cTitleClr, cBarClr, actual_len, lTagging, nInitRow

DO CASE
   CASE nStatus = 0 .OR. key = 255    && idle or start-up
      cOldColor := SETCOLOR()
      IF lDrawBar
         ** draw arrows if there are elements beyond top or bottom of window
         ** first the bottom
         @ nBottom, nRight SAY IF(nLastEle - nCurElem >= nBottom - nOldRow, ;
            CHR(25), ' ')
         ** then the top
         @ nTop,nRight SAY IF(nOldRow - nCurElem < nTop, CHR(24), ' ')

         ** if status bar position has changed...
         IF nBarLine # nTop + 1 + ;
               INT((nCurElem / nLastEle) * (nBottom - nTop - 2))
            *** first, blank out previous status bar
            SETCOLOR(cBarClr)
            @ nBarLine, nRight SAY '°'
            *** then recalculate position of status bar
            nBarLine := nTop + 1 + INT((nCurElem/nLastEle)*(nBottom-nTop-2))
            *** finally, redraw it
            @ nBarLine, nRight SAY 'Û'
         ENDIF
      ENDIF
      SETCOLOR(cOldColor)

   CASE nStatus = 1
      nInitRow := nLastEle
      KEYBOARD CHR(255)        && force status bar display
      nRetVal := 0             && force ACHOICE() to restart

   CASE nStatus = 2
      nInitRow := 1
      KEYBOARD CHR(255)        && force status bar display
      nRetVal := 0             && force ACHOICE() to restart

   CASE nStatus = 3            && key exception
      DO CASE
         CASE key = K_ESC      && Esc to abort
            nRetVal := 0

         CASE key = K_ENTER    && Enter - made selection
            nRetVal := 1

         CASE key = K_HOME     && Home - jump to top
            KEYBOARD CHR(31)   && equivalent to Ctrl-PgUp
            nRetVal := 2

         CASE key = K_END      && End - jump to bottom
            KEYBOARD CHR(30)   && equivalent to Ctrl-PgDn
            nRetVal := 2

            *** Spacebar - tag this item if tagging is available
         CASE key = K_SPACE .AND. lTagging
            aArray[nCurElem] = LEFT(aArray[nCurElem], ;
               LEN(aArray[nCurElem]) - 1) + ;
               IF(RIGHT(aArray[nCurElem], 1) = " ", "û", " ")
            nInitRow:=nCurElem
            nRelRow:=nCurRow
            cSearchStr:=[]    && reset search string
            @ nBottom, nMidPoint SAY REPLICATE(CHR(205), 8)
            KEYBOARD CHR(24)
            nRetVal := 0       && Force ACHOICE redisplay

            *** F8: tag all items
         CASE key = K_F8 .AND. lTagging
            FOR nLoop = 1 TO nLastEle
               *** only process available choices
               IF choices[nLoop]
                  aArray[nLoop] := LEFT(aArray[nLoop], LEN(aArray[nLoop]) - 1) + CHR(251)
               ENDIF
            NEXT
            nInitRow   := nCurElem && save current position
            nRelRow := nCurRow  && and relative position
            nRetVal := 0         && Force ACHOICE redisplay

            *** F9: clear all tags
         CASE key = K_F9 .AND. lTagging
            FOR nLoop = 1 TO nLastEle
               *** only process available choices
               IF choices[nLoop]
                  aArray[nLoop] := LEFT(aArray[nLoop], LEN(aArray[nLoop]) - 1) + [ ]
               ENDIF
            NEXT
            nInitRow   := nCurElem && save current position
            nRelRow := nCurRow  && and relative position
            nRetVal := 0         && Force ACHOICE redisplay

            *** F10: reverse all tags
         CASE key = K_F10  .AND. lTagging       && reverse all tags
            FOR nLoop = 1 TO nLastEle
               *** only process available choices
               IF choices[nLoop]
                  aArray[nLoop] := LEFT(aArray[nLoop], LEN(aArray[nLoop]) - 1) + ;
                     IF(RIGHT(aArray[nLoop], 1) = " ", "û", " ")
               ENDIF
            NEXT
            nInitRow   := nCurElem && save current position
            nRelRow := nCurRow   && and relative position
            nRetVal := 0         && Force ACHOICE redisplay

            *** letter key
         CASE ISALPHA(CHR(key))
            cSearchStr := cSearchStr + CHR(key)
            nElem := ASCAN(aArray, cSearchStr)
            nInitRow := IF(nElem = 0, nCurElem, nElem)
            @ nBottom, nMidPoint SAY "[" + Pad(cSearchStr, 6) + "]"
            nRetVal := 0         && Force ACHOICE redisplay

         CASE key = K_LEFT .OR. key = K_BS
            IF LEN(cSearchStr) > 0
               cSearchStr := SUBSTR(cSearchStr, 1, LEN(cSearchStr) - 1)
               nElem := ASCAN(aArray, cSearchStr)
               nInitRow := IF(nElem = 0, nCurElem, nElem)
            ENDIF
            @ nBottom, nMidPoint SAY IF(LEN(cSearchStr) = 0, ;
               REPLICATE('Í', 8), "[" + PAD(cSearchStr, 6) + "]")
            //Force ACHOICE redisplay
            nRetVal:=0
      ENDCASE
ENDCASE

** restore proper screen coordinates
DEVPOS(nOldRow, nOldCol)

RETURN nRetVal
