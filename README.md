# 🏢 Active Directory Azure Lab

![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoft-azure)
![Active Directory](https://img.shields.io/badge/Active_Directory-Windows-0078D4?style=for-the-badge&logo=windows)
![PowerShell](https://img.shields.io/badge/PowerShell-Automation-5391FE?style=for-the-badge&logo=powershell)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

Last Updated: January 6, 2026

Build a practical Active Directory environment in Microsoft Azure. The lab walks through provisioning Azure infrastructure, installing a Windows Server 2022 domain controller, joining a Windows client, automating user management with PowerShell, and enforcing security with Group Policy.

Tested with Azure Portal (2025 Q4), Windows Server 2022 Datacenter, Windows 11 Enterprise, PowerShell 7.4

---

## Contents
- [Project Overview](#project-overview)
- [Learning Objectives](#learning-objectives)
- [Target Audience](#target-audience)
- [Prerequisites](#prerequisites)
- [Estimated Time and Cost](#estimated-time-and-cost)
- [Architecture](#architecture)
- [Documentation Roadmap](#documentation-roadmap)
- [Quick Start](#quick-start)
- [Screenshots](#screenshots)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Project Overview
Stand up a small enterprise-style Active Directory forest in Azure. You will create a resource group, virtual network, Windows Server 2022 domain controller, and Windows 10/11 client VM. The documentation explains why each component matters and how they work together.

---

## Learning Objectives
You will be able to:
- Deploy Azure virtual machines and configure networking from scratch.
- Install and validate Active Directory Domain Services (AD DS).
- Join a Windows client to the new domain and confirm DNS name resolution.
- Create users manually and with the provided PowerShell automation script.
- Implement an account lockout Group Policy and test the results.
- Troubleshoot authentication, DNS, and GPO issues using built-in tools.
- Control Azure spending by stopping, deallocating, and deleting resources when idle.

Skills reinforced: Azure infrastructure, Windows Server administration, Active Directory management, DNS, PowerShell scripting, Group Policy, troubleshooting.

---

## Target Audience
- Entry-level IT professionals building real-world Active Directory practice.
- Students preparing for Microsoft or CompTIA certification exams.
- Career changers creating portfolio-ready infrastructure projects.
- Help Desk technicians expanding toward systems administration.
- Anyone who wants guided Azure and AD hands-on experience.

---

## Prerequisites
### Required
- Azure account (see the [Azure free tier](https://azure.microsoft.com/free/)).
- Computer with an RDP client (Windows Remote Desktop or [Microsoft Remote Desktop for macOS](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466)).
- Baseline knowledge of Windows administration, Active Directory concepts, and networking fundamentals (IP addressing, DNS, firewalls). Helpful resources:
  - [Active Directory basics](https://learn.microsoft.com/training/modules/intro-to-active-directory/)
  - [Networking fundamentals learning path](https://learn.microsoft.com/training/paths/network-fundamentals/)

### Recommended
- [Azure Fundamentals learning path](https://learn.microsoft.com/training/paths/azure-fundamentals/) for portal navigation and terminology.
- [PowerShell for Beginners](https://learn.microsoft.com/training/paths/powershell/) to understand the automation script.
- Background on virtualization concepts from the [Microsoft virtualization overview](https://learn.microsoft.com/virtualization/).

---

## Estimated Time and Cost
- Estimated duration: 2–3 hours
- Azure runtime cost: roughly $0.10–$0.20 USD per hour while VMs run
- Storage only cost: about $5–$10 USD per month when VMs are stopped
- Eligible for Azure free tier credits when resources are deallocated promptly

⚠️ **Important cost reminder**
```
Azure VMs accrue charges while running.

To keep spending low:
1. Stop and deallocate VMs after every session (Azure Portal → Virtual Machine → Stop).
2. Schedule time to delete the resource group when the lab is complete.
3. Leaving VMs on 24/7 can cost $50–$100 USD per month.
```

---

## Architecture
![Lab Architecture Placeholder](images/architecture-diagram.png)

The lab consists of:
- Windows Server 2022 domain controller with AD DS and DNS.
- Windows 10/11 client VM pointing to the domain controller for DNS.
- Azure virtual network with a lab subnet and Network Security Group rules.
- Resource group for easy cleanup.

Detailed diagrams and explanations are in docs/00-Lab-Architecture.md.

---

## Documentation Roadmap
Work through the documents in order:
1. [Lab Architecture Overview](docs/00-Lab-Architecture.md)
2. [Azure Setup](docs/01-Azure-Setup.md)
3. [Deploy Domain Controller](docs/02-Deploy-Domain-Controller.md)
4. [Deploy Client VM](docs/03-Deploy-Client-VM.md)
5. [Create Users with PowerShell](docs/04-Creating-Users-PowerShell.md)
6. [Group Policy Management](docs/05-Group-Policy-Management.md)
7. [Testing and Validation](docs/06-Testing-and-Validation.md)
8. [Cleanup and Cost Management](docs/07-Cleanup-and-Cost-Management.md)
9. [Troubleshooting Guide](docs/Troubleshooting.md)

Each section defines key terms such as Domain Controller, DNS, Organizational Unit (OU), Group Policy Object (GPO), and explains how to verify your work.

---

## Quick Start
```powershell
# Clone the repository
git clone https://github.com/arthurperch/active-directory-azure-lab.git
cd active-directory-azure-lab

# Review architecture and setup steps
code docs/01-Azure-Setup.md

# After the domain controller is configured
cd scripts
./Create-BulkUsers.ps1
```

Key helpers:
- scripts/Create-BulkUsers.ps1 populates the _EMPLOYEES Organizational Unit with sample accounts.
- scripts/Test-ADConfiguration.ps1 validates DNS records, domain membership, and Group Policy application.

---

## Screenshots
Replace these placeholders with your lab evidence:
- ![Azure Portal VM deployment](images/azure-portal-vm-creation.png) — [ADD SCREENSHOT]
- ![Active Directory Users and Computers](images/ad-users-and-computers.png) — [ADD SCREENSHOT]
- ![Group Policy Management Console](images/gpmc-policy.png) — [ADD SCREENSHOT]

---

## Troubleshooting
The full catalog of issues lives in docs/Troubleshooting.md. Quick checks:
- Confirm the client’s DNS server is the domain controller IP (example: 10.0.0.4).
- Verify the Network Security Group allows RDP (TCP 3389) from your client IP.
- Use `Test-NetConnection -ComputerName <dc-ip> -Port 3389` to diagnose connectivity.
- Run `gpresult /r` on the client to confirm Group Policy application.

Stop and deallocate VMs before stepping away to avoid surprise costs.

---

## Contributing
Improvements are welcome. Please open an issue with context, fork the repository, and submit a pull request that describes the change and includes screenshots or logs when relevant. Maintain the beginner-friendly tone and define terms on first use.

---

## License
Distributed under the MIT License. See LICENSE for full text.

---

Star the repository if the lab helped you learn something new.
