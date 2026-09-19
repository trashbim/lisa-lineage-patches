# LineageOS 23.2 (Android 16) Tweaks & Patches for Xiaomi 11 Lite 5G NE (lisa)

Custom optimizations, hardware tweaks, and EW (electronic warfare) anti-spoofing protection for LineageOS 23.2 on Xiaomi 11 Lite 5G NE (`lisa`).

---

## Patch Summary

### 1. GPS & Anti-Spoofing / EW Protection
* **`packages_apps_Settings`**:
  * Added user-facing toggle in **Settings -> Location** (*"GPS anti-spoofing protection (EW)"*) controlling `persist.sys.gps.anti_spoof`.
  * Translated into Russian, Ukrainian, and English.
* **`device_xiaomi_sm8350-common`**:
  * **Qualcomm Robust Location Hardware Baseband Check**: Always drops location fixes flagged by Qualcomm DSP (`LOCATION_POSTION_SPOOFED`, `LOCATION_TIME_SPOOFED`, `LOCATION_NAVIGATION_DATA_SPOOFED`).
  * **Time Discrepancy Filter**: Detects and drops simulated replay attacks (e.g. 2010 drone flight replay broadcasting 16-year-old timestamps).
  * **Geographical Filter**: Blocks known Lima, Peru spoofing coordinates broadcast by EW.
  * **Flight Profile Filter**: Drops impossible pedestrian/car movements with simulated aircraft speeds (>180 km/h) at high altitudes (>800 m).
  * **A-GPS & NTP Configuration**: Configured European NTP pools and Google SUPL for instant TTFF fix.

### 2. Kernel Tweaks (`kernel_xiaomi_sm8350`)
* **Display Backlight Thermal Throttling**: Removed panel dimming under thermal load in `sde_connector`.
* **240Hz Game Touch**: Enabled 240Hz touch sampling rate by default for ultra-responsive input.
* **Touch Stalls**: Removed Goodix panel detection stall during boot.
* **TCP BBR**: Enabled Google BBR congestion control algorithm as default for faster network throughput.
* **ZRAM**: Switched default compression algorithm to `zstd` for better performance and compression ratio.
* **Kernel Debugging**: Disabled `PAGE_OWNER` debugging overhead.

### 3. System & UI Tweaks
* **`frameworks_base`**:
  * Bypass `FLAG_SECURE` to allow taking screenshots and screen recording in any app (banking apps, secure chat).
* **`device_xiaomi_lisa`**:
  * Adjusted display cutout and status bar height to 100px to perfectly match the front camera hole.
  * Set default display refresh rate to 90Hz.
  * Enabled keyboard haptic feedback / vibration settings overlay.
* **`device_xiaomi_sm8350-common`**:
  * Set 18 media volume steps for finer volume adjustment.
  * Disabled SurfaceFlinger background blur for maximum fluidity and lower GPU power draw.
  * Supported 3 haptic vibration intensity levels.

---

## Usage

### 1. Apply Patches
Run after `repo sync`:
```bash
./apply-patches.sh [path_to_lineage_root]
# Default path: /mnt/ssd/lineage
./apply-patches.sh
```

### 2. Export / Update Patches
If you make new commits on branch `my-tweaks`:
```bash
./apply-patches.sh --export
git commit -am "Update patches"
git push
```
