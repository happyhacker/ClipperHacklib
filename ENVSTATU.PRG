*============================={ ENVSTATU.PRG }==============================
* Copyright (c) 1994 Hacksoft
*...........................................................................*
* Revision: 0000
* Created on : 06-09-94 12:02:18pm By Larry Hack
* Description: Displays various status information
*==========================[ ALL RIGHTS RESERVED ]==========================*
#INCLUDE "HACKINCL.CH"
//#INCLUDE 'INKEY.CH'
//#INCLUDE 'ERROR.CH'

PROCEDURE EnvStatus(cProc,nLine,cVar)

LOCAL ;
    aSaveKeys[2]  ,;
    bBlock        ,;
    cScr          ,;
    nCursor       ,;
    nOldCursor := SET(_SET_CURSOR,0)

MEMVAR ;
    nOldDbf       ,;
    lExit         ,;
    xpop_up

PRIVATE ;
    nOldDbf := SELECT(),;
    lExit   :=.F.

xpop_up := IIF(TYPE('xpop_up') = 'U','W+/BR',xpop_up)
cScr    := Dialog(1,5,22,74,"ENVIRONMENT STATUS",'D',.T.,xpop_up)

bBLock := {||PAGE1(cProc,nLine,cVar,nOldDbf)}

DO WHILE .NOT. lExit       && lExit is set in codeblock of exit choice
   @ 2,6 CLEAR TO 21,73
   bBlock = eval(bBlock)
ENDDO

SELECT(nOldDbf)
KillDialog(cScr)

SET(_SET_CURSOR,nOldCursor)

RETURN

**********************************************************************
* 02-18-92 added cType for type of var, local vars not available -fjs

STATIC FUNCTION PAGE1(cProc,nLine,cVar,nOldDbf)

LOCAL ;
    bBlock        ,;
    cOldColor     ,;
    cOldError     ,;
    cScr          ,;
    cType         ,;
    GETLIST[0]    ,;
    lCont   := .T.,;
    nArea   :=0   ,;
    nChoice :=0   ,;
    nCursor       ,;
    nPos

MEMVAR ;
    cCommand      ,;
    cParameters

PRIVATE ;
    cCommand      ,;
    cParameters

//cType := IIF(TYPE(cVAR) $ 'UE~UI','LOCAL',VALTYPE(&cVAR))
cType := VALTYPE(cVAR)

@  3, 7 SAY "PROCEDURE: " + IIF(VALTYPE(cProc)='U','Undefined',cProc)
@  3,30 SAY "LINE: " + IIF(VALTYPE(nLine)='U','Undefined',STR(nLine,6) )
@  3,43 SAY "VARIABLE: " + IIF(VALTYPE(cVar)='U','Undefined',ALLTRIM(cVar) )

@  4,43 SAY "    TYPE: " + cType                && VALTYPE(&cVAR)
@  5, 7 SAY "MEMORY: " + ALLTRIM(STR(MEMORY(0))) + 'K'
@  5,30 SAY "PRINTER IS: " + IIF(ISPRINTER(),'ONLINE','OFFLINE')
@  7, 7 SAY "SETTINGS: CLIPPER -" + GETENV('CLIPPER')
@  7,COL() + 2 SAY "; BLINKER -" + GETENV('BLINKER')
*@  7,50 SAY 'OVL SIZE: ' + ALLTRIM(STR(BLIOVLSIZ()))
@  9, 7 SAY "CURRENT DIRECTORY: " + CURDIR()
@ 10,19 SAY "DATABASES  RECORDS      ON   FIELDS   INDEX KEY"
@ 11, 7 SAY "SELECT  1 :"
@ 12, 7 SAY "SELECT  2 :"
@ 13, 7 SAY "SELECT  3 :"
@ 14, 7 SAY "SELECT  4 :"
@ 15, 7 SAY "SELECT  5 :"
@ 16, 7 SAY "SELECT  6 :"
@ 17, 7 SAY "SELECT  7 :"
@ 18, 7 SAY "SELECT  8 :"
@ 19, 7 SAY "SELECT  9 :"
@ 20, 7 SAY "SELECT 10 :"

DO WHILE nArea <= 9      &&  CHANGED FROM 10 HMB 10/25/91
   nArea++
   SELECT(nArea)

   IF .NOT. EMPTY(ALIAS())
      @ nArea + 10,19 SAY ALIAS() COLOR IIF(nArea = nOldDbf,"W+/B",Setcolor())
      @ nArea + 10,29 SAY RECCOUNT() PICTURE "999,999"

      IF EOF()
         @ nArea + 10,41 SAY "EOF"
      ELSE
         @ nArea + 10,37 SAY RECNO() PICTURE "999,999"
      ENDIF

      @ nArea + 10,48 SAY FCOUNT()    PICTURE "999"
      @ nArea + 10,56 SAY Indexkey(0) PICTURE "XXXXXXXXXXXXXXXX"
   ENDIF
ENDDO

SELECT(nOldDbf)

Center(' [ESC] Exit, [PGDN] Next Page ',22)

DO WHILE .T.
   nChoice := INKEY(0)

   IF nChoice = K_ESC
      bBlock := {||MENUEXIT()}
      EXIT

   ELSEIF nChoice = K_PGDN
      bBlock := {||Page2(cProc,nLine,cVar,nOldDbf)}
      EXIT

   ELSEIF nChoice = ASC('?')
      BEGIN SEQUENCE
         lCont     := .T.
         cOldError := ERRORBLOCK({|x| ENVERR(x)})     //save old errorblock
         cScr      := SAVESCREEN(00,00,23,79)         //and replace with custom
         cOldColor := SETCOLOR('N/W,N/W')
         cCommand  := SPACE(75)

         DO WHILE lCont
            @ 23,00 TO 23,79
            cCommand := PADR(cCommand,75)
            @ 23,00 SAY '.'
            @ 23,01 GET cCommand PICTURE '@!'
            READ
            cCommand := ALLTRIM(cCommand)
            DEVPOS(23,0)
            DEVOUT('Í> ')
            DEVOUT(SPACE(75))
            DEVPOS(23,3)

            DO CASE
               CASE 'QUIT' $ cCommand .OR. LASTKEY() = K_ESC
                  lCont := .F.

               CASE LEFT(cCommand,1) # '?'
                  nPos        := AT('(',cCommand)
                  cParameters := SUBS(cCommand,nPos + 1,LEN(cCommand) - nPos - 1)
                  cCommand    := SUBS(cCommand,1,nPos - 1)
                  IF EMPTY(cParameters)
                     &cCommand()
                  ELSE
                     &cCommand(&cParameters)
                  ENDIF

                  INKEY(0)

               CASE LEFT(cCommand,1) = '?'
                  cCommand := ALLTRIM(SUBS(cCommand,2))

                  IF TYPE('&cCommand') $ 'UI~UE' .OR. &cCommand = NIL
                     DEVOUT(PADR(cCommand + ' is NOT available!',75))
                  ELSE
                     DEVOUT(&cCommand)
                  ENDIF
                  cCommand := '? ' + cCommand
                  INKEY(0)
            ENDCASE
         ENDDO
      END SEQUENCE

      bBlock := {||Page1(cProc,nLine,cVar,nOldDbf)}
      SETCOLOR(cOldColor)
      RESTSCREEN(00,00,23,79,cScr)
      ERRORBLOCK(cOldError)
      EXIT
   ENDIF
ENDDO

RETURN bBlock

**********************************************************************
STATIC FUNCTION PAGE2(cProc,nLine,cVar,nOldDbf)

LOCAL ;
    bBlock        ,;
    nLEVEL  := 2  ,;
    nChoice := 0

@ 2,35 TO 20,35
@ 2,15 SAY "CALL STACK"
@ 2,50 SAY "MEMORY"
@ 3, 7 SAY "Called by :"

DO WHILE .NOT. EMPTY(PROCNAME(nLEVEL)) .AND. nLEVEL < 21
   @ 2 + nLEVEL, 8 SAY PROCNAME(nLEVEL)
   @ 2 + nLEVEL,20 SAY "LINE # " + STR(PROCLINE(nLEVEL),6)
   nLevel++
ENDDO

@  4,36 SAY "MEMORY FOR CHARACTER VARIABLES"
@  5,45 SAY "MEMORY(0) :" + STR(MEMORY(0),5) + "K"
@  7,36 SAY "LARGEST CONTIGUOUS BLOCK FOR CHARACTER"
@  8,45 SAY "MEMORY(1) :" + STR(MEMORY(1),5) + "K"
@ 10,36 SAY "MEMORY FOR RUN COMMANDS"
@ 11,45 SAY "MEMORY(2) :" + STR(MEMORY(2),5) + "K"
@ 13,36 SAY "ROUGH ESTIMATE OF VIRTUAL MEMORY USAGE"
@ 14,45 SAY "MEMORY(3) :" + STR(MEMORY(3),5) + "K"
@ 16,36 SAY "UNUSED EXPANDED MEMORY PRESENT"
@ 17,45 SAY "MEMORY(4) :" + STR(MEMORY(4),5) + "K"

Center(' [ESC] Exit, [PGUP] Prior Page ',22)

DO WHILE .T.
   nChoice := INKEY(0)
   IF nChoice = K_ESC
      bBlock := {||MENUEXIT()}
      EXIT
   ELSEIF nChoice = K_PGUP
      bBlock := {||Page1(cProc,nLine,cVar,nOldDbf)}
      EXIT
   ENDIF
ENDDO

RETURN bBlock

**********************************************************************
STATIC PROCEDURE MenuExit

MEMVAR ;
    lExit

lExit = .T.

RETURN

**********************************************************************
STATIC FUNCTION EnvErr(e)

ErrDraw('ENV_STATUS() ERROR MESSAGE:',ErrorMessage(e))

BREAK

RETURN .T.

/***
*  ErrorMessage()  FROM ERRORSYS.PRG
*/

static func ErrorMessage(e)
local cMessage

   // start error message
   cMessage := if( e:severity > ES_WARNING, "!Error ", "!Warning " )


   // add subsystem name if available
   if ( ValType(e:subsystem) == "C" )
      cMessage += e:subsystem()
   else
      cMessage += "???"
   end


   // add subsystem's error code if available
   if ( ValType(e:subCode) == "N" )
      cMessage += ("/" + NTRIM(e:subCode))
   else
      cMessage += "/???"
   end

   // add error description if available
   if ( ValType(e:description) == "C" )
      cMessage += ("  " + e:description)
   end


   // add either filename or operation
   if ( !Empty(e:filename) )
      cMessage += (": " + e:filename)

   elseif ( !Empty(e:operation) )
      cMessage += (": " + e:operation)

   end

return (cMessage)
