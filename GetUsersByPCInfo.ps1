#################################################################################################################
# Made by t3hc0nnect10n                                                                                         #
#################################################################################################################
# Создание настраиваемого графического поля ввода                                                               #
# https://learn.microsoft.com/ru-ru/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.4#
#################################################################################################################

# Скрипт предоставляет сведения по пользователю, а именно на каком устройстве происходила аутентификация.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Cоздание экземпляра класса "Форма".
$form = New-Object System.Windows.Forms.Form
$form.Text = 'UsersByPCInfo'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

# Созданиее кнопки "OК" для формы.
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

# Созданиее кнопки "Cancel" для формы.
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

# Создание метки в окне в виде текста.
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Введите учётную запись AD (SamAccountName)'
$form.Controls.Add($label)

# Создание элемента управления, который позволит пользователям указать сведения, описанные в тексте метки.
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

# Установка значение $true для Topmost, чтобы принудительно открыть окно поверх других диалоговых окон.
$form.Topmost = $true

# Создание следующей строки кода, чтобы активировать форму и установить фокус на текстовое поле, которое создали.
$form.Add_Shown({$textBox.Select()})

# Отображения формы в Windows.
$result = $form.ShowDialog()


# Код внутри блока If указывает Windows, что следует делать с формой после того, как пользователь задаст текст в поле и нажмет кнопку ОК или клавишу ВВОД.
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    # Вывод информации свойства учётной записи
    Get-ADUser $textBox.Text -Properties *  | Select-Object DisplayName, SamAccountName, info | Sort DisplayName | Out-GridView -Title "Информация по логонам" -Wait
}
