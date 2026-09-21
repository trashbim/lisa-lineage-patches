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
* **GPU Overclock & Undervolt (Adreno 642L / Yupik)**: Tuned `speed-bin 117` frequency table with 180-563 MHz profile (563 MHz boost overclock, undervolted mid-frequencies, and 180 MHz low-power idle step with optimized DDR memory bus bandwidth).
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
  * **Deep Sleep & Idle Timers**: Increased `vm.stat_interval` to 10s, reducing idle CPU timer wakeups by 90% during screen-off.
  * **VFS Inode/Dentry Cache**: Tuned `vm.vfs_cache_pressure` to 60 to retain file structure and directory trees in RAM longer for instantaneous app and gallery launches.
  * **Outdoor Wi-Fi Power Saving**: Increased disconnected PNO scan intervals (moving: 60s, stationary: 120s) and screen-on intervals (30/60/120/240s) in `WifiOverlaySM8350` to prevent rapid battery drain when away from saved networks.
  * **UFS Storage Optimization**: Set multi-queue I/O scheduler to `none` (direct hardware queue bypass) and tuned `read_ahead_kb` to 128 KB for optimal random 4K read performance without read amplification.
  * **Smooth UI & Jitter Reduction**: Tuned `schedutil` down-rate limits (20ms silver, 10ms gold/prime) to eliminate DVFS frequency jitter across 90Hz frame bounds.
  * **App Compilation & RAM**: Disabled `dalvik.vm.minidebuginfo` and `dex2oat-minidebuginfo` to eliminate GDB unwind tables from compiled apps, saving disk space and memory footprint.
  * **Wi-Fi Diagnostics**: Disabled firmware log polling (`gEnablefwlog=0`) in `WCNSS_qcom_cfg.ini`.
  * Set 18 media volume steps for finer volume adjustment.
  * Disabled SurfaceFlinger background blur for maximum fluidity and lower GPU power draw.
  * Supported 3 haptic vibration intensity levels.
  * Configured ZRAM disk size to 80% of physical RAM (~4.9 GB on 6GB model, ~6.5 GB on 8GB model) paired with kernel `zstd` compression for superior app retention.
  * Disabled subsystem crash ramdumps (`persist.vendor.ssr.enable_ramdumps=0`) and background modem diagnostic logging.

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
