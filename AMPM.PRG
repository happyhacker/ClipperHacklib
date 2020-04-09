FUNCTION AMPM(cTime,lUpper)

LOCAL ;
    cHour   ,;
    cRet    ,;
    nHour

cTime  := IIF(cTime == NIL,TIME(),cTime)
nHour  := VAL(cTime)
lUpper := IIF(lUpper == NIL,.F.,lUpper)

cHour  := IIF(nHour > 12,STR(nHour - 12,2),STR(nHour,2))
cRet   := cHour + SUBS(cTime,3,3) + IIF(nHour >= 12, ' pm',' am')

RETURN IIF(lUpper,UPPER(cRet),cRet)
