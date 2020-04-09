*========================={ _HACKCAL.PRG }==========================
* Copyright (c) 1990 Larry Hack, Hacksoft Inc.
*.............................................................................
* Revision: 1.0 Last Revised: 12/20/1989 at 16:05
* Description: Original Creation.
*.............................................................................
* Revision: 1.5 Last Revised: 3/18/1990 at 16:41
* Description: Changed the way February's last day is calculated, line 350 HAC
*.............................................................................
* Revision: 1.7 Last Revised: 11/19/90 at 20:55:32
* Description: Can now start hackcal with date, 'hackday'
*.............................................................................
* Revision:  Last Revised: 11/19/90 at 20:56:24
* Description: Hackcal pops up on the opposite side of the cursor now
*.............................................................................
* Revision:  Modified on : 08-01-91 10:30:28pm By Larry Hack
* Description:Changed to function so you can pass para unstead of
* setting var for hackday. Also save & restore cursor, keyboard of
* date is done differently, & return hackday
* Note: This is 5.0 specific now.
*.............................................................................
* Revision:  Modified on : 08-01-91 11:44:16pm By Larry Hack
* Description:No longer redraws calendar for every move!
*...................................................................*
*========================[ ALL RIGHTS RESERVED ]====================*
#INCLUDE 'HACKINCL.CH'

FUNCTION HACKCAL

LOCAL xold_scr := SAVESCREEN(0,0,24,79)
LOCAL xcursor  := SET(_SET_CURSOR,0)
SET KEY -1 TO     && turn off f2 -no recursive calls

PARAMETERS hackday, line, variable
// If called by a set key the 1st para would be 'procedure', ie; P,L,V
// If called as a function, there is only 1 para.
IF PCOUNT() # 1
   hackday := DATE()
ENDIF

PRIVATE xcol,xmonth
PRIVATE st_col,no_days, max_days, m_day

IF COL() > 40
   xcol := 1
ELSE
   xcol := 45
ENDIF

curr_color := SETCOLOR()
newcolor(2,xcol+2,23,xcol+30,7)

m_day    := DAY(hackday)
m_month  := MONTH(hackday)
m_year   := YEAR(hackday)
max_days := 0


DO disp_cal                                          && Display calendar
disp_hdate(hackday)                                  && Display heading date
find_col(CTOD(STR(m_month,2)+'/01/'+STR(m_year,4)))  && Find starting column
disp_days(hackday)                                   && Display days

xtype    := TYPE(READVAR())
selected := .F.

DO WHILE .T.
   IF m_month = 2
      max_days := IF(INT(m_year/4)=m_year/4,29,28)
   ELSE
      max_days := IF(STR(m_month,2)$' 1 3 5 7 8 10 12',31,30)
   ENDIF
   IF .NOT. selected
      KEY := INKEY(0)
   ENDIF

   IF KEY = K_ESC .OR. selected
      SETCOLOR(curr_color)
      RESTSCREEN(0,0,24,79,xold_scr)
      SET KEY -1 TO hackcal  && set f2 back to hackcal
      IF selected
         xmonth := IF(m_month < 10,'0' + LTRIM(STR(m_month)),LTRIM(STR(m_month)))
         xday   := IF(m_day < 10,'0' + LTRIM(STR(m_day)),LTRIM(STR(m_day)))
         hackday:= CTOD(xmonth + '/' + xday + '/' + SUBSTR(STR(m_year),-2))

         IF xtype = 'D'
            KEYBOARD xmonth + xday + SUBSTR(STR(m_year),-2)
         ELSE
            KEYBOARD DTOC(hackday)  &&xmonth + '/' + xday + '/' + SUBSTR(STR(m_year),-2)
         ENDIF
      ENDIF
      EXIT
   ENDIF

   DO CASE
      CASE KEY = K_CTRL_PGUP
         m_year := m_year-1
         DO setdays

      CASE KEY = K_CTRL_PGDN
         m_year := m_year+1
         DO setdays

      CASE KEY = K_PGUP
         m_month := m_month-1
         IF m_month < 1
            m_month := 12
            m_year  := m_year-1
         ENDIF

         DO setdays

      CASE KEY = K_PGDN
         m_month := m_month+1
         IF m_month > 12
            m_month := 1
            m_year  := m_year+1
         ENDIF
         DO setdays

      CASE KEY = K_LEFT
         m_day := m_day-1
         IF m_day < 1
            m_day := 1
         ENDIF

      CASE KEY = K_RIGHT
         m_day := m_day+1
         IF m_day > max_days
            m_day := m_day-1
         ENDIF

      CASE KEY = K_UP
         m_day := m_day-7
         IF m_day < 1
            m_day := m_day+7
         ENDIF

      CASE KEY = K_DOWN
         m_day := m_day+7
         IF m_day > max_days
            m_day := m_day-7
         ENDIF

      CASE KEY = K_ENTER
         selected := .T.
         LOOP
   ENDCASE

   IF m_month = 2
      max_days := IF(INT(m_year/4)=m_year/4,29,28)
   ELSE
      max_days := IF(STR(m_month,2)$' 1 3 5 7 8 10 12',31,30)
   ENDIF

   IF m_day > max_days
      m_day := max_days
   ENDIF

   *--- Check to see if the current date is the last day of the month.
   m_date := CTOD(STR(m_month,2)+'/'+STR(m_day,2)+'/'+STR(m_year,4))
   find_col(CTOD(STR(m_month,2)+'/01/'+STR(m_year,4)))
   disp_hdate(m_date)

   IF key # K_LEFT .AND. key # K_RIGHT .AND. key # K_UP .AND. key # K_DOWN
      clear_date(xcol+1)
   ENDIF

   disp_days(m_date)
ENDDO

SET(_SET_CURSOR,xcursor)

RETURN hackday

*!*********************************************************************
*!
*!      Procedure: DISP_CAL
*!
*!      Called by: HACKCAL.PRG
*!
*!*********************************************************************
STATIC PROCEDURE disp_cal
SET COLOR TO +BG/N
@  1,xcol,22,xcol+28 BOX "зд©ЁыдюЁ "
@  3,xcol SAY "ц"
@  3,xcol+28 SAY "╢"
@  5,xcol SAY "ц"
@  5,xcol+28 SAY "╢"
@  7,xcol SAY "ц"
@  7,xcol+28 SAY "╢"
@  9,xcol SAY "ц"
@  9,xcol+28 SAY "╢"
@ 11,xcol SAY "ц"
@ 11,xcol+28 SAY "╢"
@ 13,xcol SAY "ц"
@ 13,xcol+28 SAY "╢"
@ 15,xcol SAY "ц"
@ 15,xcol+28 SAY "╢"
@ 17,xcol SAY "ц"
@ 17,xcol+28 SAY "╢"
@  3,xcol+ 1 SAY "дддбдддбдддбдддбдддбдддбддд"
@  4,xcol+ 4 SAY "Ё   Ё   Ё   Ё   Ё   Ё"
@  5,xcol+ 1 SAY "дддедддедддедддедддедддеддд"
@  6,xcol+ 4 SAY "Ё   Ё   Ё   Ё   Ё   Ё"
@  7,xcol+ 1 SAY "дддедддедддедддедддедддеддд"
@  8,xcol+ 4 SAY "Ё   Ё   Ё   Ё   Ё   Ё"
@  9,xcol+ 1 SAY "дддедддедддедддедддедддеддд"
@ 10,xcol+ 4 SAY "Ё   Ё   Ё   Ё   Ё   Ё"
@ 11,xcol+ 1 SAY "дддедддедддедддедддедддеддд"
@ 12,xcol+ 4 SAY "Ё   Ё   Ё   Ё   Ё   Ё"
@ 13,xcol+ 1 SAY "дддедддедддедддедддедддеддд"
@ 14,xcol+ 4 SAY "Ё   Ё   Ё   Ё   Ё   Ё"
@ 15,xcol+ 1 SAY "дддедддедддедддедддедддеддд"
@ 16,xcol+ 4 SAY "Ё   Ё   Ё   Ё   Ё   Ё"
@ 17,xcol+ 1 SAY "дддадддадддадддадддадддаддд"
SET COLOR TO +W/B
@  2,xcol+ 1 SAY SPACE(27)
SET COLOR TO +R/B
@  4,xcol+ 1 SAY "Sun"
@  4,xcol+ 5 SAY "Mon"
@  4,xcol+ 9 SAY "Tue"
@  4,xcol+13 SAY "Wed"
@  4,xcol+17 SAY "Thu"
@  4,xcol+21 SAY "Fri"
@  4,xcol+25 SAY "Sat"
SET COLOR TO GR+/B
@ 18,xcol+ 1 SAY "     "+CHR(26)+" "+CHR(27)+ "   Highlight Date"
@ 19,xcol+ 1 SAY " PgDn PgUp    Up/Down Month"
@ 20,xcol+ 1 SAY "Ctrl PgDn PgUp Up/Down Year"
@ 21,xcol+ 1 SAY "<Enter> Select   <Esc> Exit"
RETURN

* Comment: This procedure will display the new heading date for the calendar.
*
*!*********************************************************************
*!
*!      Procedure: DISP_HDATE
*!
*!      Called by: HACKCAL.PRG
*!
*!*********************************************************************
STATIC FUNCTION disp_hdate(mdate)

SET COLOR TO RG+/B
@ 2,xcol  + 2 SAY SPACE(25)
@ 2,xcol  + 4 SAY CMONTH(mdate)
@ 2,COL() + 2 SAY DAY(mdate)
@ 2,COL() + 2 SAY YEAR(mdate)
RETURN NIL

* Comment    : This procedure will display the date on the calendar.
*
*!*********************************************************************
*!      Procedure: DISP_DAYS
*!      Called by: HACKCAL.PRG
*!          Calls: LAST_DAY       (procedure in HACKCAL.PRG)
*!*********************************************************************
STATIC FUNCTION disp_days(m_date)

st_row := 6
last_day(MONTH(m_date), YEAR(m_date))

FOR X = 1 TO no_days
   SET COLOR TO W
   *--- If x=current day, display in reverse video.
   IF X = DAY(m_date)
      SET COLOR TO N/W
   ENDIF

   @st_row,st_col SAY STR(X,2)

   st_col := st_col+4
   st_col := IF(st_col>xcol+26,xcol+1,st_col)
   st_row := IF(st_col=xcol+1,st_row+2,st_row)
NEXT

RETURN NIL

*!*********************************************************************
*!      Procedure: CLEAR_DATE
*!      Called by: HACKCAL.PRG
*!*********************************************************************
STATIC FUNCTION clear_date(st_col)

st_row := 6
no_days:= 42
SET COLOR TO W

FOR X = 1 TO no_days
   @st_row,st_col SAY '  '

   st_col := st_col+4
   st_col := IF(st_col>xcol+26,xcol+1,st_col)
   st_row := IF(st_col=xcol+1,st_row+2,st_row)
NEXT

RETURN NIL

*!*********************************************************************
*! Comment    : This procedure will find the starting column's depend which day is the first
*!      Procedure: FIND_COL
*!      Called by: HACKCAL.PRG
*!*********************************************************************
STATIC FUNCTION find_col(mdate)

fst_day := DOW(mdate)
C       := xcol + 1

FOR X = 1 TO 7
   IF fst_day = X
      st_col := C
      EXIT
   ENDIF
   C := C + 4
NEXT

RETURN NIL

*!*********************************************************************
*!  Comment    : This procedure will find the maximum no. of days of a
*!               particular month.
*!      Procedure: LAST_DAY
*!      Called by: DISP_DAYS      (procedure in HACKCAL.PRG)
*!*********************************************************************
STATIC FUNCTION last_day(mmonth,myear)

IF mmonth = 2
   no_days := IF(INT(myear/4)=myear/4,29,28)
ELSE
   no_days := IF(STR(mmonth,2)$' 1 3 5 7 8 10 12',31,30)
ENDIF

RETURN NIL

*!*********************************************************************
*!      Procedure: SETDAYS
*!      Called by: HACKCAL.PRG
*!*********************************************************************
STATIC PROCEDURE setdays

IF m_day > max_days
   m_day := max_days
ENDIF