<#
	Скрипт подключается к почтовому серверу Microsoft Exchange и обращается к каталогу Active Directory.
	Осуществляет непрерывный цикл ping ПК и останавливается в случае, если все ПК из списка были в сети.
	По ПК, которые ответиели на пинг и оказались в сети, отправляется один раз электронное письмо на указанную почту.
#>

# Импортируем модуль и подключаемся к почтовому серверу Microsoft Exchange.
if (-Not(Get-Module -Name RemoteExchange)) {
	Import-Module 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto -ClientApplication:ManagementShell
}

# Вводим электронную почту, на которую будут приходить письма.
while ($true) {
	echo ""
	# Write-Host " Введите адрес электронной почты" -ForegroundColor Yellow
	[string]$InputMail = (Read-Host " Почтовый адрес").ToLower()

	if ($InputMail -like $null) {
		echo ""
		Start-Sleep -Milliseconds 500
		Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
		Write-Host " Введено пустое значение."
	}
	else {
		$Name = $InputMail.Split("@")
		try {
			if (Get-ADUser $Name[0]){
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " OK" -ForegroundColor Green
					echo ""
					break
			}
			else {
				echo ""
				Start-Sleep -Milliseconds 500
				Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
				Write-Host " Учётная запись" -NoNewline
				Write-Host " $($Name[0])" -ForegroundColor Gray -NoNewline
				Write-Host " не имеет привилегий получать отчет на почту."
			}
		}
		catch {
			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
			Write-Host " Учётная запись" -NoNewline
			Write-Host " $($Name[0])" -ForegroundColor Gray -NoNewline
			Write-Host " не существует."
		}
	}
}

$PathRoot = $MyInvocation.MyCommand.Path | Split-Path -parent
[string]$Path = "$PathRoot"

<# 
	В директории, которой находится скрипт необходимо создать текстовый файл "PC.txt", в котором надо сохранить список имён ПК.
	Например:
		PC-001
		PC-002
		PC-003
#> 
$Computers = (Get-Content -Path "$($Path)\PC.txt").Trim()
$ArrayComputers = [System.Collections.ArrayList]@()

while ($true) {

	if ($ArrayComputers.Count -ne $Computers.Count) {

		foreach ($Comp in $Computers) {

			try {

				$CheckComp = Test-Connection $Comp -Count 1 -ErrorAction Stop

				if ($CheckComp) { 

					$GetIP = (Test-Connection $Comp -Count 1).IPV4Address.IPAddressToString
					$ChekName = [System.Net.Dns]::GetHostEntry($GetIP).HostName

					if ($ChekName -match $Comp){
						
						if (-Not($Comp -in $ArrayComputers)) {
							
							Write-Host " $($Comp)" -NoNewline
							Write-Host " В сети" -ForegroundColor Green
							[void]($ArrayComputers.Add($Comp))
							
							# Если в Active directory записывается в атрибут "info" ФИО, кто логинился на ПК.
							$GetUserName = (Get-ADUser -Filter * -Properties * | Where-Object {$_.info -match $Comp}).Name
							
							$MailMessage = @{
								From       = "$($InputMail)"
								To         = "$($InputMail)"
								Subject    = "[$($Comp)]$($GetUserName)"
								Body       = "Компьютер $($Comp) в сети. Пользователь: $($GetUserName)"
								Smtpserver = "mail.tradicia-k.ru"
								Port       = 25
								UseSsl     = $false
								Encoding   = “UTF8”
							}
							
							# Отправка электронного письма.
							Send-MailMessage @MailMessage
							# В директории, в которой находится скрипт формируется лог-файл.
							Add-Content -Path "$($Path)\log.txt" -Value ("[$($Comp)]Был в сети.") -Encoding UTF8
						}
					}
					else {
						Write-Host " $($Comp)" -NoNewline
						Write-Host " Не в сети" -ForegroundColor Red -NoNewline
						Write-Host " IP:" -NoNewline
						Write-Host " $($GetIP)" -ForegroundColor Gray -NoNewline
						Write-Host " присвоен" -NoNewline
						Write-Host " $($ChekName)" -ForegroundColor Green
					}
				}
			}
			catch {
				Write-Host " $($Comp)" -NoNewline
				Write-Host " Не в сети" -ForegroundColor Red
			}
		}
	}
	else {
		echo ""
		Write-Host " Все компьютеры из списка были в сети" -ForegroundColor Green
		$ArrayComputers.Clear()
		break
	}
}
