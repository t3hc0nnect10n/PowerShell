# Добавляем в ISE оснастку для работы с Exchange
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Задаём переменной '$Name' имя файла 'DistributionGroup' в текстовом формате 'txt'
$Name = 'DistributionGroup.txt'
# Задаём переменной '$Path' путь, в котором будет сохраняться полученный файл 'DGroup.txt' 
$Path = '<Указываем полный путь где будет храниться файл>'

# Получаем список почтовых групп рассылок и сохраняем его в файл 'DistributionGroup.txt'
# Параметр 'HideTableHeader' удаляет заголовок
$DGroup = Get-DistributionGroup | Select-Object Name | Format-Table -HideTableHeaders | Out-File $Path$Name 

# Перезаписываем файл 'DistributionGroup.txt' с параметром 'Trim()', который удаляет все начальные и конечные пробелы из текущего объекта String
$DGroup = ((Get-Content $Path$Name) -join [environment]::NewLine).Trim() | Set-Content -Path $Path$Name

# Задаём переменной '$DGroup' получить список почтовых групп рассылок из файла 'DistributionGroup.txt'
$DGroup = (Get-Content $Path$Name).Trim()

echo ' '
Write-Host '<---------------------------------------------START--------------------------------------------->' -ForegroundColor Red -BackgroundColor White
Write-Host '<------------------------ Full выгрузка сведений почтовых групп рассылок ------------------------>' -ForegroundColor Black -BackgroundColor White 

# Задаём переменной '$OutputMemberFull' итерацию по списку почтовых групп расссылок
$OutputMemberFull = foreach ($Group in $DGroup) {

    # Вывод в консоль именование почтовой группы рассылки в зеленом цвете
    Write-Host ''$Group'' -ForegroundColor Green
    
    # Получаем сведения участников почтовых групп рассылок: ФИО, Гланый почтовый адрес, Дополнительные почтовые адреса, Должность, Отдел, Компания 
    Get-DistributionGroupMember $Group | Select-Object Name, PrimarySmtpAddress, @{Name='EmailAddresses'; Expression={$_.EmailAddresses -join ", "}}, Title, Department, Company | Sort-Object Name
}

echo ' '
Write-Host '<------------------------ Light выгрузка сведений почтовых групп рассылок ----------------------->' -ForegroundColor Black -BackgroundColor White 

# Задаём переменной '$OutputMemberLight' итерацию по списку почтовых групп расссылок
$OutputMemberLight = foreach ($Group in $DGroup) {
    
    # Вывод в консоль именование почтовой группы рассылки в зеленом цвете
    Write-Host ''$Group'' -ForegroundColor Green
    
    # Получаем имя почтовой групы рассылки
    Get-DistributionGroup $Group | Select-Object Name
    
    # Получаем сведения участников почтовых групп рассылок: ФИО
    Get-DistributionGroupMember $Group | Select-Object Name
    echo ' '
}

Write-Host '<---------------------------------------------FINISH--------------------------------------------->' -ForegroundColor Red -BackgroundColor White


# Full выгрузка сведений почтовых групп рассылк в файл 'CSV_FullDistributionGroupMember.csv'
$OutputMemberFull | Export-CSV '<Указываем полный путь где будет храниться файл>\CSV_FullDistributionGroupMember.csv' -Encoding UTF8

# Light выгрузка сведений почтовых групп рассылк в файл 'CSV_LightDistributionGroupMember.csv'
$OutputMemberLight | Export-CSV '<Указываем полный путь где будет храниться файл>\CSV_LightDistributionGroupMember.csv' -Encoding UTF8
