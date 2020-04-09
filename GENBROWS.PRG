* Copyright (c) 1992 Larry Hack, Hacksoft Inc.
*...................................................................*
* Revision: 0000 Modified on : 08-03-92 07:30:50am
* Description: Orignal creation By Larry Hack
*...................................................................*
* Revision: 1.2 Modified on : 09-04-92 05:20:08pm By Larry Hack
* Project #:
* Description:Add browse object to parameter list that is sent to passed keys
*...................................................................*
* Revision: 9209 Modified on : 10-27-92 10:52:08am By Larry Hack
* Project #:
* Description: CHANGED INKEY(0) TO DO WHILE IN BrowseExec
*========================[ ALL RIGHTS RESERVED ]====================*
#include "Inkey.ch"
#include "Setcurs.ch"
#include "Dbstruct.ch"
#include "Genbrows.ch"

STATIC cString := '',nType:=2

MEMVAR GETLIST

*Щ***************************************************************
*      Function: InitBrowse()
*    Parameters: <nTop>, <nLeft>, <nBottom>, <nRight>, <[Title]>,;
    *                <[aFields]>,<[aArray]>
*       Returns: NIL
*   Description: Initialize browse
*    Created by: Larry Hack   07-31-92
/* Notes: You can browse arrays or databases.  If you browse data
bases you can pass the column in the second element of
aFields as either a character or a codeblock. If you
pass it as a character it will be macro compiled for gets. If
you don't pass an array at all, it will create a column for every
field in the selected area.  */
*****************************************************************
FUNCTION InitBrowse(nTop, nLeft, nBottom, nRight, cTitle, aFields, aArray)

LOCAL ;
    cbField       ,;
    cColField     ,;
    nLength :=0   ,;
    nLoop :=0     ,;
    oBrowse       ,;
    oColumn

// Start with a new browse object from TBrowseDB()
oBrowse := TBrowseDB(nTop+1,nLeft+1,nBottom-1,nRight-1)
//oBrowse := TBrowseNew(nTop+1,nLeft+1,nBottom-1,nRight-1)

// Create columns from passed 2 diminsional array, if not passed, all fields
// Note:You must pass columns if browsing an array
nLength:=IF(aFields # NIL,LEN(aFields),FCOUNT())

FOR nLoop:=1 TO nLength
   // Builds columns from either passed 2 diminsional array or use all fields
   IF aFields # NIL
      // If character is passed, macro compile code block
      // Note:Browsing arrays require that you pass column as a codeblock
      IF VALTYPE(aFields[nLoop,2])=='C'
         cColField:=aFields[nLoop,2]
         cbField:=&('{|SetVal|IF(SetVal==NIL,'+cColField+','+cColfield+':=SetVal) }')
         oColumn := TBColumnNew(aFields[nLoop,1], cbField )
      ELSE
         // Use codeblock as is
         oColumn := TBColumnNew(aFields[nLoop,1], aFields[nLoop,2])
      ENDIF

		  // Add 3 element array to CARGO for PREBLOCK, POSTBLOCK, & PICTURE
      oColumn:CARGO:=ARRAY(3)

      // Add PREBLOCK, POSTBLOCK, & PICTURE TO CARGO IF EXISTS
      IF LEN(aFields[nLoop]) >= 3
         oColumn:CARGO[M_PREBLOCK]:=aFields[nLoop,3]
      ENDIF

      IF LEN(aFields[nLoop]) >= 4
         oColumn:CARGO[M_POSTBLOCK]:=aFields[nLoop,4]
      ENDIF

      IF LEN(aFields[nLoop]) >= 5
         oColumn:CARGO[M_PICTURE]:=aFields[nLoop,5]
      ENDIF

   ELSE
      oColumn := TBColumnNew(FIELD(nLoop),FieldWBlock(FIELD(nLoop),SELECT()))
      // Add 3 element array to CARGO for PREBLOCK, POSTBLOCK, & PICTURE
      oColumn:CARGO:=ARRAY(3)
   ENDIF

   // Add the column to the browse
   oBrowse:addColumn(oColumn)
NEXT

oBrowse:headSep:= "мям"
oBrowse:colSep := " Ё "

/* Cargo holds an array, the manifest constants defined in genbrows.ch are:
M_TITLE    Title
M_BORDER   Border; S,D, or T for single, double, or Thick
M_SHADOW   Shadow; .T. or .F.
M_GETS     Allow gets; M_ON, or M_OFF
M_DELCOL   Allow deletion of columns; M_ON, or M_OFF
M_DOSEEK   Display/accept seeks; M_ON, or M_OFF
M_MOVE     Allow box to be moved
M_RESIZE   Allow box to be resized
M_EXIT     Exit browse; .T.,.F.
M_VISIBLE  Whether or not browse is currently visible, .T.,.F.
M_SCREEN   Holder for saved screen of browse area only
M_HIDE     Whether browse screen should be erased on exit
M_FOOTER   Footer for tbrowse box
*/

oBrowse:Cargo := ARRAY(15)
IF VALTYPE(cTitle) == 'C'
   oBrowse:Cargo[M_TITLE] :=cTitle
ENDIF
oBrowse:Cargo[M_BORDER] :='S'
oBrowse:Cargo[M_SHADOW] :=M_ON
oBrowse:Cargo[M_GETS]   :=M_OFF
oBrowse:Cargo[M_DELCOL] :=M_OFF
oBrowse:Cargo[M_DOSEEK] :=M_OFF
oBrowse:Cargo[M_MOVE]   :=M_OFF
oBrowse:Cargo[M_RESIZE] :=M_OFF
oBrowse:Cargo[M_EXIT]   :=M_OFF
oBrowse:Cargo[M_VISIBLE]:=M_OFF
oBrowse:Cargo[M_SCREEN] :=' '
oBrowse:Cargo[M_HIDE]   :=M_ON
oBrowse:Cargo[M_OLDSCREEN]:=' '
oBrowse:Cargo[M_FOOTER]:=''

IF aArray # NIL
   // Add array element for row and customize movement blocks for arrays
   oBrowse:goTopBlock    := {|| oBrowse:CARGO[M_ROW]:=1}
   oBrowse:goBottomBlock := {|| oBrowse:CARGO[M_ROW]:=LEN(aArray)}
   oBrowse:skipBlock     := {|nNum, nAtNow| nAtNow := oBrowse:CARGO[M_ROW],;
                             oBrowse:CARGO[M_ROW]:=IIF(nNum > 0, MIN(LEN(aArray),;
                             oBrowse:CARGO[M_ROW] + nNum),MAX(1, oBrowse:CARGO[M_ROW] +;
                             nNum)), oBrowse:CARGO[M_ROW] - nAtNow }
ENDIF

RETURN oBrowse

*!short: BrowseExec     (_GENBROWS.PRG)
*Щ***************************************************************
*      Function: BrowseExec()
*    Parameters: <Browse object>,<[array of field descriptions and names]>
*       Returns: NIL
*   Description: Generic Browser for tbrowse objects
*    Created by: Larry Hack   07-31-92
*****************************************************************
FUNCTION BrowseExec(oBrowse, aMethods)

LOCAL ;
    cOldClr := SETCOLOR()  ,;
    lmore   := .T.         ,;
    nKey    := 0

IF VALTYPE(aMethods) == 'U'
   aMethods:={}
ENDIF

// Add current set keys to aMethods array
GetKeys(@aMethods)

// Save the whole screen since box might be moving all over the place
oBrowse:Cargo[M_OLDSCREEN]:=SAVESCREEN(0,0,MAXROW(),MAXCOL())

DO WHILE lMore .AND. .NOT. oBrowse:CARGO[M_EXIT]

   // Display the browse on the screen if needed
	 IF .NOT. oBrowse:CARGO[M_VISIBLE]
      DispBrowse(oBrowse)

			// Set visible to true so it doen't display again, this is in case
			// programmer exits out of browse and plans on coming back in
			// Requested by Ana
			oBrowse:CARGO[M_VISIBLE]:=.T.
	 ENDIF

   // Stabilize the display until it's stable or a key is pressed
   nKey := 0

   DO WHILE nKey == 0 .AND. .NOT. oBrowse:stable
      oBrowse:stabilize()
      nKey := InKey()
   ENDDO

   IF oBrowse:stable
      IF oBrowse:hitTop .OR. oBrowse:hitBottom
         TONE(125, 0)
      ENDIF

      // Make sure that the current record is showing up-to-date data
      // in case we are on a network.
      oBrowse:refreshCurrent()
      ForceStable(oBrowse)
      // Wait for user to do something
      nKey := 0
      DO WHILE nKey == 0 .AND. .NOT. oBrowse:CARGO[M_EXIT]
         nKey := INKEY()
      ENDDO
   ENDIF
   // Apply the key to the browse
   IF nKey # 0
      lMore:=ApplyKey(oBrowse,nKey,aMethods)
   ENDIF
ENDDO

IF oBrowse:CARGO[M_HIDE]==M_ON
   SETCOLOR(cOldClr)
   RESTSCREEN(0,0,MAXROW(),MAXCOL(),oBrowse:Cargo[M_OLDSCREEN])
ENDIF

RETURN NIL  && For now, mabey I can think of something useful to return later

*Щ***************************************************************
*      Function: ApplyKey()
*    Parameters: Browse object, key pressed
*       Returns: Logical
*   Description: Apply single keystroke to browse
*    Created by: Larry Hack   07-31-92
*****************************************************************
STATIC FUNCTION ApplyKey(oBrowse,nKey,aMethods)

LOCAL ;
    lRetVal := .T.   ,;
    nLoop   := 1     ,;
    nNum    := 0

// Apply one keystroke to the browse.
// Scan array if passed and run codeblock if found
IF aMethods # NIL
   // AEVAL(aMethods,{|nLoop| nNum:=ASCAN(aMethods[nLoop],nKey)})
   FOR nLoop:=1 TO LEN(aMethods)
      IF aMethods[nLoop,1]==nKey
         nNum:=nLoop
         EXIT
      ENDIF
   NEXT
ENDIF

IF nNum#0
   lRetVal:=EVAL(aMethods[nNum,2],PROCNAME(),PROCLINE(),READVAR(),oBrowse)
   // If function did not return logical, set to .T.
   IF VALTYPE(lRetVal) # 'L'
      lRetVal:=.T.
   ENDIF
ELSE

   DO CASE
         // Default stuff
      CASE nKey == K_ESC
         lRetVal:=.F.
      CASE nKey == K_DOWN
         oBrowse:down()
      CASE nKey == K_PGDN
         oBrowse:pageDown()
      CASE nKey == K_CTRL_PGDN
         oBrowse:goBottom()
      CASE nKey == K_UP
         oBrowse:up()
      CASE nKey == K_PGUP
         oBrowse:pageUp()
      CASE nKey == K_CTRL_PGUP
         oBrowse:gotop()
      CASE nKey == K_RIGHT
         oBrowse:right()
      CASE nKey == K_LEFT
         oBrowse:left()
      CASE nKey == K_HOME
         oBrowse:home()
      CASE nKey == K_END
         oBrowse:end()
      CASE nKey == K_CTRL_LEFT
         oBrowse:panLeft()
      CASE nKey == K_CTRL_RIGHT
         oBrowse:panRight()
      CASE nKey == K_CTRL_HOME
         oBrowse:panHome()
      CASE nKey == K_CTRL_END
         oBrowse:panEnd()

         // Optional stuff
      CASE nKey == K_DEL .AND. oBrowse:CARGO[M_DELCOL]==M_ON
         DelCol(oBrowse)
      CASE nKey == K_ALT_M .AND. oBrowse:CARGO[M_MOVE]==M_ON
         // Move tbrowse
         MoveBrowse(oBrowse)
      CASE nKey == K_ENTER .AND. oBrowse:CARGO[M_GETS]==M_ON
         //Get field
         GetField(oBrowse)
      CASE nKey == K_ALT_R .AND. oBrowse:CARGO[M_RESIZE]==M_ON
         //Resize tbrowse
         Resize(oBrowse)
      OTHERWISE
         IF oBrowse:CARGO[M_DOSEEK]==M_ON
            //Look-up
            SEEKIT(oBrowse,nKey)
         ENDIF
   ENDCASE
ENDIF

RETURN lRetVal

*Щ***************************************************************
*      Function: BrowseRow()
*    Parameters: oBrowse,nRow
*       Returns: nRow
*   Description: Increments Row counter for arrays
*    Created by: Larry Hack   08-21-92
*****************************************************************
FUNCTION BrowseRow(nRow)

STATIC nRow2:=1

IF nRow # NIL
   nRow2 := nRow
ENDIF

RETURN nRow2

*Щ***************************************************************
*      Function: ForceStable()
*    Parameters: Browse object
*       Returns: NIL
*   Description: Stablize the browse objec
*    Created by: Larry Hack   07-31-92
*****************************************************************
STATIC FUNCTION ForceStable(oBrowse)

DO WHILE .NOT. oBrowse:stabilize()
ENDDO

RETURN NIL

*Щ***************************************************************
*!short: GetKeys        (_GENBROW.PRG)
*      Function: GetKeys()
*    Parameters: Optional Methods array
*       Returns: 2 dimensional array of setkeys & associated codeblock
*   Description: Adds set keys and associated codeblock to array
*       Project:
*    Created by: Larry Hack   08-04-92
*****************************************************************
FUNCTION GetKeys(aMethods)

LOCAL ;
    cBlock     ,;
    nLoop := 0

IF aMethods == NIL
   aMethods := {}
ENDIF

FOR nLoop := -39 to 306
   cBlock := SETKEY(nLoop)
   IF cBlock # NIL
      AADD(aMethods,{nLoop,cBlock})
   ENDIF
NEXT

RETURN aMethods

// Misc. optional routines
*Щ***************************************************************
*      Function: SeekIt()
*    Parameters:
*       Returns: NIL
*   Description: Do a seek based on current index order
*    Created by: Larry Hack   08-25-92
*****************************************************************
STATIC FUNCTION SeekIt(oBrowse,nKey)

IF INDEXORD()#0
   IF nKey >= 32 .AND. nKey <= 126 .AND. LEN(cString) < 20
      cString := LTRIM(cString) + CHR(nKey)
   ELSEIF nKey == K_BS
      cString := SUBSTR(cString,1,LEN(cString) - 1)
   ENDIF
   @ oBrowse:nBottom + 1,oBrowse:nLeft + 2 SAY SPACE(20) COLOR GetColor()
   @ oBrowse:nBottom + 1,oBrowse:nLeft + 2 SAY cString COLOR GetColor()
   SEEK cString
   oBrowse:refreshAll()
   oBrowse:stable := .F.
ENDIF

RETURN NIL

*Щ***************************************************************
*      Function: MoveBrowse()
*    Parameters: Browse object
*       Returns: NIL
*   Description: Move browse object with cursor keys, home, & end
*       Project:
*    Created by: Larry Hack   08-21-92
*****************************************************************
STATIC FUNCTION MoveBrowse(oBrowse)

LOCAL ;
    cTempScr         ,;
    nHidth           ,;
    nKeyMove := 0    ,;
    nWidth

oBrowse:CARGO[M_SCREEN]:=SAVESCREEN(oBrowse:nTop-1,oBrowse:nLeft-1,;
                                    oBrowse:nBottom+1,oBrowse:nRight+1)
IF nType == 1
   cTempScr := SAVESCREEN(0,0,MAXROW(),MAXCOL())
   @ oBrowse:nTop - 1,oBrowse:nLeft - 1 TO oBrowse:nBottom + 1,;
       oBrowse:nRight + 1 COLOR 'W/N'
ENDIF

DO WHILE nKeyMove # K_ENTER
   nKeyMove := INKEY(0)
   DO CASE
      CASE nKeyMove ==  K_UP
         IF oBrowse:nTop -1 # 0
            oBrowse:nTop--
            oBrowse:nBottom--
         ENDIF
      CASE nKeyMove == K_DOWN
         IF oBrowse:nBottom+1 # MAXROW()
            oBrowse:nTop++
            oBrowse:nBottom++
         ENDIF
      CASE nKeyMove == K_LEFT
         IF oBrowse:nLeft -1 # 0
            oBrowse:nLeft--
            oBrowse:nRight--
         ENDIF
      CASE nKeyMove == K_RIGHT
         IF oBrowse:nRight+1 # MAXCOL()
            oBrowse:nLeft++
            oBrowse:nRight++
         ENDIF
      CASE nKeyMove == K_HOME
         nWidth:=oBrowse:nRight-oBrowse:nLeft
         nHidth:=oBrowse:nBottom-oBrowse:nTop
         IF oBrowse:nLeft#1
            oBrowse:nLeft:=1
            oBrowse:nRight:=oBrowse:nLeft+nWidth
         ELSE
            oBrowse:nTop:=1
            oBrowse:nBottom:=oBrowse:nTop+nHidth
         ENDIF
      CASE nKeyMove == K_END
         nWidth:=oBrowse:nRight-oBrowse:nLeft
         nHidth:=oBrowse:nBottom-oBrowse:nTop
         IF oBrowse:nRight#MAXCOL()-1
            oBrowse:nRight:=MAXCOL()-1
            oBrowse:nLeft:=oBrowse:nRight-nWidth
         ELSE
            oBrowse:nBottom:=MAXROW()-1
            oBrowse:nTop:=oBrowse:nBottom-nHidth
         ENDIF
   ENDCASE

   IF nType == 2
      // Restore whole screen
      DISPBEGIN()
      RESTSCREEN(0,0,MAXROW(),MAXCOL(),oBrowse:Cargo[M_OLDSCREEN])
      //Restore Box in new coordinates
      NEWCOLOR(oBrowse:nTop,oBrowse:nLeft,oBrowse:nBottom+2,;
          oBrowse:nRight+3,'W/N')
      RESTSCREEN(oBrowse:nTop-1,oBrowse:nLeft-1,;
          oBrowse:nBottom+1,oBrowse:nRight+1,oBrowse:CARGO[M_SCREEN])
      DISPEND()
   ENDIF

   IF nType == 1
      RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTempScr)
      @ oBrowse:nTop-1,oBrowse:nLeft-1 TO oBrowse:nBottom+1,;
          oBrowse:nRight+1 COLOR 'W/N'
   ENDIF

ENDDO

// Restore box at new coordinates
IF nType == 1
   RESTSCREEN(0,0,MAXROW(),MAXCOL(),oBrowse:Cargo[M_OLDSCREEN])
   NEWCOLOR(oBrowse:nTop,oBrowse:nLeft,oBrowse:nBottom+2,;
       oBrowse:nRight+3,'W/N')
   RESTSCREEN(oBrowse:nTop-1,oBrowse:nLeft-1,oBrowse:nBottom+1,;
       oBrowse:nRight+1,oBrowse:CARGO[M_SCREEN])
ENDIF

RETURN NIL

*Щ***************************************************************
*      Function: ReSize()
*    Parameters: Browse object
*       Returns: NIL
*   Description: Resizes the browse box and data
*    Created by: Larry Hack   08-25-92
*****************************************************************
STATIC FUNCTION Resize(oBrowse)

LOCAL ;
    cTempScr      ,;
    nKeySize := 0

cTempScr := SAVESCREEN(0,0,MAXROW(),MAXCOL())
@ oBrowse:nTop - 1,oBrowse:nLeft - 1 TO oBrowse:nBottom + 1,;
    oBrowse:nRight + 1 COLOR 'W/N'

DO WHILE nKeySize # K_ENTER
   nKeySize := INKEY(0)

   DO CASE
      CASE nKeySize ==  K_UP
         IF oBrowse:nBottom # oBrowse:nTop+1
            oBrowse:nBottom--
         ENDIF
      CASE nKeySize == K_DOWN
         IF oBrowse:nBottom+1 # MAXROW()
            oBrowse:nBottom++
         ENDIF
      CASE nKeySize == K_LEFT
         IF oBrowse:nRight # oBrowse:nLeft + 2
            oBrowse:nRight--
         ENDIF
      CASE nKeySize == K_RIGHT
         IF oBrowse:nRight+1 # MAXCOL()
            oBrowse:nRight++
         ENDIF
   ENDCASE

   RESTSCREEN(0,0,MAXROW(),MAXCOL(),cTempScr)
   @ oBrowse:nTop-1,oBrowse:nLeft-1 TO oBrowse:nBottom+1,;
       oBrowse:nRight+1 COLOR 'W/N'

ENDDO

// Restore box at new coordinates
RESTSCREEN(0,0,MAXROW(),MAXCOL(),oBrowse:Cargo[M_OLDSCREEN])
DispBrowse(oBrowse)

RETURN NIL

*****************************************************************
*      Function: DispBrowse()
*    Parameters: Browse object
*       Returns: NIL
*   Description: Display the browse
*    Created by: Larry Hack   09-17-92
*****************************************************************
Function DispBrowse(oBrowse)

LOCAL cOldClr:=SETCOLOR()
Dialog(oBrowse:nTop-1,oBrowse:nLeft-1,oBrowse:nBottom+1,;
    oBrowse:nRight+1,oBrowse:Cargo[M_TITLE],oBrowse:Cargo[M_BORDER],;
    oBrowse:Cargo[M_SHADOW],oBrowse:ColorSpec )

IF oBrowse:CARGO[M_DOSEEK] .AND. INDEXORD()#0
   @ oBrowse:nBottom+1,oBrowse:nLeft+1 SAY '['+SPACE(20)+']'
   @ oBrowse:nBottom+1,oBrowse:nLeft+2 SAY SPACE(20) COLOR GetColor()
ELSEIF .NOT. EMPTY(oBrowse:CARGO[M_FOOTER])
   @ oBrowse:nBottom+1,oBrowse:nLeft+2 SAY oBrowse:CARGO[M_FOOTER] COLOR oBrowse:ColorSpec
ENDIF

oBrowse:CARGO[M_SCREEN]:=SAVESCREEN(oBrowse:nTop-1,oBrowse:nLeft-1,;
                                    oBrowse:nBottom+1,oBrowse:nRight+1)
oBrowse:INVALIDATE()
oBrowse:REFRESHALL()

SETCOLOR(cOldClr)
RETURN NIL

*Щ***************************************************************
*      Function: GetField()
*    Parameters: Browse object
*       Returns: NIL
*   Description: Edit field in browse
*    Created by: Larry Hack   08-03-92
*****************************************************************
FUNCTION GetField(oBrowse)

LOCAL ;
    aGet,;
    nOldcurs  := SETCURSOR(2),;
		nRelations:= 0,;
		nParent   := SELECT(),;
    oColumn   := oBrowse:GETCOLUMN(oBrowse:colPos)

// create a corresponding GET
aGet := GETNEW(Row(),Col(),oColumn:block,oColumn:heading, , oBrowse:colorSpec)

// Modify get object if stuff is in column cargo
IF VALTYPE(oColumn:CARGO) == 'A'
   IF oColumn:CARGO[M_PREBLOCK] # NIL
      aGet:PreBlock:=oColumn:CARGO[M_PREBLOCK]
   ENDIF
   IF oColumn:CARGO[M_POSTBLOCK] # NIL
      aget:PostBlock:=oColumn:CARGO[M_POSTBLOCK]
   ENDIF
   IF oColumn:CARGO[M_PICTURE] # NIL
      aget:Picture:=oColumn:CARGO[M_PICTURE]
   ENDIF
ENDIF

// Lock current record
BEGIN SEQUENCE
IF .NOT. RecLock()
	 BREAK
ENDIF

// Lock any related records
DO WHILE DBRSELECT(++nRelations)#0
	 SELECT DBRSELECT(nRelations)
    IF .NOT. RecLock()
	    BREAK
	 ENDIF
   SELECT(nParent)
ENDDO

// Get & read it
READMODAL({aGet})

RECOVER
   SELECT(nParent)
   ErrDraw('Record or file already in use')
END

SETCURSOR(nOldcurs)   // reset cursor status

RETURN NIL

*Щ***************************************************************
*      Function: DelCol()
*    Parameters: Browse object
*       Returns: NIL
*   Description: Delete column from tbrowse
*       Project:
*    Created by: Larry Hack   08-03-92
*****************************************************************
STATIC FUNCTION DelCol(oBrowse)

oBrowse:DelColumn(oBrowse:ColPos)

IF oBrowse:ColCount==0
	 oBrowse:CARGO[M_EXIT]:=M_ON
ELSE
   oBrowse:RefreshAll()
ENDIF

RETURN NIL

*Щ***************************************************************
*      Function: InsToggle()
*    Parameters: None
*       Returns: NIL
*   Description: Toggle <Ins> key
*    Created by: Larry Hack   07-31-92
*****************************************************************
STATIC FUNCTION InsToggle()

IF READINSERT()
   READINSERT(.F.)
   SETCURSOR(SC_NORMAL)
ELSE
   READINSERT(.T.)
   SETCURSOR(SC_INSERT)
ENDIF

RETURN NIL
