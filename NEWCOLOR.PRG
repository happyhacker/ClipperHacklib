*========================={ NEWCOLOR.PRG }==========================
*...................................................................*
* Revision: 0000 Modified on :
* Description: Orignal creation By Larry Hack
*========================[ ALL RIGHTS RESERVED ]====================*
FUNCTION NEWCOLOR(top,left,bottom,right,cColor)
LOCAL cArea := 0, cBlock, cBlock1 := 0, cBlock2 := 0

cColor := IIF(PCOUNT() < 5,7,cColor)

// If para was passed as a character, convert to number
IF VALTYPE(cColor) = 'C'
   cColor := Clr2Num(cColor)
ENDIF

cArea  := SAVESCREEN(top,left,bottom,right)
cBlock := TRANSFORM(cArea, REPLICATE('x' + CHR(cColor),LEN(cArea)))

RESTSCREEN(top,left,bottom,right,cBlock)

RETURN .T.

**********************************************************************
STATIC FUNCTION Clr2Num(cColor)

LOCAL clr_array := {'N','B','G','BG','R','BR','GR','W'}
LOCAL clr1  := UPPER(SUBSTR(cColor,1,AT('/',cColor) - 1))
LOCAL clr2  := UPPER(RIGHT(cColor,LEN(cColor) - AT('/',cColor)))
LOCAL apos1 := ASCAN(clr_array,IF(RIGHT(clr1,1) == '+' ,SUBSTR(clr1,1,LEN(clr1) - 1),clr1)) - 1
LOCAL apos2 := ASCAN(clr_array,IF(RIGHT(clr2,1) == '+' ,SUBSTR(clr2,1,LEN(clr2) - 1),clr2)) - 1
cColor      := (16 * apos2) + IF(RIGHT(clr1,1) == '+' ,apos1 + 8,apos1)

RETURN cColor