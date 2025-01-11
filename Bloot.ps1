#Bloot

do {
$banner = @"

 ________  ___       ________  ________  _________   
|\   __  \|\  \     |\   __  \|\   __  \|\___   ___\ 
\ \  \|\ /\ \  \    \ \  \|\  \ \  \|\  \|___ \  \_| 
 \ \   __  \ \  \    \ \  \\\  \ \  \\\  \   \ \  \  
  \ \  \|\  \ \  \____\ \  \\\  \ \  \\\  \   \ \  \ 
   \ \_______\ \_______\ \_______\ \_______\   \ \__\
    \|_______|\|_______|\|_______|\|_______|    \|__|
                                                     
                                                     
                                                     
"@

Write-Host $banner -ForegroundColor Yellow
	
Write-Output "* Digite a opção e aperte Enter para selecioná-la *"
Write-Output "`n             MENU`n"
Write-Output "1 - Ip's versão 4 da máquina"
Write-Output "2 - Impressoras Instaladas"
Write-Output "3 - Portas de impressoras"
Write-Output "4 - Teste de Comunicação de Rede"
Write-Output "5 - Teste de Comunicação de Rede com Log"
Write-OutPut "6 - Reiniciar Spooler de impressão"
Write-Output "S/s - Sair"

$opcao = Read-Host -Prompt "`nOpção"

switch ($opcao) {
	"1" { 
		Get-NetIPAddress -AddressFamily IPv4 |
		ForEach-Object{ "IPv4 - $(($_.IPAddress)) | Interface - $(($_.InterfaceAlias))" }
	}
	"2" {Get-Printer}
	"3" {Get-PrinterPort}
	"4" {
		$ip = Read-Host "`nDigite o IP"
		Test-Connection -Repeat -TargetName $ip
	}
	"5" {
		$ip = Read-Host "`nDigite o IP"
		Write-Output "`nPara interromper o teste aperte Ctrl-C. `nIniciando teste..."
		"Target = " + $ip | Out-File .\$($ip)_LOG.txt
		Test-Connection -Repeat -TargetName $ip| 
		ForEach-Object { 
		"$((Get-Date)) - Endereço: $(($_.Address)) - Status: $(($_.Status)) - Tempo de resposta: $(($_.Latency))ms" }|
		Out-File -FilePath .\$($ip)_LOG.txt -Append
	}
	"6" {
		Write-Output "`nReiniciando serviço..."
		Restart-Service -Name Spooler
		Write-Output "Serviço reiniciado."
	}
	{"S", "s" -contains $_} { break }
	default {Write-Output "`nEssa opção não existe!"}
}

} while ($opcao -ne "S" -and $opcao -ne "s")