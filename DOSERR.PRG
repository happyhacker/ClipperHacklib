#INCLUDE "HACKINCL.CH"

FUNCTION DOSERROR(nError)

LOCAL ;
    cRet := NTRIM(nError) + ': '

DO CASE
   CASE nError = 1
      cRet += 'Invalid Function Number.'

   CASE nError = 2
      cRet += 'File Not Found.'

   CASE nError = 3
      cRet += 'Path Not Found.'

   CASE nError = 4
      cRet += 'No More File Handles Left.'

   CASE nError = 5
      cRet += 'Access Denied.'

   CASE nError = 6
      cRet += 'Invalid Handle.'

   CASE nError = 7
      cRet += 'Memory control Blocks Corrupted.'

   CASE nError = 8
      cRet += 'Not Enough Memory.'

   CASE nError = 9
      cRet += 'Invalid Memory Block Address.'

   CASE nError = 10
      cRet += 'Invalid Environment.'

   CASE nError = 11
      cRet += 'Invalid Format.'

   CASE nError = 12
      cRet += 'Invalid Access Code.'

   CASE nError = 13
      cRet += 'Invalid Data.'

   CASE nError = 14
      cRet += 'Reserved.'

   CASE nError = 15
      cRet += 'Invalid Drive Specified.'

   CASE nError = 16
      cRet += 'Attempt To Remove Current Directory.'

   CASE nError = 17
      cRet += 'Not Same Device.'

   CASE nError = 18
      cRet += 'No More Files.'

   CASE nError = 19
      cRet += 'Attempt To Write On Write Protected Disk.'

   CASE nError = 20
      cRet += 'Unknown Unit.'

   CASE nError = 21
      cRet += 'Drive Not Ready.'

   CASE nError = 22
      cRet += 'Unknown Command.'

   CASE nError = 23
      cRet += 'Data Error (CRC).'

   CASE nError = 24
      cRet += 'Bad Request Structure Length.'

   CASE nError = 25
      cRet += 'Seek Error.'

   CASE nError = 26
      cRet += 'Unknown Media Type.'

   CASE nError = 27
      cRet += 'Sector Not Found.'

   CASE nError = 28
      cRet += 'Printer Out Of Paper.'

   CASE nError = 29
      cRet += 'Write Fault.'

   CASE nError = 30
      cRet += 'Read Fault.'

   CASE nError = 31
      cRet += 'General Failure.'

   CASE nError = 32
      cRet += 'Sharing Violation.'

   CASE nError = 33
      cRet += 'Lock Violation.'

   CASE nError = 34
      cRet += 'Invalid Disk Change.'

   CASE nError = 35
      cRet += 'File Control Block Unavailable.'

   CASE nError = 36
      cRet += 'Sharing Buffer Overflow.'

   CASE nError >=37 .AND. nError <= 49
      cRet += 'Reserved.'

   CASE nError = 50
      cRet += 'Network Request Not Supported.'

   CASE nError = 51
      cRet += 'Remote Computer Not Listening.'

   CASE nError = 52
      cRet += 'Duplicate Name on Network.'

   CASE nError = 53
      cRet += 'Network Name Not Found.'

   CASE nError = 54
      cRet += 'Network Busy.'

   CASE nError = 55
      cRet += 'Network Device No Longer Exists.'

   CASE nError = 56
      cRet += 'Network BIOS Command Limit Exceeded.'

   CASE nError = 57
      cRet += 'Network Adapter Hardware Error.'

   CASE nError = 58
      cRet += 'Incorrect Response From Network.'

   CASE nError = 59
      cRet += 'Unexpected Network Error.'

   CASE nError = 60
      cRet += 'Incompatible Remote Adapter.'

   CASE nError = 61
      cRet += 'Print Queue Full.'

   CASE nError = 62
      cRet += 'Not Enough Space For Print File.'

   CASE nError = 63
      cRet += 'Print File Deleted (Not Enough Space).'

   CASE nError = 64
      cRet += 'Network Name Deleted.'

   CASE nError = 65
      cRet += 'Access Denied.'

   CASE nError = 66
      cRet += 'Network Device Type Incorrect.'

   CASE nError = 67
      cRet += 'Network Name Not Found.'

   CASE nError = 68
      cRet += 'Network Name Limit Exceeded.'

   CASE nError = 69
      cRet += 'Network BIOS Session Limit Exceeded.'

   CASE nError = 70
      cRet += 'Temporarily Paused.'

   CASE nError = 71
      cRet += 'Network Request Not Accepted.'

   CASE nError = 72
      cRet += 'Print Or Disk Redirection Paused.'

   CASE nError >=73 .AND. nError <= 79
      cRet += 'Reserved.'

   CASE nError = 80
      cRet += 'File Already Exists.'

   CASE nError = 81
      cRet += 'Reserved.'

   CASE nError = 82
      cRet += 'Cannot Make Directory Entry.'

   CASE nError = 83
      cRet += 'Fail On Int 24.'

   CASE nError = 84
      cRet += 'Too Many Redirections.'

   CASE nError = 85
      cRet += 'Duplicate Redirection.'

   CASE nError = 86
      cRet += 'Invalid Password.'

   CASE nError = 87
      cRet += 'Invalid Parameter.'

   CASE nError = 88
      cRet += 'Network Device Fault.'

ENDCASE

RETURN cRet