#
# Copyright (C) 2016-2017 Wind River Systems Inc.
#

DESCRIPTION = "MOK Secure Boot packages for secure-environment."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

ALLOW_EMPTY_${PN} = "1"

pkgs = " \
    shim \
    mokutil \
    packagegroup-efi-secure-boot \
"

RDEPENDS_${PN}_x86 = "${pkgs}"
RDEPENDS_${PN}_x86-64 = "${pkgs}"
