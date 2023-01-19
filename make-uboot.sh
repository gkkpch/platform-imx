#!/bin/bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export PATH=/opt/toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/:$PATH
PLATFORMDIR=/media/nas/vari/platform-hemx8mmini

if [ -d uboot-imx ]; then
    sudo rm -r uboot-imx
fi
echo "[INFO] Cloning u-boot"
git clone https://github.com/varigit/uboot-imx.git -b imx_v2018.03_4.14.98_2.0.0_ga_var01 --depth 1
pushd uboot-imx

echo "[INFO] Applying uboot patches]"
git apply $PLATFORMDIR/hemx8mmini/uboot/uboot-imx8mm_var_dart.patch

echo "[INFO] Building u-boot"
make mrproper
make imx8mm_var_dart_defconfig
make -j16

echo "[INFO] Get DDR firmware"
mkdir imx-boot-tools
pushd imx-boot-tools
wget https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-8.5.bin
chmod +x firmware-imx-8.5.bin
./firmware-imx-8.5.bin
cp firmware-imx-8.5/firmware/ddr/synopsys/* .

echo "[INFO] Download imx_mkimage"
git clone https://source.codeaurora.org/external/imx/imx-mkimage -b imx_4.19.35_1.1.0 --depth 1
cp imx-mkimage/iMX8M/*.c imx-mkimage/iMX8M/*.sh  imx-mkimage/scripts/pad_image.sh .

echo "[INFO] Download ATF"
git clone https://source.codeaurora.org/external/imx/imx-atf -b imx_4.19.35_1.1.0 --depth 1
git clone https://github.com/varigit/meta-variscite-imx -b warrior-imx-4.19.35-var01 --depth 1
cp meta-variscite-imx/recipes-bsp/imx-mkimage/files/soc.mak .

echo "[INFO] Build ATF"
cd imx-atf
git apply ../meta-variscite-imx/recipes-bsp/imx-atf/imx-atf/imx8mm* ../meta-variscite-imx/recipes-bsp/imx-atf/imx-atf/imx8m-*
unset LDFLAGS
make PLAT=imx8mm bl31
cp build/imx8mm/release/bl31.bin ..
cd ..

pwd

cp ../tools/mkimage mkimage_uboot
cp ../u-boot.bin .
cp ../u-boot-nodtb.bin ../spl/u-boot-spl.bin ../arch/arm/dts/fsl-imx8mm-var-dart.dtb ../arch/arm/dts/fsl-imx8mm-var-som*.dtb .

make -f soc.mak clean
make -f soc.mak SOC=iMX8MM dtbs="fsl-imx8mm-var-dart.dtb fsl-imx8mm-var-som.dtb fsl-imx8mm-var-som-rev10.dtb" MKIMG=./mkimage_imx8 PAD_IMAGE=./pad_image.sh CC=gcc OUTIMG=imx-boot-sd.bin flash_lpddr4_ddr4_evk
cp imx-boot-sd.bin $PLATFORMDIR/hemx8mmini/uboot

echo "[INFO] Compressing hemx8mmini"
cd $PLATFORMDIR
tar cvfJ hemx8mmini.tar.xz ./hemx8mmini
echo "[INFO] [INFO] This is where your kernel image is: ${PLATFORMDIR}/hemx8mmini/boot"
echo "[INFO] [INFO] This is where your dtb files are: ${PLATFORMDIR}/hemx8mmini/boot/dtb/"
echo "[INFO] [INFO] This is where your lib modules are: ${PLATFORMDIR}/hemx8mmini/lib/modules"
echo "[INFO] [INFO] This is where your last config file is: ${PLATFORMDIR}"

