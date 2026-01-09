# Active Directory Azure Lab – Deploy the Client VM

Last Updated: January 6, 2026  
Applies to: Azure Portal (2025 Q4 UI), Windows 11 Enterprise

---

## Objective
Create a Windows 11 virtual machine, configure DNS to point at the domain controller, join the machine to the Active Directory domain, and verify connectivity.

---

## Prerequisites
- [02-Deploy-Domain-Controller](02-Deploy-Domain-Controller.md) completed and the domain controller is running.
- Domain controller private IP recorded in the previous step (for example, `10.0.0.4`).
- Domain administrator credentials (for example, `MYDOMAIN\\Administrator`).

⚠️ **Important cost reminder**
```
Each additional VM adds to your hourly spend.
Stop and deallocate both VMs when you are not actively testing.
```

---

## Step 1 – Create the Client VM
1. In the resource group, select **Create** > **Virtual machine**.
2. Basics tab:
   - Name: `client-1`.
   - Image: **Windows 11 Enterprise, version 23H2** (or Windows 10 Enterprise if you prefer).
   - Size: `Standard_B2s` (2 vCPU, 4 GiB RAM).
   - Administrator username/password: choose strong credentials (different from domain admin to avoid confusion).
3. Networking tab:
   - Virtual network: `Active_D_vnet`.
   - Subnet: `default`.
   - Public IP: create new (`client-1-ip`).
   - NIC NSG: Attach `client-1-nsg` so the configuration matches `dc-1`.
4. Review and create the VM.

> Tip: Consider enabling auto-shutdown at a convenient time (for example, 22:00 local) to avoid accidental overnight charges.

---

## Step 2 – Review the Private IP
1. Open the VM’s **Networking** blade.
2. Select the network interface and open **IP configurations**.
3. Note the dynamically assigned IPv4 address (expect `10.0.0.5` in this lab). Leave the assignment set to **Dynamic** so the environment mirrors the reference screenshots.

Azure keeps the IP reserved for the NIC while it exists. Document the value in your lab journal for future troubleshooting.

---

## Step 3 – Configure DNS to Use the Domain Controller
1. Still on the NIC blade, select **DNS servers**.
2. Set DNS to **Custom**.
3. Enter the `dc-1` private IP you recorded earlier (for example, `10.0.0.4`).
4. Save changes. The VM may need a restart to pick up new settings.

> Definition: **DNS** (Domain Name System) resolves human-readable names to IP addresses. Pointing the client at the domain controller ensures domain join and resource discovery work.

---

## Step 4 – Connect via RDP
1. From the VM overview page, use **Connect** > **RDP**.
2. Sign in with the local administrator credentials you set during deployment.
3. Allow the system to finish initial setup (takes a few minutes on first login).

---

## Step 5 – Join the Domain
1. Open **Settings** > **System** > **About** > **Advanced system settings** > **Computer Name** tab > **Change**.
2. In **Member of**, select **Domain** and enter your domain (example: `mydomain.com`).
3. Provide domain admin credentials when prompted.
4. On success, you see a welcome message to the domain. Restart the VM to apply changes.

Alternate method via PowerShell (run as Administrator):
```powershell
Add-Computer -DomainName "mydomain.com" -Credential "MYDOMAIN\Administrator" -Restart
```

---

## Step 6 – Log On with Domain Credentials
1. After reboot, select **Other user** on the sign-in screen.
2. Enter `MYDOMAIN\GlobalUser` (replace with a real domain account, such as `MYDOMAIN\Administrator`).
3. Verify the logon completes without error.

---

## Step 7 – Test Connectivity
Run these commands in Windows PowerShell:
```powershell
# Confirm DNS server assignment
Get-DnsClientServerAddress -InterfaceAlias "Ethernet"

# Test DNS resolution of the DC
Resolve-DnsName dc-1.mydomain.com

# Confirm LDAP connectivity
Test-NetConnection -ComputerName dc-1.mydomain.com -Port 389

# Check domain membership
(Get-ComputerInfo).CsDomain
```
Expected output:
- DNS server list contains the `dc-1` IP you documented.
- DNS resolution returns the `dc-1` IP.
- `Test-NetConnection` shows `TcpTestSucceeded : True`.
- `CsDomain` equals your domain name.

---

## Troubleshooting
| Issue | Symptoms | Solution |
| --- | --- | --- |
| Cannot join domain | "The domain controller could not be contacted" | Ensure DNS is set to the `dc-1` IP and the NSGs allow intra-VNet traffic. Use `Test-NetConnection` against port 389 to confirm reachability. |
| Wrong domain credentials | "Access is denied" during join | Use `MYDOMAIN\Administrator` format and verify the password on `dc-1`. |
| Slow logons | Long pause at "Applying computer settings" | Confirm the client uses the private IP of `dc-1` for DNS; remove any public DNS entries. |

---

## Cost Control Reminder
- Stop both `dc-1` and `client-1` when not in use.
- Monitor the **Cost analysis** blade in Cost Management to ensure spending aligns with the $15.33 baseline captured in the reference deployment.

---

## Next Steps
Continue to [04-Creating-Users-PowerShell](04-Creating-Users-PowerShell.md) to build organizational units and bulk user accounts.
