# Описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
# https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3

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
}