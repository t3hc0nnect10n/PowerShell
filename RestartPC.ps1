<#
	Скрипт предназначен для принудительной перезагрузки компьютеров с уведомлением пользователей.
	Предварительно необходимо сформировать список имён компьютеров по NETBIOS-name и сохранить с именем "PC" в формате "txt".

	Скрипт запускть от имени администратора из директории, в которой находится файл "PC.txt".
	В этой же директории будет сформирован "log" файл, в котором записывается информация компьютеров не прошедшие проверку соединения.
#>

$PC  = "PC.txt"
$Log = "log"

# Переменной $Text присваиваем текст сообщения для пользователей.
$Text = "Доброго дня.
На вашем компьютере был обновлен антивирус Касперский. На данный момент требуется перезагрузка вашего устройства. Ваше устройство автоматически перезагрузится через 10 минут, просьба сохранить ваши данные и ожидать перезагрузки. Спасибо."

# Переменная $Date получает текущую дату.
$Date = Get-Date

# Переменная $PathRoot получает полный путь директории из которой запускается скрипт.
$PathRoot = $MyInvocation.MyCommand.Path | Split-Path -parent
[string]$Path ="$PathRoot\" 

# Условие проверки файла "log" в директории откуда запускается скрипт. Если файла нет, то он создается.
if (-Not (Test-Path $Path$Log)) {
	New-Item -Path $Path -Name log -ItemType File
}
<#
	Используется try, catch блоки для обработки завершающих ошибок.
	Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
	https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
#>
 # Запускается блок 'try', в котором выполняется проверка наличия файла"PC.txt" в директории откуда запускается скрипт.
try {
	# Переменная $GetFilePC проверяет наличие файла "PC.txt" в директории откуда запускается скрипт.
	$GetFilePC  = Get-ChildItem -Path $Path -File -Name $PC -ErrorAction Stop

	# Условие проверки файла "PC.txt" в директории откуда запускается скрипт.
	if (Test-Path $Path$GetFilePC -ErrorAction Stop) {

		# Переменная $Computers получает спиоск компьютеров.
		$Computers = (Get-Content $Path$GetFilePC -ErrorAction Stop).Trim()

		# В цикле foreach запускается итерация по каждому компьютеру.
		foreach ($Computer in $Computers) {


			# Запускается блок 'try', в котором выполняется проверка соединения с компьютером.
			try {
				# Переменная $TestConnetion получает результат соединения с компьютером.
				$TestConnetion = Test-Connection $Computer -Count 1 -ErrorAction Stop

				# Условие проверки соединения с компьютером.
				# Если истина, то выполняется тело условия.
				if ($TestConnetion) {

					# Команда на перезагрузку компьютера через 10 минут (600 секунд) с уведомлением пользователя.
					shutdown.exe /r /t 600 /f /m \\$Computer /c $Text
					<# 
						Для отмены запланированной перезагрузки надо скопировать команду, вставить в консоль PowerShell и нажать кнопку "Enter".
						Вместо DT-000 указываем имя компьютера.

						shutdown.exe /a /m \\DT-000
					#>
				}
			}
			# Блок catch улавливает завершающую ошибку.
			catch {
				Write-Host ""
				Write-Warning $Computer
				Write-Host $($_.Exception.Message)
				# Произвордится запись ошибки в лог файл "log".
				Add-Content -Path $Path$Log -Value ("[$Date][$Computer] $($_.Exception.Message)","")
			}
		}
	}
}
catch {
	Write-Host ""
	Write-Warning $($_.Exception.Message)
	# Произвордится запись ошибки в лог файл "log".
	Add-Content -Path $Path$Log -Value ("[$Date]$($_.Exception.Message)","")
}