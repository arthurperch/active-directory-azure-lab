# Active Directory Azure Lab

Build a polished, portfolio-ready Active Directory environment in Azure without guessing the order of steps.

![Hero placeholder for the lab dashboard](images/hero/lab-hero.png)

Last Updated: January 6, 2026  
Platform baseline: Azure Portal (2025 Q4), Windows Server 2022 Datacenter, Windows 11 Enterprise, PowerShell 7.4

---

## Documentation Roadmap
| Phase | Guide | What You Complete |
| --- | --- | --- |
| 01 | [Lab Architecture Overview](docs/00-Lab-Architecture.md) | Understand the network, DNS, and VM layout before deploying. |
| 02 | [Azure Setup](docs/01-Azure-Setup.md) | Create the resource group, VNet, subnet, and NSG with cost guardrails. |
| 03 | [Deploy Domain Controller](docs/02-Deploy-Domain-Controller.md) | Provision `dc01`, assign a static IP, and promote it to a new forest. |
| 04 | [Deploy Client VM](docs/03-Deploy-Client-VM.md) | Build `client01`, point DNS to the DC, and join it to the domain. |
| 05 | [Create Users with PowerShell](docs/04-Creating-Users-PowerShell.md) | Script bulk user creation inside the `_EMPLOYEES` OU. |
| 06 | [Group Policy Management](docs/05-Group-Policy-Management.md) | Enforce and test an account lockout policy. |
| 07 | [Testing and Validation](docs/06-Testing-and-Validation.md) | Run the verification checklist and capture evidence. |
| 08 | [Cleanup and Cost Management](docs/07-Cleanup-and-Cost-Management.md) | Stop, deallocate, or delete resources safely. |
| Support | [Troubleshooting Guide](docs/Troubleshooting.md) | Resolve DNS, domain join, RDP, and script issues quickly. |
| Assets | [Screenshot Workflow](docs/Screenshot-Workflow.md) | Capture, resize, and place screenshots so README visuals update instantly. |

---

## Get Started Fast
```powershell
git clone https://github.com/arthurperch/active-directory-azure-lab.git
cd active-directory-azure-lab
code docs/01-Azure-Setup.md

# After promoting the domain controller
cd scripts
./Create-BulkUsers.ps1
```

- scripts/Create-BulkUsers.ps1 populates the `_EMPLOYEES` OU with realistic sample accounts.
- scripts/Test-ADConfiguration.ps1 validates DNS, AD DS, and GPO health before you present lab results.

---

## Skills You Will Practice
- Azure VNet design, NSG hardening, and VM provisioning.
- Active Directory Domain Services installation and forest configuration.
- Windows client domain join, DNS validation, and remote management.
- PowerShell automation for bulk identity creation.
- Group Policy enforcement and account lockout testing.
- Troubleshooting methodology across DNS, authentication, and policy layers.

---

## Prerequisites
**Required**
- Azure subscription (use the [Azure free tier](https://azure.microsoft.com/free/) credits).
- Workstation with an RDP client (Windows built-in or [Microsoft Remote Desktop for macOS](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466)).
- Working knowledge of Windows administration, Active Directory fundamentals, and IP networking basics.

**Recommended**
- [Azure Fundamentals learning path](https://learn.microsoft.com/training/paths/azure-fundamentals/) for portal fluency.
- [PowerShell for Beginners](https://learn.microsoft.com/training/paths/powershell/) to tweak automation scripts.
- Overview of virtualization concepts from the [Microsoft virtualization documentation](https://learn.microsoft.com/virtualization/).

---

## Architecture Snapshot
Review the network flow and component roles in [docs/00-Lab-Architecture.md](docs/00-Lab-Architecture.md). The key building blocks:
- `dc01` (Windows Server 2022) hosts AD DS and DNS with static IP 10.0.0.4.
- `client01` (Windows 10/11) joins the domain and resolves DNS through `dc01`.
- `vnet-ad-lab` with subnet `10.0.0.0/24` and NSG rules that allow secure RDP and intra-subnet communication.

Add your architecture diagram to `images/steps/architecture-topology.png` (recommended 1600×900 PNG) so the README hero links to a real design.

---

## Image Asset Checklist
Place high-quality screenshots in the following paths (PNG preferred for clarity):

| Location | Expected Content | Dimensions |
| --- | --- | --- |
| `images/hero/lab-hero.png` | Hero banner that showcases the finished environment dashboard. | 1920×1080 PNG |
| `images/steps/architecture-topology.png` | Network/architecture overview exported from Visio, draw.io, or similar. | 1600×900 PNG |
| `images/steps/azure-portal-resource-group.png` | Azure Portal view of the resource group and cost alerts. | 1600×900 PNG |
| `images/steps/domain-controller-dashboard.png` | Server Manager or AD DS status on `dc01`. | 1600×900 PNG |
| `images/steps/ad-users-and-computers.png` | User list showing bulk accounts in `_EMPLOYEES`. | 1600×900 PNG |
| `images/steps/gpo-account-lockout.png` | Group Policy Management Console with the lockout policy. | 1600×900 PNG |

Follow the step-by-step capture instructions in [docs/Screenshot-Workflow.md](docs/Screenshot-Workflow.md), then run `scripts/Validate-ImageAssets.ps1` to confirm nothing is missing before pushing.

Replace the placeholders and keep file names identical so links remain valid. JPEG at 85% quality also works if PNG sizes are excessive.

---

## Cost Safety Net
Azure VMs accrue charges while running.

```
Stop and deallocate both VMs after each session:
1. Azure Portal → Virtual Machines → Select dc01/client01 → Stop (deallocate).
2. Delete the lab resource group when you finish documenting results.
Expected monthly cost if left running 24/7: ~$80. Deallocated: ~$5–$10 for storage.
```

---

## Troubleshooting & Support
Start with [docs/Troubleshooting.md](docs/Troubleshooting.md) for step-by-step fixes covering DNS, domain join, RDP, PowerShell script errors, and GPO verification. The guide explains symptoms, root causes, and prevention tips for each scenario.

---

## Contributing
Improvements are welcome. Open an issue describing the change, fork the repository, and submit a pull request that includes screenshots or logs when relevant. Keep the writing beginner-friendly and define acronyms on first mention.

---

## License
Distributed under the MIT License. See LICENSE for the full text.

---

Star the repository if the lab helped you level up your Azure and AD skills.
