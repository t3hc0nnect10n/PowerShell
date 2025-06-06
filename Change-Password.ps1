<#
	Made by t3hc0nnect10n (c) 2025
	Version 1.0

	Сценарий создаёт форму для смены пароля доменной учётной записи пользователя.

	Пароль должен отвечать требованиям сложности:
		
		- Состоять из латинских букв.
		- Иметь длину не менее 8 знаков.
		- Содержать знаки из четырех перечисленных ниже категорий:

			- Латинские заглавные буквы (от A до Z).
			- Латинские строчные буквы (от a до z).
			- Цифры (от 0 до 9).
			- Отличающиеся от букв и цифр знаки (например, !, $, #, %).

	Функции:

		1. Функция генерирования надежного пароля.
		2. Функция преобразования пароля.
		3. Функция проверки плохого пароля.
		4. Функция проверки сложности новго пароля.
		5. Функция cмены пароля.

	Рекомендации:
		
		Создать исполняемый exe-файл с помощью PowerShell-модуля PS2EXE
		https://windowsnotes.ru/powershell-2/kak-skonvertirovat-powershell-v-exe/
#>

$Version = "1.0"

# Список плохихих паролей.
$Array_Bad_Password = [System.Collections.ArrayList]@("qwerty","qwerty123","qwerty1234","qwerty123!","qwerty1234!","qwerty123#","qwerty1234#",
													  "Qwerty","Qwerty123","Qwerty1234","Qwerty123!","Qwerty1234!","Qwerty123#","Qwerty1234#",
													  "QWERTY","QWERTY123","QWERTY1234","QWERTY123!","QWERTY1234!","QWERTY123#","QWERTY1234#",
													  "1q2w3e","1q2w3e4r","1q2w3e!","1q2w3e#","1Q2W3E","1Q2W3E!","1Q2W3E#","1Q2W3E4R","1Q2W3E4R!","1Q2W3E4R#",
													  "!qaz@wsx","123QWEasd","!@#123QWEqweASDasd","!@#123qweQWEasdASD","1qaz2wsx",
													  "Passw0rd","P@$$W)rd","P@$$Word","P@ssword","P@ssw0rd","PASSWORD",
													  "Passw0rd123","P@$$W)rd123","P@$$Word123","P@ssword123","P@ssw0rd123","PASSWORD123",
													  "Passw0rd1234","P@$$W)rd1234","P@$$Word1234","P@ssword1234","P@ssw0rd1234","PASSWORD1234")

# Английский алфавит заглавных букв.
$Alphabet_Uppper = [char[]]([char]"A"..[char]"Z") -join " "

# Английский алфавит строчных букв.
$Alphabet_Lower  = [char[]]([char]"a"..[char]"z") -join " "

# Цифры.
$Integer         = [char[]]([char]"0"..[char]"9") -join " "

# Специальные символы.
$Symbol = [char]33+" "+[char]34+" "+[char]35+" "+[char]36+" "+[char]37+" "+[char]38+" "+[char]39+" "+[char]40+" "+[char]41+" "+[char]42+" "+`
		  [char]43+" "+[char]44+" "+[char]45+" "+[char]46+" "+[char]47+" "+[char]58+" "+[char]59+" "+[char]60+" "+[char]61+" "+[char]62+" "+`
		  [char]63+" "+[char]64+" "+[char]91+" "+[char]92+" "+[char]93+" "+[char]124+" "+[char]94+" "+[char]123+" "+[char]125+" "+[char]126

# Добавляем класс пользовательского интерфейса. https://learn.microsoft.com/ru-ru/dotnet/desktop/winforms/overview/
Add-Type -AssemblyName System.Windows.Forms

# Добавляем класс по работе с изображениями. https://learn.microsoft.com/ru-ru/dotnet/api/system.windows.media.drawing?view=windowsdesktop-8.0
Add-Type -AssemblyName System.Drawing

#функции для включения визуальных стилей для приложения. https://learn.microsoft.com/ru-ru/dotnet/api/system.windows.forms.application.enablevisualstyles?view=windowsdesktop-9.0
[System.Windows.Forms.Application]::EnableVisualStyles()
 
# Параметры формы.
$Form                  = New-Object system.Windows.Forms.Form
$Form.ClientSize       = New-Object System.Drawing.Point(420,590)
$Form.text             = "Смена пароля. Версия $($Version)"
$Form.TopMost          = $True
$Form.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#8dbbf3")

# Полный путь к изображению.
$ImagePath             = "<Укажите полный путь к логотипу компании>" # Формат изображения png, jpg, jpeg.

# Параметры изображения.
$Image                 = [System.Drawing.Image]::FromFile($ImagePath)
$PictureBox            = New-Object System.Windows.Forms.PictureBox
$PictureBox.Size       = New-Object System.Drawing.Size(200, 150)
$PictureBox.Location   = New-Object System.Drawing.Point(120, 20)
$PictureBox.Image      = $Image

# Параметры текста в форме.
$Label_                = New-Object system.Windows.Forms.Label
$Label_.text           = "Новый пароль должен отвечать требованиям сложности.`n" +`
						 "Не содержать имени учётной записи.`n" +`
						 "Иметь длину не менее 8 знаков.`n" +`
						 "Содержать знаки из четырёх перечисленных ниже категорий:`n" +`
						 "`n1. Латинские заглавные буквы:`n" +`
						 "     $($Alphabet_Uppper)`n" +`
						 "`n2. Латинские строчные буквы:`n" +`
						 "     $($Alphabet_Lower)`n" +`
						 "`n3. Цифры:`n" +`
						 "     $($Integer)`n" +`
						 "`n4. Специальные символы:`n" +`
						 "      $($Symbol)"
$Label_.AutoSize       = $True
$Label_.location       = New-Object System.Drawing.Point(10,70)
$Label_.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Параметры текста в форме. 
$Label0                = New-Object system.Windows.Forms.Label
$Label0.text           = "Пример надёжного пароля:"
$Label0.AutoSize       = $True
$Label0.location       = New-Object System.Drawing.Point(10,320)
$Label0.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Параметры текста в форме. 
$Labelp                = New-Object system.Windows.Forms.Label
$Labelp.text           = ".g1zz]%M2Ops"
$Labelp.AutoSize       = $True
$Labelp.location       = New-Object System.Drawing.Point(190,320)
$Labelp.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Labelp.ForeColor      = [System.Drawing.ColorTranslator]::FromHtml("#FFA0522D") # Sienna

# Параметры текста в форме. 
$Label1                = New-Object system.Windows.Forms.Label
$Label1.text           = "Введите cтарый пароль"
$Label1.AutoSize       = $True
$Label1.location       = New-Object System.Drawing.Point(10,345)
$Label1.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))

# Параметры окна для пользовательского ввода старого пароля.
$TextBox1              = New-Object system.Windows.Forms.MaskedTextBox
$TextBox1.AutoSize     = $True
$TextBox1.PasswordChar = '*'
$TextBox1.width        = 400
$TextBox1.height       = 25
$TextBox1.location     = New-Object System.Drawing.Point(10,365)
$TextBox1.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Параметры текста в форме. 
$Label2                = New-Object system.Windows.Forms.Label
$Label2.text           = "Введите новый пароль"
$Label2.AutoSize       = $True
$Label2.location       = New-Object System.Drawing.Point(10,395)
$Label2.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))

# Параметры окна для пользовательского ввода нового пароля.
$TextBox2              = New-Object system.Windows.Forms.MaskedTextBox
$TextBox2.AutoSize     = $True
$TextBox2.PasswordChar = '*'
$TextBox2.width        = 400
$TextBox2.height       = 25
$TextBox2.location     = New-Object System.Drawing.Point(10,415)
$TextBox2.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Параметры текста в форме. 
$Label3                = New-Object system.Windows.Forms.Label
$Label3.text           = "Повторите новый пароль"
$Label3.AutoSize       = $True
$Label3.location       = New-Object System.Drawing.Point(10,445)
$Label3.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))

# Параметры окна для пользовательского повторного ввода нового пароля.
$TextBox3              = New-Object system.Windows.Forms.MaskedTextBox
$TextBox3.AutoSize     = $True
$TextBox3.PasswordChar = '*'
$TextBox3.width        = 400
$TextBox3.height       = 25
$TextBox3.location     = New-Object System.Drawing.Point(10,465)
$TextBox3.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Уведомление в форме о несоответсвии с установленными требованиями к смене пароля.
$StatusLabel1           = New-Object System.Windows.Forms.Label
$StatusLabel1.AutoSize  = $True
$StatusLabel1.Location  = New-Object System.Drawing.Point(10, 550)
$StatusLabel1.Size      = New-Object System.Drawing.Size(235, 250)
$StatusLabel1.Font      = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))

# Уведомление в форме об успешной смене пароля.
$StatusLabel2           = New-Object System.Windows.Forms.Label
$StatusLabel2.AutoSize  = $True
$StatusLabel2.Location  = New-Object System.Drawing.Point(10, 550)
$StatusLabel2.Size      = New-Object System.Drawing.Size(235, 250)
$StatusLabel2.Font      = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$StatusLabel2.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#FF228B22") # ForestGreen

# Активная кнопка в форме.
$Button                = New-Object System.Windows.Forms.Button
$Button.Text           = "OK"
$Button.AutoSize       = $True
$Button.Location       = New-Object System.Drawing.Point(165, 505)
$Button.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',14)
$Button.BackColor      = [System.Drawing.ColorTranslator]::FromHtml("#FFE6E6FA") # Lavender

# Если изображение по указанному полному пути в переменной $ImagePath существует.
if (Test-Path -Path $ImagePath -ErrorAction SilentlyContinue) {

	# Добавляем в форму установленные параметры с изображением.
	$Form.Controls.AddRange(@($Label_, $Labelp, $Label0, $Label1, $Label2, $Label3, $TextBox1, $TextBox2, $TextBox3, $StatusLabel1, $StatusLabel2, $Button, $PictureBox))
}
else {
	# Добавляем в форму установленные параметры без изображения.
	$Form.Controls.AddRange(@($Label_, $Labelp, $Label0, $Label1, $Label2, $Label3, $TextBox1, $TextBox2, $TextBox3, $StatusLabel1, $StatusLabel2, $Button))
}

# 1. Функция генерирования надежного пароля.
function Generate-Password() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[int]$PasswordLength
	)

	Add-Type -AssemblyName System.Web
	
	$Flag_Generate_Password = $false

	do {

		$Generate_Password = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, 2)

		if ( ($Generate_Password -cmatch "[A-Z\p{Lu}\s]") -and`
			 ($Generate_Password -cmatch "[a-z\p{Ll}\s]") -and`
			 ($Generate_Password -match "[\d]") -and`
			 ($Generate_Password -match "[^\w]")
			) {

			$Flag_Generate_Password = $true
		}
	} 
	while ($Flag_Generate_Password -like $false)

		return $Generate_Password

		Clear-Variable -Name "New_Password"
	}

# 2. Функция преобразования пароля.
function ConvertTo-UnsecureString() {
	param(
		[SecureString]$secStr
	)
	
	return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secStr))
}

# 3. Функция проверки плохого пароля.
function Password-Bad() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Password
	)

	if ($Array_Bad_Password.Contains((ConvertTo-UnsecureString $Password))) {

		$Log_File = "<Укажите полный путь к Log-файлу воода плохих паролей>" # Формат Log-файла txt.

		if (Test-Path -Path $Log_File -ErrorAction SilentlyContinue) {

			$Date = Get-Date -Format "yyyy.MM.dd hh:mm:ss"

			Add-Content -Path $Log_File -Value ("[$($Date)][$($env:USERNAME)] $((ConvertTo-UnsecureString $Password))")

			Clear-Variable -Name "Date"
		}

		return "BadВведен ненадёжный пароль"

		Clear-Variable -Name "Password"
	}
	else {
		
		return $true

		Clear-Variable -Name "Password"
	}
}

# 4. Функция проверки сложности новго пароля.
function Password-Check(){
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Password
	)

	while($true) {

		# Русские буквы.
		if ((ConvertTo-UnsecureString $Password) -cmatch "[а-яА-Я]") {

			Clear-Variable -Name "Password"
			return "RusНовый пароль не должен состоять из русских букв"
			break
		}
		else {

			$Flag_Length = $true
		}

		# Длина.
		if($Flag_Length) {

			$Flag_Length = $false

			if ((ConvertTo-UnsecureString $Password).Length -ge 8) {

				$Flag_Upper = $true
			}
			else {

				Clear-Variable -Name "Password"
				return "LengthМинимальная длина нового пароля должна`nсостовлять 8 знаков"
				break
			}
		}

		# Заглавная.
		if ($Flag_Upper) {

			$Flag_Upper = $false

			if ((ConvertTo-UnsecureString $Password) -cmatch "[A-Z\p{Lu}\s]") {

				$Flag_Lower = $true
			}
			else {

				Clear-Variable -Name "Password"
				return "UpperНовый пароль должен иметь заглавную букву"
				break
			}
		}

		# Строчная.
		if ($Flag_Lower) {
			
			$Flag_Lower = $false

			if ((ConvertTo-UnsecureString $Password) -cmatch "[a-z\p{Ll}\s]") {

				$Flag_Integer = $true
			}
			else {

				Clear-Variable -Name "Password"
				return "LowerНовый пароль должен иметь строчную букву"
				break
			}
		}

		# Цифра.
		if ($Flag_Integer) {

			$Flag_Integer = $false

			if ((ConvertTo-UnsecureString $Password) -match "[\d]") {

				$Flag_Symbol = $true
			}
			else {

				Clear-Variable -Name "Password"
				return "IntegerНовый пароль должен иметь цыфры"
				break
			}
		}

		# Специальный символ.
		if ($Flag_Symbol) {

			$Flag_Symbol = $false

			if ((ConvertTo-UnsecureString $Password) -cmatch "[^\w]") {

				Clear-Variable -Name "Password"
				return $true
				break
			}
			else {

				Clear-Variable -Name "Password"
				return "SymbolПароль должен иметь специальный символ"
				break
			}
		}
	}
}

# 5. Функция cмены пароля.
function Password-Change() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$OldPassworrd
		,
		[Parameter(Mandatory = $true)]
		$NewPassword
		,
		[Parameter(Mandatory = $true)]
		$RepeatPassword
	)

	Add-Type -AssemblyName System.DirectoryServices.AccountManagement

	# Получаем контекст текущего домена
	$Domain = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain)

	# Получаем текущего пользователя
	$User = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Domain, $env:USERNAME)

	if ((ConvertTo-UnsecureString $NewPassword) -ne (ConvertTo-UnsecureString $RepeatPassword)) {

		$StatusLabel1.Text = "Новые пароли не совпадают"

		Clear-Variable -Name "OldPassworrd" -ErrorAction SilentlyContinue
		Clear-Variable -Name "NewPassword" -ErrorAction SilentlyContinue
		Clear-Variable -Name "RepeatPassword" -ErrorAction SilentlyContinue
	}
	else {
		
		# Попытка сменить пароль.
		try {

			# Русские буквы.
			if ((ConvertTo-UnsecureString $OldPassworrd) -cmatch "[а-яА-Я]") {

				$StatusLabel1.Text =  "Старый пароль введён на русском языке"

				Clear-Variable -Name "OldPassworrd" -ErrorAction SilentlyContinue
				Clear-Variable -Name "NewPassword" -ErrorAction SilentlyContinue
				Clear-Variable -Name "RepeatPassword" -ErrorAction SilentlyContinue
			}
			else {
			
				$User.ChangePassword((ConvertTo-UnsecureString $OldPassworrd), (ConvertTo-UnsecureString $NewPassword))

				$StatusLabel2.Text = "✅ Пароль успешно изменён"

				Clear-Variable -Name "OldPassworrd" -ErrorAction SilentlyContinue
				Clear-Variable -Name "NewPassword" -ErrorAction SilentlyContinue
				Clear-Variable -Name "RepeatPassword" -ErrorAction SilentlyContinue
			}
		}
		catch {

			$StatusLabel1.Text = "Неверно введён старый пароль"

			Clear-Variable -Name "OldPassworrd" -ErrorAction SilentlyContinue
			Clear-Variable -Name "NewPassword" -ErrorAction SilentlyContinue
			Clear-Variable -Name "RepeatPassword" -ErrorAction SilentlyContinue
		}
	}
}

# Исполняемый код при нажатии кнопки в форме.
$Button.add_click({

	$Labelp.text = "$(Generate-Password -PasswordLength (Get-Random -Minimum 8 -Maximum 14))"

	# Очистка уведомление в интерфейсе программы.
	if ($StatusLabel1.Text) {

		$StatusLabel1.Text = ""
	}
	elseif ($StatusLabel2.Text) {

		$StatusLabel2.Text = ""
	}

	# Если введен старый пароль.
	if ($TextBox1.Text | ConvertTo-SecureString -AsPlainText -Force -ErrorAction SilentlyContinue) {

		# Если введен новый пароль.
		if ($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force -ErrorAction SilentlyContinue) {

			$Flag_Check_Pass = $true
		}
		else {

			$StatusLabel1.Text = "Не введён новый пароль"
		}
	}
	else {

		$StatusLabel1.Text = "Не введён старый пароль"
	}

	 # Проверка ввода надежного пароля.
	if ($Flag_Check_Pass) {

		$Flag_Check_Pass = $true

		if ((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)) -like $true) {

			$Flag_Bad_Pass = $true
		}
		elseif ((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).StartsWith("Rus")) {

			$StatusLabel1.Text = (Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).Replace('Rus', '')
		}
		elseif ((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).StartsWith("Length")) {

			$StatusLabel1.Text = (Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).Replace('Length', '')
		}
		elseif ((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).StartsWith("Upper")) {

			$StatusLabel1.Text = "$((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).Replace('Upper', ''))`n$($Alphabet_Uppper)"
		}
		elseif ((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).StartsWith("Lower")) {

			$StatusLabel1.Text = "$((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).Replace('Lower', ''))`n$($Alphabet_Lower)"
		}
		elseif ((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).StartsWith("Integer")) {

			$StatusLabel1.Text = "$((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).Replace('Integer', ''))`n$($Integer)"
		}
		elseif ((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).StartsWith("Symbol")) {

			$StatusLabel1.Text = "$((Password-Check -Password $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)).Replace('Symbol', ''))`n$($Symbol)"
		}
	}

	# Проверка ввода плохого пароля.
	if ($Flag_Bad_Pass) {

		$Flag_Bad_Pass = $false

		$Bad_Pass = Password-Bad -Password ($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force)

		if($Bad_Pass -like $true){

			$Flag_Password_Change = $true

			Clear-Variable -Name "Bad_Pass"
		}
		elseif ($Bad_Pass.StartsWith("Bad")) {

			$StatusLabel1.Text = $Bad_Pass.Replace("Bad", "")

			Clear-Variable -Name "Bad_Pass"
		}
	}

	# Установка нового пароля.
	if($Flag_Password_Change) {

		$Flag_Password_Change = $false

		if ($TextBox3.Text | ConvertTo-SecureString -AsPlainText -Force -ErrorAction SilentlyContinue) {

			Password-Change -OldPassworrd $($TextBox1.Text | ConvertTo-SecureString -AsPlainText -Force) -NewPassword $($TextBox2.Text | ConvertTo-SecureString -AsPlainText -Force) -RepeatPassword $($TextBox3.Text | ConvertTo-SecureString -AsPlainText -Force)
		}
		else {

			$StatusLabel1.Text = "Не введён повторно новый пароль"
		}
	}

	# Очистка формы старого пароля.
	if ($TextBox1.Text) {

		$TextBox1.Text = ""
	}

	# Очистка формы нового пароля.
	if ($TextBox2.Text) {

		$TextBox2.Text = ""
	}

	# Очистка формы повторно введенного нового пароля.
	if ($TextBox3.Text) {

		$TextBox3.Text = ""
	}
})

[void]$Form.ShowDialog()