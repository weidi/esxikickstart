<#
.Synopsis
   Edit the  Files of an ESXi ISO
.DESCRIPTION
   Editing ISO Files of an extracted ESXi setup ISO to inject a kickstart file
.EXAMPLE
   Edit-ESXiISO -Hostname hostname.domain.net -IP 10.0.0.2 -Gateway 10.0.0.1 -Subnetmask 255.255.255.0 -Vlan 1000 -Mmnic vmnic0 -RootPassword mypassword -Keyboard German -Nameserver 10.0.1.2 -ISOTempDir ./iso
.EXAMPLE
   Edit-ESXiISO -Hostname hostname.domain.net -IP 10.0.0.2 -Gateway 10.0.0.1 -Subnetmask 255.255.255.0 -RootPassword mypassword -Keyboard German -Nameserver 10.0.1.2 -ISOTempDir ./iso
#>
function Edit-ESXiISO
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
        [Parameter(Mandatory=$true)]
        [String]$IP,
        [Parameter(Mandatory=$true)]
        [string]$Subnetmask,
        [Parameter(Mandatory=$true)]
        [string]$Gateway,
        [int]$Vlan,
        [string]$Mmnic,
        [Parameter(Mandatory=$true)]
        [string]$RootPassword,
        [ValidateSet('Belgian','Brazilian','Croatian','Czechoslovakian','Danish','Estonian','Finnish','French','German','Greek','Icelandic','Italian','Japanese','Latin American','Norwegian','Polish','Portuguese','Russian','Slovenian','Spanish','Swedish','Swiss French','Swiss German','Turkish','Ukrainian','United Kingdom','US Default','US Dvorak')]
        [String]$Keyboard = "German",
        [Parameter(Mandatory=$true)]
        [string]$Nameserver,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})]
        [string]$ISOTempDir
    )

    Begin
    {
        $ks = @("
##############################
# Custom ESXi kickstart file #
##############################

accepteula
clearpart --firstdisk=local --overwritevmfs
install --firstdisk=local --overwritevmfs

#Set password, either encrypted or unencrypted
#rootpw --iscrypted $(Get-StringHash $rootPassword -HashName SHA512)
rootpw $rootPassword

#Keyboard
keyboard $Keyboard

reboot


")

    }
    Process
    {
        $networkString = "network --bootproto=static --addvmportgroup=0 --ip=$IP --netmask=$subnetmask --gateway=$gateway --nameserver=$nameserver --hostname=$Hostname "
        if($vlan)
        {
            $networkString += "--vlanid=$vlan "
        }
        if($vmnic)
        {
            $networkString += "--device=$vmnic "
        }
        $ks += $networkString
    }
    End
    {
        $ks | Out-File -FilePath "$ISOTempDir\KS_CUST.cfg" -Encoding ascii
        (Get-Content $ISOTempDir\EFI\BOOT\BOOT.cfg ).Replace('cdromBoot','ks=cdrom:/KS_CUST.CFG') | Out-File $ISOTempDir\EFI\BOOT\BOOT.cfg -Encoding ascii
        (Get-Content $ISOTempDir\BOOT.cfg ).Replace('cdromBoot','ks=cdrom:/KS_CUST.CFG') | Out-File $ISOTempDir\BOOT.cfg -Encoding ascii 
    }
}

Function Get-StringHash([String] $String,$HashName = "MD5")
{
  $StringBuilder = New-Object System.Text.StringBuilder
  [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
  [Void]$StringBuilder.Append($_.ToString("x2"))
  }
  $StringBuilder.ToString()
}