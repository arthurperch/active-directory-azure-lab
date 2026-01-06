# Active Directory Azure Lab – Creating Users with PowerShell

Last Updated: January 6, 2026  
Applies to: Windows Server 2022, PowerShell 7.4, Active Directory Module for Windows PowerShell

---

## Why Automate User Creation?
- Saves time compared to manual entry in Active Directory Users and Computers (ADUC).
- Ensures consistent naming, passwords, and placement within Organizational Units (OUs).
- Makes it easy to rerun the lab or reset the directory for new testing scenarios.

---

## What You Will Do
1. Create an `_EMPLOYEES` Organizational Unit to house lab accounts.
2. Review the provided PowerShell script `Create-BulkUsers.ps1`.
3. Customize settings such as number of accounts and default password.
4. Run the script and verify results in ADUC and PowerShell.

⚠️ **Important cost reminder**
```
All automation runs on dc01. Remember to stop and deallocate the VM after testing.
```

---

## Step 1 – Create the Organizational Unit
The script expects an `_EMPLOYEES` OU at the root of the domain. Create it manually or via PowerShell.

**Using Active Directory Users and Computers**
1. Open **Tools** > **Active Directory Users and Computers** on `dc01`.
2. Right-click the domain root (e.g., `mydomain.com`) > **New** > **Organizational Unit**.
3. Name the OU `_EMPLOYEES` and leave **Protect container from accidental deletion** enabled.

**Using PowerShell**
```powershell
New-ADOrganizationalUnit -Name "_EMPLOYEES" -Path "DC=mydomain,DC=com"
```
Replace the distinguished name with your domain structure.

> Definition: **Organizational Unit (OU)** – a logical container in Active Directory used to group users, computers, and other objects for administrative control and Group Policy targeting.

---

## Step 2 – Review the Script Header
`scripts/Create-BulkUsers.ps1` begins with metadata describing purpose and usage:
```powershell
<#
.SYNOPSIS
    Bulk Active Directory User Creation Script
.DESCRIPTION
    Creates multiple test user accounts in Active Directory with random names.
    Useful for lab environments and testing Group Policy, permissions, etc.
.NOTES
    Author: Oleg Perchatkin
    Version: 1.0
    Requires: Active Directory PowerShell Module
.EXAMPLE
    .\Create-BulkUsers.ps1
#>
```

---

## Step 3 – Understand Configuration Variables
Open the script and locate the configuration section near the top:
```powershell
$PASSWORD_FOR_USERS = "P@ssw0rd123!"      # CHANGE THIS VALUE
$NUMBER_OF_ACCOUNTS_TO_CREATE = 25         # Recommend 10-50 for labs
$TARGET_OU = "OU=_EMPLOYEES,DC=mydomain,DC=com"
```
- `$PASSWORD_FOR_USERS`: Shared password for all generated accounts. Labs often reuse one value for convenience. Always change it before production use.
- `$NUMBER_OF_ACCOUNTS_TO_CREATE`: Limits how many users the script creates. Start with 10 or 25 to keep AD manageable.
- `$TARGET_OU`: Distinguished Name (DN) path where accounts are stored. Update `DC=` components to match your domain.

---

## Step 4 – Script Logic Walkthrough
1. **generate-random-name function** – Builds realistic names by alternating consonants and vowels. Ensures user display names look human.
2. **Password handling** – Converts the shared password into a secure string (`ConvertTo-SecureString`).
3. **Loop** – Iterates `1..$NUMBER_OF_ACCOUNTS_TO_CREATE`, generating first/last names, display name, and employee ID (random 6-digit number).
4. **New-ADUser** – Creates each user with key parameters:
   - `-AccountPassword`: uses the secure string created earlier.
   - `-GivenName`, `-Surname`, `-DisplayName`: friendly naming fields.
   - `-SamAccountName`: generated username (e.g., `alex.morgan`).
   - `-UserPrincipalName`: aligns with the domain (e.g., `alex.morgan@mydomain.com`).
   - `-EmployeeID`: random unique number for tracking.
   - `-PasswordNeverExpires`: set to `$true` so passwords do not expire in the lab.
   - `-Path`: targets `_EMPLOYEES` OU.
   - `-Enabled`: activates the account immediately.
5. **Progress output** – Writes the username created and any errors encountered.

---

## Step 5 – Run the Script
1. On `dc01`, open **Windows PowerShell ISE** or **Windows Terminal** as Administrator.
2. Change directory to the scripts folder:
   ```powershell
   Set-Location "C:\Users\Administrator\Desktop\active-directory-azure-lab\scripts"
   ```
   Adjust the path if you cloned the repository elsewhere.
3. Unblock the script if downloaded from the internet:
   ```powershell
   Unblock-File .\Create-BulkUsers.ps1
   ```
4. Update variables inside the script (password, OU path, user count).
5. Run the script:
   ```powershell
   .\Create-BulkUsers.ps1
   ```
6. Watch the console for confirmation messages such as `Created user: alex.morgan`.

> Definition: **PowerShell** – Windows automation framework and scripting language. In this lab, PowerShell manages Active Directory operations through the `ActiveDirectory` module.

---

## Step 6 – Verify User Creation
- **Active Directory Users and Computers**: Navigate to `_EMPLOYEES` and confirm new accounts appear.
- **PowerShell**: Run `Get-ADUser -Filter * -SearchBase "OU=_EMPLOYEES,DC=mydomain,DC=com" | Select-Object Name, SamAccountName`.
- **Logon test**: Use `client01` to sign in with one of the generated accounts. The default password is the value you set earlier.

---

## Script Customization Ideas
- Add parameters such as `-Department` or `-City` to fill additional attributes.
- Import user data from a CSV file instead of random generation.
- Modify the naming convention to align with real-world standards (first initial + last name, etc.).

---

## Safety Notes
- The script uses the same password for every account to simplify the lab. Highlight in interviews that production environments require unique, strong passwords.
- Re-running the script may trigger duplicate username errors. Either delete existing users first or modify the script to append numbers (e.g., `alex.morgan2`).
- Keep the `_EMPLOYEES` OU protected against accidental deletion to avoid losing sample users.

---

## Troubleshooting
| Issue | Cause | Fix |
| --- | --- | --- |
| `New-ADUser` access denied | Running script without Domain Admin rights | Sign in as the domain administrator on `dc01`. |
| `ActiveDirectory` module not found | PowerShell session missing RSAT components | Open **Server Manager** > **Add Roles and Features** > enable **AD DS Tools**. |
| Duplicate username errors | Random name generator produced same combination | Adjust script to skip duplicates or rerun after removing conflicting accounts. |

---

## Next Steps
Proceed to [05-Group-Policy-Management](05-Group-Policy-Management.md) to create and enforce security policies against the newly created users.
