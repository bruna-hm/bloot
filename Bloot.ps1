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
	
Write-Host "`n             MENU`n" -ForegroundColor DarkYellow
Write-Output "1 - Ip's versao 4 adaptadores"
Write-Output "2 - Impressoras Instaladas"
Write-Output "3 - Drivers de Impressoras"
Write-Output "4 - Portas de impressoras"
Write-Output "5 - Testes de Conectividade"
Write-OutPut "6 - Reiniciar Spooler de impressao"
Write-host "S/s " -ForegroundColor DarkRed -NoNewLine
Write-Host "- Sair`n"

Get-CimInstance -ClassName Win32_ComputerSystem | 
ForEach-Object {
	Write-Host "Nome:" -NoNewLine
	Write-Host "$(($_.Name))" -ForegroundColor DarkGreen -NoNewLine
	Write-Host " Domain:" -NoNewLine
	Write-Host "$(($_.Domain))" -ForegroundColor DarkGreen 
}

$opcao = Read-Host -Prompt "`nOpcao"
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

function Waiting {
	param (
		[Parameter(Mandatory=$true)]
        [ScriptBlock]$Command
	)
	$Symbols = @('|', '/', '-', '\')
    $SymbolIndex = 0
    $Job = Start-Job -ScriptBlock $Command
	while ($Job.State -eq 'Running') {
        if ($SymbolIndex -ge $Symbols.Count) {
            $SymbolIndex = 0
        }
        Write-Host -NoNewline -Object ("{0}`b" -f $Symbols[$SymbolIndex++]) -ForegroundColor Cyan
        Start-Sleep -Milliseconds 200
    }
	$Job | Wait-Job
    Write-Host "`n"
	Receive-Job -Job $Job
    Remove-Job -Job $Job
}	

switch ($opcao) {
	"1" {
		Write-Output "IPv4 de adaptadores"
		Waiting -Command {Get-NetIPAddress -AddressFamily IPv4} |
		Select-Object IPAddress, InterfaceAlias |
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"2" {
		Write-Output "Impressoras instaladas"
		Waiting -Command {Get-Printer} |
		Select-Object Name, DriverName, Shared |
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"3" {
		Write-Output "Drivers de impressoras"
		Waiting -Command {Get-PrinterDriver} |
		Select-Object Name, Manufacturer, PrinterEnvironment |
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"4" {
		Write-Output "Portas do servidor de impressao"
		Waiting -Command {Get-PrinterPort} |
		Select-Object Name, Description, PortMonitor | 
		Format-Table -AutoSize
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	"5" {
		do {
		Write-Host "`n          TESTES`n" -ForegroundColor DarkYellow
		Write-Output "1 - Disgnostico Rapido"
		Write-OutPut "2 - Ping em repeticao"
		Write-Output "3 - Ping com LOG"
		Write-Host "V/v " -ForegroundColor DarkRed -NoNewline
		Write-Host "- Voltar"
		
		$opcRede = Read-Host "`nOpcao"
		
			switch ($opcRede) {
				"1" {
					do {
					Write-OutPut "Diagnostico Rapido`n"
					$ip = Read-Host "`nDigite o IP"
						if (IpParser $ip) {
							$diagn = Test-NetConnection -RemoteAddress $ip
							Write-OutPut -InputObject $diagn 
							$continuar = Read-Host "`nContinuar no teste? (S/N)"
						} else {
							Write-Host "`nIP Inválido" -ForegroundColor Red
							$continuar = Read-Host "`nContinuar no teste? (S/N)"
						}
					} while ($continuar -ne "N" -and $continuar -ne "n")
				}
				"2" {
					do {
					Write-OutPut "`nPING"
					$ip = Read-Host "`nDigite o IP"
						if (IpParser $ip) {
							Write-Output "`nIniciando teste em outra janela..."
							Start-Process -FilePath cmd.exe -ArgumentList "/k", "ping -t $ip"
						} else {
							Write-Host "`nIP Invalido" -ForegroundColor Red
						}
					$continuar = Read-Host "`nContinuar no teste? (S/N)"
					} while ($continuar -ne "N" -and $continuar -ne "n")
				}
				"3" {
					do {
						Write-OutPut "`nPING c/ LOG"
					$ip = Read-Host "`nDigite o IP"
						if (IpParser $ip) {
							Write-Output "`nIniciando teste..."
							Write-Output "O LOG será escrito no mesmo local onde está o Script"
							$logfile = ".\$($ip)_LOG.txt"
							[System.IO.File]::WriteAllText($logFile, "TARGET = $ip", [System.Text.Encoding]::UTF8)
							Start-Process -FilePath cmd.exe -ArgumentList "/k", "ping -t $ip >> .\$($ip)_LOG.txt"
							Write-Host "`nPara encerrar o LOG feche a cmd que foi aberta!`n" -ForegroundColor DarkGreen
						} else {
							Write-Host "`nIP Invalido" -ForegroundColor Red
						}
					$continuar = Read-Host "Continuar no teste com LOG? (S/N)"
					} while ($continuar -ne "N"  -and $continuar -ne "n")
				}
				{"V", "v" -contains $_} { break }
				default {Write-Host "`nEssa opcao não existe!" -ForegroundColor Red}
			}
			
		} while ($opcRede -ne "V" -and $opcRede -ne "v")
	}	
	"6" {
		Write-Output "`nReiniciando serviço..." 
		Waiting -Command {Restart-Service -Name Spooler}
		Write-Host "Servico reiniciado." -ForegroundColor Blue
		Write-Host "`nAperte qualquer tecla para continuar..."
		$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	}
	{"S", "s" -contains $_} { break }
	default {Write-Host "`nEssa opcao nao existe!" -ForegroundColor Red}
}
} while ($opcao -ne "S" -and $opcao -ne "s")