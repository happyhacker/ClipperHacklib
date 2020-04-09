*    Parameters: dDate - optional
*    Returns: date  mm/dd/yy
*    Description: Calculates last day in month

FUNCTION EOM(dDate)

LOCAL ;
    dRet

IF dDate == NIL
   dDate := DATE()
ENDIF

dRet := dDate + 35 - DAY(dDate)

RETURN dRet - DAY(dRet)
