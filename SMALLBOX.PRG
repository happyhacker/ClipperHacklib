*============================={ SMALLBOX.PRG }==============================
* Copyright (c) 1992 Hacksoft
*...........................................................................*
* Revision: 0000
* Created on : ? By Larry Hack
* Description: Creates a small box
*==========================[ ALL RIGHTS RESERVED ]==========================*
FUNCTION SMALLBOX(nRow,nCol,cString,cClr)
LOCAL cCurBkGrndClr:=SUBSTR(SETCOLOR(),AT('/',SETCOLOR())+1,AT(',',SETCOLOR()))
LOCAL cNewClr:='N/'+cCurBkGrndClr
LOCAL nLoop:=0

IF VALTYPE(cClr)=='NIL'
   cClr:=SETCOLOR()
ENDIF

// This is very cryptic but all it does is replace the shadow area with a
// block in block on a background that was on the screen
cShadow:=SAVESCREEN(nRow+1,nCol+1,nRow,nCol+1+LEN(cString))
FOR nLoop:=1 TO LEN(cString)*2 STEP 2
   cShadow:=STUFF(cShadow,nLoop,1,'ß')
   cShadow:=STUFF(cShadow,nLoop+1,1,ShadowClr(SUBSTR(cShadow,nLoop+1,1) )  )
NEXT
RESTSCREEN(nRow+1,nCol+1,nRow,nCol+LEN(cString),cShadow)

// Store only 1 position for shadow on end of string
cShadow:=SAVESCREEN(nRow,nCol+LEN(cString),nRow,nCol+LEN(cString))
//@ nRow,nCol+LEN(cString) SAY 'Ü' COLOR cNewClr
cShadow:=STUFF(cShadow,1,1,'Ü')
cShadow:=STUFF(cShadow,2,1,ShadowClr(SUBSTR(cShadow,2,1) )  )
RESTSCREEN(nRow,nCol+LEN(cString),nRow,nCol+LEN(cString),cShadow)

@ nRow,nCol SAY cString COLOR cClr

RETURN NIL


FUNCTION ShadowClr(cClr)
LOCAL cRetVal:=cClr

DO CASE
   CASE ASC(cClr) >=0 .AND. ASC(cClr) <16
      cRetVal:=CHR(0)
   CASE ASC(cClr) >=16 .AND. ASC(cClr) <32
      cRetVal:=CHR(16)
   CASE ASC(cClr) >=32 .AND. ASC(cClr) <48
      cRetVal:=CHR(32)
   CASE ASC(cClr) >=48 .AND. ASC(cClr) <64
      cRetVal:=CHR(48)
   CASE ASC(cClr) >=64 .AND. ASC(cClr) <80
      cRetVal:=CHR(64)
   CASE ASC(cClr) >=80 .AND. ASC(cClr) <96
      cRetVal:=CHR(80)
   CASE ASC(cClr) >=96 .AND. ASC(cClr) <112
      cRetVal:=CHR(96)
   CASE ASC(cClr) >=112
      cRetVal:=CHR(112)
ENDCASE

RETURN cRetVal
