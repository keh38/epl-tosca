; -- sync.iss --

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

#define verStr GetFileVersion("..\Build\Tosca.exe")
#define lastDot RPos(".", verStr)
#define revStr Copy(verStr, lastDot+1)
#define verStr_ StringChange(verStr, '.', '_')

[Setup]                        
AppName=Tosca 
AppVerName=Tosca V{#verStr}
DefaultDirName={commonpf}\EPL\Tosca\V{#revStr}
OutputDir=D:\Experiment VIs\Tosca\Installer\Output
DefaultGroupName=EPL
AllowNoIcons=yes
OutputBaseFilename=Tosca_Install_{#verStr_}
UsePreviousAppDir=no
UsePreviousGroup=no
DisableProgramGroupPage=yes

[Dirs]
Name: "C:\Data\Tosca"; Permissions: users-full; Check: CreateFolders()
Name: "C:\Data\Tosca\Config Files"; Permissions: users-full; Check: CreateFolders()
Name: "C:\Data\Tosca\Calibration Files"; Permissions: users-full; Check: CreateFolders()
Name: "C:\Data\Tosca\Data"; Permissions: users-full; Check: CreateFolders()
Name: "C:\Data\Tosca\Parameter Files"; Permissions: users-full; Check: CreateFolders()

[Files]
Source: "..\Build\*.*"; DestDir: "{app}"; Flags: replacesameversion
;Source: "..\dotNET Source\Tracker\bin\Release\*.*"; DestDir: "{app}"; Flags: replacesameversion 
;Source: "D:\Experiment VIs\Tosca\LV Source\Sub VIs\ToscaControls.dll"; DestDir: "{app}"; Flags: replacesameversion 
Source: "D:\Experiment VIs\Tosca\LV Source\Sub VIs\Tosca-MATLAB Thread.vi"; DestDir: "{app}"; Flags: replacesameversion 
Source: "D:\Experiment VIs\Tosca\LV Source\Pretrial VIs\Tosca-Execute MATLAB Script.vi"; DestDir: "{app}"; Flags: replacesameversion 

[Icons]
Name: "{group}\Tosca"; Filename: "{app}\Launch_Tosca.exe";
Name: "{commondesktop}\Tosca"; Filename: "{app}\Launch_Tosca.exe"; IconFilename: "{app}\Tosca.ico"; IconIndex: 0; 
Name: "{commondesktop}\previous version"; Filename: "{code:GetPreviousVersion}\Launch_Tosca.exe"; IconFilename: "{code:GetPreviousVersion}\tosca.ico"; IconIndex: 0; Check: IsThereAPreviousVersion()
Name: "{commondesktop}\Multirig Tosca"; Filename: "{app}\Multirig.exe"; IconFilename: "{app}\Tosca.ico"; IconIndex: 0; Check: IsMultirig()

[INI]
Filename: "{app}\Tosca.ini"; Section: "Tosca"; Key: "allowmultipleinstances"; String: "TRUE"

[Code]
var
  IPAddressPage: TInputQueryWizardPage;
  OptionsPage : TInputOptionWizardPage;
  PreviousVersion : String;

procedure InitializeWizard();
begin
  { Create the pages }
  OptionsPage := CreateInputOptionPage(wpSelectDir,
    'Tosca Installation', '',
    '', False, False);
  OptionsPage.Add('Create desktop shortcut to previous version');
  OptionsPage.Values[0] := False;
  OptionsPage.Add('Create desktop shortcut to multirig startup');
  OptionsPage.Values[1] := False;
  OptionsPage.Add('Create folder structure');
  OptionsPage.Values[1] := False;

end;

function GetPreviousVersion(Param : String) : String;
begin
  Result := PreviousVersion;
end;

function IsThereAPreviousVersion(): Boolean;
var
  rootFolder : String;
  rev : Longint;
  folder : String;
  v : Longint;
begin
  Result := OptionsPage.Values[0];
  if Result then
  begin
    rootFolder := ExtractFilePath(ExpandConstant('{app}'));
    rev := StrToInt(ExpandConstant('{#revStr}'));

    for v := rev - 1 downto 0 do
    begin
      folder := rootFolder + 'V' + IntToStr(v);
      if DirExists(folder) then
      begin
        PreviousVersion := folder;
        Result := True;
        break;
      end
    end
  end
end;

function IsMultirig(): Boolean;
begin
  Result := OptionsPage.Values[1];
end;

function CreateFolders(): Boolean;
begin
  Result := OptionsPage.Values[2];
end;
