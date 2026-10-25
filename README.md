# Android Device tree for the Infinix HOT 50i

LineageOS 23.2 device tree for the **Infinix HOT 50i** (MT6768 / Helio G81,
Android 14 vendor, `device/infinix/X6531`, blobs in `vendor/infinix/X6531`).

```
lunch lineage_X6531-userdebug    # HOT 50i, no NFC
lunch lineage_X6531B-userdebug   # HOT 50i with NFC (TMS/THN31)
```

Both products are built from this one tree; the only difference is the NFC
stack described below. `PRODUCT_NAME` is set at the top of
`lineage_X6531B.mk`, before `device.mk` is inherited, and the
`# NFC (X6531B only)` block in `device.mk` is gated on it, so the
`lineage_X6531` build is untouched.

## 1. NFC (X6531B only - TECNO/Transsion TMS "THN31")

The X6531B (the NFC SKU of the HOT 50i) has a TMS/THN31 controller on I2C;
the `lineage_X6531` build in this tree has no NFC stack at all. Evidence, all
from the X6531B stock dump:

* `vendor/lib/modules/modules.load` loads `nfc_i2c_tms.ko` (the TMS I2C
  driver, creates `/dev/tms_nfc` and `/sys/nfc/chip_name`) - the tree already
  lists it in `modules/modules.load.vendor`;
* `vendor/bin/hw/android.hardware.nfc@1.2-service-tms` +
  `vendor/lib64/nfc_nci.thn31nfc.tms.so` + `vendor/lib64/tms-*.so` +
  `vendor/lib64/vendor.tms.tmsnfc@1.0.so` - the HAL;
* `vendor/etc/libnfc-tms*.conf` (`TMS_NFC_DEV_NODE="/dev/tms_nfc"`) and the
  THN31 firmware `vendor/etc/SEC_THN31_FW_VTP.txt.bin`;
* `vendor/etc/init/init.vnd_x6531_v631.nfc.rc` chowns `/dev/tms_nfc` and
  `/sys/nfc/chip_name` (the device specific project name is this one).

The NXP `snxxx` stack that the same dump also carries (and the TMS forked app
`NfcNci_tms`/`libtmsnfc-nci.so` in `system_ext`) is dead weight there: no
`nfc_i2c.ko` in `vendor/lib/modules/modules.load`, no NXP NFCC firmware
anywhere in `/vendor`, and the only `ISecureElement` readers in the stock
manifest are the MTK `SIM1`/`SIM2` ones. It is not packaged here.

### How it works

No NFC sources are needed (no `hardware/nxp/*`, no `hardware/st/*`):
Lineage's own `NfcNci` + `libnfc-nci` from `packages/modules/Nfc` (shipped by
`build/make/target/product/base_system.mk`, together with `SecureElement` /
`com.android.se`) bind to the **HIDL 1.2** HAL first - see
`NfcAdaptation::InitializeHalDeviceContext`, it tries `INfcV1_2::getService()`
before falling back to AIDL - and read the shared `/vendor/etc/libnfc-nci.conf`
that the device tree copies.

```
NfcNci (Lineage) ─ libnfc-nci ─ HIDL android.hardware.nfc@1.2::INfc/default
                                         │  android.hardware.nfc@1.2-service-tms
                                         │      (init: nfc_hal_service.tms)
                                         ├── nfc_nci.thn31nfc.tms.so
                                         │     ├── /vendor/etc/libnfc-tms*.conf
                                         │     ├── SEC_THN31_FW_VTP.txt.bin
                                         │     ├── /data/vendor/nfc (NVM state)
                                         │     └── /dev/tms_nfc  (nfc_i2c_tms.ko)
                                         └── vendor.tms.tmsnfc@1.0::ITmsNfc/default

com.android.se ─ HIDL android.hardware.secure_element@1.2::ISecureElement
                        └── android.hardware.secure_element@1.2-service-mediatek
```

### File map

| Where | What |
| --- | --- |
| `AndroidProducts.mk` | `lineage_X6531` + `lineage_X6531B` and their lunch choices |
| `lineage_X6531B.mk` | product file, identity props from the stock X6531B dump |
| `device.mk` (`NFC (X6531B only)` block) | NFC packages, configs, feature XMLs, vendor NFC makefile |
| `configs/nfc/*.conf` | `libnfc-tms{,_RF,_RF_EC2,_RF_GB1}.conf` (HAL), `libese-tms.conf` (FW/BL/COS names, read by `tms-utils.so`) + `libnfc-nci.conf` (libnfc-nci) |
| `configs/nfc/manifest_x6531b.xml` | VINTF fragment: `android.hardware.nfc@1.2::INfc/default`, `vendor.tms.tmsnfc@1.0::ITmsNfc/default`, `android.hardware.secure_element@1.2::ISecureElement/SIM{1,2}` |
| `overlay/NfcResOverlay_X6531B` | RRO for `com.android.nfc` (`enable_secure_nfc_support`) |
| `rootdir/etc/init.stnfc.rc` | `/data/vendor/nfc*` dirs, `/dev/tms_nfc` perms, both HAL services (imported by the `init.*.rc` files already in the tree) |
| `rootdir/etc/ueventd.mt6768.rc` | `/dev/tms_nfc 0660 nfc nfc`, `/dev/tms_ese 0660 secure_element secure_element` |
| `sepolicy/vendor/file_contexts` | `/dev/tms_nfc` -> `nfc_device`, `/dev/tms_ese` -> `secure_element_device`, `android.hardware.nfc@1.2-service-tms` -> `hal_nfc_default_exec` |
| `sepolicy/vendor/hwservice_contexts` | `vendor.tms.tmsnfc::ITmsNfc` -> `hal_nfc_hwservice` |
| `sepolicy/vendor/hal_nfc_default.te` | NFC HAL <-> `mtk_hal_secure_element` binder calls |
| `framework_compatibility_matrix.xml` | optional `vendor.tms.tmsnfc` entry (keeps `lineage_X6531` checkvintf clean) |
| `vendor/infinix/X6531/X6531B-nfc.mk` | packages the HALs (prebuilt modules) + libraries |
| `vendor/infinix/X6531/proprietary_x6531b/` | the blobs themselves |

Everything else (the `hal_nfc_default` domain, `hal_nfc_default_exec`,
`nfc_device`, `hal_nfc_hwservice`, `hal_nfc_service`, `/data/vendor/nfc`) comes
from `system/sepolicy` and `device/mediatek/sepolicy_vndr`; the ST/NXP/Samsung
`-service-*` variants of the NFC HAL are already labelled there, only the
`-tms` binary is not.

### Build / package notes

* `NfcNci`, `framework-nfc`, `com.android.nfcservices`, `SecureElement` are
  part of `base_system.mk` (the NFC app is selected by the build release flag
  `RELEASE_PACKAGE_NFC_STACK`, default `NfcNci`); `Tag` and
  `com.android.nfc_extras` are added by the device NFC block, as on other
  NFC devices.
* The HAL executables are installed through `cc_prebuilt_binary` modules
  (`proprietary_x6531b/Android.bp`), not `PRODUCT_COPY_FILES`, so they always
  end up mode 0755 regardless of the blob's mode in git.
* The THN31 firmware and `firmware_slm*.bin` were already packaged by
  `X6531-vendor.mk` before this change (they are listed in
  `proprietary-files.txt`), no duplication.

### Verify

```sh
adb shell getprop | grep -i nfc          # ro.hardware.nfc, persist.vendor.nfc...
adb shell dumpsys nfc | head -40         # state + HAL interface version
adb shell ls -l /dev/tms_nfc             # nfc:nfc, 0660
adb shell ps -A | grep nfc               # both HAL services + com.android.nfc
adb logcat -b all -d | grep -Ei "nfc_nci|NfcService|nfc_ncif|Tms|tms_nfc"
```

Expected: no `avc: denied` for `hal_nfc_default`, `nfc_device` or
`nfc_data_vendor_file`, `NfcService` reports `NFC state: ON` and tags are
dispatched to `NfcDispatcher`.

### Known caveats (not fixed here)

* `nfc_nci.thn31nfc.tms.so` reads `persist.vendor.nfc.configFile_name` and the
  TMS stack also touches `vendor.tms.nfc.*`. Those property contexts exist in
  the stock (MTK `non_plat`) sepolicy but not in
  `device/mediatek/sepolicy_vndr`; both are unset on a clean build, so an avc
  denial for them is cosmetic (the HAL falls back to `/vendor/etc/
  libnfc-tms.conf`). Add property contexts if the log noise is unwanted.
* The HAL binary reads `/sys/nfc/chip_name` without an SELinux label (as in
  stock, where `hal_nfc_default` had no sysfs rights either); the
  `chown` in `init.stnfc.rc` mirrors the stock script and is best effort.
* The 32-bit copies of the NFC libraries and the unused NXP/TMS-forked
  userspace from the dump are deliberately not packaged.
