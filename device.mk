#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Installs gsi keys into ramdisk, to boot a developer GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Project ID Quota
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Setup dalvik vm configs
$(call inherit-product, frameworks/native/build/phone-xhdpi-4096-dalvik-heap.mk)

## Inherit from GKI stuffs
#$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Inherit common MediaTek IMS
$(call inherit-product, vendor/mediatek/ims/ims.mk)

## Inherit from virtual A/B, most specific first
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)


# A/B
PRODUCT_PACKAGES += \
    com.android.hardware.boot \
    android.hardware.boot-service.default_recovery

PRODUCT_PACKAGES += \
    create_pl_dev \
    create_pl_dev.recovery

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@7.0-impl:32 \
    android.hardware.audio.effect@7.0-impl:32 \
    android.hardware.audio.service

PRODUCT_PACKAGES += \
    audio.bluetooth.default:32 \
    android.hardware.bluetooth.audio-impl:32

PRODUCT_PACKAGES += \
    Audioservice.tran \
    MtkInCallService

PRODUCT_PACKAGES += \
    libdynproc:32 \
    libhapticgenerator:32

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/audio/,$(TARGET_COPY_OUT_VENDOR)/etc)

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml

# Cgroup
PRODUCT_COPY_FILES += \
    system/core/libprocessgroup/profiles/cgroups_30.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json \
    $(LOCAL_PATH)/configs/task_profiles.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json

# Charger
PRODUCT_PACKAGES += \
    libsuspend

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.memtrack-service.mediatek

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey

# DT2W
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/keylayout/mtk-tpd.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/mtk-tpd.kl

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := false

PRODUCT_PACKAGES += \
    fastbootd

# FM Radio
PRODUCT_PACKAGES += \
    FMRadio

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-V1-ndk \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-impl.recovery \
    android.hardware.health@2.1-service

# HIDL 
PRODUCT_PACKAGES += \
    libhidltransport \
    libhidltransport.vendor 

# Light
PRODUCT_PACKAGES += \
    android.hardware.light-service.lineage

# Linker
PRODUCT_VENDOR_LINKER_CONFIG_FRAGMENTS += \
    $(LOCAL_PATH)/configs/linker.config.json

# Neural Networks
PRODUCT_PACKAGES += \
	android.hardware.neuralnetworks@1.0.vendor \
	android.hardware.neuralnetworks@1.1.vendor \
	android.hardware.neuralnetworks@1.2.vendor \
	android.hardware.neuralnetworks@1.3.vendor \
    libruy.vendor \
    libtextclassifier_hash.vendor
    
# NFC (X6531B only - TECNO/Transsion TMS "THN31" controller)
#
# Only the X6531B (Infinix HOT 50i with NFC) has an NFC controller: it sits
# on I2C behind /dev/tms_nfc, brought up by nfc_i2c_tms.ko (already listed in
# modules/modules.load.vendor).  Everything NFC related lives behind this
# gate - lineage_X6531.mk inherits device.mk without setting PRODUCT_NAME, so
# PRODUCT_NAME is empty here for that product and the block is skipped.
#
# Lineage's own NFC stack (packages/modules/Nfc: NfcNci + libnfc-nci, both
# shipped by base_system.mk) binds to the stock HIDL 1.2 HAL first
# (NfcAdaptation::InitializeHalDeviceContext), so no NFC sources are needed.
# com.android.nfc_extras and Tag are not part of base_system.mk;
# SecureElement (com.android.se) already is.
ifneq ($(filter lineage_X6531B,$(PRODUCT_NAME)),)

# RRO for com.android.nfc (enable_secure_nfc_support for the eSE/UICC routes
# in libnfc-tms.conf).
PRODUCT_PACKAGES += \
    NfcResOverlay_X6531B \
    Tag \
    com.android.nfc_extras

# NFC init (/vendor/etc/init/hw/init.stnfc.rc).  The import of that file is
# already in init.mt6768.rc, init.connectivity.rc,
# init.connectivity.common.rc and init.connectivity.mt6768.rc - it is a no-op
# on the X6531 build because the file is only packaged here.
PRODUCT_PACKAGES += \
    init.stnfc.rc

# NFC config: libnfc-tms*.conf is read by the HAL, libnfc-nci.conf by
# libnfc-nci (the framework side) - both from the stock dump.
# The vintf fragment declares the HALs this product installs.
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*.conf,$(LOCAL_PATH)/configs/nfc,$(TARGET_COPY_OUT_VENDOR)/etc) \
    $(LOCAL_PATH)/configs/nfc/manifest_x6531b.xml:$(TARGET_COPY_OUT_VENDOR)/etc/vintf/manifest/vendor.tms.hardware.nfc.xml

# NFC features (the framework only enables NFC when these are present).
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.android.nfc_extras.xml

# NFC HAL, config and firmware blobs (vendor/infinix/X6531).
$(call inherit-product, vendor/infinix/X6531/X6531B-nfc.mk)

endif

# Media
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/seccomp,$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy) \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/media,$(TARGET_COPY_OUT_VENDOR)/etc)

# Overlays
PRODUCT_PACKAGES += \
    CarrierConfigOverlay_X6531 \
    FrameworksResOverlay_X6531 \
    SystemUIOverlay_X6531 \
    SettingsResOverlay_X6531 \
    TetheringResOverlay_X6531 \
    WifiResOverlay_X6531

DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_ENFORCE_RRO_TARGETS := *

# Partition source order for Product/Build properties pickup.
PRODUCT_SYSTEM_PROPERTIES += \
    ro.product.property_source_order=odm,vendor,product,system_ext,system

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.faketouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.faketouch.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.dynamic.head_tracker.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2020-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2020-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

PRODUCT_PACKAGES += \
    android.hardware.hardware_keystore.km41.xml

# vndservice
PRODUCT_PACKAGES += \
   vndservicemanager \
   vndservice

# Power
PRODUCT_PACKAGES += \
    android.hardware.power@1.3.vendor \
    android.hardware.power-service.lineage-libperfmgr \
    vendor.mediatek.hardware.mtkpower@1.2-service.stub \
    libmtkperf_client_vendor \
    libmtkperf_client

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# Power Off Alarm
PRODUCT_PACKAGES += \
    PowerOffAlarm

# Properties
include $(LOCAL_PATH)/vendor_logtag.mk

# Rootdir
PRODUCT_PACKAGES += \
    fstab.mt6768 \
    fstab.mt6768.vendor_ramdisk \
    init.connectivity.rc \
    init.modem.rc \
    init.insmod.mt6768.cfg \
    init.mtkgki.rc \
    init.connectivity.mt6768.rc \
    init.connectivity.common.rc \
    init_connectivity.rc \
    init.mt6768.rc \
    init.cgroup.rc \
    init.insmod.sh \
    init.x6531.usb.rc \
    init.project.rc \
    init.sensor_1_0.rc \
    init.target.rc \
    ueventd.mt6768.rc

PRODUCT_PACKAGES += \
    init.recovery.usb.rc

PRODUCT_PACKAGES += \
    libsensorndkbridge:64 \
    android.hardware.sensors@1.0.vendor:64 \
    android.hardware.sensors@2.1.vendor:64 \
    android.frameworks.sensorservice@1.0:64 \
    android.frameworks.sensorservice@1.0.vendor:64 \
    android.hardware.sensors@2.1-service.multihal \
    android.hardware.sensors@2.0-ScopedWakelock.vendor:64

PRODUCT_PACKAGES += \
    sensors.dynamic_sensor_hal:64

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 30

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/google/interfaces \
    hardware/google/pixel \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/mediatek \
    hardware/mediatek/libmtkperf_client 

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-impl

PRODUCT_PACKAGES += \
    android.hardware.thermal@2.0.vendor

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb@1.3.vendor \
    android.hardware.usb.gadget@1.1.vendor

# Vibrator
$(call soong_config_set, vibrator, vibratortargets, vibratoraidlV2target)

PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/vibrator/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml

# VNDK
PRODUCT_PACKAGES += \
    libcrypto-v33 \
    libtinyxml2-v34 \
    libssl-v33

# Wi-Fi
$(call soong_config_set_bool,mediatek_wifi_hal,use_pre_u_qpr2_struct,true)
PRODUCT_PACKAGES += \
    android.system.wifi.keystore@1.0.vendor \
    libkeystore-wifi-hidl:64 \
    libkeystore-engine-wifi-hidl:64 \
    libnl.vendor \
    android.hardware.wifi@1.1.vendor \
    android.hardware.wifi@1.2.vendor \
    android.hardware.wifi@1.3.vendor \
    android.hardware.wifi@1.4.vendor \
    android.hardware.wifi.supplicant@1.0.vendor \
    android.hardware.wifi.supplicant@1.1.vendor \
    android.hardware.wifi.supplicant@1.2.vendor \
    android.hardware.wifi.supplicant@1.3.vendor \
    android.hardware.wifi.supplicant@1.4.vendor \
    wpa_supplicant \
    hostapd \
    libwifi-hal-wrapper:64 \
    android.hardware.wifi-service

# Debugging
ifeq ($(WITH_XGSI_LOGS),true)
    PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/logging/init.xgsi-bootlog.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.xgsi-bootlog.rc \
        $(LOCAL_PATH)/logging/xgsi-bootlog.sh:$(TARGET_COPY_OUT_SYSTEM)/etc/init/xgsi-bootlog.sh \
        $(LOCAL_PATH)/logging/xgsi-dmesg.sh:$(TARGET_COPY_OUT_SYSTEM)/etc/init/xgsi-dmesg.sh
endif

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/wifi/,$(TARGET_COPY_OUT_VENDOR)/etc/wifi)

# Inherit the proprietary files
$(call inherit-product, vendor/infinix/X6531/X6531-vendor.mk)

# Inherit the sign keys
$(call inherit-product, vendor/lineage-priv/keys/keys.mk)
