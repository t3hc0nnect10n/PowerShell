# Задаём переменной '$Name' имя файла 'DynamicDistributionGroup' в текстовом формате 'txt'
$Name_DD = 'DynamicDistributionGroup.txt'

# Задаём переменной '$Path' путь, в котором будет сохраняться полученный файл 'DynamicDistributionGroup.txt' 
$Path = '<Указываем полный путь где будет храниться файл>'

Get-DynamicDistributionGroup | ForEach-Object {
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
} | Export-CSV '<Указываем полный путь где будет храниться файл>\CSV_DynamicDistributionGroupMember.csv' -NoTypeInformation -Encoding UTF8