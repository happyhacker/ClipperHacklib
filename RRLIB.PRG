*==========================={ RRLIB.PRG }============================
* Copyright (c) 1992 Larry Hack
*...................................................................*
* Created on : 11-23-92 12:49:28pm By Larry Hack
* Description: Create an array containing report names from an rp1 file
*========================[ ALL RIGHTS RESERVED ]====================*
FUNCTION RRLib(libname)

LOCAL buffer, bufptr, chunk, handle, numreps, partdone
LOCAL partlen, replen, repnum, size, aReports:={}

libname := IIF(UPPER(RIGHT(libname, 4))= ".RP1", libname, libname + ".RP1")     && append .RP1 if necessary
handle  := FOPEN(libname, 0)           && open report library, read-only
buffer  := SPACE(2)                    && initialize an input buffer
FSEEK(handle, 19, 0)                   && position to chunk size
FREAD(handle, @buffer, 2)					&& read chunk size (binary integer)
bufptr  := 1                           && point to first byte
size    :=;
   (ASC(SUBSTR(buffer,bufptr+0,1))*256^0)+;
   (ASC(SUBSTR(buffer,bufptr+1,1))*256^1)   && convert binary to numeric

size   := IIF(size = 0, 32, size)            && zero means 32 bytes
buffer := SPACE(size)                        && reinitialize input buffer

bufptr := size + 1                           && prime variables to...
chunk  := 1                                  &&  ...read second chunk

readchunk(@bufptr,@buffer,;
   @chunk,handle,size)                      && read next chunk
&& now pointing to number of
&&  reports (binary integer)

numreps :=(ASC(SUBSTR(buffer,bufptr+0,1))*256^0)+;
   (ASC(SUBSTR(buffer,bufptr+1,1))*256^1)   && convert binary to numeric
bufptr := bufptr + 2                         && point to next byte of input

repnum := 1                               && init count of names processed

DO WHILE repnum <= numreps                && process each report name
   replen := ASC(SUBSTR(buffer, bufptr, 1))   && get length of name (binary byte)
   bufptr := bufptr + 5                   && point to report name
   readchunk(@bufptr,@buffer,;
      @chunk,handle,size)                && read next chunk if necessary
   partlen := MIN((size+1)-bufptr, replen)&& get length of portion of
   &&  name in current chunk

   && store portion of name
   AADD(aReports,SUBSTR(buffer, bufptr, partlen))
   bufptr := bufptr + partlen             && update input buffer pointer
   readchunk(@bufptr,@buffer,;
      @chunk,handle,size)                && read next chunk if necessary
   partdone := partlen                    && store length of portion of name

   DO WHILE partdone < replen             && if there's more to the name
      partlen := MIN((size + 1) - bufptr,;
         replen - partlen)               && get length of next part of name
      partdone := partdone + partlen      && update length of portion of name
      aReports[repnum] := aReports[repnum] +;
         SUBSTR(buffer, bufptr, partlen) && concatenate rest of name
      bufptr := bufptr + partlen          && update input buffer pointer
      readchunk(@bufptr,@buffer,;
         @chunk,handle,size)             && read next chunk if necessary
   ENDDO
   repnum := repnum + 1                   && update count of names processed
ENDDO

FCLOSE(handle)

RETURN aReports

**********************************************************************
** read next library file chunk
STATIC FUNCTION readchunk(bufptr, buffer, chunk, handle, size)

IF bufptr > size                       && if beyond end of chunk
   FSEEK(handle, chunk * size, 0)      && seek file position of next chunk
   FREAD(handle, @buffer, size)        && read next chunk
   bufptr := bufptr - size             && reset input buffer pointer
   chunk  :=;
      (ASC(SUBSTR(buffer, 1, 1)) * 256^2)+;
      (ASC(SUBSTR(buffer, 3, 1)) * 256^1)+;
      (ASC(SUBSTR(buffer, 2, 1)) * 256^0) &&  get next chunk # (binary 3-byte)
   bufptr := bufptr + 3                &&  move pointer beyond chunk number
ENDIF

RETURN .T.