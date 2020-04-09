* procedure Center
* parameters
*    cMessage  =  character string
*    nRow      =  numeric  row
*    optional ...
*    nLCol     =  numeric  left column
*    nRCol     =  numeric  right column
*
*    writes string to screen
*
* returns       NIL

PROCEDURE Center(cMessage, nRow, nLCol, nRCol)

nLCol := IIF(PCOUNT() < 3,  0, nLCol)  && no LEFT COLUMN parameter passed
nRCol := IIF(PCOUNT() < 4, 79, nRCol)  && no RIGHT COLUMN parameter passed

IF nRCol - nLCol > LEN(cMessage)  && validate coorinates
   @ nRow,nLCol + INT(((nRCol + 1 - nLCol) - LEN(cMessage)) / 2) SAY cMessage
ELSE     
   @ nRow,nLCol SAY SUBSTR(cMessage,1,MAX(0,nRCol + 1 - nLCol))
ENDIF

RETURN