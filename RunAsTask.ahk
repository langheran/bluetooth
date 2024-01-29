RunAsTask(isSingeInstance=0) {                         ;  By SKAN,  http://goo.gl/yG6A1F,  CD:19/Aug/2014 | MD:22/Aug/2014
  Local CmdLine, TaskName, TaskExists, XML, TaskSchd, TaskRoot, RunAsTask
  Local TASK_CREATE := 0x2,  TASK_LOGON_INTERACTIVE_TOKEN := 3, TASK_STATE_RUNNING := 0x4
  if (isSingeInstance){
    #SingleInstance, off
  }
  Try TaskSchd  := ComObjCreate( "Schedule.Service" ),    TaskSchd.Connect()
    , TaskRoot  := TaskSchd.GetFolder( "\" )
  Catch
      Return "", ErrorLevel := 1    
 
  CmdLine       := ( A_IsCompiled ? "" : """"  A_AhkPath """" )  A_Space  ( """" A_ScriptFullpath """"  )
  TaskName      := "[RunAsTask] " A_ScriptName " @" SubStr( "000000000"  DllCall( "NTDLL\RtlComputeCrc32"
                   , "Int",0, "WStr",CmdLine, "UInt",StrLen( CmdLine ) * 2, "UInt" ), -9 )
 
  Try RunAsTask := TaskRoot.GetTask( TaskName )
  TaskExists    := ! A_LastError 
 
  If (not A_IsAdmin && isSingeInstance && TaskExists && RunAsTask.State == TASK_STATE_RUNNING){
    try{
      RunAsTask.Stop(a:=0)
      while(RunAsTask.State == TASK_STATE_RUNNING)
        sleep, 10
    }catch{}
  }
  If ( not A_IsAdmin and TaskExists )      { 
    RunAsTask.Run( "" )
    ExitApp
  }
 
  If ( not A_IsAdmin and not TaskExists )  { 
    Run *RunAs %CmdLine%, %A_ScriptDir%, UseErrorLevel
    ExitApp
  }
 
  If ( A_IsAdmin and not TaskExists )      {  
 
    XML := "
    ( LTrim Join
      <?xml version=""1.0"" ?><Task xmlns=""http://schemas.microsoft.com/windows/2004/02/mit/task""><Regi
      strationInfo /><Triggers /><Principals><Principal id=""Author""><LogonType>InteractiveToken</LogonT
      ype><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolic
      y>Parallel</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><
      StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>false</AllowHardTerminate>
      <StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAva
      ilable><IdleSettings><StopOnIdleEnd>true</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleS
      ettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><
      RunOnlyIfIdle>false</RunOnlyIfIdle><DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteApp
      Session><UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine><WakeToRun>false</WakeToRun><
      ExecutionTimeLimit>PT0S</ExecutionTimeLimit></Settings><Actions Context=""Author""><Exec>
      <Command>"   (  A_IsCompiled ? A_ScriptFullpath : A_AhkPath )       "</Command>
      <Arguments>" ( !A_IsCompiled ? """" A_ScriptFullpath  """" : "" )   "</Arguments>
      <WorkingDirectory>" A_ScriptDir "</WorkingDirectory></Exec></Actions></Task>
    )"    
 
    TaskRoot.RegisterTask( TaskName, XML, TASK_CREATE, "", "", TASK_LOGON_INTERACTIVE_TOKEN )
 
  }

  if(isSingeInstance && A_IsAdmin)
  {
    _KillOtherCopies()
  }
 
Return TaskName, ErrorLevel := 0
}

_KillOtherCopies()
{
  nkilled := 0
  if (!A_IsCompiled)
    return
  PID := DllCall("GetCurrentProcessId")
  for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
    if (proc.Name = A_ScriptName) && (proc.ProcessID != PID)
    {
      PPID := proc.ProcessID
      ;MsgBox, 4160, , Killing %PPID%, 2
      Process,close,%PPID%
      nkilled += 1
    }
  return nkilled
}
