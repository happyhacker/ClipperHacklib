*ý***************************************************************
*      Function: D_Filter
*    Parameters: ANY DBF ALIAS
*       Returns: A FILTER ARRAY
*   Description: LETS USER CREATE A FILTER CONDITION
*****************************************************************
#INCLUDE "HACKINCL.CH"
#INCLUDE "GENBROWSE.CH"

FUNCTION Filter(cDBF, aFilter)

LOCAL                 ;
   N                 ,;
   aDBF              ,;
   aFields           ,;
   aRetn             ,;
   cAlias            ,;
   cClr              ,;
   cNext             ,;
   cScr              ,;
   lConfirm          ,;
   lEsc              ,;
   lLoop := .T.      ,;
   lPop              ,;
   nChoice           ,;
   nOldCursor        ,;
   nOldRow := BrowseRow()

DEFAULT aFilter TO {}

lConfirm   :=  SET( _SET_CONFIRM , .T.       )
lEsc       :=  SET( _SET_ESCAPE,.F.          )
nOldCursor :=  SETCURSOR( 0                  )

cAlias  := ALIAS(             ) // Used to restore to origl workarea SELECTed
SELECT     SELECT( cDbf       )
aDBF    := DBSTRUCT(          ) // Used for pick box of filter conditions
cScr    := SAVESCREEN(        ) // Restore screen before RETURNing
cClr    := SETCOLOR("W/B,W+/R")

CLS

// Add Alias name to fields in the aDBF array //
FOR N := 1 TO LEN(aDbf)
   aDBF[N,1] := ALLTRIM(cDBF) + "->" + aDBF[N,1]
NEXT

DO WHILE lLoop
   lPop    := .T.
   nChoice := MENU_BOX()     // Create, Reset or Proceed

   DO CASE
      CASE nChoice = 1  // CREATE
         IF .NOT. EMPTY(aFilter)
            IF YesNo("Erase Present Query?", .F.)
               aFilter := {}
            ELSE
               DISP_STR(aFilter)  // display query to screen
               cNext := POP_NEXT(aFilter)  // start with and/or/done
               IF cNext = "done"
                  lPop := .F.
               ELSE
                  aFilter := MAKE_NEXT(aFilter, cNext)
               ENDIF
            ENDIF
         ENDIF
         CLS

         DO WHILE lPop
            aFilter := POP_FIELDS(aDBF,aFilter)
            DISP_STR(aFilter) // redisplay because want browse to restore scrn
            IF LASTKEY() = K_ESC .AND. EMPTY(aFilter)
               lPop := .NOT. YesNo("FINISHED WITH QUERY?")
            ENDIF
            IF lPop .AND. .NOT. EMPTY(aFilter)
               cNext := POP_NEXT(aFilter)
               IF cNext = "done"
                  DISP_STR(aFilter)
                  lPop := .F.
               ELSE
                  aFilter := MAKE_NEXT(aFilter, cNext)
               ENDIF
            ENDIF
         ENDDO

      CASE nChoice = 2  // RESET
         IF YesNo("ERASE QUERY?")
            CLS
            aFilter := {}
            ErrDraw(" QUERY HAS BEEN ERASED " )
         ENDIF

      CASE nChoice = 3 //PROCEED
         lLoop := .F.
   ENDCASE
ENDDO

SET( lConfirm         )
SET( lEsc             )
SETCURSOR( nOldCursor )
SETCOLOR( cClr        )
RESTSCREEN( ,,,,cScr  )
SELECT SELECT(cAlias)

// MAKE TWO CHARACTER STRINGS FROM THE 2-DIMENSIONAL aFilter AND   //
// RETURN A 1-DIMENSIONAL, 2-ELEMENT aFilter WHERE THE 1st ELEMENT //
// IS THE FILTER STRING & THE 2nd ELEMENT IS THE DESCRIPTION       //

aRetn := {"",""}

IF .NOT. EMPTY(aFilter)
   FOR N := 1 TO LEN(aFilter)
      aRetn[1] := aRetn[1] + aFilter[N,1]
      aRetn[2] := aRetn[2] + aFilter[N,2] + aFilter[N,3]
   NEXT
ENDIF

BrowseRow(nOldRow)

RETURN aRetn


*ý***************************************************************
*      Function: MENU_BOX
*    Parameters: NONE
*       Returns: nChoice
*   Description: NON GENERIC MENU TO FUNCTION
*       Project:
*    Created by: Phil Boyer   09-22-92
*****************************************************************
STATIC FUNCTION MENU_BOX

LOCAL              ;
   cBox           ,;
   nChoice

cBox := Dialog(01,00,03,30,,,,"W+/BR,N/W")

SET MESSAGE TO 03
@ 02, 04 PROMPT "Create"   MESSAGE "ÈÍ[    Create a new query    ]"
@ 02, 12 PROMPT "Reset"    MESSAGE "ÈÍ[    Clear present query   ]"
@ 02, 19 PROMPT "Proceed"  MESSAGE "ÈÍ[     Query is complete    ]"

MENU TO nChoice

KillDialog(cBox)

RETURN  nChoice

*ý***************************************************************
*      Function: POP_FIELDS
*    Parameters: aDBF, aFilter
*       Returns: aFilter
*   Description: ADDDS FIRST FIELD TO NEXT CONDITON
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC FUNCTION POP_FIELDS(aDBF,aFilter)

LOCAL                    ;
   aFields := {}        ,;
   aKeys := {}          ,;
   cAdd                 ,;
   nChoice              ,;
   nOldRow              ,;
   oBrowse

BrowseRow(1)

AADD(aFields , { "SELECT FIELD"  , { | | aDBF[BrowseRow(),1]         } } )

AADD(aKeys   , {K_ENTER , { | | nOldRow := BrowseRow(), ;
   aFilter := MAKE_FIELD(aDBF[BrowseRow(),1],aFilter), ;
   aFilter := POP_OPER(aDBF,aFilter , aDBF[BrowseRow()]), ;
   IIF(LASTKEY() <> K_ESC, oBrowse:CARGO[M_EXIT] := .T.,), ;
   BrowseRow(nOldRow) } } )

AADD(aKeys , {K_ESC , { | |  IIF(.NOT. EMPTY(aFilter) , aFilter := ;
   ASIZE(aFilter, LEN(aFilter)-1 ) , ), ;
   oBrowse:CARGO[M_EXIT] := .T.  } } )

IF .NOT. EMPTY(aFilter)
   DISP_STR(aFilter)
ENDIF

oBrowse := InitBrowse(13,02,22,35,,aFields,aDBF)
oBrowse:COLORSPEC := "B/W,W/B"
oBrowse:GETCOLUMN(1):WIDTH := 21
BrowseExec(oBrowse,aKeys)

RETURN aFilter

*ý***************************************************************
STATIC FUNCTION MAKE_FIELD(cAdd, aFilter)

IF LASTKEY() <> K_ESC
   IF EMPTY(aFilter)
      aFilter := { { "",  "ALL RECORDS WHERE " , "" } }
   ENDIF
   aFilter[LEN(aFilter),1] := aFilter[LEN(aFilter),1] +  cAdd
   aFilter[LEN(aFilter),3] := aFilter[LEN(aFilter),3] + "( " + cAdd
ENDIF

DISP_STR(aFilter)

RETURN aFilter

*ý***************************************************************
*      Function: POP_OPER
*    Parameters: aDBF, aFilter
*       Returns: aFilter
*   Description: ADDS A OPERATOR TO THE CONDITON IN aFilter
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC FUNCTION POP_OPER(aDBF,aFilter,aElement)

LOCAL                       ;
   aFields := {}           ,;
   aKeys   := {}           ,;
   aOPER   := {}           ,;
   cAdd                    ,;
   cType   := aElement[2]  ,;
   nOldRow                 ,;
   oBrowse

BrowseRow(1)

AADD(aFields, { "SELECT COMPARISON" , { | | aOPER[BrowseRow()]  } } )

AADD(aKeys , {K_ENTER ,{ || nOldRow := BrowseRow(), aFilter := ;
   MAKE_OPER(BrowseRow(),aFilter,cType), ;
   aFilter := POP_VALUE(aDBF,aFilter,aElement[2]),IIF(LASTKEY() <> ;
   K_ESC,oBrowse:CARGO[M_EXIT] := .T.,), BrowseRow(nOldRow)  } } )

AADD(aKeys, { K_ESC , { | |  aFilter[LEN(aFilter),3] := ""  , ;
   aFilter[LEN(aFilter),1] := ""  , ;
   oBrowse:CARGO[M_EXIT] := .T. } } )

AADD(aOPER, "equal to                 ")
AADD(aOPER, "not equal to             ")

// IF FIELD IS LOGICAL IT WILL ONLY HAVE = AND # AS OPTIONS //
IF aElement[2] <> "L"
   AADD(aOPER, "greater than             ")
   AADD(aOPER, "greater than or equal to ")
   AADD(aOPER, "less than                ")
   AADD(aOPER, "less than or equal to    ")
   AADD(aOPER, "in the range             ")
   AADD(aOPER, "not in the range         ")
   AADD(aOPER, "in the list              ")
   AADD(aOPER, "not in the list          ")
ENDIF

oBrowse := InitBrowse(10,18,23,44,,aFields,aOPER)
oBrowse:COLORSPEC := "B/W,W/B"
BrowseExec(oBrowse,aKeys)

RETURN aFilter

*ý***************************************************************
*    Function: MAKE_OPER
*  Parameters: n, aFilter, cType
*     Returns: aFilter
* Description: ADDS OPERATOR TO THE AFILTER[N,1&3] ELEMENTS
*  Created by: Phil Boyer   10-01-92
*****************************************************************
STATIC FUNCTION MAKE_OPER(n,aFilter,cType)

DO CASE
   CASE n = 1  // "equal to"
      IF cType = "C"

      aFilter[LEN(aFilter),1] := IIF("." $ aFilter[LEN(aFilter),1], ;
                                 STRTRAN(aFilter[LEN(aFilter),1], ". ",". ALLTRIM(",1,1);
                                 + ") == " , ;  //(ELSE)
                                 "ALLTRIM(" + aFilter[LEN(aFilter),1] + ") ==  ")
      ELSE

      aFilter[LEN(aFilter),1] := aFilter[LEN(aFilter),1] + " = "

      ENDIF


      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is equal to " )

   CASE n = 2  // "not equal to"
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " #  "  )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is not equal to " )

   CASE n = 3  //  "greater than"
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " >  "  )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is greater than " )

   CASE n = 4  //  "greater than or equal to"
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " >= " )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is greater than or equal to " )

   CASE n = 5  //  "less than"
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " <  "  )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is less than " )

   CASE n = 6  //  "less than or equal to"
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " <= " )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is less than or equal to " )

   CASE n = 7  //  "in the range"
      IF "." $ aFilter[LEN(aFilter),1]
         aFilter[LEN(aFilter),1] := STRTRAN(aFilter[LEN(aFilter),1] , ". " , ". (" , 1 , 1 )
      ELSE
         aFilter[LEN(aFilter),1] := "(" + aFilter[LEN(aFilter),1]
      ENDIF
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " >=(" )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is in the range of " )

   CASE n = 8  //  "not in the range"
      IF "." $ aFilter[LEN(aFilter),1]
         aFilter[LEN(aFilter),1] := STRTRAN(aFilter[LEN(aFilter),1] , ". " , ". (" , 1 , 1 )
      ELSE
         aFilter[LEN(aFilter),1] := "(" + aFilter[LEN(aFilter),1]
      ENDIF
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " < (" )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is not in the range of " )

   CASE n = 9  //  "in the list"
      IF "." $ aFilter[LEN(aFilter),1]
         aFilter[LEN(aFilter),1] := STRTRAN(aFilter[LEN(aFilter),1] , ". " , ". (" , 1 , 1 )
      ELSE
         aFilter[LEN(aFilter),1] := "(" + aFilter[LEN(aFilter),1]
      ENDIF
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " $ (" )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is in the list " )

   CASE n = 10  // "not in the list"
      IF "." $ aFilter[LEN(aFilter),1]
         aFilter[LEN(aFilter),1] := STRTRAN(aFilter[LEN(aFilter),1] , ". " , ". ( '.NOT. " , 1 , 1 )
      ELSE
         aFilter[LEN(aFilter),1] := "( .NOT. " + aFilter[LEN(aFilter),1]
      ENDIF
      aFilter[LEN(aFilter),1] := (aFilter[LEN(aFilter),1] + " $ (" )
      aFilter[LEN(aFilter),3] := (aFilter[LEN(aFilter),3] + ;
         " is not in the list " )
ENDCASE

DISP_STR(aFilter)

RETURN aFilter

*ý***************************************************************
*      Function: IN_RANGE
*    Parameters: lVar, aFilter, cType
*       Returns: aFilter
*   Description:
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC FUNCTION IN_RANGE(lVar, aFilter, cType)

LOCAL                                ;
   cAdd1                            ,;
   cAdd2                            ,;
   cAndOr := " .AND. "              ,;
   cBox                             ,;
   cField                           ,;
   cOperator := " <= "              ,;
   cPict                            ,;
   cTitle := "IN THE RANGE OF:"     ,;
   nBeg                             ,;
   nCursor                          ,;
   nEnd                             ,;
   xRange1                          ,;  // CAN BE ANY DATA TYPE
   xRange2                              // CAN BE ANY DATA TYPE

MEMVAR ;
   GETLIST

// get the name of the field that we are using in this filter //

aFilter[LEN(aFilter),1] := SUBSTR(aFilter[LEN(aFilter),1] , 1, LEN(aFilter[LEN(aFilter),1])-1 )

IF "." $ aFilter[LEN(aFilter),1]
   nBeg :=  AT(". (" , aFilter[LEN(aFilter),1] )+3
   nEnd :=  LEN(aFilter[LEN(aFilter),1])- 2 - nBeg
ELSE
   nBeg    :=  2
   nEnd    :=  AT(" " , aFilter[LEN(aFilter),1] ) - nBeg
ENDIF

cField := SUBSTR(aFilter[LEN(aFilter),1] , nBeg , nEnd)

IF .NOT. lVar
   cTitle    :=  "NOT IN THE RANGE OF:"
   cOperator :=  " > "
   cAndOr    :=  " .OR. "
ENDIF

DO CASE
   CASE cType = "C" .OR. cType = "M"
      cPict := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      xRange1 := SPACE(30)
      xRange2 := SPACE(30)

   CASE cType = "D"
      cPict := "99/99/99"
      xRange1 := CTOD("  /  /  ")
      xRange2 := CTOD("  /  /  ")

   CASE cType = "N"
      cPict := "999999999999999999999999999999"
      xRange1 := SPACE(30)
      xRange2 := SPACE(30)
ENDCASE

cBox := Dialog(15,35,19,75,cTitle)

@ 16, 40 GET xRange1 PICTURE cPict
@ 17, 40 SAY "-- TO --"
@ 18, 40 GET xRange2 PICTURE cPict VALID RANGEVAL(@xRange1,xRange2,cType)
READ

DO CASE
   CASE cType = "C" .OR. cType = "M"

      xRange1 := '"' + ALLTRIM(xRange1) + '"'

      xRange2 := '"' + ALLTRIM(xRange2) + '"'

      cAdd1 := ALLTRIM(xRange1) + cAndOr + " "  + cField + cOperator + ;
         ALLTRIM(xRange2) + ")"

      cAdd2 := ALLTRIM(xRange1) + " through " + ALLTRIM(xRange2) + ")"

   CASE cType = "D"

      cAdd1 := "CTOD(" + DTOC(xRange1) + ")) " + cAndOr + " "  + cField + ;
         cOperator + " (CTOD(" + DTOC(xRange2) + "))"

      cAdd2 := DTOC(xRange1) + " through " + DTOC(xRange2) + ")"

   CASE cType = "N"

      cAdd1 := ALLTRIM(xRange1) + " " + cAndOr + " " + cField + " " + ;
         cOperator + " " + ALLTRIM(xRange2) + ")"

      cAdd2 := ALLTRIM(xRange1) + " through " + ALLTRIM(xRange2) + ")"

ENDCASE

aFilter[LEN(aFilter),1] := aFilter[LEN(aFilter),1] + cAdd1
aFilter[LEN(aFilter),3] := aFilter[LEN(aFilter),3] + cAdd2

KillDialog(cBox)

RETURN aFilter

*ý***************************************************************
STATIC FUNCTION RANGEVAL(X1,X2,cType)

LOCAL ;
   lRetn := .T.   ,;
   nCursor

IF cType = "N"
   IF X1 = SPACE(30)
      X1 := "0"
   ENDIF
   IF VAL(X1) >= VAL(X2)
      ErrDraw("SECOND RANGE ELEMENT MUST BE GREATER THAN FIRST")
      lRetn := .F.
   ENDIF
ELSE  // cType = D,C,M
   IF X1 >= X2
      ErrDraw("SECOND RANGE ELEMENT MUST BE GREATER THAN FIRST")
      lRetn := .F.
   ENDIF
ENDIF

RETURN lRetn


*ý***************************************************************
*      Function: IN_LIST
*    Parameters: lVar, aFilter
*       Returns: aFilter
*   Description:
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC FUNCTION IN_LIST(lVar, aFilter, cType)

LOCAL                             ;
   N                             ,;
   aList[10]                     ,;
   cAdd1                         ,;
   cAdd2                         ,;
   cAndOr := " .OR. "            ,;
   cBox                          ,;
   cField                        ,;
   cN_Str := ""                  ,;
   cOper := " = "                ,;
   cPict                         ,;
   cStr := ""                    ,;
   cStr2                         ,;
   cTitle := "IN THE LIST OF:"   ,;
   nBeg                          ,;
   nEnd                          ,;
   nCursor

MEMVAR ;
   GETLIST

// get the name of the field that we are using in this filter //

IF ". (" $ aFilter[LEN(aFilter),1]
   IF ".NOT." $ aFilter[LEN(aFilter),1]
      nBeg    :=  AT(".NOT." , aFilter[LEN(aFilter),1] ) + 6
   ELSE
      nBeg    :=  AT(". (" , aFilter[LEN(aFilter),1] ) + 3
   ENDIF
ELSE
   IF ".NOT." $ aFilter[LEN(aFilter),1]
      nBeg    :=  AT(".NOT." , aFilter[LEN(aFilter),1] ) + 6
   ELSE
      nBeg    :=  2
   ENDIF
ENDIF

nEnd   := AT("$" , aFilter[LEN(aFilter),1]) - nBeg
cField := SUBSTR(aFilter[LEN(aFilter),1] , nBeg , nEnd)

IF .NOT. lVar
   cTitle    :=  "NOT IN THE LIST OF:"
   cOper     := " <> "
   cAndOr    := " .AND. "
ENDIF

DO CASE
   CASE cType = "C" .OR. cType = "M"
      cPict := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      AFILL(aList , SPACE(30))
      aFilter[LEN(aFilter),1]:=STRTRAN(aFilter[LEN(aFilter),1],"$ (","$ [")

   CASE cType = "D"
      cPict := "99/99/99"
      AFILL(aList , CTOD("  /  /  "))

      IF ".NOT." $ aFilter[LEN(aFilter),1]
         aFilter[LEN(aFilter),1] := STRTRAN(aFilter[LEN(aFilter),1] , ".NOT. " , ".NOT. DTOC(" , 1 , 1 )
         aFilter[LEN(aFilter),1] := STRTRAN(aFilter[LEN(aFilter),1] , " $" , ") $" , 1 , 1 )

      ELSE
         aFilter[LEN(aFilter),1] := STRTRAN(aFilter[LEN(aFilter),1] , "(" , "(DTOC(" , 1 , 1 )
         aFilter[LEN(aFilter),1] := SUBSTR(aFilter[LEN(aFilter),1] , 1 , ;
            LEN(aFilter[LEN(aFilter),1])-4 ) + ")" + ;
            SUBSTR(aFilter[LEN(aFilter),1] , ;
            LEN(aFilter[LEN(aFilter),1])-3, 4 )
      ENDIF
      aFilter[LEN(aFilter),1]:=STRTRAN(aFilter[LEN(aFilter),1],"$ (","$ [")

   CASE cType = "N"
      cPict := "999999999999999999999999999999"
      AFILL(aList , SPACE(30))
      IF ". (" $ aFilter[LEN(aFilter),1]
         aFilter[LEN(aFilter),1] := SUBSTR(aFilter[LEN(aFilter),1],1,AT(". (" , aFilter[LEN(aFilter),1])+2)
      ELSE
         aFilter[LEN(aFilter),1] := "("
      ENDIF
ENDCASE

cBox := Dialog(11,35,24,75,cTitle)

@ 12, 40 GET aList[01] PICTURE cPict
@ 13, 40 GET aList[02] PICTURE cPict
@ 14, 40 GET aList[03] PICTURE cPict
@ 15, 40 GET aList[04] PICTURE cPict
@ 16, 40 GET aList[05] PICTURE cPict
@ 17, 40 GET aList[06] PICTURE cPict
@ 18, 40 GET aList[07] PICTURE cPict
@ 19, 40 GET aList[08] PICTURE cPict
@ 20, 40 GET aList[09] PICTURE cPict
@ 21, 40 GET aList[10] PICTURE cPict

READ

IF cType = "N"
   FOR N := 1 TO 10
      IF .NOT. EMPTY(aList[N])
         cN_Str  :=  cN_Str + IIF(.NOT. EMPTY(cN_Str) , cAndOr , "" ) + ;
            cField + cOper + ALLTRIM(aList[N])
      ENDIF
   NEXT
ENDIF

FOR N := 1 TO 10
   cStr  := cStr + IIF(.NOT. EMPTY(aList[N]) .AND. .NOT. EMPTY(cStr) , ;
      CHR(179),"") + IIF(VALTYPE(aList[N]) = "D" .AND. .NOT. ;
      EMPTY(aList[N]), ALLTRIM(DTOC(aList[N])) , ALLTRIM(aList[N]))
NEXT

IF EMPTY(cN_Str)
   cN_Str := ".T."
ENDIF

cStr  := ALLTRIM(cStr)

cStr2 := STRTRAN(cStr , CHR(179) , ",")

cAdd1 := IIF(cType = "N", cN_Str, cStr)  + IIF(cType = "N" , ")" , "])" )
cAdd2 := "(" + cStr2 + "))"

aFilter[LEN(aFilter),1] := aFilter[LEN(aFilter),1] + cAdd1
aFilter[LEN(aFilter),3] := aFilter[LEN(aFilter),3] + cAdd2

KillDialog(cBox)

RETURN aFilter

*ý***************************************************************
*      Function: POP_VALUE
*    Parameters: aDBF, aFilter
*       Returns: aFilter
*   Description: ADDS A VALUE TO THE OPERATOR & CONDITON IN aFilter
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC FUNCTION POP_VALUE(aDBF,aFilter,cType)

LOCAL              ;
   N              ,;
   aFields  := {} ,;
   aKeys    := {} ,;
   nOldRow        ,;
   oBrowse

DO CASE

   CASE "in the range" $ aFilter[LEN(aFilter),3]
      IF "not" $ aFilter[LEN(aFilter),3]
         aFilter := IN_RANGE(.F., aFilter, cType)
      ELSE
         aFilter := IN_RANGE(.T., aFilter, cType)
      ENDIF

   CASE "in the list" $ aFilter[LEN(aFilter),3]
      IF "not" $ aFilter[LEN(aFilter),3]
         aFilter := IN_LIST(.F., aFilter, cType)
      ELSE
         aFilter := IN_LIST(.T., aFilter, cType)
      ENDIF

   OTHERWISE
      BrowseRow(1)

      AADD(aDBF, {})
      AINS(aDBF,1)
      aDBF[1] := {"__________","TOP"}

      AADD(aFields, { "SELECT VALUE" , { | | aDBF[BrowseRow(),1]  } } )
      AADD(aKeys ,;
         { K_ENTER ,;
             { | | ;
                nOldRow := BrowseRow() , ;
                aFilter := MAKE_VALUE(cType,aFilter, aDBF[BrowseRow(),1]),;
                IIF(LASTKEY() = 200, oBrowse:CARGO[M_EXIT] := .F., ;
                   oBrowse:CARGO[M_EXIT] := .T.) , ;
                BrowseRow(nOldRow) ;
          } } )

      AADD(aKeys  , { K_ESC , { | | aFilter := WIPE_OPER(aFilter) , ;
                                oBrowse:CARGO[M_EXIT] := .T. } } )

      oBrowse := InitBrowse(13,35,22,70,,aFields,aDBF)
      oBrowse:COLORSPEC := "B/W,W/B"
      oBrowse:GETCOLUMN(1):WIDTH := 21
      oBrowse:goTopBlock    := { | | BrowseRow(1) }
      oBrowse:goBottomBlock := { | | BrowseRow( FINDBOTT(aDBF,cType) ) }
      oBrowse:SkipBlock     := { | X, nAtNow | nAtNow := BrowseRow(), ;
         BrowseRow( SKIPFUNC(aDBF , cType , X , ;
         BrowseRow() ) ) , BrowseRow() - nAtNow  }

      BrowseExec(oBrowse,aKeys)

      ADEL(aDBF,1)
      ASIZE(aDBF,LEN(aDBF)-1)

ENDCASE

RETURN aFilter

*ý***************************************************************
*    Function: WIPE_OPER
*  Parameters: aFilter
*     Returns: aFilter
* Description: CLEARS THE OPERATOR FROM THE STRING IN aFilter[N,1&3] IF
*              USER HITS <ESC>
*  Created by: Phil Boyer   10-01-92
*****************************************************************
STATIC FUNCTION WIPE_OPER(aFilter)

IF ".NOT." $ aFilter[LEN(aFilter),1]
   aFilter[LEN(aFilter),1] := SUBSTR(aFilter[LEN(aFilter),1] , 1 , ;
      LEN(aFilter[LEN(aFilter),1])-9)
ELSE
   aFilter[LEN(aFilter),1] := SUBSTR(aFilter[LEN(aFilter),1] , 1 , ;
      LEN(aFilter[LEN(aFilter),1])-4)
ENDIF

aFilter[LEN(aFilter),3] := SUBSTR(aFilter[LEN(aFilter),3] , 1 ,;
   (AT(" is" , aFilter[LEN(aFilter),3] )-1) )


RETURN aFilter

*ý***************************************************************
STATIC FUNCTION SKIPFUNC(aDBF,cType,nOccured,nRow)

LOCAL ;
   lLoop := .T.   ,;
   nBot  := FINDBOTT(aDBF, cTYPE),;
   nTop  := 1

IF nRow < nTop
   nRow := nTop
ENDIF

IF nOccured = 0
   lLoop := .F.
ENDIF
DO WHILE lLoop
   IF nOccured > 0
      nRow++
      IF nRow > nBot
         nRow--
         EXIT
      ENDIF
      IF aDBF[nRow,2] = cType
         nOccured--
      ENDIF
   ELSEIF nOccured < 0
      nRow--
      IF nRow < nTop
         nRow++
         EXIT
      ENDIF
      IF aDBF[nRow,2] = cType .OR. aDBF[nRow,2] = "TOP"
         nOccured++
      ENDIF
   ENDIF
   IF nOccured = 0
      lLoop := .F.
   ENDIF
ENDDO

RETURN nRow

*ý***************************************************************
STATIC FUNCTION FINDTOP(aDBF,cType)

LOCAL ;
   N     := 0  ,;
   lLoop := .T.

DO WHILE lLoop
   N++
   IF aDBF[N,2] = cType
      lLoop := .F.
   ENDIF
ENDDO

RETURN N

*ý***************************************************************
STATIC FUNCTION FINDBOTT(aDBF,cType)

LOCAL ;
   N     := LEN(aDBF) + 1   ,;
   lLoop := .T.

DO WHILE lLoop
   N--
   IF aDBF[N,2] = cType
      lLoop := .F.
   ENDIF
ENDDO

RETURN N

*ý***************************************************************
*    Function: MAKE_VALUE
*  Parameters: cType, aFilter, cAdd
*     Returns: aFilter
* Description: ADDS THE COMPARED VALUE TO THE aFilter[N,1&3] STRINGS
*  Created by: Phil Boyer   10-01-92
*****************************************************************
STATIC FUNCTION MAKE_VALUE(cType,aFilter,cAdd)

LOCAL              ;
   VAR  := cAdd   ,;
   cBox           ,;
   cPict          ,;
   lAdd := .F.    ,;
   nCursor

MEMVAR ;
   GETLIST

IF cAdd == "__________"
   lAdd := .T.
   DO CASE
      CASE cType = "C"
         VAR   := SPACE(30)
         cPict := REPL("X",30)
      CASE cType = "D"
         VAR := CTOD("  /  /  ")
         cPict := "99/99/99"
      CASE cType = "L"
         VAR := .T.
         cPict := "Y"
      CASE cType = "N"
         VAR := SPACE(30)
         cPict := REPLICATE("9",30)
      CASE cType = "M"
         VAR := SPACE(30)
         cPict := REPL("X",30)
   ENDCASE
ENDIF

IF lAdd
   cBox := Dialog(14,40,16,75)
   @ 15,42 GET VAR PICTURE cPict
   READ

   KillDialog(cBox)

   DO CASE
      CASE cType = "C" .OR. cType = "M"
         cAdd := '"'+ALLTRIM(VAR)+'"'

      CASE cType = "N"
         cAdd := ALLTRIM(VAR)

      CASE cType = "L"
         cAdd := IIF( VAR ,  ".T."  , ".F."   )
         VAR  := IIF( VAR ,  "TRUE" , "FALSE" )

      CASE cType = "D"
         cAdd := 'CTOD("'+DTOC(VAR)+'")'
         VAR  := DTOC(VAR)
   ENDCASE
ENDIF

IF LASTKEY() <> K_ESC
   aFilter[LEN(aFilter),1] := ( aFilter[LEN(aFilter),1] + cAdd                 )
   aFilter[LEN(aFilter),3] := ( aFilter[LEN(aFilter),3] + ALLTRIM(VAR) + " )"  )
ENDIF

DISP_STR(aFilter)

// THIS IS AN UGLY FIX FOR A PROBLEM CAUSED BY A LASTKEY() OF ESCAPE //
// 200 IS A BOX CHR - (DOUBFULT CANDIDATE FOR HOT KEY CONFLICT)
IF LASTKEY() = K_ESC
   KEYBOARD CHR(200)
   INKEY(0)
ENDIF

RETURN aFilter

*ý***************************************************************
*      Function: POP_NEXT
*    Parameters: aDBF, aFilter
*       Returns: cNext
*   Description: DETERMINE IF USER WANTS AN ".OR." , ".AND." , OR IF
*                DONE
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC FUNCTION POP_NEXT(aFilter)

LOCAL              ;
   aFields := {}  ,;
   aKeys   := {}  ,;
   aNEXT   := {}  ,;
   cAdd           ,;
   oBrowse

BrowseRow(1)

AADD(aFields, { "CONNECTOR"        , { | | aNEXT[BrowseRow()]         } } )

AADD(aKeys  , { K_ENTER            , { | | cAdd := aNEXT[BrowseRow()], ;
   oBrowse:CARGO[M_EXIT] := .T. } } )

AADD(aKeys,{K_ESC,{ || IIF(LEN(aFilter) = 1 , aFilter[1] :=  { "", ;
   "ALL RECORDS WHERE " , "" }   , ASIZE(aFilter, ;
   LEN(aFilter)-1) ) , oBrowse:CARGO[M_EXIT] := ;
   IIF(EMPTY(aFilter[1,1]) , .T. , .F. ) , ;
   DISP_STR(aFilter) } } )

AADD(aNEXT, "and ")
AADD(aNEXT, "or  ")
AADD(aNEXT, "done")

oBrowse := InitBrowse(11,65,17,75,,aFields,aNEXT)
oBrowse:COLORSPEC := "B/W,W/B"
BrowseExec(oBrowse,aKeys)

RETURN cAdd

*ý***************************************************************
*      Function: MAKE_NEXT
*    Parameters: aFilter, cNext
*       Returns: aFilter
*   Description: ADDS NEW ELEMENT TO aFilter ARRAY FOR NEXT "AND/OR" CONDITION
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC FUNCTION MAKE_NEXT(aFilter, cNext)

DO CASE
   CASE cNext = "or"
      AADD(aFilter, {" .OR. ", " OR WHERE " , ""})
   CASE cNext = "and"
      AADD(aFilter, {" .AND. ", " AND WHERE " , ""})
ENDCASE

DISP_STR(aFilter)

RETURN aFilter

*ý***************************************************************
*     Procedure: DISP_STR()
*    Parameters: aFilter
*   Description: DISPLAYS THE QUERY DESCRIPTION STRING IN THE aFilter ARRAY
*    Created by: Phil Boyer   09-23-92
*****************************************************************
STATIC PROCEDURE DISP_STR(aFilter)

LOCAL                             ;
   N     := 1                    ,;
   cCol  := SETCOLOR("W/B,W+/B") ,;
   nCol  := 2                    ,;
   nRow  := 4


@ nRow, nCol CLEAR TO 10, MAXCOL()
SETCOLOR(cCol)

BEGIN SEQUENCE
   IF EMPTY(aFilter)
      BREAK
   ENDIF

   DO WHILE N <= LEN(aFilter)
      IF nCol + LEN(aFilter[N,2]) < 77
         @ nRow , nCol SAY aFilter[N,2] COLOR "W/B"
         nCol := nCol + LEN(aFilter[N,2])
      ELSE
         nRow := nRow + 1
         IF nRow > 10
            EXIT
         ENDIF
         nCol := 2
         @ nRow , nCol SAY aFilter[N,2] COLOR "W/B"
         nCol := nCol + LEN(aFilter[N,2])
      ENDIF

      IF nCol + LEN(aFilter[N,3]) < 77
         @ nRow , nCol SAY aFilter[N,3] COLOR "W+/B"
         nCol := nCol + LEN(aFilter[N,3])
      ELSE
         nRow := nRow + 1
         IF nRow > 10
            EXIT
         ENDIF
         nCol := 2
         @ nRow , nCol SAY aFilter[N,3] COLOR "W+/B"
         nCol := nCol + LEN(aFilter[N,3])
      ENDIF
      N++
   ENDDO
END

RETURN