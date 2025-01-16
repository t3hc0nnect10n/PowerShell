<#
	Название параметра GPO              Подветка с именем Device Class GUID           Имя параметра реестра:

	Floppy Drives:
	Deny read access                    {53f56311-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Read
	Deny write access                   {53f56311-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Write

	CD and DVD:
	Deny read access                    {53f56308-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Read
	Deny write access                   {53f56308-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Write

	Removable Disks:
	Deny read access                    {53f5630d-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Read
	Deny write access                   {53f5630d-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Write

	Tape Drives:
	Deny read access                    {53f5630b-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Read
	Deny write access                   {53f5630b-b6bf-11d0-94f2-00a0c91efb8b}        Deny_Write

	WPD Devices:
	Deny read access                    {6AC27878-A6FA-4155-BA85-F98F491D4F33}        Deny_Read
	Deny write access                   {6AC27878-A6FA-4155-BA85-F98F491D4F33}        Deny_Write
	Deny read access                    {F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}        Deny_Read
	Deny write access                   {F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}        Deny_Write
#>

# Значение для параметра DWord.
#  Вкл: 1
# Выкл: 0
$Value = 0

try {
	# Ветки в реестре.
	$RegKey_0 = "HKLM:\Software\Policies\Microsoft\Windows"
	$RegKey_1 = "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices"	
	$RegKey_2 = "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f56308-b6bf-11d0-94f2-00a0c91efb8b}"
	$RegKey_3 = "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}"
	$RegKey_4 = "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}"
	$RegKey_5 = "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f56311-b6bf-11d0-94f2-00a0c91efb8b}"
	$RegKey_6 = "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{6AC27878-A6FA-4155-BA85-F98F491D4F33}"
	$RegKey_7 = "HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}"

	$ParentPSPath = (Get-ChildItem -Path $RegKey_0 -ErrorAction Stop | Where-Object PSPath -match "RemovableStorageDevices").PSPath
	$ChiledPSPath = (Get-ChildItem -Path $ParentPSPath -ErrorAction Stop).PSPath
	$ItemParentPSPath = Get-ItemProperty -Path $ParentPSPath -ErrorAction Stop
}
catch {}

$TestPath_1 = Test-Path $RegKey_1
$TestPath_2 = Test-Path $RegKey_2
$TestPath_3 = Test-Path $RegKey_3
$TestPath_4 = Test-Path $RegKey_4
$TestPath_5 = Test-Path $RegKey_5
$TestPath_6 = Test-Path $RegKey_6
$TestPath_7 = Test-Path $RegKey_7

# Создание веток в реестре.
if (-Not($TestPath_1 -or $TestPath_2 -or $TestPath_3 -or $TestPath_4 -or $TestPath_5 -or $TestPath_6 -or $TestPath_7)) {
	# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "RemovableStorageDevices".
	New-Item -Path $RegKey_0 -Name "RemovableStorageDevices" -Force | Out-Null
	New-ItemProperty -Path $RegKey_1 -Name "Deny_All" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_1 -Name "AllowRemoteDASD" -Value $Value -PropertyType 'DWord' -Force | Out-Null

	# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "{53f56308-b6bf-11d0-94f2-00a0c91efb8b}".
	New-Item -Path $RegKey_1 -Name "{53f56308-b6bf-11d0-94f2-00a0c91efb8b}" -Force | Out-Null
	New-ItemProperty -Path $RegKey_2 -Name "Deny_Read" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_2 -Name "Deny_Write" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_2 -Name "Deny_Execute" -Value $Value -PropertyType 'DWord' -Force | Out-Null

	# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}".
	New-Item -Path $RegKey_1 -Name "{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}" -Force | Out-Null
	New-ItemProperty -Path $RegKey_3 -Name "Deny_Read" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_3 -Name "Deny_Write" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_3 -Name "Deny_Execute" -Value $Value -PropertyType 'DWord' -Force | Out-Null

	# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}".
	New-Item -Path $RegKey_1 -Name "{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" -Force | Out-Null
	New-ItemProperty -Path $RegKey_4 -Name "Deny_Read" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_4 -Name "Deny_Write" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_4 -Name "Deny_Execute" -Value $Value -PropertyType 'DWord' -Force | Out-Null

	# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "{53f56311-b6bf-11d0-94f2-00a0c91efb8b}".
	New-Item -Path $RegKey_1 -Name "{53f56311-b6bf-11d0-94f2-00a0c91efb8b}" -Force | Out-Null
	New-ItemProperty -Path $RegKey_5 -Name "Deny_Read" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_5 -Name "Deny_Write" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_5 -Name "Deny_Execute" -Value $Value -PropertyType 'DWord' -Force | Out-Null

	# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "{6AC27878-A6FA-4155-BA85-F98F491D4F33}".
	New-Item -Path $RegKey_1 -Name "{6AC27878-A6FA-4155-BA85-F98F491D4F33}" -Force | Out-Null
	New-ItemProperty -Path $RegKey_6 -Name "Deny_Read" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_6 -Name "Deny_Write" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_6 -Name "Deny_Execute" -Value $Value -PropertyType 'DWord' -Force | Out-Null

	# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "{F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}".
	New-Item -Path $RegKey_1 -Name "{F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}" -Force | Out-Null
	New-ItemProperty -Path $RegKey_7 -Name "Deny_Read" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_7 -Name "Deny_Write" -Value $Value -PropertyType 'DWord' -Force | Out-Null
	New-ItemProperty -Path $RegKey_7 -Name "Deny_Execute" -Value $Value -PropertyType 'DWord' -Force | Out-Null

	echo ""
	Write-Host "GOOD" -BackgroundColor Green -NoNewline
	Write-Host " В реестре создались ветки" -ForegroundColor Cyan
	echo ""
	Write-Host "$($RegKey_1)"
	Write-Host "Deny_All = $($Value)"
	Write-Host "AllowRemoteDASD = $($Value)"
	echo ""
	Write-Host "$($RegKey_2)"
	Write-Host "Deny_Read = $($Value)"
	Write-Host "Deny_Write = $($Value)"
	Write-Host "Deny_Execute = $($Value)"
	echo ""
	Write-Host "$($RegKey_3)"
	Write-Host "Deny_Read = $($Value)"
	Write-Host "Deny_Write = $($Value)"
	Write-Host "Deny_Execute = $($Value)"
	echo ""
	Write-Host "$($RegKey_4)"
	Write-Host "Deny_Read = $($Value)"
	Write-Host "Deny_Write = $($Value)"
	Write-Host "Deny_Execute = $($Value)"
	echo ""
	Write-Host "$($RegKey_5)"
	Write-Host "Deny_Read = $($Value)"
	Write-Host "Deny_Write = $($Value)"
	Write-Host "Deny_Execute = $($Value)"
	echo ""
	Write-Host "$($RegKey_6)"
	Write-Host "Deny_Read = $($Value)"
	Write-Host "Deny_Write = $($Value)"
	Write-Host "Deny_Execute = $($Value)"
	echo ""
	Write-Host "$($RegKey_7)"
	Write-Host "Deny_Read = $($Value)"
	Write-Host "Deny_Write = $($Value)"
	Write-Host "Deny_Execute = $($Value)"
}
# Изменение значений веток в реестре.
else {
	echo ""
	Write-Host "GOOD" -BackgroundColor Green -NoNewline
	Write-Host " В ветках реестра изменились значения" -ForegroundColor Cyan

	echo ""
	Write-Host $ParentPSPath

	# Изменение значения "Deny_All" в ветке "RemovableStorageDevices".
	if (($ItemParentPSPath.Deny_All -eq 0) -or ($ItemParentPSPath.Deny_All -eq 1)) {
		Set-ItemProperty -Path $ParentPSPath -Name "Deny_All" -Value $Value
		$ItemParentPSPath = Get-ItemProperty -Path $ParentPSPath
		Write-Host "Deny_All = $($ItemParentPSPath.Deny_All)"
	}
	# Изменение значения "AllowRemoteDASD" в ветке "RemovableStorageDevices".
	if (($ItemParentPSPath.AllowRemoteDASD -eq 0) -or ($ItemParentPSPath.AllowRemoteDASD -eq 1)) {
		Set-ItemProperty -Path $ParentPSPath -Name "AllowRemoteDASD" -Value $Value
		$ItemParentPSPath = Get-ItemProperty -Path $ParentPSPath
		Write-Host "AllowRemoteDASD = $($ItemParentPSPath.AllowRemoteDASD)"
	}

	<# 
		Изменение значений "Deny_Read","Deny_Write", "Deny_Execute" в ветках:
		{53f56308-b6bf-11d0-94f2-00a0c91efb8b}
		{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}
		{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}
		{53f56311-b6bf-11d0-94f2-00a0c91efb8b}
		{6AC27878-A6FA-4155-BA85-F98F491D4F33}
		{F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}
	#>
	foreach($Reg in $ChiledPSPath) {
		echo ""
		Write-Host "$($Reg)"

		$tmp_Reg = Get-ItemProperty -Path $Reg

		if (($tmp_Reg.Deny_Read -eq 0) -or ($tmp_Reg.Deny_Read -eq 1)) {
			Set-ItemProperty -Path $ChiledPSPath -Name "Deny_Read" -Value $Value
			$tmp_Reg = Get-ItemProperty -Path $Reg
			Write-Host "Deny_Read = $($tmp_Reg.Deny_Read)"
		}

		if (($tmp_Reg.Deny_Write -eq 0) -or ($tmp_Reg.Deny_Write -eq 1)) {
			Set-ItemProperty -Path $ChiledPSPath -Name "Deny_Write" -Value $Value
			$tmp_Reg = Get-ItemProperty -Path $Reg
			Write-Host "Deny_Write = $($tmp_Reg.Deny_Write)"
		}

		if (($tmp_Reg.Deny_Execute -eq 0) -or ($tmp_Reg.Deny_Execute -eq 1)) {
			Set-ItemProperty -Path $ChiledPSPath -Name "Deny_Execute" -Value $Value
			$tmp_Reg = Get-ItemProperty -Path $Reg
			Write-Host "Deny_Execute = $($tmp_Reg.Deny_Execute)"
		}
	}
}
