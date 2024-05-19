# Subnetting PowerShell Script

Convert CIDR notation to binary, then into subnet mask in decimal notation (with Pester unit tests).

## Functions

`subnet.ps1`

- **Main** function calls and terminal output.
- **Get-IPCIDR** Prompts the user for an IP address and CIDR notation (192.168.1.1/24)
- **Convert-CIDRToBinaryMask** CIDR notation to binary subnet mask
- **Convert-BinaryMaskToDecimal** Binary subnet mask to decimal subnet mask

   To run, execute the following in PowerShell:

   ```powershell
   .\subnet.ps1
   ```
