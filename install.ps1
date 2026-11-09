# ember installer (Windows, PowerShell 7)
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$cd   = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Force $cd | Out-Null

# 1. copy files
Copy-Item "$repo\scripts\*.ps1" $cd -Force
Copy-Item "$repo\assets\claude-mascot-pad.png" $cd -Force
if (-not (Test-Path "$cd\CLAUDE.md")) { Copy-Item "$repo\CLAUDE.md" $cd }
Write-Host "✓ files copied to $cd"

# 2. Claude Code settings: status line + timer hooks
$sf = "$cd\settings.json"
$s  = if (Test-Path $sf) { Get-Content $sf -Raw | ConvertFrom-Json -AsHashtable } else { @{} }
$ps = "pwsh -NoProfile -File"
$s.statusLine = @{ type = "command"; command = "$ps `"$cd\statusline.ps1`"" }
$s.hooks = @{
  UserPromptSubmit = @(@{ hooks = @(@{ type = "command"; command = "$ps `"$cd\rifi-timer.ps1`" start" }) })
  Stop             = @(@{ hooks = @(@{ type = "command"; command = "$ps `"$cd\rifi-timer.ps1`" stop" }) })
}
$s | ConvertTo-Json -Depth 10 | Set-Content $sf -Encoding UTF8
Write-Host "✓ Claude Code settings updated"

# 3. Windows Terminal: Claude Dark scheme + Claude Code profile
$wt = @(
  "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
  "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
  "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($wt) {
  Copy-Item $wt "$wt.bak" -Force
  $j = Get-Content $wt -Raw | ConvertFrom-Json -AsHashtable
  $j.schemes = @($j.schemes | Where-Object { $_.name -ne 'Claude Dark' })
  $j.schemes += @{
    name='Claude Dark'; background='#1A1915'; foreground='#E6E2D8'; cursorColor='#D97757'; selectionBackground='#4A3A30'
    black='#1A1915'; red='#D9645A'; green='#A3B18A'; yellow='#E8B06A'; blue='#D97757'; purple='#C77D5F'; cyan='#E0C9A6'; white='#E6E2D8'
    brightBlack='#6B5A4E'; brightRed='#E88F6F'; brightGreen='#B8C4A0'; brightYellow='#F0C48A'; brightBlue='#E88F6F'; brightPurple='#D9967C'; brightCyan='#ECDCC0'; brightWhite='#FAF9F5'
  }
  $j.profiles.list = @($j.profiles.list | Where-Object { $_.name -ne 'Claude Code' })
  $j.profiles.list += @{
    guid='{c1a0dec0-de00-4c1a-9e0d-000000000001}'; name='Claude Code'; hidden=$false; tabTitle='Claude Code'
    commandline='pwsh.exe -NoLogo -NoProfile -File "%USERPROFILE%\.claude\rifi-launcher.ps1"'
    icon='%USERPROFILE%\.claude\claude-mascot-pad.png'
    colorScheme='Claude Dark'; useAcrylic=$false; opacity=100
    backgroundImage='%USERPROFILE%\.claude\claude-mascot-pad.png'; backgroundImageOpacity=0.7
    backgroundImageAlignment='topRight'; backgroundImageStretchMode='none'
    'experimental.pixelShaderPath'=''; 'experimental.retroTerminalEffect'=$false
  }
  $j | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding UTF8
  Write-Host "✓ Windows Terminal profile 'Claude Code' added (backup: settings.json.bak)"
} else { Write-Host "! Windows Terminal settings not found, skipped" }

# 4. PowerShell profile: `claude` command
$fn = @'

# >>> ember >>>
function claude {
  if ($args.Count -eq 0 -or $args[0] -eq 'hi') {
    wt -w 0 nt -p "Claude Code" -d "$((Get-Location).Path)"
  } else { & "$env:USERPROFILE\.local\bin\claude.exe" @args }
}
# <<< ember <<<
'@
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Force $PROFILE | Out-Null }
if (-not ((Get-Content $PROFILE -Raw) -match 'ember')) { Add-Content $PROFILE $fn }
Write-Host "✓ PowerShell profile updated"

Write-Host "`nDone. Restart terminal, then run: claude" -ForegroundColor Green
Write-Host "Inside Claude, run /theme once and pick the ANSI dark theme."
