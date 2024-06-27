<#
    Скрипт обращается к каталогу Active Directory и добавляет в группу безопасности пользователя по атрибуту 'Name' - ФИО
#>

echo " "
Write-Host "################################################" -ForegroundColor Magenta
Write-Host "# Hellow Senior System Administrator, Lets go! #" -ForegroundColor Magenta
Write-Host "################################################" -ForegroundColor Magenta
echo " "

sleep 1

# Функция 'PasteUsersList' выполняет добавление пользователя в группу безопасности вставив в консоль сформированный список пользователей по ФИО.
# Пример сформированного списка: 'Иванов Иван Иванович','Сидоров Иван Иванович','Иванова Людмила Викторовна'
function PasteUsersList() {
    
    echo " "
    
    # Группа безопасности (Security Group)
    while ($true) {
        
        # Переменной 'ADGroup' задать название группы безопасности (Security Group).
        Write-Host " Задаём переменной 'ADGroup' название группы как в Active Directory" -ForegroundColor Yellow
        Write-Host " Пример: RO_Департамент ИТ" -ForegroundColor DarkCyan
        $ADGroup = Read-Host " Введите название группы доступа"

        <# 
            Используется try, catch блоки для обработки завершающих ошибок.
            Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
            https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
        #>

        try {
            # Переменной 'CheckGroup' задано получить группу безопасности
            $CheckGroup = Get-ADGroup $ADGroup

            # Проверка на существование группы безопасности в Active Directory
            if ($CheckGroup) {
                Start-Sleep -Milliseconds 500
	            echo " "
	            Write-Host " ОК" -ForegroundColor Green
	            echo " "
                break
            }
        }
        catch {
            echo " "
            Write-Host " ОШИБКА: Такой группы безопасности не существует." -ForegroundColor Red
            echo " "
        }
    }

    # Список пользователей (ФИО)
    while ($true) {
        
        Write-Host " Переменной 'ListUsers' задаём список из пользователей по ФИО." -ForegroundColor Yellow
        Write-Host " Пример списка: 'Иванов Иван Иванович','Сидоров Иван Иванович','Иванова Людмила Викторовна'" -ForegroundColor DarkCyan
        $ListUsers = [System.Collections.ArrayList]@()
        $UserListPaste = Read-Host " Вставьте список"
        
        if ($UserListPaste.Contains("'") -and $UserListPaste.Contains(",") -and $UserListPaste -notcontains " ") {
        
            $ListUsersSplit = $UserListPaste.Split(",")

            foreach ($i in $ListUsersSplit) {
                if ($i.contains("'")){
                    $ListUsers.Add($i.Replace("'","")) 
                }
            }

            Start-Sleep -Milliseconds 500
	        echo " "
	        Write-Host " ОК" -ForegroundColor Green
	        echo " "
            break
        
        }
        else{
            echo " "
            Write-Host " ОШИБКА: Неверно сформирован список. Смотри пример." -ForegroundColor Red
            echo " "
        }
    }

    echo " "
    Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
    echo " "

    foreach ($User in $ListUsers) {
    
        # Переменная 'ADUser' получает пользователя по атрибуту 'Name' (ФИО).
        $ADUser = Get-ADUser -Filter * -Properties * | Where-Object {$_.Name -like $User}

        # Добавляем пользователя в группу заданной переменной 'Group'.
        #Add-ADGroupMember -Identity $Group -Members $ADUser

        # Проверка добавления пользователя, если в группе есть, то выводится в зеленом цвете, если нет то в красном.
        if ($ADUser.MemberOf -match $ADGroup) {
            Write-Host " Сотрудник '$User' добавлен в группу '$ADGroup'" -ForegroundColor Green
        } 
        else {
            Write-Host " Сотрудник '$User' НЕ добавлен в группу '$ADGroup'" -ForegroundColor Red
        }

    }

    echo " "
    Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White

    Clear-Variable -Name "ADGroup"
    Clear-Variable -Name "ListUsers"
    Clear-Variable -Name "UserListPaste"
}

# Функция 'CreateUsersList' выполняет добавление пользователя в группу безопасности прописывая ФИО по одному.
# Пример ввода в консоли ФИО: Иванов Иван Иванович
function CreateUsersList() {
    
    echo " "
    
    # Группа безопасности (Security Group)
    while ($true) {
        
        # Переменной 'ADGroup' задать название группы безопасности (Security Group).
        Write-Host " Задаём переменной 'ADGroup' название группы как в Active Directory" -ForegroundColor Yellow
        Write-Host " Пример: RO_Департамент ИТ" -ForegroundColor DarkCyan
        $ADGroup = Read-Host " Введите название группы доступа"

        <# 
            Используется try, catch блоки для обработки завершающих ошибок.
            Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
            https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
        #>

        try {          
            # Переменной 'CheckGroup' задано получить группу безопасности
            $CheckGroup = Get-ADGroup -Identity $ADGroup

            # Проверка на существование группы безопасности в Active Directory
            if ($CheckGroup) {
                Start-Sleep -Milliseconds 500
	            echo " "
	            Write-Host " ОК" -ForegroundColor Green
	            echo " "
                break
            }
        }
        catch {
            echo " "
            Write-Host " ОШИБКА: Такой группы безопасности не существует." -ForegroundColor Red
            echo " "
        }
    }

    Write-Host " Переменной 'ListUsers' задаём список из пользователей по ФИО." -ForegroundColor Yellow
    $ListUsers = [System.Collections.ArrayList]@()

    [int]$UsersNumbers = Read-Host " Введите количество пользователей"
    
    echo " "

    for ([int]$i = 0 ; $i -ne $UsersNumbers; $i++) {
    
        Write-Host " Вводите по одному пользователю." -ForegroundColor Yellow
        Write-Host " Пример: Иванов Иван Иванович" -ForegroundColor DarkCyan
        [string]$UserInput = Read-Host " Введите ФИО"
        $ListUsers.Add($UserInput)
    
        Write-Host " ОК" -ForegroundColor Green
        echo " "

    }


    echo " "
    Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
    echo " "

    foreach ($User in $ListUsers) {
    
        # Переменная 'ADUser' получает пользователя по атрибуту 'Name' (ФИО).
        $ADUser = Get-ADUser -Filter * -Properties * | Where-Object {$_.Name -like $User}

        # Добавляем пользователя в группу заданной переменной 'Group'.
        #Add-ADGroupMember -Identity $Group -Members $ADUser

        # Проверка добавления пользователя, если в группе есть, то выводится в зеленом цвете, если нет то в красном.
        if ($ADUser.MemberOf -match $ADGroup) {
            Write-Host " Сотрудник '$User' добавлен в группу '$ADGroup'" -ForegroundColor Green
        } 
        else {
            Write-Host " Сотрудник '$User' НЕ добавлен в группу '$ADGroup'" -ForegroundColor Red
        }

    }

    echo " "
    Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White

    Clear-Variable -Name "ADGroup"
    Clear-Variable -Name "ListUsers"
    Clear-Variable -Name "UsersNumbers"
}

# Выполняемый код.
while ($true) {
    
    # Меню.
    Write-Host " 1. Задать список скопировав целиком"  -ForegroundColor Yellow
    Write-Host " 2. Задать список вводя ФИО по одному"  -ForegroundColor Yellow
    Write-Host " 3. Выход" -ForegroundColor Yellow
    [int]$UserInput = Read-Host " Введите номер команды"
    
    if ($UserInput -eq 1) {
        
        PasteUsersList

    }
    elseif ($UserInput -eq 2) {
        
        CreateUsersList
    }
    elseif ($UserInput -eq 3) {
        
        Start-Sleep -Milliseconds 500
        echo " "
        
        Write-Host "#######################################" -ForegroundColor Magenta
        Write-Host "# GOOD JOB! Good day for you!         #" -ForegroundColor Magenta
        Write-Host "#######################################" -ForegroundColor Magenta
        Write-Host "# PS: Keep Calm and Call t3hadmin! =) #" -ForegroundColor Magenta
        Write-Host "#######################################" -ForegroundColor Magenta
        break
    }
    else{
        Start-Sleep -Milliseconds 500
        echo " "
        Write-Host " ОШИБКА: Неверно введена команда." -ForegroundColor Red
        echo " "
    }
}
