function IsValidIPAddress {
    param (
        [string]$ip
    )
    # Verifica se o IP está no formato correto com regex
    if ($ip -match '^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$') {
        # Se o formato é válido, usa TryParse para garantir
        return [System.Net.IPAddress]::TryParse($ip, [ref]$null)
    }
    return $false
}

# Teste
$ip = "192"
if (IsValidIPAddress $ip) {
    Write-Host "IP válido"
} else {
    Write-Host "IP inválido"
}