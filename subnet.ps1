<#Learn Subnetting! | subnet.ps1 #>

# Convert CIDR to Binary Mask
function Convert-CIDRToBinaryMask {
    param (
        [int]$CIDR
    )
    $binaryMask = "1" * $CIDR + "0" * (32 - $CIDR)
    $binaryMask = $binaryMask -replace '.{8}', '$& ' # Add spaces every 8 bits
    return $binaryMask.Trim()
}

# Convert Binary Mask to Decimal
function Convert-BinaryMaskToDecimal {
    param (
        [string]$BinaryMask
    )

    $binaryOctets = $BinaryMask -split ' '
    $decimalMask = $binaryOctets | ForEach-Object { [convert]::ToInt32($_, 2) }
    return ($decimalMask -join '.')
}

# Get User Input for IP and CIDR
function Get-IPCIDR {
    param (
        [string]$Prompt = "Enter IP address and CIDR notation (ex: 192.168.1.1/24) "
    )

    while ($true) {
        $userInput = Read-Host $Prompt
        Write-Host "Debug: User input received: $userInput"  # Debug output
        if ($userInput -match '^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$') {
            Write-Host "Debug: Valid input received: $userInput"  # Debug output
            return $userInput
        }
        else {
            Write-Host "Invalid input. Please try again."
        }
    }
}

# Calculate Network Address
function Get-NetworkAddress {
    param (
        [string]$ipAddress,
        [int]$cidr
    )
    $ip = [System.Net.IPAddress]::Parse($ipAddress).GetAddressBytes()
    $binaryMask = "1" * $cidr + "0" * (32 - $cidr)
    $maskBytes = [byte[]](0, 0, 0, 0)
    for ($i = 0; $i -lt 4; $i++) {
        $maskBytes[$i] = [convert]::ToInt32($binaryMask.Substring($i * 8, 8), 2)
    }
    $networkBytes = [byte[]](0, 0, 0, 0)
    for ($i = 0; $i -lt 4; $i++) {
        $networkBytes[$i] = $ip[$i] -band $maskBytes[$i]
    }
    return [System.Net.IPAddress]::new($networkBytes)
}

# Calculate First and Last Host Address
function Get-FirstAndLastHost {
    param (
        [string]$ipAddress,
        [int]$cidr
    )
    $networkAddress = Get-NetworkAddress -ipAddress $ipAddress -cidr $cidr
    $binaryMask = "1" * $cidr + "0" * (32 - $cidr)
    $maskBytes = [byte[]](0, 0, 0, 0)
    for ($i = 0; $i -lt 4; $i++) {
        $maskBytes[$i] = [convert]::ToInt32($binaryMask.Substring($i * 8, 8), 2)
    }
    $broadcastBytes = [byte[]](0, 0, 0, 0)
    for ($i = 0; $i -lt 4; $i++) {
        $broadcastBytes[$i] = [byte]($networkAddress.GetAddressBytes()[$i] -bor ($maskBytes[$i] -bxor 255))
    }
    $firstHostBytes = [byte[]](0, 0, 0, 0)
    $lastHostBytes = [byte[]](0, 0, 0, 0)
    for ($i = 0; $i -lt 4; $i++) {
        $firstHostBytes[$i] = $networkAddress.GetAddressBytes()[$i]
        $lastHostBytes[$i] = $broadcastBytes[$i]
    }
    $firstHostBytes[3] = $firstHostBytes[3] + 1
    $lastHostBytes[3] = $lastHostBytes[3] - 1
    $firstHost = [System.Net.IPAddress]::new($firstHostBytes)
    $lastHost = [System.Net.IPAddress]::new($lastHostBytes)
    return @{FirstHost=$firstHost; LastHost=$lastHost}
}

# Interactive Subnetting Program
function SubnettingMenu {
    while ($true) {
        Write-Host "Choose an option:"
        Write-Host "1. Find the subnet the host belongs to"
        Write-Host "2. Find the last valid host on the network"
        Write-Host "3. Find the first valid host on the network the host is part of"
        Write-Host "4. Exit"
        $choice = Read-Host "Enter your choice (1-4)"

        switch ($choice) {
            1 {
                $UserInput = Get-IPCIDR "Enter the host IP address and CIDR notation (ex: 192.168.1.1/24): "
                $parts = $UserInput -split '/'
                $ipAddress = $parts[0]
                $cidr = [int]$parts[1]
                $networkAddress = Get-NetworkAddress -ipAddress $ipAddress -cidr $cidr
                Write-Host "The subnet the host $ipAddress/$cidr belongs to is: $networkAddress/$cidr"
            }
            2 {
                $UserInput = Get-IPCIDR "Enter the network IP address and CIDR notation (ex: 192.168.1.0/24): "
                $parts = $UserInput -split '/'
                $ipAddress = $parts[0]
                $cidr = [int]$parts[1]
                $hosts = Get-FirstAndLastHost -ipAddress $ipAddress -cidr $cidr
                Write-Host "The last valid host on the network $ipAddress/$cidr is: $($hosts.LastHost)"
            }
            3 {
                $UserInput = Get-IPCIDR "Enter the host IP address and CIDR notation (ex: 192.168.1.1/24): "
                $parts = $UserInput -split '/'
                $ipAddress = $parts[0]
                $cidr = [int]$parts[1]
                $hosts = Get-FirstAndLastHost -ipAddress $ipAddress -cidr $cidr
                Write-Host "The first valid host on the network $ipAddress/$cidr is: $($hosts.FirstHost)"
            }
            4 {
                Write-Host "Exiting..."
                break
            }
            default {
                Write-Host "Invalid choice. Please try again."
            }
        }
    }
}

# Run the interactive subnetting menu
SubnettingMenu
