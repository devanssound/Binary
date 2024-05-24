<#Learn Subnetting! | subnet.ps1 #>

# Input: CIDR value like 24 or 26;
# Output: SubnetMask in Binary 11111111 11111111 11111111 11000000
function Convert-CIDRToBinaryMask {
    param (
        [int]$CIDR
    )
    # $CIDR notates how many bits are for the network: 26 bits for network: 11111111111111111111111111
    # IPv4 uses 32bit values. 32 - 26 = 6 (number of '0' bits for the hosts) 000000
    # BinaryMask = 11111111 11111111 11111111 11000000
    $binaryMask = "1" * $CIDR + "0" * (32 - $CIDR)
    $binaryMask = $binaryMask -replace '.{8}', '$& ' # Add spaces every 8 bits
    return $binaryMask.Trim()
}

# Input: SubnetMask in Binary 11111111 11111111 11111111 11000000;
# Output: SubnetMask in decimal notation 255.255.255.192
function Convert-BinaryMaskToDecimal {
    param (
        [string]$BinaryMask
    )

    $binaryOctets = $BinaryMask -split ' '
    $decimalMask = $binaryOctets | ForEach-Object { [convert]::ToInt32($_, 2) }
    return ($decimalMask -join '.')
}

# I/O: User prompt like 192.168.1.8/23
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

while ($true) {
     $userInput = Get-IPCIDR
     Write-Host "Debug: Processing user input: $userInput"  # Debug output
        $parts = $userInput -split '/'
        $ipAddress = $parts[0]
        $cidr = [int]$parts[1]
        if ($cidr -ge 0 -and $cidr -le 32) {
            $binaryMask = Convert-CIDRToBinaryMask -CIDR $cidr
            $decimalMask = Convert-BinaryMaskToDecimal -BinaryMask $binaryMask
            Write-Host "IP Address: $ipAddress"
            Write-Host "CIDR Notation: /$cidr"
            Write-Host "Subnet Mask (Decimal): $decimalMask"
            Write-Host "Subnet Mask (Binary): $binaryMask"
            break
        }
        else {
            Write-Host "Invalid CIDR value. Please try again."
        }
    }
}
