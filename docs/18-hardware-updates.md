# 18 — BIOS, chipset driver and SSD firmware updates

For the **ASUS TUF GAMING B550-PLUS (WI-FI)** with a Ryzen 5 5600X and a Kingston NV1 SSD
(`SNVS1000GB`). Do them **in this order**: BIOS → chipset driver → SSD firmware.

Why: the BIOS (2423) is from August 2021. BIOSes that old have the AMD **fTPM stutter** bug: the
whole PC freezes for a second or two, then continues. AMD fixed it in BIOS updates from 2022 on.
There was also one blue screen `0x133 DPC_WATCHDOG_VIOLATION` (31 Oct 2026), which usually
points to chipset or storage drivers or firmware.

Versions before updating (6 Nov 2026):

| Part | Version |
|---|---|
| BIOS | 2423 (2021-08-10) |
| AMD Chipset Software | 7.09.23.2230 |
| SSD firmware (Kingston SNVS1000GB) | S8442101 |

Check the current versions again in PowerShell:

```powershell
Get-CimInstance Win32_BIOS | Select-Object SMBIOSBIOSVersion, ReleaseDate
Get-PhysicalDisk | Select-Object FriendlyName, FirmwareVersion
Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' |
  Where-Object DisplayName -match 'AMD Chipset' | Select-Object DisplayName, DisplayVersion
```

## 0. Prepare the USB stick (FAT32)

ASUS EZ Flash 3 reads **FAT32** only. Windows can't format more than 32 GB as FAT32, so on a
large stick create one **31 GB FAT32 partition**. This **erases the whole stick**.

In **Terminal (Admin)** (Win + X), first find the stick's disk number:

```powershell
Get-Disk | Where-Object BusType -eq 'USB' | Format-Table Number, FriendlyName, Size
```

Double-check the number is the USB stick (the right size and name, **not** `KINGSTON`). Then,
using that number (here `1`):

```powershell
Clear-Disk -Number 1 -RemoveData -RemoveOEM -Confirm:$false
Initialize-Disk -Number 1 -PartitionStyle MBR
New-Partition -DiskNumber 1 -Size 31GB -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel BIOS
```

Afterwards, to use the whole stick again as exFAT, use Disk Management: delete the partition,
then create a new volume.

## 1. BIOS (ASUS EZ Flash 3)

Target: **BIOS 3636** (downloaded 6 Nov 2026; no intermediate version required). BitLocker /
device encryption is **off** on this PC (no recovery key in the Microsoft account), so no key
prompt is expected.

1. Download the **latest BIOS** from the
   [support page](https://www.asus.com/motherboards-components/motherboards/tuf-gaming/tuf-gaming-b550-plus-wi-fi/helpdesk_bios/).
   Read the version notes: if a version says it must be installed first ("must update to
   version X before…"), flash that one first, then the latest.
2. Unzip it and copy the `.CAP` file to the root of the FAT32 stick. **BIOSRenamer** is only
   needed for FlashBack (below). EZ Flash takes the original file name.
3. Plug the stick into the rear USB port inside the box labeled **BIOS** (black USB 2.0, next to
   the **BIOS FLBK** button). Avoid the blue USB 3 and Type-C ports for this.
4. Restart and press **Del** repeatedly to enter the BIOS. Press **F7** for Advanced Mode, then go
   to **Tool → ASUS EZ Flash 3 Utility** → *via Storage Device(s)*, pick the stick and the `.CAP`
   file, and confirm **Yes**.
5. **Never cut the power while it flashes** (no power button, no power strip). It takes about 5
   minutes and restarts by itself, possibly more than once. A black screen for a while is normal.
6. If a message about the **fTPM** appears ("fTPM NV corrupted or fTPM NV structure changed"),
   press **N** to keep the existing fTPM data. **Y** resets it, which breaks Windows Hello PIN/face.

### Settings to check after the flash

The update resets the BIOS to defaults. Press **Del**, then **F7**, and check:

| Tab | Setting | Value | |
|---|---|---|---|
| Main | BIOS Version | 3636 | check |
| Main | System Date / Time | correct | check |
| Ai Tweaker | Ai Overclock Tuner | **D.O.C.P.** (or EXPO/D.O.C.P.): RAM at its rated speed, not 2133/2400 | **must** |
| Advanced | CPU Configuration → **SVM Mode** | **Enabled**: WSL and Docker need it | **must** |
| Advanced | AMD fTPM configuration → TPM Device Selection | **Firmware TPM**: Windows 11 needs it | **must** |
| Advanced | PCI Subsystem Settings → Above 4G Decoding / Re-Size BAR | Enabled / Auto: a few % FPS on the RTX 3060 Ti (needs CSM off) | nice to have |
| Boot | CSM (Compatibility Support Module) | **Disabled** (pure UEFI) | **must** |
| Boot | Secure Boot → OS Type | **Windows UEFI mode**: Windows 11, Vanguard, FACEIT AC | **must** |
| Boot | Boot Option #1 | **Windows Boot Manager** (KINGSTON SNVS1000GB) | **must** |
| Boot | Fast Boot | leave the default | — |
| Monitor | Q-Fan Configuration | redo custom fan curves if you had them | check |
| Monitor | CPU temperature | about 30–50 °C idle | check |

**F10** → check the change list → **OK**. If Windows doesn't boot after you changed CSM or Secure
Boot, set **CSM → Enabled** again.

### Check in Windows

```powershell
Get-CimInstance Win32_BIOS | Select-Object SMBIOSBIOSVersion, ReleaseDate   # 3636
Get-CimInstance Win32_PhysicalMemory | Select-Object ConfiguredClockSpeed   # D.O.C.P. speed
Confirm-SecureBootUEFI                                                       # True (admin)
Get-Tpm | Select-Object TpmPresent, TpmReady                                 # True True (admin)
wsl -l -v                                                                    # distros start (SVM on)
```

### Backup: BIOS FlashBack (if EZ Flash doesn't see the stick or refuses the file)

1. Run `BIOSRenamer.exe` from the download folder; it renames the `.CAP` to the name FlashBack
   expects. Copy the renamed file to the stick, into the **BIOS** port.
2. Shut down Windows normally, but leave the PSU switched on and plugged in.
3. Hold the **BIOS FLBK** button about 3 s until its light blinks. Wait until the light goes out
   (3–8 minutes), then power on. A light that stays solid means the file or stick wasn't accepted.
## 2. AMD chipset driver

1. <https://www.amd.com/en/support/download/drivers.html> → **Chipsets → AMD Socket AM4 → B550** → Submit.
2. Under Windows 11, download **AMD Chipset Software**. Install it only if it's newer than the
   version in the table above.
3. Run the installer, keep the default selection, click **Install**, and restart when it asks.

## 3. Kingston SSD firmware

1. Install **Kingston SSD Manager**: <https://www.kingston.com/support/technical/ssdmanager>.
2. Open it, select the `SNVS1000GB` drive and look at **Firmware**. If an update is offered, click
   **Update Firmware** and restart afterwards. If it says the firmware is current, there's nothing to do.
3. The update keeps your data, but don't cut the power during it.

## After all three

- Shut down normally, never by holding the power button. Forced power-offs caused the 27
  "unexpected shutdown" entries. A `Repair-Volume -DriveLetter C -Scan` on 6 Nov 2026 found no errors.
- If the short freezes come back, check the event log for new crashes:
  `Get-WinEvent -FilterHashtable @{LogName='System'; Id=41,1001} -MaxEvents 5`.

Back to the [README](../README.md).
