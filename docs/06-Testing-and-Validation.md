# Active Directory Azure Lab – Testing and Validation

Last Updated: January 6, 2026  
Applies to: Windows Server 2022, Windows 10/11, PowerShell 7.4

---

## Purpose
Validate that every major lab component works as intended. Document results for your resume, portfolio, or interview discussions.

---

## Quick Checklist
| Test | Pass/Fail | Notes |
| --- | --- | --- |
| Domain controller responds to ping (`10.0.0.4`) | [ ] | |
| DNS resolves `dc01.mydomain.com` from client | [ ] | |
| Client can log on with domain user | [ ] | |
| PowerShell script created expected number of users | [ ] | |
| Account lockout triggers after 3 failures | [ ] | |
| Group Policy appears in `gpresult` | [ ] | |
| Cost control reminder acknowledged | [ ] | |

Print or copy this table into your lab journal and fill it out as you test.

---

## Test 1 – Connectivity and DNS
On `client01`, run:
```powershell
Test-NetConnection -ComputerName 10.0.0.4 -Port 3389
Resolve-DnsName dc01.mydomain.com
Resolve-DnsName _ldap._tcp.dc._msdcs.mydomain.com
```
Expected results:
- RDP port test succeeds.
- Both DNS queries return IP `10.0.0.4`.

If DNS fails, ensure the client’s DNS server is set to the domain controller.

---

## Test 2 – Domain Logon
1. Sign out of `client01`.
2. Log on with a scripted user (example: `MYDOMAIN\alex.morgan`).
3. Confirm desktop loads without credential prompts.

> If sign-in fails, check the `_EMPLOYEES` OU for lockouts or password issues.

---

## Test 3 – Group Policy Application
On `client01`, run:
```powershell
gpresult /h C:\Temp\gpresult.html
Start-Process C:\Temp\gpresult.html
```
Review the HTML report. Under **Computer Details**, verify that the `Account Lockout Policy` GPO is listed.

---

## Test 4 – Account Lockout Behavior
1. From the lock screen, attempt incorrect passwords three times for a test user.
2. Confirm Windows reports the account is locked.
3. On `dc01`, check **Active Directory Users and Computers** > user properties > **Account** tab for lockout status.
4. Unlock the account manually or wait 30 minutes for automatic unlock.

---

## Test 5 – PowerShell Script Output
On `dc01`, validate the expected number of accounts:
```powershell
Get-ADUser -Filter * -SearchBase "OU=_EMPLOYEES,DC=mydomain,DC=com" |
    Measure-Object | Select-Object -ExpandProperty Count
```
Document the count returned. It should match `$NUMBER_OF_ACCOUNTS_TO_CREATE`.

---

## Test 6 – Optional Validation Script
The repository includes `scripts/Test-ADConfiguration.ps1`. Run it from `dc01` to perform automated checks.
```powershell
cd C:\Path\To\active-directory-azure-lab\scripts
./Test-ADConfiguration.ps1
```
Review the output for any failed tests and resolve before continuing.

---

## Documenting Results
Maintain a short validation log including:
- Date/time of tests
- Account names used
- Screenshot references (store under `images/`)
- Issues encountered and resolutions

This log becomes a powerful artifact for job interviews.

---

## Troubleshooting
| Test | Common Failure | Suggested Fix |
| --- | --- | --- |
| DNS resolution | Client still pointing to public DNS | Update NIC DNS settings to `10.0.0.4` and run `ipconfig /flushdns`. |
| Domain logon | Account disabled or locked | Unlock the user in ADUC; confirm password. |
| GPO application | `Account Lockout Policy` missing | Run `gpupdate /force`, verify GPO link at domain level, and ensure client is in scope. |
| Validation script | Access denied errors | Run PowerShell as Domain Administrator. |

---

## Cost Control Reminder
⚠️ **Stop and deallocate both VMs after validation.**  Forgetting this step can consume the remainder of your free credits quickly.

---

## Next Steps
Move to [07-Cleanup-and-Cost-Management](07-Cleanup-and-Cost-Management.md) to learn how to pause or retire the lab responsibly.
