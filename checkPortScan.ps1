# "20/TCP"       (FTP)                  FTP-DATA — для передачи данных FTP
# "21/TCP"       (FTP)                  Для передачи команд FTP
# "22/TCP,UDP"   (SSH)                  Secure SHell — криптографический сетевой протокол для безопасной передачи данных
# "23/TCP,UDP"   (TELNET)               Telnet — применяется для передачи текстовых сообщений в незашифрованном виде
# "25/TCP,UDP"   (SMTP)                 Simple Mail Transfer Protocol — применяется для пересылки почтовых сообщений в виде незашифрованного текста
# "53/TCP,UDP"   (DOMAIN)               DNS - Domain Name System
# "80/TCP,UDP"   (HTTP)                 HyperText Transfer Protocol (ранее — WWW)
# "81/TCP,UDP"   (HTTP), (HOSTS2-NS)    HyperText Transfer Protocol (используется в приложениях проекта Tor для целей маршрутизации), HOSTS2-NS - Name Server
# "88/TCP,UDP"   (KERBEROS)             Система аутентификации
# "135/TCP,UDP"  (RPC)                  MSRPC (Microsoft RPC[6]) — используется в приложениях «клиент—сервер» Microsoft (например, Exchange)
# "135/TCP,UDP"  (RPC)                  OC-SRV (Locator service) — используется службами удалённого обслуживания (DHCP, DNS, WINS и т. д.)
# "389/TCP,UDP"  (LDAP)                 Lightweight Directory Access Protocol
# "443/TCP,UDP"	 (HTTPS)                HyperText Transfer Protocol Secure — HTTP с шифрованием по SSL или TLS 
# "445/TCP,UDP"	 (MICROSOFT-DS)         Используется в Microsoft Windows 2000 и поздних версий для прямого TCP/IP-доступа без использования NetBIOS (например, в Active Directory)
# "993/TCP,UDP"	 (IMAPS)                Internet Message Access Protocol с шифрованием по SSL или TLS
# "636/TCP,UDP"  (LDAPS)                Lightweight Directory Access Protocol Secure — LDAP с шифрованием по SSL или TLS
# "3268/TCP,UDP" (MSFT-GC)              Microsoft Global Catalog (LDAP service which contains data from Active Directory forests)
# "3269/TCP,UDP" (MSFT-GC-SSL)          Microsoft Global Catalog over SSL (similar to port 3268, LDAP over SSL)
# "3389/TCP"     (RDP)                  Microsoft Terminal Server официально зарегистрировано как Windows Based Terminal (WBT)
# "5985/TCP"     (WinRM HTTP)           По умолчанию в Windows 7 и более поздних версиях WinRM HTTP. В более ранних версиях Windows в WinRM HTTP используется порт 80
# "5986/TCP"     (WinRM HTTPS)          По умолчанию в Windows 7 и более поздних версиях WinRM HTTPS. В более ранних версиях Windows в WinRM HTTPS используется порт 443
# "8080/TCP"     (HTTP-ALT)              Альтернативный порт HTTP (http_alt) — обычно используется для организации веб-прокси и кэширующих серверов, запуска веб-сервера от имени не-root пользователя

# В переменной "$Ports" указаны порты через запятую, который мы хотим ппросканировать 
$Ports  = "20", "21", "22", "23", "25", "53", "80", "81", "88", "135", "389", "443", "445", "636", "993", "3268", "3269", "3389", "5985", "5986", "8080"

# Переменной  "$AllHosts" задано брать список IP адресов из файла
$AllHosts = Get-Content -Path "С:\Users\Ivan\Desktop\ipListHosts.txt" # Указываем путь к файлу, в котором указан список ip адресов, напимер: "С:\Users\Ivan\Desktop\ipListHosts.txt"

# Запуск цикла по кажлому IP адресу "$Hosts" из списка "$AllHosts"
ForEach($Hosts in $AllHosts)
{
    $Hosts # Для каждого IP адреса "$Hosts" запуск цикла проверки порта "$P" из списка портов $Ports" по каждому 
    Foreach ($P in $Ports){
        
        # Проверка порта "$P" IP адреса "$Hosts"
        $check=Test-NetConnection $Hosts -Port $P -WarningAction SilentlyContinue
       
        # Если результат положитеьный то вывод в зеленом цвете, либо в красном если отрицательный
        If ($check.tcpTestSucceeded -eq $true)
            {Write-Host $Hosts.name  $P -ForegroundColor Green -Separator " => "}
        else 
            {Write-Host $Hosts.name  $P -ForegroundColor Red -Separator " => "}
    }
}


# 1. Разкомментируйте скрипт ниже, если есть доменнная инфраструктура
# $AllDCs = Get-ADDomainController -Filter * | Select-Object Hostname,Ipv4address,isGlobalCatalog,Site,Forest,OperatingSystem
# ForEach($DC in $AllDCs)
# {
#     Foreach ($P in $Ports){
#         $check=Test-NetConnection $DC -Port $P -WarningAction SilentlyContinue
#         If ($check.tcpTestSucceeded -eq $true)
#             {Write-Host $DC.name $P -ForegroundColor Green -Separator " => "}
#         else
#             {Write-Host $DC.name $P -Separator " => " -ForegroundColor Red}
#     }
# }
#
# 2. Используйте следующую команду, чтобы отобразить имя процесса, открывшего UDP порт
# Get-NetUDPEndpoint | Select-Object LocalAddress,LocalPort,OwningProcess,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} | Sort-Object -Property LocalPort | Format-Table
#
# 3. Трассировка до хоста yandex.ru 
# Test-NetConnection yandex.ru -TraceRoute
#
# 4. Просканировать порт задав диапазон IP адресов с детальным вывод
# Foreach ($ip in 2..150) {Test-NetConnection -Port 80 -InformationLevel "Detailed" 10.3.1.$ip}
# 
# 5. Просканировать диапазон TCP портов (от 1 до 1024) на указанном сервере
# Foreach ($port in 1..1024) {If ((Test-NetConnection 10.3.1.1 -Port $port -WarningAction SilentlyContinue).tcpTestSucceeded -eq $true){ "TCP port $port is open!"}}
#
# 6. Вывести список открытых портов в Windows
# Get-NetTcpConnection -State Listen | Select-Object LocalAddress,LocalPort| Sort-Object -Property LocalPort | Format-Table
