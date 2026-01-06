# Active Directory Azure Lab – Cleanup and Cost Management

Last Updated: January 6, 2026  
Applies to: Azure Portal (2025 Q4 UI)

---

## Why Cleanup Matters
Leaving lab resources running can quickly consume free credits and lead to unexpected bills. Proper cleanup also keeps your subscription organized and ready for future projects.

---

## Quick Reference Table
| Action | When to Use | Estimated Savings |
| --- | --- | --- |
| Stop (deallocate) VMs | Between lab sessions | Saves compute charges ($0.10–$0.20/hour) |
| Delete VM snapshots | After confirming lab success | Avoids storage fees |
| Delete resource group | After exporting evidence | Eliminates all remaining charges |

⚠️ **Important cost reminder**
```
Always stop AND deallocate VMs when pausing the lab.
Shutting down inside Windows is not enough.
```

---

## Step 1 – Stop and Deallocate Virtual Machines
1. Go to **Virtual Machines** in the Azure Portal.
2. Select `dc01` and click **Stop**. Confirm the status changes to `Stopped (deallocated)`.
3. Repeat for `client01`.
4. Verify no VMs remain in the `Running` state.

> Deallocated VMs release compute resources so you only pay for the storage backing the disks.

---

## Step 2 – Disable Public IP (Optional)
If you plan to keep disks but do not need remote access immediately:
1. Open each VM’s **Networking** blade.
2. Select the Public IP resource.
3. Change **Assignment** to `Static` if you need a consistent IP, or delete the Public IP resource to stop public exposure (you can re-create it later).

Deleting the public IP removes inbound RDP access. Only do this if you are comfortable redeploying the IP when needed.

---

## Step 3 – Export Configurations (Optional)
Before full cleanup, export these items for documentation:
- Screenshots stored in `images/` demonstrating key steps.
- List of users (`Get-ADUser` output saved to CSV).
- Group Policy reports (`gpresult` HTML file).
- Terraform or ARM template exports if you used Infrastructure as Code.

Store exports locally or in another repository for reference.

---

## Step 4 – Delete the Resource Group
When you are ready to retire the lab:
1. Navigate to the resource group (`rg-ad-lab`).
2. Select **Delete resource group**.
3. Type the resource group name to confirm.
4. Wait for deletion to complete (can take a few minutes).

Deleting the resource group removes all VMs, disks, network components, and public IPs associated with the lab.

---

## Step 5 – Verify Charges Cleared
- Open **Cost Management + Billing** > **Cost analysis**.
- Filter by the last 7 days to confirm daily charges drop to zero after cleanup.
- If charges persist, check for leftover resources (storage accounts, key vaults, etc.).

---

## Step 6 – Optional Automation
For recurring labs, consider scripting cleanup:
```powershell
# Example PowerShell snippet to stop VMs
yourVmNames = @("dc01", "client01")
foreach ($vm in yourVmNames) {
    Stop-AzVM -Name $vm -ResourceGroupName "rg-ad-lab" -Force
}
```
For full deletion:
```powershell
Remove-AzResourceGroup -Name "rg-ad-lab" -Force
```
Ensure you install the Az PowerShell module and authenticate with `Connect-AzAccount` before running these commands.

---

## Cost Monitoring Tips
- Set up a budget in Azure Cost Management with alerts when spending exceeds $5 or $10.
- Review the **Cost by resource** view to spot any orphaned disks or IP addresses.
- Keep track of lab hours in your project log.

---

## Troubleshooting
| Problem | Cause | Resolution |
| --- | --- | --- |
| VM refuses to deallocate | Active sessions or extensions still running | Use `Stop-AzVM -Force` or check Azure activity logs for errors. |
| Resource group deletion stuck | Dependent resources locked | Verify no locks are applied; remove policy assignments before retrying. |
| Charges continue after deletion | Azure reservation or different subscription | Check billing scope and ensure you selected the correct subscription. |

---

## Next Steps
Return to the [Troubleshooting Guide](Troubleshooting.md) if you hit issues during cleanup, or rebuild the lab to practice again with new scenarios.
