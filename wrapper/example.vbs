'*************************************************************************
' Script Name - AD Time Skew Detection
'
' Purpose     - Compares the time on the local server against the time
'               on the specified DC.  If it is above the configured threshold,
'               an alert will be raised.
'
' (c) Copyright 2014, Microsoft Corporation, All Rights Reserved
' Proprietary and confidential to Microsoft Corporation
'*************************************************************************

Option Explicit

SetLocale("en-us")

Sub Main()

  Dim oBag, oAPI, oParams, sError, iThreshold, oNTInfo, iRetryMax
  Dim strLocalServer, strTargetServer, strLocalTime, strRemoteTime, tmLocal
  Dim strTimeTime, tmTime, iSecondsDiff

  Set oParams = WScript.Arguments
  Set oAPI = CreateObject("Mom.ScriptAPI")
  Set oBag = oAPI.CreatePropertyBag()

  If oParams.Count < 3 Then
        sError = "The number of command line arguments is incorrect: " & vbCrLf & _
                      "Expected: 3" & vbCrLf & _
                      "Actual: " & oParams.Count

        oBag.AddValue "State", "BAD"
        oBag.AddValue "ErrorString", sError

        Call oAPI.Return(oBag)
        Exit Sub
  End if

  strTargetServer = oParams(0)
  iThreshold = CInt(oParams(1))
  iRetryMax = CInt(oParams(2))

  On Error Resume Next

  set oNTInfo = CreateObject("WinNTSystemInfo")
  strLocalServer = oNTInfo.ComputerName

  strLocalTime = GetTimeWithRetry(strLocalServer, iRetryMax)
  If Err Then
    oBag.AddValue "State", "BAD"
    oBag.AddValue "ErrorString", "Failed to connect to the local domain controller, " & strLocalServer & ", to determine local time from the directory." & GetErrorString(Err)

    Call oAPI.Return(oBag)
    Exit Sub
  End If

  strRemoteTime = GetTimeWithRetry(strTargetServer, iRetryMax)
  If Err Then
    oBag.AddValue "State", "BAD"
    oBag.AddValue "ErrorString", "Unable to connect to the remote server, " & strTargetServer & ", to determine domain time for comparison purposes." & GetErrorString(Err)

    Call oAPI.Return(oBag)
    Exit Sub
  End If

  tmTime = CDate(ConvertTimeStamp(strRemoteTime))
  tmLocal = CDate(ConvertTimeStamp(strLocalTime))

  iSecondsDiff = Abs(DateDiff("s",tmTime,tmLocal))

  If iSecondsDiff > iThreshold Then
      sError = "Time check has found that the time on the current DC compared to the specified server is outside of the specified threshold." & vbCrLf & _
                    "The current time skew is " & iSecondsDiff & " second(s)." & vbCrLf & _
                    "Time skew threshold is " & iThreshold & " second(s)." & vbCrLf & _
                    "Time on local DC (" & strLocalServer & ") is " & tmLocal & vbCrLf & _
                    "Time on target DC (" & strTargetServer & ") is " & tmTime

      oBag.AddValue "State", "BAD"
      oBag.AddValue "ErrorString", sError
  Else
      oBag.AddValue "State", "GOOD"
  End If

  Call oAPI.Return(oBag)

End Sub

'******************************************************************************
' Name:         GetTimeWithRetry
'
' Purpose:      Gets the time from the specified server, retrying attempt iRetryMax times if the call fails
'
' Paramters:    strServer, the server to target
'		        iRetryMax, the integer parameter for retry iterations max
'
' Return:       The current time in string format
'
Function GetTimeWithRetry(strServer, iRetryMax)
  dim iRetry, objRootDSE
  dim strTime

  iRetry = 0

  On Error Resume Next

  Do
    'Reset Err object
    Err.Clear

    'Attempt to bind to the root DSE and get the time
    Set objRootDSE = GetObject("LDAP://" & strServer & "/RootDSE")
    strTime = objRootDSE.Get("currentTime")

    'If no errors then skip retry
    If Err = 0 Then
      Exit Do
    End If

    'Wait a second before next attempt
    wscript.sleep(1000)
    iRetry = iRetry + 1

  Loop While (iRetry < iRetryMax)

  GetTimeWithRetry = strTime
End Function

'******************************************************************************
Function ConvertTimeStamp(strUTCTime)
'
' Purpose:      Convert a timestamp into a human-readable format
'
' Paramters:    strUTCTime, the timestamp to be converted
'
  dim sYear
  dim sMonth
  dim sDay
  dim sHour
  dim sMinute
  dim sSecond

  sYear = Mid(strUTCTime, 1, 4)
  sMonth = Mid(strUTCTime, 5, 2)
  sDay = Mid(strUTCTime, 7, 2)
  sHour = Mid(strUTCTime, 9, 2)
  sMinute = Mid(strUTCTime, 11, 2)
  sSecond = Mid(strUTCTime, 13, 2)

  ConvertTimeStamp = sMonth & "/" & sDay & "/" & sYear & " " & sHour & ":" & sMinute & ":" & sSecond
End Function

'******************************************************************************
' Name:         GetErrorString
'
' Purpose:      Attempts to find the description for an error if an error with
'               no description is passed in.
'
' Parameters:   oErr, the error object
'
' Return:       String, the description for the error.  (Includes the error code.)
'
Function GetErrorString(oErr)
  Dim lErr, strErr
  lErr = oErr
  strErr = oErr.Description

  On Error Resume Next
  If 0 >= Len(strErr) Then
    ' If we don't have an error description, then check to see if the error
    ' is a 0x8007xxxx error.  If it is, then look it up.
    Const ErrorMask = &HFFFF0000
    Const HiWord8007 = &H80070000
    Const LoWordMask = 65535          ' This is equivalent to 0x0000FFFF

    If (lErr And ErrorMask) = HiWord8007 Then
      ' Attempt to use 'net helpmsg' to get a description for the error.
      Dim oShell
      Set oShell = CreateObject("WScript.Shell")
      If Err = 0 Then
        Dim oExec
        Set oExec = oShell.Exec("net helpmsg " & (lErr And LoWordMask))

        Dim strMessage, i
        Do
          strMessage = oExec.stdout.ReadLine()
          i = i + 1
        Loop While (Len(strMessage) = 0) And (i < 5)

        strErr = strMessage
      End If
    End If
  End If

  GetErrorString = vbCrLf & vbCrLf & "The error returned was: '" & strErr & "' (0x" & Hex(lErr) & ")"
End Function

Main()
