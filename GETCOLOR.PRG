*ý***************************************************************
*      Function: GetColor()
*    Parameters: none
*       Returns: c -current get color string
*   Description: use to say 'xxx' color getcolor()
*****************************************************************
#INCLUDE "HACKINCL.CH"

FUNCTION GetColor()

LOCAL cGetColor

**** getting "get" colors & adding back colors to color string
cGetColor := SUBSTR(SETCOLOR(),AT(',',SETCOLOR()) + 1)
cGetColor := SUBSTR(cGetColor,1,AT(',',cGetColor) - 1)

RETURN cGetColor
