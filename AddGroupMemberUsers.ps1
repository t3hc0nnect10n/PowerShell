# Made by t3hc0nect10n
# Скрипт позволяет в интерактивном режиме узнать информацию о пользователях, кто входит в группу доступа и добавить пользователей в группу доступа.

# Install-Module -Name WindowsCompatibility
# Import-WinModule -Name ActiveDirectory

echo " "
Write-Host "##################################################`n# Hellow Senior System Administrator, Lets go!!! #`n##################################################" -ForegroundColor Magenta
sleep 1
echo " "

 while ($true) {

    Write-Host " 1. Проверить пользователей группы доступа (Security Group)`n 2. Проверить пользователей в контейнере (OU)`n 3. Создать список`n 4. Добавить пользователей в группу доступа (Security Group)`n 5. Выход"  -ForegroundColor Yellow
    $UsrInput1 = Read-Host " Введите номер команды (1)-(2)-(3)-(4)-(5)"
    $UsrInput1 = [int]$UsrInput1

    # 1. Проверить пользователей группы доступа (Security Group)
    if ($UsrInput1 -eq 1) {
        echo " "
        Write-Host "<---------------------------------------------START--------------------------------------------->`n" -ForegroundColor Red -BackgroundColor White

        Write-Host " Задаём переменной 'ShawADGroup' название группы как в Active Directory" -ForegroundColor Yellow
        Write-Host " Пример: RO_Департамент ИТ" -ForegroundColor DarkCyan
        $ShawADGroup = Read-Host " Введите имя группы доступа (Security Group)"

        Start-Sleep -Milliseconds 500
        Get-ADGroupMember -Identity $ShawADGroup | Select-Object Name, SamAccountName | Sort-Object Name | Format-Table -AutoSize | more

        Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
        echo " "
    }
    
    # 2. Проверить пользователей в контейнере (OU)
    elseif ($UsrInput1 -eq 2) {
        echo " "
        Write-Host "<---------------------------------------------START--------------------------------------------->`n" -ForegroundColor Red -BackgroundColor White

        # LDAPdName1
        while ($true) {
            Write-Host " Задаём переменной 'LDAPdName1' название distinguishedName из LDAP каталога Active Directory" -ForegroundColor Yellow
            Write-Host " Пример: OU=Департамет ИТ,OU=Users,DC=example,DC=local" -ForegroundColor DarkCyan
            $LDAPdName1 = Read-Host " Введите distinguishedName контейнера (OU)"

            # Условие проверяющее правильность написания distinguishedName
            if (($LDAPdName1.Contains("OU=") -and $LDAPdName1.Contains("DC="))) {
                Start-Sleep -Milliseconds 500
                Write-Host " ОК`n" -ForegroundColor Green
                break
            }
            else {
                Start-Sleep -Milliseconds 500
                Write-Host  " ОШИБКА: Неверно указан distinguishedName контейнера (OU).`n" -ForegroundColor Red
            }
        }

        # UsrInpit2
        while ($true) {
            Write-Host " Введите какие свойства требуется вывести на экран:" -ForegroundColor Yellow
            Write-Host "            ФИО            : Name" -ForegroundColor Cyan
            Write-Host "            Логин УЗ       : SamAccountName" -ForegroundColor Cyan
            Write-Host "            Почта          : Mail" -ForegroundColor Cyan
            Write-Host "            Должность      : Title" -ForegroundColor Cyan
            Write-Host "            Отдел          : Department" -ForegroundColor Cyan
            Write-Host "            Компания       : Company" -ForegroundColor Cyan
            Write-Host "            Активирована   : Enabled" -ForegroundColor Cyan 
            Write-Host " Пример: Name,SamAccountName,Mail,Title" -ForegroundColor DarkCyan
            $UsrInput2 = Read-Host " Введите свойство учётной записи"
            $UsrInput2 = $UsrInput2.ToLower()

            # Условие проверяющее правильность ввода, а именно ", "
            if ($UsrInput2.Contains(", ")) {
                Start-Sleep -Milliseconds 500 
                Write-Host  " ОШИБКА: Неверно введены свойства учётной записи. Смотри пример. `n" -ForegroundColor Red
            }
            else {
                Start-Sleep -Milliseconds 500
                Write-Host " ОК`n" -ForegroundColor Green
                break 
            } 
            
        }

        if ($UsrInput2.Contains(",")) {
            Get-ADUser -SearchBase $LDAPdName1 -Filter * -Properties * | Select-Object $UsrInput2.Split(",") | Sort-Object Name | Format-Table -AutoSize | more
        }
        else {
            Get-ADUser -SearchBase $LDAPdName1 -Filter * -Properties * | Select-Object $UsrInput2 | Sort-Object Name | Format-Table -AutoSize | more
        }

        Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
        echo " "
    }

    # 3. Создать список
    elseif ($UsrInput1 -eq 3) {
        echo " "
        Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
        echo " "

        # Name
        while ($true) {
            Write-Host " Задаём переменной 'Name' имя файла в текстовом формате txt" -ForegroundColor Yellow
            Write-Host " Пример: Департамет ИТ.txt" -ForegroundColor DarkCyan
            $Name = Read-Host " Введите имя"

            if ($Name.EndsWith(".txt")) {
                Start-Sleep -Milliseconds 500
                Write-Host " ОК`n" -ForegroundColor Green
                break 
            }
            else {
                Start-Sleep -Milliseconds 500
                Write-Host  " ОШИБКА: Неверно указан формат файла. Требуется указать txt формат. Смотри пример.`n" -ForegroundColor Red
            }
        }

        # Path
        while ($true) {
            Write-Host " Задаём переменной 'Path' путь к месту хранения файла" -ForegroundColor Yellow
            Write-Host " Пример: C:\Users\Ivanov\Documents\" -ForegroundColor DarkCyan
            $Path = Read-Host " Введите путь"

            if (($Path.Contains(":\")) -and ($Path.EndsWith("\"))) {
                Start-Sleep -Milliseconds 500
                Write-Host " ОК`n" -ForegroundColor Green
                break
            }
            else {
                Start-Sleep -Milliseconds 500
                Write-Host  " ОШИБКА: Неверно указан путь. Смотри пример.`n" -ForegroundColor Red
            }
        }

        # LDAPdName2
        while ($true) {
            Write-Host " Задаём переменной 'LDAPdName2' distinguishedName из LDAP каталога Active Directory" -ForegroundColor Yellow
            Write-Host " Пример: OU=Департамет ИТ,OU=Users,DC=example,DC=local" -ForegroundColor DarkCyan
            $LDAPdName2 = Read-Host " Введите distinguishedName контейнера (OU)"

            # Условие проверяющее правильность написания distinguishedName
            if (($LDAPdName2.Contains("OU=") -and $LDAPdName2.Contains("DC="))) {
                Start-Sleep -Milliseconds 500
                Write-Host " ОК`n" -ForegroundColor Green
                break
            }
            else {
                Start-Sleep -Milliseconds 500
                Write-Host  " ОШИБКА: Неверно указан distinguishedName. Смотри пример.`n" -ForegroundColor Red
            }   
        }

        # Получаем список пользователей и сохраняем его в файл
        $ADUsers = Get-ADUser -SearchBase $LDAPdName2 -Filter * -Properties * | Where-Object {$_.Enabled -like "$true"} | 
            Select-Object SamAccountName | Sort-Object SamAccountName | Format-Table -HideTableHeaders | Out-File $Path$Name 

        # Перезаписываем файл '$Name' с параметром 'Trim()',  который удаляет все начальные и конечные пробелы из текущего объекта String
        $ADUsers = ((Get-Content $Path$Name) -join [environment]::NewLine).Trim() | Set-Content -Path $Path$Name

        Write-Host " Список пользователей выгружен в вайл $Name в директорию $Path" -ForegroundColor Green

        while ($true) {
            Write-Host " `n Посмотреть список $Name?"
            $UsrInput3 = Read-Host " Введите (Yes[y]/No[n])"
            $UsrInput3 =  $UsrInput3.ToLower()
            
            echo " "

            if (($UsrInput3 -like "y") -or (($UsrInput3 -like "yes"))) {
                $ListUsers = Get-Content $Path$Name

                if ($ListUsers -eq $null) {
                    Start-Sleep -Milliseconds 500
                    Write-Host " Файл $Path$Name ничего не содержит.`n" -ForegroundColor Red
                    break
                }
                else {
                    Start-Sleep -Milliseconds 500
                    $ListUsers
                    break
                }
            }
            elseif (($UsrInput3 -like "n") -or (($UsrInput3 -like "no"))) {
                break
            }
            else {
                Write-Host " ОШИБКА: Неверно введена команда." -ForegroundColor Red
            }
        }
        echo " "
        Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
        echo " "
    }

    # 4. Добавить пользователей в группу доступа (Security Group)
    elseif ($UsrInput1 -eq 4){
        echo " "
        Write-Host "<---------------------------------------------START--------------------------------------------->`n" -ForegroundColor Red -BackgroundColor White

        if (($Path -eq $null) -or ($Name -eq $null)) {
            Write-Host " ОШИБКА: Необходимо создать список выбрав пункт 3." -ForegroundColor Red
        }
        else {
            # Задаём переменной '$ADUsers' получить список пользователей из файла '$Name'
            $ADUsers = (Get-Content $Path$Name).Trim()
        
            Write-Host " Задаём переменной 'ADGroup' название группы как в Active Directory`n Пример: RO_Департамент ИТ" -ForegroundColor Yellow
            $ADGroup = Read-Host " Введите имя группы доступа (Security Group)"
            Start-Sleep -Milliseconds 500
            Write-Host " ОК`n" -ForegroundColor Green

            $UsrInput4 = Read-Host " Подтвердите действие (Yes[y]/No[n])"
            $UsrInput4 = $UsrInput4.ToLower()
        
            if (($UsrInput4 -like "y") -or ($UsrInput4 -like "yes")) {

				# Задаем итерацию по списку пользователей
                foreach ($ADUser in $ADUsers) {
                    Start-Sleep -Milliseconds 500

                    # Добавляем пользователя в группу
                    Add-ADGroupMember -Identity $ADGroup -Members $ADUser

                    # Задаём переменной '$GetMemeber' получить пользователя в группе
                    $GetMember = Get-ADGroupMember -Identity $ADGroup | Where-Object {$_.SamAccountName -like $ADUser} | Select-Object SamAccountName

                    # Если пользователь есть в группе, то выводится в консоль SamAccountName пользователя в зеленом цвете, если нет, то в красном цвете
                    if ($GetMember) {Write-Host " $ADUser" -ForegroundColor Green} else {Write-Host " $ADUser" -ForegroundColor Red}
                }
            }
            elseif (($UsrInput4 -like "n") -or ($UsrInput4 -like "no")) {
		    Start-Sleep -Milliseconds 500
	            Write-Host " Добавление пользователей отменено.`n" -ForegroundColor Green
            }
        }
        echo " "
        Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
        echo " "
    }

    # 5. Выход
    elseif ($UsrInput1 -eq 5) {
        echo " "
        Write-Host "############################################`n# GOOD JOB! Good day for you!              #`n############################################`n# PS: Keep Calm and Call t3hc0nnect10n! =) #`n############################################`n" -ForegroundColor Magenta
        break
    }
}
