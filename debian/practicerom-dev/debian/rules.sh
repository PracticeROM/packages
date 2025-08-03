clean() {
	rm -f debian/files
	rm -rf debian/tmp/
}

build() {
	return 0
}

build-arch() {
	return 0
}

build-indep() {
	return 0
}

binary() {
	binary-indep
}

binary-arch() {
	return 0
}

binary-indep() {
	pkgdir="${PWD}"/debian/tmp

	rm -rf "${pkgdir}"
	mkdir -p "${pkgdir}"
	mkdir -p "${pkgdir}"/DEBIAN

	dpkg-gencontrol
	dpkg-deb -b "${pkgdir}" ..
}
