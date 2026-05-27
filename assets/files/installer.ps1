<#
.SYNOPSIS
    WinGet Software Installer & Bloatware Remover - GUI Edition
.DESCRIPTION
    WPF-based GUI tool for automated software deployment and Windows debloating.
    Installs curated packages via WinGet and removes pre-installed bloatware.
.AUTHOR
    Pietro Melillo
.NOTES
    Requires Windows 10 build 18363+ and Administrator privileges.
    Launch via default.cmd with -ExecutionPolicy Bypass.
#>

#region === ELEVATION & OS GUARD ===

$ErrorActionPreference = 'Stop'

# UAC elevation check
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $args = "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    Start-Process powershell.exe -Verb RunAs -ArgumentList $args
    exit
}

# OS version guard (minimum build 18363 = Windows 10 1909)
$osBuild = [System.Environment]::OSVersion.Version.Build
if ($osBuild -lt 18363) {
    [System.Windows.MessageBox]::Show(
        "Questo script richiede Windows 10 build 18363 o superiore.`nBuild attuale: $osBuild",
        "Versione OS non supportata",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
    exit 1
}

#endregion

#region === ASSEMBLIES ===

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

#endregion

#region === PACKAGE DEFINITIONS ===

$installPackages = @(
    @{ Name = "7-Zip"; Id = "7zip.7zip"; Checked = $true }
    @{ Name = "Notepad++"; Id = "Notepad++.Notepad++"; Checked = $true }
    @{ Name = "VLC"; Id = "VideoLAN.VLC"; Checked = $true }
    @{ Name = "VMware Workstation Pro"; Id = "VMware.WorkstationPro"; Checked = $true }
    @{ Name = "OBS Studio"; Id = "OBSProject.OBSStudio"; Checked = $true }
    @{ Name = "Notion"; Id = "Notion.Notion"; Checked = $true }
    @{ Name = "NordVPN"; Id = "NordVPN.NordVPN"; Checked = $true }
    @{ Name = "Adobe Acrobat Reader 64-bit"; Id = "Adobe.Acrobat.Reader.64-bit"; Checked = $true }
    @{ Name = "WhatsApp"; Id = "WhatsApp.WhatsApp"; Checked = $true }
    @{ Name = "Telegram"; Id = "Telegram.TelegramDesktop"; Checked = $true }
    @{ Name = ".NET Framework 4 Dev Pack"; Id = "Microsoft.DotNet.Framework.DeveloperPack_4"; Checked = $true }
    @{ Name = "Synology Drive Client"; Id = "Synology.DriveClient"; Checked = $true }
    @{ Name = "Microsoft Teams"; Id = "Microsoft.Teams"; Checked = $false }
    @{ Name = "Google Chrome"; Id = "Google.Chrome"; Checked = $false }
    @{ Name = "Tor Browser"; Id = "TorProject.TorBrowser"; Checked = $false }
    @{ Name = "Recuva"; Id = "Recuva"; Checked = $false }
    @{ Name = "Discord"; Id = "Discord.Discord"; Checked = $false }
    @{ Name = "Sublime Text 4"; Id = "SublimeHQ.SublimeText.4"; Checked = $false }
    @{ Name = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Checked = $false }
    @{ Name = "Screenpresso"; Id = "Learnpulse.Screenpresso"; Checked = $false }
    @{ Name = "AnyDesk"; Id = "AnyDeskSoftwareGmbH.AnyDesk"; Checked = $false }
    @{ Name = "Burp Suite Community"; Id = "PortSwigger.BurpSuite.Community"; Checked = $false }
    @{ Name = "PDF24 Creator"; Id = "geeksoftwareGmbH.PDF24Creator"; Checked = $false }
    @{ Name = "Intel Driver Assistant"; Id = "Intel.IntelDriverAndSupportAssistant"; Checked = $false }
    @{ Name = "GeForce Experience"; Id = "Nvidia.GeForceExperience"; Checked = $false }
    @{ Name = "Apache OpenOffice"; Id = "Apache.OpenOffice"; Checked = $false }
    @{ Name = "HWMonitor"; Id = "CPUID.HWMonitor"; Checked = $false }
    @{ Name = "Python 3.11"; Id = "Python.Python.3.11"; Checked = $false }
    @{ Name = "PyCharm Professional"; Id = "JetBrains.PyCharm.Professional"; Checked = $false }
    @{ Name = "Visual Studio 2022 Community"; Id = "Microsoft.VisualStudio.2022.Community.Preview"; Checked = $false }
    @{ Name = "VirusTotal Uploader"; Id = "VirusTotal.VirusTotalUploader"; Checked = $false }
)

$bloatwarePackages = @(
    @{ Name = "Xbox Gaming App"; Id = "Microsoft.GamingApp_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Xbox App"; Id = "Microsoft.XboxApp_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Xbox TCUI"; Id = "Microsoft.Xbox.TCUI_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Xbox Speech Overlay"; Id = "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Xbox Identity Provider"; Id = "Microsoft.XboxIdentityProvider_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Xbox Gaming Overlay"; Id = "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Xbox Game Overlay"; Id = "Microsoft.XboxGameOverlay_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Groove Music"; Id = "Microsoft.ZuneMusic_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Feedback Hub"; Id = "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Microsoft Tips"; Id = "Microsoft.Getstarted_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "3D Viewer"; Id = "9NBLGGH42THS"; Checked = $true }
    @{ Name = "Microsoft Solitaire"; Id = "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Paint 3D"; Id = "9NBLGGH5FV99"; Checked = $true }
    @{ Name = "Weather"; Id = "Microsoft.BingWeather_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Mail & Calendar"; Id = "microsoft.windowscommunicationsapps_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Your Phone"; Id = "Microsoft.YourPhone_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "People"; Id = "Microsoft.People_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Microsoft Pay"; Id = "Microsoft.Wallet_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Microsoft Maps"; Id = "Microsoft.WindowsMaps_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "OneNote"; Id = "Microsoft.Office.OneNote_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Voice Recorder"; Id = "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Mixed Reality Portal"; Id = "Microsoft.MixedReality.Portal_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Sticky Notes"; Id = "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Get Help"; Id = "Microsoft.GetHelp_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Cortana"; Id = "cortana"; Checked = $true }
    @{ Name = "Skype"; Id = "skype"; Checked = $true }
    @{ Name = "Microsoft To Do"; Id = "Microsoft.Todos_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Power Automate"; Id = "Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Bing News"; Id = "Microsoft.BingNews_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Microsoft Teams"; Id = "MicrosoftTeams_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Microsoft Family"; Id = "MicrosoftCorporationII.MicrosoftFamily_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Quick Assist"; Id = "MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe"; Checked = $true }
    @{ Name = "Disney+"; Id = "disney+"; Checked = $true }
    @{ Name = "Clipchamp"; Id = "Clipchamp.Clipchamp_yxz26nhyzhsrt"; Checked = $true }
    @{ Name = "Movies & TV"; Id = "Microsoft.ZuneVideo_8wekyb3d8bbwe"; Checked = $false }
    @{ Name = "Office Hub"; Id = "Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe"; Checked = $false }
    @{ Name = "OneDrive"; Id = "Microsoft.OneDrive"; Checked = $false }
    @{ Name = "Calculator (reinstall)"; Id = "Microsoft.WindowsCalculator_8wekyb3d8bbwe"; Checked = $false }
)

#endregion

#region === WINGET BOOTSTRAP ===

function Test-WinGetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        $version = (winget --version 2>$null)
        return ($null -ne $version)
    } catch {
        return $false
    }
}

function Install-WinGetBootstrap {
    $splashXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Preparazione ambiente..." Height="200" Width="450"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        WindowStyle="ToolWindow" Background="#1e1e2e">
    <StackPanel VerticalAlignment="Center" Margin="30">
        <TextBlock Text="&#x23F3; Installazione WinGet in corso..."
                   Foreground="#cdd6f4" FontSize="16" FontWeight="SemiBold"
                   HorizontalAlignment="Center" Margin="0,0,0,15"/>
        <ProgressBar IsIndeterminate="True" Height="6" Foreground="#89b4fa"
                     Background="#313244" BorderThickness="0"/>
        <TextBlock Text="Download dei componenti necessari (VCLibs, WinGet)..."
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
        # Install VCLibs dependency
        $vcLibsPath = "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        $vcLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
        
        $progressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $vcLibsUrl -OutFile $vcLibsPath -UseBasicParsing
        Add-AppxPackage -Path $vcLibsPath -ErrorAction SilentlyContinue

        # Install Microsoft.UI.Xaml dependency
        $uiXamlUrl = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6"
        $uiXamlPath = "$env:TEMP\microsoft.ui.xaml.2.8.6.nupkg.zip"
        Invoke-WebRequest -Uri $uiXamlUrl -OutFile $uiXamlPath -UseBasicParsing
        $uiXamlExtract = "$env:TEMP\microsoft.ui.xaml"
        Expand-Archive -Path $uiXamlPath -DestinationPath $uiXamlExtract -Force
        $uiXamlAppx = Get-ChildItem -Path "$uiXamlExtract\tools\AppX\x64\Release\" -Filter "*.appx" | Select-Object -First 1
        if ($uiXamlAppx) {
            Add-AppxPackage -Path $uiXamlAppx.FullName -ErrorAction SilentlyContinue
        }

        # Install WinGet from GitHub latest release
        $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest" -UseBasicParsing
        $msixBundleAsset = $latestRelease.assets | Where-Object { $_.name -match "\.msixbundle$" } | Select-Object -First 1
        $licenseAsset = $latestRelease.assets | Where-Object { $_.name -match "License.*\.xml$" } | Select-Object -First 1

        $msixPath = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
        Invoke-WebRequest -Uri $msixBundleAsset.browser_download_url -OutFile $msixPath -UseBasicParsing

        if ($licenseAsset) {
            $licensePath = "$env:TEMP\WinGet_License.xml"
            Invoke-WebRequest -Uri $licenseAsset.browser_download_url -OutFile $licensePath -UseBasicParsing
            Add-AppxProvisionedPackage -Online -PackagePath $msixPath -LicensePath $licensePath -ErrorAction SilentlyContinue
        }
        Add-AppxPackage -Path $msixPath -ForceApplicationShutdown

        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        
        $wingetPaths = @(
            "$env:LOCALAPPDATA\Microsoft\WindowsApps"
            "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
        )
        foreach ($wp in $wingetPaths) {
            $resolved = Resolve-Path $wp -ErrorAction SilentlyContinue
            if ($resolved) { $env:PATH += ";$($resolved.Path)" }
        }

    } catch {
        $splashWindow.Close()
        [System.Windows.MessageBox]::Show(
            "Errore durante l'installazione di WinGet:`n$($_.Exception.Message)`n`nInstallare manualmente da: https://github.com/microsoft/winget-cli/releases",
            "Errore Bootstrap",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        ) | Out-Null
        exit 1
    }

    $splashWindow.Close()

    Start-Sleep -Seconds 2
    if (-not (Test-WinGetAvailable)) {
        [System.Windows.MessageBox]::Show(
            "WinGet non risulta disponibile dopo l'installazione.`nRiavviare il PC e riprovare.",
            "WinGet non trovato",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        ) | Out-Null
        exit 1
    }
}

# Execute bootstrap if needed
if (-not (Test-WinGetAvailable)) {
    Install-WinGetBootstrap
}

#endregion

#region === MAIN GUI ===

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinGet Installer &amp; Debloater — Script by Pietro Melillo"
        Height="820" Width="1100" MinHeight="700" MinWidth="900"
        WindowStartupLocation="CenterScreen" Background="#1e1e2e">
    <Window.Resources>
        <Style x:Key="PanelHeader" TargetType="TextBlock">
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Foreground" Value="#cdd6f4"/>
            <Setter Property="Margin" Value="0,0,0,8"/>
        </Style>
        <Style x:Key="ActionButton" TargetType="Button">
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="14,7"/>
            <Setter Property="Margin" Value="4,0"/>
            <Setter Property="Background" Value="#313244"/>
            <Setter Property="Foreground" Value="#cdd6f4"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#45475a"/>
                </Trigger>
                <Trigger Property="IsEnabled" Value="False">
                    <Setter Property="Opacity" Value="0.5"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="200"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Top: Two-panel layout -->
        <Grid Grid.Row="0" Margin="12,12,12,6">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- Left Panel: Install -->
            <Border Grid.Column="0" Background="#181825" CornerRadius="8" Padding="12">
                <DockPanel>
                    <StackPanel DockPanel.Dock="Top">
                        <TextBlock Style="{StaticResource PanelHeader}"
                                   Text="&#x1F4E6; Software da Installare"/>
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
                            <Button x:Name="btnSelectAllInstall" Content="&#x2714; Seleziona Tutto"
                                    Style="{StaticResource ActionButton}" FontSize="11"/>
                            <Button x:Name="btnDeselectAllInstall" Content="&#x2718; Deseleziona Tutto"
                                    Style="{StaticResource ActionButton}" FontSize="11"/>
                        </StackPanel>
                    </StackPanel>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="panelInstall"/>
                    </ScrollViewer>
                </DockPanel>
            </Border>

            <!-- Right Panel: Bloatware -->
            <Border Grid.Column="2" Background="#181825" CornerRadius="8" Padding="12">
                <DockPanel>
                    <StackPanel DockPanel.Dock="Top">
                        <TextBlock Style="{StaticResource PanelHeader}"
                                   Text="&#x1F5D1; Bloatware da Rimuovere"/>
                        <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
                            <Button x:Name="btnSelectAllBloat" Content="&#x2714; Seleziona Tutto"
                                    Style="{StaticResource ActionButton}" FontSize="11"/>
                            <Button x:Name="btnDeselectAllBloat" Content="&#x2718; Deseleziona Tutto"
                                    Style="{StaticResource ActionButton}" FontSize="11"/>
                        </StackPanel>
                    </StackPanel>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="panelBloatware"/>
                    </ScrollViewer>
                </DockPanel>
            </Border>
        </Grid>

        <!-- Action Buttons Row -->
        <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,6,0,6">
            <Button x:Name="btnStart" Style="{StaticResource ActionButton}"
                    Background="#a6e3a1" Foreground="#1e1e2e" FontSize="13"
                    Content="&#x25B6; Avvia Installazione" Padding="20,9"/>
            <Button x:Name="btnCancel" Style="{StaticResource ActionButton}"
                    Background="#f38ba8" Foreground="#1e1e2e" FontSize="13"
                    Content="&#x2716; Annulla" Padding="20,9"/>
        </StackPanel>

        <!-- Progress Section -->
        <Border Grid.Row="2" Background="#11111b" Margin="12,0,12,6" CornerRadius="8" Padding="10">
            <DockPanel>
                <StackPanel DockPanel.Dock="Top" Margin="0,0,0,6">
                    <TextBlock x:Name="lblCurrentOp" Text="In attesa di avvio..."
                               Foreground="#a6adc8" FontSize="12" Margin="0,0,0,4"/>
                    <ProgressBar x:Name="progressBar" Height="8" Minimum="0" Maximum="100" Value="0"
                                 Foreground="#89b4fa" Background="#313244" BorderThickness="0"/>
                    <TextBlock x:Name="lblProgress" Text="0%" Foreground="#6c7086"
                               FontSize="10" HorizontalAlignment="Right" Margin="0,2,0,0"/>
                </StackPanel>
                <TextBox x:Name="txtLog" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                         Background="#11111b" Foreground="#a6e3a1" BorderThickness="0"
                         FontFamily="Consolas" FontSize="11" TextWrapping="Wrap"
                         AcceptsReturn="True"/>
            </DockPanel>
        </Border>

        <!-- Footer -->
        <Border Grid.Row="3" Background="#181825" Padding="10,6">
            <TextBlock Text="Script by Pietro Melillo | WinGet Installer &amp; Debloater v2.0"
                       Foreground="#6c7086" FontSize="10" HorizontalAlignment="Center"/>
        </Border>
    </Grid>
</Window>
"@

# Parse XAML
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Get named elements
$panelInstall = $window.FindName("panelInstall")
$panelBloatware = $window.FindName("panelBloatware")
$btnSelectAllInstall = $window.FindName("btnSelectAllInstall")
$btnDeselectAllInstall = $window.FindName("btnDeselectAllInstall")
$btnSelectAllBloat = $window.FindName("btnSelectAllBloat")
$btnDeselectAllBloat = $window.FindName("btnDeselectAllBloat")
$btnStart = $window.FindName("btnStart")
$btnCancel = $window.FindName("btnCancel")
$progressBar = $window.FindName("progressBar")
$lblProgress = $window.FindName("lblProgress")
$lblCurrentOp = $window.FindName("lblCurrentOp")
$txtLog = $window.FindName("txtLog")

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
        [bool]$IsChecked,
        [System.Windows.Controls.Panel]$Panel,
        [ref]$CheckboxList,
        [ref]$StatusList
    )

    $border = New-Object System.Windows.Controls.Border
    $border.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)
    $border.Padding = [System.Windows.Thickness]::new(8, 5, 8, 5)
    $border.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1e1e2e")
    $border.CornerRadius = [System.Windows.CornerRadius]::new(4)

    $grid = New-Object System.Windows.Controls.Grid
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = [System.Windows.GridLength]::new(30)
    $grid.ColumnDefinitions.Add($col1)
    $grid.ColumnDefinitions.Add($col2)

    $checkPanel = New-Object System.Windows.Controls.StackPanel
    $checkPanel.Orientation = "Horizontal"
    [System.Windows.Controls.Grid]::SetColumn($checkPanel, 0)

    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.IsChecked = $IsChecked
    $checkbox.VerticalAlignment = "Center"
    $checkbox.Margin = [System.Windows.Thickness]::new(0, 0, 8, 0)
    $checkbox.Tag = $Id

    $textPanel = New-Object System.Windows.Controls.StackPanel
    $textPanel.VerticalAlignment = "Center"

    $nameBlock = New-Object System.Windows.Controls.TextBlock
    $nameBlock.Text = $Name
    $nameBlock.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#cdd6f4")
    $nameBlock.FontSize = 12
    $nameBlock.FontWeight = "Medium"

    $idBlock = New-Object System.Windows.Controls.TextBlock
    $idBlock.Text = $Id
    $idBlock.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#6c7086")
    $idBlock.FontSize = 9.5

    $textPanel.Children.Add($nameBlock) | Out-Null
    $textPanel.Children.Add($idBlock) | Out-Null

    $checkPanel.Children.Add($checkbox) | Out-Null
    $checkPanel.Children.Add($textPanel) | Out-Null

    $statusLabel = New-Object System.Windows.Controls.TextBlock
    $statusLabel.Text = ""
    $statusLabel.FontSize = 14
    $statusLabel.VerticalAlignment = "Center"
    $statusLabel.HorizontalAlignment = "Center"
    [System.Windows.Controls.Grid]::SetColumn($statusLabel, 1)

    $grid.Children.Add($checkPanel) | Out-Null
    $grid.Children.Add($statusLabel) | Out-Null

    $border.Child = $grid
    $Panel.Children.Add($border) | Out-Null

    $CheckboxList.Value += $checkbox
    $StatusList.Value += $statusLabel
}

# Populate install panel
foreach ($pkg in $installPackages) {
    New-PackageItem -Name $pkg.Name -Id $pkg.Id -IsChecked $pkg.Checked `
        -Panel $panelInstall -CheckboxList ([ref]$script:installCheckboxes) -StatusList ([ref]$script:installStatusLabels)
}

# Populate bloatware panel
foreach ($pkg in $bloatwarePackages) {
    New-PackageItem -Name $pkg.Name -Id $pkg.Id -IsChecked $pkg.Checked `
        -Panel $panelBloatware -CheckboxList ([ref]$script:bloatCheckboxes) -StatusList ([ref]$script:bloatStatusLabels)
}

#endregion

#region === BUTTON HANDLERS ===

# Select/Deselect All - Install
$btnSelectAllInstall.Add_Click({
    foreach ($cb in $script:installCheckboxes) { $cb.IsChecked = $true }
})
$btnDeselectAllInstall.Add_Click({
    foreach ($cb in $script:installCheckboxes) { $cb.IsChecked = $false }
})

# Select/Deselect All - Bloatware
$btnSelectAllBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $true }
})
$btnDeselectAllBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $false }
})

# Cancel
$btnCancel.Add_Click({
    $window.Close()
})

# Start Installation
$btnStart.Add_Click({
    # Collect selected items
    $selectedInstalls = @()
    for ($i = 0; $i -lt $script:installCheckboxes.Count; $i++) {
        if ($script:installCheckboxes[$i].IsChecked) {
            $selectedInstalls += @{
                Index = $i
                Id = $script:installCheckboxes[$i].Tag
                Name = $installPackages[$i].Name
            }
        }
    }

    $selectedBloat = @()
    for ($i = 0; $i -lt $script:bloatCheckboxes.Count; $i++) {
        if ($script:bloatCheckboxes[$i].IsChecked) {
            $selectedBloat += @{
                Index = $i
                Id = $script:bloatCheckboxes[$i].Tag
                Name = $bloatwarePackages[$i].Name
            }
        }
    }

    $totalOps = $selectedInstalls.Count + $selectedBloat.Count
    if ($totalOps -eq 0) {
        [System.Windows.MessageBox]::Show(
            "Nessun pacchetto selezionato.",
            "Attenzione",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        ) | Out-Null
        return
    }

    # Disable controls during execution
    $btnStart.IsEnabled = $false
    $btnCancel.Content = "Chiudi"
    $btnSelectAllInstall.IsEnabled = $false
    $btnDeselectAllInstall.IsEnabled = $false
    $btnSelectAllBloat.IsEnabled = $false
    $btnDeselectAllBloat.IsEnabled = $false
    foreach ($cb in $script:installCheckboxes) { $cb.IsEnabled = $false }
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsEnabled = $false }

    # Mark all selected as pending
    foreach ($item in $selectedInstalls) {
        $script:installStatusLabels[$item.Index].Text = [char]0x23F3
    }
    foreach ($item in $selectedBloat) {
        $script:bloatStatusLabels[$item.Index].Text = [char]0x23F3
    }

    $dispatcher = $window.Dispatcher

    # Execute in a background runspace to keep GUI responsive
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()

    $runspace.SessionStateProxy.SetVariable("selectedInstalls", $selectedInstalls)
    $runspace.SessionStateProxy.SetVariable("selectedBloat", $selectedBloat)
    $runspace.SessionStateProxy.SetVariable("totalOps", $totalOps)
    $runspace.SessionStateProxy.SetVariable("dispatcher", $dispatcher)
    $runspace.SessionStateProxy.SetVariable("progressBar", $progressBar)
    $runspace.SessionStateProxy.SetVariable("lblProgress", $lblProgress)
    $runspace.SessionStateProxy.SetVariable("lblCurrentOp", $lblCurrentOp)
    $runspace.SessionStateProxy.SetVariable("txtLog", $txtLog)
    $runspace.SessionStateProxy.SetVariable("installStatusLabels", $script:installStatusLabels)
    $runspace.SessionStateProxy.SetVariable("bloatStatusLabels", $script:bloatStatusLabels)
    $runspace.SessionStateProxy.SetVariable("btnStart", $btnStart)
    $runspace.SessionStateProxy.SetVariable("btnCancel", $btnCancel)
    $runspace.SessionStateProxy.SetVariable("window", $window)

    $psCmd = [powershell]::Create()
    $psCmd.Runspace = $runspace
    $psCmd.AddScript({
        $successInstall = 0
        $failedInstall = 0
        $successBloat = 0
        $failedBloat = 0
        $currentOp = 0

        function Invoke-UIUpdate {
            param([scriptblock]$Code)
            $dispatcher.Invoke([Action]$Code, [System.Windows.Threading.DispatcherPriority]::Background)
        }

        function Write-LogLine {
            param([string]$Line)
            Invoke-UIUpdate {
                $txtLog.AppendText("$Line`r`n")
                $txtLog.ScrollToEnd()
            }.GetNewClosure()
        }

        function Update-Progress {
            param([int]$Step, [string]$Label)
            $pct = [math]::Round(($Step / $totalOps) * 100)
            Invoke-UIUpdate {
                $progressBar.Value = $pct
                $lblProgress.Text = "$pct%"
                $lblCurrentOp.Text = $Label
            }.GetNewClosure()
        }

        function Set-Status {
            param($Labels, [int]$Idx, [string]$Emoji)
            Invoke-UIUpdate {
                $Labels[$Idx].Text = $Emoji
            }.GetNewClosure()
        }

        # === INSTALL PHASE ===
        Write-LogLine "========================================="
        Write-LogLine "  FASE 1: Installazione Software"
        Write-LogLine "========================================="
        Write-LogLine ""

        foreach ($item in $selectedInstalls) {
            $currentOp++
            $opLabel = "Installando: $($item.Name)..."
            Update-Progress -Step $currentOp -Label $opLabel
            Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x1F504)
            Write-LogLine "[>] Installazione: $($item.Name) ($($item.Id))"

            try {
                $procInfo = New-Object System.Diagnostics.ProcessStartInfo
                $procInfo.FileName = "winget"
                $procInfo.Arguments = "install --id `"$($item.Id)`" --silent --accept-package-agreements --accept-source-agreements --force"
                $procInfo.RedirectStandardOutput = $true
                $procInfo.RedirectStandardError = $true
                $procInfo.UseShellExecute = $false
                $procInfo.CreateNoWindow = $true

                $proc = [System.Diagnostics.Process]::Start($procInfo)

                while (-not $proc.StandardOutput.EndOfStream) {
                    $line = $proc.StandardOutput.ReadLine()
                    if ($line -and $line.Trim().Length -gt 0) {
                        Write-LogLine "    $line"
                    }
                }

                $stderrContent = $proc.StandardError.ReadToEnd()
                $proc.WaitForExit()

                if ($proc.ExitCode -eq 0) {
                    $successInstall++
                    Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x2705)
                    Write-LogLine "[OK] $($item.Name) installato con successo."
                } else {
                    $failedInstall++
                    Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C)
                    Write-LogLine "[ERRORE] $($item.Name) - Exit code: $($proc.ExitCode)"
                    if ($stderrContent) { Write-LogLine "    STDERR: $stderrContent" }
                }
            } catch {
                $failedInstall++
                Set-Status -Labels $installStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C)
                Write-LogLine "[ERRORE] $($item.Name) - Eccezione: $($_.Exception.Message)"
            }
            Write-LogLine ""
        }

        # === UNINSTALL PHASE ===
        Write-LogLine ""
        Write-LogLine "========================================="
        Write-LogLine "  FASE 2: Rimozione Bloatware"
        Write-LogLine "========================================="
        Write-LogLine ""

        foreach ($item in $selectedBloat) {
            $currentOp++
            $opLabel = "Rimuovendo: $($item.Name)..."
            Update-Progress -Step $currentOp -Label $opLabel
            Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x1F504)
            Write-LogLine "[>] Rimozione: $($item.Name) ($($item.Id))"

            try {
                $procInfo = New-Object System.Diagnostics.ProcessStartInfo
                $procInfo.FileName = "winget"
                $procInfo.Arguments = "uninstall --id `"$($item.Id)`" --silent --accept-source-agreements --force"
                $procInfo.RedirectStandardOutput = $true
                $procInfo.RedirectStandardError = $true
                $procInfo.UseShellExecute = $false
                $procInfo.CreateNoWindow = $true

                $proc = [System.Diagnostics.Process]::Start($procInfo)

                while (-not $proc.StandardOutput.EndOfStream) {
                    $line = $proc.StandardOutput.ReadLine()
                    if ($line -and $line.Trim().Length -gt 0) {
                        Write-LogLine "    $line"
                    }
                }

                $stderrContent = $proc.StandardError.ReadToEnd()
                $proc.WaitForExit()

                if ($proc.ExitCode -eq 0) {
                    $successBloat++
                    Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x2705)
                    Write-LogLine "[OK] $($item.Name) rimosso con successo."
                } else {
                    $failedBloat++
                    Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C)
                    Write-LogLine "[ERRORE] $($item.Name) - Exit code: $($proc.ExitCode)"
                    if ($stderrContent) { Write-LogLine "    STDERR: $stderrContent" }
                }
            } catch {
                $failedBloat++
                Set-Status -Labels $bloatStatusLabels -Idx $item.Index -Emoji ([string][char]0x274C)
                Write-LogLine "[ERRORE] $($item.Name) - Eccezione: $($_.Exception.Message)"
            }
            Write-LogLine ""
        }

        # === SUMMARY ===
        Write-LogLine ""
        Write-LogLine "========================================="
        Write-LogLine "  RIEPILOGO OPERAZIONI"
        Write-LogLine "========================================="
        Write-LogLine "  Software installati:    $successInstall OK / $failedInstall ERRORI"
        Write-LogLine "  Bloatware rimossi:      $successBloat OK / $failedBloat ERRORI"
        Write-LogLine "========================================="
        Write-LogLine ""

        Invoke-UIUpdate {
            $progressBar.Value = 100
            $lblProgress.Text = "100%"
            $lblCurrentOp.Text = "Completato!"
            $btnStart.IsEnabled = $false
        }

        $summaryMsg = "Operazioni completate!`n`n" +
                      "Software installati: $successInstall (errori: $failedInstall)`n" +
                      "Bloatware rimossi: $successBloat (errori: $failedBloat)"

        Invoke-UIUpdate {
            [System.Windows.MessageBox]::Show(
                $window,
                $summaryMsg,
                "Riepilogo - Script by Pietro Melillo",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Information
            )
        }.GetNewClosure()

    }) | Out-Null

    $asyncResult = $psCmd.BeginInvoke()

    # Store references for cleanup on window close
    $window.Tag = @{ PowerShell = $psCmd; AsyncResult = $asyncResult; Runspace = $runspace }
})

# Cleanup on window close
$window.Add_Closed({
    if ($window.Tag) {
        $tag = $window.Tag
        if ($tag.PowerShell) {
            try {
                $tag.PowerShell.Stop()
                $tag.PowerShell.Dispose()
            } catch {}
        }
        if ($tag.Runspace) {
            try { $tag.Runspace.Close() } catch {}
        }
    }
})

#endregion

#region === LAUNCH ===

$window.ShowDialog() | Out-Null

#endregion
