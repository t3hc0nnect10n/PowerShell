# Добавляем в ISE оснастку для работы с Exchange
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Задаём переменной '$Name' имя файла 'DistributionGroup' в текстовом формате 'txt'
$Name = 'DistributionGroup.txt'
# Задаём переменной '$Path' путь, в котором будет сохраняться полученный файл 'DistributionGroup.txt' 
$Path = '<Указываем полный путь где будет храниться файл>' # Вместо <Указываем полный путь где будет храниться файл> пишем путь, например: C:\Users\Ivan\Documents\

# Получаем список почтовых групп рассылок и сохраняем его в файл 'DistributionGroup.txt'
# Параметр 'HideTableHeader' удаляет заголовок
$DGroup = Get-DistributionGroup | Select-Object Name | Format-Table -HideTableHeaders | Out-File $Path$Name 

# Перезаписываем файл 'DistributionGroup.txt' с параметром 'Trim()', который удаляет все начальные и конечные пробелы из текущего объекта String
$DGroup = ((Get-Content $Path$Name) -join [environment]::NewLine).Trim() | Set-Content -Path $Path$Name

# Задаём переменной '$DGroup' получить список почтовых групп рассылок из файла 'DistributionGroup.txt'
$DGroup = (Get-Content $Path$Name).Trim()

echo " "
Write-Host "<---------------------------------------------START--------------------------------------------->" -ForegroundColor Red -BackgroundColor White
echo " "

# Задаём переменной '$Output' итерацию по списку почтовых групп расссылок
$Output = foreach ($Group in $DGroup) {

    # Вывод в консоль именование почтовой группы рассылки в зеленом цвете                                       
    Write-Host " $Group" -ForegroundColor Green
    
    # Получаем имя почтовой групы рассылки
    Get-DistributionGroup $Group | Select-Object Name, DisplayName, PrimarySmtpAddress, @{Name='EmailAddresses'; Expression={$_.EmailAddresses -join ", "}}, Title, Department, Company
    
    # Получаем сведения участников почтовых групп рассылок: ФИО, Гланый почтовый адрес, Дополнительные почтовые адреса, Должность, Отдел, Компания 
    Get-DistributionGroupMember $Group | Select-Object '$null', DisplayName, PrimarySmtpAddress, @{Name='EmailAddresses'; Expression={$_.EmailAddresses -join ", "}}, Title, Department, Company | Sort-Object DisplayName 

}
echo " "
Write-Host "<---------------------------------------------FINISH--------------------------------------------->" -ForegroundColor Red -BackgroundColor White

# Выгрузка сведений почтовых групп рассылк в файл 'CSV_DistributionGroupMember.csv'
# Вместо <Указываем полный путь где будет храниться файл> пишем путь, например: C:\Users\Ivan\Documents\
$Output | Export-CSV '<Указываем полный путь где будет храниться файл>\CSV_DistributionGroupMember.csv' -NoTypeInformation -Encoding UTF8 
