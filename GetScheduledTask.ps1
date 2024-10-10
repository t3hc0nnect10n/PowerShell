<#
    Скрипт производит выгрузку в файл формата "CSV" всех заданий в планировщике задач серверов находящиеся в каталое ActiveDirectory.
    Цель заключается в получении параметров заданий: 
        
        $PSItem.Actions.Arguments - аргумент действия.
        $PSItem.Principal.Id      - от какой учётной записи производится запуск.
       
    Запускать от имена администратора в PowerShell ISE. 
#>

# Переменная $SRV_MSK получакется список имён серверов находящиеся в организационном подразделение "OU=SRV MSK,OU=Servers,DC=example,DC=local" по атрибуту "DistinguishedName"
$SRV_MSK = (Get-ADComputer -Filter * | Where-Object {$_.Enabled -like $True -and $_.DistinguishedName -match "OU=SRV MSK,OU=Servers,DC=example,DC=local"}).Name
# Переменная $SRV_SPB получакется список имён серверов находящиеся в организационном подразделение "OU=SRV MSK,OU=Servers,DC=example,DC=local" по атрибуту "DistinguishedName"
$SRV_SPB = (Get-ADComputer -Filter * | Where-Object {$_.Enabled -like $True -and $_.DistinguishedName -match "OU=SRV SPB,OU=Servers,DC=example,DC=local"}).Name

# Переменной $ServersArray задаём массив полученых списков.
$ServersArray = @(
    $SRV_MSK, 
    $SRV_SPB
)

$Log = "log"
$Csv = "ScheduledTask.csv"

# Переменная $Date получает текущую дату.
$Date = Get-Date

# Переменная $PathRoot получает полный путь директории из которой запускается скрипт.
$PathRoot = $MyInvocation.MyCommand.Path | Split-Path -parent
[string]$Path ="$PathRoot\" 

# Условие проверки файла "log" в директории откуда запускается скрипт. Если файла нет, то он создается.
if (-Not (Test-Path $Path$Log)) {
    New-Item -Path $Path -Name log -ItemType File
}
echo " "
Write-Host " " -NoNewline
Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
echo " "
# В переменной $Result записывается результат цикла for, в котором производится итерация массивов в переменной $ServersArray.
$Result = for ( $i = 0; $i -lt $ServersArray.count; $i++ ) {
    
    # Переменная $Servers получает массив по индексу.
    $Servers = $ServersArray[$i]
    
    # В цикле foreach запускается итерация по каждому серверу.
    foreach ($Server in $Servers) {
        <#
	        Используется try, catch блоки для обработки завершающих ошибок.
	        Полное описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
	        https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
        #>
        # Запускается блок 'try', в котором выполняется проверка соединения с сервером.
        try {
            # Переменная $TestConnetion получает результат соединения с компьютером.
            $TestConnection = Test-Connection $Server -Count 1 -ErrorAction Stop
            
            # Условие проверки соединения с компьютером.
			# Если истина, то выполняется тело условия.
            if ($TestConnection) {
                Write-Host " $Server" -NoNewline
                Write-Host " в cети" -ForegroundColor Green

                # Команда Invoke-Command отправляет серверу ScriptBlock, в котором задано получить список всех заданий.
                Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {
                    Get-ScheduledTask | Select-Object -Property PSComputerName, TaskName, State,
                    @{
                        Name        = 'GroupId'
                        Expression = {$PSItem.Actions.Arguments}},
                    @{
                        Name        = 'Id'
                        Expression = {$PSItem.Principal.Id}
                    }
                }
            }
        }
        # Блок catch улавливает завершающую ошибку.
        catch {
            Write-Host ""
            Write-Warning $Server
            Write-Host $($_.Exception.Message)
            Add-Content -Path $Path$Log -Value ("[$Date][$Server] $($_.Exception.Message)","")
            Write-Host ""
        }
    } 
} 
echo " "
Write-Host " " -NoNewline
Write-Host "<---------------------------------------------FINISH-------------------------------------------->" -ForegroundColor Red -BackgroundColor White
echo " " 
# Полученный результат в переменной $Result сохраняется в файл формата "CSV" в директорию из которой запускается скрипт.
$Result | Export-Csv -Path $Path$Csv -NoTypeInformation -Encoding UTF8