#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run the build script as root"
  exit
fi

BUILDDATE=$(date -I)
IMG_FILE="imx8mm-UMS-mode-${BUILDDATE}.img"

echo "[INFO] Creating Image File ${IMG_FILE}"

dd if=/dev/zero of=${IMG_FILE} bs=1M count=40

echo "[INFO] Creating Image Bed"
LOOP_DEV=`losetup -f --show ${IMG_FILE}`
# Note: leave the first 20Mb free for the firmware
parted -s "${LOOP_DEV}" mklabel msdos
parted -s "${LOOP_DEV}" mkpart primary fat16 21 40
parted -s "${LOOP_DEV}" set 1 boot on
parted -s "${LOOP_DEV}" print
partprobe "${LOOP_DEV}"
kpartx -s -a "${LOOP_DEV}"

BOOT_PART=`echo /dev/mapper/"$( echo ${LOOP_DEV} | sed -e 's/.*\/\(\w*\)/\1/' )"p1`
if [ ! -b "${BOOT_PART}" ]
then
	echo "[ERR] ${BOOT_PART} doesn't exist"
	exit 1
fi

echo "[INFO] Creating boot and rootfs filesystems"
mkfs -t vfat -n BOOT "${BOOT_PART}"
sync

echo "[INFO] Getting the imx8mm u-boot and boot files"
if [ -d platform-variscite ]
then
# if you really want to re-clone from the repo, then delete the platform-imx8mm folder
    # that will refresh all, see below
   cd platform-variscite
   if [ -f imx8mm.tar.xz ]; then
      echo "[INFO] Found a new tarball, unpacking..."
      [ -d imx8mm ] || rm -r imx8mm
      tar xfJ imx8mm.tar.xz
      rm imx8mm.tar.xz
   fi
   cd ..
else
   echo "[INFO] Get imx8mm files from repo"
   git clone https://github.com/volumio/platform-variscite --depth 1
   cd platform-variscite
   tar xfJ imx8mm.tar.xz
   rm imx8mm.tar.xz
   cd ..
fi

echo "[INFO] Copying the hemx8mmini bootloader"
sudo dd if=platform-variscite/imx8mm/uboot/imx-boot-sd.bin of=${LOOP_DEV} bs=1K seek=33 conv=fsync

echo "[INFO] Prepare the boot folder"
if [ ! -d /mnt ]; then
	mkdir /mnt
fi
if [ -d /mnt/boot ]; then
	rm -rf /mnt/boot/*
else
	mkdir /mnt/boot
fi

echo "[INFO] Mount the boot partition"
mount -t vfat "${BOOT_PART}" /mnt/boot

echo "[INFO] Copying boot files"
cp platform-variscite/imx8mm/ums-mode/boot.cmd /mnt/boot

echo "[INFO] Compiling u-boot boot script"
mkimage -C none -A arm -T script -d platform-variscite/imx8mmini/ums-mode/boot.cmd /mnt/boot/boot.scr

echo "[INFO] ==> imx8mmini usm-mode image installed"
sync

echo "[INFO] Unmounting Temp Devices"
umount -l /mnt/boot

dmsetup remove_all
losetup -d ${LOOP_DEV}
zip ${IMG_FILE}.zip ${IMG_FILE}
sync
