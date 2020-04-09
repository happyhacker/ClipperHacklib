// INCLUDE STANDARD CLIPPER 5.01 HEADERS

// Not in INKEY.CH for some reason
#DEFINE K_SPACE 32

// use when working with low level file handling
#DEFINE FILEBOTTOM(nHandle)   (FSEEK(nHandle,0,2))
#DEFINE FILETOP(nHandle)      (FSEEK(nHandle,0))
#DEFINE FILEPOS(nHandle)      (FSEEK(nHandle,0,1))

// number to character with trimming
#DEFINE NTRIM(N)     (ALLTRIM(STR(N)))

// syntax to allow defaults to be more legible
#command DEFAULT <p> TO <val> [ , <pn> TO <valn> ]   ;
      => <p> := IIF( <p> == NIL, <val>, <p> )          ;
         [; <pn> := IIF( <pn> == NIL, <valn>, <pn> ) ]
