# Описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
# https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
#
# Название параметра GPO	        Подветка с именем Device Class GUID			Имя параметра реестра:
#
# Floppy Drives:
# Deny read access			{53f56311-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Read
# Floppy Drives:
# Deny write access			{53f56311-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Write
#
# CD and DVD:
# Deny read access			{53f56308-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Read
# CD and DVD:
# Deny write access			{53f56308-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Write
#
# Removable Disks:
# Deny read access			{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Read
# Removable Disks:
# Deny write access			{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Write
#
# Tape Drives:
# Deny read access			{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Read
# Tape Drives:
# Deny write access			{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}			Deny_Write
#
# WPD Devices:
# Deny read access			{6AC27878-A6FA-4155-BA85-F98F491D4F33}			Deny_Read
# Deny read access			{F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}			Deny_Read
# WPD Devices:
# Deny write access			{6AC27878-A6FA-4155-BA85-F98F491D4F33}			Deny_Write
# Deny write access			{F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}			Deny_Write
try
{
	# Ветка в реестре
	$regkey='HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}'
	# Проверка на наличии ветки в реестре
	$exists = Test-Path $regkey

	try
	{
		if (!$exists) {
			# Если ветки в реестре нет, то она создастся с присвоенным классом устройства "{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}"
			New-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\RemovableStorageDevices' -Name '{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}' -Force | Out-Null
			# Запрет на запись
			New-ItemProperty -Path $regkey -Name 'Deny_Write' -Value 1 -PropertyType 'DWord' -Force | Out-Null
		}
	}
    finally
    {
        # Индикация успешновыполненого скритпта
        Write-Host ""
        Write-Host "GOOD" -BackgroundColor Green
    }
}
catch
{
    # Вывод шибки в консоль
    Write-Host ""
    Write-Host "ERROR" -BackgroundColor Red
    Write-Host "Error: $($_.Exception.Messege)"
