@echo off
setlocal enabledelayedexpansion

rem Obtém a data atual no formato DD-MM-YYYY
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "DataAtual=%%a"
set "Dia=!DataAtual:~6,2!"
set "Mes=!DataAtual:~4,2!"
set "Ano=!DataAtual:~0,4!"
set "DataFormatada=!Dia!-!Mes!-!Ano!"

rem Cria a pasta "relatorios" com a data atual
mkdir "relatorios_!DataFormatada!"

rem Entra na pasta "relatorios"
cd "relatorios_!DataFormatada!"

rem Cria as pastas "sistema", "tarefas", "discos" e "usbstor"
mkdir sistema
mkdir tarefas
mkdir discos
mkdir usbstor

rem Coleta informações do sistema
rem O relatório será gravado no arquivo "relatorio_sistema.txt"
cd sistema
systeminfo > relatorio_sistema.txt
cd ..

rem Coleta informações das tarefas
rem O relatório será gravado no arquivo "relatorio_tarefas.txt"
cd tarefas
tasklist > relatorio_tarefas.txt
cd ..

rem Lista as subchaves e valores em HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\USB
rem O relatório será gravado no arquivo "registro_usb_info.txt"
cd usbstor
reg query "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\USB" /s > registro_usb_info.txt
cd ..

rem Lista os discos do computador
rem O relatório será gravado no arquivo "relatorio_discos.txt"
cd discos
wmic logicaldisk get name,size,freespace,description > relatorio_discos.txt
cd ..

rem Inicializa o corpo do e-mail
set "Body=Relatórios gerados em !DataFormatada!:"

rem Adiciona o conteúdo dos relatórios ao corpo do e-mail
for %%A in (
    ".\sistema\relatorio_sistema.txt",
    ".\tarefas\relatorio_tarefas.txt",
    ".\usbstor\registro_usb_info.txt",
    ".\discos\relatorio_discos.txt"
) do (
    set "Relatorio=%%~nxA"
    setlocal enabledelayedexpansion
    for /f "delims=" %%B in ('type "%%A"') do (
        set "Body=!Body!!NL!!NL!========== !Relatorio! ==========!NL!!NL!%%B"
        echo %%B >> "..\relatorio_temp.txt"
    )
    endlocal
)

rem Chama o PowerShell para enviar o e-mail com a codificação UTF-8
PowerShell -Command "& {$From = 'joaovictorlisboaporcel4@gmail.com'; $To = 'joaovictorlisboaporcel4@gmail.com'; $Subject = 'Relatórios do Sistema - !DataFormatada!'; $Password = 'rhsa qrfw woac rlmh' | ConvertTo-SecureString -AsPlainText -Force; $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password; $Body = Get-Content '..\relatorio_temp.txt' -Raw; Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $Credential}"

rem Imprime uma mensagem de sucesso
echo Relatórios enviados por e-mail com sucesso!

rem Pausa para que o usuário possa visualizar a mensagem
pause