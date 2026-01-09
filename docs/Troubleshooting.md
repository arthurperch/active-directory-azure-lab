# Active Directory Azure Lab – Troubleshooting Guide

Last Updated: January 6, 2026  
Applies to: Azure Portal (2025 Q4), Windows Server 2022, Windows 10/11

---

## How to Use This Guide
Each issue includes symptoms, likely causes, a step-by-step solution, and prevention tips. Work through the list from top to bottom until the problem is resolved. Capture your findings to improve future lab runs.

⚠️ **Important cost reminder**
```
Pause and deallocate VMs after troubleshooting sessions to prevent extra charges.
```

---

## Issue: Cannot RDP to VM
**Symptoms**: RDP client reports "Unable to connect" or times out.  
**Cause**: VM stopped, NSG missing RDP rule, or wrong public IP.  
**Solution**:
1. In Azure Portal, confirm the VM status is `Running`.
2. Check the attached NSG (`dc-1-nsg` or `client-1-nsg`) inbound rules. Ensure TCP 3389 allows your public IP.
3. Verify the VM’s public IP address in the **Networking** blade.
4. From your workstation, run `Test-NetConnection -ComputerName <PublicIP> -Port 3389`.
5. Restart the VM if needed, then retry RDP.
**Prevention**: Document inbound rules and use Azure Bastion or Just-In-Time access for production-like scenarios.

---

## Issue: DNS Not Resolving Domain Names
**Symptoms**: `Resolve-DnsName` fails; domain join wizard cannot locate the domain.  
**Cause**: Client VM pointing to public DNS or wrong private IP on the domain controller.  
**Solution**:
1. On `client-1`, run `Get-DnsClientServerAddress` to confirm the DNS server is the `dc-1` private IP (for example, `10.0.0.4`).
2. If not, set custom DNS in the NIC settings and restart the VM.
3. On `dc-1`, confirm the NIC retains the expected private IP (documented in [02-Deploy-Domain-Controller](02-Deploy-Domain-Controller.md)).
4. Flush caches: `ipconfig /flushdns` on client and server.
5. Retry `Resolve-DnsName dc-1.mydomain.com`.
**Prevention**: Configure DNS immediately after VM creation and record IP assignments.

---

## Issue: Cannot Join Domain
**Symptoms**: "The domain controller could not be contacted" or access denied errors.  
**Cause**: DNS misconfiguration, firewall blocks, or incorrect credentials.  
**Solution**:
1. Confirm DNS as above.
2. Ping the `dc-1` private IP from `client-1` to confirm network reachability.
3. Ensure NSGs allow VirtualNetwork-to-VirtualNetwork traffic within `Active_D_vnet`.
4. Join using PowerShell to view detailed errors: `Add-Computer -DomainName mydomain.com -Credential MYDOMAIN\Administrator -Verbose`.
5. Verify the domain administrator password on `dc-1` before returning to the client.
**Prevention**: Create the domain controller first, test DNS, then deploy clients.

---

## Issue: PowerShell Script Errors
**Symptoms**: `New-ADUser` failures, module import errors, or execution policy blocks.  
**Cause**: Missing Active Directory module, script blocked, insufficient permissions.  
**Solution**:
1. On `dc-1`, run `Import-Module ActiveDirectory` to confirm module availability.
2. If import fails, add RSAT tools via Server Manager > Add Roles and Features > AD DS Tools.
3. Unblock script: `Unblock-File .\Create-BulkUsers.ps1`.
4. Run PowerShell as Domain Administrator.
5. Review error messages for duplicate usernames; adjust script variables if needed.
**Prevention**: Verify prerequisites before execution and keep scripts under version control.

---

## Issue: Account Lockout Policy Not Working
**Symptoms**: Users can enter many wrong passwords without lockout.  
**Cause**: GPO not applied, policy scope incorrect, or client using cached credentials.  
**Solution**:
1. On `client-1`, run `gpupdate /force` and wait for completion.
2. Execute `gpresult /r /scope computer` to confirm `Account Lockout Policy` GPO is applied.
3. Ensure the GPO is linked at the domain level or to the OU containing the computer account.
4. Verify policy settings inside the GPO editor.
5. Restart the client if the policy still does not apply.
**Prevention**: Document GPO links and security filtering. Avoid conflicting local policies.

---

## Issue: Unexpected Azure Charges After Cleanup
**Symptoms**: Azure cost analysis continues to show VM charges.  
**Cause**: VMs stopped but not deallocated, disks or public IPs still allocated, or resource group not deleted.  
**Solution**:
1. Verify each VM status is `Stopped (deallocated)`.
2. Check for remaining disks or snapshots in the `Active_Dir_Lab` resource group.
3. Delete unused public IP resources like `dc-1-ip` and `client-1-ip`.
4. In Cost Management, filter by resource to identify stragglers.
5. Delete the entire resource group if the lab is finished.
**Prevention**: Use the cleanup checklist in [07-Cleanup-and-Cost-Management](07-Cleanup-and-Cost-Management.md) every time.

---

## General Troubleshooting Tips
- Keep an admin PowerShell window open on `dc-1` for quick checks (`dcdiag`, `Get-ADUser`, `Get-DnsServerResourceRecord`).
- Document every change. A simple text file with timestamps helps trace back mistakes.
- Restarting VMs resolves many transient lab issues, especially after NIC or DNS changes.

---

## Still Stuck?
Open an issue in the GitHub repository with:
- Description of the problem
- Steps already attempted
- Screenshots or command output (remove sensitive data)
- Azure region and VM sizes used

Community feedback accelerates fixes and improves future revisions of the lab.
