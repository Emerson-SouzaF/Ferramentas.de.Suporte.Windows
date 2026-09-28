@echo off
:: =====================================================================
:: PAINEL DE FERRAMENTAS DE SUPORTE WINDOWS
:: Eleva automaticamente para Administrador na inicializacao
:: =====================================================================

:: Garante suporte a caracteres UTF-8
chcp 65001 >nul

NET FILE >nul 2>&1 || (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

title PAINEL DE OTIMIZACAO E SUPORTE WINDOWS
mode con cols=72 lines=26
setlocal EnableExtensions
set "LOGFILE=%userprofile%\Desktop\Log_Suporte.txt"
set "RELATORIO=%userprofile%\Desktop\Relatorio_Sistema.txt"

:menu
cls
color 0B
echo ========================================================================
echo                      PAINEL DE FERRAMENTAS DE SUPORTE
echo ========================================================================
echo  [ 1 ] Limpeza Profunda de Temporarios e Cache
echo  [ 2 ] Resetar e Otimizar Conexao de Rede
echo  [ 3 ] Reparar Imagem do Sistema, Arquivos e Otimizar Disco
echo  [ 4 ] Gerar Relatorio Completo de Hardware e Rede
echo  [ 5 ] Reiniciar Spooler de Impressao
echo  [ 6 ] Reiniciar Servicos Essenciais (Rede/Update/Spooler)
echo  [ 7 ] Verificar Espaco em Disco
echo  [ 8 ] Abrir Pasta de Logs Gerados
echo  [ 0 ] Sair
echo ========================================================================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="1" goto opcao1
if "%opcao%"=="2" goto opcao2
if "%opcao%"=="3" goto opcao3
if "%opcao%"=="4" goto opcao4
if "%opcao%"=="5" goto opcao5
if "%opcao%"=="6" goto opcao6
if "%opcao%"=="7" goto opcao7
if "%opcao%"=="8" goto opcao8
if "%opcao%"=="0" goto fim
echo. & echo Opcao invalida! Tente novamente. & timeout /t 2 >nul & goto menu

:log
echo [%date% %time%] %~1 >> "%LOGFILE%"
goto :eof

:opcao1
cls
color 0A
echo ========================================================================
echo    LIMPEZA PROFUNDA DE TEMPORARIOS E CACHE
echo ========================================================================
call :log "Iniciando limpeza de temporarios"

echo [1/4] Parando servicos de atualizacao...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop dosvc >nul 2>&1

echo [2/4] Apagando temporarios, lixeira, prefetch e logs...
rd /s /q "%systemroot%\SoftwareDistribution\Download" >nul 2>&1
md "%systemroot%\SoftwareDistribution\Download" >nul 2>&1
del /q /f /s "%temp%\*" >nul 2>&1
del /q /f /s "%systemroot%\Temp\*" >nul 2>&1
del /q /f /s "%systemroot%\Prefetch\*" >nul 2>&1
del /q /f /s "%systemroot%\Logs\*" >nul 2>&1
for /d %%i in ("%temp%\*") do rd /s /q "%%i" >nul 2>&1
for /d %%i in ("%systemroot%\Temp\*") do rd /s /q "%%i" >nul 2>&1
rd /s /q "%systemdrive%\$Recycle.Bin" >nul 2>&1

echo [3/4] Reiniciando servicos e limpando componentes do Windows (DISM)...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

echo [4/4] Executando Limpeza de Disco e Flush de DNS...
ipconfig /flushdns >nul 2>&1
cleanmgr /autoclean >nul 2>&1

call :log "Limpeza de temporarios concluida"
echo.
echo Limpeza concluida com sucesso!
pause
goto menu

:opcao2
cls
color 0D
echo ========================================================================
echo    RESET E OTIMIZACAO DE REDE
echo ========================================================================
call :log "Iniciando reset de rede"

echo Limpando cache DNS...
ipconfig /flushdns >nul 2>&1
echo Liberando e renovando IP...
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
echo Resetando Winsock...
netsh winsock reset >nul 2>&1
echo Resetando pilha TCP/IP...
netsh int ip reset >nul 2>&1
echo Resetando Firewall para o padrao...
netsh advfirewall reset >nul 2>&1

call :log "Reset de rede concluido"
echo.
echo Configuracoes de rede redefinidas! Pode ser necessario reiniciar o PC.
pause
goto menu

:opcao3
cls
color 0E
echo ========================================================================
echo    REPARO DE SISTEMA E OTIMIZACAO DE DISCO
echo ========================================================================
call :log "Iniciando reparo de sistema"

echo [1/4] Verificando integridade da imagem do Windows (DISM)...
Dism /Online /Cleanup-Image /ScanHealth

echo.
echo [2/4] Corrigindo a imagem do Windows (DISM)...
Dism /Online /Cleanup-Image /RestoreHealth

echo.
echo [3/4] Escaneando e reparando arquivos de sistema (SFC)...
sfc /scannow

echo.
echo [4/4] Otimizando Unidade C: (TRIM/Desfragmentacao)...
defrag C: /O /V

call :log "Reparo de sistema concluido"
echo.
set /p chk=Deseja agendar verificacao de erros do disco (CHKDSK) na proxima inicializacao? (S/N): 
if /i "%chk%"=="S" (
    chkdsk C: /f /r
    call :log "CHKDSK agendado para proxima inicializacao"
)
echo.
echo Reparo e Otimizacao Concluidos!
pause
goto menu

:opcao4
cls
color 0B
echo ========================================================================
echo    RELATORIO COMPLETO DE HARDWARE E REDE
echo ========================================================================
echo Coletando informacoes do sistema, aguarde...

(
echo ========================================================================
echo    RELATORIO DE HARDWARE E REDE - Gerado em %date% %time%
echo ========================================================================
) > "%RELATORIO%"

systeminfo >> "%RELATORIO%" 2>&1

(
echo.
echo ========================================================================
echo    CONFIGURACOES DE REDE
echo ========================================================================
) >> "%RELATORIO%"
ipconfig /all >> "%RELATORIO%" 2>&1

(
echo.
echo ========================================================================
echo    ESPACO EM DISCO
echo ========================================================================
) >> "%RELATORIO%"
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID,VolumeName,@{N='TamanhoGB';E={[math]::Round($_.Size/1GB,1)}},@{N='LivreGB';E={[math]::Round($_.FreeSpace/1GB,1)}} | Format-Table -AutoSize" >> "%RELATORIO%" 2>&1

(
echo.
echo ========================================================================
echo    PROGRAMAS INSTALADOS
echo ========================================================================
) >> "%RELATORIO%"
powershell -NoProfile -Command "Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | Select-Object DisplayName,DisplayVersion | Sort-Object DisplayName | Format-Table -AutoSize" >> "%RELATORIO%" 2>&1

call :log "Relatorio de sistema gerado"

echo.
echo Informacoes principais:
powershell -NoProfile -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,OSArchitecture | Format-Table -HideTableHeaders"
powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select-Object Name | Format-Table -HideTableHeaders"
powershell -NoProfile -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object Capacity,Speed | Format-Table -HideTableHeaders"
echo.
echo Relatorio completo salvo na Area de Trabalho: Relatorio_Sistema.txt
pause
goto menu

:opcao5
cls
color 0A
echo ========================================================================
echo    REINICIAR SPOOLER DE IMPRESSAO
echo ========================================================================
call :log "Reiniciando spooler de impressao"

echo Parando servico Spooler...
net stop spooler >nul 2>&1

echo Limpando fila de impressao...
del /q /f "%systemroot%\System32\spool\PRINTERS\*.*" >nul 2>&1

echo Reiniciando servico Spooler...
net start spooler >nul 2>&1

call :log "Spooler de impressao reiniciado"
echo.
echo Spooler de impressao reiniciado e fila limpa com sucesso!
pause
goto menu

:opcao6
cls
color 0D
echo ========================================================================
echo    REINICIAR SERVICOS ESSENCIAIS
echo ========================================================================
call :log "Reiniciando servicos essenciais"

echo Reiniciando servico de Rede (Netman)...
net stop netman >nul 2>&1
net start netman >nul 2>&1

echo Reiniciando servico de Windows Update...
net stop wuauserv >nul 2>&1
net start wuauserv >nul 2>&1

echo Reiniciando servico de Spooler de Impressao...
net stop spooler >nul 2>&1
net start spooler >nul 2>&1

echo Reiniciando servico DNS Client...
net stop dnscache >nul 2>&1
net start dnscache >nul 2>&1

call :log "Servicos essenciais reiniciados"
echo.
echo Servicos essenciais reiniciados com sucesso!
pause
goto menu

:opcao7
cls
color 0B
echo ========================================================================
echo    ESPACO EM DISCO
echo ========================================================================
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID,VolumeName,@{N='TamanhoGB';E={[math]::Round($_.Size/1GB,1)}},@{N='LivreGB';E={[math]::Round($_.FreeSpace/1GB,1)}} | Format-Table -AutoSize"
call :log "Consulta de espaco em disco realizada"
echo.
pause
goto menu

:opcao8
cls
if exist "%userprofile%\Desktop\Log_Suporte.txt" (
    start "" "%userprofile%\Desktop"
) else (
    echo Nenhum log foi gerado ainda nesta sessao.
    pause
)
goto menu

:fim
call :log "Painel encerrado pelo usuario"
endlocal
exit