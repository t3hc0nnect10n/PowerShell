<#
	Скрипт выполняет формирование Excel-таблицы структуры групп доступа и пользователей.
	Обращается к Active Directory.

	Необходимо наличие установленного MS Excel.
#>

# Функция Check-User.
function Check-User() {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$fUser # В параметр $fUser передаётся ФИО пользователя из Excel-таблицы.
		,
		[Parameter(Mandatory = $true)]
		[string]$fGroup # В параметр $fGroup передаётся имя группы доступа из Excel-таблицы.
		,
		[Parameter(Mandatory = $true)]
		[hashtable]$fHash # В параметр $fHash передаётся словарь (хеш-таблица) $HashGroup.
	)

	# В цикле foreach идёт итерация по ключам словаря (хеш-таблицы). Ключ = группа доступа.
	foreach ($Key in $fHash.Keys) {
		# Если $Key равен $fGroup.
		if ($Key -like $fGroup) {
			# Переменной $Grp получаем значение в виде списка (массива), который ранее добавляли в словарь (хеш-таблицу) $HashGroup.
			$Grp = $fHash[$Key]
			# Если группа список (массив) содержит ФИО пользователя то переменная $Flag = $true.
			if ($Grp.Contains($fUser)) {
				$Flag = $true
			}
			# Иначе если группа список (массив) НЕ содержит ФИО пользователя то переменная $Flag = $false.
			else {
				$Flag = $false
			}
			# Возвращаем значение присвоенной переменной $Flag.
			return $Flag
		}
	}
}

# Счётчик.
$OUCount = 0

# Вечный цикл while.
while ($true) {

	echo ""
	Write-Host " Введите полный путь директории для сохранения Excel-таблиц" -ForegroundColor Yellow
	Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
	Write-Host " C:\Users\User\Documents" -ForegroundColor Gray
	$Path = Read-Host " Ввод"

	try {
		if (Test-Path $Path -ErrorAction Stop) {

			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " OK" -ForegroundColor Green

			echo ""
			Write-Host " Введите имя организационной единицы, в которой хранятся группы доступа" -ForegroundColor Yellow
			Write-Host " Пример:" -ForegroundColor Yellow -NoNewline
			Write-Host " Domain Groups" -ForegroundColor Gray
			$OUName = Read-Host " Ввод"

			# Переменной $ADFiler присваиваем фильтр для поиска в Active Directory.
			$ADFiler = "Name -like" + "'$($OUName)'"

			# Получаем "DistinguishedName" организационной единицы "Rights for shared folders".
			$OUParent = (Get-ADOrganizationalUnit -Filter $ADFiler).DistinguishedName

			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " OK" -ForegroundColor Green

			# Получаем организационные единицы из "Rights for shared folders".
			$OUChild = Get-ADOrganizationalUnit -Filter * | Where-Object {($_.DistinguishedName -match $OUParent) -and ($_.Name -notlike "$($OUName)")} | Sort-Object Name

			# В цикле foreach идём по каждой организационной единице из переменной $OUChild.
			foreach ($OU in $OUChild) {

				echo ""
				Write-Host " Запуск чтения организационной единицы:" -ForegroundColor Cyan -NoNewline
				Write-Host " $($OU.Name)"
				
				# Переменной $SaveExcel полный путь директории, в которой будет сохранена Excel-таблица.
				$SaveExcel = "$($Path)\$($OU.Name).xlsx"

				# Переменной $DistinguishedName присваиваем "DistinguishedName" организационной единицы.
				$DistinguishedName = "$($OU.DistinguishedName)"

				# Создаём словарь (хеш-таблицу). Структура {"Ключ": "Значение"}
				$HashGroup = [hashtable]@{}
				# Создаём список (массив) групп доступа входящие в организационную единицу.
				$ArrayGroup = [System.Collections.ArrayList]@()
				# Создаём список (массив) пользователей входящие в группу доступа.
				$ArrayUsers = [System.Collections.ArrayList]@()

				# Переменной $ADGroup задано получить группы доступа из переменной $DistinguishedName с сортировкой по атрибуту "Name".
				$ADGroup = Get-ADGroup -SearchBase $DistinguishedName -Filter {GroupCategory -eq "Security"} | Sort-Object Name

				# В цикле foreach добавляем в список (массив) $ArrayGroup полученные группы доступа из переменной $ADGroup.
				foreach ($Group in $ADGroup) {
					[void]($ArrayGroup.Add($Group.Name))
				}

				# В цикле for идём по длине списка (массива) $ArrayGroup.
				for ($Num = 0; $Num -le $ArrayGroup.Count; $Num ++) {
					# Переменной $tmpGroup присваиваем имя группы.
					$tmpGroup = "$($ArrayGroup[$Num])"
					# В переменной $ADUsers получаем имена пользователей входящие в группу доступа с сортировкой по атрибуту "Name".
					$ADUsers = ($ArrayGroup[$Num] | Get-ADGroupMember -ErrorAction SilentlyContinue | Sort-Object Name).Name
					# Создаём временный список (массив) пользователей.
					$tmpArrayUser = [System.Collections.ArrayList]@()
					# В цикле foreach добавляем каждого пользователя из переменной $ADUsers во временный список (массив) $tmpArrayUser.
					foreach ($User in $ADUsers) {
						[void]($tmpArrayUser.Add($User))
					}
					# В словарь (хеш-таблицу) добавляем данные где: Ключ = имя группы доступа $tmpGroup, Значение = список (массив) пользователей $tmpArrayUser находящиеся в группе доступа $tmpGroup.
					$HashGroup[$tmpGroup] = "$($tmpArrayUser)"
					# Очищаем временный список (массив) $tmpArrayUser для последующей итерации.
					$tmpArrayUser.Clear()
				}

				# В цикле foreach идём по списку (массиву) $ArrayGroup.
				foreach ($Group in $ArrayGroup) {
					# В переменной $Users получаем ФИО пользователей с сортировкой по атрибуту "Name".
					$Users = ($Group | Get-ADGroupMember -ErrorAction SilentlyContinue | Sort-Object Name).Name
					# В цикле foreach добавляем пользователя в список (массив).
					foreach ($User in $Users) {
						# Если пользователя нет в списке (массиве) $ArrayUsers, то добавляем его в список (массив) $ArrayUsers.
						if (-Not($ArrayUsers.Contains($User))) {
							[void]($ArrayUsers.Add($User))
						}
					}
				}

				Write-Host " Запись данных в Excel-таблицу:" -ForegroundColor Cyan -NoNewline
				Write-Host " $($OU.Name).xlsx"

				# Запускаем Excel-таблицу.
				$Excel = New-Object -Com Excel.Application
				# Устанавливаем параметр "Visible" - делаем Excel видимым.
				$Excel.Visible = $True
				# Создаем книгу.
				$Book = $Excel.Workbooks.Add()
				# Добавляем в книгу лист.
				$Book.WorkSheets.Item(1).Name = "Лист1"
				# Переменной $Sheet указываем в каком листе будет производиться вся дальнейшая работа.
				$Sheet = $Book.WorkSheets.Item(1)
				# Задаем имя в первой ячейке.
				$Sheet.Cells.Item(1,1) = "ФИО сотрудника"
				# В первой ячейке выравниваем текст по середине.
				$Sheet.Cells.Item(1,1).HorizontalAlignment = -4108
				# В первой ячейке выравниваем текст по центру.
				$Sheet.Cells.Item(1,1).VerticalAlignment = 2

				# Счётчик.
				$iRow = 2
				# В цикле foreach идём по списку (массиву) пользователей $ArrayUsers.
				foreach ($User in $ArrayUsers) {
					# Записываем в Excel-таблицу в первую колонку со второй строки ФИО пользователя.
					$Sheet.Cells.Item($iRow,1) = "$($User)"
					# Добавляем +1 в счётчик $iRow.
					$iRow ++
				}

				# Счётчик.
				$iCol = 2
				# В цикле foreach идём по списку (массиву) групп доступа $ADGroup.
				foreach ($Group in $ADGroup) {
					# Записываем в Excel-таблицу в первую строку со второй колонки группу доступа.
					$Sheet.Cells.Item(1,$iCol) = "$($Group.Name)"
					# Поворачиваем текст вверх.
					$Sheet.Cells.Item(1,$iCol).Cells.Orientation = -4171
					# Выравниваем текст по центру.
					$Sheet.Cells.Item(1,$iCol).HorizontalAlignment = -4108
					# Добавляем +1 в счётчик $iCol.
					$iCol ++
				}

				# В переменной $UsedRange получаем используемый диапазон на указанном листе.
				$UsedRange = $Sheet.UsedRange
				# Выравниваем ширину столбцов в используемом диапазоне.
				$UsedRange.EntireColumn.AutoFit() | Out-Null
				# Делаем текст жирным в первой ячейке.
				$Sheet.Cells.Item(1,1).Font.Bold = $true
				# Создаем границы.
				$Sheet.UsedRange.Cells.Borders.TintAndShade = 1

				# В переменной $MaxRows получаем длину строк.
				$MaxRows    = ($Sheet.UsedRange.Rows).Count
				# В переменной $MaxColumns получаем длину столбцов.
				$MaxColumns = ($Sheet.UsedRange.Columns).Count

				# В цикле for идём по длине строк.
				for ($Row = 2; $Row -le $MaxRows; $Row ++) {

					# В переменной $UserName получаем ФИО пользователя из Excel-таблицы.
					$UserName = $Sheet.Columns.Item(1).Rows.Item($Row).Text

					# В цикле for идём по длине столбцов.
					for ($Col = 2; $Col -le $MaxColumns; $Col ++) {

						# В переменной $GroupName получаем имя группы доступа из Excel-таблицы.
						$GroupName = $Sheet.UsedRange.Cells(1, $Col).Text

						# В переменной $CheckUser получаем возвращаемое значение $true или $false функцией Check-User.
						# Функции Check-User передаем параметры: -fUser ФИО пользователя, -fGroup группа доступа, -fHash словарь (хеш-таблица).
						$CheckUser = Check-User -fUser $UserName -fGroup $GroupName -fHash $HashGroup

						# Если переменная $CheckUser = $true.
						if ($CheckUser) {
							# Если группа доступа $GroupName содержит "RW".
							#if ($GroupName.Contains("RW")) {
								# Делаем заливку ячейки зелёным цветом.
								$Sheet.Cells.Item($Row, $Col).Interior.ColorIndex = 10
							#}
							# Если группа доступа $GroupName содержит "RO".
							#elseif ($GroupName.Contains("RO")) {
								# Делаем заливку ячейки голубым цветом.   
								#$Sheet.Cells.Item($Row, $Col).Interior.ColorIndex = 23
							#}
						}
						# Иначе переменная $CheckUser = $false.
						else {
							# Делаем заливку ячейки бежевым цветом.
							$Sheet.Cells.Item($Row, $Col).Interior.ColorIndex = 40
						}
						# Очищаем переменную $GroupName от ранее полученного значения для следующей итерации.
						Clear-Variable -Name "GroupName"
					}
					# Очищаем переменную $UserName от ранее полученного значения для следующей итерации.
					Clear-Variable -Name "UserName"
				}

				Write-Host " Excel-таблица заполнена и сохранена:" -ForegroundColor Cyan -NoNewline
				Write-Host " $($SaveExcel)"

				# Очищаем $HashGroup словарь (хеш-таблицу).
				$HashGroup.Clear()
				# Очищаем $ArrayGroup список (массив).
				$ArrayGroup.Clear()
				# Очищаем $ArrayUsers список (массив).
				$ArrayUsers.Clear()
				# Сохраняем Excel-таблицу по указанному ранее пути в переменной $Path.
				$Book.SaveAs($SaveExcel)
				# Закрываем Excel-таблицу.
				$Excel.Quit()

				# Добавляем +1 в счётчик $OUCount.
				$OUCount ++
			}

			# Если переменная $OUCount равна длине $OUChild.
			if ($OUCount -eq $OUChild.Count) {
				# Создаём уведомление в виде формы с кнопкой.
				$shell = New-Object -ComObject Wscript.Shell
				# Воспроизводим форму.
				[void]($shell.popup("Ура всё получилось", 0, "Результат", 0 + 64 + 4096))
				# Останавливаем вечный цикл while.
				break
			}
		}
		# Ошибка.
		else {
			echo ""
			Start-Sleep -Milliseconds 500
			Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
			Write-Host " Путь не существует."
		}
	}
	# Ошибка.
	catch {
		echo ""
		Start-Sleep -Milliseconds 500
		Write-Host " ОШИБКА:" -ForegroundColor Red -NoNewline
		Write-Host " $($Error[0])"
	}
}