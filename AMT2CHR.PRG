FUNCTION Amt2Chr(nNum, nLen1, lNumFolw, lPercent)

LOCAL ;
    cString  := ''   ,;
    i                ,;
    nOrigNum := nNum ,;
    nTemp            ,;
    the_words[27]

nLen1    := IIF(PCOUNT() < 2,84,nLen1)
lNumFolw := IIF(PCOUNT() < 3,.F.,lNumFolw)
lPercent := IIF(PCOUNT() < 4,.F.,lPercent)

the_words[1]  := 'ONE'
the_words[2]  := 'TWO'
the_words[3]  := 'THREE'
the_words[4]  := 'FOUR'
the_words[5]  := 'FIVE'
the_words[6]  := 'SIX'
the_words[7]  := 'SEVEN'
the_words[8]  := 'EIGHT'
the_words[9]  := 'NINE'
the_words[10] := 'TEN'
the_words[11] := 'ELEVEN'
the_words[12] := 'TWELVE'
the_words[13] := 'THIRTEEN'
the_words[14] := 'FOURTEEN'
the_words[15] := 'FIFTEEN'
the_words[16] := 'SIXTEEN'
the_words[17] := 'SEVENTEEN'
the_words[18] := 'EIGHTEEN'
the_words[19] := 'NINETEEN'
the_words[20] := 'TWENTY'
the_words[21] := 'THIRTY'
the_words[22] := 'FORTY'
the_words[23] := 'FIFTY'
the_words[24] := 'SIXTY'
the_words[25] := 'SEVENTY'
the_words[26] := 'EIGHTY'
the_words[27] := 'NINETY'

FOR i = 6 TO 0 STEP -3
   IF nNum >= 10 ^ i
      nTemp := INT (nNum / 10 ^ i)
      cString := cString + ConvertIt(nTemp,the_words) + IIF(i = 6, ' MILLION ', ;
          IIF(i = 3, ' THOUSAND ', ''))
      nNum := nNum - nTemp * 10 ^ i
   ENDIF
NEXT

IF AT('.',STR(nOrigNum)) # 0
   IF nNum # INT(nNum)
      IF lPercent
         cString := cString + ' AND ' + STR( (nNum - INT(nNum)) * 1000, 3) + '/1000'
      ELSE
         cString := cString + ' AND ' + STR( (nNum - INT(nNum)) * 100, 2) + '/100'
      ENDIF
   ELSE
      IF lPercent
         cString := cString + ' AND NO/1000'
      ELSE
         cString := cString + ' AND NO/100'
      ENDIF
   ENDIF

   IF lNumFolw
      IF lPercent
         cString := cString + ' (' + ALLTRIM(STR(nOrigNum,12,3)) + ')'
      ELSE
         cString := cString + ' ($' + ALLTRIM(STR(nOrigNum,12,2)) + ')'
      ENDIF
   ENDIF
ENDIF

IF LEN(cString) > nLen1             && return '*****' if too long
   cString := REPLICATE('*',nLen1)
ENDIF

RETURN cString

*******************************************************
*     Function: ConvertIt()
*     Called by AMT2CHR()
********************************************************
STATIC FUNCTION ConvertIt(nNum, the_words)

LOCAL ;
    cString := '' ,;
    nTemp

IF nNum > 99
   nTemp   := INT (nNum / 100)
   cString := cString + the_words[nTemp] + ' HUNDRED'
   nNum    := nNum - nTemp * 100
ENDIF

DO CASE
   CASE nNum > 0 .AND. nNum < 20
      cString := cString + ' ' + the_words[nNum]

   CASE nNum > 19
      nTemp   := INT(nNum / 10)
      cString := cString + ' ' + the_words[nTemp + 18]
      nNum    := nNum - nTemp * 10

      IF nNum # 0
         cString := cString + '-' + the_words[nNum]
      ENDIF
ENDCASE

RETURN cString