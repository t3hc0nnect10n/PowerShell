<#
Утилита для оповещения пользователей о необходимости перезагрузить сервера и перезагрузка серверов
#>
 
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Drawing
 
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(700,655)
$Form.text                       = "Form"
$Form.TopMost                    = $True
$Form.BackColor                  = [System.Drawing.ColorTranslator]::FromHtml("#8dbbf3")

# Groupbox1

$CheckBoxAll1                    = New-Object system.Windows.Forms.CheckBox
$CheckBoxAll1.text               = "Выбрать все"
$CheckBoxAll1.AutoSize           = $True
$CheckBoxAll1.width              = 95
$CheckBoxAll1.height             = 20
$CheckBoxAll1.location           = New-Object System.Drawing.Point(10,7)
$CheckBoxAll1.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)                     
 
$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 385
$Groupbox1.width                 = 135
$Groupbox1.text                  = "Список серверов"
$Groupbox1.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Groupbox1.location              = New-Object System.Drawing.Point(10,25)
 
$CheckBox1                       = New-Object system.Windows.Forms.CheckBox
$CheckBox1.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox1.AutoSize              = $True
$CheckBox1.width                 = 95
$CheckBox1.height                = 20
$CheckBox1.location              = New-Object System.Drawing.Point(4,20)
$CheckBox1.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox2                       = New-Object system.Windows.Forms.CheckBox
$CheckBox2.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox2.AutoSize              = $True
$CheckBox2.width                 = 95
$CheckBox2.height                = 20
$CheckBox2.location              = New-Object System.Drawing.Point(4,40)
$CheckBox2.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox3                       = New-Object system.Windows.Forms.CheckBox
$CheckBox3.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox3.AutoSize              = $True
$CheckBox3.width                 = 95
$CheckBox3.height                = 20
$CheckBox3.location              = New-Object System.Drawing.Point(4,60)
$CheckBox3.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox4                       = New-Object system.Windows.Forms.CheckBox
$CheckBox4.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox4.AutoSize              = $True
$CheckBox4.width                 = 95
$CheckBox4.height                = 20
$CheckBox4.location              = New-Object System.Drawing.Point(4,80)
$CheckBox4.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox5                       = New-Object system.Windows.Forms.CheckBox
$CheckBox5.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox5.AutoSize              = $True
$CheckBox5.width                 = 95
$CheckBox5.height                = 20
$CheckBox5.location              = New-Object System.Drawing.Point(4,100)
$CheckBox5.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox6                       = New-Object system.Windows.Forms.CheckBox
$CheckBox6.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox6.AutoSize              = $True
$CheckBox6.width                 = 95
$CheckBox6.height                = 20
$CheckBox6.location              = New-Object System.Drawing.Point(4,120)
$CheckBox6.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox7                       = New-Object system.Windows.Forms.CheckBox
$CheckBox7.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox7.AutoSize              = $True
$CheckBox7.width                 = 95
$CheckBox7.height                = 20
$CheckBox7.location              = New-Object System.Drawing.Point(4,140)
$CheckBox7.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox8                       = New-Object system.Windows.Forms.CheckBox
$CheckBox8.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox8.AutoSize              = $True
$CheckBox8.width                 = 95
$CheckBox8.height                = 20
$CheckBox8.location              = New-Object System.Drawing.Point(4,160)
$CheckBox8.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox9                      = New-Object system.Windows.Forms.CheckBox
$CheckBox9.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox9.AutoSize             = $True
$CheckBox9.width                = 95
$CheckBox9.height               = 20
$CheckBox9.location             = New-Object System.Drawing.Point(4,180)
$CheckBox9.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox10                      = New-Object system.Windows.Forms.CheckBox
$CheckBox10.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox10.AutoSize             = $True
$CheckBox10.width                = 95
$CheckBox10.height               = 20
$CheckBox10.location             = New-Object System.Drawing.Point(4,200)
$CheckBox10.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox11                      = New-Object system.Windows.Forms.CheckBox
$CheckBox11.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox11.AutoSize             = $True
$CheckBox11.width                = 95
$CheckBox11.height               = 20
$CheckBox11.location             = New-Object System.Drawing.Point(4,220)
$CheckBox11.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox12                      = New-Object system.Windows.Forms.CheckBox
$CheckBox12.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox12.AutoSize             = $True
$CheckBox12.width                = 95
$CheckBox12.height               = 20
$CheckBox12.location             = New-Object System.Drawing.Point(4,240)
$CheckBox12.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox13                      = New-Object system.Windows.Forms.CheckBox
$CheckBox13.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox13.AutoSize             = $True
$CheckBox13.width                = 95
$CheckBox13.height               = 20
$CheckBox13.location             = New-Object System.Drawing.Point(4,260)
$CheckBox13.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox14                      = New-Object system.Windows.Forms.CheckBox
$CheckBox14.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox14.AutoSize             = $True
$CheckBox14.width                = 95
$CheckBox14.height               = 20
$CheckBox14.location             = New-Object System.Drawing.Point(4,280)
$CheckBox14.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox15                      = New-Object system.Windows.Forms.CheckBox
$CheckBox15.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox15.AutoSize             = $True
$CheckBox15.width                = 95
$CheckBox15.height               = 20
$CheckBox15.location             = New-Object System.Drawing.Point(4,300)
$CheckBox15.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox16                      = New-Object system.Windows.Forms.CheckBox
$CheckBox16.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox16.AutoSize             = $True
$CheckBox16.width                = 95
$CheckBox16.height               = 20
$CheckBox16.location             = New-Object System.Drawing.Point(4,320)
$CheckBox16.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox19                      = New-Object system.Windows.Forms.CheckBox
$CheckBox19.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox19.AutoSize             = $True
$CheckBox19.width                = 95
$CheckBox19.height               = 20
$CheckBox19.location             = New-Object System.Drawing.Point(4,340)
$CheckBox19.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox20                      = New-Object system.Windows.Forms.CheckBox
$CheckBox20.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox20.AutoSize             = $True
$CheckBox20.width                = 95
$CheckBox20.height               = 20
$CheckBox20.location             = New-Object System.Drawing.Point(4,360)
$CheckBox20.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Groupbox2

$CheckBoxAll2                    = New-Object system.Windows.Forms.CheckBox
$CheckBoxAll2.text               = "Выбрать все"
$CheckBoxAll2.AutoSize           = $True
$CheckBoxAll2.width              = 95
$CheckBoxAll2.height             = 20
$CheckBoxAll2.location           = New-Object System.Drawing.Point(145,7)
$CheckBoxAll2.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)                     
 
$Groupbox2                       = New-Object system.Windows.Forms.Groupbox
$Groupbox2.height                = 385
$Groupbox2.width                 = 135
$Groupbox2.text                  = "Список серверов"
$Groupbox2.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Groupbox2.location              = New-Object System.Drawing.Point(145,25)
 
$CheckBox21                      = New-Object system.Windows.Forms.CheckBox
$CheckBox21.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox21.AutoSize             = $True
$CheckBox21.width                = 95
$CheckBox21.height               = 20
$CheckBox21.location             = New-Object System.Drawing.Point(4,20)
$CheckBox21.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox22                      = New-Object system.Windows.Forms.CheckBox
$CheckBox22.text                 = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox22.AutoSize             = $True
$CheckBox22.width                = 95
$CheckBox22.height               = 20
$CheckBox22.location             = New-Object System.Drawing.Point(4,40)
$CheckBox22.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox23                       = New-Object system.Windows.Forms.CheckBox
$CheckBox23.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox23.AutoSize              = $True
$CheckBox23.width                 = 95
$CheckBox23.height                = 20
$CheckBox23.location              = New-Object System.Drawing.Point(4,60)
$CheckBox23.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox24                       = New-Object system.Windows.Forms.CheckBox
$CheckBox24.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox24.AutoSize              = $True
$CheckBox24.width                 = 95
$CheckBox24.height                = 20
$CheckBox24.location              = New-Object System.Drawing.Point(4,80)
$CheckBox24.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox25                       = New-Object system.Windows.Forms.CheckBox
$CheckBox25.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox25.AutoSize              = $True
$CheckBox25.width                 = 95
$CheckBox25.height                = 20
$CheckBox25.location              = New-Object System.Drawing.Point(4,100)
$CheckBox25.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)  
 
$CheckBox26                       = New-Object system.Windows.Forms.CheckBox
$CheckBox26.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox26.AutoSize              = $True
$CheckBox26.width                 = 95
$CheckBox26.height                = 20
$CheckBox26.location              = New-Object System.Drawing.Point(4,120)
$CheckBox26.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Groupbox3 
 
$CheckBoxAll3                     = New-Object system.Windows.Forms.CheckBox
$CheckBoxAll3.AutoSize            = $True
$CheckBoxAll3.width               = 95
$CheckBoxAll3.height              = 20
$CheckBoxAll3.location            = New-Object System.Drawing.Point(280,7)
$CheckBoxAll3.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)                     
 
$Groupbox3                        = New-Object system.Windows.Forms.Groupbox
$Groupbox3.height                 = 385
$Groupbox3.width                  = 135
$Groupbox3.text                   = "Список серверов"
$Groupbox3.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Groupbox3.location               = New-Object System.Drawing.Point(280,25)
 
$CheckBox27                       = New-Object system.Windows.Forms.CheckBox
$CheckBox27.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox27.AutoSize              = $True
$CheckBox27.width                 = 95
$CheckBox27.height                = 20
$CheckBox27.location              = New-Object System.Drawing.Point(4,20)
$CheckBox27.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox28                       = New-Object system.Windows.Forms.CheckBox
$CheckBox28.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox28.AutoSize              = $True
$CheckBox28.width                 = 95
$CheckBox28.height                = 20
$CheckBox28.location              = New-Object System.Drawing.Point(4,40)
$CheckBox28.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox29                       = New-Object system.Windows.Forms.CheckBox
$CheckBox29.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox29.AutoSize              = $True
$CheckBox29.width                 = 95
$CheckBox29.height                = 20
$CheckBox29.location              = New-Object System.Drawing.Point(4,60)
$CheckBox29.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox30                       = New-Object system.Windows.Forms.CheckBox
$CheckBox30.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox30.AutoSize              = $True
$CheckBox30.width                 = 95
$CheckBox30.height                = 20
$CheckBox30.location              = New-Object System.Drawing.Point(4,60)
$CheckBox30.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
# Groupbox4

$CheckBoxAll4                     = New-Object system.Windows.Forms.CheckBox
$CheckBoxAll4.text                = "Выбрать все"
$CheckBoxAll4.AutoSize            = $True
$CheckBoxAll4.width               = 95
$CheckBoxAll4.height              = 20
$CheckBoxAll4.location            = New-Object System.Drawing.Point(415,7)
$CheckBoxAll4.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)                     
 
$Groupbox4                        = New-Object system.Windows.Forms.Groupbox
$Groupbox4.height                 = 385
$Groupbox4.width                  = 135
$Groupbox4.text                   = "Список серверов"
$Groupbox4.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Groupbox4.location               = New-Object System.Drawing.Point(415,25)
 
$CheckBox31                       = New-Object system.Windows.Forms.CheckBox
$CheckBox31.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox31.AutoSize              = $True
$CheckBox31.width                 = 95
$CheckBox31.height                = 20
$CheckBox31.location              = New-Object System.Drawing.Point(4,20)
$CheckBox31.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox32                       = New-Object system.Windows.Forms.CheckBox
$CheckBox32.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox32.AutoSize              = $True
$CheckBox32.width                 = 95
$CheckBox32.height                = 20
$CheckBox32.location              = New-Object System.Drawing.Point(4,40)
$CheckBox32.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox33                       = New-Object system.Windows.Forms.CheckBox
$CheckBox33.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox33.AutoSize              = $True
$CheckBox33.width                 = 95
$CheckBox33.height                = 20
$CheckBox33.location              = New-Object System.Drawing.Point(4,60)
$CheckBox33.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox34                       = New-Object system.Windows.Forms.CheckBox
$CheckBox34.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox34.AutoSize              = $True
$CheckBox34.width                 = 95
$CheckBox34.height                = 20
$CheckBox34.location              = New-Object System.Drawing.Point(4,80)
$CheckBox34.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox35                       = New-Object system.Windows.Forms.CheckBox
$CheckBox35.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox35.AutoSize              = $True
$CheckBox35.width                 = 95
$CheckBox35.height                = 20
$CheckBox35.location              = New-Object System.Drawing.Point(4,100)
$CheckBox35.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox36                       = New-Object system.Windows.Forms.CheckBox
$CheckBox36.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox36.AutoSize              = $True
$CheckBox36.width                 = 95
$CheckBox36.height                = 20
$CheckBox36.location              = New-Object System.Drawing.Point(4,120)
$CheckBox36.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CheckBox37                       = New-Object system.Windows.Forms.CheckBox
$CheckBox37.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox37.AutoSize              = $True
$CheckBox37.width                 = 95
$CheckBox37.height                = 20
$CheckBox37.location              = New-Object System.Drawing.Point(4,140)
$CheckBox37.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox38                       = New-Object system.Windows.Forms.CheckBox
$CheckBox38.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox38.AutoSize              = $True
$CheckBox38.width                 = 95
$CheckBox38.height                = 20
$CheckBox38.location              = New-Object System.Drawing.Point(4,160)
$CheckBox38.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox39                       = New-Object system.Windows.Forms.CheckBox
$CheckBox39.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox39.AutoSize              = $True
$CheckBox39.width                 = 95
$CheckBox39.height                = 20
$CheckBox39.location              = New-Object System.Drawing.Point(4,180)
$CheckBox39.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Groupbox5 
 
$CheckBoxAll5                     = New-Object system.Windows.Forms.CheckBox
$CheckBoxAll5.text                = "Выбрать все"
$CheckBoxAll5.AutoSize            = $True
$CheckBoxAll5.width               = 95
$CheckBoxAll5.height              = 20
$CheckBoxAll5.location            = New-Object System.Drawing.Point(550,7)
$CheckBoxAll5.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)                     
 
$Groupbox5                        = New-Object system.Windows.Forms.Groupbox
$Groupbox5.height                 = 385
$Groupbox5.width                  = 135
$Groupbox5.text                   = "Список серверов"
$Groupbox5.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Groupbox5.location               = New-Object System.Drawing.Point(550,25)
 
$CheckBox40                       = New-Object system.Windows.Forms.CheckBox
$CheckBox40.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox40.AutoSize              = $True
$CheckBox40.width                 = 95
$CheckBox40.height                = 20
$CheckBox40.location              = New-Object System.Drawing.Point(4,20)
$CheckBox40.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox41                       = New-Object system.Windows.Forms.CheckBox
$CheckBox41.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox41.AutoSize              = $True
$CheckBox41.width                 = 95
$CheckBox41.height                = 20
$CheckBox41.location              = New-Object System.Drawing.Point(4,40)
$CheckBox41.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox42                       = New-Object system.Windows.Forms.CheckBox
$CheckBox42.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox42.AutoSize              = $True
$CheckBox42.width                 = 95
$CheckBox42.height                = 20
$CheckBox42.location              = New-Object System.Drawing.Point(4,60)
$CheckBox42.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox43                       = New-Object system.Windows.Forms.CheckBox
$CheckBox43.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox43.AutoSize              = $True
$CheckBox43.width                 = 95
$CheckBox43.height                = 20
$CheckBox43.location              = New-Object System.Drawing.Point(4,80)
$CheckBox43.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
$CheckBox44                       = New-Object system.Windows.Forms.CheckBox
$CheckBox44.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox44.AutoSize              = $True
$CheckBox44.width                 = 95
$CheckBox44.height                = 20
$CheckBox44.location              = New-Object System.Drawing.Point(4,100)
$CheckBox44.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

 
$CheckBox45                       = New-Object system.Windows.Forms.CheckBox
$CheckBox45.text                  = "<Написать имя сервера>" # Вместо <Написать имя сервера> пишем ьребуемое имя сервера например: SRV-DC-MSK-01
$CheckBox45.AutoSize              = $True
$CheckBox45.width                 = 95
$CheckBox45.height                = 20
$CheckBox45.location              = New-Object System.Drawing.Point(4,120)
$CheckBox45.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Ввод времени перезагрузки сервера в секундах 

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Введите время через которое перезагрузить сервера (сек):"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(10,550)
$Label2.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline))
 
$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $True
$TextBox1.AutoSize               = $True
$TextBox1.width                  = 40
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(420,550)
$TextBox1.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Форма сообщения пользователям
 
$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Введите сообщение для пользователей:"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(9,280)
$Label3.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline))
 
$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $True
$TextBox2.AutoSize               = $True
$TextBox2.width                  = 685
$TextBox2.height                 = 100
$TextBox2.location               = New-Object System.Drawing.Point(9,430)
$TextBox2.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
 
# Кнопка "Отправить сообщение"

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Отправить сообщение"
$Button1.AutoSize                = $True
$Button1.width                   = 60
$Button1.height                  = 60
$Button1.location                = New-Object System.Drawing.Point(10,585)
$Button1.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',14,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Underline))
$Button1.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#f8e71c")
 
# Кнопка "Перезагрузить сервера

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Перезагрузить сервера"
$Button2.AutoSize                = $True
$Button2.width                   = 60
$Button2.height                  = 60
$Button2.location                = New-Object System.Drawing.Point(460,585)
$Button2.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',14,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Underline))
$Button2.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#f82b1c")
 
# Кнопка "Отменить

$Button3                         = New-Object system.Windows.Forms.Button
$Button3.text                    = "Отменить"
$Button3.AutoSize                = $True
$Button3.width                   = 200
$Button3.height                  = 60
$Button3.location                = New-Object System.Drawing.Point(245,585)
$Button3.DialogResult            = [System.Windows.Forms.DialogResult]::Cancel
$Button3.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',14,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Underline))
$Button3.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#7ed321")
 
 
$Form.controls.AddRange(@($Groupbox1, $Groupbox2, $Groupbox3, $Groupbox4, $Groupbox5, $Button1, $Button2, $Button3,
    $TextBox1, $TextBox2, $CheckBoxAll1, $Label2, $Label3, $CheckBoxAll2, $CheckBoxAll3, $CheckBoxAll4, $CheckBoxAll5))
 
$Groupbox1.controls.AddRange(@($CheckBox1, $CheckBox2, $CheckBox3, $CheckBox4, $CheckBox5, $CheckBox6,
    $CheckBox7, $CheckBox8, $CheckBox9, $CheckBox10, $CheckBox11, $CheckBox12, $CheckBox13, $CheckBox14,
    $CheckBox15, $CheckBox16, $CheckBox17, $CheckBox18, $CheckBox19, $CheckBox20))
 
$Groupbox2.controls.AddRange(@($CheckBox21, $CheckBox22, $CheckBox23, $CheckBox24, $CheckBox25, $CheckBox26))
 
$Groupbox3.controls.AddRange(@($CheckBox27, $CheckBox28, $CheckBox29, $CheckBox30))
 
$Groupbox4.controls.AddRange(@($CheckBox31, $CheckBox32, $CheckBox33, $CheckBox34, $CheckBox35, $CheckBox36,
    $CheckBox37, $CheckBox38, $CheckBox39))
 
$Groupbox5.controls.AddRange(@($CheckBox40, $CheckBox41, $CheckBox42, $CheckBox43, $CheckBox44, $CheckBox45))
 
function clkSelectALL($param) {
 
    Foreach ($control in $param){
        $objectType = $control.GetType().Name
        If ($objectType -like "CheckBox"){
            $control.checked = $true
        }
    }
}
 
function clkUnSelectALL($param) {
 
    Foreach ($control in $param){
        $objectType = $control.GetType().Name
        If ($objectType -like "CheckBox"){
            $control.checked = $false
        }
    }
}


Function SendMessage {
 
foreach ($Groupbox in $Form.controls) {
            $objectType = $Groupbox.GetType().Name
            if ($objectType -like "Groupbox"){
         
foreach ($server in $Groupbox.controls) {
 
            if ($server.Checked -eq $true){
            $Name = ($server.text).Trim()
            #write-host $Name
            $PathMsg = 'c:\windows\system32\'
            Invoke-Expression ($PathMsg + 'msg * /server:$Name $TextBox2.Text')
            #$Servers += $server.text + ','
            }
       }
       }   
 }
 
}        
     
 
Function RebootComp {
$Creds = Get-Credential
foreach ($Groupbox in $Form.controls) {
            $objectType = $Groupbox.GetType().Name
            if ($objectType -like "Groupbox"){
         
foreach ($server in $Groupbox.controls) {
 
            if ($server.Checked -eq $true){
            $Name = $server.text
            write-host $Name
            Start-Sleep -Seconds $TextBox1.Text; Restart-Computer -ComputerName $Name -force -Credential $Creds
 
            }
       }
       }   
 }
 
}        
 
<#
Function Confirm {
        $ConfirmWin = New-Object System.Windows.Forms.Form
        $ConfirmWin.StartPosition  = "CenterScreen"
        $ConfirmWin.Text = "Подтверждение отправки"
        $ConfirmWin.Width = 200
        $ConfirmWin.Height = 120
        $ConfirmWin.ControlBox = 0
        $ConfirmWinOKButton = New-Object System.Windows.Forms.Button
        $ConfirmWinOKButton.add_click({ $MainSendWindow.Close(); $ConfirmWin.Close() })
        $ConfirmWinOKButton.Text = "Закрыть"
         
        $ConfirmWinOKButton.AutoSize = 1
        $ConfirmWinOKButton.Location        = New-Object System.Drawing.Point(50,50)
 
        $ConfirmLabel = New-Object System.Windows.Forms.Label
        $ConfirmLabel.Text = "Сообщение было отправлено"
        $ConfirmLabel.AutoSize = 1
        $ConfirmLabel.Location = New-Object System.Drawing.Point(10,10)
        $ConfirmWin.Controls.Add($ConfirmLabel)
        $ConfirmWin.Controls.Add($ConfirmWinOKButton)
        $ConfirmWin.ShowDialog() | Out-Null
    }
#>
 
$CheckBoxAll1.Add_CheckStateChanged({if($CheckBoxAll1.Checked){clkSelectAll -param $Groupbox1.controls} else {clkUnSelectALL -param $Groupbox1.controls}})
 
$CheckBoxAll2.Add_CheckStateChanged({if($CheckBoxAll2.Checked){clkSelectAll -param $Groupbox2.controls} else {clkUnSelectALL -param $Groupbox2.controls}})
 
$CheckBoxAll3.Add_CheckStateChanged({if($CheckBoxAll3.Checked){clkSelectAll -param $Groupbox3.controls} else {clkUnSelectALL -param $Groupbox3.controls}})
 
$CheckBoxAll4.Add_CheckStateChanged({if($CheckBoxAll4.Checked){clkSelectAll -param $Groupbox4.controls} else {clkUnSelectALL -param $Groupbox4.controls}})
 
$CheckBoxAll5.Add_CheckStateChanged({if($CheckBoxAll5.Checked){clkSelectAll -param $Groupbox5.controls} else {clkUnSelectALL -param $Groupbox5.controls}})
 
$Button1.add_click({SendMessage})
$Button2.add_click({RebootComp})
 
 
#region Logic
 
#endregion
 
$Form.ShowDialog()|Out-null