# Данный скрипт делает опрос по классу win32 и выводит полученный результат в таблицу excel.
# В связке с доменной инфраструткурой и отконфигурированной службой WinRM, можно выполнить invoke-request опорос.

# Сохдаём книгу excel,удаляем лишние листы, присваиваем листу имя "Computers". 
$Excel=New-Object -Com Excel.Application
$Book=$Excel.Workbooks.Add()
$Book.workSheets.item(3).delete()
$Book.WorkSheets.item(2).delete()
$Book.WorkSheets.item(1).Name="Computers"
$Sheet=$Book.WorkSheets.Item(1)

# Присваиваем ячейкам заголовки: "Name", "Operating system", "CPU", "Мemory", "Motherboard", "Hard drive", "Video card", "Network"
$Sheet.Cells.Item(1,1)="Name"
$Sheet.Columns.Item(1).columnWidth=20
$Sheet.Cells.Item(1,2)="Operating system"
$Sheet.Columns.Item(2).columnWidth=25
$Sheet.Cells.Item(1,3)="CPU"
$Sheet.Columns.Item(3).columnWidth=35
$Sheet.Cells.Item(1,4)="Мemory"
$Sheet.Columns.Item(4).columnWidth=13
$Sheet.Cells.Item(1,5)="Motherboard"
$Sheet.Columns.Item(5).columnWidth=25
$Sheet.Cells.Item(1,6)="Hard drive"
$Sheet.Columns.Item(6).columnWidth=40
$Sheet.Cells.Item(1,7)="Video card"
$Sheet.Columns.Item(7).columnWidth=25
$Sheet.Cells.Item(1,8)="Network"
$Sheet.Columns.Item(8).columnWidth=45

# Задаём красивый стиль 
$Sheet.UsedRange.Interior.ColorIndex=5
$Sheet.UsedRange.Font.ColorIndex=20
$Sheet.UsedRange.Font.Bold=$True
$sheet.Rows.Item(1).HorizontalAlignment=3
$Row=2

# Если компьютер в списке включен то выполняется условие
Get-WmiObject -Class Win32_ComputerSystem -ComputerName . | Select-Object name | foreach {
if ((Test-connection $_.name -count 2 -quiet) -eq "True"){
$Sheet.Cells.Item($Row,1)=$_.name

# Операционная Система
$sys=Get-WmiObject -computername . Win32_OperatingSystem
$Sheet.Cells.Item($Row,2)=$sys.caption+"`n"+$sys.csdversion+"`n"+$sys.serialnumber

# Процессор
$cpu=Get-WmiObject -computername . Win32_Processor
$Sheet.Cells.Item($Row,3)=$cpu.name+"`n"+$cpu.caption+"`n"+$cpu.SocketDesignation

# Оперативная память
$ram=Get-WmiObject -computername . Win32_Physicalmemory
foreach ($dimm in $ram){$mem=$mem + $dimm.model + $dimm.capacity
$dimms=$dimms +1}
$speed=$ram[0].speed
$Sheet.Cells.Item($Row,4)=($mem / 1Gb).tostring("F00")+"GB`n"+$dimms+"`n"+$speed+"Mhz"
$mem=0
$dimms=0

# Материнская плата
$mb=Get-WmiObject -computername . Win32_BaseBoard
$Sheet.Cells.Item($Row,5)=$mb.manufacturer+"`n"+$mb.product+"'n"+$mb.SerialNumber

# Жесткий диск
$disk=""
foreach ($hard in Get-WmiObject -computername . win32_diskdrive){
if ($hard.MediaType.ToLower().StartsWith("fixed")){
$disk=$disk+(($hard.size)/1Gb).tostring("F00")+"GB - "+$hard.model+"`n"+$hard.serialnumber+"`n"}}
$Sheet.Cells.Item($Row,6)=$disk.TrimEnd("`n")

# Видеокарта
$video=""
foreach ($card in Get-WmiObject -computername . Win32_videoController){
if ($card.AdapterRAM -gt 0){
$video=$video+$card.name+"`n"+($card.AdapterRAM/1Mb).tostring("F00")+"MB`n"}}
$Sheet.Cells.Item($Row,7)=$video.TrimEnd("`n")

# Сетевой адаптер
$net=""
foreach ($card in Get-WmiObject -computername . Win32_NetworkAdapter -Filter "NetConnectionStatus>0"){
$net=$net+$card.name+"`n"}
$Sheet.Cells.Item($Row,8)=$net.TrimEnd("`n")
$Row=$Row + 1
}}

# Выравниваем полученную информацию в ячейказ таблицы
$Sheet.UsedRange.WrapText=1
$Sheet.Rows.Item(1).AutoFilter()
$Sheet.UsedRange.EntireRow.AutoFit()
$sheet.UsedRange.Cells.borders.TintAndShade=1
$sheet.UsedRange.VerticalAlignment=2
$Excel.visible=$True
#$book.SaveAs("D:\[DOCUMENTS]\comps.xlsx")
#$excel.Quit()
