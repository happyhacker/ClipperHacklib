FUNCTION GetAlias(cFile)

cFile  = IIF(RAT(':',cFile) = 0,cFile,SUBSTR(cFile,RAT(':',cFile) + 1))
cFile  = IIF(RAT('\',cFile) = 0,cFile,SUBSTR(cFile,RAT('\',cFile) + 1))
cFile  = IIF('.' $ cFile,SUBS(cFile,1,AT('.',cFile) - 1),cFile)

RETURN cFile