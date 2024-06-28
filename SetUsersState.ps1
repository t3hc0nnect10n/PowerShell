<#
    Скрипт обращается к каталогу Active Directory и производит запись в атрибут учётной записи 'State' (область, край).

    Для осуществления записи, в механике скрипта необходимо указать полный путь к месту хранения файла, 
    в котором предварительно сформированный список учётных записей по атрибуту 'SamAccountName'. 
    Запись в атрибут 'State' (область, край) происходит только в том случае, если учётная запись:
      
        - Включена
        - Находится в организационном подразделении (OU) заданному значению
        - Описание не соответствует заданному значению
    
    В конце в консоль выводится отчёт о проделанной работе.
#>
echo " "
Write-Host "################################################" -ForegroundColor Magenta
Write-Host "# Hellow Senior System Administrator, Lets go! #" -ForegroundColor Magenta
Write-Host "################################################" -ForegroundColor Magenta
echo " "

sleep 1
echo " "

# В операторе 'while' указывается полный путь места хранения файла с проверкой ввода.
while ($true) {
        
        # Пользовательский ввод в консоли.
		Write-Host " Задаём переменной 'File' полный путь места хранения файла" -ForegroundColor Yellow
		Write-Host " Пример: C:\Users\Ivanov\Documents\Москва.txt" -ForegroundColor DarkCyan
		$GetFile = Read-Host " Введите полный путь к файлу"
        
        # Проверка, что такой файл существует. 
		$Check = Test-Path -Path $GetFile
        
		if ($Check -like $true) {
            
            # Проверка, что полный путь содержит нужные символы ":\" и формат файла ".txt".
			if (($GetFile.Contains(":\")) -and ($GetFile.EndsWith(".txt"))) {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host " ОК" -ForegroundColor Green
				echo " "
				break
			}
			else {
				Start-Sleep -Milliseconds 500
				echo " "
				Write-Host  " ОШИБКА: Неверно указан полный путь. Смотри пример." -ForegroundColor Red
				echo " "
			}
		}
		else {
			echo " "
			Write-Host " ОШИБКА: Такого файла не существует." -ForegroundColor Red
			echo " "
		}
	}

# Пользовательский ввод в консоли.
Write-Host " Задаём переменной 'State' территориальный признак" -ForegroundColor Yellow
Write-Host " Пример: Москва" -ForegroundColor DarkCyan
$State = Read-Host " Введите территориальный признак"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " ОК" -ForegroundColor Green
echo " "

# Пользовательский ввод в консоли.
Write-Host " Задаём переменной 'Description' описание, как указано в атрибуте учетной записи" -ForegroundColor Yellow
Write-Host " Пример: Для почты" -ForegroundColor DarkCyan
$Description = " Введите описание"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " ОК" -ForegroundColor Green
echo " "

# Пользовательский ввод в консоли.
Write-Host " Задаём переменной 'SearchBase' название distinguishedName из LDAP каталога Active Directory" -ForegroundColor Yellow
Write-Host " Пример: OU=Департамет ИТ,OU=Users,DC=domain,DC=local" -ForegroundColor DarkCyan
$SearchBase = " Введите distinguishedName контейнера (OU)"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " ОК" -ForegroundColor Green
echo " "

echo " "
Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
echo " "

# Переменная 'File' получает данные из переменной 'GetFile' с удалением лишних пробелов.
$File = Get-Content $GetFile.Trim()
Write-Host $File.Count " Пользователей" -ForegroundColor Black -BackgroundColor White
echo " "

# В переменную 'CountStateAdd' записывается скольким учётным записям записано значение атрибута 'State' - область, край.
$CountStateAdd = 0
# В переменную 'CountDescripton' записывается сколько учётных записей содержат значение атрибута 'Description' - описание.
$CountDescripton = 0
# В переменную 'CountUsersEnabledFalse' записывается сколько учётных записей деактивировано.
$CountUsersEnabledFalse = 0
# В переменную 'CountUsersAdNo' записывается сколько учётных записей не существуют в Active Directory.
$CountUsersAdNo = 0
# В переменную 'ListUsersEnabledFalse' формируется список деактивированных учётных записей.
$ListUsersEnabledFalse = @()
# В переменную 'ListUsersAdNo' формируется список не существующих учётных записей в Active Directory.
$ListUsersAdNo = @()

# Цикл 'foreach' запускает итерацию по каждой учётной записи заданной в переменную 'User'.
foreach ($User in $File) {

    Start-Sleep -Milliseconds 100

    <# 
        Используется try, catch блоки для обработки завершающих ошибок.
        Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
        https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
    #>

    # Запускается блок 'try' в котором выполняется основная часть кода.
	try {
        
        # Задаём переменной 'GetUser' получить все свойства учётной записи.
		$GetUser = Get-ADUser $User -Properties *
        
        # Условие, если учётная запись активирована и описание не содержит значение заданной в переменной 'Description'. 
        # и учётная запись расположена в директории каталога Active Directory указанной в переменной 'SearchBase'.
		if ($GetUser.Enabled -like $true -and $GetUser.Description -notmatch $Description -and $GetUser.DistinguishedName -match $SearchBase) {
			
            # Записываем значение в учетной записи в атрибут 'State' - область, край. 
			Set-ADUser $User -State $State
			$CountStateAdd += 1
                        			
			Start-Sleep -Milliseconds 100
            
            # Переменной 'CheckState' проверяет, что в учётную запись записано значение присвоенной в переменной 'State' 
            # Проверка учётной записи по атрибутам 'Enabled' равно активирована, 'Description' не содержит значению заданной в переменной 'Description', 
            # 'DistinguishedName' содержит значение заданной в переменной DistinguishedName', 'State' равно значению в заданной переменной 'State'.
            $CheckState = Get-ADUser $User -Properties * | 
                Where-Object {$_.Enabled -like $true -and $_.Description -notmatch $Description -and $_.DistinguishedName -match $SearchBase -and $_.State -like $State} | 
                Select-Object State
            
            # Вывод результата в консоль.
            Write-Host " $User - Значение добавлено =" $CheckState.State -ForegroundColor Green
		    
        }
        # В операторе 'else' отрабатывается условие, которое не попало в оператор 'if'.
		else {
	        
            # В учётную запись записывается пустое значение в атрибут 'State' - область, край. 
			Set-ADUser $User -State $null           

            # Если учётная запись активирована, то в консоль выводится результат, по которой не произошла запись в атрибут 'State' - область, край.
			if ($GetUser.Enabled -like $true){
                # В переменную 'CountDescripton' плюcуется единица для подсчёта.
				$CountDescripton += 1
				Write-Host " $User - Значение НЕ добавлено =" $GetUser.Description -ForegroundColor Red

			}
            # В операторе 'else' отрабатывается условие, которое не попало в оператор 'if'.
			else{
				echo " "
				Write-Host " Учётная запись $User отключена" -ForegroundColor Yellow
				# В переменную 'CountUsersEnabledFalse' плюcуется единица для подсчёта.
                $CountUsersEnabledFalse += 1
                # В переменную 'ListUsersEnabledFalse' добавляется в список учётная запись.  
				$ListUsersEnabledFalse += "$User,"
				echo " "
			}
		}
	}
    # В блоке 'catch' улавливается завершающая ошибка и отрабатывает код вместо вывода ошибки в стиле PowerSHell. 
	catch {
		echo " "
		Write-Host " Учётной записи $User НЕ существует" -ForegroundColor Magenta
        # В переменную 'CountUsersAdNo' плюcуется единица для подсчёта.
		$CountUsersAdNo += 1
        # В переменную 'ListUsersAdNo' добавляется в список учётная запись.
		$ListUsersAdNo += "$User,"
		echo " "
	}
}

Start-Sleep -Milliseconds 500

# Вывод отчёта в консоль.
echo " "
Write-Host "Признак '$State' добавлен учётным записям в количестве: $CountStateAdd" -ForegroundColor Black -BackgroundColor White
Write-Host "Учётные записи с описанием '$Description' в количестве: $CountDescripton" -ForegroundColor Black -BackgroundColor White
Write-Host "Деактивированные учётные записи в количестве:           $CountUsersEnabledFalse" -ForegroundColor Black -BackgroundColor White
Write-Host "Не существующих учётных записей в количестве:            $CountUsersAdNo" -ForegroundColor Black -BackgroundColor White
echo " "
Write-Host " Список деактивированных учётных записей: `n`n$ListUsersEnabledFalse"
echo " "
Write-Host " Список не существующих учётных записей: `n`n$ListUsersAdNo"

echo " "
Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
echo " "

# Очистка переменных от заданных ранее значениями.
Clear-Variable -Name "GetFile"
Clear-Variable -Name "File"
Clear-Variable -Name "State"
