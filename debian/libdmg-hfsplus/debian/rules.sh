_commit="fb17a7b"

pkgname="libdmg-hfsplus"
pkgrel=1
url="https://github.com/glankk/libdmg-hfsplus"

pkgver() {
	rev=$(git -C "${pkgname}" rev-list --count "${_commit}")
	printf "0.r%s.%s" "${rev}" "${_commit}"
}

clean() {
	rm -f debian/files
	rm -rf debian/tmp/
	rm -rf "${pkgname}"/
}

prepare() {
	git clone -- "${url}.git" "${pkgname}"
	git -C "${pkgname}" checkout "${_commit}"

	host=$(dpkg-architecture -q DEB_HOST_GNU_TYPE)
	cpu=$(dpkg-architecture -q DEB_HOST_GNU_CPU)

	cmake -S "${pkgname}" -B build \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_SYSTEM_PROCESSOR=${cpu} \
		-DCMAKE_C_COMPILER=${host}-gcc \
		-DCMAKE_CXX_COMPILER=${host}-g++ \
		-DCMAKE_SYSROOT=/usr/${host} \
		-DCMAKE_SYSROOT_COMPILE= \
		-DCMAKE_SYSROOT_LINK=
}

build() {
	build-arch
}

build-arch() {
	prepare

	make -C build all
}

build-indep() {
	return 0
}

binary() {
	binary-arch
}

binary-arch() {
	pkgdir="${PWD}"/debian/tmp
	pkgver=$(pkgver)

	rm -rf "${pkgdir}"
	mkdir -p "${pkgdir}"
	mkdir -p "${pkgdir}"/DEBIAN

	make DESTDIR="${pkgdir}" -C build install/strip

	dpkg-gencontrol -v"${pkgver}-${pkgrel}" -p"${pkgname}"
	dpkg-deb -b "${pkgdir}" ..
}

binary-indep() {
	return 0
}
