#Bloot

$banner = @"

 ________  ___       ________  ________  _________   
|\   __  \|\  \     |\   __  \|\   __  \|\___   ___\ 
\ \  \|\ /\ \  \    \ \  \|\  \ \  \|\  \|___ \  \_| 
 \ \   __  \ \  \    \ \  \\\  \ \  \\\  \   \ \  \  
  \ \  \|\  \ \  \____\ \  \\\  \ \  \\\  \   \ \  \ 
   \ \_______\ \_______\ \_______\ \_______\   \ \__\
    \|_______|\|_______|\|_______|\|_______|    \|__|
                                                     
                                                                                          
"@

do {

Write-Host $banner -ForegroundColor DarkYellow
	
Write-Output "`n             MENU`n"
Write-Output "1 - Ip's versão 4 adaptadores"
Write-Output "2 - Impressoras Instaladas"
Write-Output "3 - Drivers de Impressoras"
Write-Output "4 - Portas de impressoras"
Write-Output "5 - Teste de Comunicação de Rede"
Write-Output "6 - Teste de Comunicação de Rede com Log"
Write-OutPut "7 - Reiniciar Spooler de impressão"
Write-Output "S/s - Sair"

$opcao = Read-Host -Prompt "`nOpção"
Write-Output ""

switch ($opcao) {
	"1" {
		Get-NetIPAddress -AddressFamily IPv4 |
		ForEach-Object{ 
		Write-Host "IPv4 -" -NoNewline
        Write-Host " $(($_.IPAddress))" -ForegroundColor DarkGreen -NoNewline
        Write-Host "  Interface -" -NoNewline
        Write-Host " $(($_.InterfaceAlias))" -ForegroundColor DarkCyan
		}	
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"2" {
		Get-Printer |
		ForEach-Object{
		Write-Host "Nome - " -NoNewLine
		Write-Host "$(($_.Name))" -ForegroundColor Magenta -NoNewLine
		Write-Host " Driver - " -NoNewLine
		Write-Host "$(($_.DriverName))" -ForegroundColor DarkMagenta -NoNewline
		Write-Host " Compartilhada - " -NoNewLine
		Write-Host "$(($_.Shared))" -ForegroundColor Blue
		}
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"3" {
		Get-PrinterDriver |
		ForEach-Object {
		Write-Host "Nome - " -NoNewLine
		Write-Host "$(($_.Name))" -ForegroundColor Magenta -NoNewLine
		Write-Host " Fabricante - " -NoNewLine
		Write-Host "$(($_.Manufacturer))" -ForegroundColor DarkMagenta -NoNewLine
		Write-Host " PrinterEnv - "
		Write-Host "$(($_.PrinterEnvironment))" -ForegroundColor DarkBlue 
		}
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"4" {
		Get-PrinterPort |
		ForEach-Object {
		Write-Host "Nome - " -NoNewLine
		Write-Host "$(($_.Name))" -ForegroundColor Magenta -NoNewLine
		Write-Host " Descrição - " -NoNewLine
		Write-Host "$(($_.Description))" -ForegroundColor DarkMagenta -NoNewLine
		Write-Host "- PortMonitor - " -NoNewline
		Write-Host "$(($_.PortMonitor))" -ForegroundColor DarkBlue
		}
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"5" {
		$ip = Read-Host "`nDigite o IP"
		Write-Output "`nPara interromper o teste aperte Ctrl-C. `nIniciando teste..."
		Test-Connection -Repeat -TargetName $ip
	}
	"6" {
		$ip = Read-Host "`nDigite o IP"
		Write-Output "`nPara interromper o teste aperte Ctrl-C. `nIniciando teste..."
		Write-Output "O log será escrito no mesmo local onde está o Script"
		"TARGET = " + $ip | Out-File .\$($ip)_LOG.txt
		Test-Connection -Repeat -TargetName $ip| 
		ForEach-Object { 
		"$((Get-Date)) - Status: $(($_.Status)) - Tempo de resposta: $(($_.Latency))ms" }|
		Out-File -FilePath .\$($ip)_LOG.txt -Append
	}
	"7" {
		Write-Output "`nReiniciando serviço..." 
		Restart-Service -Name Spooler
		Write-Host "Serviço reiniciado." -ForegroundColor Blue
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	{"S", "s" -contains $_} { break }
	default {Write-Host "`nEssa opção não existe!" -ForegroundColor DarkRed}
}

} while ($opcao -ne "S" -and $opcao -ne "s")