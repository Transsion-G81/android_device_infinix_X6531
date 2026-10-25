#
# Copyright (C) 2023-2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# X6531B - Infinix HOT 50i with NFC, built out of the X6531 device tree
# (device/infinix/X6531, vendor/infinix/X6531).
#
# The ONLY differences from lineage_X6531.mk are the NFC bits:
#   * device.mk picks up its "NFC (X6531B only)" block because PRODUCT_NAME
#     is set before device.mk is inherited (the block inherits
#     vendor/infinix/X6531/X6531B-nfc.mk, adds the NFC configs/feature XMLs
#     and the NfcResOverlay_X6531B RRO).
#   * identity properties are taken from the stock X6531B dump
#     (Infinix/X6531B-OP/Infinix-X6531B:14/UP1A.231005.007/260713V1136).
#
# The X6531 has no NFC controller at all, so nothing in this file may leak
# into lineage_X6531 (see the git history of device.mk for the gate).

# Variant marker read by device.mk - must be set before device.mk is
# inherited.
PRODUCT_NAME := lineage_X6531B

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from device makefile.
$(call inherit-product, device/infinix/X6531/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_DEVICE := X6531
PRODUCT_MANUFACTURER := Infinix
PRODUCT_BRAND := Infinix
PRODUCT_MODEL := Infinix X6531B

PRODUCT_SYSTEM_NAME := X6531B-OP
PRODUCT_SYSTEM_DEVICE := X6531B

PRODUCT_GMS_CLIENTID_BASE := android-transsion

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="Infinix-X6531B-user 14 UP1A.231005.007 260713V1136 release-keys" \
    BuildFingerprint=Infinix/X6531B-OP/Infinix-X6531B:14/UP1A.231005.007/260713V1136:user/release-keys \
    SystemModel=$(PRODUCT_SYSTEM_DEVICE) \
    SystemName=$(PRODUCT_SYSTEM_NAME) \
    ProductModel=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)
