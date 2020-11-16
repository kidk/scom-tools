<package>
<job id="Import_Example">
<script language="VBScript" src="NewRelic.class.vbs"/>
<script language="VBScript">

'*************************************************************************
' Script Name - Disk space
'
' Purpose     - Gets the current free space on the disk drive that holds the AD log file
'
' (c) Copyright 2014, Microsoft Corporation, All Rights Reserved
' Proprietary and confidential to Microsoft Corporation
'*************************************************************************

Option Explicit

SetLocale("en-us")

On Error Resume Next

' TypedPropertyBag
const PerformanceDataType = 2

' Location of the log file
const LogFileRegKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\Database log files path"

Sub Main()
  Dim sPathLog, oAPI, oPerfBag, oDrive, oReg, oFileSystem, oParams, iResultType

'  Set oAPI = CreateObject("Mom.ScriptAPI")
  Set oAPI = New NewRelic
  Set oReg = CreateObject("WScript.Shell")
  Set oFileSystem = CreateObject("Scripting.FileSystemObject")
  Set oParams = WScript.Arguments

  if oParams.Count <> 1 then
    iResultType = 1
  Else
    iResultType = CInt(oParams(0))

    if iResultType > 2  or iResultType < 1 then
      iResultType = 1
    End if
  End if

  ' Read the path to the database file from the registry
  sPathLog = oReg.RegRead(LogFileRegKey)

  Set oDrive = oFileSystem.GetDrive(oFileSystem.GetDriveName(sPathLog))

  Set oPerfBag = oAPI.CreateTypedPropertyBag(PerformanceDataType)

  if iResultType = 1 Then
    oPerfBag.AddValue "StatusCounter" , "Log File Drive Free Space"
    oPerfBag.AddValue "StatusInstance" , sPathLog
    oPerfBag.AddValue "StatusValue", "" & oDrive.FreeSpace
  Else
    oPerfBag.AddValue "StatusCounter" , "Log File Drive Percent Free Space"
    oPerfBag.AddValue "StatusInstance" , sPathLog
    oPerfBag.AddValue "StatusValue", "" & (oDrive.FreeSpace  / oDrive.TotalSize) * 100
  End If

  oAPI.AddItem oPerfBag

  oAPI.ReturnItems
End Sub

Call Main()

</script>
</job>
</package>
