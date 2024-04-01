Write-Host ''
Write-Host ''
Write-Host 'Имя компьютера' -ForegroundColor Green
Write-Host ''
$env:COMPUTERNAME
Write-Host ''
#
Write-Host 'Операционная система' -ForegroundColor Green
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object ProductName, EditionID, DisplayVersion, CurrentBuildNumber | Format-Table
#
Write-Host 'Архитектура' -ForegroundColor Green
Get-CimInStance CIM_OperatingSystem | Select-Object OSArchitecture | Format-Table
#
#Просмотр установленных обновлений wmic qfe list
Write-Host 'Обновления' -ForegroundColor Green
Get-WinEvent -filterHashtable @{ LogName = 'Setup'; Id = 2 }| Where-Object {$_.Message -like '*KB*'} | Format-Table
#
#systeminfo
#
#Распаковака пакета обновления, пример:
#expand -f:* "C:\Temp\windows10.0-kb5034768-x64_04b794598371fdc01bb5840c68487388ca029ad5.msu" C:\Temp\KB5034768\x64\
#
#Установка CAB файла, пример: 
#DISM.exe /Online /Add-Package /PackagePath:C:\Temp\KB5034768\x64\Windows10.0-KB5034768-x64.cab
$shell = New-Object -ComObject Wscript.Shell
$shell.popup("Ура все получилось",0,"Результат" , 64)
