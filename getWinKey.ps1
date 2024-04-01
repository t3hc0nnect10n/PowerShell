(Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey

# Главная функция
Function GetWin10Key
{
	$Hklm = 2147483650
	$Target = $env:COMPUTERNAME
	$regPath = "Software\Microsoft\Windows NT\CurrentVersion"
	$DigitalID = "DigitalProductId"
	$wmi = [WMIClass]"\\$Target\root\default:stdRegProv"
	
   	# Получаем знаячение реестра 
	$Object = $wmi.GetBinaryValue($hklm,$regPath,$DigitalID)
	[Array]$DigitalIDvalue = $Object.uValue 
	
   	# Если получен успех
	If($DigitalIDvalue)
	{
		# Получаем название и идентификатор продукта
		$ProductName = (Get-itemproperty -Path "HKLM:Software\Microsoft\Windows NT\CurrentVersion" -Name "ProductName").ProductName 
		$ProductID =  (Get-itemproperty -Path "HKLM:Software\Microsoft\Windows NT\CurrentVersion" -Name "ProductId").ProductId
		
        	# Преобразование двоичного значения в серийный номер
		$Result = ConvertTokey $DigitalIDvalue
		$OSInfo = (Get-WmiObject "Win32_OperatingSystem"  | select Caption).Caption
		If($OSInfo -match "Windows 10")
		{
			if($Result)
			{
				
				[string]$value ="ProductName  : $ProductName `r`n" `
				+ "ProductID    : $ProductID `r`n" `
				+ "Installed Key: $Result"
				$value 
				
               			# Сохраняем информацию о Windows в файл
				$Choice = GetChoice
				If( $Choice -eq 0 )
				{	
					$txtpath = "C:\Users\"+$env:USERNAME+"\Documents"
					New-Item -Path $txtpath -Name "WindowsKeyInfo.txt" -Value $value   -ItemType File  -Force | Out-Null 
				}
				Elseif($Choice -eq 1)
				{
					Exit 
				}
			}
			Else
			{
				Write-Warning "Запускайте скрипт в Windows 10"
			}
		}
		Else
		{
			Write-Warning "Запускайте скрипт в Windows 10"
		}
		
	}
	Else
	{
		Write-Warning "Возникла ошибка, не удалось получить ключ"
	}

}

# Запрос пользователя на сохранения файла
Function GetChoice
{
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
    $caption = "Подтверждение"
    $message = "Сохранить ключ в текстовый файл?"
    $result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
    $result
}

# Преобразование двоичного кода в серийный номер
Function ConvertToKey($Key)
{
	$Keyoffset = 52 
	$isWin10 = [int]($Key[66]/6) -band 1
	$HF7 = 0xF7
	$Key[66] = ($Key[66] -band $HF7) -bOr (($isWin10 -band 2) * 4)
	$i = 24
	[String]$Chars = "BCDFGHJKMPQRTVWXY2346789"	
	do
	{
		$Cur = 0 
		$X = 14
		Do
		{
			$Cur = $Cur * 256    
			$Cur = $Key[$X + $Keyoffset] + $Cur
			$Key[$X + $Keyoffset] = [math]::Floor([double]($Cur/24))
			$Cur = $Cur % 24
			$X = $X - 1 
		}while($X -ge 0)
		$i = $i- 1
		$KeyOutput = $Chars.SubString($Cur,1) + $KeyOutput
		$last = $Cur
	}while($i -ge 0)
	
	$Keypart1 = $KeyOutput.SubString(1,$last)
	$Keypart2 = $KeyOutput.Substring(1,$KeyOutput.length-1)
	if($last -eq 0 )
	{
		$KeyOutput = "N" + $Keypart2
	}
	else
	{
		$KeyOutput = $Keypart2.Insert($Keypart2.IndexOf($Keypart1)+$Keypart1.length,"N")
	}
	$a = $KeyOutput.Substring(0,5)
	$b = $KeyOutput.substring(5,5)
	$c = $KeyOutput.substring(10,5)
	$d = $KeyOutput.substring(15,5)
	$e = $KeyOutput.substring(20,5)
	$keyproduct = $a + "-" + $b + "-"+ $c + "-"+ $d + "-"+ $e
	$keyproduct 
	
  
}
GetWin10Key
$shell = New-Object -ComObject Wscript.Shell
$shell.popup("Ура все получилось",0,"Результат" , 64)
