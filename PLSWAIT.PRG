*========================={ PLSWAIT.PRG }==========================
#INCLUDE 'HACKINCL.CH'
FUNCTION PlsWait(cMsg,cBorder,lShadow,cColor,nRow)

LOCAL nLCol, nRCol, cScr, nLen, cDevice := SET(_SET_DEVICE,'SCREEN')
DEFAULT nRow To 11

IF PCOUNT() < 4 .OR. cColor==NIL
   cColor := 'W+/BR'

   IF PCOUNT() < 3 .OR. lShadow==NIL
      lShadow := .T.

      IF PCOUNT() < 2 .OR. cBorder==NIL
         cBorder := 'S'

         IF PCOUNT() < 1 .OR. cMsg==NIL
           cMsg := ''
         ENDIF
      ENDIF
   ENDIF
ENDIF

cMsg  := ALLTRIM(cMsg)
nLen  := MAX(LEN(cMsg),20)            && 20 MAX for ' Please wait... '
nLCol := (40 - (nLen / 2)) - 2
nRCol := (40 + (nLen / 2)) + 1
cScr  := Dialog(nRow,nLCol,nRow+2,nRCol,'',cBorder,.T.,cColor)

Center(cMsg,nRow+1)
Center(' Please wait... ',IIF(EMPTY(cMsg),nRow+1,nRow+2))

SET(_SET_DEVICE,cDevice)

RETURN cScr
