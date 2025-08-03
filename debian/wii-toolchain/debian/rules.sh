_commit="0279cc9"
_binutils_ver=2.44
_gcc_ver=15.1.0
_newlib_ver=4.5.0.20241231
_gdb_ver=16.3

pkgname_arch=(
	"powerpc-eabi-binutils"
	"powerpc-eabi-gcc"
	"powerpc-eabi-gdb"
)
pkgname_indep=(
	"powerpc-eabi-gcc-libs"
	"powerpc-eabi-newlib"
)
pkgrel=1
url="https://github.com/PracticeROM/wii-toolchain"

pkgver() {
	rev=$(git -C wii-toolchain rev-list --count "${_commit}")
	printf "0.r%s.%s" "${rev}" "${_commit}"
}

clean() {
	rm -f debian/files
	rm -rf debian/tmp/
	rm -rf wii-toolchain/
}

prepare() {
	git clone -- "${url}.git" wii-toolchain
	git -C wii-toolchain checkout "${_commit}"

	build=$(dpkg-architecture -q DEB_BUILD_GNU_TYPE)
	host=$(dpkg-architecture -q DEB_HOST_GNU_TYPE)

	configure_toolchain=(
		"--libexecdir='\${exec_prefix}/lib'"
		"--build=${build}"
		"--host=${host}"
	)

	(cd wii-toolchain && ./configure \
		--prefix=/usr \
		--build=${build} \
		--host=${host} \
		--with-configure-toolchain="${configure_toolchain[*]}" \
		BINUTILS_VERSION="binutils-${_binutils_ver}" \
		GCC_VERSION="gcc-${_gcc_ver}" \
		NEWLIB_VERSION="newlib-${_newlib_ver}" \
		GDB_VERSION="gdb-${_gdb_ver}" \
		CFLAGS="${CFLAGS} -Wno-error=format-security" \
		CXXFLAGS="${CXXFLAGS} -Wno-error=format-security" \
		LDFLAGS="${LDFLAGS}"
	)
}

build() {
	prepare

	make -C wii-toolchain toolchain-all
}

build-arch() {
	prepare

	make -C wii-toolchain toolchain-all-binutils
	make -C wii-toolchain toolchain-all-gas
	make -C wii-toolchain toolchain-all-ld
	make -C wii-toolchain toolchain-all-gcc \
		TARGET-gcc=gcc-cross
	make -C wii-toolchain toolchain-all-gcc \
		TARGET-gcc="specs selftest" GCC_FOR_TARGET=true
	make -C wii-toolchain toolchain-all-gcc
	make -C wii-toolchain toolchain-all-c++tools
	make -C wii-toolchain toolchain-all-lto-plugin
	make -C wii-toolchain toolchain-all-libcc1
	make -C wii-toolchain toolchain-all-gdb
	make -C wii-toolchain toolchain-all-sim
}

build-indep() {
	prepare

	make -C wii-toolchain toolchain-all-target-libstdc++-v3
	make -C wii-toolchain toolchain-all-target-libssp
	make -C wii-toolchain toolchain-all-target-libgcc
	make -C wii-toolchain toolchain-all-target-newlib
	make -C wii-toolchain toolchain-all-target-libgloss
}

package() {
	pkgdir="${PWD}"/debian/tmp
	pkgver=$(pkgver)

	for pkg in "${@}"; do
		rm -rf "${pkgdir}"
		mkdir -p "${pkgdir}"
		mkdir -p "${pkgdir}"/DEBIAN

		depends=()

		package_${pkg}

		depends_value=
		for d in "${depends[@]}"; do
			depends_value="${depends_value}${depends_value:+, }${d}"
		done

		dpkg-gencontrol -v"${pkgver}-${pkgrel}" -p"${pkg}" -V"misc:Depends=${depends_value}"
		dpkg-deb -b "${pkgdir}" ..
	done
}

binary() {
	binary-arch
	binary-indep
}

binary-arch() {
	package "${pkgname_arch[@]}"
}

binary-indep() {
	package "${pkgname_indep[@]}"
}

package_powerpc-eabi-binutils() {
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-binutils
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-gas
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-ld

	rm -r "${pkgdir}"/usr/lib/ # bfd-plugins/libdep.so
	rm -r "${pkgdir}"/usr/share/info/
}

package_powerpc-eabi-gcc() {
	depends=(
		"powerpc-eabi-binutils"
		"powerpc-eabi-gcc-libs (= ${pkgver}-${pkgrel})"
		"powerpc-eabi-newlib (= ${pkgver}-${pkgrel})"
	)

	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-gcc \
		INSTALL_HEADERS=install-headers
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-c++tools
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-lto-plugin
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-libcc1

	rm "${pkgdir}"/usr/lib/libcc1*
	rm -r "${pkgdir}"/usr/share/info/
	rm -r "${pkgdir}"/usr/share/man/man3/
	rm -r "${pkgdir}"/usr/share/man/man7/
	find "${pkgdir}" -type f -name '*.la' -delete
}

package_powerpc-eabi-gcc-libs() {
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-target-libstdc++-v3
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-target-libssp
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-target-libgcc

	rm -r "${pkgdir}"/usr/share/ # gcc-${_gcc_ver}/python/libstdcxx/
	rm "${pkgdir}"/usr/lib/gcc/powerpc-eabi/"${_gcc_ver}"/include/unwind.h
	find "${pkgdir}" -type f -name '*.la' -delete
}

package_powerpc-eabi-newlib() {
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-target-newlib
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-target-libgloss

	rm -r "${pkgdir}"/usr/share/
}

package_powerpc-eabi-gdb() {
	sim_STRIP=$(
		grep "^STRIP = " wii-toolchain/build-toolchain/sim/Makefile |
		sed "s/STRIP = //"
	)

	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-gdb
	make DESTDIR="${pkgdir}" -C wii-toolchain toolchain-install-strip-sim \
		STRIPPROG="${sim_STRIP}"

	rm -r "${pkgdir}"/usr/include/
	rm -r "${pkgdir}"/usr/share/gdb/
	rm -r "${pkgdir}"/usr/share/info/
}
