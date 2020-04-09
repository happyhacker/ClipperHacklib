* parameters
*   cIndex        <expc> := name of system index file
*   cDBF          <expc> := name of open database  required
*   lDispGraph    <expl> := logical to display graph,default =.f.   optional
*                           calls function graph_it()
*   nNtxNo        <expn> := index number to reindex ,0 =reindex all optional
* calls
*   GraphIt() - optional
* requires - dbf with following structure: (index dbf is first param passed)
* xxxxIDX.dbf - index on dbf to xxxxIDX.ntx := holds system dbf's & ntx info
*Structure for database  : INDICES.DBF
*Field  Field Name  Type       Width    Dec  Index
*    1  TAG         Character      1      0    N
*    2  DBF         Character      8      0    N
*    3  AREA        Numeric        2      0    N
*    4  INDEX_CNT   Numeric        2      0    N
*    5  NTXNAME1    Character      8      0    N
*    6  NTXNAME2    Character      8      0    N
*    7  NTXNAME3    Character      8      0    N
*    8  NTXNAME4    Character      8      0    N
*    9  NTXNAME5    Character      8      0    N
*   10  NTXNAME6    Character      8      0    N
*   11  NTXNAME7    Character      8      0    N
*   12  NTXNAME8    Character      8      0    N
*   13  NTXNAME9    Character      8      0    N
*   14  NTXNAME10   Character      8      0    N
*   15  INDEX1      Character     80      0    N
*   16  INDEX2      Character     80      0    N
*   17  INDEX3      Character     80      0    N
*   18  INDEX4      Character     80      0    N
*   19  INDEX5      Character     80      0    N
*   20  INDEX6      Character     80      0    N
*   21  INDEX7      Character     80      0    N
*   22  INDEX8      Character     80      0    N
*   23  INDEX9      Character     80      0    N
*   24  INDEX10     Character     80      0    N
*   25  DEFNTX1     Logical        1      0    N
*   26  DEFNTX2     Logical        1      0    N
*   27  DEFNTX3     Logical        1      0    N
*   28  DEFNTX4     Logical        1      0    N
*   29  DEFNTX5     Logical        1      0    N
*   30  DEFNTX6     Logical        1      0    N
*   31  DEFNTX7     Logical        1      0    N
*   32  DEFNTX8     Logical        1      0    N
*   33  DEFNTX9     Logical        1      0    N
*   34  DEFNTX10    Logical        1      0    N
***Total record length**         904
*
* return
*   lRet          <expl> := success of reindex
#INCLUDE 'INKEY.CH'
#DEFINE FULLBLOCK 3

*****************************************************************
*
*      Function: editntx1()
*
*    Parameters: c cIndex : name of system dbf file
*
*       Returns: l .t. if any dbf indexed
*
*    Description: use to select dbfs for reindexing
*
*****************************************************************
FUNCTION EDITNTX1
PARAMETERS cIndex
LOCAL cScr, cScr1, cScr2, cOldColor, aFNames[2], nCurse
PRIVATE lRet := .F.

nCurse    := SETCURSOR(0)
cOldColor := SETCOLOR('W+/B')

* open database
IF NET_USE(cIndex,.T.)
   SET INDEX TO (cIndex)

   afnames[1] := "TAG"
   afnames[2] := "DBF"
   cScr1 := Dialog(1,2,21,36,'TAG FOR REINDEXING',,,'N/G,W+/G')
   Center('[SPACE] = TAG   [ENTER] = INDEX',21,2,36)
   cScr2 := Dialog(2,41,14,76,'INDEXES','s')
   dbedit(2,3,20,35,afnames,"dbfunc1")
   KillDialog(cScr2)
   KillDialog(cScr1)
ENDIF

SETCOLOR(cOldColor)
SETCURSOR(nCurse)

RETURN lRet

**********************************************************************
STATIC FUNCTION DBFUNC1(nStatus)
LOCAL nRet, nKey

nKey := LASTKEY()
nRet := 1

DO CASE
   CASE nStatus = 0      && idle
      DO DISP_NTX

   CASE nStatus = 1      && bof() = .t.

   CASE nStatus = 2      && eof() = .t.

   CASE nStatus = 3      && empty dbf

   CASE nStatus = 4      && key stroke exception
      DO CASE
         CASE nKey = K_ESC
            nRet := 0

         CASE nKey = K_SPACE && check mark column toggle check mark or space
            REPLACE TAG  WITH IIF(TAG = CHR(251),CHR(176),CHR(251))
            nRet := 2

         CASE nKey = K_ENTER
            SELECT(cIndex)
            GO TOP
            nRecNo := RECNO()

            DO WHILE .NOT. EOF()
               IF TAG # CHR(251)
                  SKIP
                  nRecNo := RECNO()
                  LOOP
               ENDIF

               DO DISP_NTX
               Mdbf := dbf

               IF .NOT. NET_USE(MDBF,.T.)
                  ErrDraw(MDBF + ' NOT OPENED EXCLUSIVE')
               ELSE
                  SET INDEX TO
                  FINDEX(MDBF,.T.)
                  lRet := .T.
                  USE
               ENDIF

               SELECT(cIndex)
               GO nRecNo
               SKIP
               nRecNo := RECNO()
            ENDDO

            nRet := 0

         OTHERWISE
            TONE(150,1)
            nRet := 1
      ENDCASE
ENDCASE

RETURN nRet

**********************************************************************
STATIC PROCEDURE DISP_NTX

Center(PADC(' ' + ALLTRIM(DBF) + ' ',15,'Ä'),2,41,76)
@ ROW()+1,42 SAY "# TAG  INDEX name     INDEX key"
@ ROW()+1,42 SAY " 1 "+IIF(DEFNTX1,CHR(251),CHR(32)) +" "+NTXNAME1 +" "+SUBSTR(INDEX1 ,1,20)
@ ROW()+1,42 SAY " 2 "+IIF(DEFNTX2,CHR(251),CHR(32)) +" "+NTXNAME2 +" "+SUBSTR(INDEX2 ,1,20)
@ ROW()+1,42 SAY " 3 "+IIF(DEFNTX3,CHR(251),CHR(32)) +" "+NTXNAME3 +" "+SUBSTR(INDEX3 ,1,20)
@ ROW()+1,42 SAY " 4 "+IIF(DEFNTX4,CHR(251),CHR(32)) +" "+NTXNAME4 +" "+SUBSTR(INDEX4 ,1,20)
@ ROW()+1,42 SAY " 5 "+IIF(DEFNTX5,CHR(251),CHR(32)) +" "+NTXNAME5 +" "+SUBSTR(INDEX5 ,1,20)
@ ROW()+1,42 SAY " 6 "+IIF(DEFNTX6,CHR(251),CHR(32)) +" "+NTXNAME6 +" "+SUBSTR(INDEX6 ,1,20)
@ ROW()+1,42 SAY " 7 "+IIF(DEFNTX7,CHR(251),CHR(32)) +" "+NTXNAME7 +" "+SUBSTR(INDEX7 ,1,20)
@ ROW()+1,42 SAY " 8 "+IIF(DEFNTX8,CHR(251),CHR(32)) +" "+NTXNAME8 +" "+SUBSTR(INDEX8 ,1,20)
@ ROW()+1,42 SAY " 9 "+IIF(DEFNTX9,CHR(251),CHR(32)) +" "+NTXNAME9 +" "+SUBSTR(INDEX9 ,1,20)
@ ROW()+1,42 SAY "10 "+IIF(DEFNTX10,CHR(251),CHR(32))+" "+NTXNAME10+" "+SUBSTR(INDEX10,1,20)

RETURN


*!short: EDITNTX2.PRG
*****************************************************************
*
*      Function: editntx2()
*
*    Parameters: c cIndex : name of system dbf file
*
*       Returns: nil
*
*    Description: use to build or modify system dbf files
*
*****************************************************************
FUNCTION EDITNTX2
PARAMETERS cIndex
LOCAL cScr1, cScr2, cOldColor, nCurse
PRIVATE aFnames[0]

nCurse    := SETCURSOR(0)
cOldColor := SETCOLOR('W+/B')

* open database
IF NET_USE(cIndex,.T.)
   SET INDEX TO (cIndex)

   ASIZE(afnames,FCOUNT()) && build array of fields
   AFIELDS(afnames)        && fill arrays

   cScr1 := Dialog(1,0,21,36,'EDIT SYSTEM INDEXES',,,'N/G,W+/G')
   Center('[SPACE] TAG,[ENTER] EDIT,[ESC] QUIT',21,0,36)
   cScr2 := Dialog(2,41,14,76,'INDEXES','s')
   DBEDIT(2,1,20,35,AFNAMES,"DBFUNC2")
   KillDialog(cScr2)
   KillDialog(cScr1)
ENDIF

SETCOLOR(cOldColor)
SETCURSOR(nCurse)

RETURN NIL

**********************************************************************
STATIC FUNCTION DBFUNC2(nStatus, nFldPtr)
LOCAL nRet, nKey, cColor
PRIVATE cFName, cPict

nKey := LASTKEY()
nRet := 1

DO CASE
   CASE nStatus = 0      && idle
      DO DISP_NTX

   CASE nStatus = 1      && bof()=.t.

   CASE nStatus = 2      && eof()=.t.

   CASE nStatus = 3      && empty dbf

   CASE nStatus = 4      && key stroke exception
      DO CASE
         CASE nKey = K_ESC
            nRet := 0

         CASE nKey = K_SPACE  && mark column toggle CHECK MARK or SPACE
            REPLACE TAG WITH IIF(TAG = CHR(251),CHR(176),CHR(251))
            nRet := 2

         CASE nKey = K_ENTER .AND. nFldPtr # 1
            cFName := FIELD(nFldPtr)

            IF VALTYPE(&cFName) = 'N'
               cPict := '@9'
            ELSEIF VALTYPE(&cFName) = 'L'
               cPict := 'L'
            ELSE
               cPict := '@!S' + ALLTRIM(STR(MIN(LEN(&cFName),36 - COL()),2))
            ENDIF

            cColor := SETCOLOR('N/G,N/W')
            @ ROW(),COL() GET &cFName PICTURE '&cPict'
            READ
            SETCOLOR(cColor)
            nRet := 2

         CASE nKey = K_INS
            ADD_REC(0)
            KEYBOARD CHR(K_ENTER)
            nRet := 2

         CASE nKey = K_DEL
            IF YesNo('DELETE ' + ALLTRIM(DBF))
               DELETE
               SKIP IIF(EOF(),-1,1)
               PACK
               nRet := 2
            ENDIF

         OTHERWISE
            TONE(150,1)
            nRet := 1
      ENDCASE
ENDCASE

RETURN nRet

**********************************************************************
FUNCTION FINDEX
PARAMETERS cDBF, lDispGraph, nNtxNo
LOCAL lRet, lTag,  i, cScr, cErrMsg

PRIVATE nCounter, cNtxKey, cNtxFile, cType

EXTERNAL GraphIt

nOldDbf  := SELECT()
cScr     := SAVESCREEN(0,0,24,79)
cErrMsg  := ''
lRet     := .F.

BEGIN SEQUENCE
   * initial variables
   DO CASE
      CASE PCOUNT() = 0
         cErrMsg := 'NO DATABASE REQUESTED TO INDEX...'
         BREAK

      CASE PCOUNT() = 1
         lDispGraph := .F.
         nNtxNo     := 0

      CASE PCOUNT() = 2
         nNtxNo := 0

      CASE PCOUNT() = 3
         * all variables initialized - do nothing
   ENDCASE

   * open indices database
   IF NET_USE(cIndex)
      SET INDEX TO (cIndex)
   ELSE
      cErrMsg := ALLTRIM(cIndex) + '.DBF NOT FOUND, REINDEX FAILED...'
      BREAK
   ENDIF

   * find passed database
   SEEK cDBF

   IF .NOT. FOUND()
      cErrMsg := ALLTRIM(cDBF) + '.DBF NOT FOUND IN ' + ALLTRIM(cIndex) + '.DBF, REINDEX FAILED...'
      BREAK
   ENDIF

   * if passed database is not open return
   IF SELECT(cDBF) = 0
      cErrMsg := ALLTRIM(cDBF) + '.DBF NOT OPEN, REINDEX FAILED...'
      BREAK
   ENDIF

   * reindex based on third parameter
   SELECT SELECT(cDBF)

   IF nNtxNo = 0      && reindex all indexs with default flags in database
      FOR i = 1 TO 10
         nCounter := ALLTRIM(STR(i,2))
         lTag     := &cIndex.->(defntx&nCounter.)

         IF lTag
            cNtxKey  := &cIndex.->(index&nCounter.)
            cType    := TYPE("&cNtxKey.")
            cNtxFile := &cIndex.->(ntxname&nCounter.)

            IF lDispGraph .AND. .NOT. cType $ "UL"
               cNtxKey := cNtxKey + " + GraphIt(cNtxFile,cType)"
            ENDIF

            INDEX ON &cNtxKey. TO &cNtxFile.
            SET INDEX TO
            D_KILL_GRF(cNtxFile,&cIndex.->(index&nCounter.))
         ENDIF
      NEXT
   ELSE
      * reindex only called index regardless of default flag in database
      cNtxKey  := &cIndex.->index&nNtxNo
      cType    := TYPE("&cNtxKey.")
      cNtxFile := &cIndex.->ntxname&nNtxNo

      IF lDispGraph .AND. .NOT. cType $ "UL"
         cNtxKey := cNtxKey + " + GraphIt(cNtxFile,cType)"
      ENDIF

      INDEX ON &cNtxKey. TO  &cNtxFile.
      SET INDEX TO
      D_KILL_GRF(cNtxFile,&cIndex.->index&nNtxNo)
   ENDIF
   lRet := .T.
END SEQUENCE

IF .NOT. EMPTY(cErrMsg)
   ErrDraw(cErrMsg)
ENDIF

RESTSCREEN(0,0,24,79,cScr)

SELECT(nOldDbf)

RETURN lRet