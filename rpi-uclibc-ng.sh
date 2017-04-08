#!/bin/sh

set -e

target=""

kernel_version="4.10.9"
uclibcng_version="1.0.23"
binutils_version="2.28"
gcc_version="6.3.0"
gmp_version="6.1.2"
mpfr_version="3.1.5"
mpc_version="1.0.3"
isl_version="0.18"

current_dir="`pwd`"
working_dir="/tmp/toolchain"
download_dir="${current_dir}/download"
source_dir="${working_dir}/source"
build_dir="${working_dir}/build"

linux_source_dir="${source_dir}/linux-${kernel_version}"
uclibcng_source_dir="${source_dir}/uClibc-ng-${uclibcng_version}"
binutils_source_dir="${source_dir}/binutils-${binutils_version}"
gcc_source_dir="${source_dir}/gcc-${gcc_version}"
gmp_source_dir="${source_dir}/gmp-${gmp_version}"
mpfr_source_dir="${source_dir}/mpfr-${mpfr_version}"
mpc_source_dir="${source_dir}/mpc-${mpc_version}"
isl_source_dir="${source_dir}/isl-${mpc_version}"

linux_build_dir="${build_dir}/linux-${kernel_version}"
uclibcng_build_dir="${build_dir}/uClibc-ng-${uclibcng_version}"
binutils_build_dir="${build_dir}/binutils-${binutils_version}"
gcc_build_dir="${build_dir}/gcc-${gcc_version}"
gmp_build_dir="${build_dir}/gmp-${gmp_version}"
mpfr_build_dir="${build_dir}/mpfr-${mpfr_version}"
mpc_build_dir="${build_dir}/mpc-${mpc_version}"
isl_build_dir="${build_dir}/isl-${mpc_version}"

parallel_build="$(expr `nproc` + 2)"

# check working directory
if [ ! -d "${working_dir}" ]; then
  mkdir -p "${working_dir}"
fi

# check download directory
if [ ! -d "${download_dir}" ]; then
  mkdir -p "${download_dir}"
fi

# check source directory
if [ ! -d "${source_dir}" ]; then
  mkdir -p "${source_dir}"
fi

# check build directory
if [ ! -d "${build_dir}" ]; then
  mkdir -p "${build_dir}"
fi

# change working directory
cd "${working_dir}"

# download linux kernel source archive
if [ ! -f "${download_dir}/linux-${kernel_version}.tar.xz" ]; then
  wget -P "${download_dir}" "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${kernel_version}.tar.xz"
fi

# download uclibc-ng source archive
if [ ! -f "${download_dir}/uClibc-ng-${uclibcng_version}.tar.xz" ]; then
  wget -P "${download_dir}" "https://downloads.uclibc-ng.org/releases/${uclibcng_version}/uClibc-ng-${uclibcng_version}.tar.xz"
fi

# download binutils source archive
if [ ! -f "${download_dir}/binutils-${binutils_version}.tar.bz2" ]; then
  wget -P "${download_dir}" "http://ftp.jaist.ac.jp/pub/GNU/binutils/binutils-${binutils_version}.tar.bz2"
fi

# download gcc source archive
if [ ! -f "${download_dir}/gcc-${gcc_version}.tar.bz2" ]; then
  wget -P "${download_dir}" "http://ftp.jaist.ac.jp/pub/GNU/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.bz2"
fi

# download gmp source archive
if [ ! -f "${download_dir}/gmp-${gmp_version}.tar.bz2" ]; then
  wget -P "${download_dir}" "http://ftp.jaist.ac.jp/pub/GNU/gmp/gmp-${gmp_version}.tar.bz2"
fi

# download mpfr source archive
if [ ! -f "${download_dir}/mpfr-${mpfr_version}.tar.bz2" ]; then
  wget -P "${download_dir}" "http://ftp.jaist.ac.jp/pub/GNU/mpfr/mpfr-${mpfr_version}.tar.bz2"
fi

# download mpc source archive
if [ ! -f "${download_dir}/mpc-${mpc_version}.tar.gz" ]; then
  wget -P "${download_dir}" "http://ftp.jaist.ac.jp/pub/GNU/mpc/mpc-${mpc_version}.tar.gz"
fi

# download isl source archive
if [ ! -f "${download_dir}/isl-${isl_version}.tar.bz2" ]; then
  wget -P "${download_dir}" "http://isl.gforge.inria.fr/isl-${isl_version}.tar.bz2"
fi

# cleanup build directory
rm -fr "${build_dir}"

# extract linux kernel source archive
if [ ! -d "${linux_source_dir}" ]; then
  echo "extract linux kernel source"
  tar -xf "${download_dir}/linux-${kernel_version}.tar.xz" -C "${source_dir}"
fi

# extract uclibc-ng source archive
if [ ! -d "${uclibcng_source_dir}" ]; then
  echo "extract uclibc-ng source"
  tar -xf "${download_dir}/uClibc-ng-${uclibcng_version}.tar.xz" -C "${source_dir}"
fi

# extract binutils source archive
if [ ! -d "${binutils_source_dir}" ]; then
  echo "extract binutils source"
  tar -xf "${download_dir}/binutils-${binutils_version}.tar.bz2" -C "${source_dir}"
fi

# extract gcc source archive
if [ ! -d "${gcc_source_dir}" ]; then
  echo "extract gcc source"
  tar -xf "${download_dir}/gcc-${gcc_version}.tar.bz2" -C "${source_dir}"
fi

# extract gmp source archive
if [ ! -d "${gmp_source_dir}" ]; then
  echo "extract gmp source"
  tar -xf "${download_dir}/gmp-${gmp_version}.tar.bz2" -C "${source_dir}"
fi

# extract mpfr source archive
if [ ! -d "${mpfr_source_dir}" ]; then
  echo "extract mpfr source"
  tar -xf "${download_dir}/mpfr-${mpfr_version}.tar.bz2" -C "${source_dir}"
fi

# extract mpc source archive
if [ ! -d "${mpc_source_dir}" ]; then
  echo "extract mpc source"
  tar -xf "${download_dir}/mpc-${mpc_version}.tar.gz" -C "${source_dir}"
fi

# extract isl source archive
if [ ! -d "${source_dir}/isl-${isl_version}" ]; then
  echo "extract isl source"
  tar -xf "${download_dir}/isl-${isl_version}.tar.bz2" -C "${source_dir}"
fi

# install linux kernel headers
make -C "${linux_source_dir}" -j ${parallel_build} O="${linux_build_dir}" INSTALL_HDR_PATH="${linux_build_dir}-headers" headers_install

# default configure uclibc-ng
make -C "${uclibcng_source_dir}" -j ${parallel_build} O="${uclibcng_build_dir}" defconfig

# custom configure uclibc-ng
if [ -f "${current_dir}/uclibcng_defconfig" ]; then
  cp "${current_dir}/uclibcng_defconfig" "${uclibcng_build_dir}/.config"
  make -C "${uclibcng_source_dir}" -j ${parallel_build} O="${uclibcng_build_dir}" silentoldconfig
else
  make -C "${uclibcng_source_dir}" -j ${parallel_build} O="${uclibcng_build_dir}" menuconfig
fi

# directory configure uclibc-ng
sed -i -e "s@KERNEL_HEADERS=.*@KERNEL_HEADERS=\"${linux_build_dir}-headers/include\"@" "${uclibcng_build_dir}/.config"
sed -i -e "s@RUNTIME_PREFIX=.*@RUNTIME_PREFIX=\"${uclibcng_build_dir}-runtime\"@" "${uclibcng_build_dir}/.config"
sed -i -e "s@DEVEL_PREFIX=.*@DEVEL_PREFIX=\"${uclibcng_build_dir}-devel\"@" "${uclibcng_build_dir}/.config"

# build/install uclibc-ng
make -C "${uclibcng_source_dir}" -j ${parallel_build} O="${uclibcng_build_dir}" install

# build&install binutils
mkdir -p "${binutils_build_dir}"
cd "${binutils_build_dir}"
${binutils_source_dir}/configure --prefix=${binutils_build_dir}-prefix --with-sysroot=${binutils_build_dir}-sysroot
cd "${working_dir}"

# change current directory
cd "${current}"
