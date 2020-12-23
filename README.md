# esxikickstart

## Usage

1. extract ESXi ISO of your choice be it VMware plain or Vendor provided one to a temporary location
2. dot source functions ```. .\Edit-ESXiSO.ps1; . .\New-ISOFile.ps1 ```
3. ``` Edit-ESXiISO -Hostname hostname.domain.net -IP 10.0.0.2 -Gateway 10.0.0.1 -Subnetmask 255.255.255.0 -RootPassword mypassword -Keyboard German -Nameserver 10.0.1.2 -ISOTempDir ./tempdir ```
4. ``` dir .\tempdir | New-IsoFile -Path custom.iso -BootFile .\tempdir\\EFIBOOT.IMG ```

This will create a custom.iso file that you can use to EFI Boot your baremetal host. It will get kickstarted and if everything went well you will have a ready to use ESXi instance after some minutes.

