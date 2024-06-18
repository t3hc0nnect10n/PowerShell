# Задаём переменной $ListUsers полный путь хранения фала. 
# Например: C:\Users\Ivan\Documents\DisabledUsers.txt
$ListUsers = Read-Host "Введите путь"

# Переменной $BlockedUsers присвоен distinguishedName контейнера, в котором хранятся отключенные учетные записи.
# Например: OU=Deactivated Users,DC=example,DC=local
$BlockedUsers = Read-Host "Введите distinguishedName контейнера"

# Удаление лишних пробелов
$Users = Get-Content $ListUsers.Trim()

echo " "
Write-Host $Users.Count "Учётных записей" -ForegroundColor Yellow
echo " "

foreach ($User in $Users) {
    
    # Перемещение пользователя в контейнер OU=Blocked Users
    Get-ADUser $User | Move-ADObject -TargetPath $BlockedUsers
    
    # Отключение учетной записи
    Disable-ADAccount -Identity $User

    # Переменная $Groups получает все группы безопасности пользователя кроме "Пользователи домена"
    $Groups = Get-ADPrincipalGroupMembership -Identity $User | Where {$_.Name -ne "Пользователи домена"}
    
    # Цикл проходит по каждой группе безопасности и удаляет пользователя из неё 
    foreach ($Group in $Groups) {
        
        Remove-ADGroupMember -identity $Group.name -Members $User -Confirm:$false
    }

    # Переменная $Check проверяет на наличие отключенной учетной записи в контейнере OU=Blocked Users 
    $Check = Get-ADUser -Filter * -SearchBase $BlockedUsers -Properties * | Where-Object {$_.Enabled -like $false -and $_.SamAccountName -like $User}
    
    # Переменная $Name выводит в консоль ФИО в виде массива
    $Name = Get-ADUser $User -Properties * | Select-Object Name

    # Условие проверки на выполнение отключения учетной записи и перемещение в контейнер OU=Blocked Users, 
    # Если условие истинно, то в консоль выводится ФИО и SamAccountName в зелёном цвете, если нет, то в красном. 
    if ($Check) {Write-Host $Name $User "заблокирован" -ForegroundColor Green} else {Write-Host $Name $User "не заблокирован" -ForegroundColor Red}

}
