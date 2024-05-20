# Скрипт запускаем в Exchange Management Shell

# Задаём переменной '$Name' имя файла 'DynamicDistributionGroup' в формате 'csv' где значения разделены спецсимволами
$Name = 'CSV_DynamicDistributionGroupMember.csv'

# Задаём переменной '$Path' путь, в котором будет сохраняться полученный файл 'CSV_DynamicDistributionGroupMember.csv'
# Вместо <Указываем полный путь где будет храниться файл> пишем путь, например: C:\Users\Ivan\Documents\
$Path = '<Указываем полный путь где будет храниться файл>' 

# Вызываем итерацию по каждой динамической почтовой группе рассылок 
$Output = Get-DynamicDistributionGroup | ForEach-Object {
    
    # Выводим свойства объекта получателя состоящий в динамической почтовой группе рассылки
    foreach ($recipient in Get-Recipient -RecipientPreviewFilter $_.RecipientFilter -ResultSize Unlimited) {
        [pscustomobject]@{
            DistributionGroup  = $_.Name
            Recipient          = $recipient.Name
            PrimarySmtpAddress = $recipient.PrimarySmtpAddress
            EmailAddresses     = $recipient.EmailAddresses
            Title              = $recipient.Title
            Department         = $recipient.Department
            Company            = $recipient.Company
        } 
    }
}

# Выгрузка сведений почтовых групп рассылок в файл 'CSV_DynamicDistributionGroupMember.csv'
$Output | Export-CSV $Path$Name -NoTypeInformation -Encoding UTF8
