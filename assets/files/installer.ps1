# Script realizzato da Pietro Melillo
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
	Exit
}
if([System.Environment]::OSVersion.Version.Build -lt 18363) {"ATTENZIONE: Per usare lo script e' necessario aggiornare almeno a Windows 10 versione 1909 ..."; Start-Sleep -s 5; Exit}

Write-Output "**************************************"
Write-Output "Installazione programmi automatizzata"
Write-Output "**************************************"

$wc = New-Object System.Net.WebClient

$output=".\DesktopAppInstaller.appxbundle"
$output2=".\VCLibs.appx"
$json=Invoke-WebRequest 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' -UseBasicParsing
$psobj = ConvertFrom-Json $json
$version=$psobj.tag_name

Write-Host "Download WinGet in corso..." -ForegroundColor white -BackgroundColor green
$wc.DownloadFile("https://github.com/microsoft/winget-cli/releases/download/$version/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle",$output)
Write-Host "Download VCLibs in corso..." -ForegroundColor white -BackgroundColor green
if([Environment]::Is64BitOperatingSystem) {$wc.DownloadFile("https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx",$output2)}
else{$wc.DownloadFile("https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx",$output2)}
Clear

Add-AppxPackage -Path $output2 -ErrorAction SilentlyContinue
Add-AppxPackage -Path $output
Clear

# winget install Microsoft.Teams

#browser
#winget install Google.Chrome --accept-package-agreements --accept-source-agreements
#winget install -e --id TorProject.TorBrowser

#utility
#winget install Recuva
winget install 7zip.7zip
#winget install Discord.Discord
winget install Notepad++.Notepad++
#winget install -e --id SublimeHQ.SublimeText.4
winget install -e --id VideoLAN.VLC
#winget install -e --id TeamViewer.TeamViewer
winget install -e --id VMware.WorkstationPro
winget install -e --id OBSProject.OBSStudio
#winget install -e --id Learnpulse.Screenpresso
winget install -e --id Notion.Notion
#winget install -e --id AnyDeskSoftwareGmbH.AnyDesk
winget install -e --id NordVPN.NordVPN
#winget install -e --id PortSwigger.BurpSuite.Community
#winget install -e --id VMware.WorkstationPro
#Reader
winget install -e --id Adobe.Acrobat.Reader.64-bit
#winget install -e --id geeksoftwareGmbH.PDF24Creator

#Social
winget install -e --id WhatsApp.WhatsApp
winget install -e --id Telegram.TelegramDesktop
#Drivers
#winget install -e --id Intel.IntelDriverAndSupportAssistant
#Windows
winget install -e --id Microsoft.DotNet.Framework.DeveloperPack_4
#ALL
#winget install -e --id Nvidia.GeForceExperience
#winget install -e --id Apache.OpenOffice
#winget install -e --id CPUID.HWMonitor

#Dev
#winget install -e --id Python.Python.3.11
#winget install -e --id JetBrains.PyCharm.Professional
#winget install -e --id Microsoft.VisualStudio.2022.Community.Preview

# Security
#winget install -e --id VirusTotal.VirusTotalUploader

# Cloud
winget install -e --id Synology.DriveClient

# Utilizzare eventualmente la forma seguente:
# winget install --id Recuva --interactive --scope machine
# In questo modo non si accetteranno mai le impostazioni predefinite per l'installazione del software indicato
# e l'applicazione sarà installata per tutti gli account utente configurati sulla macchina Windows.

###############bloatware

Write-Output "**************************************"
Write-Output "BLOATWARE"
Write-Output "**************************************"

#Xbox
winget uninstall Microsoft.GamingApp_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxApp_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.Xbox.TCUI_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxIdentityProvider_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxGamingOverlay_8wekyb3d8bbwe --accept-source-agreements --silent
winget uninstall Microsoft.XboxGameOverlay_8wekyb3d8bbwe --accept-source-agreements --silent

#Groove Music
winget uninstall Microsoft.ZuneMusic_8wekyb3d8bbwe --accept-source-agreements --silent

#Feedback Hub
winget uninstall Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe --accept-source-agreements --silent

#Microsoft-Tips...
winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe --accept-source-agreements --silent

#3D Viewer
winget uninstall 9NBLGGH42THS --accept-source-agreements --silent

#MS Solitaire
winget uninstall Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --accept-source-agreements --silent

#Paint-3D...
winget uninstall 9NBLGGH5FV99 --accept-source-agreements --silent

#Weather 
winget uninstall Microsoft.BingWeather_8wekyb3d8bbwe --accept-source-agreements --silent

#Mail / Calendar
winget uninstall microsoft.windowscommunicationsapps_8wekyb3d8bbwe --accept-source-agreements --silent

#Your Phone
winget uninstall Microsoft.YourPhone_8wekyb3d8bbwe --accept-source-agreements --silent

#People
winget uninstall Microsoft.People_8wekyb3d8bbwe --accept-source-agreements --silent

#MS Pay 
winget uninstall Microsoft.Wallet_8wekyb3d8bbwe --accept-source-agreements --silent

#MS Maps
winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe --accept-source-agreements --silent

#OneNote
winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe --accept-source-agreements --silent

#MS Office [No Active]
#winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe --accept-source-agreements --silent

#Voice Recorder
winget uninstall Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe --accept-source-agreements --silent

#Movies & TV
#winget uninstall Microsoft.ZuneVideo_8wekyb3d8bbwe --accept-source-agreements --silent

#Mixed Reality-Portal
winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe --accept-source-agreements --silent

#Sticky Notes...
winget uninstall Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe --accept-source-agreements --silent

#Get Help
winget uninstall Microsoft.GetHelp_8wekyb3d8bbwe --accept-source-agreements --silent

#OneDrive [No Active]
#winget uninstall Microsoft.OneDrive --accept-source-agreements --silent

#Calculator (reinstall with winget install calculator) [No Active]
#winget uninstall Microsoft.WindowsCalculator_8wekyb3d8bbwe --accept-source-agreements --silent

#Cortana
winget uninstall cortana
#Skype
winget uninstall skype

#Microsoft TO Do
winget uninstall Microsoft.Todos_8wekyb3d8bbwe --accept-source-agreements --silent
#Power Automate
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent
#Bing News
winget uninstall Microsoft.BingNews_8wekyb3d8bbwe --accept-source-agreements --silent
#Microsoft Teams
winget uninstall MicrosoftTeams_8wekyb3d8bbwe --accept-source-agreements --silent
#Microsoft Family
winget uninstall MicrosoftCorporationII.MicrosoftFamily_8wekyb3d8bbwe --accept-source-agreements --silent
#Quick Assist
winget uninstall MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe --accept-source-agreements --silent
#Third-Party Preinstalled bloat
winget uninstall disney+ --accept-source-agreements --silent
winget uninstall Clipchamp.Clipchamp_yxz26nhyzhsrt --accept-source-agreements --silent
#