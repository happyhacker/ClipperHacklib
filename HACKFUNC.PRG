*.............................................................................
*
*   Program Name: HACKFUNC.PRG      Copyright: Hacksoft
*   Date Created: 07/11/90           Language: Clipper
*   Time Created: 20:46:15             Author: Larry Hack
*
*.............................................................................
* Revision: 1.0 Last Revised: 12/20/1989 at 16:05
* Description: Original Creation.
*.............................................................................
* Revision: 1.6 Last Revised: 07/11/90 at 20:47:48
* Description: Changed PTC_GRAPH to GRAPH_IT and it now can be displayed
*              on any line.
*...................................................................*
* Revision: 1.7 Modified on : 08-08-91 06:05:40pm By
* Description:Added ability to pass char. color to newcolor, ie;
*             NEWCOLOR(5,5,10,20,'W+/B')
***************************** ALL RIGHTS RESERVED ****************************
******************************************************************************
*   CDATE()
*   Larry Hack
*   02/02/89
*
*   Return the date in a 18 character string format
*
FUNCTION CDATE

PARAMETER XDATE

IF PCOUNT() = 0
   XDATE = DATE()
ENDIF

RETURN(TRIM(CMONTH(xdate))+' '+STR(DAY(xdate),2)+', '+STR(YEAR(xdate),4))
******************************************************************************
*   CTIME()
*   Larry Hack
*   02/02/89
*
*   Return the time in a 18 character string format
*
FUNCTION CTIME

PARAMETER XTIME

IF PCOUNT() = 0
   xtime = TIME()
ENDIF

xtime = LEFT(xtime,5)

IF VAL(xtime) < 12
   xampm = xtime + " am"
ELSEIF VAL(xtime) = 12
   xampm = xtime + " pm"
ELSE
   xampm = STR(VAL(xtime)-12,2) + SUBSTR(xtime,3) + " pm"
ENDIF

RETURN(xampm)
*
*
** eofunc CTIME()
******************************************************************************
*   CTR()
*   Larry Hack
*   02/02/89
*
*   Center a prompt. Returns string centered in length specified.
*
FUNCTION CTR

PARAMETER XSTR, XLEN

IF PCOUNT() = 1
   XLEN = 80
ENDIF

RETURN(SPACE(INT((XLEN-LEN(XSTR))/2)-1)+LTRIM(RTRIM(XSTR)))
*******************************************************************************
FUNCTION deleteit

PRIVATE xdel_yn, delete_it, pop_up
IF TYPE('pop_up') = 'U'
   pop_up = 'W+/BR,W+/BG'
ENDIF
OLDCOLOR = SETCOLOR()
DELETE_IT = SAVESCREEN(11,19,14,62)

SETCOLOR(pop_up)
SHDOW_BX(11,19,13,60,'S')
@ 12,21 SAY "MARK THIS RECORD FOR DELETION"
@ 12,52 PROMPT 'NO'
@ 12,56 PROMPT 'YES'
MENU TO xdel_yn

SETCOLOR(OLDCOLOR)
RESTSCREEN(11,19,14,62,DELETE_IT)

RETURN xdel_yn
******************************************************************************
FUNCTION EXIT

PRIVATE pop_up, xretv
IF TYPE('pop_up') = 'U'
   pop_up = 'W+/BR,W+/BG'
ENDIF
SET DEVI TO SCREEN
SET PRINT OFF
xretv = .T.
exit_scr = Savescreen(0,0,24,79)
exit_clr = SETCOLOR(pop_up)
SHDOW_BX(9,19,13,59,'S')
@ 11,22 SAY "ARE YOU SURE YOU WANT TO EXIT? Y/N"
INKEY(0)
IF LASTKEY() = ASC("Y") .OR. LASTKEY() = ASC("y")
   CLEAR GETS
   SET FORMAT TO
   BREAK
ELSE
   xretv = .F.
   SETCOLOR(exit_clr)
   RESTSCREEN(0,0,24,79,exit_scr)
ENDIF

RETURN xretv
******************************************************************************
*   GRAPH_IT([<expC1>], [<expN1>], [<expN2>, <expN3>])
*   Larry Hack
*   01/18/89
*
*   Display a graph of percent to completion. Useful for indexing.
*
*   Usage: GRAPH_IT(<expC1>), where:
*          <expC1> is a character string indicating INDEXING, UPDATING, etc.
*          <expN1> is a numeric indicating the row
*          <expN2> is a numeric indicating the position
*          <expN3> is a numeric indicating the total
*
*   example:
*           INDEX ON CODE+GRAPH_IT('INDEXING')
*   This would display INDEXING <FILENAME> RECORDS, PLEASE WAIT...

FUNCTION GRAPH_IT

PARAMETERS xstr, xrow, xpos, xtot
PRIVATE xptc
IF TYPE('pop_up') = 'U'
   pop_up = 'W+/BR,W+/BG'
ENDIF
IF TYPE('graph_clr') = 'U'
   graph_clr = 'GR+/W+'
ENDIF
oldclr = SETCOLOR()

IF PCOUNT() < 4
   IF PCOUNT() < 3
      xpos = RECNO()
   ENDIF
   IF PCOUNT() < 2
      xrow = 22
   ENDIF
   XTOT = LASTREC()
   IF PCOUNT() = 0
      xstr = 'Updating'
   ENDIF
ENDIF

IF XTOT = 0
   SETCOLOR(OLDCLR)
   RETURN('')
ENDIF
IF XPOS > XTOT
   SETCOLOR(OLDCLR)
   RETURN('')
ENDIF
IF XPOS = 1
   SETCOLOR(POP_UP)
   SHDOW_BX(xrow-2,3,xrow+1,76,'D')
   @ XROW-1, 4 SAY CTR(XSTR,72)
   SETCOLOR(graph_clr)
   @ XROW,12 SAY REPLICATE(CHR(176), 60)
   SETCOLOR(oldclr)
ENDIF
XPTC = XPOS / XTOT
SETCOLOR(pop_up)
@ XROW, 6 SAY XPTC*100 PICT '999%'
SETCOLOR(graph_clr)
@ XROW,12 SAY REPLICATE(CHR(219), XPTC*60)
SETCOLOR(OLDCLR)

RETURN('')
******************************************************************************
PROCEDURE INTPRN

XSELITE = CHR(32)
XCR     = CHR(32)

DO CASE
      ** EPSON LQ PRINTER CONTROL CODES
   CASE XPRTYPE = 1
      XSELITE = CHR(27)+CHR(77)
      XCR = CHR(13)

      ** OKIDATA 93 PRINTER CONTROL CODES
   CASE XPRTYPE = 2
      XSELITE = CHR(28)
      XCR = CHR(13)

      ** IBM PRINTER CONTROL CODES
   CASE XPRTYPE = 3
      XSELITE = CHR(27)+CHR(58)
      XCR = CHR(13)

      ** EPSON FX PRINTER CONTROL CODES
   CASE XPRTYPE = 4
      XSELITE = CHR(27)+CHR(77)
      XCR = CHR(13)
ENDCASE

SET DEVICE TO PRINT
SETPRN()
SET DEVICE TO SCREEN
RETURN
******************************************************************************
FUNCTION ISPRIN

PRIV old_clr, xretv, pop_up
IF TYPE('pop_up') = 'U'
   pop_up = 'W+/BR,W+/BG'
ENDIF

IF .NOT. ISPRINTER()
   SAVE SCREEN
   old_clr = SETCOLOR(pop_up)
   SHDOW_BX(11,30,13,50,'S')
   @ 12,32 SAY "NO PRINTER ONLINE"
   INKEY(5)
   SETCOLOR(old_clr)
   RESTORE SCREEN
   XRETV = .F.
ELSE
   XRETV = .T.
ENDIF
RETURN XRETV
******************************************************************************
PROCEDURE LOADING

PRIVATE old_color, pop_up
IF TYPE('pop_up') = 'U'
   pop_up = 'W+/BR,W+/BG'
ENDIF
old_color = SETCOLOR()
SETCOLOR(pop_up)
SHDOW_BX(9,25,12,55,'S')
@ 10,33 SAY "LOADING PROGRAM"
@ 11,33 SAY "  PLEASE WAIT"
SETCOLOR(old_color)
RETURN

*******************************************************************************
FUNCTION  NoRead                                 && valid picts: !!! or 9.99, dont mix
PARAMETER XRow,XCol,XPict,XAsterick           && returns whatever the user inputs
PRIVATE   I,ICtr,IStr, IPic, IAlpha, IChar, INum

IAlpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz '
IChar = "~`!@#$%^&*()_-+=|\[]{}:;<>,.?/' " + '"'
INum = '+-1234567890 '
ILog = 'TFtf'
IYorN = 'YNyn'
ICtr  = 0
IStr  = ''
XChar = .T.

Do While ICtr < Len(XPict)
   @ XRow,XCol+ICtr Say ''
   IPic = SUBSTR(XPict,ICtr+1,1)
   I = Inkey(0)
   Xchr = CHR(I)

   Do Case
      Case I = 27 .Or. I = 13                 && enter/esc
         Exit

      Case (I = 19 .Or. I = 8) .And. ICtr > 0  && back
         ICtr = ICtr - 1
         @ XRow,XCol + ICtr Say ' '
         IStr = Subs(IStr,1,ICtr)

      Case Xchr $ IChar .And. IPic $ '!X'     && char's
         @ XRow,XCol + ICtr Say iif(XAsterick, '*', Chr(I))
         XChar = .T.
         ICtr = ICtr + 1
         IStr = IStr + (Chr(I))

      Case Xchr $ IAlpha .And. IPic $ '!XAN'  && char's
         @ XRow,XCol + ICtr Say iif(XAsterick, '*', iif(IPic $ '!',Upper(Chr(I)),Chr(I)))
         XChar = .T.
         ICtr = ICtr + 1
         IStr = IStr + iif(IPic $ '!',Upper(Chr(I)),Chr(I))

      Case Xchr $ INum .And. IPic $ '!X#9N'   && numbers
         @ XRow,XCol + ICtr Say iif(XAsterick, '*', Chr(I))
         ICtr = ICtr + 1
         IStr = IStr + Chr(I)

      Case Xchr $ ILog .And. IPic $ 'L'       && Logical TF
         @ XRow,XCol + ICtr Say iif(XAsterick, '*', Upper(Chr(I)))
         ICtr = ICtr + 1
         IStr = IStr + Upper(Chr(I))

      Case Xchr $ IYorN .And. IPic $ 'Y'      && Logical YN
         @ XRow,XCol + ICtr Say iif(XAsterick, '*', Upper(Chr(I)))
         ICtr = ICtr + 1
         IStr = IStr + Upper(Chr(I))

      Otherwise
         Tone(300,1)
         LOOP
   Endcase

Enddo

Return iif(XChar, IStr, Val(IStr))
*******************************************************************************
PROCEDURE plswait2

PRIVATE old_color, pop_up
IF TYPE('pop_up') = 'U'
   pop_up = 'W+/BR,W+/BG'
ENDIF
old_color = SETCOLOR()
SETCOLOR(pop_up)

SHDOW_BX(10,23,13,51,'S')
@ 11,25 SAY "REMOVING UNWANTED RECORDS"
@ 12,25 SAY "  ONE MOMENT PLEASE..."

SETCOLOR(old_color)

RETURN
******************************************************************************
FUNCTION PRINT

PRIVATE wbbrbg, wbgwbr, wbrwbg
wbbrbg = 'W+/B,BR/BG'
wbgwbr = 'W+/BG,W+/BR'
wbrwbg = 'W+/BR,W+BG'
print = .F.
SETCOLOR(wbbrbg)
@ 0,0,24,79 BOX REPL('±',9)
SETCOLOR(wbgwbr)
SHDOW_BX(9,14,11,65,'S')
@ 10,20 SAY "DO YOU WANT A PRINTED REPORT ALSO? Y/N " GET print PICTURE 'Y'
READ
IF print
   SETCOLOR(wbgwbr)
   SHDOW_BX(9,10,12,70,'S')
   @ 10,12 SAY "MAKE SURE PRINTER IS TURNED ON AND AT THE TOP OF THE PAGE"
   @ 11,12 SAY '                PRESS ANY KEY TO PRINT'
   INKEY(0)
   IF ISPRIN()
      SET PRINT ON
      SET DEVICE TO PRINT
      SETPRC(0,PCOL())
   ENDIF
ENDIF

RETURN print
******************************************************************************
FUNCTION PRNTMEMO
* prints memo field
* returns part of memo not printed

PARAMETER xmemo, xtoprow, xmargin, xmaxrows
PRIVATE xcnt, xline

IF PCOUNT() < 4
   xmaxrows = 999
ENDIF
IF PCOUNT() < 3
   xmargin = 0
ENDIF
IF PCOUNT() < 2
   xtoprow = 0
ENDIF
xline = 0
DO WHILE xline < xmaxrows
   xline = xline + 1
   xcnt = AT(CHR(10),xmemo)
   IF xcnt = 0
      xmemo = ''
      EXIT
   ENDIF
   @ xtoprow,xmargin SAY SUBSTR(xmemo,1,xcnt-2)
   xtoprow = xtoprow + 1
   xmemo = SUBSTR(xmemo,xcnt+1)
ENDDO
RETURN xmemo
******************************************************************************
FUNCTION  Read_Col                               && returns current color, sets color to read color
PRIVATE   XCol, XNewCol, XTmp

XCol = SetColor()

XTmp = At(',',XCol)
If XTmp > 0
   XNewCol = Subs(XCol,XTmp+1,20)
   If ',' $ XNewCol
      XNewCol = Subs(XNewCol,1,At(',',XNewCol)-1)
   Endif
   Set Color To &XNewCol
Else
   Set Color To
Endif

Return XCol
******************************************************************************
PROCEDURE SETPRN
IF ISPRINTER()
   @ 0,1 SAY XSELITE
   @ 0,0 SAY XCR
ENDIF
RETURN
******************************************************************************
FUNCTION SHDOW_BX

PARA T,L,B,R,LINE

NEWCOLOR(T+1,L+2,B+1,R+2,7)
@ T,L CLEAR TO B,R
IF UPPER(LINE) = 'S'
   @ T,L TO B,R
ELSE
   @ T,L TO B,R DOUBLE
ENDIF

RETURN .T.
******************************************************************************
PROCEDURE SHOWMEM

@ 24,2 SAY "Memory:  " + LTRIM(STR(MEMORY(0))) + 'K'
RETURN
*******************************************************************************
FUNCTION STOP_PRN

PRIVATE in_key, xstopit, xretv, stop_it, pop_up
IF TYPE('pop_up') = 'U'
   pop_up = 'W+/BR,W+/BG'
ENDIF
IN_KEY = INKEY()

IF .Not. (IN_KEY = 27 .OR. IN_KEY = -8)       && ESC OR F9
   Return .F.
ENDIF

SET DEVI TO SCREEN
OLDCOLOR = SETCOLOR()
STOP_IT = SAVESCREEN(11,25,14,62)

SETCOLOR(pop_up)
SHDOW_BX(11,25,13,57,'S')
@ 12,27 SAY "STOP PRINTING REPORT?"
@ 12,49 PROMPT 'NO'
@ 12,53 PROMPT 'YES'
MENU TO xstopit

SETCOLOR(OLDCOLOR)
RESTSCREEN(11,25,14,62,STOP_IT)
SET DEVI TO PRINT
IF xstopit = 2
   x = x + 2
   @ x,0 SAY CTR("REPORT ABORTED BY USER",165)
ENDIF
RETURN (xstopit = 2)
