#INCLUDE 'HACKINCL.CH'
#INCLUDE 'GENBROWS.CH'

PROCEDURE DEMO
LOCAL oBrowse
LOCAL aMethods:={{K_F10,{||EVAL(&(DEMO->CODEBLOCK))}} }
LOCAL aFields:={ {'Name',       'DEMO->FUNCTION'},;
                 {'Description','DEMO->DESC'},;
                 {'Codeblock',  'DEMO->CODEBLOCK',,,'@S60'} }

EXTERNAL ADDMONTH,;
         AMPM,;
         AMT2CHR,;
         APICK,;
         BOM,;
         CENTER,;
         DIALOG,;
         DOSERROR,;
         ENVSTATUS,;
         EOM,;
         ERRDRAW,;
         FILTER,;
         GETALIAS,;
         GETCOLOR,;
         GraphIndex,;
         GRAPHIT,;
         HACKCAL,;
         ISLEAP,;
         ListRp1,;
         MSG,;
         NETUSE,;
         NEWCOLOR,;
         PLSWAIT,;
         RrExecute,;
         RRLIB,;
         RUNIT,;
         SmallBox,;
         STRIPALIAS,;
         YESNO

SET SCORE OFF
SETCURSOR(0)
SETCOLOR("W+/B")
CLS
USE DEMO INDEX DEMO
SETCOLOR('N/W,W+/BG')

oBrowse:=InitBrowse(0,0,12,76,'Demo of Hacklib.lib',aFields)
oBrowse:FREEZE:=1

// Turn all the options on
oBrowse:CARGO[M_GETS]:=M_ON
oBrowse:CARGO[M_RESIZE]:=M_ON
oBrowse:CARGO[M_MOVE]:=M_ON
oBrowse:CARGO[M_DOSEEK]:=M_ON

BrowseExec(oBrowse,aMethods)

USE

RETURN
