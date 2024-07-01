<#
	Скрипт обращается к каталогу Active Directory.
	Функциональная возможность скрипта позволяет произвести действия как указав
	заранее сформированный список пользователей по атрибуту SamAccountName, так и вводя по одному пользователю.

	Производит следующие действия:

		- Учётная запись:
			- отключает учётную запись
			- перемещает в организационное подразделение (OU) с отключенными учётными записями
			- удаляет все группы безопасности кроме 'Пользователи домена'

		- Диск профиля:
			- удаляет диск профиля в заданной директории

		В функциях ListUsers(), OneUser(), RemoveProfileDiskDisabledUsers() закомментированы команды удаления диска профиля.
		Для удаление дисков профилей необходимо снять комментарий удалив символ #

		Remove-Item -Path $DiskProfileCheck

#>

# Функция для списка учётных записей.
function ListUsers() {

	# В цикле while контроль ввода полного пути места хранения файла списка пользователей.
	while ($true) {

		# Задаём переменной $ListUsers полный путь хранения файла.
		# Например: C:\Users\Ivan\Documents\DisabledUsers.txt
		echo " "
		Write-Host " Задаём переменной 'ListUsersFile' полный путь места хранения файла" -ForegroundColor Yellow
		Write-Host " Пример: C:\Users\Ivan\Documents\DisabledUsers.txt" -ForegroundColor DarkCyan
		$ListUsersFile = Read-Host " Введите полный путь"

		$CheckPath = Test-Path -Path $ListUsersFile

		if ($CheckPath -like $true) {

			if (($CheckPath.EndsWith(".txt"))) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
			}
			else {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host  " ОШИБКА: Файл НЕ формата 'txt'. Смотри пример." -ForegroundColor Red
			}
		}
		else {
			echo " "
			Write-Host " ОШИБКА: Такого файла НЕ существует." -ForegroundColor Red
		}
	}

	# В цикле while контроль ввода полного пути места хранения дисков профилей.
	while ($true) {

		# Переменной $DiskProfilePath задаём полный путь места хранения дисков профилей.
		echo " "
		Write-Host " Задаём переменной 'DiskProfilePath' полный путь места хранения дисков профилей" -ForegroundColor Yellow
		Write-Host " Пример: \\VM-WIN-SRV\ProfileDisk\" -ForegroundColor DarkCyan
		$DiskProfilePath = Read-Host " Введите полный путь к папке"

		if ($DiskProfilePath.Contains("\\") -or $DiskProfilePath.Contains("\") -and $DiskProfilePath.EndsWith("\")) {

			$CheckProfilePath = Test-Path -Path $DiskProfilePath

			if ($CheckProfilePath -like $true) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
			}
			else{
				echo " "
				Write-Host " ОШИБКА: Такой папки НЕ существует." -ForegroundColor Red
				echo " "
			}
		}
		else {
			echo " "
			Write-Host " ОШИБКА: Неверно указан путь. Смотри пример" -ForegroundColor Red
			echo " "
		}
	}

	# В цикле while контроль ввода организационного подразделения (OU)
	while($true) {

		# Переменной $BlockedUsers присвоен distinguishedName организационного подразделения (OU), в котором хранятся отключенные учетные записи.
		# Например: OU=Disabled Users,DC=example,DC=local
		echo " "
		Write-Host " Задаём переменной 'BlockedUsers' distinguishedName организационного подразделения отключенных учётных записей" -ForegroundColor Yellow
		Write-Host " Пример: OU=Disabled Users,OU=Users,DC=domain,DC=local" -ForegroundColor DarkCyan
		$BlockedUsers = Read-Host " Введите distinguishedName"

		$CheckBlockedUsers = Get-ADObject -Identity $BlockedUsers -ErrorAction SilentlyContinue

		<#
			Используется try, catch блоки для обработки завершающих ошибок.
			Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
			https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
		#>

		# Запускается блок 'try', в котором выполняется проверка существования организационного подразделения (OU).
		try {

			if ($CheckBlockedUsers) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				break
			}
			else {
				echo " "
				Write-Host " ОШИБКА: Организационного подразделения '$BlockedUsers' - НЕ существует" -ForegroundColor Magenta
    				echo " "
			}
		}
		catch{
			echo " "
			Write-Host " ОШИБКА: Организационного подразделения '$BlockedUsers' - НЕ существует" -ForegroundColor Magenta
   			echo " "
		}
	}

	# В переменную $ListProfileDiskYes формируется массив (список) найденных дисков.
	$ListProfileDiskYes = [System.Collections.ArrayList]@()
	# В переменную $ListProfileDiskNo формируется массив (список) НЕ найденных дисков.
	$ListProfileDiskNo = [System.Collections.ArrayList]@()

	# В переменную 'Count_VM_1C_APP' записывается количество удалённых дисков профилей.
	$CountYes = 0
	# В переменную 'CountNo' записывается количество НЕ найденных, НЕ удалённых дисков парофилей.
	$CountNo = 0

	# Переменной $DiskProfileCount задаём получить количество дисков профилей.
	$DiskProfileCount = (Get-ChildItem -Path $DiskProfilePath).count

	# Удаление лишних пробелов.
	$Users = Get-Content $ListUsersFile.Trim()

	echo " "
	Write-Host $Users.Count "Учётных записей" -ForegroundColor Yellow

	echo " "
	Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
	echo " "

	# Цикл foreach производит итерацию по учётным записям из списка в заданной переменной $ListUsersFile.
	foreach ($User in $Users) {

		try {

			$CheckUser = Get-ADUser $User -Properties *

			if ($CheckUser) {
				# Перемещение пользователя в организационное подразделение (OU) в заданной переменной $BlockedUsers.
				Get-ADUser $User | Move-ADObject -TargetPath $BlockedUsers

				# Отключение учетной записи.
				Disable-ADAccount -Identity $User

				# Переменная $Groups получает все группы безопасности пользователя кроме "Пользователи домена".
				$Groups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object {$_.Name -ne "Пользователи домена"}

				# Цикл foreach производит итерацию по каждой группе безопасности и удаляет пользователя из неё.
				foreach ($Group in $Groups) {
					# Удаление групп безопасности из учётной записи.
					Remove-ADGroupMember -identity $Group.name -Members $User -Confirm:$false
				}

				# Переменной $Name задаём получить атрибут 'Name' (ФИО) учётной записи.
				$Name = Get-ADUser $User -Properties * | Select-Object Name
				# Переменной $UserName задаём преобразовать полученный данные из переменной $Name в строку.
				$UserNameT = [string]$Name
				# Убираем лишние символы '@{Name=' и '}', которые получили в виде массива.
				$UserName = $UserNameT.Replace("@{Name=","").Replace("}","")
    				
				# Переменная $CheckGroup получает список групп, в которые входит пользователь.
				$CheckGroup = Get-ADPrincipalGroupMembership -Identity $User | Select-Object Name
                		# Переменной $CheckGroupNameT задаём преобразовать полученный данные из переменной $CheckGroup в строку.
                		$CheckGroupNameT = [string]$CheckGroup
                		# Убираем лишние символы '@{Name=' и '}', которые получили в виде массива.
                		$CheckGroupName =  $CheckGroupNameT.Replace("@{Name=","").Replace("}","")

				# Переменная $CheckUserNotEnabled проверяет на наличие отключенной учетной записи в организационном подразделении (OU) в заданной переменной $BlockedUsers.
				$CheckUserNotEnabled = Get-ADUser $User -Filter * -SearchBase $BlockedUsers -Properties * | Where-Object {$_.Enabled -like $false -and $_.Name -like $UserName}	

				# Условие проверки на выполнение отключения учетной записи, наличие группы безопасности "Пользователи домена" и
				# перемещение в организационное подразделение (OU) в заданной переменной $BlockedUsers. 
				# Если условие истинно, то в консоль выводится ФИО, SamAccountName и группы безопасности в зелёном цвете, если нет, то в красном. 
				if ($CheckUserNotEnabled) {

					Write-Host " Пользователь '$UserName' -" $User "- заблокирован и перемещен в '$BlockedUsers'. Группы доступа:" $CheckGroupName -ForegroundColor Green

					# Переменной $DiskProfileNameSid задаём получить 'SID'.
					$DiskProfileNameSid =  Get-ADUser $User -Properties *  | Where-Object {$_.Enabled -like $false -and $_.Name -like $UserName}| Select-Object SID
					# Переменной $SidName задаём преобразовать полученный данные из переменной $DiskProfileNameSid в строку.
					$SidNameT = [string]$DiskProfileNameSid
					# Убираем лишние символы '@{SID=' и '}', которые получили в виде массива.
					$SidName = $SidNameT.Replace("@{SID=","*").Replace("}","*")

					# Переменной $DiskProfileCheck задаём получить диск профиля.
					$DiskProfileCheck = Get-ChildItem -Path $DiskProfilePath -Name $SidName

					if ($DiskProfileCheck) {
						# Удаление диска профиля.
						#Remove-Item -Path $DiskProfileCheck
						# Убираем лишние символы '*'.
						$SidName = $SidName.Replace("*","")
						Write-Host " Диск профиля '$UserName': $SidName - Удалён" -ForegroundColor Green
						# В переменную $CountYes плюcуется единица для подсчёта.
						$CountYes += 1
						# В массив (список) $ListProfileDiskYes добавляется 'SID'.
						$ListProfileDiskYes.Add($SidName)
						# Очистка переменной $UserNameT от полученного значения.
						Clear-Variable -Name "UserNameT"
						# Очистка переменной $SidNameT от полученного значения.
						Clear-Variable -Name "SidNameT"
      						# Очистка переменной $CheckGroupNameT от полученного значения.
                        			Clear-Variable -Name "CheckGroupNameT"
						echo " "
					}
					else {
						# Убираем лишние символы '*'.
						$SidName = $SidName.Replace("*","")
						Write-Host " Диск профиля '$UserName': $SidName - Не существует" -ForegroundColor Red
						# В переменную $CountNo плюcуется единица для подсчёта.
						$CountNo += 1
						# В массив (список) $ListProfileDiskNo добавляется 'SID'.
						$ListProfileDiskNo.Add($SidName)
						# Очистка переменной $UserName от полученного значения.
						Clear-Variable -Name "UserNameT" 
						# Очистка переменной $SidNameT от полученного значения.
						Clear-Variable -Name "SidNameT"
      						# Очистка переменной $CheckGroupNameT от полученного значения.
                        			Clear-Variable -Name "CheckGroupNameT"
						echo " "
					}
				}
				else {
					Write-Host " Пользователь '$UserName' -" $User "- НЕ заблокирован. Группы доступа:" $CheckGroup -ForegroundColor Red
					# Очистка переменной $UserNameT от полученного значения.
					Clear-Variable -Name "UserNameT"
     					# Очистка переменной $CheckGroupNameT от полученного значения.
                    			Clear-Variable -Name "CheckGroupNameT"
				}
			}
		}
		catch {
			echo " "
			Write-Host " Учётной записи $User НЕ существует" -ForegroundColor Magenta
			echo " "
		}
	}

	echo " "
	Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
	echo " " 

	# Вывод отчёта в консоль.
	echo " "
	Write-Host " Всего дисков: $DiskProfileCount" -ForegroundColor Black -BackgroundColor White
	Write-Host " Удалено дисков: $CountYes" -ForegroundColor Black -BackgroundColor White
	Write-Host " Не найдено дисков: $CountNo" -ForegroundColor Black -BackgroundColor White
	echo " "
	Write-Host " Список удалённых дисков: `n`n$ListProfileDiskYes"
	echo " "
	Write-Host " Список НЕ удалённых, НЕ найденных дисков: `n`n$ListProfileDiskNo"

	# Очистка переменной $ListUsersFile от заданного значения.
	Clear-Variable -Name "ListUsersFile"
	# Очистка переменной $BlockedUsers от заданного значения.
	Clear-Variable -Name "BlockedUsers"

	# Очищаем ранее созданный массив (список) $ListProfileDisk.
	$ListProfileDiskYes.Clear()
	# Очищаем ранее созданный массив (список) $ListProfileDiskNo.
	$ListProfileDiskNo.Clear()

	$CountYes = 0
	$CountNo = 0
}

# Функция для одной учётной записи.
function OneUser() {
	
	echo " "
	Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
	echo " "

	# В цикле while контроль ввода учётной записи по атрибуту 'SamAccountName'.
	while ($true) {

		echo " "
		Write-Host " Задаём переменной 'User' имя учётной записи по атрибуту SamAccountName " -ForegroundColor Yellow
		Write-Host " Пример: Ivanov.I" -ForegroundColor DarkCyan
		[string]$User = Read-Host " Введите имя учётной записи"
		
		$CheckUser = Get-ADUser $User -Properties *

		<# 
			Используется try, catch блоки для обработки завершающих ошибок.
			Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
			https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
		#>

		# Запускается блок 'try', в котором выполняется проверка существования учётной записи.
		try {

			if ($CheckUser) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
				}
		}
		catch{
			echo " "
			Write-Host " Учётной записи $User НЕ существует" -ForegroundColor Magenta
		}
	}

	# В цикле while контроль ввода полного пути места хранения дисков профилей.
	while ($true) {

		# Переменной $DiskProfilePath задаём полный путь места хранения дисков профилей в папке.
		echo " "
		Write-Host " Задаём переменной 'DiskProfilePath' полный путь места хранения дисков профилей" -ForegroundColor Yellow
		Write-Host " Пример: \\VM-WIN-SRV\ProfileDisk\" -ForegroundColor DarkCyan
		[string]$DiskProfilePath = Read-Host " Введите полный путь к папке"

		if ($DiskProfilePath.Contains("\\") -or $DiskProfilePath.Contains("\") -and $DiskProfilePath.EndsWith("\")) {

			$CheckProfilePath = Test-Path -Path $DiskProfilePath

			if ($CheckProfilePath -like $true) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
			}
			else{
				echo " "
				Write-Host " ОШИБКА: Такой папки НЕ существует." -ForegroundColor Red
				echo " "
			}
		}
		else {
			echo " "
			Write-Host " ОШИБКА: Неверно указан путь. Смотри пример" -ForegroundColor Red
			echo " "
		}
	}

	# В цикле while контроль ввода организационного подразделения (OU).
	while ($true) {

		# Переменной $BlockedUsers присвоен distinguishedName организационного подразделения (OU), в котором хранятся отключенные учетные записи.
		# Например: OU=Disabled Users,DC=example,DC=local
		echo " "
		Write-Host " Задаём переменной 'BlockedUsers' distinguishedName организационного подразделения отключенных учётных записей" -ForegroundColor Yellow
		Write-Host " Пример: OU=Disabled Users,OU=Users,DC=domain,DC=local" -ForegroundColor DarkCyan
		[string]$BlockedUsers = Read-Host " Введите distinguishedName"

		$CheckBlockedUsers = Get-ADObject -Identity $BlockedUsers -ErrorAction SilentlyContinue

		<#
			Используется try, catch блоки для обработки завершающих ошибок.
			Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
			https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
		#>

		# Запускается блок 'try', в котором выполняется проверка существования организационного подразделения (OU).
		try {

			if ($CheckBlockedUsers) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
			}
			else {
				echo " "
				Write-Host " ОШИБКА: Организационного подразделения '$BlockedUsers' - НЕ существует" -ForegroundColor Magenta
    				echo " "
			}
		}
		catch{
			echo " "
			Write-Host " ОШИБКА: Организационного подразделения '$BlockedUsers' - НЕ существует" -ForegroundColor Magenta
   			echo " "
		}
	}

	# Перемещение пользователя в организационное подразделение (OU) в заданной переменной $BlockedUsers.
	Get-ADUser $User -Properties * | Move-ADObject -TargetPath $BlockedUsers

	# Отключение учётной записи.
	Disable-ADAccount -Identity $User

	# Переменная $Groups получает все группы безопасности пользователя кроме "Пользователи домена".
	$Groups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object {$_.Name -ne "Пользователи домена"}

	# Цикл проходит по каждой группе безопасности и удаляет пользователя из неё.
	foreach ($Group in $Groups) {
		# Удаление групп безопасности из учётной записи.
		Remove-ADGroupMember -identity $Group.name -Members $ADUser -Confirm:$false
	}

	Start-Sleep -Milliseconds 1000

	# Переменной $Name задаём получить атрибут Name (ФИО) учётной записи.
	$Name = Get-ADUser $User -Properties * | Select-Object Name
	# Переменной $UserNameT задаём преобразовать полученный данные из переменной $Name в строку.
	$UserNameT = [string]$Name
	# Убираем лишние символы '@{Name=' и '}', которые получили в виде массива.
	$UserName = $UserNameT.Replace("@{Name=","").Replace("}","")

	# Переменная $CheckGroup получает список групп, в которые входит пользователь.
	$CheckGroup = Get-ADPrincipalGroupMembership -Identity $User | Select-Object Name
    	# Переменной $CheckGroupNameT задаём преобразовать полученный данные из переменной $CheckGroup в строку.
    	$CheckGroupNameT = [string]$CheckGroup
    	# Убираем лишние символы '@{Name=' и '}', которые получили в виде массива.
    	$CheckGroupName =  $CheckGroupNameT.Replace("@{Name=","").Replace("}","")

	# Переменная $CheckUserNotEnabled проверяет на наличие отключенной учетной записи в организационном подразделение (OU) в заданной переменной $BlockedUsers.
	$CheckUserNotEnabled = Get-ADUser -Filter * -SearchBase $BlockedUsers -Properties * | Where-Object {$_.Enabled -like $false -and $_.SamAccountName -like $User}

	# Условие проверки на выполнение отключения учетной записи, наличие группы безопасности "Пользователи домена" и
	# перемещение в организационное подразделение (OU) в заданной переменной $BlockedUsers. 
	# Если условие истинно, то в консоль выводится ФИО, SamAccountName и группы безопасности в зелёном цвете, если нет, то в красном.
	if ($CheckUserNotEnabled) {

		Write-Host " Пользователь '$UserName' -" $User "- заблокирован и перемещен в '$BlockedUsers'. Группы доступа:" $CheckGroupName -ForegroundColor Green

		# Переменной $DiskProfileName задаём получить атрибут 'SID' учётной записи.
		$DiskProfileNameSid =  Get-ADUser $User -Properties *  | Select-Object SID
		# Переменной $SidNameT задаём преобразовать полученный данные из переменной $DiskProfileNameSid в строку.
		$SidNameT = [string]$DiskProfileNameSid
		# Заменяем лишние символы '@{SID=' и '}' на '*', которые получили в виде массива.
		$SidName = $SidNameT.Replace("@{SID=","*").Replace("}","*")

		# Переменной $DiskProfileCheck задаём получить диск профиля.
		$DiskProfileCheck = Get-ChildItem -Path $DiskProfilePath -Name $SidName

		if ($DiskProfileCheck) {
			# Удаление диска профиля.
			#Remove-Item -Path $DiskProfileCheck
			# Убираем лишние символы '*'.
			$SidName = $SidName.Replace("*","")
			Write-Host " Диск профиля '$UserName': $SidName  - Удалён" -ForegroundColor Green
			# Очистка переменной $UserNameT от полученного значения.
			Clear-Variable -Name "UserNameT" 
			# Очистка переменной $SidNameT от полученного значения.
			Clear-Variable -Name "SidNameT"
   			# Очистка переменной $CheckGroupNameT от полученного значения.
            		Clear-Variable -Name "CheckGroupNameT"
		}
		else {
			# Убираем лишние символы '*'.
			$SidName = $SidName.Replace("*","")
			Write-Host " Диск профиля '$UserName': $SidName  - Не существует" -ForegroundColor Red
			# Очистка переменной $UserNameT от полученного значения.
			Clear-Variable -Name "UserNameT" 
			# Очистка переменной $SidNameT от полученного значения.
			Clear-Variable -Name "SidNameT"
   			# Очистка переменной $CheckGroupNameT от полученного значения.
            		Clear-Variable -Name "CheckGroupNameT"
		}
	}
	else {
		echo " "
		Write-Host " Пользователь '$UserName' -" $User "- не заблокирован. Группы доступа:" $CheckGroupName -ForegroundColor Red
		echo " "
		# Очистка переменной $UserNameT от полученного значения.
		Clear-Variable -Name "UserNameT"
  		# Очистка переменной $CheckGroupNameT от полученного значения.
            	Clear-Variable -Name "CheckGroupNameT"
	}

	echo " "
	Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
	echo " "

	# Очистка переменной $UserInput от заданного значения.
	Clear-Variable -Name "User"
	# Очистка переменной $BlockedUsers от заданного значения.
	Clear-Variable -Name "BlockedUsers"
	
}

# Функция удаления дисков профилей отключенных учётных записей.
function RemoveProfileDiskDisabledUsers() {

	# В цикле while контроль ввода полного пути места хранения дисков профилей.
	while ($true) {

		# Переменной $DiskProfilePath задаём полный путь места хранения дисков профилей в папке.
		echo " "
		Write-Host " Задаём переменной 'DiskProfilePath' полный путь места хранения дисков профилей" -ForegroundColor Yellow
		Write-Host " Пример: \\VM-WIN-SRV\ProfileDisk\" -ForegroundColor DarkCyan
		$DiskProfilePath = Read-Host " Введите полный путь к папке"

		if ($DiskProfilePath.Contains("\\") -or $DiskProfilePath.Contains("\") -and $DiskProfilePath.EndsWith("\")) {

			$CheckProfilePath = Test-Path -Path $DiskProfilePath

			if ($CheckProfilePath -like $true) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
			}
			else{
				echo " "
				Write-Host " ОШИБКА: Такой папки НЕ существует." -ForegroundColor Red
				echo " "
			}
		}
		else {
			echo " "
			Write-Host " ОШИБКА: Неверно указан путь. Смотри пример" -ForegroundColor Red
			echo " "
		}
	}

	# В цикле while контроль ввода организационного подразделения (OU).
	while ($true) {
	
		# Переменной $BlockedUsers присвоен distinguishedName организационного подразделения (OU), в котором хранятся отключенные учетные записи.
		# Например: OU=Disabled Users,DC=example,DC=local
		echo " "
		Write-Host " Задаём переменной 'BlockedUsers' distinguishedName организационного подразделения отключенных учётных записей" -ForegroundColor Yellow
		Write-Host " Пример: OU=Disabled Users,OU=Users,DC=domain,DC=local" -ForegroundColor DarkCyan
		[string]$BlockedUsers = Read-Host " Введите distinguishedName"

		$CheckBlockedUsers = Get-ADObject -Identity $BlockedUsers -ErrorAction SilentlyContinue

		<# 
			Используется try, catch блоки для обработки завершающих ошибок.
			Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
			https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
		#>

		# Запускается блок 'try', в котором выполняется проверка существования организационного подразделения (OU).
		try {

			if ($CheckBlockedUsers) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
			}
			else {
				echo " "
				Write-Host " ОШИБКА: Организационного подразделения '$BlockedUsers' - НЕ существует" -ForegroundColor Magenta
    				echo " "
			}
		}
		catch{
			echo " "
			Write-Host " ОШИБКА: Организационного подразделения '$BlockedUsers' - НЕ существует" -ForegroundColor Magenta
   			echo " "
		}
	}

	# В переменную $ListProfileDiskYes формируется список найденных дисков.
	$ListProfileDiskYes = [System.Collections.ArrayList]@()
	# В переменную $ListProfileDiskNo формируется список НЕ найденных дисков.
	$ListProfileDiskNo = [System.Collections.ArrayList]@()

	# В переменную $CountYse записывается сколько дисков удалено.
	$CountYes = 0
	# В переменную $CountNo записывается сколько дисков не удалось обнаружить.
	$CountNo = 0

	# Переменной $DiskProfileCount_1C_APP задаём посчитать количество дисков.
	$DiskProfileCount = (Get-ChildItem -Path $DiskProfilePath).count

	# Переменной $GetSid задаём получить 'SID' из организационного подразделения 'OU=Blocked Users,DC=tk,DC=local'.
	$GetSid = Get-ADUser -Filter * -SearchBase $BlockedUsers -Properties * | Select-Object SID

	echo " "
	Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
	echo " "

	Write-Host " Заблокированных учётных записей:" $GetSid.Count -ForegroundColor Yellow 
	echo " "

	# Цикл foreach производит итерацию по каждому элементу из ранее созданного файла в заданной переменной $FileName.
	foreach ($SID in $GetSid) {

		Start-Sleep -Milliseconds 100
  		
    		# Переменной $SidName задаём преобразовать полученный данные из переменной $SID в строку.
		$SidNameTemp = [string]$SID
		# Убираем лишние символы '@{SID=' и '}', которые получили в виде массива.
		$SidNameTemp = $SidNameTemp.Replace("@{SID=","").Replace("}","")

		# Переменной $Name задаём получить ФИО по атрибуту 'SID'.
		$Name = Get-ADUser -Filter * -SearchBase $BlockedUsers -Properties * | Where-Object {$_.SID -like $SidNameTemp} | Select-Object Name
		# Переменной $UserNameT задаём преобразовать полученный данные из переменной $Name в строку.
		$UserNameT = [string]$Name
		# Убираем лишние символы '@{Name=' и '}', которые получили в виде массива.
		$UserName = $UserNameT.Replace("@{Name=","").Replace("}","")

		# Переменной $SidNameT задаём преобразовать полученный данные из переменной $SID в строку.
		$SidNameT = [string]$SID
		# Убираем лишние символы '@{SID=' и '}', которые получили в виде массива.
		$SidName = $SidName.Replace("@{SID=","*").Replace("}","*")

		# Переменной $DiskProfileCheck задаём получить диск профиля.
		$DiskProfileCheck = Get-ChildItem -Path $DiskProfilePath -Name $SidName

		if ($DiskProfileCheck) {
			# Удаление диска профиля.
			#Remove-Item -Path $DiskProfileCheck
			# Убираем лишние символы '*'.
			$SidName = $SidName.Replace("*","")
			Write-Host " Диск профиля '$UserName': $SidName - Удалён" -ForegroundColor Green
			# В переменную $CountYes плюcуется единица для подсчёта.
			$CountYes += 1
			# В массив (список) $ListProfileDiskYes добавляется 'SID'.
			$ListProfileDiskYes.Add($SidName)
			# Очистка переменной $UserNameT от полученного значения.
			Clear-Variable -Name "UserNameT" 
			# Очистка переменной $SidNameT от полученного значения.
			Clear-Variable -Name "SidNameT"
   			# Очистка переменной $SidNameTemp от полученного значения.
            		Clear-Variable -Name "SidNameTemp"
		}
		else {
  			$SidName = $SidName.Replace("*","")
			Write-Host " Диск профиля '$UserName': $SidName - Не существует" -ForegroundColor Red
			# В переменную $CountNo плюcуется единица для подсчёта.
			$CountNo += 1
			# В массив (список) $ListProfileDiskNo добавляется 'SID'.
			$ListProfileDiskNo.Add($SidName)
			# Очистка переменной $UserNameT от полученного значения.
			Clear-Variable -Name "UserNameT" 
			# Очистка переменной $SidNameT от полученного значения.
			Clear-Variable -Name "SidNameT"
   			# Очистка переменной $SidNameTemp от полученного значения.
            		Clear-Variable -Name "SidNameTemp"
		}
	}

	echo " "
	Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
	echo " "

	# Вывод отчёта в консоль.
	echo " "
	Write-Host " Заблокированных учётных записей:" $GetSid.Count -ForegroundColor Yellow
	Write-Host " Всего дисков в папке: $DiskProfileCount" -ForegroundColor Black -BackgroundColor White
	Write-Host " Удалено дисков: $CountYes" -ForegroundColor Black -BackgroundColor White
	Write-Host " Не найдено дисков: $CountNo" -ForegroundColor Black -BackgroundColor White
	echo " "
	Write-Host " Список дисков: `n`n$ListProfileDiskYes"
	echo " "
	Write-Host " Список НЕ удалённых, НЕ найденных дисков: `n`n$ListProfileDiskNo"

	# Очищаем переменную $DiskProfilePath от заданных значений.
	Clear-Variable -Name "DiskProfilePath"
	# Очищаем переменную $BlockedUsers от заданных значений.
	Clear-Variable -Name "BlockedUsers"

	# Очищаем ранее созданный массив (список) $ListProfileDiskYes.
	$ListProfileDiskYes.Clear()
	# Очищаем ранее созданный массив (список) $ListProfileDiskNo.
	$ListProfileDiskNo.Clear()

	$CountYes = 0
	$CountNo = 0
}

echo " "
Write-Host "################################################" -ForegroundColor Magenta
Write-Host "# Hellow Senior System Administrator, Lets go! #" -ForegroundColor Magenta
Write-Host "################################################" -ForegroundColor Magenta
echo " "

sleep 1

# Выполняемый код.
while ($true) {

	echo " "
	Write-Host " 1. Указать список пользователей" -ForegroundColor Yellow
	Write-Host " 2. Вводить пользователя по одному" -ForegroundColor Yellow
	Write-Host " 3. Отключенные пользователи"
	Write-Host " 4. Выход" -ForegroundColor Yellow
	$UserInputMenu = Read-Host " Введите номер команды"

	# Cписок учётных записей.
	if ($UserInputMenu -eq 1) {

		ListUsers
	}

	# Одина учётная запись.
	elseif ($UserInputMenu -eq 2) {

		OneUser
	}

	# Удаления дисков профилей отключенных учётных записей.
	elseif($UserInputMenu -eq 3) {

		RemoveProfileDiskDisabledUsers
	}

	# Выход.
	elseif ($UserInputMenu -eq 4) {
		Start-Sleep -Milliseconds 500
		echo " "
		Write-Host "#######################################" -ForegroundColor Magenta
		Write-Host "# GOOD JOB! Good day for you!         #" -ForegroundColor Magenta
		Write-Host "#######################################" -ForegroundColor Magenta
		Write-Host "# PS: Keep Calm and Call t3hadmin! =) #" -ForegroundColor Magenta
		Write-Host "#######################################" -ForegroundColor Magenta
		break
	}

	# Ошибка.
	else {
		Start-Sleep -Milliseconds 500
		echo " "
		Write-Host " ОШИБКА: Неверно введена команда." -ForegroundColor Red
		echo " "
	}
}
