pkgname="practicerom-repository"
pkgver=1

clean() {
	rm -f debian/files
	rm -rf debian/tmp/
	rm -rf "${pkgname}"/
}

build() {
	build-arch
}

build-arch() {
	return 0
}

build-indep() {
	return 0
}

binary() {
	binary-arch
}

binary-arch() {
	arch=$(dpkg-architecture -q DEB_HOST_ARCH)
	pkgdir="${PWD}"/debian/tmp

	rm -rf "${pkgdir}"/
	mkdir -p "${pkgdir}"
	mkdir -p "${pkgdir}"/DEBIAN

	mkdir -p "${pkgdir}"/etc/apt/sources.list.d
	mkdir -p "${pkgdir}"/usr/share/keyrings

	cp practicerom.sources."${arch}" "${pkgdir}"/etc/apt/sources.list.d/practicerom.sources
	cp practicerom-archive-keyring.gpg "${pkgdir}"/usr/share/keyrings/

	dpkg-gencontrol -v"${pkgver}" -p"${pkgname}"
	dpkg-deb -b "${pkgdir}" ..
}

binary-indep() {
	return 0
}
