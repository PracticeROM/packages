_commit="5c389f2"
_binutils_ver=2.44
_gcc_ver=15.1.0
_newlib_ver=4.5.0.20241231
_gdb_ver=16.3

pkgname_arch=(
	"mips64-ultra-elf-binutils"
	"mips64-ultra-elf-gcc"
	"mips64-ultra-elf-gdb"
	"practicerom-tools"
)
pkgname_indep=(
	"mips64-ultra-elf-gcc-libs"
	"mips64-ultra-elf-newlib"
	"mips64-ultra-elf-practicerom-libs"
)
pkgrel=1
url="https://github.com/glankk/n64"

pkgver() {
	rev=$(git -C n64 rev-list --count "${_commit}")
	printf "0.r%s.%s" "${rev}" "${_commit}"
}

clean() {
	rm -f debian/files
	rm -rf debian/tmp/
	rm -rf n64/
}

prepare() {
	git clone -- "${url}.git" n64
	git -C n64 checkout "${_commit}"

	build=$(dpkg-architecture -q DEB_BUILD_GNU_TYPE)
	host=$(dpkg-architecture -q DEB_HOST_GNU_TYPE)

	configure_toolchain=(
		"--libexecdir='\${exec_prefix}/lib'"
		"--build=${build}"
		"--host=${host}"
	)

	(cd n64 && ./configure \
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

	make -C n64 all
	make -C n64 toolchain-all
}

build-arch() {
	prepare

	make -C n64 all
	make -C n64 toolchain-all-binutils
	make -C n64 toolchain-all-gas
	make -C n64 toolchain-all-ld
	make -C n64 toolchain-all-gcc \
		TARGET-gcc=gcc-cross
	make -C n64 toolchain-all-gcc \
		TARGET-gcc="specs selftest" GCC_FOR_TARGET=true
	make -C n64 toolchain-all-gcc
	make -C n64 toolchain-all-c++tools
	make -C n64 toolchain-all-lto-plugin
	make -C n64 toolchain-all-libcc1
	make -C n64 toolchain-all-gdb
	make -C n64 toolchain-all-sim
}

build-indep() {
	prepare

	make -C n64 toolchain-all-target-libstdc++-v3
	make -C n64 toolchain-all-target-libssp
	make -C n64 toolchain-all-target-libgcc
	make -C n64 toolchain-all-target-newlib
	make -C n64 toolchain-all-target-libgloss
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

package_mips64-ultra-elf-binutils() {
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-binutils
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-gas
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-ld

	rm -r "${pkgdir}"/usr/lib/ # bfd-plugins/libdep.so
	rm -r "${pkgdir}"/usr/share/info/
}

package_mips64-ultra-elf-gcc() {
	depends=(
		"mips64-ultra-elf-binutils"
		"mips64-ultra-elf-gcc-libs (= ${pkgver}-${pkgrel})"
		"mips64-ultra-elf-newlib (= ${pkgver}-${pkgrel})"
	)

	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-gcc \
		INSTALL_HEADERS=install-headers
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-c++tools
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-lto-plugin
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-libcc1

	rm "${pkgdir}"/usr/lib/libcc1*
	rm -r "${pkgdir}"/usr/share/info/
	rm -r "${pkgdir}"/usr/share/man/man3/
	rm -r "${pkgdir}"/usr/share/man/man7/
	find "${pkgdir}" -type f -name '*.la' -delete
}

package_mips64-ultra-elf-gcc-libs() {
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-target-libstdc++-v3
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-target-libssp
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-target-libgcc

	rm -r "${pkgdir}"/usr/share/ # gcc-${_gcc_ver}/python/libstdcxx/
	rm "${pkgdir}"/usr/lib/gcc/mips64-ultra-elf/"${_gcc_ver}"/include/unwind.h
	find "${pkgdir}" -type f -name '*.la' -delete
}

package_mips64-ultra-elf-newlib() {
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-target-newlib
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-target-libgloss

	rm -r "${pkgdir}"/usr/share/
}

package_mips64-ultra-elf-gdb() {
	sim_STRIP=$(
		grep "^STRIP = " n64/build-toolchain/sim/Makefile |
		sed "s/STRIP = //"
	)

	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-gdb
	make DESTDIR="${pkgdir}" -C n64 toolchain-install-strip-sim \
		STRIPPROG="${sim_STRIP}"

	rm -r "${pkgdir}"/usr/include/
	rm -r "${pkgdir}"/usr/share/gdb/
	rm -r "${pkgdir}"/usr/share/info/
}

package_mips64-ultra-elf-practicerom-libs() {
	make DESTDIR="${pkgdir}" -C n64 install-sys
}

package_practicerom-tools() {
	make DESTDIR="${pkgdir}" -C n64 install-strip

	mv "${pkgdir}"/usr/bin/gs "${pkgdir}"/usr/bin/n64-gs
}
