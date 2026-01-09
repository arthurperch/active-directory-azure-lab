# Active Directory Azure Lab – Architecture Overview

Last Updated: January 6, 2026  
Applies to: Azure Portal (2025 Q4), Windows Server 2022, Windows 11 Enterprise

---

## Purpose of This Document
Understand how the lab components fit together before you provision any resources. A clear picture reduces misconfiguration and helps you explain the environment on resumes and in interviews.

---

## Visual Diagram Placeholder
Insert your preferred diagram tool output here:

![Lab Architecture Diagram](../screenshots/architecture-topology.png)

> Tip: Draw a diagram even if you are the only viewer. Visualizing IP ranges, DNS flow, and trust boundaries makes troubleshooting easier later.

---

## ASCII Topology (Optional Reference)
```
             Internet
                 |
          Azure Public IP
                 |
        +----------------+
        |  Network NAT   |
        +----------------+
                 |
         [Resource Group]
                 |
        +----------------+
        |    VNet Active_D_vnet
        |    Subnet default (10.0.0.0/24)
        +----------------+
           |            |
           |            |
   +---------------+  +---------------+
   | dc-1          |  | client-1      |
   | Win Server    |  | Windows 11    |
   | DHCP address  |  | 10.0.0.5      |
   | DNS + AD DS   |  | Uses dc-1 for |
   | NSG allows    |  | DNS + Domain  |
   | RDP           |  | Auth          |
   +---------------+  +---------------+
```

---

## Component Breakdown
| Component | Purpose | Key Settings |
| --- | --- | --- |
| Resource Group | Container for all lab assets. Simplifies cleanup and cost tracking. | Name: `Active_Dir_Lab` |
| Virtual Network (VNet) | Software-defined network that isolates lab traffic inside Azure. | Address space: `10.0.0.0/24` (`Active_D_vnet`) |
| Subnet | Smaller network segment that hosts the lab VMs. | Subnet name: `default` |
| Network Security Group (NSG) | Firewall rules controlling inbound/outbound traffic. | Allow TCP 3389 (RDP) from your public IP. Allow intra-subnet traffic. |
| Domain Controller VM | Windows Server 2022 machine running Active Directory Domain Services (AD DS) and DNS. | Hostname `dc-1`, dynamic private IP, Standard_B2s size. |
| Client VM | Windows 11 machine joined to the domain. | Hostname `client-1`, obtains dynamic IP (typically `10.0.0.5`), DNS server set to `dc-1`. |
| Azure DNS / Public IP | Provides RDP access from your workstation to each VM. | Use Just-In-Time access or restrict inbound 3389 to your IP. |

---

## Key Concepts for Beginners
- **Domain Controller**: The server that authenticates users, stores Active Directory data, and issues security tokens. In this lab, `dc-1` holds the forest root domain (`mydomain.com`).
- **DNS**: Domain Name System resolves hostnames to IP addresses. The domain controller doubles as the DNS server so domain-joined devices can locate services.
- **DHCP reservation**: Azure assigns addresses dynamically inside the subnet. Document the IP that `dc-1` receives so you can reference it in client DNS settings.
- **Organizational Unit (OU)**: A container that helps administrators group users, computers, or other objects for easier management and Group Policy targeting.
- **Group Policy Object (GPO)**: A collection of settings applied to users or computers. GPOs enforce security standards, scripts, and software deployments.

---

## How Traffic Flows
1. **RDP from your workstation** reaches the Azure VM public IP. The NSG evaluates inbound rules and forwards allowed requests to the VM private IP.
2. **Client authentication** occurs when the Windows 11 VM (`client-1`) contacts the domain controller (`dc-1`) using Kerberos/LDAP over the virtual network. DNS records hosted on the domain controller make name resolution possible.
3. **Group Policy replication** triggers when the client refreshes policies (`gpupdate` or every 90 minutes). The client pulls policy data and settings from the `SYSVOL` share on the domain controller.
4. **PowerShell automation** runs locally on the domain controller. User objects are stored in the Active Directory database (`NTDS.dit`) and replicated within the forest if additional domain controllers exist.

---

## Interaction Summary
| Source | Destination | Protocol | Purpose |
| --- | --- | --- | --- |
| Workstation | dc-1 / client-1 | RDP (TCP 3389) | Remote management |
| client-1 | dc-1 | DNS (UDP/TCP 53) | Name resolution |
| client-1 | dc-1 | Kerberos (TCP/UDP 88) | Authentication |
| client-1 | dc-1 | LDAP (TCP/UDP 389) | Directory lookups |
| client-1 | dc-1 | SMB (TCP 445) | Group Policy and logon scripts |

---

## Security Considerations
- Restrict RDP access to your public IP. Avoid permitting `0.0.0.0/0` unless you are in a temporary testing phase.
- Use Azure Just-In-Time VM access if available on your subscription to limit exposure.
- Apply Azure tags (for example, `Environment=Lab`) to make cleanup queries easier.

---

## Cost Awareness
Even architecture planning has cost implications:
- Each running VM consumes compute charges. If you add optional servers, review the pricing calculator first.
- Network resources (VNets, subnets, NSGs) are largely free, but public IP addresses incur small daily charges while allocated.
- Azure storage retains VM disks even when machines are stopped. Budget for $5–$10 USD monthly if you keep disks around for future labs.

⚠️ **Reminder**: Stop and **deallocate** VMs via the Azure Portal whenever you finish a configuration phase. Deallocating releases compute resources and keeps the lab eligible for free-tier credits.

---

## Next Steps
Move on to [01-Azure-Setup](01-Azure-Setup.md) to create the resource group, network, and NSG that support this design.
