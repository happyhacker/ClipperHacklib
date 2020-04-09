FUNCTION AddMonth(dDate, nAddMonths)

LOCAL nYears, nMonths, nDay

nYears  := INT(nAddMonths / 12)
nMonths := nAddMonths - (nYears * 12)

IF MONTH(dDate) + nMonths > 12
   nMonths := nMonths - 12
   nYears  := nYears + 1
ENDIF

IF MONTH(dDate) + nMonths <= 0
   nMonths := nMonths + 12
   nYears  := nYears - 1
ENDIF

nMonths := MONTH(dDate) + nMonths

DO CASE
   CASE nMonths = 2
      nDay := MIN(28,DAY(dDate))
   CASE nMonths = 4 .OR. nMonths = 6 .OR. nMonths = 9 .OR. nMonths = 11
      nDay := MIN(30,DAY(dDate))
   OTHERWISE
      nDay := DAY(dDate)
ENDCASE

RETURN(CTOD(STR(nMonths,2) + '/' +;
            STR(nDay,2) + '/' +;
            STR(YEAR(dDate) + nYears,4)))