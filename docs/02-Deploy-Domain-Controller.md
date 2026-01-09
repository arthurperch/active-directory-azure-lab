# Active Directory Azure Lab – Deploy the Domain Controller

Last Updated: January 6, 2026  
Applies to: Azure Portal (2025 Q4 UI), Windows Server 2022 Datacenter, PowerShell 7.4

---

## Goal
Provision a Windows Server 2022 VM, document its dynamically assigned IP, install Active Directory Domain Services (AD DS), and promote the server to a new forest (domain: `mydomain.com`).

---

## Before You Begin
- Complete [01-Azure-Setup](01-Azure-Setup.md).
- Decide on a domain name that is not publicly routable (for example, `mydomain.com` or `corp.contoso.local`).
- Gather local administrator credentials you will use when connecting via RDP.

⚠️ **Important cost reminder**
```
Creating a VM starts billing immediately.
Stop and deallocate the VM when you pause the lab.
```

---

## Step 1 – Create the Virtual Machine
1. In the resource group, select **Create** > **Virtual machine**.
2. Basics tab:
   - Subscription: same as earlier steps.
   - Resource group: `Active_Dir_Lab`.
   - Virtual machine name: `dc-1`.
   - Region: same as VNet.
   - Availability options: `No infrastructure redundancy required` (lab scenario).
   - Image: **Windows Server 2022 Datacenter: Azure Edition**.
   - Size: `Standard_B2s` (2 vCPU, 4 GiB RAM) – suitable for labs.
   - Administrator account: set a strong username/password (store securely).
3. Disks tab: OS disk type can be **Standard SSD** to balance cost and performance.
4. Networking tab:
   - Virtual network: `Active_D_vnet`.
   - Subnet: `default`.
   - Public IP: create new (keep default SKU Basic for lab).
   - NIC network security group: **None** (subnet-level NSG already protects traffic).
   - Public inbound ports: `None` (we rely on NSG rule created earlier).
5. Management tab: disable auto-shutdown only if you plan to manage your own schedule. Consider enabling it for extra cost protection.
6. Review and create the VM.

---

## Step 2 – Capture the Private IP
1. Once deployment finishes, open the VM and select **Networking** > **Network interface**.
2. Under **IP configurations**, note the IPv4 address Azure assigns (for example, `10.0.0.4`). Leave the setting as **Dynamic** to mirror the reference environment.
3. Record this value—you will point client DNS settings at it during the next guide.

> Definition: **DHCP reservation** – Azure retains the assigned IP while the NIC exists. Document the value so you can reapply it quickly if the VM is redeployed.

---

## Step 3 – Connect via RDP
1. From the VM overview, click **Connect** > **RDP**.
2. Download the RDP file and connect with the admin credentials you defined.
3. Accept any certificate warnings; this is expected for self-signed certificates.

If RDP fails, revisit the NSG inbound rule and ensure the VM status is `Running`.

---

## Step 4 – Rename the Computer (Optional but Recommended)
1. In Windows Server, open **Server Manager** > **Local Server**.
2. Click the computer name (default `WIN-XXXX`).
3. Select **Change**, enter `dc-1`, and confirm.
4. Restart the VM when prompted.

---

## Step 5 – Install AD DS Role
1. After restart, sign in again via RDP.
2. Open **Server Manager** > **Manage** > **Add Roles and Features**.
3. Choose **Role-based or feature-based installation**.
4. Select the local server.
5. Under **Server Roles**, check **Active Directory Domain Services**.
6. Accept required features and proceed through the wizard.
7. Select **Install** (no need to close the wizard; the installation continues in the background).

> Definition: **Active Directory Domain Services (AD DS)** – Microsoft directory service storing user accounts, computers, and security information.

---

## Step 6 – Promote to Domain Controller
1. When the role installation completes, click the yellow notification in Server Manager and select **Promote this server to a domain controller**.
2. Choose **Add a new forest**.
3. Enter your domain name (example: `mydomain.com`).
4. Domain Controller Options:
   - Forest functional level: `Windows Server 2016`.
   - Domain functional level: `Windows Server 2016`.
   - Keep DNS and Global Catalog selected.
   - Set a Directory Services Restore Mode (DSRM) password and store it securely.
5. DNS Options: Azure may warn about dynamic addressing. Confirm the NIC IP you documented earlier and continue.
6. Additional Options: NetBIOS name auto-populates (e.g., `MYDOMAIN`).
7. Paths: leave defaults (database, log files, SYSVOL).
8. Review options and select **Install**. The server restarts automatically.

---

## Step 7 – Verify Domain Controller Health
After reboot, reconnect using the domain credentials `MYDOMAIN\\Administrator` (replace with your domain).
After reboot, reconnect using the domain credentials `MYDOMAIN\\Administrator`.

Run the following checks in **Windows PowerShell** (run as Administrator):
```powershell
# Confirm domain services
Get-ADDomain

# Confirm DNS is running
Get-Service DNS

# Quick replication health (single DC should show success)
dcdiag /test:services
```

Expected results:
- `Get-ADDomain` returns your domain name and NetBIOS name.
- `Get-Service DNS` shows `Running`.
- `dcdiag` outputs `passed` results for all tests.

---

## Troubleshooting Tips
| Issue | Symptoms | Fix |
| --- | --- | --- |
| Promotion fails at DNS configuration | Wizard reports DNS error | Ensure the NIC lists its own IP first under DNS servers, then restart the promotion. |
| Cannot sign in with domain credentials | “User or password incorrect” | Use `MYDOMAIN\Administrator` format; confirm domain name spelled correctly. |
| `dcdiag` errors about FRS | Warning about deprecated File Replication Service | Acceptable in lab; Windows Server 2022 uses DFS Replication, so warnings may be informational. |

---

## Cost Control Reminder
- Deallocate `dc-1` whenever you pause the lab: Azure Portal > Virtual Machines > `dc-1` > **Stop** (deallocate).
- Leaving the VM running 24/7 can add $15–$20 USD per week depending on your region.

---

## Next Steps
Move to [03-Deploy-Client-VM](03-Deploy-Client-VM.md) to provision the Windows 11 workstation and join it to the domain.
