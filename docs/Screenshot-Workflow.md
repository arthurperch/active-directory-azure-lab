# Screenshot Workflow and Placement Guide

Last Updated: January 6, 2026

This guide explains how to capture each screenshot, format it correctly, and place it in the repository so the README displays the images automatically.

---

## Required Assets
| File Name | Resolution | Description | Where it Appears |
| --- | --- | --- | --- |
| `images/hero/lab-hero.png` | 1920×1080 PNG | Portfolio-style hero banner showing the completed lab dashboard or architecture overview. | README hero section |
| `images/steps/architecture-topology.png` | 1600×900 PNG | Diagram illustrating VNet, subnet, domain controller, and client relationships. | Architecture Snapshot |
| `images/steps/azure-portal-resource-group.png` | 1600×900 PNG | Azure Portal Resource Group blade with cost alerts highlighted. | Image Asset Checklist / portfolio evidence |
| `images/steps/domain-controller-dashboard.png` | 1600×900 PNG | Server Manager or Active Directory Administrative Center view on `dc01`. | Image Asset Checklist |
| `images/steps/ad-users-and-computers.png` | 1600×900 PNG | Active Directory Users and Computers showing `_EMPLOYEES` with bulk accounts. | Image Asset Checklist |
| `images/steps/gpo-account-lockout.png` | 1600×900 PNG | Group Policy Management Console displaying the Account Lockout Policy settings. | Image Asset Checklist |

PNG format keeps text crisp. JPEG (quality ≥85) works if PNG files exceed GitHub limits.

---

## Capture Checklist
1. **Prepare the scene**
   - Open the target window (Azure Portal, Server Manager, etc.).
   - Maximize the window to 1920×1080 or 1600×900. Use browser zoom (90–110%) if needed to fit content.
2. **Capture the screenshot**
   - Windows: `Win + Shift + S` (Snipping Tool) → Rectangular Snip.
   - macOS: `Shift + Command + 4` and drag the capture area.
   - Save the file temporarily on your desktop.
3. **Resize if necessary**
   - Use built-in Photos app (Windows) → **Edit & Create** → **Resize**.
   - Set width/height to the recommended resolution while preserving aspect ratio.
4. **Rename the file exactly** as listed in the table (case-sensitive on GitHub):
   - Example: `lab-hero.png`, `architecture-topology.png`, etc.
5. **Copy the file into the repository** under the correct folder:
   - `images/hero/lab-hero.png`
   - `images/steps/...`
6. **Verify the image loads**
   - In the repository root, run `git status` to confirm the new file is tracked.
   - Open README locally (Markdown preview) to ensure the image renders and proportions look correct.

---

## Quick Commands (PowerShell Example)
```powershell
# From the repository root
Copy-Item "$env:USERPROFILE\Desktop\lab-hero.png" .\images\hero\lab-hero.png
Copy-Item "$env:USERPROFILE\Desktop\architecture-topology.png" .\images\steps\architecture-topology.png
```

Update the source paths to match where you saved each screenshot.

---

## Validation Script
Run the helper script to confirm all assets are in place:
```powershell
cd scripts
./Validate-ImageAssets.ps1
```
This script reports any missing images and shows their expected resolution.

---

## Troubleshooting Tips
- **Image not showing in README**: Confirm the filename matches exactly (no spaces, correct casing) and that you committed the image.
- **Large file size warnings**: Use PNG compression tools such as [TinyPNG](https://tinypng.com/) before committing.
- **Blurry text**: Capture at native resolution (100% scaling) and avoid resizing below the recommended dimensions.

Add new screenshots whenever you update the lab to keep the portfolio current.
