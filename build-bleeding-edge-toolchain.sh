#!/bin/sh

set -e
set -u

binutilsVersion=2.27
expatVersion=2.2.0
gccVersion=6.2.0
gdbVersion=7.12
gmpVersion=6.1.1
islVersion=0.16
libelfVersion=0.8.13
mpcVersion=1.0.3
mpfrVersion=3.1.5
newlibVersion=2.4.0.20160923
zlibVersion=1.2.8

top=$(pwd)
buildNative=buildNative
installNative=installNative
sources=sources

binutils=binutils-${binutilsVersion}
binutilsArchive=${binutils}.tar.bz2
expat=expat-${expatVersion}
expatArchive=${expat}.tar.bz2
gcc=gcc-${gccVersion}
gccArchive=${gcc}.tar.bz2
gdb=gdb-${gdbVersion}
gdbArchive=${gdb}.tar.xz
gmp=gmp-${gmpVersion}
gmpArchive=${gmp}.tar.xz
isl=isl-${islVersion}
islArchive=${isl}.tar.xz
libelf=libelf-${libelfVersion}
libelfArchive=${libelf}.tar.gz
mpc=mpc-${mpcVersion}
mpcArchive=${mpc}.tar.gz
mpfr=mpfr-${mpfrVersion}
mpfrArchive=${mpfr}.tar.xz
newlib=newlib-${newlibVersion}
newlibArchive=${newlib}.tar.gz
zlib=zlib-${zlibVersion}
zlibArchive=${zlib}.tar.xz

pkgversion=bleeding-edge-toolchain
target=arm-none-eabi
package=${target}-${gcc}-$(date +'%y%m%d')
packageArchive=${package}.tar.xz

bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}********** Cleanup${normal}"
rm -rf ${buildNative}
mkdir -p ${buildNative}
rm -rf ${installNative}
mkdir -p ${installNative}
mkdir -p ${sources}
find ${sources} -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
find ${sources} -mindepth 1 -maxdepth 1 -type f ! -name "${binutilsArchive}" \
	! -name "${expatArchive}" \
	! -name "${gccArchive}" \
	! -name "${gdbArchive}" \
	! -name "${gmpArchive}" \
	! -name "${islArchive}" \
	! -name "${libelfArchive}" \
	! -name "${mpcArchive}" \
	! -name "${mpfrArchive}" \
	! -name "${newlibArchive}" \
	! -name "${zlibArchive}" \
	-exec rm -rf {} +

echo "${bold}********** Download${normal}"
mkdir -p ${sources}
cd ${sources}
download() {
	if [ ! -e ${1} ]; then
		echo "${bold}---------- Downloading ${1}${normal}"
		curl -L -o ${1} -C - ${2}
	fi	
}
download ${binutilsArchive} http://ftp.gnu.org/gnu/binutils/${binutilsArchive}
download ${expatArchive} https://sourceforge.net/projects/expat/files/expat/${expatVersion}/${expatArchive}
download ${gccArchive} ftp://ftp.gnu.org/gnu/gcc/${gcc}/${gccArchive}
download ${gdbArchive} http://ftp.gnu.org/gnu/gdb/${gdbArchive}
download ${gmpArchive} https://gmplib.org/download/gmp/${gmpArchive}
download ${islArchive} http://isl.gforge.inria.fr/${islArchive}
download ${libelfArchive} http://www.mr511.de/software/${libelfArchive}
download ${mpcArchive} ftp://ftp.gnu.org/gnu/mpc/${mpcArchive}
download ${mpfrArchive} http://www.mpfr.org/mpfr-${mpfrVersion}/${mpfrArchive}
download ${newlibArchive} ftp://sourceware.org/pub/newlib/${newlibArchive}
download ${zlibArchive} http://zlib.net/${zlibArchive}
cd ${top}

echo "${bold}********** Extract${normal}"
cd ${sources}
echo "${bold}---------- Extracting ${binutilsArchive}${normal}"
tar -xf ${binutilsArchive}
echo "${bold}---------- Extracting ${expatArchive}${normal}"
tar -xf ${expatArchive}
echo "${bold}---------- Extracting ${gccArchive}${normal}"
tar -xf ${gccArchive}
echo "${bold}---------- Extracting ${gdbArchive}${normal}"
tar -xf ${gdbArchive}
echo "${bold}---------- Extracting ${gmpArchive}${normal}"
tar -xf ${gmpArchive}
echo "${bold}---------- Extracting ${islArchive}${normal}"
tar -xf ${islArchive}
echo "${bold}---------- Extracting ${libelfArchive}${normal}"
tar -xf ${libelfArchive}
echo "${bold}---------- Extracting ${mpcArchive}${normal}"
tar -xf ${mpcArchive}
echo "${bold}---------- Extracting ${mpfrArchive}${normal}"
tar -xf ${mpfrArchive}
echo "${bold}---------- Extracting ${newlibArchive}${normal}"
tar -xf ${newlibArchive}
echo "${bold}---------- Extracting ${zlibArchive}${normal}"
tar -xf ${zlibArchive}
cd ${top}

echo "${bold}********** Patch${normal}"
cd ${sources}/${gcc}
patch -p1 << 'EOF'
diff -ruN gcc-6.2.0-original/gcc/config/arm/t-baremetal gcc-6.2.0/gcc/config/arm/t-baremetal
--- gcc-6.2.0-original/gcc/config/arm/t-baremetal	1970-01-01 01:00:00.000000000 +0100
+++ gcc-6.2.0/gcc/config/arm/t-baremetal	2016-10-06 21:54:25.735579948 +0200
@@ -0,0 +1,260 @@
+# A set of predefined MULTILIB which can be used for different ARM targets.
+# Via the configure option --with-multilib-list, user can customize the
+# final MULTILIB implementation.
+
+comma := ,
+
+with_multilib_list := $(subst $(comma), ,$(with_multilib_list))))
+
+MULTILIB_OPTIONS   = mthumb/marm
+MULTILIB_DIRNAMES  = thumb arm
+MULTILIB_OPTIONS  += march=armv6s-m/march=armv7-m/march=armv7e-m/march=armv7/march=armv8-m.base/march=armv8-m.main
+MULTILIB_DIRNAMES += armv6-m armv7-m armv7e-m armv7-ar armv8-m.base armv8-m.main
+MULTILIB_OPTIONS  += mfloat-abi=softfp/mfloat-abi=hard
+MULTILIB_DIRNAMES += softfp fpu
+MULTILIB_OPTIONS  += mfpu=fpv5-sp-d16/mfpu=fpv5-d16/mfpu=fpv4-sp-d16/mfpu=vfpv3-d16
+MULTILIB_DIRNAMES += fpv5-sp-d16 fpv5-d16 fpv4-sp-d16 vfpv3-d16
+
+MULTILIB_MATCHES   = march?armv6s-m=mcpu?cortex-m0
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m0.small-multiply
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m0plus
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m0plus.small-multiply
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m1
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m1.small-multiply
+MULTILIB_MATCHES  += march?armv6s-m=march?armv6-m
+MULTILIB_MATCHES  += march?armv7-m=mcpu?cortex-m3
+MULTILIB_MATCHES  += march?armv7e-m=mcpu?cortex-m4
+MULTILIB_MATCHES  += march?armv7e-m=mcpu?cortex-m7
+MULTILIB_MATCHES  += march?armv7e-m=mcpu?marvell-pj4
+MULTILIB_MATCHES  += march?armv7=march?armv7-r
+MULTILIB_MATCHES  += march?armv7=march?armv7-a
+MULTILIB_MATCHES  += march?armv7=march?armv8-a
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r4
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r4f
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r5
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r7
+MULTILIB_MATCHES  += march?armv7=mcpu?generic-armv7-a
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a5
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a7
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a8
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a9
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a12
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a15
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a17
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a15.cortex-a7
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a17.cortex-a7
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a53
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a57
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a72
+MULTILIB_MATCHES  += march?armv7=mcpu?exynos-m1
+MULTILIB_MATCHES  += march?armv7=mcpu?xgene1
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a57.cortex-a53
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a72.cortex-a53
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3-d16-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3xd
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3xd-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv4
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv4-d16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?neon
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?neon-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?neon-vfpv4
+
+MULTILIB_EXCEPTIONS =
+MULTILIB_REUSE =
+
+MULTILIB_REQUIRED  = mthumb
+MULTILIB_REQUIRED += marm
+MULTILIB_REQUIRED += mfloat-abi=hard
+
+MULTILIB_OSDIRNAMES  = mthumb=!thumb
+MULTILIB_OSDIRNAMES += marm=!arm
+MULTILIB_OSDIRNAMES += mfloat-abi.hard=!fpu
+
+ifneq (,$(findstring armv6-m,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv6s-m
+MULTILIB_OSDIRNAMES += mthumb/march.armv6s-m=!armv6-m
+endif
+
+ifneq (,$(findstring armv8-m.base,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.base
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.base=!armv8-m.base
+endif
+
+ifneq (,$(findstring armv7-m,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv7-m
+MULTILIB_OSDIRNAMES += mthumb/march.armv7-m=!armv7-m
+endif
+
+ifneq (,$(findstring armv7e-m,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=softfp/mfpu=fpv4-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=hard/mfpu=fpv4-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=softfp/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=hard/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=softfp/mfpu=fpv5-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=hard/mfpu=fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m=!armv7e-m
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.hard/mfpu.fpv4-sp-d16=!armv7e-m/fpu
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.softfp/mfpu.fpv4-sp-d16=!armv7e-m/softfp
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.hard/mfpu.fpv5-d16=!armv7e-m/fpu/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.softfp/mfpu.fpv5-d16=!armv7e-m/softfp/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.hard/mfpu.fpv5-sp-d16=!armv7e-m/fpu/fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.softfp/mfpu.fpv5-sp-d16=!armv7e-m/softfp/fpv5-sp-d16
+endif
+
+ifneq (,$(findstring armv8-m.main,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=softfp/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=hard/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=softfp/mfpu=fpv5-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=hard/mfpu=fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main=!armv8-m.main
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.hard/mfpu.fpv5-d16=!armv8-m.main/fpu/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.softfp/mfpu.fpv5-d16=!armv8-m.main/softfp/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.hard/mfpu.fpv5-sp-d16=!armv8-m.main/fpu/fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.softfp/mfpu.fpv5-sp-d16=!armv8-m.main/softfp/fpv5-sp-d16
+endif
+
+ifneq (,$(filter armv7 armv7-r armv7-a,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv7
+MULTILIB_REQUIRED   += mthumb/march=armv7/mfloat-abi=softfp/mfpu=vfpv3-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7/mfloat-abi=hard/mfpu=vfpv3-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7=!armv7-ar/thumb
+MULTILIB_OSDIRNAMES += mthumb/march.armv7/mfloat-abi.hard/mfpu.vfpv3-d16=!armv7-ar/thumb/fpu
+MULTILIB_OSDIRNAMES += mthumb/march.armv7/mfloat-abi.softfp/mfpu.vfpv3-d16=!armv7-ar/thumb/softfp
+MULTILIB_REUSE      += mthumb/march.armv7=marm/march.armv7
+MULTILIB_REUSE      += mthumb/march.armv7/mfloat-abi.softfp/mfpu.vfpv3-d16=marm/march.armv7/mfloat-abi.softfp/mfpu.vfpv3-d16
+MULTILIB_REUSE      += mthumb/march.armv7/mfloat-abi.hard/mfpu.vfpv3-d16=marm/march.armv7/mfloat-abi.hard/mfpu.vfpv3-d16
+endif
+# A set of predefined MULTILIB which can be used for different ARM targets.
+# Via the configure option --with-multilib-list, user can customize the
+# final MULTILIB implementation.
+
+comma := ,
+
+with_multilib_list := $(subst $(comma), ,$(with_multilib_list))))
+
+MULTILIB_OPTIONS   = mthumb/marm
+MULTILIB_DIRNAMES  = thumb arm
+MULTILIB_OPTIONS  += march=armv6s-m/march=armv7-m/march=armv7e-m/march=armv7/march=armv8-m.base/march=armv8-m.main
+MULTILIB_DIRNAMES += armv6-m armv7-m armv7e-m armv7-ar armv8-m.base armv8-m.main
+MULTILIB_OPTIONS  += mfloat-abi=softfp/mfloat-abi=hard
+MULTILIB_DIRNAMES += softfp fpu
+MULTILIB_OPTIONS  += mfpu=fpv5-sp-d16/mfpu=fpv5-d16/mfpu=fpv4-sp-d16/mfpu=vfpv3-d16
+MULTILIB_DIRNAMES += fpv5-sp-d16 fpv5-d16 fpv4-sp-d16 vfpv3-d16
+
+MULTILIB_MATCHES   = march?armv6s-m=mcpu?cortex-m0
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m0.small-multiply
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m0plus
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m0plus.small-multiply
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m1
+MULTILIB_MATCHES  += march?armv6s-m=mcpu?cortex-m1.small-multiply
+MULTILIB_MATCHES  += march?armv6s-m=march?armv6-m
+MULTILIB_MATCHES  += march?armv7-m=mcpu?cortex-m3
+MULTILIB_MATCHES  += march?armv7e-m=mcpu?cortex-m4
+MULTILIB_MATCHES  += march?armv7e-m=mcpu?cortex-m7
+MULTILIB_MATCHES  += march?armv7e-m=mcpu?marvell-pj4
+MULTILIB_MATCHES  += march?armv7=march?armv7-r
+MULTILIB_MATCHES  += march?armv7=march?armv7-a
+MULTILIB_MATCHES  += march?armv7=march?armv8-a
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r4
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r4f
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r5
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-r7
+MULTILIB_MATCHES  += march?armv7=mcpu?generic-armv7-a
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a5
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a7
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a8
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a9
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a12
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a15
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a17
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a15.cortex-a7
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a17.cortex-a7
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a53
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a57
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a72
+MULTILIB_MATCHES  += march?armv7=mcpu?exynos-m1
+MULTILIB_MATCHES  += march?armv7=mcpu?xgene1
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a57.cortex-a53
+MULTILIB_MATCHES  += march?armv7=mcpu?cortex-a72.cortex-a53
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3-d16-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3xd
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv3xd-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv4
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?vfpv4-d16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?neon
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?neon-fp16
+MULTILIB_MATCHES  += mfpu?vfpv3-d16=mfpu?neon-vfpv4
+
+MULTILIB_EXCEPTIONS =
+MULTILIB_REUSE =
+
+MULTILIB_REQUIRED  = mthumb
+MULTILIB_REQUIRED += marm
+MULTILIB_REQUIRED += mfloat-abi=hard
+
+MULTILIB_OSDIRNAMES  = mthumb=!thumb
+MULTILIB_OSDIRNAMES += marm=!arm
+MULTILIB_OSDIRNAMES += mfloat-abi.hard=!fpu
+
+ifneq (,$(findstring armv6-m,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv6s-m
+MULTILIB_OSDIRNAMES += mthumb/march.armv6s-m=!armv6-m
+endif
+
+ifneq (,$(findstring armv8-m.base,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.base
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.base=!armv8-m.base
+endif
+
+ifneq (,$(findstring armv7-m,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv7-m
+MULTILIB_OSDIRNAMES += mthumb/march.armv7-m=!armv7-m
+endif
+
+ifneq (,$(findstring armv7e-m,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=softfp/mfpu=fpv4-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=hard/mfpu=fpv4-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=softfp/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=hard/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=softfp/mfpu=fpv5-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7e-m/mfloat-abi=hard/mfpu=fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m=!armv7e-m
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.hard/mfpu.fpv4-sp-d16=!armv7e-m/fpu
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.softfp/mfpu.fpv4-sp-d16=!armv7e-m/softfp
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.hard/mfpu.fpv5-d16=!armv7e-m/fpu/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.softfp/mfpu.fpv5-d16=!armv7e-m/softfp/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.hard/mfpu.fpv5-sp-d16=!armv7e-m/fpu/fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7e-m/mfloat-abi.softfp/mfpu.fpv5-sp-d16=!armv7e-m/softfp/fpv5-sp-d16
+endif
+
+ifneq (,$(findstring armv8-m.main,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=softfp/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=hard/mfpu=fpv5-d16
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=softfp/mfpu=fpv5-sp-d16
+MULTILIB_REQUIRED   += mthumb/march=armv8-m.main/mfloat-abi=hard/mfpu=fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main=!armv8-m.main
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.hard/mfpu.fpv5-d16=!armv8-m.main/fpu/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.softfp/mfpu.fpv5-d16=!armv8-m.main/softfp/fpv5-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.hard/mfpu.fpv5-sp-d16=!armv8-m.main/fpu/fpv5-sp-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv8-m.main/mfloat-abi.softfp/mfpu.fpv5-sp-d16=!armv8-m.main/softfp/fpv5-sp-d16
+endif
+
+ifneq (,$(filter armv7 armv7-r armv7-a,$(with_multilib_list)))
+MULTILIB_REQUIRED   += mthumb/march=armv7
+MULTILIB_REQUIRED   += mthumb/march=armv7/mfloat-abi=softfp/mfpu=vfpv3-d16
+MULTILIB_REQUIRED   += mthumb/march=armv7/mfloat-abi=hard/mfpu=vfpv3-d16
+MULTILIB_OSDIRNAMES += mthumb/march.armv7=!armv7-ar/thumb
+MULTILIB_OSDIRNAMES += mthumb/march.armv7/mfloat-abi.hard/mfpu.vfpv3-d16=!armv7-ar/thumb/fpu
+MULTILIB_OSDIRNAMES += mthumb/march.armv7/mfloat-abi.softfp/mfpu.vfpv3-d16=!armv7-ar/thumb/softfp
+MULTILIB_REUSE      += mthumb/march.armv7=marm/march.armv7
+MULTILIB_REUSE      += mthumb/march.armv7/mfloat-abi.softfp/mfpu.vfpv3-d16=marm/march.armv7/mfloat-abi.softfp/mfpu.vfpv3-d16
+MULTILIB_REUSE      += mthumb/march.armv7/mfloat-abi.hard/mfpu.vfpv3-d16=marm/march.armv7/mfloat-abi.hard/mfpu.vfpv3-d16
+endif
diff -ruN gcc-6.2.0-original/gcc/config.gcc gcc-6.2.0/gcc/config.gcc
--- gcc-6.2.0-original/gcc/config.gcc	2016-06-08 15:34:25.000000000 +0200
+++ gcc-6.2.0/gcc/config.gcc	2016-10-06 21:54:25.735579948 +0200
@@ -1108,7 +1108,7 @@
 	case ${target} in
 	arm*-*-eabi*)
 	  tm_file="$tm_file newlib-stdint.h"
-	  tmake_file="${tmake_file} arm/t-bpabi"
+	  tmake_file="${tmake_file} arm/t-bpabi arm/t-baremetal"
 	  use_gcc_stdint=wrap
 	  ;;
 	arm*-*-rtems*)
@@ -3792,42 +3792,6 @@
 			exit 1
 		fi
 
-		# Add extra multilibs
-		if test "x$with_multilib_list" != x; then
-			arm_multilibs=`echo $with_multilib_list | sed -e 's/,/ /g'`
-			for arm_multilib in ${arm_multilibs}; do
-				case ${arm_multilib} in
-				aprofile)
-				# Note that arm/t-aprofile is a
-				# stand-alone make file fragment to be
-				# used only with itself.  We do not
-				# specifically use the
-				# TM_MULTILIB_OPTION framework because
-				# this shorthand is more
-				# pragmatic. Additionally it is only
-				# designed to work without any
-				# with-cpu, with-arch with-mode
-				# with-fpu or with-float options.
-					if test "x$with_arch" != x \
-					    || test "x$with_cpu" != x \
-					    || test "x$with_float" != x \
-					    || test "x$with_fpu" != x \
-					    || test "x$with_mode" != x ; then
-					    echo "Error: You cannot use any of --with-arch/cpu/fpu/float/mode with --with-multilib-list=aprofile" 1>&2
-					    exit 1
-					fi
-					tmake_file="${tmake_file} arm/t-aprofile"
-					break
-					;;
-				default)
-					;;
-				*)
-					echo "Error: --with-multilib-list=${with_multilib_list} not supported." 1>&2
-					exit 1
-					;;
-				esac
-			done
-		fi
 		;;
 
 	fr*-*-*linux*)
diff -ruN gcc-6.2.0-original/gcc/configure gcc-6.2.0/gcc/configure
--- gcc-6.2.0-original/gcc/configure	2016-06-08 15:34:25.000000000 +0200
+++ gcc-6.2.0/gcc/configure	2016-10-06 21:54:25.732246640 +0200
@@ -767,6 +767,7 @@
 LN_S
 AWK
 SET_MAKE
+with_multilib_list
 accel_dir_suffix
 real_target_noncanonical
 enable_as_accelerator
diff -ruN gcc-6.2.0-original/gcc/configure.ac gcc-6.2.0/gcc/configure.ac
--- gcc-6.2.0-original/gcc/configure.ac	2016-06-08 15:34:25.000000000 +0200
+++ gcc-6.2.0/gcc/configure.ac	2016-10-06 21:54:25.732246640 +0200
@@ -981,6 +981,7 @@
 [AS_HELP_STRING([--with-multilib-list], [select multilibs (AArch64, SH and x86-64 only)])],
 :,
 with_multilib_list=default)
+AC_SUBST(with_multilib_list)
 
 #---------------
 # Checks for other programs
diff -ruN gcc-6.2.0-original/gcc/Makefile.in gcc-6.2.0/gcc/Makefile.in
--- gcc-6.2.0-original/gcc/Makefile.in	2016-04-15 13:49:39.000000000 +0200
+++ gcc-6.2.0/gcc/Makefile.in	2016-10-06 21:54:25.735579948 +0200
@@ -546,6 +546,7 @@
 lang_specs_files=@lang_specs_files@
 lang_tree_files=@lang_tree_files@
 target_cpu_default=@target_cpu_default@
+with_multilib_list=@with_multilib_list@
 OBJC_BOEHM_GC=@objc_boehm_gc@
 extra_modes_file=@extra_modes_file@
 extra_opt_files=@extra_opt_files@
EOF
cd ${top}

echo "${bold}********** ${zlib}${normal}"
cp -R ${sources}/${zlib} ${buildNative}
cd ${buildNative}/${zlib}
echo "${bold}---------- ${zlib} configure${normal}"
./configure --static --prefix=$(pwd)/install
echo "${bold}---------- ${zlib} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${zlib} make install${normal}"
make install
cd ${top}

echo "${bold}********** ${gmp}${normal}"
mkdir -p ${buildNative}/${gmp}
cd ${buildNative}/${gmp}
savedCPPFLAGS=${CPPFLAGS-}
export CPPFLAGS="-fexceptions"
echo "${bold}---------- ${gmp} configure${normal}"
${top}/${sources}/${gmp}/configure \
	--prefix=$(pwd)/install \
	--enable-cxx \
	--disable-shared \
	--disable-nls
echo "${bold}---------- ${gmp} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${gmp} make install${normal}"
make install
export CPPFLAGS=${savedCPPFLAGS}
cd ${top}

echo "${bold}********** ${mpfr}${normal}"
mkdir -p ${buildNative}/${mpfr}
cd ${buildNative}/${mpfr}
echo "${bold}---------- ${mpfr} configure${normal}"
${top}/${sources}/${mpfr}/configure \
	--prefix=$(pwd)/install \
	--disable-shared \
	--disable-nls \
	--with-gmp=${top}/${buildNative}/${gmp}/install
echo "${bold}---------- ${mpfr} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${mpfr} make install${normal}"
make install
cd ${top}

echo "${bold}********** ${mpc}${normal}"
mkdir -p ${buildNative}/${mpc}
cd ${buildNative}/${mpc}
echo "${bold}---------- ${mpc} configure${normal}"
${top}/${sources}/${mpc}/configure \
	--prefix=$(pwd)/install \
	--disable-shared \
	--disable-nls \
	--with-gmp=${top}/${buildNative}/${gmp}/install \
	--with-mpfr=${top}/${buildNative}/${mpfr}/install
echo "${bold}---------- ${mpc} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${mpc} make install${normal}"
make install
cd ${top}

echo "${bold}********** ${isl}${normal}"
mkdir -p ${buildNative}/${isl}
cd ${buildNative}/${isl}
echo "${bold}---------- ${isl} configure${normal}"
${top}/${sources}/${isl}/configure \
	--prefix=$(pwd)/install \
	--disable-shared \
	--disable-nls \
	--with-gmp-prefix=${top}/${buildNative}/${gmp}/install
echo "${bold}---------- ${isl} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${isl} make install${normal}"
make install
cd ${top}

echo "${bold}********** ${libelf}${normal}"
mkdir -p ${buildNative}/${libelf}
cd ${buildNative}/${libelf}
echo "${bold}---------- ${libelf} configure${normal}"
${top}/${sources}/${libelf}/configure \
	--prefix=$(pwd)/install \
	--disable-shared \
	--disable-nls
echo "${bold}---------- ${libelf} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${libelf} make install${normal}"
make install
cd ${top}

echo "${bold}********** ${expat}${normal}"
mkdir -p ${buildNative}/${expat}
cd ${buildNative}/${expat}
echo "${bold}---------- ${expat} configure${normal}"
${top}/${sources}/${expat}/configure \
	--prefix=$(pwd)/install \
	--disable-shared \
	--disable-nls
echo "${bold}---------- ${expat} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${expat} make install${normal}"
make install
cd ${top}

echo "${bold}********** ${binutils}${normal}"
mkdir -p ${buildNative}/${binutils}
cd ${buildNative}/${binutils}
savedCFLAGS=${CFLAGS-}
savedCPPFLAGS=${CPPFLAGS-}
savedLDFLAGS=${LDFLAGS-}
export CFLAGS=-I${top}/${buildNative}/${zlib}/install/include
export CPPFLAGS=-I${top}/${buildNative}/${zlib}/install/include
export LDFLAGS=-L${top}/${buildNative}/${zlib}/install/lib
echo "${bold}---------- ${binutils} configure${normal}"
${top}/${sources}/${binutils}/configure \
	--target=${target} \
	--prefix=${top}/${installNative} \
	--disable-nls \
	--disable-sim \
	--disable-gdb \
	--disable-libdecnumber \
	--disable-readline \
	--enable-interwork \
	--enable-plugins \
	"--with-pkgversion=${pkgversion}"
echo "${bold}---------- ${binutils} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${binutils} make install${normal}"
make install
echo "${bold}---------- ${binutils} make install-html${normal}"
make install-html
#echo "${bold}---------- ${binutils} make install-pdf${normal}"
#make install-pdf
export CFLAGS=${savedCFLAGS}
export CPPFLAGS=${savedCPPFLAGS}
export LDFLAGS=${savedLDFLAGS}
cd ${top}

echo "${bold}********** ${gcc}${normal}"
mkdir -p ${buildNative}/${gcc}
cd ${buildNative}/${gcc}
echo "${bold}---------- ${gcc} configure${normal}"
${top}/${sources}/${gcc}/configure \
	--target=${target} \
	--prefix=${top}/${installNative} \
	--libexecdir=${top}/${installNative}/lib \
	--enable-languages=c \
	--disable-decimal-float \
	--disable-libffi \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libquadmath \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-nls \
	--disable-shared \
	--disable-threads \
	--disable-tls \
	--with-newlib \
	--without-headers \
	--with-gnu-as \
	--with-gnu-ld \
	--with-sysroot=${top}/${installNative}/${target} \
	--with-gmp=${top}/${buildNative}/${gmp}/install \
	--with-mpfr=${top}/${buildNative}/${mpfr}/install \
	--with-mpc=${top}/${buildNative}/${mpc}/install \
	--with-isl=${top}/${buildNative}/${isl}/install \
	"--with-pkgversion=${pkgversion}" \
	--with-multilib-list=armv6-m,armv7-m,armv7e-m,armv7-r
echo "${bold}---------- ${gcc} make all-gcc${normal}"
make -j$(nproc) all-gcc
echo "${bold}---------- ${gcc} make install-gcc${normal}"
make install-gcc
cd ${top}

echo "${bold}********** ${newlib}${normal}"
mkdir -p ${buildNative}/${newlib}
cd ${buildNative}/${newlib}
savedPATH=${PATH-}
savedCFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET-}
export PATH=${top}/${installNative}/bin:${PATH}
export CFLAGS_FOR_TARGET="-g -O2 -ffunction-sections -fdata-sections"
echo "${bold}---------- ${newlib} configure${normal}"
${top}/${sources}/${newlib}/configure \
	--target=${target} \
	--prefix=${top}/${installNative} \
	--enable-newlib-io-c99-formats \
	--enable-newlib-io-long-long \
	--disable-newlib-supplied-syscalls \
	--enable-newlib-reent-small \
	--disable-newlib-atexit-dynamic-alloc \
	--disable-newlib-fvwrite-in-streamio \
	--disable-newlib-fseek-optimization \
	--disable-newlib-wide-orient \
	--disable-newlib-unbuf-stream-opt \
	--enable-newlib-global-atexit \
	--disable-nls
echo "${bold}---------- ${newlib} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${newlib} make install${normal}"
make install
cd ${target}/newlib/libc
echo "${bold}---------- ${newlib} libc make install-html${normal}"
make install-html
#echo "${bold}---------- ${newlib} libc make install-pdf${normal}"
#make install-pdf
cd ../../..
cd ${target}/newlib/libm
echo "${bold}---------- ${newlib} libm make install-html${normal}"
make install-html
#echo "${bold}---------- ${newlib} libm make install-pdf${normal}"
#make install-pdf
cd ../../..
export PATH=${savedPATH}
export CFLAGS_FOR_TARGET=${savedCFLAGS_FOR_TARGET}
cd ${top}

echo "${bold}********** ${gcc} final${normal}"
mkdir -p ${buildNative}/${gcc}-final
cd ${buildNative}/${gcc}-final
savedCFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET-}
savedCXXFLAGS_FOR_TARGET=${CXXFLAGS_FOR_TARGET-}
export CFLAGS_FOR_TARGET="-g -O2 -ffunction-sections -fdata-sections -fno-exceptions"
export CXXFLAGS_FOR_TARGET="-g -O2 -ffunction-sections -fdata-sections -fno-exceptions"
echo "${bold}---------- ${gcc} final configure${normal}"
${top}/${sources}/${gcc}/configure \
	--target=${target} \
	--prefix=${top}/${installNative} \
	--libexecdir=${top}/${installNative}/lib \
	--enable-languages=c,c++ \
	--disable-libstdcxx-verbose \
	--enable-plugins \
	--disable-decimal-float \
	--disable-libffi \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libquadmath \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--disable-nls \
	--disable-shared \
	--disable-threads \
	--disable-tls \
	--with-gnu-as \
	--with-gnu-ld \
	--with-newlib \
	--with-headers=yes \
	--with-sysroot=${top}/${installNative}/${target} \
	--with-gmp=${top}/${buildNative}/${gmp}/install \
	--with-mpfr=${top}/${buildNative}/${mpfr}/install \
	--with-mpc=${top}/${buildNative}/${mpc}/install \
	--with-isl=${top}/${buildNative}/${isl}/install \
	"--with-pkgversion=${pkgversion}" \
	--with-multilib-list=armv6-m,armv7-m,armv7e-m,armv7-r
echo "${bold}---------- ${gcc} final make${normal}"
make -j$(nproc) INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
echo "${bold}---------- ${gcc} final make install${normal}"
make install
echo "${bold}---------- ${gcc} final make install-html${normal}"
make install-html
#echo "${bold}---------- ${gcc} final make install-pdf${normal}"
#make install-pdf
export CFLAGS_FOR_TARGET=${savedCFLAGS_FOR_TARGET}
export CXXFLAGS_FOR_TARGET=${savedCXXFLAGS_FOR_TARGET}
cd ${top}

echo "${bold}********** ${gdb}${normal}"
mkdir -p ${buildNative}/${gdb}
cd ${buildNative}/${gdb}
savedCFLAGS=${CFLAGS-}
savedCPPFLAGS=${CPPFLAGS-}
savedLDFLAGS=${LDFLAGS-}
export CFLAGS=-I${top}/${buildNative}/${zlib}/install/include
export CPPFLAGS=-I${top}/${buildNative}/${zlib}/install/include
export LDFLAGS=-L${top}/${buildNative}/${zlib}/install/lib
echo "${bold}---------- ${gdb} configure${normal}"
${top}/${sources}/${gdb}/configure \
	--target=${target} \
	--prefix=${top}/${installNative} \
	--disable-nls \
	--disable-sim \
	--disable-gas \
	--disable-binutils \
	--disable-ld \
	--disable-gprof \
	--with-libexpat \
	--with-lzma=no \
	--with-system-gdbinit=${top}/${installNative}/${target}/lib/gdbinit \
	--with-libexpat-prefix=${top}/${buildNative}/${expat}/install \
	--with-python=yes \
	"--with-gdb-datadir='\${prefix}'/${target}/share/gdb" \
	"--with-pkgversion=${pkgversion}"
echo "${bold}---------- ${gdb} make${normal}"
make -j$(nproc)
echo "${bold}---------- ${gdb} make install${normal}"
make install
echo "${bold}---------- ${gdb} make install-html${normal}"
make install-html
#echo "${bold}---------- ${gdb} make install-pdf${normal}"
#make install-pdf
export CFLAGS=${savedCFLAGS}
export CPPFLAGS=${savedCPPFLAGS}
export LDFLAGS=${savedLDFLAGS}
cd ${top}

echo "${bold}********** Post-cleanup${normal}"
find ${installNative} -name '*.la' -exec rm -rf {} +
find ${installNative}/${target}/bin \
	${installNative}/bin \
	${installNative}/lib/gcc/${target}/${gccVersion} \
	-type f -and -executable -exec strip {} \; || true
cat > ${installNative}/info.txt << EOF
${pkgversion}
build date: $(date +'%Y-%m-%d')
build system: $(uname -srvmo)
host system: $(uname -mo)
target system: ${target}
compiler: GCC $(gcc --version | grep -o '[0-9]\.[0-9]\.[0-9]')

Toolchain components:
- ${gcc} + multilib patch
- ${newlib}
- ${binutils}
- ${gdb}
- ${expat}
- ${gmp}
- ${isl}
- ${libelf}
- ${mpc}
- ${mpfr}
- ${zlib}

This script and info about it can be found on Freddie Chopin's website:
http://www.freddiechopin.info/
EOF
cp ${0} ${installNative}

echo "${bold}********** Package${normal}"
rm -rf ${package}
ln -s ${installNative} ${package}
rm -rf ${packageArchive}
XZ_OPT="-9e -T 0" tar -cJf ${packageArchive} --group=0 --owner=0 $(find ${package}/ -mindepth 1 -maxdepth 1)
rm -rf ${package}

echo "${bold}********** Done${normal}"