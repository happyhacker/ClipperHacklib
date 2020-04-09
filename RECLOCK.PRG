*ý***************************************************************
*      Function: RecLock
*    Parameters: logical - keep trying until user says no?
*       Returns: logical - .t. if record successfully locked
*   Description: a new way of locking a record - doesn't force retries
*****************************************************************
#INCLUDE 'HACKINCL.CH'
FUNCTION RecLock(lTryUntil)
LOCAL lRet

DEFAULT lTryUntil TO .T.
lRet := RLOCK()

IF .NOT. lRet .AND. lTryUntil
   DO WHILE .NOT. lRet .AND. YesNo(ALIAS() + " RECORD " + NTRIM(RECNO()) + " IS LOCKED...TRY AGAIN?")
      lRet := RLOCK()
   ENDDO
ENDIF

RETURN lRet
