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
Write-Output "5 - Testes de Conectividade"
Write-OutPut "6 - Reiniciar Spooler de impressão"
Write-Output "S/s - Sair`n"

Get-CimInstance -ClassName Win32_ComputerSystem | 
ForEach-Object {
	Write-Host "Nome:" -NoNewLine
	Write-Host "$(($_.Name))" -ForegroundColor DarkMAgenta -NoNewLine
	Write-Host " Domain:" -NoNewLine
	Write-Host "$(($_.Domain))" -ForegroundColor DarkGreen 
}

$opcao = Read-Host -Prompt "`nOpção"
Write-Output ""

function IpParser {
	param (
		[string]$ip
	)
	if ($ip -match '^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$')
	{
	return $true 
	} return $false
}

switch ($opcao) {
	"1" {
		Get-NetIPAddress -AddressFamily IPv4 |
		Select-Object IPAddress, InterfaceAlias |
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"2" {
		Get-Printer |
		Select-Object Name, DriverName, Shared |
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"3" {
		Get-PrinterDriver |
		Select-Object Name, Manufacturer, PrinterEnvironment |
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"4" {
		Get-PrinterPort |
		Select-Object Name, Description, PortMonitor | 
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"5" {
		do {
		Write-Output "`n          TESTES`n"
		Write-Output "1 - Disgnóstico Rápido"
		Write-OutPut "2 - Ping em repetição"
		Write-Output "3 - Ping com LOG"
		Write-OutPut "V/v - Voltar"
		
		$opcRede = Read-Host "`nOpção"
		
			switch ($opcRede) {
				"1" {
					$ip = Read-Host "`nDigite o IP"
					Test-NetConnection -ComputerName $ip
					Write-Host "`nAperte qualquer tecla para continuar..."
					$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
				}
				"2" {
					do {
					$ip = Read-Host "`nDigite o IP"
					if (IpParser $ip) {
						Write-Output "`nIniciando teste em outra janela..."
						Start-Process -FilePath cmd.exe -ArgumentList "/k", "ping -t $ip"
					} else {
						Write-Host "`nIP Inválido" -ForegroundColor DarkRed
					}
					$continuar = Read-Host "`nContinuar no teste? (S/N)"
					} while ($continuar -ne "N" -and $continuar -ne "n")
				}
				"3" {
					do {
					$ip = Read-Host "`nDigite o IP"
					if (IpParser $ip) {
						Write-Output "`nIniciando teste..."
						Write-Output "O LOG será escrito no mesmo local onde está o Script"
						"TARGET = " + $ip | Out-File .\$($ip)_LOG.txt
						Start-Process -FilePath cmd.exe -ArgumentList "/k", "ping -t $ip >> .\$($ip)_LOG.txt"
						Write-Host "`nPara encerrar o LOG feche a cmd que foi aberta!`n" -ForegroundColor DarkRed
					} else {
						Write-Host "`nIP Inválido" -ForegroundColor DarkRed
					}
					$continuar = Read-Host "Continuar no teste com LOG? (S/N)"
					} while ($continuar -ne "N"  -and $continuar -ne "n")
				}
				{"V", "v" -contains $_} { break }
				default {Write-Host "`nEssa opção não existe!" -ForegroundColor DarkRed}
			}
			
		} while ($opcRede -ne "V" -and $opcRede -ne "v")
	}	
	"6" {
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