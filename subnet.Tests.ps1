# subnet.Tests.ps1
# Set-Location or CD to path of subnet.Tests.ps1
# Invoke-Pester .\subnet.Tests.ps1

Describe 'Get-IPCIDR' {
    Context 'with valid input' {
        It 'should return the user input if valid' {
            # Read-Host to return a valid IP/CIDR
            Mock -CommandName Read-Host -MockWith { "192.168.1.1/24" }
            $result = Get-IPCIDR
            $expected = "192.168.1.1/24"
            $result | Should -BeExactly $expected
        }
    }

    Context 'with invalid input' {
        It 'should retry if the input is invalid' -Skip {
            # Read-Host to return an invalid IP/CIDR first, then a valid one
            Mock -CommandName Read-Host -MockWith {
                if ($global:retryCount -eq $null) { $global:retryCount = 0 }
                $global:retryCount++
                if ($global:retryCount -eq 1) { return "invalid_input" }
                return "192.168.1.1/24"
            }
            $result = Get-IPCIDR
            $expected = "192.168.1.1/24"
            $result | Should -BeExactly $expected
        }
    }
}

Describe 'Main function' {
    It 'should process a valid IP/CIDR and print correct results' -Skip {
        # Read-Host to return a valid IP/CIDR
        Mock -CommandName Read-Host -MockWith { "192.168.1.1/24" }
        Main
        # Expected output
        Assert-MockCalled -CommandName Write-Host -ParameterFilter { $args[0] -like "IP Address: 192.168.1.1" } -Times 1
        Assert-MockCalled -CommandName Write-Host -ParameterFilter { $args[0] -like "CIDR Notation: /24" } -Times 1
        Assert-MockCalled -CommandName Write-Host -ParameterFilter { $args[0] -like "Subnet Mask (Decimal): 255.255.255.0" } -Times 1
        Assert-MockCalled -CommandName Write-Host -ParameterFilter { $args[0] -like "Subnet Mask (Binary): 11111111 11111111 11111111 00000000" } -Times 1
    }
}
