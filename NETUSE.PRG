*=========================={ NETUSE.PRG }===========================
FUNCTION NetUse(cFilename, lExclUse, nWait, cAliasName)

LOCAL ;
    cBox   := '',;
    cMessage    ,;
    lAliasExists,;
    lOpenSuccess := .F.  ,;
    nLeft       ,;
    nLen        ,;
    nRight      ,;
    cTemp       ,;
    nTry

cFilename  := UPPER(ALLTRIM(cFilename))

IF ".DBF" $ cFilename
   cFilename := SUBS(cFilename, 1, LEN(cFilename) - 4)
ENDIF


cAliasName   := IIF(cAliasName # NIL, GetAlias(cAliasName), GetAlias(cFileName))
lExclUse     := IIF(lExclUse = NIL, .F., lExclUse)
nWait        := IIF(nWait = NIL, 5, nWait)

nTry         := nWait
lAliasExists := SELECT(cAliasName) # 0
cTemp  = IIF('.' $ cFileName,cFileName,cFileName + '.DBF')

IF FILE(cTemp)
   MEMORY(-1)
   DO WHILE (nWait >= 0) .AND. .NOT. lOpenSuccess
      IF lAliasExists
         SELECT (cAliasName)
         IF lExclUse
            IF ISALPHA(cAliasName)
               USE (cFilename) ALIAS &cAliasName EXCLUSIVE
            ELSE
               USE (cFilename) EXCLUSIVE
            ENDIF
         ELSE
            IF ISALPHA(cAliasName)
               USE (cFilename) ALIAS &cAliasName SHARED
            ELSE
               USE (cFilename) SHARED
            ENDIF
         ENDIF
      ELSE
         IF lExclUse
            IF ISALPHA(cAliasName)
               USE (cFilename) ALIAS &cAliasName EXCLUSIVE NEW
            ELSE
               USE (cFilename) EXCLUSIVE NEW
            ENDIF
         ELSE
            IF ISALPHA(cAliasName)
               USE (cFilename) ALIAS &cAliasName SHARED NEW
            ELSE
               USE (cFilename) SHARED NEW
            ENDIF
         ENDIF
      ENDIF

      IF .NOT. NETERR()
         lOpenSuccess := .T.
      ELSE
         INKEY(1)

         IF nWait = 0
            IF .NOT. EMPTY(cBox)
               KillDialog(cBox)
               cBox := ''
            ENDIF

            IF YesNo(ALLTRIM(cFilename) + ' IS LOCKED...TRY AGAIN?')
               cMessage := "TRYING TO UNLOCK " + ALLTRIM(cFilename) + " FILE..."
               nLen     := LEN(cMessage)
               nLeft    := (40-(nLen/2))-2
               nRight   := (40+(nLen/2))+1
               cBox     := Dialog(10,nLeft,12,nRight,'','S',.T.,'W+/BR')
               Center(cMessage,11)
               Center(' Please Wait .... ',12)
               nWait := nTry + 1
            ENDIF
         ENDIF
         nWait--
      ENDIF
   ENDDO

   IF .NOT. EMPTY(cBox)
      KillDialog(cBox)
   ENDIF
ELSE
   ErrDraw(cTemp + ' NOT FOUND...','Check System Set-up')
ENDIF

RETURN (lOpenSuccess)
