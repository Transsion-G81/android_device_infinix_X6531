#
# Copyright (C) 2023-2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# X6531B - Infinix HOT 50i with NFC, built out of the X6531 tree.

# Read by device.mk - must be set before device.mk is inherited.
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
