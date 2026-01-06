# Active Directory Azure Lab – Deploy the Client VM

Last Updated: January 6, 2026  
Applies to: Azure Portal (2025 Q4 UI), Windows 11 Enterprise, Windows 10 Enterprise

---

## Objective
Create a Windows 10/11 virtual machine, configure DNS to point at the domain controller, join the machine to the Active Directory domain, and verify connectivity.

---

## Prerequisites
- [02-Deploy-Domain-Controller](02-Deploy-Domain-Controller.md) completed and the domain controller is running.
- Domain controller private IP (`10.0.0.4` by default).
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
   - Name: `client01`.
   - Image: **Windows 11 Enterprise, version 23H2** (or Windows 10 Enterprise if you prefer).
   - Size: `Standard_B2s` (2 vCPU, 4 GiB RAM).
   - Administrator username/password: choose strong credentials (different from domain admin to avoid confusion).
3. Networking tab:
   - Virtual network: `vnet-ad-lab`.
   - Subnet: `subnet-lab`.
   - Public IP: create new.
   - NIC NSG: None (rely on subnet NSG).
4. Review and create the VM.

> Tip: Consider enabling auto-shutdown at a convenient time (for example, 22:00 local) to avoid accidental overnight charges.

---

## Step 2 – Assign Static Private IP (Optional but Recommended)
1. Open the VM’s **Networking** blade.
2. Select the network interface and open **IP configurations**.
3. Change `ipconfig1` assignment to `Static` and set the IP to `10.0.0.5`.

Static IPs are not mandatory for member servers, but they simplify documentation and troubleshooting during the lab.

---

## Step 3 – Configure DNS to Use the Domain Controller
1. Still on the NIC blade, select **DNS servers**.
2. Set DNS to **Custom**.
3. Enter `10.0.0.4` (the domain controller IP).
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
Resolve-DnsName dc01.mydomain.com

# Confirm LDAP connectivity
Test-NetConnection -ComputerName dc01.mydomain.com -Port 389

# Check domain membership
(Get-ComputerInfo).CsDomain
```
Expected output:
- DNS server list contains `10.0.0.4`.
- DNS resolution returns the DC IP.
- `Test-NetConnection` shows `TcpTestSucceeded : True`.
- `CsDomain` equals your domain name.

---

## Troubleshooting
| Issue | Symptoms | Solution |
| --- | --- | --- |
| Cannot join domain | "The domain controller could not be contacted" | Ensure DNS is set to `10.0.0.4` and the NSG allows intra-VNet traffic. Ping `10.0.0.4` to confirm network reachability. |
| Wrong domain credentials | "Access is denied" during join | Use `MYDOMAIN\Administrator` format and verify the password on `dc01`. |
| Slow logons | Long pause at "Applying computer settings" | Confirm the client uses the private IP of the DC for DNS; remove any public DNS entries. |

---

## Cost Control Reminder
- Stop both `dc01` and `client01` when not in use.
- Monitor the **Estimated cost** tile in Cost Management to keep the monthly total near $10 USD.

---

## Next Steps
Continue to [04-Creating-Users-PowerShell](04-Creating-Users-PowerShell.md) to build organizational units and bulk user accounts.
