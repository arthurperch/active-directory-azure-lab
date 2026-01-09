# Active Directory Azure Lab – Azure Setup

Last Updated: January 6, 2026  
Applies to: Azure Portal (2025 Q4 UI)

---

## What You Will Accomplish
- Create or confirm access to an Azure subscription (free tier eligible).
- Build a clean resource group to contain every lab asset.
- Deploy a virtual network, subnet, and Network Security Group (NSG).
- Configure cost controls so the lab stays affordable.

> This guide assumes you have basic knowledge of Azure navigation. New to the portal? Spend five minutes with the [Azure Portal navigation tour](https://learn.microsoft.com/azure/azure-portal/azure-portal-overview).

---

## Prerequisites Checklist
- [ ] You have an Azure subscription with contributor rights. If not, sign up for the [Azure free account](https://azure.microsoft.com/free/).
- [ ] Your workstation can reach `portal.azure.com` without corporate restrictions.
- [ ] You know your public IP address (for NSG rules). Run `curl ifconfig.me` or visit a site like https://ifconfig.me.

---

## Step 1 – Sign In and Select Subscription
1. Browse to [https://portal.azure.com](https://portal.azure.com) and sign in.
2. Confirm the correct directory and subscription in the top-right corner. If you received free credits, they appear under the `Free Trial` subscription.
3. Optional: Pin the Azure Cost Management tile to your dashboard for quick access.

---

## Step 2 – Create the Resource Group
1. Search for **Resource groups** in the global search bar.
2. Select **Create**.
3. Configure:
   - Subscription: your active subscription.
   - Resource group name: `Active_Dir_Lab`.
   - Region: choose the Azure region closest to you to minimize latency.
4. Click **Review + create**, then **Create**.

> Why a resource group? It is the logical container for everything in the lab. When finished, deleting the group removes all contained resources in one step.

![Azure resource group view](../screenshots/azure-portal-resource-group.png)

---

## Step 3 – Create the Virtual Network and Subnet
1. Navigate to the new resource group and select **Create** > **Virtual network**.
2. Enter:
   - Name: `Active_D_vnet`.
   - Region: same as the resource group.
3. Under **IP Addresses**:
   - IPv4 address space: `10.0.0.0/24` (keeps the lab simple and matches the deployed environment).
   - Subnet name: `default`.
   - Subnet address range: `10.0.0.0/24`.
4. Leave IPv6 disabled for simplicity.
5. Review and create the VNet.

### Why These Ranges?
`10.0.0.0/24` aligns with the live lab. The address space supports up to 251 usable IP addresses, which is more than enough for `dc-1`, `client-1`, and any optional test hosts while maintaining tight control of DNS records.

---

## Step 4 – Create the Network Security Group (NSG)
1. In the resource group, select **Create** > **Network security group**.
2. Configure:
   - Name: `dc-1-nsg`.
   - Region: same region as the VNet.
3. After creation, open the NSG and add inbound rules:
   - **Allow RDP**: Priority 100; Source `IP Addresses`; Source IP your public IP; Protocol `TCP`; Port `3389`; Action `Allow`.
   - **Allow Intra-VNet Traffic**: Priority 200; Source `VirtualNetwork`; Destination `VirtualNetwork`; Protocol `Any`; Action `Allow`.
4. Associate the NSG with the `default` subnet using the **Subnets** blade. When you deploy `client-1`, create a second NSG named `client-1-nsg` and reuse the same rule set to mirror the production environment captured in the screenshots.

> Definition: **Network Security Group** – Azure's built-in firewall at the subnet or NIC level. It permits or denies traffic based on IP, port, and protocol. NSGs are stateful, so return traffic is automatically allowed.

---

## Step 5 – Tag Resources (Optional but Helpful)
Apply consistent tags to your resource group and VNet:
- Key: `Environment`, Value: `Lab`
- Key: `Owner`, Value: Your name or alias
- Key: `Expires`, Value: Date to delete (for example, `2026-02-01`)

These tags feed into cost management reports and remind you to clean up.

---

## Step 6 – Enable Budget Alerts
1. Go to **Cost Management + Billing** > **Budgets**.
2. Create a budget (for example, `$15` monthly) and enable email alerts at 80% of the limit.
3. Budgets do not stop usage, but they warn you if charges spike unexpectedly.

---

## Step 7 – Document Your Settings
Record the following in a secure note for later steps:
- Subscription ID and name
- Resource group name
- VNet name and address space
- Subnet name and address range
- NSG name
- Your public IP used in the inbound rule (update if your IP changes)

---

## Cost Awareness
⚠️ **Important cost reminder**
```
Nothing in this document spins up virtual machines, so no compute costs yet.
VMs will generate charges as soon as they run.
Keep notes on what you create so you can delete it later. The live lab reported $15.33 in spend after the full build, so staying disciplined with shutdowns makes a big difference.
```

---

## Troubleshooting Tips
| Problem | Likely Cause | Fix |
| --- | --- | --- |
| Cannot create resource group | Missing permissions | Ask subscription owner for Contributor rights. |
| NSG rule does not appear | NSG created in different region | Recreate NSG in the same region as the VNet. |
| Inbound RDP blocked | Incorrect public IP in NSG rule | Update rule with current public IP or use Azure Bastion. |

---

## Next Steps
Proceed to [02-Deploy-Domain-Controller](02-Deploy-Domain-Controller.md) to provision the Windows Server VM and promote it to a domain controller.
