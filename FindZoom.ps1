# Описание, как использовать try_catch_finally блоки для обработки завершающих ошибок:
# https://learn.microsoft.com/ru-ru/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.3
#
# Если у вас доменная инфраструктукра и к примеру SCCM или KSC, или ещё какие-либо программы не могут выявить на каких ПК используется Zoom, то данный скрипт поможет выявить это.
# Бывает не редко, что в компаниях в рамках информационной бехопасности программа Zoom запрещена, но для исппользования этой программы привелигированные права не требуются, т. к. программа не устанавливается, 
# не создается ветка в реестре, а так же её нет в списке среди установленных программ (appwiz.cpl), Zoom просто оседает в папке AppData.
try
{
   # Имя компьютера
   $PC = $env:computername   
   # Место хранения отчёта файла в формате txt о наличии\отсутствии "Zoom.exe"
   $path = "C:\"
   # Проверка наличии файла "Zoom.exe" в кэш-директории подьзователя
   $zoom = Get-ChildItem -Path $env:APPDATA -Filter "Zoom.exe" -Recurse -ErrorAction SilentlyContinue | select Name

   try
   {
        # Если файл с именем "Zoom.exe" есть в кэш-директории, то создается текстовый файл
        # с именем из двух частей: 1.имя компьютера, + 2.название: "zoomYes", который сохраняется в переменной "$path"
        if ($zoom) {
            Get-ChildItem -Path $env:APPDATA -Filter "*zoom*" -ErrorAction SilentlyContinue | select Name, PSPath, Directory | Format-List | Out-File $path$PC.zoomYes.txt
        }
        # Если файл с именем "Zoom.exe" отсутствует в кэш-директории, то создается текстовый файл
        # с именем из двух частей: 1.имя компьютера, + 2.название: "zoomNo", который сохраняется в переменной "$path"
        else {
            Out-FiLe $path$PC.zoomNo.txt
        }
    }
    finally
    {
        # Индикация успешновыполненого скритпта
        Write-Host ""
        Write-Host "GOOD" -BackgroundColor Green
    }
}
catch
{
    # Вывод шибки в консоль
    Write-Host ""
    Write-Host "ERROR" -BackgroundColor Red
    Write-Host "Error: $($_.Exception.Messege)"
}
