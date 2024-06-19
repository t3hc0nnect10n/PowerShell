<#
    Скрипт запускать в Exchange Management Shell.

    Для выполнения скрипта необходимо обладать правами ролей Mailbox Import Export и Mailbox Search, для этого
    достаточно в Active Directory добавить учётную запись в группу безопасноcти Discovery Management.
    
    Для использования командлета Serach-MailBox необходимо задать обязательные параметры:
        
        -Identity      (Указывыем у какого пользователя необходимо найти письмо)
        -TargetMailbox (Указываем в коком почтовом ящике появится искомое письмо)
        -TargetFolder  (Указываем название папки, которое создастся в указанном почтовом ящике, в котором будет находиться искомое письмо)
   
    Также указан необязательный параметр -SearchQuery, в котором указаны следующие значения:
        
        Subject (Указываем тему искомого письма)
        Body    (Указываем ключевые слова в теле письма)
        From    (Указываем почтовый адрес отправителя искомого письма)
        Sent    (Указываем дату получения искомого письма)
    
    Существуют иные параметры командлета Search-Mailbox, которыми можно дополнить скрипт при необходимости - https://learn.microsoft.com/ru-ru/powershell/module/exchange/search-mailbox?view=exchange-ps
#>

echo " "

# Пользователь
Write-Host " Задаём переменной 'User' значение SamAccountName" -ForegroundColor Yellow
Write-Host " Пример: ivanov.i" -ForegroundColor DarkCyan
[string]$User = Read-Host " Введите SamAccountNam пользователя"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " OK" -ForegroundColor Green
echo " "

# Почтовый ящик
Write-Host " Задаём переменной 'Mailbox' почтовый ящик" -ForegroundColor Yellow
Write-Host " Пример: ivanov.i@domain.ru" -ForegroundColor DarkCyan
[string]$Mailbox = Read-Host " Введите почтовый ящик"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " OK" -ForegroundColor Green
echo " "

# Имя папки
Write-Host " Задаём переменной 'Folder' название папки" -ForegroundColor Yellow
Write-Host " Пример: SearchAndDeleteLog" -ForegroundColor DarkCyan
[string]$Folder = Read-Host " Введите название папки"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " OK" -ForegroundColor Green
echo " "

# Тема письма
Write-Host " Задаём переменной 'Subject' название темы искомого письма" -ForegroundColor Yellow
Write-Host " Пример: Срочно" -ForegroundColor DarkCyan
[string]$Subject = Read-Host " Введите тему письма"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " OK" -ForegroundColor Green
echo " "

# Тело письма
Write-Host " Задаём переменной 'Body' ключевое слово в письме" -ForegroundColor Yellow
Write-Host " Пример: Hello world" -ForegroundColor DarkCyan
[string]$Body = Read-Host " Введите ключевое слово"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " OK" -ForegroundColor Green
echo " "

# Отправитель
Write-Host " Задаём переменной 'Sender' почтовый адрес отправителя" -ForegroundColor Yellow
Write-Host " Пример: sidorov.i@domain.ru" -ForegroundColor DarkCyan
[string]$Sender = Read-Host " Введите почтовый адрес отправителя"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " OK" -ForegroundColor Green
echo " "

# Дата
Write-Host " Задаём переменной 'Date' дату получения письма" -ForegroundColor Yellow
Write-Host " Пример: 19/06/2024" -ForegroundColor DarkCyan
[string]$Date = Read-Host " Введите дату"

Start-Sleep -Milliseconds 500
echo " "
Write-Host " OK" -ForegroundColor Green
echo " "

# Получение письма
Search-Mailbox -Identity $User -TargetMailbox $Mailbox -TargetFolder $Folder -SearchQuery "(Subject:$Subject) AND (Body:$Body) AND (From:$Sender) AND (Sent:$Date)"