# Задаём переменной $ListUsers полный путь хранения фала. 
# Например: C:\Users\Ivan\Documents\DisabledUsers.txt
echo " "
$ListUsers = Read-Host "Введите путь"

# Переменной $BlockedUsers присвоен distinguishedName контейнера, в котором хранятся отключенные учетные записи.
# Например: OU=Deactivated Users,DC=example,DC=local
echo " "
$BlockedUsers = Read-Host "Введите distinguishedName контейнера"

# Удаление лишних пробелов
$Users = Get-Content $ListUsers.Trim()

echo " "
Write-Host $Users.Count "Учётных записей" -ForegroundColor Yellow
echo " "

foreach ($User in $Users) {
    
    # Перемещение пользователя в контейнер заданной переменной $BlockedUsers
    Get-ADUser $User | Move-ADObject -TargetPath $BlockedUsers
    
    # Отключение учетной записи
    Disable-ADAccount -Identity $User
    
    # Переменная $Groups получает все группы безопасности пользователя кроме "Пользователи домена"
    $Groups = Get-ADPrincipalGroupMembership -Identity $User | Where {$_.Name -ne "Пользователи домена"}
    
    # Цикл проходит по каждой группе безопасности и удаляет пользователя из неё 
    foreach ($Group in $Groups) {
        
        Remove-ADGroupMember -identity $Group.name -Members $User -Confirm:$false
    }

    # Переменная $Name выводит в консоль ФИО в виде массива
    $Name = Get-ADUser $User -Properties * | Select-Object Name
    
    # Переменная $Check проверяет на наличие отключенной учетной записи в контейнере заданной переменной $BlockedUsers
    $CheckUser = Get-ADUser -Filter * -SearchBase $BlockedUsers -Properties * | Where-Object {$_.Enabled -like $false -and $_.SamAccountName -like $User}
    
    # Переменная $CheckGroup получает список групп, в которые входит пользователь
    $CheckGroup = Get-ADPrincipalGroupMembership -Identity $User | Select-Object Name

    # Условие проверки на выполнение отключения учетной записи, наличие группы безопасности "Пользователи домена" и перемещение в контейнер заданной переменной $BlockedUsers, 
    # Если условие истинно, то в консоль выводится ФИО, SamAccountName и группы безопасности в зелёном цвете, если нет, то в красном. 
    if ($CheckUser) {Write-Host $Name $User "- заблокирован. Группы доступа:" $CheckGroup -ForegroundColor Green} 
    else {Write-Host $Name $User "- не заблокирован. Группы доступа:" $CheckGroup -ForegroundColor Red}

}
