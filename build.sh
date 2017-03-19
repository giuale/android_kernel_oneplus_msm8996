#!/bin/bash

#
#  Build Script for Dark Kernel for OnePlus 3/t!
#  Based off AK'sbuild script - Thanks!
#

# Bash Color
rm .version
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DEFCONFIG="sduzz_defconfig"

# Kernel Details
BASE_SDUZZ_VER=Dark-Kernel
VER="1.0-rc1"
VARIANT="DARK-OOS"

# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=Sduzz
export CCACHE=ccache

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/project/OP3-AnyKernel"
PATCH_DIR="${HOME}/project/OP3-AnyKernel/patch"
MODULES_DIR="${HOME}/project/OP3-AnyKernel/modules"
ZIP_MOVE="${HOME}/project/out"
ZIMAGE_DIR="${HOME}/project/sduzz/arch/arm64/boot"

function clean_all {
		cd $REPACK_DIR
		rm -rf $MODULES_DIR/*
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		rm -rf zImage
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		rm `echo $MODULES_DIR"/*"`
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm64/boot/
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 sduzz-"$VARIANT"-R.zip *
		mv sduzz-"$VARIANT"-R.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "sduzz Kernel Creation Script:"
echo -e "${restore}"

echo "Pick Toolchain..."
select choice in aarch64-5.3 aarch64-6.3 aarch64-linux-android-4.9 linaro-6.3 ubertc-6.0 ubertc-7.0
do
case "$choice" in
	"aarch64-5.3")
		export CROSS_COMPILE=${HOME}/project/toolchain/aarch64-5.3/bin/aarch64-linux-gnu-
		break;;
	"aarch64-6.3")
		export CROSS_COMPILE=${HOME}/project/toolchain/aarch64-6.3/bin/aarch64-
		break;;
	"aarch64-linux-android-4.9")
		export CROSS_COMPILE=${HOME}/project/toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-
		break;;
	"linaro-6.3")
		export CROSS_COMPILE=${HOME}/project/toolchain/aarch64-6.3-linaro/bin/aarch64-linux-gnu-
		break;;
	"ubertc-6.0")
		export CROSS_COMPILE=${HOME}/project/toolchain/UBERTC-aarch64-6.0/bin/aarch64-linux-android-
		break;;
	"ubertc-7.0")
		export CROSS_COMPILE=${HOME}/project/toolchain/UBERTC-aarch64-7.0/bin/aarch64-linux-android-
		break;;
esac
done

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
