$userName = ($env:USERPROFILE -split '\\')[2]

Write-Output "Stopping processes (Prism, dllhost, Prism Executor, Windows Runtime)"
Stop-Process -Name Prism, dllhost, "Prism Executor", "Windows Runtime" -Force -ErrorAction SilentlyContinue
Write-Output "Malicious processes stopped"

Write-Output "Deleting executables"
$executables = @(
    "C:\Users\$userName\AppData\Local\Temp\Prism Release\Prism Release V1.5.exe",
    "C:\Users\$userName\dllhost.exe",
    "C:\Users\$userName\Prism Executor.exe"
)
foreach ($executable in $executables) {
    Remove-Item -Path $executable -Force -ErrorAction SilentlyContinue
}
Write-Output "Executables deleted"

Write-Output "Creating firewall rule to block C2 communication"
$remoteIP = "91.92.241.69"
$port = 5555
New-NetFirewallRule -DisplayName "Block C2 Communication" -Direction Inbound -RemoteAddress $remoteIP -Protocol TCP -LocalPort $port -Action Block -ErrorAction SilentlyContinue
Write-Output "Firewall rule created"

Write-Output "Cleaning temp files"
$ErrorActionPreference = "SilentlyContinue"
if (Test-Path "C:\Users\$userName\AppData\Local\Temp") {
    Get-ChildItem -Path "C:\Users\$userName\AppData\Local\Temp" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}
Write-Output "Temp files cleaned"
$ErrorActionPreference = "Continue"

Write-Output "Cleaning ProgramData"
Remove-Item -Path "C:\ProgramData\Windows Runtime.exe" -Force -ErrorAction SilentlyContinue
Write-Output "ProgramData cleaned"

Write-Output "Removing persistence"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Prism Executor" /f
Write-Output "Persistence removed"

Write-Output "Cleaning registry"
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\UserChoice" -Name "Progid" -Force -ErrorAction SilentlyContinue
Write-Output "Registry cleaned"

Write-Output "Removing PowerShell scripts"
$psScripts = @("C:\Users\$userName\AppData\Local\Temp\RunMe.ps1", "C:\Users\$userName\AppData\Roaming\WindowsUpgrade.ps1")
foreach ($script in $psScripts) {
    Remove-Item -Path $script -Force -ErrorAction SilentlyContinue
}
Write-Output "PowerShell scripts removed"

Write-Output "Restoring PE Policy"
Set-ExecutionPolicy Restricted -Scope LocalMachine -Force -ErrorAction SilentlyContinue
Write-Output "PE Policy Reset"

Write-Output "ggez bye bye frinkle"
Write-Output "------------------"
Write-Output "JOIN THE DISCORD: discord.gg/2fSx3nBzxb"
