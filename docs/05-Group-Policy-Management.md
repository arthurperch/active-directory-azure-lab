# Active Directory Azure Lab – Group Policy Management

Last Updated: January 6, 2026  
Applies to: Windows Server 2022, Group Policy Management Console (GPMC)

---

## Objective
Create and test an Account Lockout Policy using Group Policy Objects (GPOs). You will learn how to link policies, force updates, and troubleshoot common issues.

---

## Key Terms
- **Group Policy Object (GPO)**: A collection of settings that control user and computer behavior in Active Directory.
- **Account Lockout**: Security feature that prevents brute-force attacks by locking an account after repeated failed sign-in attempts.
- **gpresult**: Command-line tool that reports which GPOs applied to a user or computer.

---

## Prerequisites
- Domain controller configured ([02-Deploy-Domain-Controller](02-Deploy-Domain-Controller.md)).
- Bulk users created in `_EMPLOYEES` ([04-Creating-Users-PowerShell](04-Creating-Users-PowerShell.md)).
- Client machine joined to the domain.

⚠️ **Important cost reminder**
```
Group Policy configuration requires both VMs running.
Deallocate them when you finish testing.
```

---

## Step 1 – Open Group Policy Management Console
1. Sign in to `dc01` with domain admin credentials.
2. Launch **Group Policy Management** from **Server Manager** > **Tools**.
3. Expand `Forest: mydomain.com` > `Domains` > `mydomain.com`.

---

## Step 2 – Create a New GPO
1. Right-click the domain (`mydomain.com`) and select **Create a GPO in this domain, and Link it here**.
2. Name the GPO `Account Lockout Policy`.
3. Right-click the new GPO and choose **Edit**.

---

## Step 3 – Configure Account Lockout Settings
Navigate to **Computer Configuration** > **Policies** > **Windows Settings** > **Security Settings** > **Account Policies** > **Account Lockout Policy**.

Set the following values:
- **Account lockout threshold**: `3` invalid logon attempts.
- Confirm the prompts to set accompanying values.
- **Account lockout duration**: `30` minutes.
- **Reset account lockout counter after**: `30` minutes.

> Why 3 attempts? In production you might set higher thresholds, but a low number makes testing easy in the lab.

---

## Step 4 – Update Group Policy on Client
1. On `client01`, sign in with a domain account that has local admin rights (e.g., `MYDOMAIN\Administrator`).
2. Open an elevated Command Prompt or PowerShell window.
3. Run `gpupdate /force`.
4. Wait for both Computer and User policy updates to complete.

---

## Step 5 – Confirm Policy Application
Run `gpresult` to verify the GPO applied:
```powershell
gpresult /r /scope computer | Select-String "Account Lockout Policy"
```
You should see the GPO name under **Applied Group Policy Objects**.

If the GPO does not appear, restart the client or check replication (even though this lab uses a single DC, restarts help apply policies).

---

## Step 6 – Test Account Lockout
1. On `client01`, sign out or lock the workstation.
2. Attempt to sign in with a test user (for example, `MYDOMAIN\alex.morgan`) using the wrong password three times.
3. On the fourth attempt, Windows should report that the account is locked.
4. On `dc01`, open **Active Directory Users and Computers** and locate the user.
5. Right-click the account > **Properties** > **Account** tab > check **Unlock account** to regain access manually.

> Note: Lockout duration automatically expires after 30 minutes. Manual unlock is useful during testing.

---

## Step 7 – Document Results
Record:
- Which OU or scope applied the policy.
- Threshold and duration values.
- Test user accounts used.
- How you unlocked accounts (automatic vs manual).

This information is valuable when writing portfolio summaries or explaining your lab in interviews.

---

## Additional GPO Ideas for the Lab
- **Password Policy**: Require complex passwords and set minimum lengths.
- **Desktop Wallpaper**: Deploy a corporate-themed wallpaper to user desktops for visual proof.
- **Software Installation**: Push simple MSI packages (e.g., 7-Zip) to domain-joined machines.
- **Logon Banner**: Display acceptable use warnings before sign-in.

Ensure you explain the purpose of each policy when documenting your lab.

---

## Troubleshooting
| Issue | Symptoms | Fix |
| --- | --- | --- |
| GPO not applying | `gpresult` shows GPO under "Denied" | Check security filtering and WMI filters; ensure `Authenticated Users` has read/apply permissions. |
| Account does not lock | Multiple failed attempts but no lockout | Confirm `Account lockout threshold` is set and `gpupdate /force` ran successfully. |
| Users locked out unexpectedly | Users mistype password too often | Increase threshold or reduce duration after testing to avoid frustration. |

---

## Cost Control Reminder
When testing finishes:
1. Sign out of both VMs.
2. Azure Portal → Virtual Machines → select `dc01` and `client01` → **Stop** (deallocate).

Stopping inside Windows does **not** release Azure compute charges.

---

## Next Steps
Continue to [06-Testing-and-Validation](06-Testing-and-Validation.md) to run a structured checklist across the environment.
