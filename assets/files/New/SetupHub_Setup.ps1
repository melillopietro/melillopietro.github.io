<#
.SYNOPSIS
    SetupHub - Windows software installer, profile-based deployment and debloater.
.DESCRIPTION
    WPF GUI tool for automated software deployment via WinGet, optional bloatware removal,
    custom software profiles, bilingual UI (Italian/English), execution log and final HTML/CSV report.
.AUTHOR
    Pietro Melillo
.NOTES
    Requires Windows 10 1909+ / Windows 11, PowerShell 5.1+, Administrator privileges and WinGet.
    Some packages, including Microsoft 365 Apps / Office, may require a valid license/account.
#>

#region === BASE CONFIGURATION ===
$ErrorActionPreference = 'Stop'
$script:AppName = 'SetupHub'
$script:AppVersion = '3.0'
$script:DefaultLanguage = 'it'
$script:ProfileFolder = Join-Path $PSScriptRoot 'profiles'
$script:ReportFolder = Join-Path $PSScriptRoot 'reports'
New-Item -Path $script:ProfileFolder -ItemType Directory -Force | Out-Null
New-Item -Path $script:ReportFolder -ItemType Directory -Force | Out-Null
#endregion

#region === ASSEMBLIES ===
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic
#endregion

#region === ELEVATION & OS GUARD ===
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $args = "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    Start-Process powershell.exe -Verb RunAs -ArgumentList $args
    exit
}

$osBuild = [System.Environment]::OSVersion.Version.Build
if ($osBuild -lt 18363) {
    [System.Windows.MessageBox]::Show(
        "Questo tool richiede Windows 10 build 18363 o superiore.`nBuild attuale: $osBuild",
        "Versione OS non supportata",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
    exit 1
}
#endregion

#region === LOCALIZATION ===
$script:Lang = $script:DefaultLanguage
$script:Text = @{
    it = @{
        WindowTitle = 'SetupHub — Installer, Profili e Debloater Windows'
        HeaderTitle = 'SetupHub'
        HeaderSubtitle = 'Installer WinGet con profili software, report finale e rimozione bloatware'
        Language = 'Lingua'
        Profile = 'Profilo'
        ApplyProfile = 'Applica profilo'
        SaveProfile = 'Salva profilo'
        LoadProfile = 'Carica profilo'
        Reset = 'Reset consigliato'
        Credits = 'Credits'
        InstallPanel = 'Software da installare'
        BloatPanel = 'Bloatware da rimuovere'
        SelectAll = 'Seleziona tutto'
        DeselectAll = 'Deseleziona tutto'
        Start = 'Avvia'
        Cancel = 'Chiudi'
        Pending = 'In attesa di avvio...'
        Report = 'Genera report HTML/CSV'
        LogTitle = 'Log operazioni'
        NoSelection = 'Nessun pacchetto selezionato.'
        Warning = 'Attenzione'
        Completed = 'Completato!'
        SummaryTitle = 'Riepilogo operazioni'
        InstallPhase = 'FASE 1: Installazione software'
        RemovePhase = 'FASE 2: Rimozione bloatware'
        Installing = 'Installando'
        Removing = 'Rimuovendo'
        InstalledOk = 'installato con successo'
        RemovedOk = 'rimosso con successo'
        Error = 'ERRORE'
        ReportSaved = 'Report salvato in'
        ProfileSaved = 'Profilo salvato'
        ProfileLoaded = 'Profilo caricato'
        InsertProfileName = 'Inserisci il nome del profilo personalizzato:'
        ProfileNameTitle = 'Nuovo profilo'
        Footer = 'Creato da Pietro Melillo | Powered by WinGet | SetupHub v3.0'
    }
    en = @{
        WindowTitle = 'SetupHub — Windows Installer, Profiles and Debloater'
        HeaderTitle = 'SetupHub'
        HeaderSubtitle = 'WinGet installer with software profiles, final report and bloatware removal'
        Language = 'Language'
        Profile = 'Profile'
        ApplyProfile = 'Apply profile'
        SaveProfile = 'Save profile'
        LoadProfile = 'Load profile'
        Reset = 'Recommended reset'
        Credits = 'Credits'
        InstallPanel = 'Software to install'
        BloatPanel = 'Bloatware to remove'
        SelectAll = 'Select all'
        DeselectAll = 'Deselect all'
        Start = 'Start'
        Cancel = 'Close'
        Pending = 'Waiting to start...'
        Report = 'Generate HTML/CSV report'
        LogTitle = 'Operation log'
        NoSelection = 'No package selected.'
        Warning = 'Warning'
        Completed = 'Completed!'
        SummaryTitle = 'Operation summary'
        InstallPhase = 'PHASE 1: Software installation'
        RemovePhase = 'PHASE 2: Bloatware removal'
        Installing = 'Installing'
        Removing = 'Removing'
        InstalledOk = 'installed successfully'
        RemovedOk = 'removed successfully'
        Error = 'ERROR'
        ReportSaved = 'Report saved in'
        ProfileSaved = 'Profile saved'
        ProfileLoaded = 'Profile loaded'
        InsertProfileName = 'Enter the custom profile name:'
        ProfileNameTitle = 'New profile'
        Footer = 'Created by Pietro Melillo | Powered by WinGet | SetupHub v3.0'
    }
}
function T([string]$Key) { return $script:Text[$script:Lang][$Key] }
#endregion

#region === PACKAGE DEFINITIONS ===
# Profiles available: Essential, Business, Developer, Cybersecurity, Multimedia, Gaming, Home, Complete
$installPackages = @(
    # Core / Essential
    @{ Name = '7-Zip'; Id = '7zip.7zip'; Category = 'Core'; Checked = $true; Profiles = @('Essential','Business','Developer','Cybersecurity','Home') }
    @{ Name = 'NanaZip'; Id = 'M2Team.NanaZip'; Category = 'Core'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'WinRAR'; Id = 'RARLab.WinRAR'; Category = 'Core'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'Notepad++'; Id = 'Notepad++.Notepad++'; Category = 'Core'; Checked = $true; Profiles = @('Essential','Business','Developer','Cybersecurity','Home') }
    @{ Name = 'Everything Search'; Id = 'voidtools.Everything'; Category = 'Core'; Checked = $false; Profiles = @('Essential','Business','Developer','Cybersecurity','Home') }
    @{ Name = 'Microsoft PowerToys'; Id = 'Microsoft.PowerToys'; Category = 'Core'; Checked = $false; Profiles = @('Essential','Business','Developer','Home') }
    @{ Name = 'Windows Terminal'; Id = 'Microsoft.WindowsTerminal'; Category = 'Core'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'PowerShell 7'; Id = 'Microsoft.PowerShell'; Category = 'Core'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'PDF24 Creator'; Id = 'geeksoftwareGmbH.PDF24Creator'; Category = 'Core'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Adobe Acrobat Reader 64-bit'; Id = 'Adobe.Acrobat.Reader.64-bit'; Category = 'Core'; Checked = $true; Profiles = @('Essential','Business','Home') }
    @{ Name = 'Foxit PDF Reader'; Id = 'Foxit.FoxitReader'; Category = 'Core'; Checked = $false; Profiles = @('Business') }

    # Browsers / Communication
    @{ Name = 'Google Chrome'; Id = 'Google.Chrome'; Category = 'Browser'; Checked = $false; Profiles = @('Essential','Business','Developer','Cybersecurity','Home') }
    @{ Name = 'Mozilla Firefox'; Id = 'Mozilla.Firefox'; Category = 'Browser'; Checked = $false; Profiles = @('Essential','Developer','Cybersecurity','Home') }
    @{ Name = 'Brave Browser'; Id = 'Brave.Brave'; Category = 'Browser'; Checked = $false; Profiles = @('Cybersecurity','Home') }
    @{ Name = 'Opera Browser'; Id = 'Opera.Opera'; Category = 'Browser'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'Tor Browser'; Id = 'TorProject.TorBrowser'; Category = 'Browser'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'Microsoft Teams'; Id = 'Microsoft.Teams'; Category = 'Communication'; Checked = $false; Profiles = @('Business') }
    @{ Name = 'Zoom'; Id = 'Zoom.Zoom'; Category = 'Communication'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Slack'; Id = 'SlackTechnologies.Slack'; Category = 'Communication'; Checked = $false; Profiles = @('Business','Developer') }
    @{ Name = 'WhatsApp'; Id = 'WhatsApp.WhatsApp'; Category = 'Communication'; Checked = $true; Profiles = @('Essential','Business','Home') }
    @{ Name = 'Telegram Desktop'; Id = 'Telegram.TelegramDesktop'; Category = 'Communication'; Checked = $true; Profiles = @('Essential','Cybersecurity','Home') }
    @{ Name = 'Discord'; Id = 'Discord.Discord'; Category = 'Communication'; Checked = $false; Profiles = @('Gaming','Home') }

    # Office / Productivity
    @{ Name = 'Microsoft 365 Apps / Office'; Id = 'Microsoft.Office'; Category = 'Office'; Checked = $false; Profiles = @('Business'); SkipSilent = $true }
    @{ Name = 'Microsoft Office Deployment Tool'; Id = 'Microsoft.OfficeDeploymentTool'; Category = 'Office'; Checked = $false; Profiles = @('Business'); SkipSilent = $true }
    @{ Name = 'LibreOffice'; Id = 'TheDocumentFoundation.LibreOffice'; Category = 'Office'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Apache OpenOffice'; Id = 'Apache.OpenOffice'; Category = 'Office'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'Notion'; Id = 'Notion.Notion'; Category = 'Productivity'; Checked = $true; Profiles = @('Business','Home') }
    @{ Name = 'Obsidian'; Id = 'Obsidian.Obsidian'; Category = 'Productivity'; Checked = $false; Profiles = @('Developer','Cybersecurity','Home') }
    @{ Name = 'Joplin'; Id = 'Joplin.Joplin'; Category = 'Productivity'; Checked = $false; Profiles = @('Cybersecurity','Home') }
    @{ Name = 'Microsoft To Do'; Id = 'Microsoft.Todos'; Category = 'Productivity'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'OneDrive'; Id = 'Microsoft.OneDrive'; Category = 'Cloud'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Google Drive'; Id = 'Google.Drive'; Category = 'Cloud'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Dropbox'; Id = 'Dropbox.Dropbox'; Category = 'Cloud'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Synology Drive Client'; Id = 'Synology.DriveClient'; Category = 'Cloud'; Checked = $true; Profiles = @('Business','Home') }

    # Developer
    @{ Name = 'Git'; Id = 'Git.Git'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'GitHub Desktop'; Id = 'GitHub.GitHubDesktop'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'Visual Studio Code'; Id = 'Microsoft.VisualStudioCode'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'Visual Studio 2022 Community'; Id = 'Microsoft.VisualStudio.2022.Community'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'Python 3.12'; Id = 'Python.Python.3.12'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'Node.js LTS'; Id = 'OpenJS.NodeJS.LTS'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'Go'; Id = 'GoLang.Go'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'Rustup'; Id = 'Rustlang.Rustup'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'Java JDK 21 Temurin'; Id = 'EclipseAdoptium.Temurin.21.JDK'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'Docker Desktop'; Id = 'Docker.DockerDesktop'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'Postman'; Id = 'Postman.Postman'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'JetBrains Toolbox'; Id = 'JetBrains.Toolbox'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'PyCharm Community'; Id = 'JetBrains.PyCharm.Community'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'Sublime Text 4'; Id = 'SublimeHQ.SublimeText.4'; Category = 'Developer'; Checked = $false; Profiles = @('Developer') }
    @{ Name = 'WinSCP'; Id = 'WinSCP.WinSCP'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'PuTTY'; Id = 'PuTTY.PuTTY'; Category = 'Developer'; Checked = $false; Profiles = @('Developer','Cybersecurity') }

    # Cybersecurity / Admin
    @{ Name = 'Wireshark'; Id = 'WiresharkFoundation.Wireshark'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'Nmap'; Id = 'Insecure.Nmap'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'Burp Suite Community'; Id = 'PortSwigger.BurpSuite.Community'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'OWASP ZAP'; Id = 'ZAP.ZAP'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'Ghidra'; Id = 'NSA.Ghidra'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'YARA'; Id = 'VirusTotal.YARA'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'Sysinternals Suite'; Id = 'Microsoft.Sysinternals'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }
    @{ Name = 'OpenVPN'; Id = 'OpenVPNTechnologies.OpenVPN'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity','Business') }
    @{ Name = 'WireGuard'; Id = 'WireGuard.WireGuard'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity','Business') }
    @{ Name = 'Bitwarden'; Id = 'Bitwarden.Bitwarden'; Category = 'Security'; Checked = $false; Profiles = @('Essential','Business','Cybersecurity','Home') }
    @{ Name = 'KeePassXC'; Id = 'KeePassXCTeam.KeePassXC'; Category = 'Security'; Checked = $false; Profiles = @('Cybersecurity','Home') }
    @{ Name = 'VirusTotal Uploader'; Id = 'VirusTotal.VirusTotalUploader'; Category = 'Cybersecurity'; Checked = $false; Profiles = @('Cybersecurity') }

    # Remote support / Utilities / Drivers
    @{ Name = 'AnyDesk'; Id = 'AnyDeskSoftwareGmbH.AnyDesk'; Category = 'Remote'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'TeamViewer'; Id = 'TeamViewer.TeamViewer'; Category = 'Remote'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'RustDesk'; Id = 'RustDesk.RustDesk'; Category = 'Remote'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Rufus'; Id = 'Rufus.Rufus'; Category = 'Utility'; Checked = $false; Profiles = @('Developer','Cybersecurity','Home') }
    @{ Name = 'balenaEtcher'; Id = 'Balena.Etcher'; Category = 'Utility'; Checked = $false; Profiles = @('Developer','Cybersecurity','Home') }
    @{ Name = 'Recuva'; Id = 'Piriform.Recuva'; Category = 'Utility'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'CrystalDiskInfo'; Id = 'CrystalDewWorld.CrystalDiskInfo'; Category = 'Utility'; Checked = $false; Profiles = @('Essential','Home') }
    @{ Name = 'CrystalDiskMark'; Id = 'CrystalDewWorld.CrystalDiskMark'; Category = 'Utility'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'CPU-Z'; Id = 'CPUID.CPU-Z'; Category = 'Utility'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'HWMonitor'; Id = 'CPUID.HWMonitor'; Category = 'Utility'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'HWiNFO'; Id = 'REALiX.HWiNFO'; Category = 'Utility'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'Intel Driver & Support Assistant'; Id = 'Intel.IntelDriverAndSupportAssistant'; Category = 'Driver'; Checked = $false; Profiles = @('Home') }
    @{ Name = 'NVIDIA GeForce Experience'; Id = 'Nvidia.GeForceExperience'; Category = 'Driver'; Checked = $false; Profiles = @('Gaming','Home') }

    # Multimedia / Creative / Gaming
    @{ Name = 'VLC'; Id = 'VideoLAN.VLC'; Category = 'Multimedia'; Checked = $true; Profiles = @('Essential','Home','Multimedia') }
    @{ Name = 'Spotify'; Id = 'Spotify.Spotify'; Category = 'Multimedia'; Checked = $false; Profiles = @('Home','Multimedia') }
    @{ Name = 'OBS Studio'; Id = 'OBSProject.OBSStudio'; Category = 'Multimedia'; Checked = $true; Profiles = @('Multimedia','Home') }
    @{ Name = 'Audacity'; Id = 'Audacity.Audacity'; Category = 'Multimedia'; Checked = $false; Profiles = @('Multimedia') }
    @{ Name = 'GIMP'; Id = 'GIMP.GIMP'; Category = 'Creative'; Checked = $false; Profiles = @('Multimedia','Home') }
    @{ Name = 'Inkscape'; Id = 'Inkscape.Inkscape'; Category = 'Creative'; Checked = $false; Profiles = @('Multimedia') }
    @{ Name = 'Kdenlive'; Id = 'KDE.Kdenlive'; Category = 'Creative'; Checked = $false; Profiles = @('Multimedia') }
    @{ Name = 'Blender'; Id = 'BlenderFoundation.Blender'; Category = 'Creative'; Checked = $false; Profiles = @('Multimedia') }
    @{ Name = 'ShareX'; Id = 'ShareX.ShareX'; Category = 'Screenshot'; Checked = $false; Profiles = @('Developer','Cybersecurity','Multimedia','Home') }
    @{ Name = 'Greenshot'; Id = 'Greenshot.Greenshot'; Category = 'Screenshot'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Screenpresso'; Id = 'Learnpulse.Screenpresso'; Category = 'Screenshot'; Checked = $false; Profiles = @('Business','Home') }
    @{ Name = 'Steam'; Id = 'Valve.Steam'; Category = 'Gaming'; Checked = $false; Profiles = @('Gaming') }
    @{ Name = 'Epic Games Launcher'; Id = 'EpicGames.EpicGamesLauncher'; Category = 'Gaming'; Checked = $false; Profiles = @('Gaming') }
    @{ Name = 'EA App'; Id = 'ElectronicArts.EADesktop'; Category = 'Gaming'; Checked = $false; Profiles = @('Gaming') }

    # Virtualization / VPN
    @{ Name = 'VMware Workstation Pro'; Id = 'VMware.WorkstationPro'; Category = 'Virtualization'; Checked = $true; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'VirtualBox'; Id = 'Oracle.VirtualBox'; Category = 'Virtualization'; Checked = $false; Profiles = @('Developer','Cybersecurity') }
    @{ Name = 'NordVPN'; Id = 'NordVPN.NordVPN'; Category = 'VPN'; Checked = $true; Profiles = @('Home') }
    @{ Name = 'qBittorrent'; Id = 'qBittorrent.qBittorrent'; Category = 'Utility'; Checked = $false; Profiles = @('Home') }
)

$bloatwarePackages = @(
    @{ Name = 'Xbox Gaming App'; Id = 'Microsoft.GamingApp_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Home','Complete') }
    @{ Name = 'Xbox App'; Id = 'Microsoft.XboxApp_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Home','Complete') }
    @{ Name = 'Xbox TCUI'; Id = 'Microsoft.Xbox.TCUI_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Xbox Speech Overlay'; Id = 'Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Xbox Identity Provider'; Id = 'Microsoft.XboxIdentityProvider_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Xbox Gaming Overlay'; Id = 'Microsoft.XboxGamingOverlay_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Xbox Game Overlay'; Id = 'Microsoft.XboxGameOverlay_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Groove Music'; Id = 'Microsoft.ZuneMusic_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Movies & TV'; Id = 'Microsoft.ZuneVideo_8wekyb3d8bbwe'; Checked = $false; Profiles = @('Complete') }
    @{ Name = 'Feedback Hub'; Id = 'Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Microsoft Tips'; Id = 'Microsoft.Getstarted_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = '3D Viewer'; Id = 'Microsoft.Microsoft3DViewer_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Microsoft Solitaire'; Id = 'Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Paint 3D'; Id = 'Microsoft.MSPaint_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Weather'; Id = 'Microsoft.BingWeather_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Mail & Calendar'; Id = 'microsoft.windowscommunicationsapps_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Your Phone'; Id = 'Microsoft.YourPhone_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'People'; Id = 'Microsoft.People_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Microsoft Pay'; Id = 'Microsoft.Wallet_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Microsoft Maps'; Id = 'Microsoft.WindowsMaps_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'OneNote UWP'; Id = 'Microsoft.Office.OneNote_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Voice Recorder'; Id = 'Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Mixed Reality Portal'; Id = 'Microsoft.MixedReality.Portal_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Sticky Notes'; Id = 'Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe'; Checked = $false; Profiles = @('Complete') }
    @{ Name = 'Get Help'; Id = 'Microsoft.GetHelp_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Cortana'; Id = 'Microsoft.549981C3F5F10_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Skype'; Id = 'Microsoft.SkypeApp_kzf8qxf38zg5c'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Power Automate'; Id = 'Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Bing News'; Id = 'Microsoft.BingNews_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Microsoft Teams Personal'; Id = 'MicrosoftTeams_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Microsoft Family'; Id = 'MicrosoftCorporationII.MicrosoftFamily_8wekyb3d8bbwe'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Quick Assist'; Id = 'MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe'; Checked = $false; Profiles = @('Complete') }
    @{ Name = 'Disney+'; Id = 'Disney.37853FC22B2CE_6rarf9sa4v8jt'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Clipchamp'; Id = 'Clipchamp.Clipchamp_yxz26nhyzhsrt'; Checked = $true; Profiles = @('Clean','Complete') }
    @{ Name = 'Office Hub'; Id = 'Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe'; Checked = $false; Profiles = @('Complete') }
)
#endregion

#region === WINGET BOOTSTRAP ===
function Test-WinGetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        $version = (winget --version 2>$null)
        return ($null -ne $version)
    } catch { return $false }
}

function Install-WinGetBootstrap {
    $splashXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Preparazione ambiente..." Height="210" Width="470"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        WindowStyle="ToolWindow" Background="#1e1e2e">
    <StackPanel VerticalAlignment="Center" Margin="30">
        <TextBlock Text="Installazione / verifica WinGet in corso..."
                   Foreground="#cdd6f4" FontSize="16" FontWeight="SemiBold"
                   HorizontalAlignment="Center" Margin="0,0,0,15"/>
        <ProgressBar IsIndeterminate="True" Height="6" Foreground="#89b4fa"
                     Background="#313244" BorderThickness="0"/>
        <TextBlock Text="Download dei componenti Microsoft necessari"
                   Foreground="#a6adc8" FontSize="11" HorizontalAlignment="Center"
                   Margin="0,12,0,0"/>
    </StackPanel>
</Window>
"@
    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($splashXaml))
    $splashWindow = [System.Windows.Markup.XamlReader]::Load($reader)
    $splashWindow.Show()
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

    try {
        $progressPreference = 'SilentlyContinue'
        $vcLibsPath = "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $vcLibsPath -UseBasicParsing
        Add-AppxPackage -Path $vcLibsPath -ErrorAction SilentlyContinue

        $uiXamlUrl = 'https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6'
        $uiXamlPath = "$env:TEMP\microsoft.ui.xaml.2.8.6.nupkg.zip"
        $uiXamlExtract = "$env:TEMP\microsoft.ui.xaml"
        Invoke-WebRequest -Uri $uiXamlUrl -OutFile $uiXamlPath -UseBasicParsing
        Expand-Archive -Path $uiXamlPath -DestinationPath $uiXamlExtract -Force
        $uiXamlAppx = Get-ChildItem -Path "$uiXamlExtract\tools\AppX\x64\Release\" -Filter '*.appx' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($uiXamlAppx) { Add-AppxPackage -Path $uiXamlAppx.FullName -ErrorAction SilentlyContinue }

        $latestRelease = Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' -UseBasicParsing
        $msixBundleAsset = $latestRelease.assets | Where-Object { $_.name -match '\.msixbundle$' } | Select-Object -First 1
        $licenseAsset = $latestRelease.assets | Where-Object { $_.name -match 'License.*\.xml$' } | Select-Object -First 1
        $msixPath = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
        Invoke-WebRequest -Uri $msixBundleAsset.browser_download_url -OutFile $msixPath -UseBasicParsing

        if ($licenseAsset) {
            $licensePath = "$env:TEMP\WinGet_License.xml"
            Invoke-WebRequest -Uri $licenseAsset.browser_download_url -OutFile $licensePath -UseBasicParsing
            Add-AppxProvisionedPackage -Online -PackagePath $msixPath -LicensePath $licensePath -ErrorAction SilentlyContinue
        }
        Add-AppxPackage -Path $msixPath -ForceApplicationShutdown
        $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('PATH','User')
    } catch {
        $splashWindow.Close()
        [System.Windows.MessageBox]::Show("Errore durante l'installazione di WinGet:`n$($_.Exception.Message)", 'Errore Bootstrap', 'OK', 'Error') | Out-Null
        exit 1
    }
    $splashWindow.Close()
    Start-Sleep -Seconds 2
    if (-not (Test-WinGetAvailable)) {
        [System.Windows.MessageBox]::Show('WinGet non risulta disponibile. Riavviare il PC e riprovare.', 'WinGet non trovato', 'OK', 'Warning') | Out-Null
        exit 1
    }
}
if (-not (Test-WinGetAvailable)) { Install-WinGetBootstrap }
#endregion

#region === GUI XAML ===
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="SetupHub" Height="900" Width="1280" MinHeight="760" MinWidth="1050"
        WindowStartupLocation="CenterScreen" Background="#1e1e2e">
    <Window.Resources>
        <Style x:Key="PanelHeader" TargetType="TextBlock">
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Foreground" Value="#cdd6f4"/>
            <Setter Property="Margin" Value="0,0,0,8"/>
        </Style>
        <Style x:Key="ActionButton" TargetType="Button">
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="12,7"/>
            <Setter Property="Margin" Value="4,0"/>
            <Setter Property="Background" Value="#313244"/>
            <Setter Property="Foreground" Value="#cdd6f4"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#45475a"/></Trigger>
                <Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.5"/></Trigger>
            </Style.Triggers>
        </Style>
        <Style x:Key="ComboStyle" TargetType="ComboBox">
            <Setter Property="Margin" Value="6,0"/>
            <Setter Property="Height" Value="28"/>
            <Setter Property="MinWidth" Value="150"/>
        </Style>
    </Window.Resources>
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="230"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#181825" Padding="14" BorderBrush="#313244" BorderThickness="0,0,0,1">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0">
                    <TextBlock x:Name="lblHeaderTitle" Text="SetupHub" Foreground="#cdd6f4" FontSize="26" FontWeight="Bold"/>
                    <TextBlock x:Name="lblHeaderSubtitle" Text="Installer WinGet con profili software, report finale e rimozione bloatware" Foreground="#a6adc8" FontSize="12"/>
                </StackPanel>
                <WrapPanel Grid.Column="1" VerticalAlignment="Center" HorizontalAlignment="Right">
                    <TextBlock x:Name="lblLanguage" Foreground="#a6adc8" VerticalAlignment="Center" Text="Lingua"/>
                    <ComboBox x:Name="cmbLanguage" Style="{StaticResource ComboStyle}">
                        <ComboBoxItem Content="Italiano" Tag="it" IsSelected="True"/>
                        <ComboBoxItem Content="English" Tag="en"/>
                    </ComboBox>
                    <Button x:Name="btnCredits" Content="Credits" Style="{StaticResource ActionButton}"/>
                </WrapPanel>
            </Grid>
        </Border>

        <Grid Grid.Row="1" Margin="12,12,12,6">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.4*"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0" Background="#181825" CornerRadius="8" Padding="12">
                <DockPanel>
                    <StackPanel DockPanel.Dock="Top">
                        <TextBlock x:Name="lblInstallPanel" Style="{StaticResource PanelHeader}" Text="Software da installare"/>
                        <WrapPanel Margin="0,0,0,8">
                            <TextBlock x:Name="lblProfile" Foreground="#a6adc8" VerticalAlignment="Center" Text="Profilo"/>
                            <ComboBox x:Name="cmbProfile" Style="{StaticResource ComboStyle}" MinWidth="190"/>
                            <Button x:Name="btnApplyProfile" Content="Applica profilo" Style="{StaticResource ActionButton}"/>
                            <Button x:Name="btnSaveProfile" Content="Salva profilo" Style="{StaticResource ActionButton}"/>
                            <Button x:Name="btnLoadProfile" Content="Carica profilo" Style="{StaticResource ActionButton}"/>
                        </WrapPanel>
                        <WrapPanel Margin="0,0,0,8">
                            <Button x:Name="btnSelectAllInstall" Content="Seleziona tutto" Style="{StaticResource ActionButton}" FontSize="11"/>
                            <Button x:Name="btnDeselectAllInstall" Content="Deseleziona tutto" Style="{StaticResource ActionButton}" FontSize="11"/>
                            <Button x:Name="btnResetRecommended" Content="Reset consigliato" Style="{StaticResource ActionButton}" FontSize="11"/>
                        </WrapPanel>
                    </StackPanel>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="panelInstall"/>
                    </ScrollViewer>
                </DockPanel>
            </Border>

            <Border Grid.Column="2" Background="#181825" CornerRadius="8" Padding="12">
                <DockPanel>
                    <StackPanel DockPanel.Dock="Top">
                        <TextBlock x:Name="lblBloatPanel" Style="{StaticResource PanelHeader}" Text="Bloatware da rimuovere"/>
                        <WrapPanel Margin="0,0,0,8">
                            <Button x:Name="btnSelectAllBloat" Content="Seleziona tutto" Style="{StaticResource ActionButton}" FontSize="11"/>
                            <Button x:Name="btnDeselectAllBloat" Content="Deseleziona tutto" Style="{StaticResource ActionButton}" FontSize="11"/>
                        </WrapPanel>
                    </StackPanel>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="panelBloatware"/>
                    </ScrollViewer>
                </DockPanel>
            </Border>
        </Grid>

        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,6,0,8">
            <CheckBox x:Name="chkReport" Content="Genera report HTML/CSV" Foreground="#cdd6f4" IsChecked="True" VerticalAlignment="Center" Margin="0,0,20,0"/>
            <Button x:Name="btnStart" Style="{StaticResource ActionButton}" Background="#a6e3a1" Foreground="#1e1e2e" FontSize="13" Content="Avvia" Padding="22,9"/>
            <Button x:Name="btnCancel" Style="{StaticResource ActionButton}" Background="#f38ba8" Foreground="#1e1e2e" FontSize="13" Content="Chiudi" Padding="22,9"/>
        </StackPanel>

        <Border Grid.Row="3" Background="#11111b" Margin="12,0,12,8" CornerRadius="8" Padding="10">
            <DockPanel>
                <StackPanel DockPanel.Dock="Top" Margin="0,0,0,6">
                    <TextBlock x:Name="lblCurrentOp" Text="In attesa di avvio..." Foreground="#a6adc8" FontSize="12" Margin="0,0,0,4"/>
                    <ProgressBar x:Name="progressBar" Height="8" Minimum="0" Maximum="100" Value="0" Foreground="#89b4fa" Background="#313244" BorderThickness="0"/>
                    <TextBlock x:Name="lblProgress" Text="0%" Foreground="#6c7086" FontSize="10" HorizontalAlignment="Right" Margin="0,2,0,0"/>
                </StackPanel>
                <TextBox x:Name="txtLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto" Background="#11111b" Foreground="#a6e3a1" BorderThickness="0" FontFamily="Consolas" FontSize="11" TextWrapping="Wrap" AcceptsReturn="True"/>
            </DockPanel>
        </Border>

        <Border Grid.Row="4" Background="#181825" Padding="10,6">
            <TextBlock x:Name="lblFooter" Text="Creato da Pietro Melillo | Powered by WinGet | SetupHub v3.0" Foreground="#6c7086" FontSize="10" HorizontalAlignment="Center"/>
        </Border>
    </Grid>
</Window>
"@
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)
#endregion

#region === GUI ELEMENTS ===
$panelInstall = $window.FindName('panelInstall')
$panelBloatware = $window.FindName('panelBloatware')
$btnSelectAllInstall = $window.FindName('btnSelectAllInstall')
$btnDeselectAllInstall = $window.FindName('btnDeselectAllInstall')
$btnSelectAllBloat = $window.FindName('btnSelectAllBloat')
$btnDeselectAllBloat = $window.FindName('btnDeselectAllBloat')
$btnResetRecommended = $window.FindName('btnResetRecommended')
$btnApplyProfile = $window.FindName('btnApplyProfile')
$btnSaveProfile = $window.FindName('btnSaveProfile')
$btnLoadProfile = $window.FindName('btnLoadProfile')
$btnCredits = $window.FindName('btnCredits')
$btnStart = $window.FindName('btnStart')
$btnCancel = $window.FindName('btnCancel')
$cmbLanguage = $window.FindName('cmbLanguage')
$cmbProfile = $window.FindName('cmbProfile')
$chkReport = $window.FindName('chkReport')
$progressBar = $window.FindName('progressBar')
$lblProgress = $window.FindName('lblProgress')
$lblCurrentOp = $window.FindName('lblCurrentOp')
$txtLog = $window.FindName('txtLog')
$lblHeaderTitle = $window.FindName('lblHeaderTitle')
$lblHeaderSubtitle = $window.FindName('lblHeaderSubtitle')
$lblLanguage = $window.FindName('lblLanguage')
$lblInstallPanel = $window.FindName('lblInstallPanel')
$lblBloatPanel = $window.FindName('lblBloatPanel')
$lblProfile = $window.FindName('lblProfile')
$lblFooter = $window.FindName('lblFooter')
#endregion

#region === DYNAMIC ITEM GENERATION ===
$script:installCheckboxes = @()
$script:bloatCheckboxes = @()
$script:installStatusLabels = @()
$script:bloatStatusLabels = @()

function New-PackageItem {
    param(
        [string]$Name,
        [string]$Id,
        [string]$Category,
        [bool]$IsChecked,
        [System.Windows.Controls.Panel]$Panel,
        [ref]$CheckboxList,
        [ref]$StatusList
    )
    $border = New-Object System.Windows.Controls.Border
    $border.Margin = [System.Windows.Thickness]::new(0,2,0,2)
    $border.Padding = [System.Windows.Thickness]::new(8,5,8,5)
    $border.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#1e1e2e')
    $border.CornerRadius = [System.Windows.CornerRadius]::new(4)

    $grid = New-Object System.Windows.Controls.Grid
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = [System.Windows.GridLength]::new(1,[System.Windows.GridUnitType]::Star)
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = [System.Windows.GridLength]::new(34)
    $grid.ColumnDefinitions.Add($col1)
    $grid.ColumnDefinitions.Add($col2)

    $checkPanel = New-Object System.Windows.Controls.StackPanel
    $checkPanel.Orientation = 'Horizontal'
    [System.Windows.Controls.Grid]::SetColumn($checkPanel,0)

    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.IsChecked = $IsChecked
    $checkbox.VerticalAlignment = 'Center'
    $checkbox.Margin = [System.Windows.Thickness]::new(0,0,8,0)
    $checkbox.Tag = $Id

    $textPanel = New-Object System.Windows.Controls.StackPanel
    $textPanel.VerticalAlignment = 'Center'

    $nameBlock = New-Object System.Windows.Controls.TextBlock
    $nameBlock.Text = $Name
    $nameBlock.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#cdd6f4')
    $nameBlock.FontSize = 12
    $nameBlock.FontWeight = 'Medium'

    $idBlock = New-Object System.Windows.Controls.TextBlock
    if ([string]::IsNullOrWhiteSpace($Category)) { $idBlock.Text = $Id } else { $idBlock.Text = "[$Category] $Id" }
    $idBlock.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#6c7086')
    $idBlock.FontSize = 9.5

    $textPanel.Children.Add($nameBlock) | Out-Null
    $textPanel.Children.Add($idBlock) | Out-Null
    $checkPanel.Children.Add($checkbox) | Out-Null
    $checkPanel.Children.Add($textPanel) | Out-Null

    $statusLabel = New-Object System.Windows.Controls.TextBlock
    $statusLabel.Text = ''
    $statusLabel.FontSize = 14
    $statusLabel.VerticalAlignment = 'Center'
    $statusLabel.HorizontalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetColumn($statusLabel,1)

    $grid.Children.Add($checkPanel) | Out-Null
    $grid.Children.Add($statusLabel) | Out-Null
    $border.Child = $grid
    $Panel.Children.Add($border) | Out-Null

    $CheckboxList.Value += $checkbox
    $StatusList.Value += $statusLabel
}

foreach ($pkg in $installPackages) {
    New-PackageItem -Name $pkg.Name -Id $pkg.Id -Category $pkg.Category -IsChecked $pkg.Checked -Panel $panelInstall -CheckboxList ([ref]$script:installCheckboxes) -StatusList ([ref]$script:installStatusLabels)
}
foreach ($pkg in $bloatwarePackages) {
    New-PackageItem -Name $pkg.Name -Id $pkg.Id -Category 'Windows App' -IsChecked $pkg.Checked -Panel $panelBloatware -CheckboxList ([ref]$script:bloatCheckboxes) -StatusList ([ref]$script:bloatStatusLabels)
}
#endregion

#region === PROFILE & LOCALIZATION HELPERS ===
$profiles = @('Essential','Business','Developer','Cybersecurity','Multimedia','Gaming','Home','Clean','Complete')
foreach ($p in $profiles) { [void]$cmbProfile.Items.Add($p) }
$cmbProfile.SelectedItem = 'Essential'

function Set-UILanguage {
    $window.Title = T 'WindowTitle'
    $lblHeaderTitle.Text = T 'HeaderTitle'
    $lblHeaderSubtitle.Text = T 'HeaderSubtitle'
    $lblLanguage.Text = T 'Language'
    $lblInstallPanel.Text = T 'InstallPanel'
    $lblBloatPanel.Text = T 'BloatPanel'
    $lblProfile.Text = T 'Profile'
    $btnApplyProfile.Content = T 'ApplyProfile'
    $btnSaveProfile.Content = T 'SaveProfile'
    $btnLoadProfile.Content = T 'LoadProfile'
    $btnResetRecommended.Content = T 'Reset'
    $btnSelectAllInstall.Content = T 'SelectAll'
    $btnDeselectAllInstall.Content = T 'DeselectAll'
    $btnSelectAllBloat.Content = T 'SelectAll'
    $btnDeselectAllBloat.Content = T 'DeselectAll'
    $btnStart.Content = T 'Start'
    $btnCancel.Content = T 'Cancel'
    $btnCredits.Content = T 'Credits'
    $chkReport.Content = T 'Report'
    $lblCurrentOp.Text = T 'Pending'
    $lblFooter.Text = T 'Footer'
}

function Apply-RecommendedDefaults {
    for ($i=0; $i -lt $script:installCheckboxes.Count; $i++) { $script:installCheckboxes[$i].IsChecked = [bool]$installPackages[$i].Checked }
    for ($i=0; $i -lt $script:bloatCheckboxes.Count; $i++) { $script:bloatCheckboxes[$i].IsChecked = [bool]$bloatwarePackages[$i].Checked }
}

function Apply-ProfileSelection([string]$ProfileName) {
    if ([string]::IsNullOrWhiteSpace($ProfileName)) { return }
    for ($i=0; $i -lt $script:installCheckboxes.Count; $i++) {
        $pkgProfiles = @($installPackages[$i].Profiles)
        $script:installCheckboxes[$i].IsChecked = ($ProfileName -eq 'Complete' -or $pkgProfiles -contains $ProfileName)
    }
    for ($i=0; $i -lt $script:bloatCheckboxes.Count; $i++) {
        $pkgProfiles = @($bloatwarePackages[$i].Profiles)
        if ($ProfileName -eq 'Clean') {
            $script:bloatCheckboxes[$i].IsChecked = ($pkgProfiles -contains 'Clean')
        } elseif ($ProfileName -eq 'Complete') {
            $script:bloatCheckboxes[$i].IsChecked = ($pkgProfiles -contains 'Complete')
        } else {
            $script:bloatCheckboxes[$i].IsChecked = $false
        }
    }
}

function Get-SelectedIds {
    $installIds = @()
    for ($i=0; $i -lt $script:installCheckboxes.Count; $i++) { if ($script:installCheckboxes[$i].IsChecked) { $installIds += [string]$script:installCheckboxes[$i].Tag } }
    $bloatIds = @()
    for ($i=0; $i -lt $script:bloatCheckboxes.Count; $i++) { if ($script:bloatCheckboxes[$i].IsChecked) { $bloatIds += [string]$script:bloatCheckboxes[$i].Tag } }
    return @{ InstallIds = $installIds; BloatIds = $bloatIds }
}

function Save-CustomProfile {
    $name = [Microsoft.VisualBasic.Interaction]::InputBox((T 'InsertProfileName'), (T 'ProfileNameTitle'), 'MyProfile')
    if ([string]::IsNullOrWhiteSpace($name)) { return }
    $safeName = ($name -replace '[^a-zA-Z0-9_\- ]','_').Trim()
    $selection = Get-SelectedIds
    $profileObject = [ordered]@{
        Name = $name
        CreatedAt = (Get-Date).ToString('s')
        InstallIds = $selection.InstallIds
        BloatIds = $selection.BloatIds
    }
    $path = Join-Path $script:ProfileFolder "$safeName.json"
    $profileObject | ConvertTo-Json -Depth 5 | Set-Content -Path $path -Encoding UTF8
    [System.Windows.MessageBox]::Show("$(T 'ProfileSaved'):`n$path", $script:AppName, 'OK', 'Information') | Out-Null
}

function Load-CustomProfile {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = $script:ProfileFolder
    $dialog.Filter = 'JSON profile (*.json)|*.json'
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return }
    $profile = Get-Content -Path $dialog.FileName -Raw | ConvertFrom-Json
    $installIds = @($profile.InstallIds)
    $bloatIds = @($profile.BloatIds)
    for ($i=0; $i -lt $script:installCheckboxes.Count; $i++) { $script:installCheckboxes[$i].IsChecked = ($installIds -contains [string]$script:installCheckboxes[$i].Tag) }
    for ($i=0; $i -lt $script:bloatCheckboxes.Count; $i++) { $script:bloatCheckboxes[$i].IsChecked = ($bloatIds -contains [string]$script:bloatCheckboxes[$i].Tag) }
    [System.Windows.MessageBox]::Show("$(T 'ProfileLoaded'):`n$($profile.Name)", $script:AppName, 'OK', 'Information') | Out-Null
}
Set-UILanguage
#endregion

#region === BUTTON HANDLERS ===
$btnSelectAllInstall.Add_Click({ foreach ($cb in $script:installCheckboxes) { $cb.IsChecked = $true } })
$btnDeselectAllInstall.Add_Click({ foreach ($cb in $script:installCheckboxes) { $cb.IsChecked = $false } })
$btnSelectAllBloat.Add_Click({ foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $true } })
$btnDeselectAllBloat.Add_Click({ foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $false } })
$btnResetRecommended.Add_Click({ Apply-RecommendedDefaults })
$btnApplyProfile.Add_Click({ Apply-ProfileSelection -ProfileName ([string]$cmbProfile.SelectedItem) })
$btnSaveProfile.Add_Click({ Save-CustomProfile })
$btnLoadProfile.Add_Click({ Load-CustomProfile })
$btnCredits.Add_Click({
    $msg = "SetupHub v$script:AppVersion`n`nCreated by Pietro Melillo.`n`nPurpose: Windows post-installation automation, software profiles, debloating and final reporting.`n`nPowered by Microsoft WinGet / Windows Package Manager. Package availability and licenses remain under their respective vendors. Microsoft 365 Apps / Office requires a valid Microsoft license/account."
    [System.Windows.MessageBox]::Show($msg, 'Credits', 'OK', 'Information') | Out-Null
})
$cmbLanguage.Add_SelectionChanged({
    $selected = $cmbLanguage.SelectedItem
    if ($selected -and $selected.Tag) {
        $script:Lang = [string]$selected.Tag
        Set-UILanguage
    }
})
$btnCancel.Add_Click({ $window.Close() })

$btnStart.Add_Click({
    $selectedInstalls = @()
    for ($i=0; $i -lt $script:installCheckboxes.Count; $i++) {
        if ($script:installCheckboxes[$i].IsChecked) {
            $selectedInstalls += @{
                Index = $i
                Id = [string]$script:installCheckboxes[$i].Tag
                Name = [string]$installPackages[$i].Name
                Category = [string]$installPackages[$i].Category
                SkipSilent = [bool]$installPackages[$i].SkipSilent
            }
        }
    }
    $selectedBloat = @()
    for ($i=0; $i -lt $script:bloatCheckboxes.Count; $i++) {
        if ($script:bloatCheckboxes[$i].IsChecked) {
            $selectedBloat += @{
                Index = $i
                Id = [string]$script:bloatCheckboxes[$i].Tag
                Name = [string]$bloatwarePackages[$i].Name
            }
        }
    }
    $totalOps = $selectedInstalls.Count + $selectedBloat.Count
    if ($totalOps -eq 0) {
        [System.Windows.MessageBox]::Show((T 'NoSelection'), (T 'Warning'), 'OK', 'Warning') | Out-Null
        return
    }

    $btnStart.IsEnabled = $false
    $btnCancel.Content = T 'Cancel'
    foreach ($control in @($btnSelectAllInstall,$btnDeselectAllInstall,$btnSelectAllBloat,$btnDeselectAllBloat,$btnResetRecommended,$btnApplyProfile,$btnSaveProfile,$btnLoadProfile,$cmbProfile,$cmbLanguage)) { $control.IsEnabled = $false }
    foreach ($cb in $script:installCheckboxes) { $cb.IsEnabled = $false }
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsEnabled = $false }
    foreach ($item in $selectedInstalls) { $script:installStatusLabels[$item.Index].Text = [string][char]0x23F3 }
    foreach ($item in $selectedBloat) { $script:bloatStatusLabels[$item.Index].Text = [string][char]0x23F3 }

    $dispatcher = $window.Dispatcher
    $createReport = [bool]$chkReport.IsChecked
    $reportFolder = $script:ReportFolder
    $lang = $script:Lang
    $selectedProfile = [string]$cmbProfile.SelectedItem
    $appName = $script:AppName
    $appVersion = $script:AppVersion
    $textTable = $script:Text[$script:Lang]

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = 'STA'
    $runspace.ThreadOptions = 'ReuseThread'
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable('selectedInstalls', $selectedInstalls)
    $runspace.SessionStateProxy.SetVariable('selectedBloat', $selectedBloat)
    $runspace.SessionStateProxy.SetVariable('totalOps', $totalOps)
    $runspace.SessionStateProxy.SetVariable('dispatcher', $dispatcher)
    $runspace.SessionStateProxy.SetVariable('progressBar', $progressBar)
    $runspace.SessionStateProxy.SetVariable('lblProgress', $lblProgress)
    $runspace.SessionStateProxy.SetVariable('lblCurrentOp', $lblCurrentOp)
    $runspace.SessionStateProxy.SetVariable('txtLog', $txtLog)
    $runspace.SessionStateProxy.SetVariable('installStatusLabels', $script:installStatusLabels)
    $runspace.SessionStateProxy.SetVariable('bloatStatusLabels', $script:bloatStatusLabels)
    $runspace.SessionStateProxy.SetVariable('btnStart', $btnStart)
    $runspace.SessionStateProxy.SetVariable('btnCancel', $btnCancel)
    $runspace.SessionStateProxy.SetVariable('window', $window)
    $runspace.SessionStateProxy.SetVariable('createReport', $createReport)
    $runspace.SessionStateProxy.SetVariable('reportFolder', $reportFolder)
    $runspace.SessionStateProxy.SetVariable('lang', $lang)
    $runspace.SessionStateProxy.SetVariable('selectedProfile', $selectedProfile)
    $runspace.SessionStateProxy.SetVariable('appName', $appName)
    $runspace.SessionStateProxy.SetVariable('appVersion', $appVersion)
    $runspace.SessionStateProxy.SetVariable('textTable', $textTable)

    $psCmd = [powershell]::Create()
    $psCmd.Runspace = $runspace
    $psCmd.AddScript({
        $successInstall = 0; $failedInstall = 0; $successBloat = 0; $failedBloat = 0; $currentOp = 0
        $results = New-Object System.Collections.Generic.List[object]
        $sessionStart = Get-Date

        function TT([string]$Key) { return $textTable[$Key] }
        function Invoke-UIUpdate { param([scriptblock]$Code) $dispatcher.Invoke([Action]$Code, [System.Windows.Threading.DispatcherPriority]::Background) }
        function Write-LogLine { param([string]$Line) Invoke-UIUpdate { $txtLog.AppendText("$Line`r`n"); $txtLog.ScrollToEnd() }.GetNewClosure() }
        function Update-Progress { param([int]$Step,[string]$Label) $pct = [math]::Round(($Step / $totalOps) * 100); Invoke-UIUpdate { $progressBar.Value = $pct; $lblProgress.Text = "$pct%"; $lblCurrentOp.Text = $Label }.GetNewClosure() }
        function Set-Status { param($Labels,[int]$Idx,[string]$Emoji) Invoke-UIUpdate { $Labels[$Idx].Text = $Emoji }.GetNewClosure() }

        function Invoke-WinGetProcess {
            param([string]$Action,[string]$Id,[bool]$SkipSilent)
            $argsList = if ($Action -eq 'install') {
                "install --id `"$Id`" --exact --accept-package-agreements --accept-source-agreements --disable-interactivity --force"
            } else {
                "uninstall --id `"$Id`" --exact --accept-source-agreements --disable-interactivity --force"
            }
            if (-not $SkipSilent) { $argsList += ' --silent' }
            $procInfo = New-Object System.Diagnostics.ProcessStartInfo
            $procInfo.FileName = 'winget'
            $procInfo.Arguments = $argsList
            $procInfo.RedirectStandardOutput = $true
            $procInfo.RedirectStandardError = $true
            $procInfo.UseShellExecute = $false
            $procInfo.CreateNoWindow = $true
            $proc = [System.Diagnostics.Process]::Start($procInfo)
            $stdout = $proc.StandardOutput.ReadToEnd()
            $stderr = $proc.StandardError.ReadToEnd()
            $proc.WaitForExit()
            return [pscustomobject]@{ ExitCode = $proc.ExitCode; StdOut = $stdout; StdErr = $stderr; Args = $argsList }
        }

        Write-LogLine '========================================='
        Write-LogLine "  $(TT 'InstallPhase')"
        Write-LogLine '========================================='
        foreach ($item in $selectedInstalls) {
            $currentOp++
            $opLabel = "$(TT 'Installing'): $($item.Name)..."
            Update-Progress -Step $currentOp -Label $opLabel
            Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x1F504)
            Write-LogLine "[>] $(TT 'Installing'): $($item.Name) ($($item.Id))"
            $start = Get-Date
            try {
                $run = Invoke-WinGetProcess -Action 'install' -Id $item.Id -SkipSilent ([bool]$item.SkipSilent)
                if ($run.StdOut) { $run.StdOut -split "`r?`n" | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object { Write-LogLine "    $_" } }
                if ($run.ExitCode -eq 0) {
                    $successInstall++; Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x2705); Write-LogLine "[OK] $($item.Name) $(TT 'InstalledOk')."
                    $status = 'Success'; $message = 'OK'
                } else {
                    $failedInstall++; Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C); Write-LogLine "[$(TT 'Error')] $($item.Name) - Exit code: $($run.ExitCode)"; if ($run.StdErr) { Write-LogLine "    STDERR: $($run.StdErr)" }
                    $status = 'Failed'; $message = $run.StdErr
                }
                $results.Add([pscustomobject]@{ Timestamp=(Get-Date).ToString('s'); Action='Install'; Name=$item.Name; Id=$item.Id; Category=$item.Category; Status=$status; ExitCode=$run.ExitCode; DurationSeconds=[math]::Round(((Get-Date)-$start).TotalSeconds,2); Message=$message }) | Out-Null
            } catch {
                $failedInstall++; Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C); Write-LogLine "[$(TT 'Error')] $($item.Name) - $($_.Exception.Message)"
                $results.Add([pscustomobject]@{ Timestamp=(Get-Date).ToString('s'); Action='Install'; Name=$item.Name; Id=$item.Id; Category=$item.Category; Status='Exception'; ExitCode=''; DurationSeconds=[math]::Round(((Get-Date)-$start).TotalSeconds,2); Message=$_.Exception.Message }) | Out-Null
            }
            Write-LogLine ''
        }

        Write-LogLine ''
        Write-LogLine '========================================='
        Write-LogLine "  $(TT 'RemovePhase')"
        Write-LogLine '========================================='
        foreach ($item in $selectedBloat) {
            $currentOp++
            $opLabel = "$(TT 'Removing'): $($item.Name)..."
            Update-Progress -Step $currentOp -Label $opLabel
            Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x1F504)
            Write-LogLine "[>] $(TT 'Removing'): $($item.Name) ($($item.Id))"
            $start = Get-Date
            try {
                $run = Invoke-WinGetProcess -Action 'uninstall' -Id $item.Id -SkipSilent $false
                if ($run.StdOut) { $run.StdOut -split "`r?`n" | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object { Write-LogLine "    $_" } }
                if ($run.ExitCode -eq 0) {
                    $successBloat++; Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x2705); Write-LogLine "[OK] $($item.Name) $(TT 'RemovedOk')."
                    $status = 'Success'; $message = 'OK'
                } else {
                    $failedBloat++; Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C); Write-LogLine "[$(TT 'Error')] $($item.Name) - Exit code: $($run.ExitCode)"; if ($run.StdErr) { Write-LogLine "    STDERR: $($run.StdErr)" }
                    $status = 'Failed'; $message = $run.StdErr
                }
                $results.Add([pscustomobject]@{ Timestamp=(Get-Date).ToString('s'); Action='Uninstall'; Name=$item.Name; Id=$item.Id; Category='Windows App'; Status=$status; ExitCode=$run.ExitCode; DurationSeconds=[math]::Round(((Get-Date)-$start).TotalSeconds,2); Message=$message }) | Out-Null
            } catch {
                $failedBloat++; Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C); Write-LogLine "[$(TT 'Error')] $($item.Name) - $($_.Exception.Message)"
                $results.Add([pscustomobject]@{ Timestamp=(Get-Date).ToString('s'); Action='Uninstall'; Name=$item.Name; Id=$item.Id; Category='Windows App'; Status='Exception'; ExitCode=''; DurationSeconds=[math]::Round(((Get-Date)-$start).TotalSeconds,2); Message=$_.Exception.Message }) | Out-Null
            }
            Write-LogLine ''
        }

        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $csvPath = Join-Path $reportFolder "SetupHub_Report_$timestamp.csv"
        $htmlPath = Join-Path $reportFolder "SetupHub_Report_$timestamp.html"
        $logPath = Join-Path $reportFolder "SetupHub_Log_$timestamp.txt"
        if ($createReport) {
            $results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
            $summary = [pscustomobject]@{
                Tool = "$appName v$appVersion"
                ComputerName = $env:COMPUTERNAME
                User = $env:USERNAME
                OS = (Get-CimInstance Win32_OperatingSystem).Caption
                OSBuild = [System.Environment]::OSVersion.Version.Build
                Profile = $selectedProfile
                StartedAt = $sessionStart.ToString('s')
                CompletedAt = (Get-Date).ToString('s')
                SuccessfulInstalls = $successInstall
                FailedInstalls = $failedInstall
                SuccessfulRemovals = $successBloat
                FailedRemovals = $failedBloat
            }
            $style = '<style>body{font-family:Segoe UI,Arial,sans-serif;background:#11111b;color:#cdd6f4}h1,h2{color:#89b4fa}.card{background:#181825;border-radius:10px;padding:16px;margin:12px 0}table{border-collapse:collapse;width:100%;background:#181825}th,td{border:1px solid #313244;padding:7px;text-align:left;font-size:12px}th{background:#313244}.Success{color:#a6e3a1}.Failed,.Exception{color:#f38ba8}</style>'
            $html = @()
            $html += '<html><head><meta charset="utf-8"><title>SetupHub Report</title>' + $style + '</head><body>'
            $html += '<h1>SetupHub - Deployment Report</h1>'
            $html += '<div class="card"><h2>Summary</h2>'
            $html += ($summary | ConvertTo-Html -Fragment)
            $html += '</div><div class="card"><h2>Operations</h2>'
            $html += ($results | ConvertTo-Html -Fragment)
            $html += '</div></body></html>'
            $html -join "`r`n" | Set-Content -Path $htmlPath -Encoding UTF8
            Invoke-UIUpdate { $txtLog.Text | Set-Content -Path $logPath -Encoding UTF8 }.GetNewClosure()
        }

        Write-LogLine ''
        Write-LogLine '========================================='
        Write-LogLine "  $(TT 'SummaryTitle')"
        Write-LogLine '========================================='
        Write-LogLine "  Software installati: $successInstall OK / $failedInstall ERRORI"
        Write-LogLine "  Bloatware rimossi:   $successBloat OK / $failedBloat ERRORI"
        if ($createReport) { Write-LogLine "  $(TT 'ReportSaved'): $htmlPath" }
        Write-LogLine '========================================='

        Invoke-UIUpdate { $progressBar.Value = 100; $lblProgress.Text = '100%'; $lblCurrentOp.Text = TT 'Completed'; $btnStart.IsEnabled = $false }.GetNewClosure()
        $summaryMsg = "$(TT 'Completed')`n`nSoftware installati: $successInstall (errori: $failedInstall)`nBloatware rimossi: $successBloat (errori: $failedBloat)"
        if ($createReport) { $summaryMsg += "`n`n$(TT 'ReportSaved'):`n$htmlPath" }
        Invoke-UIUpdate { [System.Windows.MessageBox]::Show($window, $summaryMsg, (TT 'SummaryTitle'), [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) }.GetNewClosure()
    }) | Out-Null

    $asyncResult = $psCmd.BeginInvoke()
    $window.Tag = @{ PowerShell=$psCmd; AsyncResult=$asyncResult; Runspace=$runspace }
})

$window.Add_Closed({
    if ($window.Tag) {
        $tag = $window.Tag
        if ($tag.PowerShell) { try { $tag.PowerShell.Stop(); $tag.PowerShell.Dispose() } catch {} }
        if ($tag.Runspace) { try { $tag.Runspace.Close() } catch {} }
    }
})
#endregion

#region === LAUNCH ===
$window.ShowDialog() | Out-Null
#endregion
