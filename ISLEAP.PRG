FUNCTION ISLEAP(dDate)

LOCAL ;
    nYear := YEAR(dDate)

RETURN (nYear % 4 = 0 .AND. nYear % 100 # 0) .OR. nYear % 400 = 0
