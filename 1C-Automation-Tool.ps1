<#
Made by t3hc0nnect10n (c) 2024
Version 1.0

	Для работы сценария требуется настроенная служба - Windows Remote Management (WinRM).
	https://learn.microsoft.com/en-us/windows/win32/winrm/portal

	Сценарий предназначен для работы с серверной средой *ПО "1С:Предприятие".
	Взаимодействует с сервером, с каталогом Active Directory, осуществляет контроль пользовательского ввода и выполняет функции:

		0.Устанавливает подключение к серверу. 
		1.Вывод информации о кластере.
		2.Вывод информации о COM-объекте.
		3.Вывод информации о версиях платформы.
		4.Вывод информации о службе.
		5.Выполняет работу со службой: 
			- запуск;
			- остановка;
			- перезапуск.
		6.Выполняет работу с COM-объектом:
			- регистрация;
			- отмена регистрации.
		7.Удаляет активные сессии:
			- из определённых баз	 (формируется лог файл);
			- все сессии на кластере (формируется лог файл).
		8. Удаляет сервер и службу 1С.
		9. Устанавливает сервер" и службу 1С.

	*ПО - программное обеспечение.
#>

# Функция. Загрузка меню.
function Loading-Menu() {

	echo ""
	Write-Host "  $SetServer" -ForegroundColor Cyan
	Write-Host "  --------------- Меню --------------" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 1."  -ForegroundColor Cyan -NoNewline
	Write-Host " Информация о кластере" -ForegroundColor Yellow -NoNewline
	Write-Host "          |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 2." -ForegroundColor Cyan -NoNewline
	Write-Host " Информация о COM-объекте" -ForegroundColor Yellow -NoNewline
	Write-Host "       |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 3." -ForegroundColor Cyan -NoNewline
	Write-Host " Информация о версиях платформы" -ForegroundColor Yellow -NoNewline
	Write-Host " |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline	
	Write-Host " 4." -ForegroundColor Cyan -NoNewline
	Write-Host " Информация о службе" -ForegroundColor Yellow -NoNewline
	Write-Host "            |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 5." -ForegroundColor Cyan -NoNewline
	Write-Host " Работа со службой" -ForegroundColor Yellow -NoNewline
	Write-Host "              |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 6." -ForegroundColor Cyan -NoNewline
	Write-Host " Работа с COM-объектом" -ForegroundColor Yellow -NoNewline
	Write-Host "          |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 7." -ForegroundColor Cyan -NoNewline
	Write-Host " Удаление активных сессий" -ForegroundColor Yellow -NoNewline
	Write-Host "       |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 8." -ForegroundColor Cyan -NoNewline
	Write-Host " Удаление сервера" -ForegroundColor Yellow -NoNewline
	Write-Host "               |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " 9." -ForegroundColor Cyan -NoNewline
	Write-Host " Установка сервера" -ForegroundColor Yellow -NoNewline
	Write-Host "              |" -ForegroundColor Magenta
	Write-Host " |" -ForegroundColor Magenta -NoNewline
	Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
	Write-Host " Exit" -ForegroundColor Cyan -NoNewline
	Write-Host "          |" -ForegroundColor Magenta
	Write-Host "  -----------------------------------" -ForegroundColor Magenta
}

# Функция 0. Установка подключения к серверу.
function Set-Server1C() {

	# Ввод сервера для отправки скрипт-блока.
	while ($true) {
		echo ""
		Write-Host " Введите имя сервера" -ForegroundColor Yellow
		Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
		Write-Host " SRV-1C-01" -ForegroundColor Gray
		[string]$InputServer = (Read-Host " Сервер").ToUpper()

		if (-Not($InputServer -like $null)) {
			try {
				$ADServer = Get-ADComputer $InputServer -ErrorAction Stop
				if ($ADServer) {
					try {
						$TestConnection = Test-Connection $InputServer -Count 1 -ErrorAction Stop
						if ($TestConnection) {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОК" -ForegroundColor Green
							$Global:SetServer = $InputServer
							break
						}
					}
					catch {
						echo ""
						Start-Sleep -Milliseconds 500
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " Сервер" -NoNewline
						Write-Host " $InputServer" -ForegroundColor Gray -NoNewline
						Write-Host " не в сети."
					}
				}
			}
			catch {
				echo ""
				Start-Sleep -Milliseconds 500
				Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
				Write-Host " Сервер" -NoNewline
				Write-Host " $InputServer" -ForegroundColor Gray -NoNewline
				Write-Host " не в существует."
			}
		}
		else {
			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
			Write-Host " Введено пустое значение."
		}
	}
}

# Функция 1. Информация о кластере.
function Get-Cluster1C {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {

		$services1C = Get-WmiObject win32_service | Where-Object {$_.Name -like '*'} |
			Select Name, DisplayName, State, PathName |
			Where-Object {$_.PathName -Like "*ragent.exe*"}

			if ($services1C) {
				$obj = [PSCustomObject] @{
				data = @($services1C | Where-Object {
					$serviceInfo     = $_
					$serviceExecPath = $serviceInfo.PathName

					$hash = [ordered]@{}
					$serviceExecPath.Split("-").Trim() | Where-Object {$_.Contains(" ")} | ForEach-Object {
						$name, $value = $_ -split '\s+', 2
						$hash[$name]  = $value
					}

					$parsePathAgentExe = $serviceExecPath.Substring(1, $serviceExecPath.Length -1)
					$parsePathAgentExe = $parsePathAgentExe.Substring(0, $parsePathAgentExe.IndexOf('"'))

					if(Test-Path $parsePathAgentExe) {
						$platformVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($parsePathAgentExe).FileVersion
					}
					else {
						$platformVersion = ""
					}

					$clusterPath      = $hash.d -replace '"', ''
					$clusterRegPort   = $hash.regport
					$clusterPort      = $hash.port
					$clusterPortRange = $hash.range
					$clusterRegPath   = "$clusterPath\reg_$clusterRegPort"

					[PSCustomObject] @{
						'Name'             = $serviceInfo.Name
						'DisplayName'      = $serviceInfo.DisplayName
						'State'            = $serviceInfo.State
						'Version'          = $platformVersion
						'ClusterPath'      = $clusterPath
						'ClusterRegPort'   = $clusterRegPort
						'ClusterPort'      = $clusterPort
						'ClusterPortRange' = $clusterPortRange
						'ClusterRegPath'   = $clusterRegPath
						'PathName'         = $serviceInfo.PathName
					}
				})
			}
			$obj.data | Format-List
		}
		else {
			echo ""
			Write-Verbose "Не установлен продукт 1С:Предприятие 8" -Verbose
		}
	}
	Clear-Variable -Name "Server"
}

# Функция 2. Информация о COM-объекте.
function Get-ComObject1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {

		try {
			$v83COMConnector = New-Object -COMObject "V82.COMConnector"
			echo ""
			Write-Host " Компонента V82.COMConnector" -NoNewline
			Write-Host " Зарегистрирована" -ForegroundColor Green
		}
		catch {
			echo ""
			Write-Host " Компонента V82.COMConnector" -NoNewline
			Write-Host " Не зарегистрирована" -ForegroundColor Red
		}

		try {
			$v83COMConnector = New-Object -COMObject "V83.COMConnector"
			echo ""
			Write-Host " Компонента V83.COMConnector" -NoNewline
			Write-Host " Зарегистрирована" -ForegroundColor Green
		}
		catch {
			echo ""
			Write-Host " Компонента V83.COMConnector" -NoNewline
			Write-Host " Не зарегистрирована" -ForegroundColor Red
		}
	}
	Clear-Variable -Name "Server"
}

# Функция 3. Информация о версиях платформы.
function Get-Platform1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {

		$ArrayInstalledPlatform1C = [System.Collections.ArrayList]@()
		
		if (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {($_.DisplayName -like "*1С:Предприятие*") -or ($_.DisplayName -like "*1С:Enterprise*")}) {
			Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
				Where-Object {($_.DisplayName -like "*1С:Предприятие*") -or ($_.DisplayName -like "*1С:Enterprise*")} |
				Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
				ForEach-Object {
					$ArrayInstalledPlatform1C.Add(
						[PSCustomObject] @{
							'DisplayName'     = $_.DisplayName
							'DisplayVersion'  = $_.DisplayVersion
							'Publisher'       = $_.Publisher
							'InstallDate'     = $_.InstallDate
							'InstallLocation' = $_.InstallLocation
						}
					) | Out-Null
				}
			$ArrayInstalledPlatform1C | Format-Table –AutoSize
			$ArrayInstalledPlatform1C.Clear()
		}
		elseif (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {($_.DisplayName -like "*1С:Предприятие*") -or ($_.DisplayName -like "*1С:Enterprise*")}) {
			Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
				Where-Object {($_.DisplayName -like "*1С:Предприятие*") -or ($_.DisplayName -like "*1С:Enterprise*")} |
				Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
				ForEach-Object {
					$ArrayInstalledPlatform1C.Add(
						[PSCustomObject] @{
							'DisplayName'     = $_.DisplayName
							'DisplayVersion'  = $_.DisplayVersion
							'Publisher'       = $_.Publisher
							'InstallDate'     = $_.InstallDate
							'InstallLocation' = $_.InstallLocation
						}
					) | Out-Null
				}
			$ArrayInstalledPlatform1C | Format-Table –AutoSize
			$ArrayInstalledPlatform1C.Clear()
		}
		else {
			echo ""
			Write-Verbose "Не установлен продукт 1С:Предприятие 8" -Verbose
		}
	}
	Clear-Variable -Name "Server"
}

# Функция 4. Информация о службе.
function Get-Service1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {

		$services1C = Get-WmiObject win32_service | Where-Object {$_.Name -like '*'} |
			Select Name, DisplayName, State, PathName |
			Where-Object {$_.PathName -Like "*ragent.exe*"}
		if ($services1C) {
			$obj = [PSCustomObject] @{
				data = @($services1C | % {
					$serviceInfo = $_
					[PSCustomObject] @{
						'Name'        = $serviceInfo.Name
						'State'       = $serviceInfo.State
						'DisplayName' = $serviceInfo.DisplayName
						'PathName'    = $serviceInfo.PathName
					}
				})
			}
			$obj.data | Format-Table –AutoSize
		}
		else {
			echo ""
			Write-Verbose "Не установлен продукт 1С:Предприятие 8" -Verbose
		}
	}
	Clear-Variable -Name "Server"
}

# Функция 5. Работа со службой 1С.
function Job-Service1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {

		function Service-1C() {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[string] $Number
			)

			for ($a = 1; $a -lt $ArrayServices1C.Count + 1; $a ++) {
				if ($Number -eq $a) {
					return $ArrayServices1C[$a-1]
				}
			}
		}

		if (Get-Service | Where-Object {($_.Name).StartsWith("1C")}) {
			$ArrayServices1C = [System.Collections.ArrayList]@()
			$GetServices1C	 = Get-Service | Where-Object {($_.Name).StartsWith("1C")} | ForEach-Object {$ArrayServices1C.Add($_.Name)}

			while ($true) {
				echo ""
				Write-Host " Выберите службу" -ForegroundColor Yellow
				for ($i = 1; $i -lt $ArrayServices1C.Count + 1; $i ++) {
					Write-Host " $($i)." -ForegroundColor Cyan -NoNewline
					Write-Host " $($ArrayServices1C[$i-1])" -ForegroundColor Gray
				}
				Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
				Write-Host " Exit" -ForegroundColor Cyan
				$UserInputService = (Read-Host " Выбор").ToLower()

				# Если служба 1С.
				if (($UserInputService -ge 1) -and ($UserInputService -le $ArrayServices1C.Count)) {
					$NameService1C	= Service-1C -Number $UserInputService
					$Service1C		= Get-Service -Name $NameService1C -ErrorAction Stop

					while ($true) {
						echo ""
						Start-Sleep -Milliseconds 500
						Write-Host " Служба:" -ForegroundColor Cyan -NoNewline
						Write-Host " $($NameService1C)" -ForegroundColor Gray
						Write-Host " 1." -ForegroundColor Cyan -NoNewline
						Write-Host " Запуск службы 1C" -ForegroundColor Yellow
						Write-Host " 2." -ForegroundColor Cyan -NoNewline
						Write-Host " Остановка службы 1C" -ForegroundColor Yellow
						Write-Host " 3." -ForegroundColor Cyan -NoNewline
						Write-Host " Перезапуск службы 1C" -ForegroundColor Yellow
						Write-Host " Для выход введите:" -ForegroundColor Yellow -NoNewline
						Write-Host " Exit" -ForegroundColor Cyan
						$UserInput = (Read-Host " Выбор").ToLower()

						# Запуск службы 1С.
						if ($UserInput -eq 1) {
							$CheckService1C = Get-Service -Name $Service1C.Name -ErrorAction Stop
							if ($CheckService1C.Status -like 'Stopped') {
								try {
									Start-Service $Service1C.Name -ErrorAction Stop
									Start-Sleep -Seconds 5
									$GetStatus1C = Get-Service -Name $Service1C.Name -ErrorAction Stop
									if ($GetStatus1C){
										echo ""
										Start-Sleep -Milliseconds 1500
										Write-Host " Cлужба:" -ForegroundColor Cyan -NoNewline
										Write-Host " $($Service1C.Name)" -ForegroundColor Gray -NoNewline
										Write-Host " Запущена" -ForegroundColor Green
										Clear-Variable -Name "GetStatus1C"
									}
									Clear-Variable -Name "CheckService1C"
								}
								catch {
									echo ""
									Start-Sleep -Milliseconds 1500
									Write-Host " Ошибка:" -ForegroundColor Red -NoNewline
									Write-Host $Error[0]
								}

							}
							else {
								echo ""
								Start-Sleep -Milliseconds 1500
								Write-Host " Cлужба:" -ForegroundColor Cyan -NoNewline
								Write-Host " $($Service1C.Name)" -ForegroundColor Gray -NoNewline
								Write-Host " Запущена" -ForegroundColor Green
							}
						}
						# Остановка службы 1С.
						elseif ($UserInput -eq 2) {
							$CheckService1C = Get-Service -Name $Service1C.Name -ErrorAction Stop
							if ($CheckService1C.Status -like 'Running') {
								try {
									Stop-Service $Service1C.Name -Force -ErrorAction Stop -WarningAction SilentlyContinue
									Start-Sleep -Seconds 5
									$GetStatus1C = Get-Service -Name $Service1C.Name -ErrorAction Stop
									if ($GetStatus1C){
										echo ""
										Start-Sleep -Milliseconds 1500
										Write-Host " Cлужба:" -ForegroundColor Cyan -NoNewline
										Write-Host " $($Service1C.Name)" -ForegroundColor Gray -NoNewline
										Write-Host " Остановлена" -ForegroundColor Red
										Clear-Variable -Name "GetStatus1C"
									}
									Clear-Variable -Name "CheckService1C"
								}
								catch {
									echo ""
									Start-Sleep -Milliseconds 1500
									Write-Host " Ошибка:" -ForegroundColor Red -NoNewline
									Write-Host $Error[0]
								}
							}
							else {
								echo ""
								Start-Sleep -Milliseconds 1500
								Write-Host " Cлужба:" -ForegroundColor Cyan -NoNewline
								Write-Host " $($Service1C.Name)" -ForegroundColor Gray -NoNewline
								Write-Host " Остановлена" -ForegroundColor Red
							}
						}
						# Перезапуск службы 1С.
						elseif ($UserInput -eq 3) {
							$CheckService1C = Get-Service -Name $Service1C.Name -ErrorAction Stop
							if ($CheckService1C.Status -like 'Running') {
								try {
									echo ""
									Restart-Service $Service1C.Name -Force -ErrorAction Sto
									Start-Sleep -Seconds 5
									$GetStatus1C = Get-Service -Name $Service1C.Name -ErrorAction Stop
									if ($GetStatus1C){
										echo ""
										Start-Sleep -Milliseconds 1500
										Write-Host " Cлужба:" -ForegroundColor Cyan -NoNewline
										Write-Host " $($Service1C.Name)" -ForegroundColor Gray -NoNewline
										Write-Host " Перезапущена" -ForegroundColor Green
										Clear-Variable -Name "GetStatus1C"
									}
									Clear-Variable -Name "CheckService1C"
								}
								catch {
									echo ""
									Start-Sleep -Milliseconds 1500
									Write-Host " Ошибка:" -ForegroundColor Red -NoNewline
									Write-Host $Error[0]
								}
							}
							else {
								echo ""
								Start-Sleep -Milliseconds 1500
								Write-Host " Cлужба:" -ForegroundColor Cyan -NoNewline
								Write-Host " $($Service1C.Name)" -ForegroundColor Gray -NoNewline
								Write-Host " Перезапущена" -ForegroundColor Green
							}
						}
						# Выход.
						elseif ($UserInput -eq "exit") {
							break
						}
						# Ошибка.
						elseif ($UserInput -like $null){
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
							Write-Host " Введено пустое значение."
						}
						# Ошибка.
						else {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
							Write-Host " Неверно введена команда."
						}
					}
				}
				# Выход.
				elseif ($UserInputService -like "exit") {
					break
				}
				# Ошибка.
				elseif ($UserInputService -like $null) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Введено пустое значение."
				}
				# Ошибка.
				else {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Неверно введена команда."
				}
			}
		}
		else {
			echo ""
			Write-Verbose "Не установлен продукт 1С:Предприятие 8" -Verbose
		}
	}
	Clear-Variable -Name "Server"
}

# Функция 6. Работа с COM-объектом.
function Job-ComObject1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {

		
		if (Get-Service -ErrorAction Stop | Where-Object {($_.Name).StartsWith("1C")}) {
			$ArrayServices1C       = [System.Collections.ArrayList]@()
			$GetServices1C         = Get-Service -ErrorAction Stop | Where-Object {($_.Name).StartsWith("1C")} | ForEach-Object {$ArrayServices1C.Add($_.Name)}
			$GetService1C          = ($ArrayServices1C | Measure-Object -Maximum).Maximum
			$NameService1C         = Get-Service $GetService1C -ErrorAction Stop
			$Service1C             = Get-WmiObject win32_service | Where-Object {$_.Name -like $NameService1C.Name} | Select Name, DisplayName, State, PathName | Where-Object {$_.PathName -Like "*ragent.exe*"}
			$ServiceExecPath       = $Service1C.PathName
			$ServiceExecPathRagent = $Service1C.PathName.split('"')[1]
			$ServiceDirectory      = [System.IO.Path]::GetDirectoryName($ServiceExecPathRagent)
			$ComCntrPath           = "$ServiceDirectory\comcntr.dll"
			$PlatformVersion       = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($ServiceExecPathRagent).FileVersion

			while ($true) {
				echo ""
				Start-Sleep -Milliseconds 500
				Write-Host " Компанента:" -ForegroundColor Cyan -NoNewline
				Write-Host " $($NameService1C.Name)" -ForegroundColor Gray
				Write-Host " 1." -ForegroundColor Cyan -NoNewline
				Write-Host " Регистрация" -ForegroundColor Yellow
				Write-Host " 2." -ForegroundColor Cyan -NoNewline
				Write-Host " Отмена регистрации" -ForegroundColor Yellow
				Write-Host " Для выход введите:" -ForegroundColor Yellow -NoNewline
				Write-Host " Exit" -ForegroundColor Cyan
				$UserInput = (Read-Host " Выбор").ToLower()

				# Регистрации COM-объект.
				if ($UserInput -eq 1) {
					echo ""
					Write-Host " Начало регистрации COM-компоненты 1С:Предприятия"
					Write-Host " Версия платформы: $PlatformVersion"
					Write-Host " Путь к DLL: ""$ComCntrPath"""
					Write-Host " Команда регистрации компоненты: ""$RegCommand"""
					try {
						cmd /c "regsvr32.exe /s ""$ComCntrPath"""
						Start-Sleep -Milliseconds 500
						echo ""
						Write-Host " Компонента" -NoNewline
						Write-Host " Зарегистрирована" -ForegroundColor Green
						break
					} 
					catch {
						echo ""
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " Компонента не зарегистрирована"
						Write-Host " ПОДРОБНО:" -ForegroundColor Red -NoNewline
						Write-Host $Error[0]
					}
				}
				# Отмена регистрации COM-объект.
				elseif ($UserInput -eq 2) {
					echo ""
					Write-Host " Начало отмены регистрации COM-компоненты 1С:Предприятия"
					Write-Host " Версия платформы: $PlatformVersion"
					Write-Host " Путь к DLL: ""$ComCntrPath"""
					Write-Host " Команда отмены регистрации компоненты: ""$RegCommand"""
					try {
						cmd /c "regsvr32.exe /u /s ""$comcntrPath"""
						Start-Sleep -Milliseconds 500
						echo ""
						Write-Host " Регистрация компаненты" -NoNewline 
						Write-Host " Отменена" -ForegroundColor Red
						break
					}
					catch {
						echo ""
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " Ошибка при отмене регистрации компоненты"
						Write-Host " ПОДРОБНО:" -ForegroundColor Red -NoNewline
						Write-Host $Error[0]
					}
				}
				# Выход.
				elseif ($UserInput -like "exit") {
					break
				}
				# Ошибка.
				elseif ($UserInput -like $null) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Введено пустое значение."
				}
				# Ошибка.
				else {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Неверно введена команда."
				}
			}
		}
		else {
			echo ""
			Write-Verbose "Не установлен продукт 1С:Предприятие 8" -Verbose
		}
	}
	Clear-Variable -Name "Server"
}

# Функция 7. Удаление активных сессий.
function Disactivate-Session1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
		,
		[Parameter(Mandatory = $true)]
		[string] $Path
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {
		
		if (Get-Service | Where-Object {($_.Name).StartsWith("1C")}) {
			$PathLogFile = "C:\Users\Администратор\Documents\TempLog.txt"
			# Условие проверки файла "log" в директории откуда запускается скрипт. Если файла нет, то он создается.
			if (-Not (Test-Path $PathLogFile)) {
				[void](New-Item -Path "C:\Users\Администратор\Documents\" -Name "TempLog.txt" -ItemType File)
			}

			# Ввод сервера 1С для подключения к кластеру.
			while ($true) {
				echo ""
				Write-Host " Введите имя сервера для подключения к кластеру 1С" -ForegroundColor Yellow
				Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
				Write-Host " SRV-1C-01" -ForegroundColor Gray
				Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
				Write-Host " Exit" -ForegroundColor Cyan
				[string]$InputServer1С = (Read-Host " Сервер").ToUpper()

				# Контроль ввода сервера.
				if ($InputServer1С -like $env:COMPUTERNAME) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОК" -ForegroundColor Green

					# Выбор компаненты 1С.
					while ($true) {
						echo ""
						Write-Host " Выберите компаненту 1С" -ForegroundColor Yellow
						Write-Host " 1." -ForegroundColor Cyan -NoNewline
						Write-Host " V82.COMConnector" -ForegroundColor Gray
						Write-Host " 2." -ForegroundColor Cyan -NoNewline
						Write-Host " V83.COMConnector" -ForegroundColor Gray
						Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
						Write-Host " Exit" -ForegroundColor Cyan
						$InputCOM1С = Read-Host " Выбор"

						try {
							# Компанента V82.COMConnector.
							if ($InputCOM1С -eq 1) {
								# Создается COM-объект подключения к 1С.
								$Connector = New-Object -Comobject "V82.COMConnector"
								if ($Connector) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОК" -ForegroundColor Green
									$Flag = 1
									break
								}
							}
							# Компанента V83.COMConnector.
							elseif ($InputCOM1С -eq 2) {
								# Создается COM-объект подключения к 1С.
								$Connector = New-Object -Comobject "V83.COMConnector"
								if ($Connector) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОК" -ForegroundColor Green
									$Flag = 1
									break
								}
							}
							# Выход.
							elseif ($InputCOM1С -like "exit"){
								break
							}
							# Ошибка.
							elseif ($InputCOM1С -like $null){
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " Введено пустое значение."
							}
							# Ошибка.
							else {
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " Неверно введена команда."
							}
						}
						catch {
							if ($InputCOM1С -eq 1) {
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " Компонента" -NoNewline
								Write-Host " V82.COMConnector" -ForegroundColor Gray -NoNewline
								Write-Host " Не зарегистрирована"
							}
							elseif ($InputCOM1С -eq 2) {
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " Компонента" -NoNewline
								Write-Host " V83.COMConnector" -ForegroundColor Gray -NoNewline
								Write-Host " Не зарегистрирована"
							}
						}
					}
					Clear-Variable -Name "InputCOM1С"
					break
				}
				# Выход.
				elseif ($InputServer1С -like "exit") {
					break
				}
				# Ошибка.
				elseif ($InputServer1С -like $null) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Введено пустое значение."
				}
				# Ошибка.
				else {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Имя сервера 1С" -NoNewline
					Write-Host " $InputServer1С" -ForegroundColor Gray -NoNewline
					Write-Host " не соответствует имени сервера введённого для отправки скрипт-блока."
				}
			}

			# Ввод порта сервера 1С для подключения к кластеру.
			if ($Flag -eq 1) {
				Clear-Variable -Name "Flag"
				while ($true) {
					echo ""
					Write-Host " Введите порт сервера" -ForegroundColor Yellow
					Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
					Write-Host " 1740" -ForegroundColor Gray
					Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
					Write-Host " Exit" -ForegroundColor Cyan
					[string]$InputPort1C = (Read-Host " Порт").ToLower()

					# Выход.
					if ($InputPort1C -like "exit") {
						break
					}
					# Ошибка.
					elseif ($InputPort1C -like $null) {
						echo ""
						Start-Sleep -Milliseconds 500
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " Введено пустое значение."
					}
					# Проверка порта.
					else {
						[int]$tmpInputPort = $InputPort1C
						if (Get-NetTCPConnection | Where-Object {$_.Localport -eq $tmpInputPort}){
							try {
								$Server1C = $InputServer1С+":"+$InputPort1C
								# Подключение к агенту на сервере.
								$AgentConnection = $Connector.ConnectAgent($Server1C)
								if ($AgentConnection) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОК" -ForegroundColor Green
									$Flag = 2
									break
								}
							}
							catch {
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " $($Error[0])"
							}
						}
						else {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
							Write-Host " Порт" -NoNewline
							Write-Host " $InputPort1C" -ForegroundColor Gray -NoNewline
							Write-Host " не верный."
						}
					}
				}
			}

			# Удаление активных сессий 1С.
			if ($Flag -eq 2) {
				echo ""
				Start-Sleep -Milliseconds 500

				# Сейчас используется только один кластер, поэтому просто получаем единственный элемент.
				$Cluster = $AgentConnection.GetClusters()[0]
				# Авторизация.
				$AgentConnection.Authenticate($Cluster,"","")
				# Для заданного списка баз в цикле получаем списки сессий и обрабатываем их.
				$Bases = $AgentConnection.GetInfoBases($Cluster)

				if ($Bases.count -ne 0) {
					$GetDate = (Get-Date).ToString()
					Write-Host " Текущая дата:" -ForegroundColor Yellow -NoNewline
					Write-Host ""$GetDate
					Add-Content -Path $PathLogFile -Value ("[$InputServer1С][$GetDate]")

					# Если необходимо закрыть активные сеансы более 10 часов, то необходимо указать значение: -10
					$TimeDelay = 0
					# Всего активных сеансов пользователей во всех базах.
					$Sessions1C = ($AgentConnection.GetSessions($Cluster) | Where-Object {$_.AppId -ne "SrvrConsole" -and $_.AppId -ne "BackgroundJob" })

					echo ""
					Write-Host " Активные сеансы в кластере 1С" -ForegroundColor Cyan
					# Общее число пользователей.
					$IntUsersCount = 0
					foreach ($Session1С in $Sessions1C) {
						Write-Host " Active Session" -ForegroundColor Green -NoNewline 
						Write-Host " "$Session1С.userName.ToString() -NoNewline 
						Write-Host " "$Session1С.infoBase.Name.ToString() -ForegroundColor Gray
						$AllSession = "Active Session ‘" + $Session1С.userName.ToString()+" - "+$Session1С.infoBase.Name.ToString()
						Add-Content -Path $PathLogFile -Value ($AllSession) -Encoding UTF8
						$IntUsersCount ++
					}

					# Пользовательский выбор.
					while ($true) {
						echo ""
						Start-Sleep -Milliseconds 500
						Write-Host " Отключить все активные сеансы или из определёных баз 1С?" -ForegroundColor Yellow
						Write-Host " 1." -ForegroundColor Cyan -NoNewline
						Write-Host " Из определённых баз" -ForegroundColor Yellow
						Write-Host " 2." -ForegroundColor Cyan -NoNewline
						Write-Host " Все сеансы" -ForegroundColor Yellow
						Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
						Write-Host " Exit" -ForegroundColor Cyan
						$InputSession = Read-Host " Выбор"

						# Из определённых баз.
						if ($InputSession -eq 1) {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " OK" -ForegroundColor Green
							$Flag = 3
							break
						}
						# Все сеансы.
						elseif ($InputSession -eq 2){
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " OK" -ForegroundColor Green
							$Flag = 4
							break
						}
						# Выход.
						elseif ($InputSession -like "exit") {
							echo ""
							Write-Verbose "Произведена запись в лог активных сессий" -Verbose
							break
						}
						# Ошибка.
						elseif ($InputSession -like $null) {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
							Write-Host " Введено пустое значение."
						}
						# Ошибка.
						else {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
							Write-Host " Неверно введена команда."
						}
					}

					# Из определённых баз.
					if ($Flag -eq 3) {
						Clear-Variable -Name "Flag"
						Start-Sleep -Milliseconds 500

						Write-Host " Вводите имя базы по одному" -ForegroundColor Yellow
						Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
						Write-Host " Basatk_test" -ForegroundColor Gray
						Write-Host " Для завершения введите:" -ForegroundColor Yellow -NoNewline
						Write-Host " end" -ForegroundColor Gray

						$Bases1C = [System.Collections.ArrayList]@() 
						[string]$InputBase1C = ""

						# Ввод баз 1С по одному.
						while ($InputBase1C -notlike "end") {
							[string]$InputBase1C = (Read-Host " База").ToLower()

							if ($InputBase1C -notlike "end") {
								$Bases1C.Add($InputBase1C)
							}
							else {
								[string]$InputBase1C = "end"
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " OK" -ForegroundColor Green
								echo ""
							}
						}

						Write-Host " Список введённых баз:" -ForegroundColor Yellow
						foreach ($i in $Bases1C) {
							Write-Host " "$i
						}

						echo ""
						Start-Sleep -Milliseconds 500

						foreach ($Base in $Bases1C) {

							$Sessions1CtoTerminate = ($AgentConnection.GetSessions($Cluster) | Where-Object {$_.Infobase.Name -eq $Base -and $_.AppId -ne "SrvrConsole" -and $_.AppId -ne "BackgroundJob" -and $_.StartedAt -lt ((Get-Date).AddHours($TimeDelay))})

							foreach ($Session in $Sessions1CtoTerminate) {
								Write-Host " Terminated Session " -ForegroundColor Red -NoNewline
								Write-Host " "$Session.infoBase.Name.ToString() -ForegroundColor Yellow -NoNewline
								Write-Host " "$Session.userName.ToString() -NoNewline 
								Write-Host " "$Session.Host.ToString() -NoNewline
								Write-Host " "$Session.AppID.ToString() -NoNewline
								Write-Host " "$Session.StartedAt.ToString() -NoNewline
								Write-Host " -"$Session.LastActiveAt.ToString() -NoNewline
								Write-Host " has been terminated at"(Get-Date).ToString()

								$SessionToKillMsg = "Terminated Session ‘" + $Session.infoBase.Name.ToString() + " — " + $Session.userName.ToString() + " — " + $Session.Host.ToString() + " — " + $Session.AppID.ToString() + " — " + $Session.StartedAt.ToString() + " — " + $Session.LastActiveAt.ToString() + "‘ has been terminated at "
								Add-Content -Path $PathLogFile -Value ($SessionToKillMsg) -Encoding UTF8

								# Отключаем сеансы которые "время начала" больше $TimeDelay часов.
								$AgentConnection.TerminateSession($Cluster,$Session)
							}
						}
						$Bases1C.Clear()
						Clear-Variable -Name "SessionToKillMsg"
						Clear-Variable -Name "InputBase1C"
						Clear-Variable -Name "AllSession"
					
					}
					# Все сеансы.
					elseif ($Flag -eq 4) {
						Clear-Variable -Name "Flag"
						Start-Sleep -Milliseconds 500

						foreach ($BaseAll in $Bases) {
							$Base = $BaseAll.Name
							$Sessions1CtoTerminate = ($AgentConnection.GetSessions($Cluster) | Where-Object {$_.Infobase.Name -eq $Base -and $_.AppId -ne "SrvrConsole" -and $_.AppId -ne "BackgroundJob" -and $_.StartedAt -lt ((Get-Date).AddHours($TimeDelay))})

							foreach ($Session in $Sessions1CtoTerminate) {
								Write-Host " Terminated Session " -ForegroundColor Red -NoNewline
								Write-Host " "$Session.infoBase.Name.ToString() -ForegroundColor Yellow -NoNewline
								Write-Host " "$Session.userName.ToString() -NoNewline 
								Write-Host " "$Session.Host.ToString() -NoNewline
								Write-Host " "$Session.AppID.ToString() -NoNewline
								Write-Host " "$Session.StartedAt.ToString() -NoNewline
								Write-Host " -"$Session.LastActiveAt.ToString() -NoNewline
								Write-Host " has been terminated at"(Get-Date).ToString()

								$SessionToKillMsg = "Terminated Session ‘" + $Session.infoBase.Name.ToString() + " — " + $Session.userName.ToString() + " — " + $Session.Host.ToString() + " — " + $Session.AppID.ToString() + " — " + $Session.StartedAt.ToString() + " — " + $Session.LastActiveAt.ToString() + "‘ has been terminated at "
								Add-Content -Path $PathLogFile -Value ($SessionToKillMsg) -Encoding UTF8

								# Отключаем сеансы которые "время начала" больше $TimeDelay часов.
								$AgentConnection.TerminateSession($Cluster,$Session)
							}
						}
						Clear-Variable -Name "Base"
						Clear-Variable -Name "SessionToKillMsg"
						Clear-Variable -Name "AllSession"
					
					}
					Clear-Variable -Name "InputPort1C"
					Clear-Variable -Name "GetDate"
					Clear-Variable -Name "TimeDelay"
					Clear-Variable -Name "IntUsersCount"
				}
				else {
					echo ""
					Write-Verbose "Активных сессий нет" -Verbose
				}
				Clear-Variable -Name "Bases"
			}
			Clear-Variable -Name "InputServer1С"
		}
		else {
			echo ""
			Write-Verbose "Не установлен продукт 1С:Предприятие 8" -Verbose
		}
	}

	try {
		# Отправка лог файла в директорию откуда запускался скрипт.
		if (Test-Path "\\$($Server)\C$\Users\Администратор\Documents\TempLog.txt" -ErrorAction stop) {

			if ($Path.StartsWith($Path[0]+$Path[1])) {
				[string]$Comp = $env:COMPUTERNAME
				$Target = $Path.Replace("$Path[0]+$Path[1]", "\\$Comp\$Path[0]$")
			}

			$Source  = "\\$($Server)\C$\Users\Администратор\Documents\TempLog.txt"
			Copy-Item -Path $Source -Destination $Target
			Start-Sleep -Seconds 1
			$TempLog = "TempLog.txt"

			if (Test-Path $Target$TempLog -ErrorAction Stop) {
				
				Remove-Item -Path $Source -Force
				[string]$GetAdminName = (Get-ADUser $env:USERNAME -Properties *).SamAccountName
				$GetContentLogFile = (Get-Content $Target$TempLog).Trim()

				foreach ($Line in $GetContentLogFile) {
					if (($Line).Contains("[") -and (-Not($Line).Contains("adm"))) {
						$NewLine = $Line.Replace($Line, $Line+"[$GetAdminName]")
					}
				}

				Clear-Variable -Name "Line"
				$LocalLog = "LocalLog.txt"
				[void](New-Item -Path $Target -ItemType File -Name "LocalLog.txt")
				$NewLine | Set-Content -Path $Target$LocalLog

				foreach ($Line in $GetContentLogFile) {
					if ((-Not($Line).StartsWith("[")) -and (-Not($Line).Contains("adm"))) {
						Add-Content -Path $Target$LocalLog -Value("$Line")
					}
				}

				Clear-Variable -Name "Line"
				Clear-Variable -Name "GetContentLogFile"
				Start-Sleep -Milliseconds 500
				$Log = "log.txt" 

				if (-Not(Test-Path $Target$Log -ErrorAction Stop)) {
					$GetContentLogFile = (Get-Content $Target$LocalLog).Trim()
					[void](New-Item -Path $Target -ItemType File -Name "log.txt")

					foreach ($Line in $GetContentLogFile) {
						Add-Content -Path $Target$Log -Value("$Line")
					}
					Start-Sleep -Milliseconds 500

					if (Test-Path $Target$Log -ErrorAction Stop) {
						Remove-Item -Path $Target$TempLog -Force
						Remove-Item -Path $Target$LocalLog -Force
					}
				}
				else {
					$GetContentLogFile = (Get-Content $Target$LocalLog).Trim()
					Add-Content -Path $Target$Log -Value("")

					foreach ($Line in $GetContentLogFile) {
						Add-Content -Path $Target$Log -Value("$Line")
					}
					Start-Sleep -Milliseconds 500
					Remove-Item -Path $Target$TempLog -Force
					Remove-Item -Path $Target$LocalLog -Force
				}
			}
			Clear-Variable -Name "GetAdminName"
			Clear-Variable -Name "Source"
			Clear-Variable -Name "Target"

			#[void]($shell = New-Object -ComObject Wscript.Shell)
			#[void]($shell.popup("Ура всё получилось", 0, "Результат", 0 + 64 + 4096))
		}
	}
	catch {
		echo ""
	}
	Clear-Variable -Name "Server"
	Clear-Variable -Name "Path"
}

# Функция 8. Удаление сервера и сужбы 1С.
function Remove-Server1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Отправка скрипт-блока.
	Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {
		
		function Product-1C() {
			[CmdletBinding()]
			param (
				[Parameter(Mandatory = $true)]
				[string] $Number
			)

			for ($a = 1; $a -lt $ArrayProduct1C.Count + 1; $a ++) {
				if ($Number -eq $a) {
					return $ArrayProduct1C[$a-1]
				}
			}
		}

		if (Get-Service | Where-Object {($_.Name).StartsWith("1C")}) {

			$ArrayProduct1C = [System.Collections.ArrayList]@()
			$GetProduct1C	= Get-WmiObject Win32_Product | Where-Object {($_.Name).StartsWith("1С:Предприятие")} | ForEach-Object {$ArrayProduct1C.Add($_.Name)}

			while ($true) {
				echo ""
				Write-Host " Выберите продукт" -ForegroundColor Yellow
				for ($i = 1; $i -lt $ArrayProduct1C.Count + 1; $i ++) {
					Write-Host " $($i)." -ForegroundColor Cyan -NoNewline
					Write-Host " $($ArrayProduct1C[$i-1])" -ForegroundColor Gray
				}
				Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
				Write-Host " Exit" -ForegroundColor Cyan
				$InputProduct = (Read-Host " Выбор").ToLower()

				# Если продукт 1С.
				if (($InputProduct -ge 1) -and ($InputProduct -le $ArrayProduct1C.Count)) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОК" -ForegroundColor Green

					[string]$NameProduct1C = Product-1C -Number $InputProduct
					$SplitNameProduct1C = $NameProduct1C.Split(" ")
					$ReplaceSplitNameProduct1C = $SplitNameProduct1C[3].Replace("(", "").Replace(")", "")

					$NameService1C = (Get-WmiObject win32_service | Where-Object {$_.PathName -match $ReplaceSplitNameProduct1C}).Name

					Stop-Service $NameService1C -Force -ErrorAction Stop -WarningAction SilentlyContinue

					$NameService1CStatus = (Get-Service $NameService1C).Status
					while ($true) {
						if ($NameService1CStatus -like "Stopped") {
							# Удаление службы 1С.
							if (Get-WmiObject win32_service | Where-Object {$_.PathName -match $ReplaceSplitNameProduct1C}) {
								echo ""
								Write-Verbose "Запущено удаление службы" -Verbose
								Start-Sleep -Milliseconds 500
								[void]((Get-WmiObject win32_service | Where-Object {$_.PathName -match $ReplaceSplitNameProduct1C}).delete())

								$UninstallServiceStatus = [void](Get-WmiObject win32_service | Where-Object {$_.PathName -match $ReplaceSplitNameProduct1C})
								while ($true) {
									# Удаление продукта 1С.
									if (-Not(Get-WmiObject win32_service | Where-Object {$_.PathName -match $ReplaceSplitNameProduct1C})) {
										echo ""
										Write-Host " Служба $($NameService1C)" -NoNewline
										Write-Host " Удалёна" -ForegroundColor Green
											
										Start-Sleep -Milliseconds 500

										echo ""
										Write-Verbose "Запущено удаление продукта" -Verbose
										Start-Sleep -Milliseconds 500
										[void]((Get-WmiObject Win32_Product -Filter "Name ='$($NameProduct1C)'").Uninstall())

										$UninstallProductStatus = [void](Get-WmiObject Win32_Product -Filter "Name ='$($NameProduct1C)'")
										while ($true) {
											if (-Not(Get-WmiObject Win32_Product -Filter "Name ='$($NameProduct1C)'")) {
												echo ""
												Write-Host " Продукт $($NameProduct1C)" -NoNewline
												Write-Host " Удалён" -ForegroundColor Green
												break
											}
											else {
												$UninstallProductStatus = [void](Get-WmiObject Win32_Product -Filter "Name ='$($NameProduct1C)'")
											}
										}
										break
									}
									else {
										$UninstallServiceStatus = [void](Get-WmiObject win32_service | Where-Object {$_.PathName -match $ReplaceSplitNameProduct1C})
									}
								}
								break
							}
						}
						else {
							$NameService1CStatus = (Get-Service $NameService1C).Status
						}
					}
					break
				}
				# Выход.
				elseif ($InputProduct -like "exit") {
					break
				}
				# Ошибка.
				elseif ($InputProduct -like $null) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Введено пустое значение."
				}
				# Ошибка.
				else {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Неверно введена команда."
				}
			}
		}
		else {
			echo ""
			Write-Verbose "Не установлен продукт 1С:Предприятие 8" -Verbose
		}
	}
	Clear-Variable -Name "Server"
}

# Функция 9. Установка сервера и службы 1С.
function Install-Server1C() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string] $Server
	)

	# Функция копирования папки.
	function Copy-Folder {
		[CmdletBinding()]
		param (
			[Parameter(Mandatory = $true)]
			[string] $Source
			,
			[Parameter(Mandatory = $true)]
			[string] $Destination
			,
			[Parameter(Mandatory = $true)]
			[string] $LogPath
			,
			[int] $Gap = 200
			,
			[int] $ReportGap = 2000
		)
		# Регулярное выражение, которое будет собирать количество скопированных байтов.
		$RegexBytes = "(?<=\s+)\d+(?=\s+)"

		# Robocopy параметры.
		# /MIR	 - создать зеркало дерева папок.
		# /NP	 - без хода процесса — не отображать число скопированных %.
		# /NS	 - без размера — не заносить в журнал размер файлов.
		# /NDL	 - без списка папок — не заносить в журнал имена папок.
		# /Z	 – продолжит копирование файла при обрыве. Полезно при копировании больших файлов.
		# /R:n	 - число повторных попыток для неудавшихся копий: по умолчанию — 1 миллион.
		# /W:n	 - время ожидания между повторными попытками: по умолчанию — 30 секунд.
		# /BYTES - показывает размеры файлов в байтах.
		# /NJH	 - без заголовка задания.
		# /NJS	 - без сведений о задании.
		# /TEE	 – разделение вывода работы команды и в лог файл, и в консоль.
		$CommonRobocopyParams = "/MIR /NP /NC /NDL /Z /R:3 /W:3 /BYTES /NJH /NJS /TEE"

		# Установки Robocopy.
		Write-Verbose -Message "Анализ работы Robocopy"
		$StagingLogPath = '{0}\{1}_Robocopy_анализ.log' -f $LogPath, (Get-Date -Format "yyyy-MM-dd HH-mm-ss")

		$StagingArgumentList = '"{0}" "{1}" /LOG:"{2}" /L {3}' -f $Source, $Destination, $StagingLogPath, $CommonRobocopyParams
		Start-Process -Wait -FilePath robocopy.exe -ArgumentList $StagingArgumentList -NoNewWindow

		# Получение общего количества файлов, которые будут скопированы.
		$StagingContent = Get-Content -Path $StagingLogPath
		$TotalFileCount = $StagingContent.Count - 1

		# Получение общего количества байтов, которые необходимо скопировать.
		[RegEx]::Matches(($StagingContent -join "`n"), $RegexBytes) | % { $BytesTotal = 0 } { $BytesTotal += $_.Value }
		Write-Verbose -Message ("Общее количество: {0} Mb" -f [math]::Round($BytesTotal/1Mb))

		# Запуск процесса Robocopy.
		$RobocopyLogPath = '{0}\{1}_Robocopy.log' -f $LogPath, (Get-Date -Format "yyyy-MM-dd HH-mm-ss")
		$ArgumentList = '"{0}" "{1}" /LOG:"{2}" /ipg:{3} {4}' -f $Source, $Destination, $RobocopyLogPath, $Gap, $CommonRobocopyParams
		#Write-Verbose -Message ("Параметры копирования: {0}" -f $ArgumentList)
		Write-Verbose -Message "Выполняется копирование"
		$Robocopy = Start-Process -FilePath robocopy.exe -ArgumentList $ArgumentList -Verbose -PassThru -NoNewWindow
		Start-Sleep -Milliseconds 100

		# Цикл прогресс-бара.
		while (!$Robocopy.HasExited) {
			Start-Sleep -Milliseconds $ReportGap
			$BytesCopied     = 0;
			$LogContent      = Get-Content -Path $RobocopyLogPath
			$BytesCopied     = [Regex]::Matches($LogContent, $RegexBytes) | ForEach-Object -Process { $BytesCopied += $_.Value } -End { $BytesCopied }
			$CopiedFileCount = $LogContent.Count - 1
			#Write-Verbose -Message ("Байт скопировано: {0}" -f $BytesCopied)
			#Write-Verbose -Message ("Файлов скопировано: {0}" -f $LogContent.Count)
			$Percentage = 0
			if ($BytesCopied -gt 0) {
				$Percentage = (($BytesCopied/$BytesTotal)*100)
			}
			#Write-Progress -Activity Robocopy -Status ("Скопировано {0} из {1} файлов; {2} из {3} мегабайт" -f $CopiedFileCount, $TotalFileCount, [math]::Round($BytesCopied/1Mb), [math]::Round($BytesTotal/1Mb)) -PercentComplete $Percentage
		}
		Write-Verbose -Message "Копирование завершено"
		<# Функция вывода информации.
		[PSCustomObject]@{
			BytesCopied = $BytesCopied
			FilesCopied = $CopiedFileCount
		}#>
		# Очистка переменной $Source от полученного значения.
		Clear-Variable -Name "Source"
		# Очистка переменной $Destination от полученного значения.
		Clear-Variable -Name "Destination"
		[System.Console]::Read() | Out-Null
	}

	# Функция установка сервера 1С.
	function Install-Server() {
		[CmdletBinding()]
		param (
			[Parameter(Mandatory = $true)]
			[string] $Server1C
		)

		# Отправка скрипт-блока.
		Invoke-Command -ComputerName $Server1C -ErrorAction Stop -ScriptBlock {

			# Функция установки службы 1С.
			function Install-Service1C() {

				# Функция получения версии 1С.
				function Version-1C() {
					[CmdletBinding()]
					param (
						[Parameter(Mandatory = $true)]
						[string] $Number
					)

					for ($a = 1; $a -lt $ArrayPackage1C.Count + 1; $a ++) {
						if ($Number -eq $a) {
							return $ArrayPackage1C[$a-1]
						}
					}
				}

				$ArrayPackage1C = [System.Collections.ArrayList]@()
				$GetPackageSource = (Get-Package | Where-Object {($_.Name -match "1С:Предприятие 8") -and ($_.Source -notmatch "(x86)")}).Source | 
					ForEach-Object {
						[string]$tmpPackage = $_
						$tmpSplitPackage = $tmpPackage.Split("\")
						$ArrayPackage1C.Add($tmpSplitPackage[3])
				}

				while ($true) {
					echo ""
					Write-Host " Выберите версию" -ForegroundColor Yellow
					for ($i = 1; $i -lt $ArrayPackage1C.Count + 1; $i ++) {
						Write-Host " $($i)." -ForegroundColor Cyan -NoNewline
						Write-Host " $($ArrayPackage1C[$i-1])" -ForegroundColor Gray
					}
					Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
					Write-Host " Exit" -ForegroundColor Cyan
					$UserInputPackage = (Read-Host " Выбор").ToLower()

					if (($UserInputPackage -ge 1) -and ($UserInputPackage -le $ArrayPackage1C.Count)) {

						$FlagPorts = 0

						# Ввод порта для сервера.
						while ($true) {
							echo ""
							Write-Host " Введите порт для сервера" -ForegroundColor Yellow
							Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
							Write-Host " 1740" -ForegroundColor Gray
							Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
							Write-Host " Exit" -ForegroundColor Cyan
							$InputPort = (Read-Host " Порт сервера").ToLower()

							# Проверка порта для сервера.
							if (($InputPort -notlike "exit") -and ($InputPort -notlike $null)) {

								try {
									[int]$tmpInputPort = $InputPort
									if (-Not(Get-NetTCPConnection | Where-Object {$_.Localport -eq $tmpInputPort})){
										echo ""
										$FlagPorts ++
										Start-Sleep -Milliseconds 500
										Write-Host " OK" -ForegroundColor Green
										break
									}
									else {
										echo ""
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " Порт для сервера" -NoNewline
										Write-Host " $($tmpInputPort)" -ForegroundColor Gray -NoNewline
										Write-Host " занят."
									}
								}
								catch {
									echo ""
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " $($Error[0])"
								}
							}
							# Выход.
							elseif ($InputPort -like "exit") {
								break
							}
							# Ошибка.
							elseif ($InputPort -like $null) {
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " Введено пустое значение."
							}
						}

						# Ввод порта для кластера.
						while ($true) {
							echo ""
							Write-Host " Введите порт для кластера" -ForegroundColor Yellow
							Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
							Write-Host " 1741" -ForegroundColor Gray
							Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
							Write-Host " Exit" -ForegroundColor Cyan
							$InputRegPort = (Read-Host " Порт кластера").ToLower()

							# Проверка порта для кластера.
							if (($InputRegPort -notlike "exit") -and ($InputRegPort -notlike $null)) {

								try {
									[int]$tmpInputRegPort = $InputRegPort
									if (-Not(Get-NetTCPConnection | Where-Object {$_.Localport -eq $tmpInputRegPort})){
										echo ""
										$FlagPorts ++
										Start-Sleep -Milliseconds 500
										Write-Host " OK" -ForegroundColor Green
										break
									}
									else {
										echo ""
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " Порт для кластера" -NoNewline
										Write-Host " $($tmpInputRegPort)" -ForegroundColor Gray -NoNewline
										Write-Host " занят."
									}
								}
								catch {
									echo ""
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " $($Error[0])"
								}
							}
							# Выход.
							elseif ($InputRegPort -like "exit") {
								break
							}
							# Ошибка.
							elseif ($InputRegPort -like $null) {
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " Введено пустое значение."
							}
						}

						# Ввод диапазон портов для процессов.
						while ($true) {
							echo ""
							Write-Host " Введите диапазон портов для процессов" -ForegroundColor Yellow
							Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
							Write-Host " 1760:1791" -ForegroundColor Gray
							Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
							Write-Host " Exit" -ForegroundColor Cyan
							$InputRangePort = Read-Host " Диапазон портов"
							 
							# Проверка диапазона портов для процессов.
							if (($InputRangePort -notlike "exit") -and ($InputRangePort -notlike $null)) {
								if ($InputRangePort -match ":") {
									
									$tmp = $InputRangePort.Split(":")

									try {
										[int]$tmp1 = $tmp[0]
										[int]$tmp2 = $tmp[1]
										$tmpRange  = $tmp1..$tmp2

										$tmpCount = 0
										foreach ($i in $tmpRange) {

											if (-NOt(Get-NetTCPConnection | Where-Object {$_.Localport -eq $i})) {
												$tmpCount ++
											}
											else {
												echo ""
												Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
												Write-Host " Порт для процессов" -NoNewline
												Write-Host " $($i)" -ForegroundColor Gray -NoNewline
												Write-Host " занят."
											}
										}
										if ($tmpRange.count -eq $tmpCount) {
											echo ""
											$FlagPorts ++
											Start-Sleep -Milliseconds 500
											Write-Host " OK" -ForegroundColor Green
											break
										}
									}
									catch {
										echo ""
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " $($Error[0])"
									}
								}
								# Ошибка.
								else {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Неверно указан диапазон. Смотри пример."
								}
							}
							# Выход.
							elseif ($InputRangePort -like "exit") {
								break
							}
							# Ошибка.
							elseif ($InputRangePort -like $null) {
								echo ""
								Start-Sleep -Milliseconds 500
								Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
								Write-Host " Введено пустое значение."
							}
						}

						if ($FlagPorts -eq 3) {

							# Ввод учётной записи от имени которой будет работаь служба 1С.
							while ($true) {
								echo ""
								Write-Host " Введите доменную учётную запись от имени которой будет работать служба 1С" -ForegroundColor Yellow
								Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
								Write-Host " domen\User1C" -ForegroundColor Gray
								Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
								Write-Host " Exit" -ForegroundColor Cyan
								[string]$InputUser = (Read-Host " Введите учётную запись").ToLower()

								# Проверка учётной записи от имени которой будет работаь служба 1С.
								if ($InputUser -match "\\") {
									try {
										echo ""
										Write-Verbose "Введите учётную запись доменного администратора для соединения с Active Directory" -Verbose
										Start-Sleep -Milliseconds 500
										$CredsAD = [void](Get-Credential)
										$SplitInputUser = $InputUser.Split("\")
										if (Get-ADUser $SplitInputUser[1] -Credential $CredsAD) { 
											echo ""
											Start-Sleep -Milliseconds 500
											Write-Host " OK" -ForegroundColor Green

											while ($true) {
												echo ""
												Write-Host " Введите пароль от учётной записи" -ForegroundColor Yellow -NoNewline
												Write-Host " $($InputUser)" -ForegroundColor Gray
												echo ""
												$InputPassword = Read-Host " Введите пароль от учётной записи '$($InputUser)'" -AsSecureString

												if ($InputPassword) {
													echo ""
													Start-Sleep -Milliseconds 500
													Write-Host " OK" -ForegroundColor Green
													break
												}
											}
										}
										break
									}
									catch {
										echo " "
										Clear-Variable -Name "InputUser"
										Start-Sleep -Milliseconds 500
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " Учётная запись" -NoNewline
										Write-Host " $($SplitInputUser[1])" -ForegroundColor Gray -NoNewline
										Write-Host " не существует."
									}
								}
								# Выход.
								elseif ($InputUser -like "exit") {
									break
								}
								# Ошибка.
								elseif ($InputUser -like $null) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Введено пустое значение."
									Clear-Variable -Name "InputUser"
								}
								# Ошибка.
								else {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Не введен домен. Смотри пример."
									Clear-Variable -Name "InputUser"
								}
							}

							# Ввод пути для рабочих процессов.
							while($true) {
								echo ""
								Write-Host " Введите полный путь где будут храниться рабочие процессы" -ForegroundColor Yellow
								Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
								Write-Host " D:\srvinfo_1740" -ForegroundColor Gray
								Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
								Write-Host " Exit" -ForegroundColor Cyan
								$InputPathJobProcess = (Read-Host " Путь").ToLower()

								# Проверка указанного пути для рабочих процессов.
								if ($InputPathJobProcess -match ":"+"\\") {

									try {
										# Проверка наличия папки куда был скопирован дистрибутив 1С.
										if (Test-Path "$($InputPathJobProcess)" -ErrorAction Stop) {
											$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($InputUser,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
											$parentACL  = Get-Acl -Path $InputPathJobProcess
											$parentACL.SetAccessRule($AccessRule)
											Set-Acl -Path $InputPathJobProcess -AclObject $parentACL
											echo ""
											Start-Sleep -Milliseconds 500
											Write-Host " OK" -ForegroundColor Green
											break
										}
										# Ошибка.
										else {
											[void](New-Item $InputPathJobProcess -ItemType Directory)
											$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($InputUser,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
											$parentACL  = Get-Acl -Path $InputPathJobProcess
											$parentACL.SetAccessRule($AccessRule)
											Set-Acl -Path $InputPathJobProcess -AclObject $parentACL
											echo ""
											Start-Sleep -Milliseconds 500
											Write-Host " OK" -ForegroundColor Green
											break
										}
									}
									catch {
										echo ""
										Start-Sleep -Milliseconds 500
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " $($Error[0])"
									}
								}
								# Выход.
								elseif ($InputPathJobProcess -like "exit") {
									break
								}
								# Ошибка.
								elseif ($InputPathJobProcess -like $null) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Введено пустое значение."
								}
								# Ошибка.
								else {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Неверно указан путь. Смотри пример."
								}
							}

							# Удаление кэш-папки рабочих процессов.
							if (Test-Path "$($InputPathJobProcess)\reg_$($InputRegPort)" -ErrorAction Stop) {
								$GetFolderCash1C = Get-ChildItem "$($InputPathJobProcess)\reg_$($InputRegPort)"
								if ($GetFolderCash1C.Name.StartsWith("snccntx")) {
									$tmpName   = $GetFolderCash1C.Name.StartsWith("snccntx")
									$tmpFolder = Get-Item "$($InputPathJobProcess)\reg_$($InputRegPort)\$($tmpName)"
									$tmpFolder | Remove-Item -Force -Recurse
									$RemoveFolderStatus = Test-Path "$($InputPathJobProcess)\reg_$($InputRegPort)\$($tmpName)" -ErrorAction Stop
									while ($true) {
										if (-Not($RemoveFolderStatus)) {
											break
										}
										else {
											$RemoveFolderStatus = Test-Path "$($InputPathJobProcess)\reg_$($InputRegPort)\$($tmpName)" -ErrorAction Stop
										}
									}
								}
							}

							$Package = Version-1C -Number $UserInputPackage

							[string]$PackageSource = (Get-Package | Where-Object {($_.Name -match "1С:Предприятие 8") -and ($_.Source -notmatch "(x86)") -and ($_.Source -match $Package)}).Source
							[string]$PackageName   = (Get-Package | Where-Object {($_.Name -match "1С:Предприятие 8") -and ($_.Source -notmatch "(x86)") -and ($_.Source -match $Package)}).Name

							$SplitPackageSource  = $PackageSource.Split("\")
							$SplitPackageSource1 = $SplitPackageSource[3].Split(".")
							$SplitPackageName    = $PackageName.Split(" ")

							$HomeCat     = "$($InputPathJobProcess)\"
							$PathToBin   = "$($PackageSource)Bin\ragent.exe"
							$Name        = "1C:Enterprise $($SplitPackageSource1[0]).$($SplitPackageSource1[1]) Server Agent ($($InputPort))"
							$ImagePath   = "`"$PathToBin`" -srvc -agent -regport $InputRegPort -port $InputPort -range $InputRangePort -debug -d `"$HomeCat`""
							$Desctiption = "Агент сервера $($SplitPackageName[0]) $($SplitPackageSource1[0]).$($SplitPackageSource1[1]) ($($InputPort))"
							$Creds       = New-Object System.Management.Automation.PSCredential -ArgumentList $InputUser, $InputPassword

							echo ""
							Write-Host " Проверьте введённый данные" -ForegroundColor Cyan
							echo ""
							Write-Host " Имя:" -ForegroundColor Yellow -NoNewline
							Write-Host " $($Name)" -ForegroundColor Gray
							Write-Host " Описание:" -ForegroundColor Yellow -NoNewline
							Write-Host " $($Desctiption)" -ForegroundColor Gray
							Write-Host " Путь к исполняемому файлу службы:" -ForegroundColor Yellow -NoNewline
							Write-Host " $($ImagePath)" -ForegroundColor Gray
							Write-Host " Имя учётной записи:" -ForegroundColor Yellow -NoNewline
							Write-Host " $($InputUser)" -ForegroundColor Gray
							Write-Host " Пароль от учётной записи:" -ForegroundColor Yellow -NoNewline
							Write-Host " $($InputPassword)" -ForegroundColor Gray

							# Проверка введённых параметров установки службы 1С.
							while ($true) {
								echo ""
								Write-Host " Данные верны?" -ForegroundColor Cyan
								Write-Host " 1." -ForegroundColor Cyan -NoNewline
								Write-Host " Да" -ForegroundColor Yellow
								Write-Host " 2." -ForegroundColor Cyan -NoNewline
								Write-Host " Нет" -ForegroundColor Yellow
								$InputUserCheck = (Read-Host " Выбор").ToLower()

								# Установка службы.
								if ($InputUserCheck -eq 1) {
									echo ""
									Write-Verbose "Установка службы $($Name)" -Verbose
									try{
										echo ""
										[void](New-Service -Name $Name -BinaryPathName $ImagePath -Description $Desctiption -DisplayName $Desctiption -StartupType Boot -Credential $Creds)
										Start-Sleep -Milliseconds 500
										Write-Host " Служба" -NoNewline
										Write-Host " $($Name)" -NoNewline
										Write-Host " Зарегистрирована" -ForegroundColor Green
										Clear-Variable -Name "InputPassword"
										break

									} 
									catch {
										echo ""
										Start-Sleep -Milliseconds 500
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " $($Error[0])"
									}
								}
								# Выход.
								elseif ($InputUserCheck -eq 2) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " Выход" -ForegroundColor Cyan
									break
								}
								# Ошибка.
								elseif ($InputUserCheck -like $null) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Введено пустое значение."
								}
								# Ошибка.
								else {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Неверно введена команда."
								}
							}
							break
						}
					}
					# Выход.
					elseif ($UserInputPackage -like "exit") {
						break
					}
					# Ошибка.
					elseif ($UserInputPackage -like $null) {
						echo ""
						Start-Sleep -Milliseconds 500
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " Введено пустое значение."
					}
					# Ошибка.
					else {
						echo ""
						Start-Sleep -Milliseconds 500
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " Неверно введена команда."
					}
				}
			}

			# Установка сервера 1С.
			while ($true) {
				echo ""
				Write-Host " Введите полный путь к дистрибутиву 1С" -ForegroundColor Yellow
				Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
				Write-Host " \\Computer\C$\Users\User\Downloads\8.3.22.2239" -ForegroundColor Gray
				Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
				Write-Host " Exit" -ForegroundColor Cyan
				$InputPathSource = (Read-Host " Путь").ToLower()

				# Проверка указанного пути куда был скопирован дистрибутив 1С.
				if ((($InputPathSource).StartsWith("\\")) -or ($InputPathSource -match ":"+"\\")) {

					try {
						# Проверка наличия папки куда был скопирован дистрибутив 1С.
						if (Test-Path "$($InputPathSource)" -ErrorAction Stop) {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " OK" -ForegroundColor Green

							while ($true) {
								echo ""
								Write-Host " Введите название пакета установщика windows в формате msi" -ForegroundColor Yellow
								Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
								Write-Host " 1CEnterprise 8 (x86-64).msi" -ForegroundColor Gray
								Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
								Write-Host " Exit" -ForegroundColor Cyan
								$InputFileMsi1C = (Read-Host " Пакет установщика windows").ToLower()
								
								# Проверка формата файла пакета установщика windows.
								if (($InputFileMsi1C).EndsWith(".msi")) {

									# Проверка наличия пакета установщика windows в папке с дистрибутивом 1С.
									if (Test-Path "$($InputPathSource)\$($InputFileMsi1C)" -ErrorAction Stop) {
										echo ""
										Start-Sleep -Milliseconds 500
										Write-Host " OK" -ForegroundColor Green

										while ($true) {
											echo ""
											Write-Host " Выберите вариант установки" -ForegroundColor Yellow
											Write-Host " 1." -ForegroundColor Cyan -NoNewline
											Write-Host " Сервер 1С"
											Write-Host " 2." -ForegroundColor Cyan -NoNewline
											Write-Host " Сервер 1С, Средства администрирования"
											Write-Host " 3." -ForegroundColor Cyan -NoNewline
											Write-Host " Сервер 1С, Средства администрирования, Толстый клиент, Тонкий клиент"
											Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
											Write-Host " Exit" -ForegroundColor Cyan
											$InputInstall1C = (Read-Host " Выбор").ToLower()

											$GetFileMsi = Get-ChildItem "$($InputPathSource)" -File | Where-Object {($_.Name) -like $InputFileMsi1C}

											# Выбор 1. Установка Cервера 1С.
											if ($InputInstall1C -eq 1) {

												msiexec /i "$($GetFileMsi.FullName)" /passive /norestart TRANSFORMS="1049.mst" INSTALLSRVRASSRVC=0 HASPInstall=no SERVER=1 SERVERCLIENT=0 DESIGNERALLCLIENTS=0 THICKCLIENT=0 THINCLIENT=0 LANGUAGES=RU THINCLIENTFILE=0 WEBSERVEREXT=0 CONFREPOSSERVER=0 CONVERTER77=0

												echo ""
												Start-Sleep -Seconds 20
												Write-Host " Сервер 1С" -NoNewline
												Write-Host " Установлен" -ForegroundColor Green

												echo ""
												Write-Host " Запущена функция установки службы 1С" -ForegroundColor Cyan

												Install-Service1C

												break
											}
											# Выбор 2. Установка Сервера 1С, Средства администрирования.
											if ($InputInstall1C -eq 2) {

												msiexec /i "$($GetFileMsi.FullName)" /passive /norestart TRANSFORMS="1049.mst" INSTALLSRVRASSRVC=0 HASPInstall=no SERVER=1 SERVERCLIENT=1 DESIGNERALLCLIENTS=1 THICKCLIENT=0 THINCLIENT=0 LANGUAGES=RU THINCLIENTFILE=0 WEBSERVEREXT=0 CONFREPOSSERVER=0 CONVERTER77=0

												echo ""
												Start-Sleep -Seconds 20
												Write-Host " Сервер 1С, Средства администрирования" -NoNewline
												Write-Host " Установлены" -ForegroundColor Green

												echo ""
												Write-Host " Запущена функция установки службы 1С" -ForegroundColor Cyan

												Install-Service1C

												break
											}
											# Выбор 3. Установка Сервера 1С, Средства администрирования, Толстый клиент, Тонкий клиент.
											elseif ($InputInstall1C -eq 3) {

												msiexec /i "$($GetFileMsi.FullName)" /passive /norestart TRANSFORMS="1049.mst" INSTALLSRVRASSRVC=0 HASPInstall=no SERVER=1 SERVERCLIENT=1 DESIGNERALLCLIENTS=1 THICKCLIENT=1 THINCLIENT=1 LANGUAGES=RU THINCLIENTFILE=0 WEBSERVEREXT=0 CONFREPOSSERVER=0 CONVERTER77=0

												echo ""
												Start-Sleep -Seconds 20
												Write-Host " Сервер 1С, Средства администрирования, Толстый клиент, Тонкий клиент" -NoNewline
												Write-Host " Установлены" -ForegroundColor Green

												echo ""
												Write-Host " Запущена функция установки службы 1С" -ForegroundColor Cyan

												Install-Service1C

												break
											}
											# Выход.
											elseif ($InputInstall1C -like "exit") {
												break
											}
											# Ошибка.
											elseif ($InputInstall1C -like $null) {
												echo ""
												Start-Sleep -Milliseconds 500
												Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
												Write-Host " Введено пустое значение."
											}
											# Ошибка.
											else {
												echo ""
												Start-Sleep -Milliseconds 500
												Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
												Write-Host " Неверно введена команда."
											}
										}
										break
									}
									# Ошибка.
									else {
										echo ""
										Start-Sleep -Milliseconds 500
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " Такого пакета установщика windows не существует."
									}
								}
								# Выход.
								elseif ($InputFileMsi1C -like "exit") {
									break
								}
								# Ошибка.
								elseif ($InputFileMsi1C -like $null) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Введено пустое значение."
								}
								# Ошибка.
								else {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Файл не является пакетом установщика windows. Смотри пример."
								}
								Clear-Variable -Name "InputFileMsi1C"
							}
							break
						}
						# Ошибка.
						else {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
							Write-Host " Путь не существует."
						}
					}
					catch {
						echo ""
						Start-Sleep -Milliseconds 500
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " $($Error[0])"
					}
				}
				# Выход.
				elseif ($InputPathSource -like "exit") {
					break
				}
				# Ошибка.
				elseif ($InputPathSource -like $null) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Введено пустое значение."
				}
				# Ошибка.
				else {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Неверно указан путь. Смотри пример."
				}
				Clear-Variable -Name "InputPathSource"
			}
		}
		Clear-Variable -Name "Server1C"
	}

	# Вариант действия.
	while ($true){
		echo ""
		Write-Host " Выберите действие" -ForegroundColor Yellow
		Write-Host " 1." -ForegroundColor Cyan -NoNewline
		Write-Host " Скопировать на сервер дистрибутив 1С"
		Write-Host " 2." -ForegroundColor Cyan -NoNewline
		Write-Host " Указать локальный путь к дистрибутиву 1С"
		Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
		Write-Host " Exit" -ForegroundColor Cyan
		$UserInput = (Read-Host " Выбор").ToLower()

		# Выбор 1. Скопировать на сервер дистрибутив 1С.
		if ($UserInput -eq 1) {

			while ($true){
				echo ""
				Write-Host " Введите полный путь к папке с дистрибутивом 1С" -ForegroundColor Yellow
				Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
				Write-Host " \\Computer\Soft1C\8.3.22.2239\windows64full_8_3_22_2239" -ForegroundColor Gray -NoNewline
				Write-Host " или" -ForegroundColor Yellow -NoNewline
				Write-Host " \\Computer\C$\Soft1C\8.3.22.2239\windows64full_8_3_22_2239" -ForegroundColor Gray
				Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
				Write-Host " Exit" -ForegroundColor Cyan
				$InputPathRoot = (Read-Host " Путь").ToLower()

				# Проверка указанного пути к папке с дистрибутивами 1С.
				if (($InputPathRoot.StartsWith("\\"))) {

					try {
						# Проверка доступа к папке с дистрибутивами 1С.
						if (Test-Path $InputPathRoot -ErrorAction Stop) {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " OK" -ForegroundColor Green

							while ($true) {
								echo ""
								Write-Host " Введите полный путь куда будет скопирован дистрибутив 1С" -ForegroundColor Yellow
								Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
								Write-Host " \\Computer\C$\Users\User\Downloads" -ForegroundColor Gray -NoNewline
								Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
								Write-Host " Exit" -ForegroundColor Cyan
								$InputPathDestination = (Read-Host " Путь").ToLower()

								# Проверка указанного пути куда будет скопирован дистрибутив 1С.
								if (($InputPathDestination).StartsWith("\\")) {

									# Проверка доступа к директории куда будет скопирован дистрибутив 1С.
									if (Test-Path $InputPathDestination -ErrorAction Stop) {
										echo ""
										Start-Sleep -Milliseconds 500
										Write-Host " OK" -ForegroundColor Green

										while ($true) { 
											echo ""
											Write-Host " Введите название папки, которая будет создана на сервере, в котрую будет скопирован дистрибутив 1С" -ForegroundColor Yellow
											Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
											Write-Host " 8.3.22.2239" -ForegroundColor Gray
											Write-Host " Для выхода введите:" -ForegroundColor Yellow -NoNewline
											Write-Host " Exit" -ForegroundColor Cyan
											$InputNameFolder = Read-Host " Имя папки"

											if (($InputNameFolder -notlike "Exit") -and ($InputNameFolder -notlike "exit") -and ($InputNameFolder -notlike $null)) {

												# Создание папки куда будет скопирован дистрибутив 1С, если её нет в указанном пути куда будет скопирован дистрибутив 1С.
												if (-Not(Test-Path "$($InputPathDestination)\$($InputNameFolder)" -ErrorAction Stop)) {
													[void](New-Item -Path $InputPathDestination -Name $InputNameFolder -ItemType Directory)
													Start-Sleep -Milliseconds 500
												}

												# Проверка наличия папки куда будет скопирован дистрибутив 1С.
												if (Test-Path "$($InputPathDestination)\$($InputNameFolder)" -ErrorAction Stop) {
													echo ""
													# Копирование дистрибутива 1С.
													Copy-Folder -Source $InputPathRoot -Destination "$($InputPathDestination)\$($InputNameFolder)" -LogPath $InputPathDestination -Verbose

													Start-Sleep -Milliseconds 500

													Install-Server -Server1C $Server

													break
												}
												# Ошибка.
												else {
													echo ""
													Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
													Write-Host " Папка " -NoNewline
													Write-Host " $($InputNameFolder)" -ForegroundColor Gray -NoNewline
													Write-Host " не создалась по указанному пути" -NoNewline
													Write-Host " $($InputPathDestination)" -ForegroundColor Gray -NoNewline
													Write-Host "."
												}
											}
											# Выход.
											elseif (($InputNameFolder -like "Exit") -or ($InputNameFolder -like "exit")) {
												break
											}
											elseif ($InputNameFolder -like $null) {
												echo ""
												Start-Sleep -Milliseconds 500
												Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
												Write-Host " Введено пустое значение."
											}
											Clear-Variable -name "InputNameFolder"
										}
										break
									}
									# Ошибка.
									else {
										echo ""
										Start-Sleep -Milliseconds 500
										Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
										Write-Host " Путь не существует."
									}
								}
								# Выход.
								elseif ($InputPathDestination -like "exit") {
									break
								}
								# Ошибка.
								elseif ($InputPathDestination -like $null) {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Введено пустое значение."
								}
								# Ошибка.
								else {
									echo ""
									Start-Sleep -Milliseconds 500
									Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
									Write-Host " Неверно указан путь. Смотри пример."
								}
								Clear-Variable -name "InputPathDestination"
							}
							break
						}
						# Ошибка.
						else {
							echo ""
							Start-Sleep -Milliseconds 500
							Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
							Write-Host " Путь не существует."
						}
					}
					catch {
						echo ""
						Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
						Write-Host " $($Error[0])"
					}
				}
				# Выход.
				elseif ($InputPathRoot -like "exit") {
					break
				}
				# Ошибка.
				elseif ($InputPathRoot -like $null) {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Введено пустое значение."
				}
				# Ошибка.
				else {
					echo ""
					Start-Sleep -Milliseconds 500
					Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
					Write-Host " Неверно указан путь. Смотри пример."
				}
				Clear-Variable -name "InputPathRoot"
			}
			break
		}
		# Выбор 2. Указать полный путь к дистрибутиву 1С.
		elseif($UserInput -eq 2) {
			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " OK" -ForegroundColor Green
			Start-Sleep -Milliseconds 500

			Install-Server -Server1C $Server

			break

		}
		# Выход.
		elseif ($UserInput -like "exit") {
			break
		}
		# Ошибка.
		elseif ($UserInput -like $null) {
			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
			Write-Host " Введено пустое значение."
		}
		# Ошибка.
		else {
			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
			Write-Host " Неверно введена команда."
		}
	}
	Clear-Variable -Name "Server"
	Clear-Variable -Name "UserInput"
}

echo " "
Write-Host " ################################################" -ForegroundColor Magenta
Write-Host " # Hellow Senior System Administrator, Lets go! #" -ForegroundColor Magenta
Write-Host " ################################################" -ForegroundColor Magenta
Write-Host " #               1C: Enterprise 8               #" -ForegroundColor Magenta
Write-Host " ################################################" -ForegroundColor Magenta


# Переменная $PathRoot получает полный путь директории из которой запускается скрипт.
$PathRoot = $MyInvocation.MyCommand.Path | Split-Path -parent
[string]$Path = "$PathRoot\"

Start-Sleep -Seconds 1
# Установка подключения к серверу.
Set-Server1C
Start-Sleep -Seconds 1

# В цикле while выполняется тело кода.
while ($true) {

	# Загрузка меню.
	Loading-Menu

	# Пользовательский ввод.
	$UserInputMenu = (Read-Host " Введите номер команды").ToLower()

	# Информация о кластере.
	if ($UserInputMenu -eq 1) {
		echo ""
		Write-Host "  -----------------------" -ForegroundColor Magenta 
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Информация о кластере" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  -----------------------" -ForegroundColor Magenta

		Get-Cluster1C -Server $SetServer
	}

	# Информация о COM-объекте.
	elseif ($UserInputMenu -eq 2) {
		echo ""
		Write-Host "  --------------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Информация о COM-объекте" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  --------------------------" -ForegroundColor Magenta

		Get-ComObject1C -Server $SetServer
	}

	# Информация о версиях платформы.
	elseif ($UserInputMenu -eq 3){
		echo ""
		Write-Host "  --------------------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Информация о версиях платформы" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  --------------------------------" -ForegroundColor Magenta

		Get-Platform1C -Server $SetServer
	}

	# Информация о службе.
	elseif ($UserInputMenu -eq 4) {
		echo ""
		Write-Host "  ---------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Информация о службе" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  ---------------------" -ForegroundColor Magenta

		Get-Service1C -Server $SetServer
	}

	# Работа со службой.
	elseif ($UserInputMenu -eq 5) {
		echo ""
		Write-Host "  -------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Работа со службой" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  -------------------" -ForegroundColor Magenta

		Job-Service1C -Server $SetServer
	}

	# Работа с COM-объектом.
	elseif ($UserInputMenu -eq 6) {
		echo ""
		Write-Host "  -----------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Работа с COM-объектом" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  -----------------------" -ForegroundColor Magenta

		Job-ComObject1C -Server $SetServer		
	}

	# Удаление активных сессий.
	elseif ($UserInputMenu -eq 7) {
		echo ""
		Write-Host "  --------------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Удаление активных сессий" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  --------------------------" -ForegroundColor Magenta

		Disactivate-Session1C -Server $SetServer -Path $Path
	}

	# Удаление сервера.
	elseif ($UserInputMenu -eq 8) {
		echo ""
		Write-Host "  ------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Удаление сервера" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  ------------------" -ForegroundColor Magenta

		Remove-Server1C -Server $SetServer
	}

	# Установка сервера.
	elseif ($UserInputMenu -eq 9) {
		echo ""
		Write-Host "  -------------------" -ForegroundColor Magenta
		Write-Host " |" -ForegroundColor Magenta -NoNewline
		Write-Host " Установка сервера" -ForegroundColor Magenta -NoNewline
		Write-Host " |" -ForegroundColor Magenta
		Write-Host "  -------------------" -ForegroundColor Magenta

		Install-Server1C -Server $SetServer
	}
	
	# Выход.
	elseif ($UserInputMenu -like "exit") {
		Start-Sleep -Milliseconds 500
		echo ""
		Write-Host " #######################################" -ForegroundColor Magenta
		Write-Host " # GOOD JOB! Good day for you!         #" -ForegroundColor Magenta
		Write-Host " #######################################" -ForegroundColor Magenta
		Write-Host " # PS: Keep Calm and Call t3hadmin! =) #" -ForegroundColor Magenta
		Write-Host " #######################################" -ForegroundColor Magenta
		echo " "
		break
	}

	# Ошибка.
	elseif ($UserInputMenu -like $null) {
		echo ""
		Start-Sleep -Milliseconds 500
		Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
		Write-Host " Введено пустое значение."
	}

	# Ошибка.
	else {
		echo ""
		Start-Sleep -Milliseconds 500
		Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
		Write-Host " Неверно введена команда."
	}
}
# Конец.
