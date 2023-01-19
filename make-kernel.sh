#!/bin/bash

PLATFORMDIR=/media/nas/vari/platform-hemx8mmini
KERNELDIR=./linux-imx-4.19.y

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export PATH=/opt/toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/:$PATH
export INSTALL_MOD_STRIP=1
export INSTALL_MOD_PATH=$PLATFORMDIR/hemx8mmini

pushd $KERNELDIR
echo "Cleaning and preparing .config"
cp $PLATFORMDIR/imx8_var_defconfig arch/arm64/configs/
make clean
make imx8_var_defconfig
make menuconfig
cp .config $PLATFORMDIR/imx8_var_defconfig

echo "Compiling dts, image and modules"
make -j16 Image.gz dtbs modules

echo "Saving to hemx8mmini on NAS"
cp arch/arm64/boot/Image.gz $PLATFORMDIR/hemx8mmini/boot
cp arch/arm64/boot/dts/freescale/fsl-imx8mm-var-dart.dtb $PLATFORMDIR/hemx8mmini/boot/
cp arch/arm64/boot/dts/freescale/fsl-imx8mm-var-dart-m4.dtb $PLATFORMDIR/hemx8mmini/boot/
cp arch/arm64/boot/dts/freescale/fsl-imx8mm-var-som.dtb $PLATFORMDIR/hemx8mmini/boot/
cp arch/arm64/boot/dts/freescale/fsl-imx8mm-var-som-m4.dtb $PLATFORMDIR/hemx8mmini/boot/
cp arch/arm64/boot/dts/freescale/fsl-imx8mm-var-som-rev10.dtb $PLATFORMDIR/hemx8mmini/boot/
cp arch/arm64/boot/dts/freescale/fsl-imx8mm-var-som-rev10-m4.dtb $PLATFORMDIR/hemx8mmini/boot/

kver=`make kernelrelease`-`date +%Y.%m.%d-%H.%M`
rm $PLATFORMDIR/hemx8mmini/boot/config*
cp arch/arm64/configs/imx8_var_defconfig $PLATFORMDIR/hemx8mmini/boot/config-${kver}
rm -r $PLATFORMDIR/hemx8mmini/lib
make modules_install ARCH=arm64 

echo "Compressing hemx8mmini"
cd $PLATFORMDIR
tar cvfJ hemx8mmini.tar.xz ./hemx8mmini
echo "This is where your kernel image is: ${PLATFORMDIR}/hemx8mmini/boot"
echo "This is where your dtb files are: ${PLATFORMDIR}/hemx8mmini/boot/dtb/"
echo "This is where your lib modules are: ${PLATFORMDIR}/hemx8mmini/lib/modules"
echo "This is where your last config file is: ${PLATFORMDIR}"
popd
