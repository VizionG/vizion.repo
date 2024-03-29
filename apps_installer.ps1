#Install WinGet
    #Based on this gist: https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
    $hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
    if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
        "Installing winget Dependencies"
        Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
    
        $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
    
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $releases = Invoke-RestMethod -uri $releases_url
        $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1
    
        "Installing winget from $($latestRelease.browser_download_url)"
        Add-AppxPackage -Path $latestRelease.browser_download_url
    }
    else {
        "winget already installed"
    }

      #Configure WinGet
      Write-Output "Configuring winget"
    
      #winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
      $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
      $settingsJson = 
      @"
          {
              // For documentation on these settings, see: https://aka.ms/winget-settings
              "experimentalFeatures": {
                "experimentalMSStore": true,
              }
          }
"@;
$settingsJson | Out-File $settingsPath -Encoding utf8

#Install New apps
    $apps = @(
        @{name = "VideoLAN.VLC"; source = "winget"},
        @{name = "Valve.Steam"; source = "winget"},
        @{name = "Discord.Discord"; source = "winget"},
        @{name = "Discord.Discord"; source = "winget"},
        @{name = "LibreWorf.LibreWolf"; source = "winget"},
        @{name = "HeroicGamesLauncher.HeroicGamesLauncher"; source = "winget"},
        @{name = "Monzilla.Firefox"; source = "winget"},
        @{name = "KRTirtho.Spotube"; source = "winget"},
        @{name = "Google.Chrome"; source = "winget"},
        @{name = "Notepad++.Notepad++"; source = "winget"},
        @{name = "Microsoft.PowerToys"; source = "winget"},
        @{name = "Microsoft.VisualStudioCode"; source = "winget"},
        @{name = "Ablaze.Floorp"; source = "winget"}
    );
    Foreach ($app in $apps) {
        #check if the app is already installed
        $listApp = winget list --exact -q $app.name
        if (![String]::Join("", $listApp).Contains($app.name)) {
            Write-host "Installing:" $app.name
            if ($null -ne $app.source) {
                winget install --exact --silent $app.name --source $app.source --accept-package-agreements
            }
            else {
                winget install --exact --silent $app.name --accept-package-agreements 
            }
        }
        else {
            Write-host "Skipping Install of " $app.name
        }
    }