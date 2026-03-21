[Setup]
AppName=Cellium
AppVersion=1.0.0.0
AppPublisher=Cellium
AppPublisherURL=https://github.com/Cellium
AppSupportURL=https://github.com/Cellium/issues
AppUpdatesURL=https://github.com/Cellium/releases
DefaultDirName={pf}\Cellium 应用
DefaultGroupName=Cellium 应用
AllowNoIcons=yes
OutputDir=installer
OutputBaseFilename=Cellium_App_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableDirPage=no
DisableProgramGroupPage=yes
DisableReadyPage=no
DisableFinishedPage=no
UninstallDisplayIcon={app}\Cellium Converter.exe
CreateAppDir=yes
SetupIconFile=app_icon.ico

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
chinesesimplified.desktopicon=创建桌面快捷方式
chinesesimplified.desktopiconGroup=附加图标
chinesesimplified.launch=启动 Cellium Converter
chinesesimplified.uninstall=卸载 Cellium Converter
english.desktopicon=Create a desktop shortcut
english.desktopiconGroup=Additional icons
english.launch=Launch Cellium Converter
english.uninstall=Uninstall Cellium Converter

[Tasks]
Name: "desktopicon"; Description: "{cm:desktopicon}"; GroupDescription: "{cm:desktopiconGroup}"

[Files]
Source: "dist\Cellium Converter.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Cellium Converter"; Filename: "{app}\Cellium Converter.exe"
Name: "{group}\{cm:uninstall}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\Cellium Converter"; Filename: "{app}\Cellium Converter.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Cellium Converter.exe"; Description: "{cm:launch}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
