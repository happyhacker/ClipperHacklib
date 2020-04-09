*========================={ STRIPALI.PRG }==========================
*****************************************************************
*      Function: StripAlias()
*    Parameters: c -string to strip alias from
*       Returns: c -string without alias
*    Description: readvar() in 5.01 returns the alias along with the field
*                 name -this will strip off the alias
*****************************************************************
FUNCTION StripAlias(cVar)

LOCAL nPosition := AT('>',cVar)

IF .NOT. EMPTY(nPosition)
   cVar := SUBS(cVar,nPosition + 1)
ENDIF

RETURN cVar